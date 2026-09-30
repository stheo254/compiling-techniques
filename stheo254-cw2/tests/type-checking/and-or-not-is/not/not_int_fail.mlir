// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// not 0
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.unary_expr"() <{"op" = "not"}> ({
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
