// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// s: [int] = None
// i: int = 0
// res: int = 0
//
// res = s[i]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "s"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "i"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "res"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "res"}> : () -> ()
    }, {
      "choco_ast.index_expr"() ({
        "choco_ast.id_expr"() <{"id" = "s"}> : () -> ()
      }, {
        "choco_ast.id_expr"() <{"id" = "i"}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "s"}> ({
// CHECK-NEXT:         "choco_ast.list_type"() ({
// CHECK-NEXT:           "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "i"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "res"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "res", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.index_expr"() <{"type_hint" = !choco_ir.named_type<"int">}> ({
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "s", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "i", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
