// RUN: choco-opt -p choco-ast-to-choco-flat "%s" | filecheck "%s"

//
// print(1)
//

builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.call_expr"() <{"func" = "print", "type_hint" = !choco_ir.named_type<"<None>">}> ({
      "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     %0 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     "choco_ir.call_expr"(%0) <{"func_name" = "print"}> : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
