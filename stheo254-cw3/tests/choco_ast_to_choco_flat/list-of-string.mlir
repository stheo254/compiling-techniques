// RUN: choco-opt -p "choco-ast-to-choco-flat" "%s" | filecheck "%s"

//
// l: [str] = None
// s: str = ""
//
// l = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
// s = s + l[0]
// print(s)
//

builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "s"}> ({
        "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = "", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
    }, {
      "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
        "choco_ast.literal"() <{"value" = "0", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "1", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "2", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "3", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "4", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "5", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "6", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "7", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "8", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "9", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "s", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "+", "type_hint" = !choco_ir.named_type<"str">}> ({
        "choco_ast.id_expr"() <{"id" = "s", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
      }, {
        "choco_ast.index_expr"() <{"type_hint" = !choco_ir.named_type<"str">}> ({
          "choco_ast.id_expr"() <{"id" = "l", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
        }, {
          "choco_ast.literal"() <{"value" = 0 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.call_expr"() <{"func" = "print", "type_hint" = !choco_ir.named_type<"<None>">}> ({
      "choco_ast.id_expr"() <{"id" = "s", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     %0 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:     %1 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>
// CHECK-NEXT:     "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>, !choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     %2 = "choco_ir.literal"() <{"value" = ""}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %3 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"str">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"str">>
// CHECK-NEXT:     "choco_ir.store"(%3, %2) : (!choco_ir.memloc<!choco_ir.named_type<"str">>, !choco_ir.named_type<"str">) -> ()
// CHECK-NEXT:     %4 = "choco_ir.literal"() <{"value" = "0"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %5 = "choco_ir.literal"() <{"value" = "1"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %6 = "choco_ir.literal"() <{"value" = "2"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %7 = "choco_ir.literal"() <{"value" = "3"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %8 = "choco_ir.literal"() <{"value" = "4"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %9 = "choco_ir.literal"() <{"value" = "5"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %10 = "choco_ir.literal"() <{"value" = "6"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %11 = "choco_ir.literal"() <{"value" = "7"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %12 = "choco_ir.literal"() <{"value" = "8"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %13 = "choco_ir.literal"() <{"value" = "9"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %14 = "choco_ir.list_expr"(%4, %5, %6, %7, %8, %9, %10, %11, %12, %13) : (!choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">) -> !choco_ir.list_type<!choco_ir.named_type<"str">>
// CHECK-NEXT:     "choco_ir.store"(%1, %14) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>, !choco_ir.list_type<!choco_ir.named_type<"str">>) -> ()
// CHECK-NEXT:     %15 = "choco_ir.load"(%3) : (!choco_ir.memloc<!choco_ir.named_type<"str">>) -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %16 = "choco_ir.load"(%1) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>) -> !choco_ir.list_type<!choco_ir.named_type<"str">>
// CHECK-NEXT:     %17 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %18 = "choco_ir.get_address"(%16, %17) : (!choco_ir.list_type<!choco_ir.named_type<"str">>, !choco_ir.named_type<"int">) -> !choco_ir.memloc<!choco_ir.named_type<"str">>
// CHECK-NEXT:     %19 = "choco_ir.load"(%18) : (!choco_ir.memloc<!choco_ir.named_type<"str">>) -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %20 = "choco_ir.binary_expr"(%15, %19) <{"op" = "+"}> : (!choco_ir.named_type<"str">, !choco_ir.named_type<"str">) -> !choco_ir.named_type<"str">
// CHECK-NEXT:     "choco_ir.store"(%3, %20) : (!choco_ir.memloc<!choco_ir.named_type<"str">>, !choco_ir.named_type<"str">) -> ()
// CHECK-NEXT:     %21 = "choco_ir.load"(%3) : (!choco_ir.memloc<!choco_ir.named_type<"str">>) -> !choco_ir.named_type<"str">
// CHECK-NEXT:     "choco_ir.call_expr"(%21) <{"func_name" = "print"}> : (!choco_ir.named_type<"str">) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
