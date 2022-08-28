	    .arch   armv8-a
	    .data
a:
        .word   1050253722 // 0.3
b:
        .word   1058474557 // 0.59
c:
        .word   1038174126 // 0.11
	    .text
	    .align  2
	    .global grey_filter_asm
	    .type   grey_filter_asm, %function
	    .equ	res_pointer, 56
	    .equ	pixel_pointer, 48
	    .equ	filter_value, 47
	    .equ 	img, 24
	    .equ	res_img, 16
	    .equ 	size, 12
grey_filter_asm:
        sub     sp, sp, #64
        str     x0, [sp, img] // img
        str     x1, [sp, res_img] // res_img
        str     w2, [sp, size] // size
        ldr     x0, [sp, res_img]
        str     x0, [sp, res_pointer]
        ldr     x0, [sp, img]
        str     x0, [sp, pixel_pointer]
L3:
        ldrsw   x0, [sp, size]
        ldr     x1, [sp, img]
        add     x0, x1, x0
        ldr     x1, [sp, pixel_pointer]
        cmp     x1, x0
        bcs     L2
        ldr     x0, [sp, pixel_pointer]
        ldrb    w0, [x0]
        strb    w0, [sp, filter_value]
        ldr     x0, [sp, pixel_pointer]
        add     x0, x0, 1
        ldrb    w0, [x0]
        scvtf   s1, w0
        adr     x0, a
        ldr     s0, [x0]
        fmul    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, filter_value]
        ldrb    w0, [sp, filter_value]
        scvtf   s1, w0
        ldr     x0, [sp, pixel_pointer]
        add     x0, x0, 2
        ldrb    w0, [x0]
        scvtf   s2, w0
        adr     x0, b
        ldr     s0, [x0]
        fmul    s0, s2, s0
        fadd    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, filter_value]
        ldrb    w0, [sp, filter_value]
        scvtf   s1, w0
        ldr     x0, [sp, pixel_pointer]
        add     x0, x0, 3
        ldrb    w0, [x0]
        scvtf   s2, w0
        adr     x0, c
        ldr     s0, [x0]
        fmul    s0, s2, s0
        fadd    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, filter_value]
        ldrb    w1, [sp, filter_value]
        ldr     x0, [sp, res_pointer]
        strb    w1, [x0]
        ldr     x0, [sp, res_pointer]
        add     x0, x0, 1
        str     x0, [sp, res_pointer]
        ldr     x0, [sp, pixel_pointer]
        add     x0, x0, 3
        str     x0, [sp, pixel_pointer]
        b       L3
L2:
        mov     w0, 0
        add     sp, sp, 64
        ret