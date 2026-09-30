// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// b: bool = True
// b = [0] is ["0"]
// b = [True] is [1]
// b = [True] is [None]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "b"}> ({
        "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "b"}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "is"}> ({
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
        }) : () -> ()
      }, {
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = "0"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "b"}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "is"}> ({
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
        }) : () -> ()
      }, {
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "b"}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "is"}> ({
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
        }) : () -> ()
      }, {
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "b"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "b", "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.binary_expr"() <{"op" = "is", "type_hint" = !choco_ir.named_type<"bool">}> ({
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = "0", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "b", "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.binary_expr"() <{"op" = "is", "type_hint" = !choco_ir.named_type<"bool">}> ({
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"bool">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "b", "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.binary_expr"() <{"op" = "is", "type_hint" = !choco_ir.named_type<"bool">}> ({
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"bool">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"<None>">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
