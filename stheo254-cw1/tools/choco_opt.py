#!/usr/bin/env python3

from typing import IO, Callable, List, Mapping, Type

from xdsl.passes import ModulePass, ModulePassT, PipelinePass
from xdsl.xdsl_opt_main import xDSLOptMain

from choco.dialects.choco_ast import ChocoAST
from choco.lexer import Lexer as ChocoLexer
from choco.parser import Parser as ChocoParser


def get_choco_ast():
    from choco.dialects.choco_ast import ChocoAST

    return ChocoAST


class ChocoOptMain(xDSLOptMain):
    passes_native: dict[str, Callable[[], type[ModulePass]]] = {}

    def register_all_passes(self):
        for name, pass_ in self.passes_native.items():
            self.register_pass(name, pass_)

    def pipeline_entry(
        self, k: str, entries: Mapping[str, Callable[[], Type[ModulePassT]]]
    ):
        """Helper function that returns a pass"""
        if k in entries.keys():
            return entries[k]().name

    def setup_pipeline(self):
        self.pipeline = PipelinePass(())

    def register_all_dialects(self):
        """Register all dialects that can be used."""
        self.ctx.register_dialect("choco_ast", get_choco_ast)

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


if __name__ == "__main__":
    __main__()
