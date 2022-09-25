        .arch   armv8-a 
        .data
a:
        .word   1050253722 // 0.3
b:
        .word   1058474557 // 0.59
c:
        .word   1038174126 // 0.11
        .text
        .align   2
        .global grey_filter_asm
        .type   grey_filter_asm, %function
        .equ    img,     40 // исходное изображение 
        .equ    p,       56 // указатель по img
        .equ    res_img, 32 // выходное изображение
        .equ    pg,      72 // указатель по res_img
        .equ    t,       55 // значение пикселя после фильтра
        .equ    w,       64 // указатель на первый левый пиксель в строке прямоугольника
        .equ    pixel_pointer1, 20 // указатель на правый верхний угол
        .equ    pixel_pointer2, 16 // указатель на левый нижний угол
        .equ    width,   24 // ширина изображения
        .equ    r_width, 12 // ширина прямоугольника
        .equ    size,    28 // кол-во пикселей в изображени

grey_filter_asm:
        sub     sp, sp, #80
        str     x0, [sp, img]
        str     x1, [sp, res_img]
        str     w2, [sp, size]
        str     w3, [sp, width]
        str     w4, [sp, pixel_pointer1]
        str     w5, [sp, pixel_pointer2]
        str     w6, [sp, r_width]
        ldr     x0, [sp, img]
        str     x0, [sp, p]
        ldr     x0, [sp, res_img]
        str     x0, [sp, pg]
        strb    wzr, [sp, t]
        ldr     x0, [sp, img]
        str     x0, [sp, p]
        ldr     x0, [sp, res_img]
        str     x0, [sp, pg]
L3:
        ldrsw   x0, [sp, pixel_pointer1]
        ldr     x1, [sp, img]
        add     x1, x1, x0
        ldr     x0, [sp, p]
        cmp     x1, x0
        beq     L2
        ldr     x0, [sp, pg]
        add     x0, x0, 3
        str     x0, [sp, pg]
        ldr     x0, [sp, p]
        add     x0, x0, 3
        str     x0, [sp, p]
        b       L3
L2:
        ldrsw   x0, [sp, pixel_pointer2]
        ldr     x1, [sp, img]
        add     x1, x1, x0
        ldr     x0, [sp, p]
        cmp     x1, x0
        bls     L7
        ldrsw   x0, [sp, size]
        ldr     x1, [sp, img]
        add     x1, x1, x0
        ldr     x0, [sp, p]
        cmp     x1, x0
        bls     L7
        ldr     x0, [sp, p]
        str     x0, [sp, w]
L6:
        ldr     w1, [sp, width]
        mov     w0, w1
        lsl     w0, w0, 1
        add     w0, w0, w1
        sxtw    x0, w0
        ldr     x1, [sp, w]
        add     x1, x1, x0
        ldr     x0, [sp, p]
        cmp     x1, x0
        bls     L5
        ldr     x0, [sp, p]
        ldrb    w0, [x0]
        scvtf   s1, w0
        adr     x0, a
        ldr     s0, [x0]
        fmul    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, t]
        ldrb    w0, [sp, t]
        scvtf   s1, w0
        ldr     x0, [sp, p]
        add     x0, x0, 1
        ldrb    w0, [x0]
        scvtf   s2, w0
        adr     x0, b
        ldr     s0, [x0]
        fmul    s0, s2, s0
        fadd    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, t]
        ldrb    w0, [sp, t]
        scvtf   s1, w0
        ldr     x0, [sp, p]
        add     x0, x0, 2
        ldrb    w0, [x0]
        scvtf   s2, w0
        adr     x0, c
        ldr     s0, [x0]
        fmul    s0, s2, s0
        fadd    s0, s1, s0
        fcvtzu  w0, s0
        and     w0, w0, 255
        strb    w0, [sp, t]
        ldrb    w1, [sp, t]
        ldr     x0, [sp, pg]
        strb    w1, [x0]
        ldr     x0, [sp, pg]
        add     x0, x0, 1
        ldr     x1, [sp, pg]
        ldrb    w1, [x1]
        strb    w1, [x0]
        ldr     x0, [sp, pg]
        add     x0, x0, 2
        ldr     x1, [sp, pg]
        ldrb    w1, [x1]
        strb    w1, [x0]
        ldr     x0, [sp, p]
        add     x0, x0, 3
        str     x0, [sp, p]
        ldr     x0, [sp, pg]
        add     x0, x0, 3
        str     x0, [sp, pg]
        b       L6
L5:
        ldr     x2, [sp, p]
        ldr     w1, [sp, r_width]
        mov     w0, w1
        lsl     w0, w0, 1
        add     w0, w0, w1
        sxtw    x3, w0
        ldr     w1, [sp, width]
        mov     w0, w1
        lsl     w0, w0, 1
        add     w0, w0, w1
        sxtw    x0, w0
        sub     x0, x3, x0
        add     x0, x2, x0
        str     x0, [sp, p]
        ldr     w1, [sp, r_width]
        mov     w0, w1
        lsl     w0, w0, 1
        add     w0, w0, w1
        sxtw    x2, w0
        ldr     w1, [sp, width]
        mov     w0, w1
        lsl     w0, w0, 1
        add     w0, w0, w1
        sxtw    x0, w0
        sub     x0, x2, x0
        ldr     x1, [sp, pg]
        add     x0, x1, x0
        str     x0, [sp, pg]
        b       L2
L7:
        nop
        add     sp, sp, 80
        ret
