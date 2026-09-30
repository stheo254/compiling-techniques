// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// l: [[int]] = None
// l = [[]]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.list_type"() ({
            "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
          }) : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.list_expr"() ({
        ^0:
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
