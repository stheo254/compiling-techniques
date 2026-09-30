// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// x: int = 0
//
// def foo():
//   global x
//   x = 2
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.func_def"() <{"func_name" = "foo"}> ({
    ^0:
    }, {
      "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
    }, {
      "choco_ast.global_decl"() <{"decl_name" = "x"}> : () -> ()
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
      }, {
        "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }, {
  ^1:
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.var_def"() ({
// CHECK-NEXT:       "choco_ast.typed_var"() <{"var_name" = "x"}> ({
// CHECK-NEXT:         "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ast.func_def"() <{"func_name" = "foo"}> ({
// CHECK-NEXT:     ^0:
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.global_decl"() <{"decl_name" = "x"}> : () -> ()
// CHECK-NEXT:       "choco_ast.assign"() ({
// CHECK-NEXT:         "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }, {
// CHECK-NEXT:         "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:   ^1:
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
