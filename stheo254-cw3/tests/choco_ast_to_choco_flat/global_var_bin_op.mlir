// RUN: choco-opt -p type-checking,choco-ast-to-choco-flat "%s" | filecheck "%s"

//
// x: int = 1
//
// def f() -> int:
//     global x
//     x = x + 2
//     return 3
//
// # Main program
// print(x + f())
//

builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "x"}> ({
        "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
    }) : () -> ()
    "choco_ast.func_def"() <{"func_name" = "f"}> ({
    ^0:
    }, {
      "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
    }, {
      "choco_ast.global_decl"() <{"decl_name" = "x"}> : () -> ()
      "choco_ast.assign"() ({
        "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
      }, {
        "choco_ast.binary_expr"() <{"op" = "+", "type_hint" = !choco_ir.named_type<"int">}> ({
          "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
        }, {
          "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
        }) : () -> ()
      }) : () -> ()
      "choco_ast.return"() ({
        "choco_ast.literal"() <{"value" = 3 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.call_expr"() <{"func" = "print", "type_hint" = !choco_ir.named_type<"<None>">}> ({
      "choco_ast.binary_expr"() <{"op" = "+", "type_hint" = !choco_ir.named_type<"int">}> ({
        "choco_ast.id_expr"() <{"id" = "x", "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
      }, {
        "choco_ast.call_expr"() <{"func" = "f", "type_hint" = !choco_ir.named_type<"int">}> ({
        ^1:
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     %0 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %1 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:     "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:     "choco_ir.func_def"() <{"func_name" = "f", "return_type" = !choco_ir.named_type<"int">}> ({
// CHECK-NEXT:       %2 = "choco_ir.load"(%1) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
// CHECK-NEXT:       %3 = "choco_ir.literal"() <{"value" = 2 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:       %4 = "choco_ir.binary_expr"(%2, %3) <{"op" = "+"}> : (!choco_ir.named_type<"int">, !choco_ir.named_type<"int">) -> !choco_ir.named_type<"int">
// CHECK-NEXT:       "choco_ir.store"(%1, %4) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:       %5 = "choco_ir.literal"() <{"value" = 3 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:       "choco_ir.return"(%5) : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:     }) : () -> ()
// CHECK-NEXT:     %6 = "choco_ir.load"(%1) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %7 = "choco_ir.call_expr"() <{"func_name" = "f"}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %8 = "choco_ir.binary_expr"(%6, %7) <{"op" = "+"}> : (!choco_ir.named_type<"int">, !choco_ir.named_type<"int">) -> !choco_ir.named_type<"int">
// CHECK-NEXT:     "choco_ir.call_expr"(%8) <{"func_name" = "print"}> : (!choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
