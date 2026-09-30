// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// pass
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.pass"() : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.pass"() : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
