// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// True >= 0
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.binary_expr"() <{"op" = ">="}> ({
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
