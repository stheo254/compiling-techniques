// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// x: str = ""
// for x in "a":
//   x = ""
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = ""}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.for"() <{"iter_name" = "x"}> ({
      "choco_ast.literal"() <{"value" = "a"}> : () -> ()
    }, {
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
      }, {
        "choco_ast.literal"() <{"value" = ""}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "x"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.for"() <{"iter_name" = "x"}> ({
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = "a", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.assign"() ({
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = "", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
