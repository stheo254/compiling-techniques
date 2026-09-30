// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// i: str = "foo"
// i = True
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "i"}> ({
        "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = "foo"}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "i"}> : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
