// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// b: bool = True
// for b in [0]:
//   b = True
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "b"}> ({
        "choco_ast.type_name"() <{"type_name" = "bool"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.for"() <{"iter_name" = "b"}> ({
      "choco_ast.list_expr"() ({
        "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "b"}> : () -> ()
      }, {
        "choco_ast.literal"() <{"value" = #choco_ast.bool<True>}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK: Semantic error:
