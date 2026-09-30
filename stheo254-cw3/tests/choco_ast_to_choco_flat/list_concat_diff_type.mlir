// RUN: choco-opt -p "choco-ast-to-choco-flat" "%s" | filecheck "%s"

//
// l1: [int] = None
// l2: [str] = None
// l3: [object] = None
// l1 = [1,2,3]
// l2 = ["1","2","3"]
// l3 = l1 + l2
//

builtin.module {
  "choco_ast.program"() ({
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l1"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "int"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l2"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "str"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
    }) : () -> ()
    "choco_ast.var_def"() ({
      "choco_ast.typed_var"() <{"var_name" = "l3"}> ({
        "choco_ast.list_type"() ({
          "choco_ast.type_name"() <{"type_name" = "object"}> : () -> ()
        }) : () -> ()
      }) : () -> ()
    }, {
      "choco_ast.literal"() <{"value" = #choco_ast.none, "type_hint" = !choco_ir.named_type<"<None>">}> : () -> ()
    }) : () -> ()
  }, {
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l1", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> ()
    }, {
      "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> ({
        "choco_ast.literal"() <{"value" = 1 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
        "choco_ast.literal"() <{"value" = 2 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
        "choco_ast.literal"() <{"value" = 3 : i32, "type_hint" = !choco_ir.named_type<"int">}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l2", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
    }, {
      "choco_ast.list_expr"() <{"type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> ({
        "choco_ast.literal"() <{"value" = "1", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "2", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
        "choco_ast.literal"() <{"value" = "3", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
      }) : () -> ()
    }) : () -> ()
    "choco_ast.assign"() ({
      "choco_ast.id_expr"() <{"id" = "l3", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> : () -> ()
    }, {
      "choco_ast.binary_expr"() <{"op" = "+", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> ({
        "choco_ast.id_expr"() <{"id" = "l1", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> ()
      }, {
        "choco_ast.id_expr"() <{"id" = "l2", "type_hint" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> ()
      }) : () -> ()
    }) : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ir.func_def"() <{"func_name" = "_main", "return_type" = !choco_ir.named_type<"<None>">}> ({
// CHECK-NEXT:     %0 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:     %1 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>
// CHECK-NEXT:     "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>, !choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     %2 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:     %3 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"str">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>
// CHECK-NEXT:     "choco_ir.store"(%3, %2) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>, !choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     %4 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:     %5 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"object">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"object">>>
// CHECK-NEXT:     "choco_ir.store"(%5, %4) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"object">>>, !choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:     %6 = "choco_ir.literal"() <{"value" = 1 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %7 = "choco_ir.literal"() <{"value" = 2 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %8 = "choco_ir.literal"() <{"value" = 3 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:     %9 = "choco_ir.list_expr"(%6, %7, %8) : (!choco_ir.named_type<"int">, !choco_ir.named_type<"int">, !choco_ir.named_type<"int">) -> !choco_ir.list_type<!choco_ir.named_type<"int">>
// CHECK-NEXT:     "choco_ir.store"(%1, %9) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>, !choco_ir.list_type<!choco_ir.named_type<"int">>) -> ()
// CHECK-NEXT:     %10 = "choco_ir.literal"() <{"value" = "1"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %11 = "choco_ir.literal"() <{"value" = "2"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %12 = "choco_ir.literal"() <{"value" = "3"}> : () -> !choco_ir.named_type<"str">
// CHECK-NEXT:     %13 = "choco_ir.list_expr"(%10, %11, %12) : (!choco_ir.named_type<"str">, !choco_ir.named_type<"str">, !choco_ir.named_type<"str">) -> !choco_ir.list_type<!choco_ir.named_type<"str">>
// CHECK-NEXT:     "choco_ir.store"(%3, %13) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>, !choco_ir.list_type<!choco_ir.named_type<"str">>) -> ()
// CHECK-NEXT:     %14 = "choco_ir.load"(%1) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>) -> !choco_ir.list_type<!choco_ir.named_type<"int">>
// CHECK-NEXT:     %15 = "choco_ir.load"(%3) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"str">>>) -> !choco_ir.list_type<!choco_ir.named_type<"str">>
// CHECK-NEXT:     %16 = "choco_ir.binary_expr"(%14, %15) <{"op" = "+"}> : (!choco_ir.list_type<!choco_ir.named_type<"int">>, !choco_ir.list_type<!choco_ir.named_type<"str">>) -> !choco_ir.list_type<!choco_ir.named_type<"object">>
// CHECK-NEXT:     "choco_ir.store"(%5, %16) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"object">>>, !choco_ir.list_type<!choco_ir.named_type<"object">>) -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
