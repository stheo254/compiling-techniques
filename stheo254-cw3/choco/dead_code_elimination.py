from dataclasses import dataclass

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
from choco.dialects.choco_type import *


@dataclass
class LiteralRewriter(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(  # type: ignore reportIncompatibleMethodOverride
        self, literal: Literal, rewriter: PatternRewriter
    ) -> None:
        if len(literal.results[0].uses) == 0:
            rewriter.replace_op(literal, [], [None])
        return


@dataclass
class BinaryExprRewriter(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(  # type: ignore reportIncompatibleMethodOverride
        self, expr: BinaryExpr, rewriter: PatternRewriter
    ) -> None:
        if expr.op.data == "//":
            return
        if len(expr.results[0].uses) == 0:
            rewriter.replace_op(expr, [], [None])
        return


class ChocoFlatDeadCodeElimination(ModulePass):
    name = "choco-flat-dead-code-elimination"

    def apply(self, ctx: MLContext, op: ModuleOp) -> None:
        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier(
                [
                    LiteralRewriter(),
                    BinaryExprRewriter(),
                ]
            ),
            walk_reverse=True,
        )
        walker.rewrite_module(op)
