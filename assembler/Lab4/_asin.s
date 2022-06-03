        .arch   armv8-a
        .data
mes1:
        .string "Input x: "
sformat:
        .string "%s"
fformat:
        .string "%lf"
mes2:
        .string "Input accuracy: "
mes3:
        .string "My arcsin: "
resformat:
        .string "%lf\n"
mes4:
        .string "Arcsin: "
mode:
        .string "w"
filename:
        .string "_asin_logfile.txt"
outformat1:
        .string "Series: %.0lf"
outformat2:
        .string "       --->    %.17f\n"
error1:
	.string "The argument must not exceed the value of 1 modulo\n"
error2:
	.string "The accuracy should be in the range from 0 to 1\n"
        .text
        .align 2
        .global main
        .type   main, %function
        .equ    x, 32
        .equ    acc, 24
        .equ    result, 40
main:
        stp     x29, x30, [sp, #-48]!
        mov     x29, sp
        str     xzr, [x29, x]
        str     xzr, [x29, acc]
        str     xzr, [x29, acc]
        adr     x0, mes1
        bl      printf
        add     x1, x29, x
        adr     x0, fformat
        bl      scanf
        adr     x0, mes2
        bl      printf
        add     x1, x29, acc
        adr     x0, fformat
        bl      scanf
        ldr     d1, [x29, x]
        fmov    d0, #1.0
        fcmpe   d1, d0
        bgt     L15
        ldr     d1, [x29, x]
        fmov    d0, #-1.0
        fcmpe   d1, d0
        bpl     L23
L15:	
	adr	x0, error1
	bl	printf
        mov     w0, #-1
        b       L22
L23:
        ldr     d0, [x29, acc]
        fcmpe   d0, #0.0
        bls     L19
        ldr     d1, [x29, acc]
        fmov    d0, #1.0
        fcmpe   d1, d0
        blt     L24
L19:
	adr	x0, error2
	bl	printf
        mov     w0, #-1
        b       L22
L24:
        ldr     d0, [x29, x]
        ldr     d1, [x29, acc]
        bl      my_asin
        str     d0, [x29, acc]
        adr     x0, mes3
        bl      printf
        adr     x0, resformat
        ldr     d0, [x29, acc]
        bl      printf
        ldr     d0, [x29, x]
        bl      asin
        str     d0, [x29, acc]
        adr     x0, mes4
        bl      printf
        adr     x0, resformat
        ldr     d0, [x29, acc]
        bl      printf
        mov     w0, 0
L22:
        ldp     x29, x30, [sp], 48
        ret
        .size   main, .-main
        .global foo
        .type foo, %function
        .equ    n, 0
        .equ    x, 8
        .equ    result, 24
        //********************//
        // x*x(n+0.5)^2/((n+1)(n+1.5))
        // next series
        //********************//
foo:
        sub     sp, sp, #32
        str     d0, [sp, x]
        str     d1, [sp, n]
        ldr     d1, [sp, x]
        ldr     d0, [sp, x]
        fmul    d1, d1, d0
        ldr     d2, [sp, n]
        fmov    d0, #0.5
        fadd    d0, d2, d0
        fmul    d1, d1, d0
        ldr     d2, [sp, n]
        fmov    d0, #0.5
        fadd    d0, d2, d0
        fmul    d1, d1, d0
        ldr     d2, [sp, n]
        fmov    d0, #1.0
        fadd    d2, d2, d0
        ldr     d3, [sp, n]
        fmov    d0, #1.5
        fadd    d0, d3, d0
        fmul    d0, d2, d0
        fdiv    d0, d1, d0
        str     d0, [sp, result]
        ldr     d0, [sp, result]
        add     sp, sp, 32
        ret
        .global my_asin
        .type my_asin, %function
        .equ    x, 24
        .equ    acc, 16
        .equ    is_neg, 76
        .equ    n, 64
        .equ    prev, 56
        .equ    now, 48
        .equ    sum, 40
        .equ    file_pointer, 32
my_asin:
        stp     x29, x30, [sp, -80]!
        mov     x29, sp
        str     d0, [x29, x]
        str     d1, [x29, acc]
        str     wzr, [x29, is_neg]
        ldr     d0, [x29, x]
        fcmpe   d0, #0.0
        bpl     L4
        ldr     d0, [x29, x]
        fneg    d0, d0
        str     d0, [x29, x]
        mov     w0, #1
        str     w0, [x29, is_neg]
L4:
        str     xzr, [x29, n]
        str     xzr, [x29, prev]
        ldr     d0, [x29, x]
        str     d0, [x29, now]
        ldr     d0, [x29, x]
        str     d0, [x29, sum]
        ldr     d0, [x29, x]
        str     d0, [x29, prev]
        adr     x1, mode
        adr     x0, filename
        bl      fopen
        str     x0, [x29, file_pointer]
        ldr     d1, [x29, n]
        ldr     d0, [x29, x]
        bl      foo
        fmov    d1, d0
        ldr     d0, [x29, prev]
        fmul    d0, d1, d0
        str     d0, [x29, now]
        ldr     x0, [x29, file_pointer]
        ldr     d0, [x29, n]
        adr     x1, outformat1
        bl      fprintf
        ldr     x0, [x29, file_pointer]
        ldr     d0, [x29, now]
        adr     x1, outformat2
        bl      fprintf
        ldr     d1, [x29, n]
        fmov    d0, #1.0
        fadd    d0, d1, d0
        str     d0, [x29, n]
        ldr     d1, [x29, sum]
        ldr     d0, [x29, now]
        fadd    d0, d1, d0
        str     d0, [x29, sum]
L8:
        ldr     d1, [x29, prev]
        ldr     d0, [x29, now]
        fsub    d1, d1, d0
        ldr     d0, [x29, acc]
        fcmpe   d1, d0
        blt     L13
        ldr     d0, [x29, now]
        str     d0, [x29, prev]
        ldr     d1, [x29, n]
        ldr     d0, [x29, x]
        bl      foo
        fmov    d1, d0
        ldr     d0, [x29, prev]
        fmul    d0, d1, d0
        str     d0, [x29, now]
        ldr     x0, [x29, file_pointer]
        adr     x1, outformat1
        ldr     d0, [x29, n]
        bl      fprintf
        ldr     x0, [x29, file_pointer]
        adr     x1, outformat2
        ldr     d0, [x29, now]
        bl      fprintf
        ldr     d1, [x29, n]
        fmov    d0, #1.0
        fadd    d0, d1, d0
        str     d0, [x29, n]
        ldr     d1, [x29, sum]
        ldr     d0, [x29, now]
        fadd    d0, d1, d0
        str     d0, [x29, sum]
        b       L8
L13:
        ldr     w0, [x29, is_neg]
        cmp     w0, 1
        bne     L9
        ldr     d0, [x29, sum]
        fneg    d0, d0
        b       L10
L9:
        ldr     x0, [x29, file_pointer]
        bl      fclose
        ldr     d0, [x29, sum]
L10:
        ldp     x29, x30, [sp], 80
        ret
