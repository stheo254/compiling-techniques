// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// not True
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.unary_expr"() <{"op" = "not"}> ({
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.unary_expr"() <{"op" = "not", "type_hint" = !choco_ir.named_type<"bool">}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
