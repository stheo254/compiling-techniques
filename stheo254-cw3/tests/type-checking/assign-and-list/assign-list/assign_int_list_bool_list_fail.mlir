// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// a: [bool] = None
// a = [1, 2]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "a"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "a"}> : () -> ()
    }, {
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 1 : i32}> : () -> ()
        "choco_ast.literal"() <{"value" = 2 : i32}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
