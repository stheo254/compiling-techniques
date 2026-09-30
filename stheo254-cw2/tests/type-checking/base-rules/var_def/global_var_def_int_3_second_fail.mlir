// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// i: int = 0
// j: int = "foo"
// k: int = 0
//


builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "i"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "j"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = "foo"}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "k"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 0 : i32}> : () -> ()
    }) : () -> ()
  }, {
  ^0:
  }) : () -> ()
}

// CHECK: Semantic error:
