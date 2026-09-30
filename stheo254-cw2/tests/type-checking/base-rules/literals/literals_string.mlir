// RUN: choco-opt -p check-assign-target,name-analysis,type-checking "%s" | filecheck "%s"

//
// "Hello"
// "He\"ll\"o"
// "He\nllo"
// "He\\\"llo"
//


builtin.module {
  "choco_ast.program"() ({
  ^0:
  }, {
    "choco_ast.literal"() <{"value" = "Hello"}> : () -> ()
    "choco_ast.literal"() <{"value" = "He\"ll\"o"}> : () -> ()
    "choco_ast.literal"() <{"value" = "He\nllo"}> : () -> ()
    "choco_ast.literal"() <{"value" = "He\\\"llo"}> : () -> ()
  }) : () -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   "choco_ast.program"() ({
// CHECK-NEXT:   ^0:
// CHECK-NEXT:   }, {
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = "Hello", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = "He\"ll\"o", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = "He\nllo", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:     "choco_ast.literal"() <{"value" = "He\\\"llo", "type_hint" = !choco_ir.named_type<"str">}> : () -> ()
// CHECK-NEXT:   }) : () -> ()
// CHECK-NEXT: }
