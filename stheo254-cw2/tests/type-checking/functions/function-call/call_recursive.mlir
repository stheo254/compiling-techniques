// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// def foo():
//   return foo()
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.func_def"() <{"func_name" = "foo"}> ({
    ^0:
    }, {
      "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
    }, {
      "choco_ast.return"() ({
        "choco_ast.call_expr"() <{"func" = "foo"}> ({
        ^1:
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }, {
  ^2:
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:     "choco_ast.func_def"() <{"func_name" = "foo"}> ({
// CHECK-NEXT:     ^0:
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
// CHECK-NEXT:     }, {
// CHECK-NEXT:       "choco_ast.return"() ({
// CHECK-NEXT:         "choco_ast.call_expr"() <{"func" = "foo", "type_hint" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:         ^1:
// CHECK-NEXT:         }) : () -> ()
// CHECK-NEXT:       }) : () -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:   }, {
// CHECK-NEXT:   ^2:
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
