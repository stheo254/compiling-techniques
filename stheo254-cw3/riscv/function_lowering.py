# type: ignore

from __future__ import annotations

from dataclasses import dataclass

from xdsl.context import MLContext
from xdsl.dialects.builtin import ModuleOp
from xdsl.ir import Operation
from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import (
    GreedyRewritePatternApplier,
    PatternRewriter,
    PatternRewriteWalker,
    RewritePattern,
)

import riscv.dialect as riscv
import riscv.ssa_dialect as riscvssa


@dataclass(eq=False)
class FunctionPattern(RewritePattern):
    """ """

    def match_and_rewrite(self, op: Operation, rewriter: PatternRewriter):
        if not isinstance(op, riscvssa.FuncOp):
            return

        rewriter.insert_op_before(riscv.LabelOp(op.func_name.data), op)
        rewriter.inline_block_after(op.func_body.blocks[0], op)
        rewriter.erase_op(op)


class RISCVFunctionLowering(ModulePass):
    name = "riscv-function-lowering"

    def apply(self, ctx: MLContext, mod: ModuleOp):
        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier([FunctionPattern()]),
            apply_recursively=True,
            walk_reverse=True,
        )
        walker.rewrite_module(mod)
        jump = riscv.JALOp(riscv.RegisterAttr.from_name("ra"), "_main")
        top_block = mod.regions[0].blocks[0]
        top_block.insert_op_before(jump, top_block.first_op)
