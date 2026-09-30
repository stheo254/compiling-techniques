# type: ignore

from xdsl.context import MLContext
from xdsl.dialects.builtin import ModuleOp
from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import (
    GreedyRewritePatternApplier,
    PatternRewriter,
    PatternRewriteWalker,
    RewritePattern,
    op_type_rewrite_pattern,
)

from choco.dialects.choco_flat import *
from riscv.ssa_dialect import *


class LiteralPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: Literal, rewriter: PatternRewriter):
        value = op.value
        if isinstance(value, IntegerAttr):
            constant = LIOp(op.value)
            rewriter.replace_op(op, [constant])
            return

        if isinstance(value, BoolAttr):
            if value.data == True:
                constant = LIOp(1)
            if value.data == False:
                constant = LIOp(0)
            rewriter.replace_op(op, [constant])
            return 

        if isinstance(value, NoneAttr):
            constant = LIOp(0)  # Replace None with 0
            rewriter.replace_op(op, [constant])
            return

        if isinstance(value, StringAttr):
            alloc = AllocOp()
            rewriter.insert_op_before_matched_op(alloc)
            y = []
            for x in value.data:
                ddx = LIOp(ord(x))
                y.append(ddx)
                rewriter.insert_op_before_matched_op(ddx)
            sizeinbytes = (len(value.data)+1) *4
            size_op = LIOp(sizeinbytes)
            rewriter.insert_op_before_matched_op(size_op)
            malloc = CallOp(func_name="_malloc", args=[size_op])
            size = LIOp(len(value.data))
            sw_size = SWOp(size, malloc, 0)
            rewriter.insert_op_before_matched_op(malloc)
            rewriter.insert_op_before_matched_op(size)
            rewriter.insert_op_before_matched_op(sw_size)
            counter = 1
            for z in y:
                rewriter.insert_op_before_matched_op(SWOp(z, malloc, counter*4))
                counter +=1
            fas = SWOp(malloc, alloc, 0)
            rewriter.insert_op_before_matched_op(fas)
            end = LWOp(alloc, 0)
            #end = AddIOp(malloc, 0)
            rewriter.replace_op(op, [end])
            return

        return


class CallPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: CallExpr, rewriter: PatternRewriter):
        if op.func_name.data == "len":
            zero = LIOp(0)
            maybe_fail = BEQOp(op.args[0], zero, f"_error_len_none")
            read_size = LWOp(op.args[0], 0) 
            rewriter.replace_op(op, [zero, maybe_fail, read_size])
            return

        call = CallOp(op.func_name, op.args, has_result=bool(len(op.results)))
        rewriter.replace_op(op, [call])


class AllocPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, alloc_op: Alloc, rewriter: PatternRewriter):
        aloc = AllocOp()
        rewriter.replace_op(alloc_op, [aloc])
        return


class StorePattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, store_op: Store, rewriter: PatternRewriter):
        store = SWOp(store_op.value, store_op.memloc.op, store_op.memloc.index)
        rewriter.replace_op(store_op, [store])
        return

class LoadPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, load_op: Load, rewriter: PatternRewriter):
        load = LWOp(load_op.memloc, load_op.memloc.index)
        rewriter.replace_op(load_op, [load])
        return


class UnaryExprPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, unary_op: UnaryExpr, rewriter: PatternRewriter):
        if unary_op.op.data == '-':
            constant = LIOp(-unary_op.value.op.immediate.value.data)
            rewriter.replace_op(unary_op, [constant])
            return
        if unary_op.op.data == "not" :
            one = LIOp(1)
            constant = XOROp(unary_op.value.op, one)
            rewriter.replace_op(unary_op, [one, constant])
            return
        raise NotImplementedError()


class BinaryExprPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, bin_op: BinaryExpr, rewriter: PatternRewriter):
        lhs = bin_op.lhs.op
        rhs = bin_op.rhs.op
        if bin_op.op.data == '+':
            constant = AddOp(lhs, rhs)
        if bin_op.op.data == '-':
           constant = SubOp(lhs,rhs)
        if bin_op.op.data == '*':
            constant = MULOp(lhs, rhs)
        if bin_op.op.data == '//':
            constant = DIVOp(lhs, rhs)
        if bin_op.op.data == '%':
            constant = REMOp(lhs, rhs)
        if bin_op.op.data == 'is':# dibawah ini g tw
            xor_op = XOROp(lhs, rhs)
            rewriter.insert_op_before_matched_op(xor_op)
            zero_op = LIOp(0)
            rewriter.insert_op_before_matched_op(zero_op)

            sltu_op = SLTUOp(zero_op, xor_op)
            rewriter.insert_op_before_matched_op(sltu_op)

            one_op = LIOp(1)
            rewriter.insert_op_before_matched_op(one_op)
            constant = XOROp(sltu_op, one_op)
        if bin_op.op.data == '<':
            constant = SLTOp(lhs, rhs)
        if bin_op.op.data == '>':
            constant = SLTOp(rhs, lhs)
        if bin_op.op.data == '<=':
            constants = SLTOp(rhs, lhs)
            rewriter.insert_op_before_matched_op(constants)
            constant = XORIOp(constants, 1)
        if bin_op.op.data == '>=':
            constants = SLTOp(lhs, rhs)
            rewriter.insert_op_before_matched_op(constants)
            constant = XORIOp(constants, 1)
        if bin_op.op.data == '!=':
            xor_op = XOROp(bin_op.lhs, bin_op.rhs)
            rewriter.insert_op_before_matched_op(xor_op)

            zero_op = LIOp(0)
            rewriter.insert_op_before_matched_op(zero_op)

            constant = SLTUOp(zero_op, xor_op)
        if bin_op.op.data == '==':
            xor_op = XOROp(bin_op.lhs, bin_op.rhs)
            rewriter.insert_op_before_matched_op(xor_op)

            zero_op = LIOp(0)
            rewriter.insert_op_before_matched_op(zero_op)

            sltu_op = SLTUOp(zero_op, xor_op)
            rewriter.insert_op_before_matched_op(sltu_op)

            constant = XORIOp(sltu_op, 1)

        rewriter.replace_op(bin_op, constant)
        return
        raise NotImplementedError()


class IfPattern(RewritePattern):
    counter: int = 0

    @op_type_rewrite_pattern
    def match_and_rewrite(self, if_op: If, rewriter: PatternRewriter):
        IfPattern.counter = IfPattern.counter + 1
        cond = if_op.cond.op
        then = if_op.then.blocks[0]
        orelse = if_op.orelse.blocks[0]

        then_count = LabelOp(f"then_{IfPattern.counter}")
        orelse_count = LabelOp(f"orelse_{IfPattern.counter}")
        after_label= LabelOp(f"after_{IfPattern.counter}")
        zero = LIOp(0)
        rewriter.insert_op_before_matched_op(zero)
        if len(orelse.ops) != 0:
            cond_op = BEQOp(rs1=cond, rs2=zero, offset=orelse_count.label)
        else:
            cond_op = BEQOp(rs1=cond, rs2=zero, offset=after_label.label)
        rewriter.insert_op_before_matched_op(cond_op)
        rewriter.insert_op_before_matched_op(then_count)

        rewriter.inline_block_before_matched_op(then)
        rewriter.insert_op_before_matched_op(JOp(after_label.label))
        if len(orelse.ops) != 0:
            rewriter.insert_op_before_matched_op(orelse_count)
            rewriter.inline_block_before_matched_op(if_op.orelse.blocks[0])
        rewriter.insert_op_before_matched_op(after_label)
        rewriter.erase_op(if_op)

        return


class AndPattern(RewritePattern):
    counter: int = 0

    @op_type_rewrite_pattern
    def match_and_rewrite(self, and_op: EffectfulBinaryExpr, rewriter: PatternRewriter):
        # Hint: Make sure that this is really 'and', otherwise return early!
        self.counter +=1
        op = and_op.op.data
        lhs = and_op.lhs.blocks[0]
        rhs = and_op.rhs.blocks[0]
        end_doing = LabelOp(f"true_{self.counter}")
        false_doing = LabelOp(f"false_{self.counter}")

        if op != "and":
            return 
        false = LIOp(0)
        rewriter.insert_op_before_matched_op(false)
        for i in lhs.ops:
                if isinstance(i, Literal):
                    a_test = i.value.data
                if isinstance(i, Yield):
                    a = i.value
        for y in rhs.ops:
                if isinstance(y, Yield):
                    b = y.value
        beq = BEQOp(a, false, end_doing.label)

        rewriter.inline_block_before_matched_op(lhs)
        rewriter.insert_op_before_matched_op(beq)
        rewriter.inline_block_before_matched_op(rhs)
        rewriter.insert_op_before_matched_op(end_doing)

        if a_test == True:
            res = ANDOp(a,b)
        else:
            res = AddOp(a,false)
        rewriter.replace_op(and_op, [res])


class OrPattern(RewritePattern):
    counter: int = 0

    @op_type_rewrite_pattern
    def match_and_rewrite(self, or_op: EffectfulBinaryExpr, rewriter: PatternRewriter):
        # Hint: Make sure that this is really 'or', otherwise return early!
        self.counter += 1
        op = or_op.op.data
        lhs = or_op.lhs.blocks[0]
        rhs = or_op.rhs.blocks[0]
        end_doing = LabelOp(f"true_{self.counter}")
        false_doing = LabelOp(f"false_{self.counter}")

        false = LIOp(0)
        true = LIOp(1)
        rewriter.insert_op_before_matched_op(false)
        rewriter.insert_op_before_matched_op(true)
        if op != "or":
            return 
        for lh in lhs.ops:
            if isinstance(lh, Literal):
                a_test = lh.value.data
            if isinstance(lh, Yield):
                x = lh.value

        for rh in rhs.ops:
            if isinstance(rh, Yield):
                y = rh.value
        beq = BEQOp(x, true, end_doing.label)

        rewriter.inline_block_before_matched_op(lhs)
        rewriter.insert_op_before_matched_op(beq)
        rewriter.inline_block_before_matched_op(rhs)
        rewriter.insert_op_before_matched_op(end_doing)

        if a_test == False:
            res = OROp(x,y)
        else:
            res = OROp(x,true)
        rewriter.replace_op(or_op, [res])
        return



class IfExprPattern(RewritePattern):
    counter: int = 0

    @op_type_rewrite_pattern
    def match_and_rewrite(self, if_op: IfExpr, rewriter: PatternRewriter):
        print(if_op.cond.op)
        xd = if_op.result
        self.counter = self.counter + 1
        cond = if_op.cond
        
        for x in if_op.then.ops:
            if isinstance(x, Yield):
                y = x
        for z in if_op.or_else.ops:
            if isinstance(z, Yield):
                v = z

        orelse_count = LabelOp(f"orelse_{self.counter}")
        after_label= LabelOp(f"after_{self.counter}")
        zero = LIOp(0)
        rewriter.insert_op_before_matched_op(zero)
        cond_op = BEQOp(rs1=cond, rs2=zero, offset=orelse_count.label)
        rewriter.insert_op_before_matched_op(cond_op)
        rewriter.inline_block_before_matched_op(if_op.then.blocks[0])
        jump = JOp(after_label.label)
        rewriter.insert_op_before_matched_op(jump)
        rewriter.insert_op_before_matched_op(orelse_count)
        rewriter.inline_block_before_matched_op(if_op.or_else.blocks[0])
        rewriter.insert_op_before_matched_op(after_label)
        rewriter.erase_matched_op()

        return


class WhilePattern(RewritePattern):
    counter: int = 0

    @op_type_rewrite_pattern
    def match_and_rewrite(self, while_op: While, rewriter: PatternRewriter):
        self.counter = self.counter + 1
        body = while_op.body.blocks[0]
        cond = while_op.cond.blocks[0]

        for i in cond.ops:
            if isinstance(i , Yield):
                x = i.value
        for z in body.ops:
            if isinstance(i , Yield):
                j = i.value
        true = LIOp(1)
        test_label = LabelOp(f"test_{self.counter}") 
        body_label = LabelOp(f"body_{self.counter}")
        rewriter.insert_op_before_matched_op(JOp(test_label.label))
        rewriter.insert_op_before_matched_op(body_label)
        rewriter.inline_block_before_matched_op(body)
        rewriter.insert_op_before_matched_op(test_label)
        rewriter.inline_block_before_matched_op(cond)
        rewriter.insert_op_before_matched_op(true)
        rewriter.insert_op_before_matched_op(BEQOp(rs1=x, rs2=true, offset=body_label.label))
        rewriter.erase_op(while_op)

        return


class ListExprPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, list_expr: ListExpr, rewriter: PatternRewriter):
        byte = len(list_expr.elems)
        ddx = LIOp((byte+1)*4)
        rewriter.insert_op_before_matched_op(ddx)
        malloc = CallOp(func_name="_malloc", args=[ddx])
        rewriter.insert_op_before_matched_op(malloc)

        dx = LIOp(byte)
        rewriter.insert_op_before_matched_op(dx)
        sw = SWOp(dx, malloc, 0)
        rewriter.insert_op_before_matched_op(sw)
        for i in range(byte):
            x = SWOp(list_expr.elems[i],malloc,(i+1)*4)
            rewriter.insert_op_before_matched_op(x)
        #rewriter.insert_op_before_matched_op(end)
        test = AddIOp(malloc, 0)

        rewriter.replace_op(list_expr, [test])
        return

class GetAddressPattern(RewritePattern):
    counter: int = 0
    @op_type_rewrite_pattern

    def match_and_rewrite(self, get_address: GetAddress, rewriter: PatternRewriter):
        base_ptr = get_address.value
        index_op = get_address.index.op

        self.counter +=1
        continue_label = LabelOp(f"list_continue_{self.counter}")
        none_error_label = LabelOp(f"list_none_error_{self.counter}")
        oob_error_label = LabelOp(f"list_oob_error_{self.counter}")
        xd = JOp(continue_label.label)

        zero = LIOp(0)
        four = LIOp(4)
        rewriter.insert_op_before_matched_op([zero, four])
        is_none = BEQOp(get_address.value, zero, f"list_none_error_{self.counter}")
        rewriter.insert_op_before_matched_op(is_none)

        length = LWOp(base_ptr, 0)
        rewriter.insert_op_before_matched_op(length)
        is_negative = SLTOp(get_address.index.op, zero)
        is_oob = SLTOp(length, get_address.index.op)
        is_invalid = OROp(is_negative, is_oob)
        bounds_check = BNEOp(is_invalid, zero, oob_error_label.label)
        rewriter.insert_op_before_matched_op([is_negative, is_oob, is_invalid, bounds_check])

        if isinstance(index_op, LIOp):
            offset = (index_op.immediate.value.data + 1) * 4
            offset_op = LIOp(offset)
            rewriter.insert_op_before_matched_op(offset_op)
            rewriter.insert_op_before_matched_op(xd)
        else:
            element_size = LIOp(4)
            rewriter.insert_op_before_matched_op(element_size)

            adjusted_index = AddIOp(index_op, 1)
            rewriter.insert_op_before_matched_op(adjusted_index)

            offset_op = MULOp(adjusted_index, element_size)
            rewriter.insert_op_before_matched_op(offset_op)
            rewriter.insert_op_before_matched_op(xd)

        addr_op = AddOp(base_ptr, offset_op)

        none_error_op = CallOp("_list_index_none", [])
        oob_error_op = CallOp("_list_index_oob", [])

        rewriter.insert_op_before_matched_op([none_error_label, none_error_op, oob_error_label, oob_error_op, continue_label])

        rewriter.replace_op(get_address, [ addr_op])

class IndexStringPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, indexString: IndexString, rewriter: PatternRewriter):
        xd = LWOp(indexString.value.op, (indexString.index.op.immediate.value.data+1)*4 )
        alloc = AllocOp()
        rewriter.insert_op_before_matched_op(alloc)
        sizeinbytes = 8
        size_op = LIOp(sizeinbytes)
        rewriter.insert_op_before_matched_op(size_op)
        malloc = CallOp(func_name="_malloc", args=[size_op])
        size = LIOp(1)
        sw_size = SWOp(size, malloc, 0)
        rewriter.insert_op_before_matched_op(malloc)
        rewriter.insert_op_before_matched_op(size)
        rewriter.insert_op_before_matched_op(sw_size)

        rewriter.insert_op_before_matched_op(xd)
        sw_new = SWOp(xd, malloc,4)
        rewriter.insert_op_before_matched_op(sw_new)
#        counter = 1
#        for z in y:
#            rewriter.insert_op_before_matched_op(SWOp(z, malloc, counter*4))
#            counter +=1
        fas = SWOp(malloc, alloc, 0)
        rewriter.insert_op_before_matched_op(fas)
        #end = LWOp(alloc, 0)
        end = AddIOp(alloc, 0)
        rewriter.replace_op(indexString, [end])
        return


class YieldPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, get_address: Yield, rewriter: PatternRewriter):
        rewriter.erase_matched_op()


class FuncDefPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, func: FuncDef, rewriter: PatternRewriter):
        new_func = FuncOp.create(
            result_types=[],
            properties={"func_name": StringAttr(func.func_name.data)},
        )

        new_region = rewriter.move_region_contents_to_new_regions(func.func_body)
        new_func.add_region(new_region)
        for arg in new_region.block.args:
            rewriter.modify_value_type(arg, RegisterType())

        rewriter.replace_op(func, new_func)


class ReturnPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, ret: Return, rewriter: PatternRewriter):
        x = ret.value
        rewriter.replace_op(ret, [ReturnOp(x)])



class ChocoFlatToRISCVSSA(ModulePass):
    name = "choco-flat-to-riscv-ssa"

    def apply(self, ctx: MLContext, op: ModuleOp) -> None:
        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier(
                [
                    LiteralPattern(),
                    CallPattern(),
                    UnaryExprPattern(),
                    BinaryExprPattern(),
                    StorePattern(),
                    LoadPattern(),
                    AllocPattern(),
                    IfPattern(),
                    AndPattern(),
                    OrPattern(),
                    IfExprPattern(),
                    WhilePattern(),
                    ListExprPattern(),
                    GetAddressPattern(),
                    IndexStringPattern(),
                    FuncDefPattern(),
                    ReturnPattern(),
                ]
            ),
            apply_recursively=True,
        )

        walker.rewrite_module(op)

        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier(
                [
                    YieldPattern(),
                ]
            ),
            apply_recursively=True,
        )

        walker.rewrite_module(op)
