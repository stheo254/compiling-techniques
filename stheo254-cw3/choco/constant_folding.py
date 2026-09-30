# type: ignore

from dataclasses import dataclass

from xdsl.context import MLContext
from xdsl.dialects.builtin import IntegerAttr, ModuleOp
from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import (
    GreedyRewritePatternApplier,
    PatternRewriter,
    PatternRewriteWalker,
    RewritePattern,
    op_type_rewrite_pattern,
)

from choco.dialects.choco_flat import *
from choco.dialects.choco_type import *


@dataclass
class BinaryExprRewriter(RewritePattern):
    def is_integer_literal(self, op: Operation):
        return isinstance(op, Literal) and isinstance(op.value, IntegerAttr)

    @op_type_rewrite_pattern
    def match_and_rewrite(  # type: ignore reportIncompatibleMethodOverride
        self, expr: BinaryExpr, rewriter: PatternRewriter
    ) -> None:
        if expr.op.data == "+":
            if self.is_integer_literal(expr.lhs.op) and self.is_integer_literal(
                expr.rhs.op
            ):
                lhs_value = expr.lhs.op.value.parameters[0].data
                rhs_value = expr.rhs.op.value.parameters[0].data
                result_value = lhs_value + rhs_value
                new_constant = Literal.get(result_value)
                rewriter.replace_op(expr, [new_constant])
        return


class ChocoFlatConstantFolding(ModulePass):
    name = "choco-flat-constant-folding"

    def apply(self, ctx: MLContext, op: ModuleOp) -> None:
        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier(
                [
                    BinaryExprRewriter(),
                ]
            )
        )

        walker.rewrite_module(op)
