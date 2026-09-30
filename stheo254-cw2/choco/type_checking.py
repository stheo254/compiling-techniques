from __future__ import annotations

from abc import ABC
from dataclasses import dataclass
from functools import reduce
from typing import Dict, List, Optional, Tuple, Union

from xdsl.context import MLContext
from xdsl.dialects.builtin import ModuleOp
from xdsl.ir import Attribute, Operation
from xdsl.passes import ModulePass

from choco.ast_visitor import Visitor
from choco.dialects import choco_ast, choco_type
from choco.semantic_error import SemanticError


class Type(ABC):
    @staticmethod
    def from_op(op: Operation) -> "Type":
        if isinstance(op, choco_ast.TypeName):
            name = op.type_name.data  # type: ignore
            if name == "int":
                return int_type
            if name == "bool":
                return bool_type
            if name == "str":
                return str_type
            if name == "<None>":
                return none_type
            if name == "<Empty>":
                return empty_type
            if name == "object":
                return object_type
            raise Exception(f"Found type with unknown name `{name}'")
        if isinstance(op, choco_ast.ListType):
            elem_type = Type.from_op(op.elem_type.op)
            return ListType(elem_type)
        raise Exception(f"Found {op}, expected TypeName or ListType")

    @staticmethod
    def from_attribute(attr: Attribute) -> "Type":
        if isinstance(attr, choco_type.NamedType):
            name: str = attr.type_name.data  # type: ignore
            if name == "int":
                return int_type
            if name == "bool":
                return bool_type
            if name == "str":
                return str_type
            if name == "<None>":
                return none_type
            if name == "<Empty>":
                return empty_type
            if name == "object":
                return object_type
            raise Exception(f"Found type with unknown name `{name}'")
        if isinstance(attr, choco_type.ListType):
            elem_type = Type.from_attribute(attr.elem_type)  # type: ignore
            return ListType(elem_type)
        raise Exception(f"Found {attr}, expected TypeName or ListType")


@dataclass
class BasicType(Type):
    name: str


@dataclass
class ListType(Type):
    elem_type: Type


class BottomType(Type):  # "⊥"
    pass


class ObjectType(Type):  # "object"
    pass


@dataclass
class FunctionType(Type):  # input0 x ... x inputN -> output
    inputs: List[Type]
    output: Type


int_type = BasicType("int")
bool_type = BasicType("bool")
str_type = BasicType("str")
none_type = BasicType("<None>")
empty_type = BasicType("<Empty>")
bottom_type = BottomType()
object_type = ObjectType()


def to_attribute(t: Type) -> Attribute:
    if t == int_type:
        return choco_type.int_type
    elif t == bool_type:
        return choco_type.bool_type
    elif t == str_type:
        return choco_type.str_type
    elif t == none_type:
        return choco_type.none_type
    elif t == empty_type:
        return choco_type.empty_type
    elif t == object_type:
        return choco_type.object_type
    elif isinstance(t, ListType):
        elem_type = to_attribute(t.elem_type)
        return choco_type.ListType([elem_type])
    else:
        raise Exception(f"Can't translate {t} into an attribute")


def join(t1: Type, t2: Type) -> Type:
    if is_assignment_compatible(t1, t2):
        return t2
    if is_assignment_compatible(t2, t1):
        return t1
    else:
        return object_type


def is_subtype(t1: Type, t2: Type) -> bool:
    if t1 == t2:
        return True
    elif t2 == object_type and (
        t1 == int_type or t1 == bool_type or t1 == str_type or isinstance(t1, ListType)
    ):
        return True
    elif t1 == none_type and t2 == object_type:
        return True
    elif t1 == empty_type and t2 == object_type:
        return True
    elif t1 == bottom_type:
        return True
    else:
        return False


def is_assignment_compatible(t1: Type, t2: Type) -> bool:
    if is_subtype(t1, t2) and t1 != bottom_type:
        return True
    elif (
        (t1 == none_type)
        and t2 != int_type
        and t2 != bool_type
        and t2 != str_type
        and t2 != bottom_type
    ):
        return True
    elif isinstance(t2, ListType) and t1 == empty_type:
        return True
    elif (
        isinstance(t2, ListType)
        and isinstance(t1, ListType)
        and t1.elem_type == none_type
        and is_assignment_compatible(none_type, t2.elem_type)
    ):
        return True
    else:
        return False


def check_assignment_compatibility(t1: Type, t2: Type):
    if not is_assignment_compatible(t1, t2):
        raise SemanticError(f" Expected {t1} and {t2} to be assignment compatible")


def check_type(found: Type, expected: Type):
    if found != expected:
        raise SemanticError(f"Found `{found}' but expected {expected}")


def check_list_type(found: Type) -> Type:
    if not isinstance(found, ListType):
        raise SemanticError(f"Found `{found}' but expected a list type")
    else:
        return found.elem_type


@dataclass
class FunctionInfo:
    func_type: FunctionType
    params: List[str]
    nested_defs: List[Tuple[str, Type]]

    def __post_init__(self):
        if len(self.func_type.inputs) != len(self.params):
            raise Exception(f"Expected same number of input types and parameter names")


LocalEnvironment = Dict[str, Union[Type, FunctionInfo]]


def type_checking(_: MLContext, module: ModuleOp):
    o = build_env(module)
    r = bottom_type

    program = module.ops.first
    assert isinstance(program, choco_ast.Program)
    defs = list(program.defs.ops)
    if len(defs) >= 1:
        check_stmt_or_def_list(o, r, defs)
    stmts = list(program.stmts.ops)
    if len(stmts) >= 1:
        check_stmt_or_def_list(o, r, stmts)


class TypeChecking(ModulePass):
    name = "type-checking"

    def apply(self, ctx: MLContext, op: ModuleOp) -> None:
        type_checking(ctx, op)


# Build local environments
def build_env(module: ModuleOp) -> LocalEnvironment:
    o: LocalEnvironment = {
        "len": FunctionInfo(FunctionType([object_type], int_type), ["arg"], []),
        "print": FunctionInfo(FunctionType([object_type], none_type), ["arg"], []),
        "input": FunctionInfo(FunctionType([], str_type), [], []),
    }

    @dataclass
    class BuildEnvVisitor(Visitor):
        o: LocalEnvironment

        def visit_typed_var(self, typed_var: choco_ast.TypedVar):
            name, type = typed_var.var_name.data, Type.from_op(  # type: ignore
                typed_var.type.op
            )
            self.o.update({name: type})

        def traverse_func_def(self, func_def: choco_ast.FuncDef):
            f: str = func_def.func_name.data  # type: ignore
            # collect function parameter names and types
            xs: List[str] = []
            ts: List[Type] = []
            for op in func_def.params.ops:
                assert isinstance(op, choco_ast.TypedVar)
                name, type = op.var_name.data, Type.from_op(op.type.op)  # type: ignore
                xs.append(name)
                ts.append(type)
            # collect return type
            t = (
                Type.from_op(func_def.return_type.op)
                if (len(func_def.return_type.ops) == 1)
                else none_type
            )
            # collect nested variable definitions
            body_visitor = BuildEnvVisitor({})
            for op in func_def.func_body.ops:
                body_visitor.traverse(op)
            vs: List[Tuple[str, Type]] = []
            for var_name, var_type in body_visitor.o.items():
                assert isinstance(var_type, Type)
                vs.append((var_name, var_type))

            o.update({f: FunctionInfo(FunctionType(ts, t), xs, vs)})

    BuildEnvVisitor(o).traverse(module)

    return o


# Dispatch to typing rules to decide which rule to invoke

def check_stmt_or_def_list(o: LocalEnvironment, r: Type, ops: List[Operation]):
    return stmt_def_list_rule(o, r, ops)


def check_stmt_or_def(o: LocalEnvironment, r: Type, op: Operation):
    if isinstance(op, choco_ast.VarDef):
        typed_var = op.typed_var.op
        assert isinstance(typed_var, choco_ast.TypedVar)
        id = typed_var.var_name.data  # type: ignore
        e1 = op.literal.op
        return var_init_rule(o, r, id, e1)
    elif isinstance(op, choco_ast.Assign):
        target = op.target.op
        value = op.value.op
        print(f"assign target:{value}")
        if isinstance(value, choco_ast.Assign):
            print(f"go to func multi_assign")
            return multi_assign_stmt(o, r, target, value)
        return var_assign_stmt_rule(o, r, target, value)
    elif isinstance(op, choco_ast.Pass):
        pass_rule(o, r)
    elif isinstance(op, choco_ast.Return):
        ret = op.value.op
        print(f"ret {ret}")
        return return_e_rule(o, r, ret)
    elif isinstance(op, choco_ast.If):
        cond = op.cond.op
        then = op.then.op
        print(f"in istnace if {op.orelse.ops}")
        or_else = op.orelse
        return if_else_rule(o, r, cond, then, or_else)
    elif isinstance(op, choco_ast.While):
        cond = op.cond.op
        body = op.body.op

        while_rule(o, r, cond, body)
    elif isinstance(op, choco_ast.For):
        body = op.body.op
        iter_name = op.iter_name.data
        iter_body = op.iter.op

        if check_expr(o, r, iter_body) == str_type:
            for_str_rule(o, r, iter_body, iter_name, body)
        else:
            for_list_rule(o, r, iter_body, iter_name, body)

    elif isinstance(op, choco_ast.GlobalDecl):
        if op.decl_name.data in o:
            return True
        else:
            return False
    elif isinstance(op, choco_ast.NonLocalDecl):
        raise Exception(
            "Support for choco_ast.NonLocalDecl not implemented yet"
            )
    elif isinstance(op, choco_ast.FuncDef):
        print(f"o in instance {o}")
        func_name = op.func_name.data
        body = op.func_body.ops
        ret = op.return_type.op
        print(f"body: {body}")
        return func_def_rule(o, r, func_name, body, ret)
    else:
        return expr_stmt_rule(o, r, op)


def check_expr(o: LocalEnvironment, r: Type, op: Operation) -> Type:
    t: Optional[Type] = None
    if isinstance(op, choco_ast.Literal):
        t = literal_rules(o, r, op)
    elif isinstance(op, choco_ast.UnaryExpr):
        op_name = op.op.data  # type: ignore
        e = op.value.op
        if op_name == "-":
            t = negate_rule(o, r, e)
        else:
            t = not_rule(o, r, e)
    elif isinstance(op, choco_ast.BinaryExpr):
        oper = op.op.data
        lhs = op.lhs.op
        rhs = op.rhs.op
        print(f"in binary {op}")
        if oper in ["+", "-", "*", "//", "%"]:
            print("xd")
            if oper == "+":
                if compare_type_determination(o, r, lhs, rhs) == int_type:
                    t = arith_rule(o, r, oper, lhs, rhs)
                if compare_type_determination(o, r, lhs, rhs) == str_type:
                    t = str_concat_rule(o, r, lhs, rhs)
                else:
                    t = list_concat_rule(o, r, lhs, rhs)
            else:
                t = arith_rule(o, r, oper,lhs,rhs)
        elif oper in ["<", "<=", ">", ">=", "==", "!="]:
            if compare_type_determination(o,r,lhs, rhs) == int_type:
                t = int_compare_rule(o, r, oper, lhs, rhs)
            elif compare_type_determination(o, r, lhs, rhs) == bool_type:
                print("to function bool compare")
                t = bool_compare_rule(o, r, oper, lhs, rhs)
            elif compare_type_determination(o, r, lhs, rhs) == str_type:
                t = str_compare_rule(o, r, oper, lhs, rhs)
            else:
                raise SemanticError("not applicable")
        elif oper == "and":
            t = and_rule(o, r, lhs, rhs)
        elif oper == "or":
            t = or_rule(o, r, lhs, rhs)
        elif oper == "is":
            t = is_rule(o, r, lhs, rhs)

    elif isinstance(op, choco_ast.ExprName):
        t = var_read_rule(o, r, op.id.data)  # type: ignore
    elif isinstance(op, choco_ast.IfExpr):
        e0 = op.cond.op
        e1 = op.then.op
        e2 = op.or_else.op
        t = cond_rule(o, r, e1, e0, e2)

    elif isinstance(op, choco_ast.IndexExpr):
        value = op.value.op
        idx = op.index.op
        print(f"isinstance indexexpr :::: value:{value} idk:{idx}")
        
        t = list_select_rule(o, r, value, idx)
    elif isinstance(op, choco_ast.ListExpr):
        elems = op.elems.ops
        print(elems)

        t = list_display_rule(o, r, elems)
    elif isinstance(op, choco_ast.CallExpr):
        func = op.func.data
        args = op.args.ops
        t = invoke_rule(o, r, func, args)
    print(f"t in check_expr {t} {Type}")
    assert isinstance(t, Type)

    op.properties["type_hint"] = to_attribute(t)

    return t


# Typing rules, each typing rule is implemented by a corresponding function


def compare_type_determination(o:LocalEnvironment, r:Type, e1: Operation, e2:Operation) -> Type:
    t1 = check_expr(o, r, e1)
    t2 = check_expr(o, r, e2)

    if t1 == int_type and t1 == t2:
        return int_type
    if t1 == bool_type and t1 == t2:
        return bool_type
    if t1 == str_type and t1 == t2:
        return str_type
    if t1 == t2: 
        return none_type
    print(f"is isntace or not {isinstance(t1, choco_ast.ListType)} {t1} {repr(t1)}")
    raise SemanticError(f"type not the same t1:{t1} t2:{t2} ")

# [VAR-READ] rule
# O, R |- id: T
def var_read_rule(o: LocalEnvironment, r: Type, id: str) -> Type:
    # O(id) = T, where T is not a function type.
        print("in var_read_rule")
        t = o.get(id)
        if t is None:
            raise SemanticError(f"Unknown identifier {id} used")
        if isinstance(t, FunctionInfo):
            raise SemanticError(
                    f"Function identifier `{id}' used where value identifier expected"
                    )
        print(f"varreadrule t:{t}")
        return t


# [VAR-INIT] rule
# O, R |- id: T = e1
def var_init_rule(o: LocalEnvironment, r: Type, id: str, e1: Operation):
        print("var_init_rule")
        # O(id) = T
        t = o[id]
        if isinstance(t, FunctionInfo):
            raise SemanticError(
                    f"Function identifier `{id}' used where value identifier expected"
                    )
        # O, R |- e1: T1
        t1 = check_expr(o, r, e1)
        # T1 ≤a T
        check_assignment_compatibility(t1, t)


# [VAR-ASSIGN-STMT]
# O, R |- id = e1
def var_assign_stmt_rule(o: LocalEnvironment, r: Type, id: Operation, e1: Operation):
        print("in var_assign_stmt_rule")
        print(id)
        print(e1)
        #O(id) = T
        t = check_expr(o, r, id)
        print(f"in var assign {isinstance(e1,choco_ast.Assign)}")
        if isinstance(t,FunctionInfo):
            raise SemanticError(
                    f"Function identifier `{id}' used where value identifier expected"
                    )
        #O, R ⊢ e₁ : T₁
        t1 = check_expr(o, r, e1)
        print(f"after check_expr in var_assign {t} :::: {t1}")
        #T₁ ≤a T
        check_assignment_compatibility(t1, t)
        # O, R ⊢ id = e₁


# [STMT-DEF-LIST] rule
# O, R |- s1 NEWLINE s2 NEWLINE . . . sn NEWLINE
def stmt_def_list_rule(o: LocalEnvironment, r: Type, sns: List[Operation]):
        print("in stmt_def_list_rule")
        # n >= 1
        assert len(sns) >= 1
        for sn in sns:
            # O, R |- sn
            check_stmt_or_def(o, r, sn)


# [PASS] rule
# O, R |- pass
def pass_rule(o: LocalEnvironment, r: Type):
        pass


# [EXPR-STMT] rule
# O, R |- e
def expr_stmt_rule(o: LocalEnvironment, r: Type, e: Operation):
        print("in expr_stmt_rule")
        # O, R |- e: T
        _t = check_expr(o, r, e)


# noinspection PySimplifyBooleanCheck
# O, R |- lit: T
def literal_rules(o: LocalEnvironment, r: Type, lit: choco_ast.Literal) -> Type:
    print("in literal rules")
    if isinstance(lit.value, choco_ast.BoolAttr):
        # [BOOL-FALSE] rule
        if lit.value.data == False:
            return bool_type
        # [BOOL-TRUE] rule
        if lit.value.data == True:
            return bool_type
    # [NONE] rule
    if isinstance(lit.value, choco_ast.NoneAttr):
        return none_type
    # [INT] rule
    if isinstance(lit.value, choco_ast.IntegerAttr):
        return int_type
    # [STR] rule
    if isinstance(lit.value, choco_ast.StringAttr):
        return str_type
    raise Exception(f"Could not type check literal `{lit}'")


# [NEGATE] rule
# O, R, |- - e: int
def negate_rule(o: LocalEnvironment, r: Type, e: Operation) -> Type:
    print("in negate_rule")
    # O, R, |- e: int
    check_type(check_expr(o, r, e), expected=int_type)
    return int_type


# [ARITH] rule
# O, R |- e1 op e2 : int
def arith_rule(o: LocalEnvironment, r: Type, op: str, e0: Operation, e1:Operation) -> Type:
    print("in arith_rule")
    check_type(check_expr(o, r, e0), expected=int_type)
    check_type(check_expr(o, r, e1), expected=int_type)

    if op not in ["+", "-", "*", "//", "%"]:
        raise Exception(f"{op} not in comp op")

    return int_type

# [INT-COMPARE] rule
# O, R |- e1 cmp_op e2 : bool
def int_compare_rule(o: LocalEnvironment, r: Type, op: str, e0: Operation, e1: Operation) -> Type:
    print("in int_compare_rule")
    check_type(check_expr(o, r, e0), expected=int_type)
    check_type(check_expr(o, r, e1), expected=int_type)

    if op not in ["<", "<=", ">", ">=", "==", "!="]:
        raise Exception(f"{op} not in comp op")

    return bool_type
#     ???

# [BOOL-COMPARE] rule
# O, R |- e1 cmp_op e2 : bool
def bool_compare_rule(o: LocalEnvironment, r: Type, op: str, e0: Operation, e1:Operation) -> Type:
    print("bool compare rule")
    check_type(check_expr(o, r, e0), expected=bool_type)
    check_type(check_expr(o, r, e1), expected=bool_type)

    if op not in ["==", "!="]:
        raise Exception(f"{op} not in comp op")

    return bool_type

# [AND] rule
# O, R |- e1 and e2 : bool
def and_rule(o: LocalEnvironment, r: Type, e1: Operation, e2:Operation) -> Type:
    print("and_rule")
    check_type(check_expr(o, r, e1), expected=bool_type)
    check_type(check_expr(o, r, e2), expected=bool_type)
    return bool_type
#     ???

# [OR] rule
# O, R |- e1 or e2 : bool
def or_rule(o: LocalEnvironment, r: Type, e1: Operation, e2: Operation) -> Type:
    print("or_rule")
    check_type(check_expr(o, r, e1), expected=bool_type)
    check_type(check_expr(o, r, e2), expected=bool_type)
    return bool_type

# [NOT] rule
# O, R |- not e : bool
def not_rule(o: LocalEnvironment, r: Type, e2: Operation) -> Type:
    print("not_rule")
    check_type(check_expr(o, r, e2), expected=bool_type)
    return bool_type


# [COND] rule
# O, R |- e1 if e0 else e2 : T1 |_| T2
def cond_rule(
        o: LocalEnvironment, r: Type, e1: Operation, e0: Operation, e2: Operation
        ) -> Type:
    print("in cond_rule")
    # O, R |- e0: bool
    check_type(check_expr(o, r, e0), expected=bool_type)
    # O, R |- e1: t1
    t1 = check_expr(o, r, e1)
    # O, R |- e2: t2
    t2 = check_expr(o, r, e2)

    return join(t1, t2)


# [STR-COMPARE] rule
# O, R |- e1 cmp_op e2 : bool
def str_compare_rule(o: LocalEnvironment, r: Type, op: str, e1:Operation, e0:Operation) -> Type:
    print("str_compare_rule")
    print(f"str_cpompare {e0}")
    check_type(check_expr(o, r, e0), expected=str_type)
    check_type(check_expr(o, r, e1), expected=str_type)
    if op not in ["==", "!="]:
        raise Exception(f"{op} not in comp op")

    return bool_type

# [STR-CONCAT]
# O, R |- e1 + e2 : str
def str_concat_rule(o: LocalEnvironment, r: Type, e1: Operation, e2:Operation) -> Type:
    print("str_concat_rule")
    check_type(check_expr(o, r, e1), expected=str_type)
    check_type(check_expr(o, r, e2), expected=str_type)

    return str_type


# [STR-SELECT]
# O, R |- e1[e2] : str
def str_select_rule(o: LocalEnvironment, r: Type, t: Type, e2:Operation) -> Type:
    print("str_select_rule")
    #O, R ⊢ e₁ : str
    check_type(t, expected=str_type)
    #O, R ⊢ e₂ : int
    check_type(check_expr(o, r, e2), expected=int_type)

    return str_type



# [IS]
# O, R |- e1 is e2 : bool
def is_rule(o: LocalEnvironment, r: Type, e0: Operation, e1:Operation) -> Type:
    t1 = check_expr(o, r, e0)
    t2 = check_expr(o, r, e1)
    print(f"in is_rule t1 = {t1} t2 = {t2} check: {t1 == int_type}")

    if t1 not in [str_type, int_type, bool_type] and t2 not in [str_type, int_type, bool_type]:
        return bool_type
    else:
        raise SemanticError("not in str, int, bool")

# [LIST-DISPLAY]
# O, R |- [e1, e2, ..., en] : [T]
def list_display_rule(o: LocalEnvironment, r: Type, es: [Operation]) -> Type:
    print("list_display_rule")
    print(es)
    if len(es) < 1:
        return nil_rule(o, r, es)
    ts = []
    for e in es:
        # O, R |- sn
        ts.append(check_expr(o, r, e))
    xd = ts[0]
    for t in ts:
        # O, R |- sn
        xd = join(xd, t)
        
    return ListType(xd)

# [NIL]
# O, R |- [] : <Empty>
def nil_rule(o: LocalEnvironment, r: Type, es:[Operation]) -> Type:
    print("nil rule")
    assert len(es) < 1
    return empty_type

# [LIST-CONCAT]
# O, R |- e1 + e2 : [T]
def list_concat_rule(o: LocalEnvironment, r: Type, e1:Operation, e2:Operation) -> Type:
    print("list_concat_rule")
    t1 = check_expr(o, r, e1)
    t2 = check_expr(o, r, e2)
    print(f"concat_rule t1: {t1} t2:{t2}")
    t = join(t1, t2)
    if t == object_type:
        raise SemanticError("join failed in list concat")

    return t

# [LIST-SELECT]
# O, R |- e1[e2] : T
def list_select_rule(o: LocalEnvironment, r: Type, e1:Operation, e2:Operation) -> Type:
    print("list_select_rule")
    #O, R ⊢ e₁ : [T]
    t = check_expr(o, r, e1)
    print(f"in list t: {t}")
    if t == str_type:
        return str_select_rule(o, r, t, e2)
    # O, R ⊢ e₂ : int
    check_type(check_expr(o, r, e2), expected=int_type)
    print("return list select rule")

    return check_list_type(t)


# [LIST-ASSIGN-STMT]
# O, R |- e1[e2] = e3
def list_assign_stmt_rule(o: LocalEnvironment, r: Type, e1:Operation, e2: Operation, e3:Operation):
    print("list_assign_stmt_rule")
    t = check_expr(o, r, e1)
    check_type(check_expr(o, r, e2), expected=int_type)
    t3 = check_expr(o, r, e2)
    check_assignment_compatibility(t3, t)

# [MULTI-ASSIGN-STMT]
# O,R |- e1 = e2 = ... = en = e0
def multi_assign_stmt(o: LocalEnvironment, r: Type, e1: Operation, e2:Operation):
    print("multi_assign_smtt")
    x = check_expr(o, r, e1)
    print(f"multi_assign_smtt x: {x}")
    if isinstance(e2, choco_ast.Assign):
        print(f"in multi ininstance {e2}")
        r = multi_assign_stmt(o, r, e2.target.op, e2.value.op)
    else:
        r = check_expr(o, r, e2)
        print(f"in multi else {e2} r: {r}")
    check_assignment_compatibility(r, x)

    return r


# [INVOKE]
# O, R |- f(e1, e2, ..., en): T0
def invoke_rule(o: LocalEnvironment, r: Type,name:str, e1:[Operation]) -> Type:
    print(f"in invoke o:{o} e1:{e1} {len(e1)}")
    func = o[name]
    func_params = func.params
    params_type = func.func_type.inputs
    ret_type = func.func_type.output
    input_params = []
    for e in e1:
        print(e)
        input_params.append(check_expr(o, r, e))
    for idx in range(len(params_type)):
        check_assignment_compatibility(input_params[idx], params_type[idx])

    print(f"func {ret_type} {func_params} {params_type} ::{input_params}")
    return ret_type

# [RETURN-e] rule
# O, R |- return e
def return_e_rule(o: LocalEnvironment, r: Type, ret:Operation):
    t = check_expr(o, r, ret)
    check_assignment_compatibility(r, t)
    return t


# [RETURN] rule
# O, R |- return
def return_rule(o: LocalEnvironment, r: Type, e1:Operation):
    check_assignment_compatibility(none_type, r)



# [IF-ELSE]
# O, R |- if e: b1 else: b2
def if_else_rule(o: LocalEnvironment, r: Type, cond: Operation, b0:Operation, b1: Operation):
    print("if_else_ruile")
    print(f"ifelse b0: {b0} b1: {b1}")
    check_type(check_expr(o, r, cond), expected=bool_type)

    check_stmt_or_def(o, r, b0)
    if len(b1.ops) != 0:
        check_stmt_or_def(o, r ,b1.op)

# [WHILE]
# O, R |- while e: b
def while_rule(o: LocalEnvironment, r: Type, cond: Operation, b0:Operation):
    print("while_rulke")
    #O, R ⊢ e : bool
    # O, R ⊢ b
    check_type(check_expr(o, r, cond), expected=bool_type)
    check_stmt_or_def(o, r, b0)

# [FOR-STR]
# O, R |- for id in e: b
def for_str_rule(o: LocalEnvironment, r: Type, e: Operation, id: str, b: Operation):
    print("for_str_rule")
    # O, R ⊢ e : str
    check_type(check_expr(o, r, e), expected=str_type)
    # O(id) = T
    t = o[id]
    # str ≤a T
    check_assignment_compatibility(str_type, t)
    #O, R ⊢ b
    check_stmt_or_def(o, r, b)

# [FOR-LIST]
# O, R |- for id in e: b
def for_list_rule(o: LocalEnvironment, r: Type, e: Operation, id: str, b: Operation):
    print("for_list")
    # O, R ⊢ e : [T1]
    #check_type(check_expr(o, r, e), expected=str_type)
    t1 = check_expr(o, r, e)
    # O(id) = T
    t = o[id]
    # T1 ≤a T
    check_assignment_compatibility(check_list_type(t1), t)
    #O, R ⊢ b
    check_stmt_or_def(o, r, b)

# [FUNC-DEF] rule
# O, R |- def f(x1:T1, ... , xn:Tn)  [[-> T0]]? :b
def func_def_rule(o: LocalEnvironment, r: Type, name: str, body:[Operation], ret: Operation):
    print("in func_def")
    func_info = o[name]
    if not isinstance(func_info, FunctionInfo):
        raise SemanticError(f"Function `{name}` not declared in environment.")
    param_types = func_info.func_type.inputs
    params = func_info.params
    return_type = func_info.func_type.output
    closure_vars = func_info.nested_defs  
    local_env = {}
    for name, val in o.items():
        if isinstance(val, FunctionInfo):
            local_env[name] = val
    for i in range(len(params)):
        local_env[params[i]] = param_types[i]
    for x, y in closure_vars:
        if x not in local_env:
            local_env[x] = y
    print(f"ret_type = {return_type} :: {ret}")
    for b in body:
        print(f"b {b}")
        if isinstance(b, choco_ast.GlobalDecl):
            t = check_stmt_or_def(o, return_type, b)
            if t == True:
                x = b.decl_name.data
                local_env[x] = o[x]
        check_stmt_or_def(local_env, return_type, b)

