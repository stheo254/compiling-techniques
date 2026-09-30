#!/usr/bin/env python3

import sys
from io import IOBase
from typing import IO, TYPE_CHECKING, Callable, Mapping, Type

if TYPE_CHECKING:
    from xdsl.dialects.builtin import ModuleOp
from xdsl.passes import ModulePass, ModulePassT, PipelinePass
from xdsl.printer import Printer
from xdsl.utils.parse_pipeline import PipelinePassSpec
from xdsl.xdsl_opt_main import xDSLOptMain


from choco.warn_dead_code import DeadCodeError, WarnDeadCode
from choco.lexer import Lexer as ChocoLexer
from choco.parser import Parser as ChocoParser
from choco.parser import SyntaxError
from choco.semantic_error import SemanticError
from riscv.printer import print_program


def get_builtin():
    from xdsl.dialects.builtin import Builtin

    return Builtin


def get_riscv():
    from riscv.dialect import RISCV

    return RISCV


def get_riscv_ssa():
    from riscv.ssa_dialect import RISCVSSA

    return RISCVSSA


def get_choco_ast():
    from choco.dialects.choco_ast import ChocoAST

    return ChocoAST


def get_choco_flat():
    from choco.dialects.choco_flat import ChocoFlat

    return ChocoFlat


def get_check_assign_target():
    from choco.check_assign_target import CheckAssignTargetPass

    return CheckAssignTargetPass


def get_name_analysis():
    from choco.name_analysis import NameAnalysis

    return NameAnalysis


def get_type_checking():
    from choco.type_checking import TypeChecking

    return TypeChecking


def get_warn_dead_code():
    from choco.warn_dead_code import WarnDeadCode

    return WarnDeadCode


def get_choco_ast_to_choco_flat():
    from choco.choco_ast_to_choco_flat import ChocoASTToChocoFlat

    return ChocoASTToChocoFlat


def get_choco_flat_introduce_library_calls():
    from choco.choco_flat_introduce_library_calls import ChocoFlatIntroduceLibraryCalls

    return ChocoFlatIntroduceLibraryCalls


def get_choco_flat_constant_folding():
    from choco.constant_folding import ChocoFlatConstantFolding

    return ChocoFlatConstantFolding


def get_choco_flat_dead_code_elimination():
    from choco.dead_code_elimination import ChocoFlatDeadCodeElimination

    return ChocoFlatDeadCodeElimination


def get_for_to_while():
    from choco.for_to_while import ForToWhile

    return ForToWhile


def get_choco_flat_to_riscv_ssa():
    from choco.choco_flat_to_riscv_ssa import ChocoFlatToRISCVSSA

    return ChocoFlatToRISCVSSA


def get_riscv_ssa_to_riscv():
    from riscv.register_allocation import RISCVSSAToRISCV

    return RISCVSSAToRISCV


def get_riscv_function_lowering():
    from riscv.function_lowering import RISCVFunctionLowering

    return RISCVFunctionLowering


class ChocoOptMain(xDSLOptMain):
    passes_native: dict[str, Callable[[], type[ModulePass]]] = {
        # Semantic Analysis
        "check-assign-target": get_check_assign_target,
        "name-analysis": get_name_analysis,
        "type-checking": get_type_checking,
        "warn-dead-code": get_warn_dead_code,
        # IR Generation
        "choco-ast-to-choco-flat": get_choco_ast_to_choco_flat,
        # IR Optimization
        "choco-flat-introduce-library-calls": get_choco_flat_introduce_library_calls,
        "choco-flat-constant-folding": get_choco_flat_constant_folding,
        "choco-flat-dead-code-elimination": get_choco_flat_dead_code_elimination,
        "for-to-while": get_for_to_while,
        # Code Generation
        "choco-flat-to-riscv-ssa": get_choco_flat_to_riscv_ssa,
        "riscv-ssa-to-riscv": get_riscv_ssa_to_riscv,
        "riscv-function-lowering": get_riscv_function_lowering,
    }

    def register_all_passes(self):
        for name, pass_ in self.passes_native.items():
            self.register_pass(name, pass_)

    def _output_risc(self, prog: "ModuleOp", output: IOBase):
        print_program(prog.ops, "riscv", stream=output)  # type: ignore

    def register_all_targets(self):
        super().register_all_targets()
        self.available_targets["riscv"] = lambda prog, output: print_program(
            prog.ops, "riscv", stream=output  # type: ignore
        )

    def pipeline_entry(
        self, k: str, entries: Mapping[str, Callable[[], Type[ModulePassT]]]
    ):
        """Helper function that returns a pass"""
        if k in entries.keys():
            return entries[k]().name

    def setup_pipeline(self):
        entries = {
            "type": get_type_checking,
            "warn": get_warn_dead_code,
            "ir": get_choco_ast_to_choco_flat,
            "fold": get_choco_flat_constant_folding,
            "iropt": get_for_to_while,
            "riscv": get_choco_flat_to_riscv_ssa,
        }

        if self.args.passes != "all":
            if self.args.passes in entries:
                pipeline = list(self.available_passes.keys())
                entry = self.pipeline_entry(self.args.passes, entries)
                if entry is None:
                    raise Exception(
                        f"ModulePass corresponding to {self.args.passes} doesn't have a name!"
                    )
                if entry not in ["warn-dead-code"]:
                    # the case where our entry is warn-dead-code only
                    pipeline = list(filter(lambda x: x != "warn-dead-code", pipeline))
                pipeline = [
                    PipelinePassSpec(p, dict())
                    for p in pipeline[: pipeline.index(entry) + 1]
                ]
            else:
                super().setup_pipeline()
                return

        else:
            pipeline = [
                PipelinePassSpec(p, dict())
                for p in self.available_passes
                if p != "warn-dead-code"
            ]

        def callback(
            previous_pass: ModulePass, module: "ModuleOp", next_pass: ModulePass
        ) -> None:
            if not self.args.disable_verify:
                module.verify()
            if self.args.print_between_passes:
                print(f"IR after {previous_pass.name}:")
                printer = Printer(stream=sys.stdout)
                printer.print_op(module)
                print("\n\n\n")

        self.pipeline = PipelinePass(
            tuple(self.available_passes[p.name]().from_pass_spec(p) for p in pipeline),
            callback,
        )

    def register_all_dialects(self):
        """Register all dialects that can be used."""
        self.ctx.register_dialect("builtin", get_builtin)
        self.ctx.register_dialect("riscv", get_riscv)
        self.ctx.register_dialect("riscv_ssa", get_riscv_ssa)
        self.ctx.register_dialect("choco_ast", get_choco_ast)
        self.ctx.register_dialect("choco_ir", get_choco_flat)

    def register_all_frontends(self):
        super().register_all_frontends()

        def parse_choco(f: IO[str]):
            lexer = ChocoLexer(f)  # type: ignore
            parser = ChocoParser(lexer)
            program = parser.parse_program()
            return program

        self.available_frontends["choc"] = parse_choco


def __main__():
    choco_main = ChocoOptMain()

    try:
        chunks, file_extension = choco_main.prepare_input()
        output_stream = choco_main.prepare_output()
        for i, (chunk, offset) in enumerate(chunks):
            try:
                if i > 0:
                    output_stream.write("// -----\n")
                module = choco_main.parse_chunk(chunk, file_extension, offset)
                if module is not None:
                    if choco_main.apply_passes(module):
                        output_stream.write(choco_main.output_resulting_program(module))
                output_stream.flush()
            finally:
                chunk.close()
    except SyntaxError as e:
        print(e.get_message())
        exit(0)
    except SemanticError as e:
        print("Semantic error: %s" % str(e))
        exit(0)
    except DeadCodeError as e:
        print(f"[Warning] Dead code found: {e}")
        exit(0)


if __name__ == "__main__":
    __main__()
