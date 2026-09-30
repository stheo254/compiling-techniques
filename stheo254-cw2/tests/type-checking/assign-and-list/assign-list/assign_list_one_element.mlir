// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// b: [bool] = None
// i: [int] = None
// s: [str] = None
// l: [[int]] = None
//
// b = [True]
// i = [2]
// s = ["foo"]
// l = [[1]]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "b"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "i"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "s"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.list_type"() ({
            "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
          }) : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "b"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "i"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "s"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = "foo"}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "b"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "i"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "s"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "l"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.list_type"() ({
// CHECK-NEXT:             "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:           }) : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "b", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"bool">>}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"bool">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = #choco_ast.bool<True>, "type_hint" = !choco_ir.named_type<"bool">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "i", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "s", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = "foo", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "l", "type_hint" = !choco_ir.list_type<!choco_ir.list_type<!choco_ir.named_type<"int">>>}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.list_type<!choco_ir.named_type<"int">>>}> ({
// CHECK-NEXT:         "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
