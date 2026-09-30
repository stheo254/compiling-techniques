// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// [0][None]
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.index_expr"() ({
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
