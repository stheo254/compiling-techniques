// RUN: choco-opt -p choco-flat-introduce-library-calls "%s" | filecheck "%s"

//
// print(True)
//

builtin.module {
  %0 = "choco_ir.literal"() <{"value" = #choco_ir.bool<True>}> : () -> !choco_ir.named_type<"bool">
  "choco_ir.call_expr"(%0) <{"func_name" = "print"}> : (!choco_ir.named_type<"bool">) -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   %0 = "choco_ir.literal"() <{"value" = #choco_ir.bool<True>}> : () -> !choco_ir.named_type<"bool">
// CHECK-NEXT:   "choco_ir.call_expr"(%0) <{"func_name" = "_print_bool"}> : (!choco_ir.named_type<"bool">) -> ()
// CHECK-NEXT: }
