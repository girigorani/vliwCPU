; ModuleID = 'loop-if1.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 1, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %j, align 4
  br label %4

; <label>:4                                       ; preds = %17, %0
  %5 = load i32* %j, align 4
  %6 = icmp slt i32 %5, 1
  br i1 %6, label %7, label %20

; <label>:7                                       ; preds = %4
  %8 = load i32* %i, align 4
  %9 = icmp slt i32 %8, 2
  br i1 %9, label %10, label %13

; <label>:10                                      ; preds = %7
  %11 = load i32* %i, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %i, align 4
  br label %16

; <label>:13                                      ; preds = %7
  %14 = load i32* %i, align 4
  %15 = add nsw i32 %14, -1
  store i32 %15, i32* %i, align 4
  br label %16

; <label>:16                                      ; preds = %13, %10
  br label %17

; <label>:17                                      ; preds = %16
  %18 = load i32* %j, align 4
  %19 = add nsw i32 %18, 1
  store i32 %19, i32* %j, align 4
  br label %4

; <label>:20                                      ; preds = %4
  %21 = load i32* %1
  ret i32 %21
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
