// RUN: choco-opt -p name-analysis "%s" | filecheck "%s"

//
// x: int = 0
// def foo():
//     y: int = 0
//     y = x
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.func_def"() <{"func_name" = "foo"}> ({
    ^0:
    }, {
      "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
    }, {
      "choco_ast.var_def"() ({
        "choco_ast.typed_var"() <{"var_name" = "y"}> ({
          "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
        }) : () -> ()
      }, {
        "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
      }) : () -> ()
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "y"}> : () -> ()
      }, {
        "choco_ast.id_expr"() <{"id" = "x"}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }, {
  ^1:
  }) : () -> ()
}

// CHECK: builtin.module {
