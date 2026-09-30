// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// o: object = None
// o == o
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "o"}> ({
        "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.binary_expr"() <{"op" = "=="}> ({
      "choco_ast.id_expr"() <{"id" = "o"}> : () -> ()
    }, {
      "choco_ast.id_expr"() <{"id" = "o"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
