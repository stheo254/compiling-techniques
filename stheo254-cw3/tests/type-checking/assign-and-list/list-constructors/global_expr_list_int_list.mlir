// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [[1]]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.list_expr"() ({
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.list_type<!choco_ir.named_type<"int">>>}> ({
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
