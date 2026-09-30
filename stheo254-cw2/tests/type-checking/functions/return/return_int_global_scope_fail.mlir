// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// return 0
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.return"() ({
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
