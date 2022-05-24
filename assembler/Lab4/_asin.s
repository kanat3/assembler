    .arch   armv8-a
    .data
filename:
    .string "_acsin_logfile.txt"
mes1:
    .string "P.S |x| <= 1\nInput x: "
formatdouble:
    .string "%lf"
filedouble:
    .string "%.10f\n"
mes3:
    .string "Input accuracy: "
fileint:
    .string "%.0lf ---> "
mes5:
    .string "Asin: %.10g\n"
mes6:
    .string "My _asin: %.10g\n"
mes7:
    .string "0: %.10lf\n"
mes8:
    .string "%.0ld: %.10lf\n"
    .text
    .align  2
    .global main
    .type   main,   %function
    .equ    result, 40
    .equ    x,  32
    .equ    acc,    24
main:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str xzr, [x29, x]
    str xzr, [x29, acc]
    str xzr, [x29, result]
    adr x0, mes1
    bl  printf
    adr x0, formatdouble
    add x1, x29, x
    bl  scanf
    ldr d0, [x29, x]
    adr x0, mes3
    bl printf
    adr x0, formatdouble
    add x1, x29, acc
    bl scanf
    ldr d0, [x29, x]
    bl  asin
    str d0, [x29, result]
    adr x0, mes5
    ldr d0, [x29, result]
    bl  printf
    ldr d0, [x29, x]
    ldr d1, [x29, acc]
    bl  my_asin
    str d0, [x29, result]
    adr x0, mes6
    ldr d0, [x29, result]
    bl printf
    mov w0, #0
    ldp x29, x30, [sp], #48
    ret
    .size   main, .-main
    .global power
    .type   power, %function
    .equ    x, 24
    .equ    n, 16
power:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str d0, [x29, x]
    str x0, [x29, n]
    ldr x0, [x29, n]
    cmp x0, 0
    bne L2
    fmov d0, #1.0
    b   L3
L2:
    ldr x0, [x29, n]
    cmp x0, 0
    bge L4
    fmov d1, #1.0
    ldr d0, [x29, x]
    fdiv d0, d1, d0
    ldr x0, [x29, n]
    neg x0, x0 // n --> -n
    bl power
    b L3
L4:
    ldr x0, [x29, n]
    sub x0, x0, #1
    ldr d0, [x29, x]
    bl power
    fmov d1, d0
    ldr d0, [x29, x]
    fmul d0, d1, d0
L3:
    ldp x29, x30, [sp], 32
    ret
    .global factorial
    .type   factorial, %function
    .equ    n, 40
factorial:
    stp x29, x30, [sp, -48]!
    mov x29, sp
    str d8, [sp, 16]
    str x0, [x29, n]
    ldr x0, [x29, n]
    scvtf d0, x0 // fix point -> free point
    fcmp d0, #0.0
    beq L6
    ldr x0, [x29, n]
    scvtf d1, x0
    fmov d0, #1.0
    fcmp d1, d0
    bne L7
L6:
    fmov d0, #1.0
    b L8
L7:
    ldr x0, [x29, n]
    scvtf d8, x0
    ldr x0, [x29, n]
    sub x0, x0, #1
    bl factorial
    fmul d0, d8, d0
L8:
    ldr d8, [sp, 16]
    ldp x29, x30, [sp], 48
    ret
    .global series_member
    .type   series_member, %function
    .equ    x, 40
    .equ    n, 32
series_member:
    stp x29, x30, [sp, -48]!
    mov x29, sp
    stp d8, d9, [sp, 16]
    str d0, [x29, x]
    str x0, [x29, n]
    ldr x0, [x29, n]
    lsl x0, x0, #1
    add x0, x0, #1
    ldr d0, [x29, x]
    bl power
    fmov d8, d0
    ldr x0, [x29, n]
    lsl x0, x0, #1
    bl factorial
    fmul d8, d8, d0
    ldr x0, [x29, n]
    fmov d0, #4.0
    bl power
    fmov d9, d0
    ldr x0, [x29, n]
    bl factorial
    mov x0, #2
    bl power
    fmul d1, d9, d0
    ldr x0, [x29, n]
    lsl x0, x0, #1
    add x0, x0, #1
    scvtf d0, x0
    fmul d0, d1, d0
    fdiv d0, d8, d0
    ldp d8, d9, [sp, 16]
    ldp x29, x30, [sp], 48
    ret
    .global my_asin
    .type   my_asin, %function
    .equ    x, 24
    .equ    n, 56
    .equ    sum, 48
    .equ    acc, 16
    .equ    prevsum, 40
my_asin:
    stp x29, x30, [sp, -64]!
    mov x29, sp
    str d0, [x29, x]
    str d1, [x29, acc]
    mov x0, #1
    str x0, [x29, n]
    ldr d0, [x29, x]
    str d0, [x29, sum]
    str xzr, [x29, prevsum]
    adr x0, mes7
    ldr d0, [x29, sum]
    bl printf
    ldr d0, [x29, sum]
    str d0, [x29, prevsum]
    ldr x0, [x29, n]
    ldr d0, [x29, x]
    bl series_member
    fmov d1, d0
    ldr d0, [x29, sum]
    fadd d0, d0, d1
    str d0, [x29, sum]
    ldr x0, [x29, n]
    add x0, x0, #1
    str x0, [x29, n]
L13:
    ldr d1, [x29, sum]
    ldr d0, [x29, prevsum]
    fsub d1, d1, d0
    ldr d0, [x29, acc]
    fcmpe d1, d0 // sum - prevsum >= acc
    blt L12
    ldr d0, [x29, sum]
    str d0, [x29, prevsum]
    ldr x0, [x29, n]
    ldr d0, [x29, x]
    bl series_member
    fmov d1, d0
    ldr d0, [x29, sum]
    fadd d0, d0, d1
    str d0, [x29, sum]
    ldr x0, [x29, n]
    sub x1, x0, #1
    adr x0, mes8
    ldr d0, [x29, sum]
    bl printf
    ldr x0, [x29, n]
    add x0, x0, #1
    str x0, [x29, n]
    b L13 // while
L12:
    ldr d0, [x29, sum]
    ldp x29, x30, [sp], 64
    ret













