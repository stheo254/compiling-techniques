// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// x: object = None
// y: object = None
// x = y = x = None
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "y"}> ({
        "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
    }, {
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "y"}> : () -> ()
      }, {
        "choco_ast.assign"() ({
          "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
        }, {
          "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "x"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "y"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.assign"() ({
// CHECK-NEXT:       "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"object">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.assign"() ({
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "y", "type_hint" = !choco_ir.named_type<"object">}> : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.assign"() ({
// CHECK-NEXT:           "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"object">}> : () -> ()
// CHECK-NEXT:         }, {
// CHECK-NEXT:           "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
