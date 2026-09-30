// RUN: choco-opt "%s" | filecheck "%s"

// This test checks if the verifiers work as expected

//
// x: int = 0
// l: [int] = None
// y: int = 0
// x
// l[y] = y
//

builtin.module {
    %0 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
    %1 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
    "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
    %2 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
    %3 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>
    "choco_ir.store"(%3, %2) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>, !choco_ir.named_type<"<None>">) -> ()
    %4 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
    %5 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
    "choco_ir.store"(%5, %4) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
    %6 = "choco_ir.load"(%5) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
    %7 = "choco_ir.load"(%3) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>) -> !choco_ir.list_type<!choco_ir.named_type<"int">>
    %8 = "choco_ir.load"(%5) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
    %9 = "choco_ir.get_address"(%7, %8) : (!choco_ir.list_type<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> !choco_ir.memloc<!choco_ir.named_type<"int">>
    "choco_ir.store"(%9, %6) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
}

// CHECK:      builtin.module {
// CHECK-NEXT:   %0 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:   %1 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:   "choco_ir.store"(%1, %0) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   %2 = "choco_ir.literal"() <{"value" = #choco_ir.none}> : () -> !choco_ir.named_type<"<None>">
// CHECK-NEXT:   %3 = "choco_ir.alloc"() <{"type" = !choco_ir.list_type<!choco_ir.named_type<"int">>}> : () -> !choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>
// CHECK-NEXT:   "choco_ir.store"(%3, %2) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>, !choco_ir.named_type<"<None>">) -> ()
// CHECK-NEXT:   %4 = "choco_ir.literal"() <{"value" = 0 : i32}> : () -> !choco_ir.named_type<"int">
// CHECK-NEXT:   %5 = "choco_ir.alloc"() <{"type" = !choco_ir.named_type<"int">}> : () -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:   "choco_ir.store"(%5, %4) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT:   %6 = "choco_ir.load"(%5) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
// CHECK-NEXT:   %7 = "choco_ir.load"(%3) : (!choco_ir.memloc<!choco_ir.list_type<!choco_ir.named_type<"int">>>) -> !choco_ir.list_type<!choco_ir.named_type<"int">>
// CHECK-NEXT:   %8 = "choco_ir.load"(%5) : (!choco_ir.memloc<!choco_ir.named_type<"int">>) -> !choco_ir.named_type<"int">
// CHECK-NEXT:   %9 = "choco_ir.get_address"(%7, %8) : (!choco_ir.list_type<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> !choco_ir.memloc<!choco_ir.named_type<"int">>
// CHECK-NEXT:   "choco_ir.store"(%9, %6) : (!choco_ir.memloc<!choco_ir.named_type<"int">>, !choco_ir.named_type<"int">) -> ()
// CHECK-NEXT: }
