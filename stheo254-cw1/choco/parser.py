from typing import List, Union
from xdsl.dialects.builtin import ModuleOp
from xdsl.ir import Operation

import choco.dialects.choco_ast as ast
from choco.lexer import Lexer, Token, TokenKind

#TODO parse_expr parse_literal parse_args


class SyntaxError(Exception):
    def __init__(self):
        # TODO: expert task
        pass

    def get_message(self):
        # TODO: expert task
        pass


class Parser:
    """
    A Simple ChocoPy Parser

    Parse the given tokens from the lexer and call the xDSL API to create an AST.
    """

    def __init__(self, lexer: Lexer):
        """
        Create a new parser.

        Initialize parser with the corresponding lexer.
        """
        self.lexer = lexer

    def check(self, expected: Union[List[TokenKind], TokenKind]) -> bool:
        """
                Check that the next token is of a given kind. If a list of n TokenKinds
                is given, check that the next n TokenKinds match the next expected
                ones.

                :param expected: The kind of the token we expect or a list of expected
                                 token kinds if we look ahead more than one token at
                                 a time.
                :returns: True if the next token has the expected token kind, False
        ￼                 otherwise.
        """

        if isinstance(expected, list):
            tokens = self.lexer.peek(len(expected))
            assert isinstance(tokens, list), "List of tokens expected"
            return all([tok.kind == type_ for tok, type_ in zip(tokens, expected)])

        token = self.lexer.peek()
        assert isinstance(token, Token), "Single token expected"
        return token.kind == expected

    def match(self, expected: TokenKind) -> Token:
        """
        Match a token by first checking the token kind. In case the token is of
        the expected kind, we consume the token.  If a token with an unexpected
        token kind is encountered, an error is reported by raising an
        exception.

        The exception shows information about the line where the token was expected.

        :param expected: The kind of the token we expect.
        :returns: The consumed token if the next token has the expected token
                  kind, otherwise a parsing error is reported.
        """

        if self.check(expected):
            token = self.lexer.peek()
            assert isinstance(token, Token), "A single token expected"
            self.lexer.consume()
            return token

        token = self.lexer.peek()
        assert isinstance(token, Token), "A single token expected"
        print(f"Error: token of kind {expected} not found.")
        exit(0)

    def parse_program(self) -> ModuleOp:
        """
        Parse a ChocoPy program.

        program ::= def_seq stmt_seq EOF

        TODO: Not fully implemented.
        :returns: The AST of a ChocoPy Program.
        """
        defs = self.parse_def_seq()
        stmts = self.parse_stmt_seq()
        print(f"program: defs: {defs} stmts: {stmts} peek: {self.lexer.peek()}")

        self.match(TokenKind.EOF)

        return ModuleOp([ast.Program(defs, stmts)])

    def parse_def_seq(self) -> List[Operation]:
        """
        Parse a sequence of function and variable definitions.

        def_seq ::= [func_def | var_def]*
        check first if its a func by using check? check with list in params?

        TODO: Not fully implemented.
        :returns: A list of function and variable definitions.
        """

        defs: List[Operation] = []

        while self.check(TokenKind.DEF) or self.check([TokenKind.IDENTIFIER, TokenKind.COLON]):
            if self.check([TokenKind.DEF, TokenKind.IDENTIFIER]):
                func_def = self.parse_function()
                defs.append(func_def)
            if self.check([TokenKind.IDENTIFIER, TokenKind.COLON]):
                var_def = self.parse_variable()
                defs.append(var_def)

        print(f"defs: {defs}")
        return defs

    def parse_function(self) -> Operation:
        """
        Parse a function definition.

                  func_def := `def` ID `(` `)` `:` NEWLINE INDENT func_body DEDENT
        should be func_def := `def` ID `(` params `)` ret_type `:` NEWLINE INDENT func_body DEDENT
                  func_body := stmt_seq

        The above definition is incomplete.

        TODO: Not fully implemented.
        :return: Operation
        """
        print("in function def ")
        self.match(TokenKind.DEF)

        function_name = self.match(TokenKind.IDENTIFIER)

        self.match(TokenKind.LROUNDBRACKET)

        # Function parameters
        parameters: List[Operation] = self.parse_params()
        print(f"params : {parameters}")

        self.match(TokenKind.RROUNDBRACKET)

        # Return type: default is <None>.
        print(f"self.check : {self.check(TokenKind.RETURN)}")
        if self.check(TokenKind.RARROW):
            return_type = self.parse_ret_type()
        else:
            return_type = ast.TypeName("<None>")

        print(f"typename : {return_type}")

        self.match(TokenKind.COLON)

        self.match(TokenKind.NEWLINE)
        self.match(TokenKind.INDENT)

        defs_and_decls: List[Operation] = self.global_or_var()

        stmt_seq = self.parse_stmt_seq()
        print(f"def : {defs_and_decls} stmt: {stmt_seq}")
        if not stmt_seq:
            raise Exception("Error: Function body should have at least one statement.")

        func_body = defs_and_decls + stmt_seq
        print(f"func_body : {func_body}")

        print(f"function_name : {function_name.value} params = {parameters} return_type = {return_type}")
        self.match(TokenKind.DEDENT)

        return ast.FuncDef(function_name.value, parameters, return_type, func_body)

    def global_or_var(self) -> Operation:
        dx = []
        while self.check(TokenKind.GLOBAL) or self.check([TokenKind.IDENTIFIER, TokenKind.COLON]):
            dx.extend(self.parse_global_decl())
            dx.extend( self.parse_vars_tail())

        return dx

    def parse_params(self) -> Operation:
        """

        params := typed_var params_tail | ε
        params_tail := `,` typed_var params_tail | ε
        """
        print("in params")
        params: List[Operation] = []
        while self.check(TokenKind.IDENTIFIER):
            tmp = self.parse_typed_var()
            params.append(tmp)
            if not self.check(TokenKind.COMMA):
                break
            self.match(TokenKind.COMMA)
        return params

    def parse_ret_type(self) -> Operation:
        print("""ret_type := `->` type | ε""")
        if self.check(TokenKind.RARROW):
            self.match(TokenKind.RARROW)
            ret = self.parse_type()
        else:
            ret = ast.TypeName("<None>")
            
        print(f"ret_type : {ret}")
        return ret

    def parse_vars_tail(self) -> Operation:
        ret = []
        while self.check(TokenKind.IDENTIFIER):
            ret.append(self.parse_variable())

        return ret 

    def parse_variable(self) -> Operation:
        """ vardef -> typedvar `=` literal newline
        """
        print("in parse_variable")
        var_list = None
        if self.check(TokenKind.IDENTIFIER):
            typed_var = self.parse_typed_var()
            self.match(TokenKind.ASSIGN)
            literal = self.parse_literal()
            self.match(TokenKind.NEWLINE)
            print(f"literal : {literal} typed_var : {typed_var}")
            var_list = ast.VarDef(typed_var, literal)

        print(f"var_list : {var_list}")
        return var_list

    def parse_typed_var(self) -> Operation:
        """parse ID : type
        """
        id = self.match(TokenKind.IDENTIFIER)
        self.match(TokenKind.COLON)
        type = self.parse_type()
        print(f"typed_var.id : {id.value} type : {type}")

        return ast.TypedVar(id.value, type)

    def parse_type(self) -> Operation:
        """ tell if array or var
        type -> `[` type `]` *parse_list* | type
        """
        print("in parse_type")
        if self.check(TokenKind.LSQUAREBRACKET):
            print("calling parse_list_type")
            return self.parse_list_type()
        type = self.parse_type_name()
        return type

    def parse_list_type(self) -> Operation:
        """parse `[` type `]`
        """
        self.match(TokenKind.LSQUAREBRACKET)

        type = self.parse_type()

        self.match(TokenKind.RSQUAREBRACKET)

        return ast.ListType(type)

    def parse_list_items(self) -> Operation:
        print("in parse_list_items")
        expr: List[Operation] = []

        self.match(TokenKind.LSQUAREBRACKET)

        while self.check_expr():
            print("inside while parse_list_items")
            expr_tmp = self.parse_expr()
            expr.append(expr_tmp)
            if self.check(TokenKind.COMMA):
                self.match(TokenKind.COMMA)
            else:
                break

        self.match(TokenKind.RSQUAREBRACKET)
        return ast.ListExpr(expr)

    def check_expr(self) -> bool:
        bin_op = self.check_bin_op()
        index = self.check_index_expr()
        ident = self.check(TokenKind.IDENTIFIER)
        lit = self.check_literal()
        return bin_op or index or ident or lit

    def parse_type_name(self) -> Operation:
        print("in parse_type_name")
        if self.check(TokenKind.INT):
            self.match(TokenKind.INT)
            return ast.TypeName("int")
        if self.check(TokenKind.OBJECT):
            self.match(TokenKind.OBJECT)
            return ast.TypeName("object")
        if self.check(TokenKind.STR):
            self.match(TokenKind.STR)
            return ast.TypeName("str")
        if self.check(TokenKind.BOOL):
            self.match(TokenKind.BOOL)
            return ast.TypeName("bool")
        # idk if this should bei ncluded
        if self.check(TokenKind.NONE):
            self.match(TokenKind.NONE)
            return ast.TypeName("<None>")
        raise Exception("Error: Not Type")

    def is_expr_first_set(self) -> bool:
        """
        Check if the next token is in the first set of an expression.

        TODO: Not fully implemented.
        """

        return self.check(TokenKind.IDENTIFIER) or self.check_index_expr() or self.check_literal()

    def is_stmt_first_set(self) -> bool:
        """
        Check if the next token is in the first set of a statement.

        TODO: Not fully implemented.
        """
        xd = self.check(TokenKind.FOR) or self.check(TokenKind.WHILE) or self.check(TokenKind.IF) or self.check(TokenKind.NOT)
        return self.is_expr_first_set() or self.check(TokenKind.PASS) or self.check(TokenKind.RETURN) or xd

    def parse_stmt_seq(self) -> List[Operation]:
        """Parse a sequence of statements.

        stmt_seq := stmt stmt_seq

        :return: list of Operations
        """
        print("in stmt_seq")
        stmt_seq: List[Operation] = []
        while self.is_stmt_first_set():
            print("in while stmt_seq")
            stmt_op = self.parse_stmt()
            stmt_seq.append(stmt_op)
        print(f"stmt_seq: {stmt_seq}")
        return stmt_seq

    def parse_stmt(self) -> Operation:
        """Parse a statement.

        stmt := simple_stmt NEWLINE | cond_or_loop

        The above definition is incomplete.

        TODO: Not fully implemented.
        :return: Statement as operation
        """
        print("in stmt")
        if self.check(TokenKind.FOR) or self.check(TokenKind.WHILE) or self.check(TokenKind.IF):
            return self.parse_loop_cond()
        simple_stmt = self.parse_simple_stmt()
        self.match(TokenKind.NEWLINE)
        return simple_stmt

    def parse_simple_stmt(self) -> Operation:
        """Parse a simple statement.

        stmt := `pass`

        The above definition is incomplete.

        TODO: Not fully implemented.
        :return: Statement as operation
        """
        print("in simple_stmt")
        if self.check(TokenKind.PASS):
            self.match(TokenKind.PASS)
            return ast.Pass()
        if self.check(TokenKind.RETURN):
            self.match(TokenKind.RETURN)
# empty nya blm di set
            if self.check_expr():
                expr = self.parse_expr()
            else:
                expr = None
            return ast.Return(expr)
        else:
            return self.parse_assign()

    def parse_assign(self) -> Operation:
        # assign or expr
        print(f"in parse_assign peek: ")
        lhs = self.parse_expr()
        print(f" lhs b4 while : {lhs}")
        while self.check(TokenKind.ASSIGN):
            print(f" lhs after while : {lhs}")
            print("in assign")
            self.match(TokenKind.ASSIGN)
            lhs = ast.Assign(lhs, self.parse_assign())

        print(f"return assign lhs : {lhs} peek: {self.lexer.peek()}")
        return lhs

    def check_index_expr(self) -> bool:
        if self.check(TokenKind.LROUNDBRACKET):
            return True
        if self.check(TokenKind.LSQUAREBRACKET):
            return True
        if self.check([TokenKind.IDENTIFIER, TokenKind.LROUNDBRACKET]):
            return True
        if self.check(TokenKind.MINUS):
            return True
        if self.check([TokenKind.IDENTIFIER, TokenKind.LSQUAREBRACKET]):
            return True
        else:
            return False

    def parse_literal(self) -> Operation:
        """Parse literals.
        literal := `None` | `True` | `False` | INTEGER | STRING

        """
        print("in parse_literal")
        if self.check(TokenKind.TRUE):
            self.match(TokenKind.TRUE)
            return ast.Literal(True)
        if self.check(TokenKind.FALSE):
            self.match(TokenKind.FALSE)
            return ast.Literal(False)
        if self.check(TokenKind.NONE):
            op = self.match(TokenKind.NONE)
            print(op.value)
            return ast.Literal(None)
        if self.check(TokenKind.INTEGER):
            op = self.match(TokenKind.INTEGER)
            print(f"int: {op.value} {ast.Literal(op.value)}")
            return ast.Literal(op.value)
        if self.check(TokenKind.STRING):
            op =self.match(TokenKind.STRING)
            return ast.Literal(op.value)
        raise Exception("Error: Not Literals")

    def check_literal(self) -> bool:
        if self.check(TokenKind.TRUE):
            return True
        if self.check(TokenKind.FALSE):
            return True
        if self.check(TokenKind.NONE):
            return True
        if self.check(TokenKind.INTEGER):
            return True
        if self.check(TokenKind.STRING):
            return True
        return False

    def parse_global_decl(self) -> Operation:
        """ `global` ID NEWLINE
        """
        global_list : List[Operation] = []
        while self.check(TokenKind.GLOBAL):
            self.match(TokenKind.GLOBAL)
            identifier = self.match(TokenKind.IDENTIFIER)
            self.match(TokenKind.NEWLINE)
            global_list.append(ast.GlobalDecl(identifier.value))
            print(f"global_decl : {identifier.value} global_list: {global_list}")

        return global_list

    def check_bin_op(self) -> bool:
        xd = self.check(TokenKind.PLUS) or self.check(TokenKind.MINUS)
        dx = self.check(TokenKind.MUL) or self.check(TokenKind.DIV) or self.check(TokenKind.MOD)
        ddx = self.check(TokenKind.EQ) or self.check(TokenKind.NE) or self.check(TokenKind.LT) or self.check(TokenKind.LE)
        xdd = self.check(TokenKind.GT) or self.check(TokenKind.GE) or self.check(TokenKind.IS)


        return xd or dx or ddx or xdd
    
    def parse_bin_op(self):
        print("in bin_op")
        if self.check(TokenKind.PLUS):
            xd = self.match(TokenKind.PLUS)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.MINUS):
            xd = self.match(TokenKind.MINUS)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.MUL):
            xd = self.match(TokenKind.MUL)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.DIV):
            xd = self.match(TokenKind.DIV)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.MOD):
            xd = self.match(TokenKind.MOD)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.EQ):
            xd = self.match(TokenKind.EQ)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.NE):
            xd = self.match(TokenKind.NE)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.LT):
            xd = self.match(TokenKind.LT)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.LE):
            xd = self.match(TokenKind.LE)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.GT):
            xd = self.match(TokenKind.GT)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.GE):
            xd = self.match(TokenKind.GE)
            print(f"bin_op : {xd.value}")
            return xd.value
        if self.check(TokenKind.IS):
            xd = self.match(TokenKind.IS)
            print(f"bin_op : {xd.value}")
            return xd.value
        raise Exception("Error: Not bin op")

    def parse_cexpr(self) -> Operation:
        print("in cexpr")
        add = self.parse_add_minus()
        while (self.check(TokenKind.EQ) or self.check(TokenKind.NE) or 
            self.check(TokenKind.LT) or self.check(TokenKind.LE) or
            self.check(TokenKind.GT) or self.check(TokenKind.GE) or 
            self.check(TokenKind.IS)):
            op = self.parse_bin_op()
            add = ast.BinaryExpr(op, add, self.parse_add_minus())

        return add

    def parse_add_minus(self) -> Operation:
        print("in add_minus")
        mult = self.parse_mult()
        while (self.check(TokenKind.PLUS) or self.check(TokenKind.MINUS)):
            op = self.parse_bin_op()
            mult = ast.BinaryExpr(op, mult, self.parse_mult())

        return mult

    def parse_mult(self) -> Operation:
        print("in mult")
        print(f"peek {self.lexer.peek()}")
        term = self.parse_term()
        while (self.check(TokenKind.MUL) or self.check(TokenKind.DIV) or
              self.check(TokenKind.MOD)):
            op = self.parse_bin_op()
            print(f"in while mult op:{op}")
            term = ast.BinaryExpr(op, term, self.parse_term())
            print(f"term in mult : {term}")

        return term

    def parse_args(self) -> Operation:
        print("in parse_args")
        args: List[Operation] = []
        print(f"test : {args}")
        while self.check_expr():
            args_tmp = self.parse_expr()
            print(f" args_tmp: {args_tmp}")
            args.append(args_tmp)
            print(f"args in while: {args}")
            if self.check(TokenKind.COMMA):
                self.match(TokenKind.COMMA)
            else:
                break
        print(f"args: {args}")
        return args

    def parse_term(self) -> Operation:
        """
        term := ID | literal | list_expr | `(` expr `)` | index_expr | call_expr | `-` term
        """
        print(f"in parse_term : {self.lexer.peek()}")
        if self.check([TokenKind.IDENTIFIER, TokenKind.LROUNDBRACKET]):
            print("in call expr")
            # call_expr
            id = self.match(TokenKind.IDENTIFIER)
            self.match(TokenKind.LROUNDBRACKET)
            args = self.parse_args()
            print(f"atgs in pares_term : {args} id:{id}")
            self.match(TokenKind.RROUNDBRACKET)
            ret = ast.CallExpr(id.value, args)
            while self.check(TokenKind.LSQUAREBRACKET):
                print("in call expr index_expr")
                self.match(TokenKind.LSQUAREBRACKET)
                ret = ast.IndexExpr(ret, self.parse_expr())
                self.match(TokenKind.RSQUAREBRACKET)

            print(f"return in callexpr : {ret}")
            return ret
        if self.check(TokenKind.IDENTIFIER):
            # ID
            print("in id")
            id = self.match(TokenKind.IDENTIFIER)
            print(f"ID : {id} value: {id.value}")
            ret = ast.ExprName(id.value)
            while self.check(TokenKind.LSQUAREBRACKET):
                print("in id index expr")
                self.match(TokenKind.LSQUAREBRACKET)
                ret = ast.IndexExpr(ret, self.parse_expr())
                print(f"xd: {ret}")
                self.match(TokenKind.RSQUAREBRACKET)

            return ret

        if self.check_literal():
            print("literal in parse_term")
            id = self.parse_literal()

            while self.check(TokenKind.LSQUAREBRACKET):
                self.match(TokenKind.LSQUAREBRACKET)
                id = ast.IndexExpr(id, self.parse_expr())
                self.match(TokenKind.RSQUAREBRACKET)

            return id

        if self.check(TokenKind.LSQUAREBRACKET):
            print("in list_expr")
            parse_expr = self.parse_list_items()
            while self.check(TokenKind.LSQUAREBRACKET):
                self.match(TokenKind.LSQUAREBRACKET)
                parse_expr = ast.IndexExpr(parse_expr, self.parse_expr())
                self.match(TokenKind.RSQUAREBRACKET)
            return parse_expr

        if self.check(TokenKind.LROUNDBRACKET):
            print("in lround")
            self.match(TokenKind.LROUNDBRACKET)
            parse_expr = self.parse_expr()
            self.match(TokenKind.RROUNDBRACKET)
            while self.check(TokenKind.LSQUAREBRACKET):
                self.match(TokenKind.LSQUAREBRACKET)
                parse_expr = ast.IndexExpr(parse_expr, self.parse_expr())
                self.match(TokenKind.RSQUAREBRACKET)
            return parse_expr

        if self.check(TokenKind.MINUS):
            op = self.match(TokenKind.MINUS)
            term = self.parse_term()
            ret = ast.UnaryExpr(op.value, term)

            while self.check(TokenKind.LSQUAREBRACKET):
                self.match(TokenKind.LSQUAREBRACKET)
                ret = ast.IndexExpr(ret, self.parse_expr())
                self.match(TokenKind.RSQUAREBRACKET)
            return ret

        raise Exception("parse_index_expr")

    def parse_expr(self) -> Operation:
        print("in parse_expr")
        and_expr = self.and_expr()
        while(self.check(TokenKind.OR)):
            op = self.match(TokenKind.OR)
            and_expr = ast.BinaryExpr(op.value, and_expr, self.and_expr())

        return and_expr

    def and_expr(self) -> Operation:
        not_expr = self.not_expr()
        while self.check(TokenKind.AND):
            op = self.match(TokenKind.AND)
            not_expr = ast.BinaryExpr(op.value, not_expr, self.not_expr())

        return not_expr

    def not_expr(self) -> Operation:
        if not self.check(TokenKind.NOT):
            return self.cond_expr()
        self.match(TokenKind.NOT)
        expr = self.not_expr()

        return ast.UnaryExpr("not", expr)

    def cond_expr(self) -> Operation:
        cexpr = self.parse_cexpr()
        if self.check(TokenKind.IF):
            self.match(TokenKind.IF)
            lhs = self.parse_cexpr()
            self.match(TokenKind.ELSE)
            rhs = self.cond_expr()

            return ast.IfExpr(lhs, cexpr,rhs)
        else:
            return cexpr

    def parse_loop_cond(self) -> Operation:
        print("in loop_cond")
        if self.check(TokenKind.IF):
            return self.parse_if()
        elif self.check(TokenKind.WHILE):
            return self.parse_while()
        elif self.check(TokenKind.FOR):
            return self.parse_for()

        raise Exception("loop_cond")

    def parse_if(self) -> Operation:
        self.match(TokenKind.IF)

        cond = self.parse_expr()
        self.match(TokenKind.COLON)
        then = self.parse_block()
        # need to make logic for when elif exist for now its only if else
        elif_block = self.parse_elif()

        return ast.If(cond, then, elif_block)

    def parse_block(self) -> List[Operation]:
        ret = []
        while self.check(TokenKind.NEWLINE):
            self.match(TokenKind.NEWLINE)
            self.match(TokenKind.INDENT)

            stmt = self.parse_stmt()
            ret.append(stmt)
            self.match(TokenKind.DEDENT)

        return ret

    def parse_else(self) -> List[Operation]:
        if not self.check(TokenKind.ELSE):
            return []
        self.match(TokenKind.ELSE)
        self.match(TokenKind.COLON)

        then = self.parse_block()
        return then

    def parse_elif(self) -> List[Operation]:
        if not self.check(TokenKind.ELIF):
            return self.parse_else()
        self.match(TokenKind.ELIF)
        cond = self.parse_expr()
        self.match(TokenKind.COLON)
        then = self.parse_block()

        # IDK bro this is so sus TODO
        orelse = self.parse_elif()

        return [ast.If(cond, then, orelse)]

    def parse_while(self) -> Operation:
        self.match(TokenKind.WHILE)
        cond = self.parse_expr()
        self.match(TokenKind.COLON)
        body = self.parse_block()

        return ast.While(cond, body)

    def parse_for(self) -> Operation:
        self.match(TokenKind.FOR)
        id_x = self.match(TokenKind.IDENTIFIER)
        self.match(TokenKind.IN)
        expr = self.parse_expr()
        self.match(TokenKind.COLON)
        block = self.parse_block()
        print(f"idx = {id_x} expr = {expr} block = {block}")

        return ast.For(id_x.value, expr, block)










