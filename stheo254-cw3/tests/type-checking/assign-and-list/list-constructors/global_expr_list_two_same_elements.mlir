// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [True, False]
// [2, 3]
// ["foo", "bar"]
// [[], []]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.bool<False>}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 3 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = "foo"}> : () -> ()
      "choco_ast.literal"() <{"value" = "bar"}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.list_expr"() ({
      ^1:
      }) : () -> ()
      "choco_ast.list_expr"() ({
      ^2:
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"bool">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<False>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 3 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "foo", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "bar", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"<Empty>">>}> ({
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.named_type<"<Empty>">}> ({
// CHECK-NEXT:       ^1:
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.named_type<"<Empty>">}> ({
// CHECK-NEXT:       ^2:
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
