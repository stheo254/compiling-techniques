// RUN: choco-opt -p choco-ast-to-choco-flat "%s" | filecheck "%s"

//
// x: int = 0
//

builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    }) : () -> ()
  }, {
  ^0:
  }) : () -> ()
}


// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     %0 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %1 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:     "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
