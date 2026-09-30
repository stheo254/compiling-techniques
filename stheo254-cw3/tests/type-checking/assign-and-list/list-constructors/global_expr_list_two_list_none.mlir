// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [[], None]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.list_expr"() ({
      "choco_ast.list_expr"() ({
      ^1:
      }) : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"<Empty>">>}> ({
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.named_type<"<Empty>">}> ({
// CHECK-NEXT:       ^1:
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
