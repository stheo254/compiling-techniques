// RUN: choco-opt -p choco-flat-introduce-library-calls "%s" | filecheck "%s"

//
// print(1)
//

builtin.module {
  %0 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
  "choco_ir.call_expr"(%0) <{"func_name" = "print"}> : (!choco_ir.named_type<"int">) -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   %0 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:   "choco_ir.call_expr"(%0) <{"func_name" = "_print_int"}> : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT: }
