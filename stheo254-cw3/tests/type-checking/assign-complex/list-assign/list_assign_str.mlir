// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// x: [str] = None
// x[0] = "foo"
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.index_expr"() ({
        "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
      }, {
        "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = "foo"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "x"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.index_expr"() <{"type_hint" = !choco_ir.named_type<"str">}> ({
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "foo", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
