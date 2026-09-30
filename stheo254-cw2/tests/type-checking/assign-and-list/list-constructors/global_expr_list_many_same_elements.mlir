// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [True, False, True, True]
// [1, 2, 3, 4, 5, 6]
// ["f", "o", "o", "b", "a", "r"]
// [[0], [1], [2], [3], [4], [5], [6], [7]]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.bool<False>}> : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 3 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 4 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 5 : i32}> : () -> ()
      "choco_ast.literal"() <{"value" = 6 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.literal"() <{"value" = "f"}> : () -> ()
      "choco_ast.literal"() <{"value" = "o"}> : () -> ()
      "choco_ast.literal"() <{"value" = "o"}> : () -> ()
      "choco_ast.literal"() <{"value" = "b"}> : () -> ()
      "choco_ast.literal"() <{"value" = "a"}> : () -> ()
      "choco_ast.literal"() <{"value" = "r"}> : () -> ()
    }) : () -> ()
    "choco_ast.list_expr"() ({
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 3 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 4 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 5 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 6 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 7 : i32}> : () -> ()
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
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 3 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 4 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 5 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 6 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "f", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "o", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "o", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "b", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "a", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "r", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.list_type<!choco_ir.named_type<"int">>>}> ({
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 3 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 4 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 5 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 6 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 7 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
