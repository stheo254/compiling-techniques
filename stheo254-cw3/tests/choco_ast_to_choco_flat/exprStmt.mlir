// RUN: choco-opt -p choco-ast-to-choco-flat "%s" | filecheck "%s"

//
// def noresult():
//     return
//
// def noresult2(x: int):
//     return
//
// def result() -> int:
//     return 42
//
// 1
// 1 + 1
//
// noresult()
// noresult2(result())
//

builtin.module {
  "choco_ast.program"() ({
    "choco_ast.func_def"() <{"func_name" = "noresult"}> ({
    ^0:
    }, {
      "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
    }, {
      "choco_ast.return"() ({
      ^1:
      }) : () -> ()
    }) : () -> ()
    "choco_ast.func_def"() <{"func_name" = "noresult2"}> ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.type_name"() <{"type_name" = "<None>"}> : () -> ()
    }, {
      "choco_ast.return"() ({
      ^2:
      }) : () -> ()
    }) : () -> ()
    "choco_ast.func_def"() <{"func_name" = "result"}> ({
    ^3:
    }, {
      "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
    }, {
      "choco_ast.return"() ({
        "choco_ast.literal"() <{"value" = 42 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    "choco_ast.binary_expr"() <{"op" = "+", "type_hint" = !choco_ir.named_type<"int">}> ({
      "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    }) : () -> ()
    "choco_ast.call_expr"() <{"func" = "noresult", "type_hint" = !choco_ir.named_type<"<None>">}> ({
    ^4:
    }) : () -> ()
    "choco_ast.call_expr"() <{"func" = "noresult2", "type_hint" = !choco_ir.named_type<"<None>">}> ({
      "choco_ast.call_expr"() <{"func" = "result", "type_hint" = !choco_ir.named_type<"int">}> ({
      ^5:
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     "choco_ir.func_def"() <{"func_name" = "noresult", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:       %0 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:       "choco_ir.return"(%0) : (!choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ir.func_def"() <{"func_name" = "noresult2", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     ^0(%1 : !choco_ir.named_type<"int">):
// CHECK-NEXT:       %2 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:       "choco_ir.store"(%2, %1) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:       %3 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:       "choco_ir.return"(%3) : (!choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     "choco_ir.func_def"() <{"func_name" = "result", "return_type" = !choco_ir.named_type<"int">}> ({
// CHECK-NEXT:       %4 = "choco_ir.literal"() <{"value" = 42 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:       "choco_ir.return"(%4) : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     %5 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %6 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %7 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %8 = "choco_ir.binary_expr"(%6, %7) <{"op" = "+"}> : (!choco_ir.named_type<"int">, !choco_ir.named_type<"int">) -> !choco_ir.named_type<"int">
// CHECK-NEXT:     "choco_ir.call_expr"() <{"func_name" = "noresult"}> : () -> ()
// CHECK-NEXT:     %9 = "choco_ir.call_expr"() <{"func_name" = "result"}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     "choco_ir.call_expr"(%9) <{"func_name" = "noresult2"}> : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
