// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// True
// False
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    "choco_ast.literal"() <{"value" = #choco_ast.bool<False>}> : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = #choco_ast.bool<False>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
