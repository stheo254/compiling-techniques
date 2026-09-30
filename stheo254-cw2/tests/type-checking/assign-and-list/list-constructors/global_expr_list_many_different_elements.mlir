// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [True, 1, "test", None, [2], [[[2], [None], [True, 1]]]]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = "test"}> : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.list_expr"() ({
          "choco_ast.list_expr"() ({
            "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
          }) : () -> ()
          "choco_ast.list_expr"() ({
            "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
          }) : () -> ()
          "choco_ast.list_expr"() ({
            "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
            "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
          }) : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "test", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.list_type<!choco_ir.named_type<"object">>>}> ({
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> ({
// CHECK-NEXT:           "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:             "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:           }) : () -> ()
// CHECK-NEXT:           "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"<None>">>}> ({
// CHECK-NEXT:             "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:           }) : () -> ()
// CHECK-NEXT:           "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> ({
// CHECK-NEXT:             "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:             "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:           }) : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
