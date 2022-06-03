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
	.string "	--->	%.17f\n"
        .text
        .align 2
        .global main
        .type   main, %function
main:
        stp     x29, x30, [sp, #-48]!
        mov     x29, sp
        str     xzr, [x29, 32]
        str     xzr, [x29, 24]
        str     xzr, [x29, 40]
        adr     x0, mes1
        bl      printf
        add     x1, x29, 32
        adr     x0, fformat
        bl      scanf
        adr     x0, mes2
        bl      printf
        add     x1, x29, 24
        adr     x0, fformat
        bl      scanf
        ldr     d1, [x29, 32]
        fmov    d0, #1.0
        fcmpe   d1, d0
        bgt     L15
        ldr     d1, [x29, 32]
        fmov    d0, #-1.0
        fcmpe   d1, d0
        bpl     L23
L15:
        mov     w0, #-1
        b       L22
L23:
        ldr     d0, [x29, 24]
        fcmpe   d0, #0.0
        bls     L19
        ldr     d1, [x29, 24]
        fmov    d0, #1.0
        fcmpe   d1, d0
        blt     L24
L19:
        mov     w0, #-1
        b       L22
L24:
        ldr     d0, [x29, 32]
        ldr     d1, [x29, 24]
        bl      my_asin
        str     d0, [x29, 40]
        adr     x0, mes3
	bl 	printf
        adr     x0, resformat
        ldr     d0, [x29, 40]
        bl      printf
        ldr     d0, [x29, 32]
        bl      asin
	str	d0, [x29, 40]
        adr     x0, mes4
	bl 	printf
        adr     x0, resformat
	ldr 	d0, [x29, 40]
        bl      printf
        mov     w0, 0
L22:
        ldp     x29, x30, [sp], 48
        ret
	.size   main, .-main
        .global foo
        .type foo, %function
foo:
        sub     sp, sp, #32
        str     d0, [sp, 8]
        str     d1, [sp]
        ldr     d1, [sp, 8]
        ldr     d0, [sp, 8]
        fmul    d1, d1, d0
        ldr     d2, [sp]
        fmov    d0, #0.5
        fadd    d0, d2, d0
        fmul    d1, d1, d0
        ldr     d2, [sp]
        fmov    d0, #0.5
        fadd    d0, d2, d0
        fmul    d1, d1, d0
        ldr     d2, [sp]
        fmov    d0, #1.0
        fadd    d2, d2, d0
        ldr     d3, [sp]
        fmov    d0, #1.5
        fadd    d0, d3, d0
        fmul    d0, d2, d0
        fdiv    d0, d1, d0
        str     d0, [sp, 24]
        ldr     d0, [sp, 24]
        add     sp, sp, 32
        ret
my_asin:
        stp     x29, x30, [sp, -80]!
        mov     x29, sp
        str     d0, [x29, 24]
        str     d1, [x29, 16]
        str     wzr, [x29, 76]
        ldr     d0, [x29, 24]
        fcmpe   d0, #0.0
        bpl     L4
        ldr     d0, [x29, 24]
        fneg    d0, d0
        str     d0, [x29, 24]
        mov     w0, #1
        str     w0, [x29, 76]
L4:
        str     xzr, [x29, 64]
        str     xzr, [x29, 56]
        ldr     d0, [x29, 24]
        str     d0, [x29, 48]
        ldr     d0, [x29, 24]
        str     d0, [x29, 40]
        ldr     d0, [x29, 24]
        str     d0, [x29, 56]
        adr     x1, mode
        adr     x0, filename
        bl      fopen
        str     x0, [x29, 32]
        ldr     d1, [x29, 64]
        ldr     d0, [x29, 24]
        bl      foo 
        fmov    d1, d0
        ldr     d0, [x29, 56]
        fmul    d0, d1, d0
        str     d0, [x29, 48]
	ldr	x0, [x29, 32]
	ldr	d0, [x29, 64]
        adr     x1, outformat1
	bl	fprintf
        ldr     x0, [x29, 32]
	ldr	d0, [x29, 48]
	adr	x1, outformat2
        bl      fprintf
        ldr     d1, [x29, 64]
        fmov    d0, #1.0
        fadd    d0, d1, d0
        str     d0, [x29, 64]
        ldr     d1, [x29, 40]
        ldr     d0, [x29, 48]
        fadd    d0, d1, d0
        str     d0, [x29, 40]
L8:
        ldr     d1, [x29, 56]
        ldr     d0, [x29, 48]
        fsub    d1, d1, d0
        ldr     d0, [x29, 16]
        fcmpe   d1, d0
        blt     L13
        ldr     d0, [x29, 48]
        str     d0, [x29, 56]
        ldr     d1, [x29, 64]
        ldr     d0, [x29, 24]
        bl      foo
        fmov    d1, d0 // res foo
        ldr     d0, [x29, 56]
        fmul    d0, d1, d0
        str     d0, [x29, 48]
	ldr	x0, [x29, 32]
        adr     x1, outformat1
        ldr     d0, [x29, 64] //n
        bl      fprintf
	ldr	x0, [x29, 32]
	adr	x1, outformat2
	ldr	d0, [x29, 48]
	bl	fprintf 
        ldr     d1, [x29, 64]
        fmov    d0, #1.0
        fadd    d0, d1, d0
        str     d0, [x29, 64]
        ldr     d1, [x29, 40]
        ldr     d0, [x29, 48]
        fadd    d0, d1, d0
        str     d0, [x29, 40]
        b       L8
L13:
        ldr     w0, [x29, 76]
        cmp     w0, 1
        bne     L9
        ldr     d0, [x29, 40]
        fneg    d0, d0
        b       L10
L9:
        ldr     x0, [x29, 32]
        bl      fclose
        ldr     d0, [x29, 40]
L10:
        ldp     x29, x30, [sp], 80
        ret
