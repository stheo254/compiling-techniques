// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// a: bool = True
// a = True and [True]
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "a"}> ({
        "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "a"}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "and"}> ({
        "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      }, {
        "choco_ast.list_expr"() ({
          "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
