        .arch   armv8-a
        .data
mes_N:
        .string "Enter N: "
        .equ    len_N, .-mes_N
mes1:
        .string "Filename for result: "
        .equ    len1, .-mes1
mes2:
        .string "Enter string (Use Ctrl+D to exit) : "
        .equ    len2, .-mes2
mes3:
        .string "File exists. Rewrite (y/n)? "
        .equ    len3, .-mes3
mes_err:
        .string "Error............\n"
        .equ    len_err, .-mes_err
errmes1:
        .string "Usage: "
        .equ    errlen1, .-errmes1
errmes2:
        .string " filename\n"
        .equ    errlen2, .-errmes2
choice:
        .skip   3
N:
        .skip   3
str:
        .skip   1024
        .align  3
filename:
        .skip   1024
        .align  3
mes_res:
        .ascii  "'"
newstr:
        .skip   1024
        .align  3
fd:
        .skip   8
        .text
        .align 2
        .global _start
        .type   _start, %function
_start:

//************
        ldr     x0, [sp]
        cmp     x0, #2
        beq     2f
        mov     x0, #2
        adr     x1, errmes1
        mov     x2, errlen1
        mov     x8, #64
        svc     #0
        mov     x0, #2
        ldr     x1, [sp, #8]
        mov     x2, #0
0:
        ldrb    w3, [x1, x2]
        cbz     w3, 1f
        add     x2, x2, #1
        b       0b
1:
        mov     x8, #64
        svc     #0
        mov     x0, #2
        adr     x1, errmes2
        mov     x2, errlen2
        mov     x8, #64
        svc     #0
        mov     x0, #-1
        b       bad_exit
2:


        mov     x0, #1
        adr     x1, mes_N
        mov     x2, len_N
        mov     x8, #64
        svc     #0
        /* read N */
        mov     x0, #0
        adr     x1, N
        mov     x2, #1023
        mov     x8, #63
        svc     #0
        cmp     x0, #1
        ble     exit
        adr     x1, N
        /* delete \n */
        sub     x0, x0, #1
        strb    wzr, [x1, x0]
        ldrb    w20, [x1]
        mov     w10, '0'
        sub     w20, w20, w10
        cmp     w20, #0
        ble     bad_exit

        mov     x0, #-100
        ldr	x1, [sp, #16]
        strb    wzr, [x1, x2]
        mov     x2, #0xc1
        mov     x3, #0600
        mov     x8, #56
        svc     #0
        cmp     x0, #0
        bge     save_fd
        cmp     x0, #-17
        bne     bad_exit
        /* rewrite? */
        mov     x0, #1
        adr     x1, mes3
        mov     x2, len3
        mov     x8, #64
        svc     #0
        mov     x0, #0
        adr     x1, choice
        mov     x2, #3
        mov     x8, #63
        svc     #0
        cmp     x0, #2
        beq     read_answer
        b       bad_exit
read_answer:
        /* input */
        adr     x1, choice
        ldrb    w0, [x1]
        cmp     w0, 'Y'
        beq     answer_yes
        cmp     w0, 'y'
        beq     answer_yes
        mov     x0, #-17
        b       exit
answer_yes:
        /* rewrite file */
        mov     x0, #-100
        ldr	x1, [sp, #16]
        mov     x2, #0x201
        mov     x8, #56
        svc     #0
        cmp     x0, #0
        blt     bad_exit
save_fd:
        adr     x1, fd
        str     x0, [x1]
smile:
        /* ask for string */
        mov     x0, #1
        adr     x1, mes2
        mov     x2, len2
        mov     x8, #64
        svc     #0
        /* input string */
        mov     x0, #0
        adr     x1, str
        mov     x2, #1023
        mov     x8, #63
        svc     #0
        cmp     x0, #0
        ble L11
        adr     x1, str
        sub     x0, x0, #1
        strb    wzr, [x1, x0]
        adr     x3, newstr
        mov     x4, x3
L0:
        ldrb    w0, [x1], #1
        cbz     w0, L9 // end of the str
        cmp     w0, ' ' // end of the word
        beq     L0 // skip spaces
        cmp     w0, '\t'
        beq     L0
        cmp     x4, x3
        beq     L1
        // add space in new str
        mov     w0, ' '
        strb    w0, [x3], #1
        b       L1
L1:
        sub     x2, x1, #1 // x2 beggining of the word
        mov     x12, #0 // word char counter
L2:
        // read next symbol in word
        ldrb    w0, [x1], #1
        add     x12, x12, #1
        cbz     w0, L3
        cmp     w0, ' '
        beq     L3
        cmp     w0, '\t'
        bne     L2
L3:
        // x5 - next symbol after the word
        sub     x5, x1, #1
        sub     x12, x12, #1
        mov     w21, #0
L4:
        adr     x14, N
        ldrb    w20, [x14]
        mov     w15, '0'
        sub     w20, w20, w15
        sub     x20, x12, x20
        add     x20, x20, #1
        cmp     w21, w20 // compare with N
        bge     L7
        add     w21, w21, #1
        mov     x6, x5
        ldrb    w7, [x6, #-1]! // remember last char
        mov     x10, x12
L5:
        cmp     x10, #0
        ble     L6
        ldrb    w0, [x6, #-1]!
        strb    w0, [x2, x10, lsl #0]
        sub     x10, x10, #1
        cmp     x6, x2
        bgt     L5
        b       L6
L6:
        strb    w7, [x2]
        b L4
L7:
        add     x12, x12, #1
        sub     x1, x1, #1
        mov     x10, #0
L8:
        //write new word to new str
        cmp     x10, x12
        bge     L0
        ldrb    w0, [x2, x10, lsl #0]
        strb    w0, [x3], #1
        add     x10, x10, #1
        b       L8
L9:
        mov     w0, '\''
        strb    w0, [x3], #1
        mov     w0, '\n'
        strb    w0, [x3], #1
output:
        adr     x0, fd
        ldr     x0, [x0]
        adr     x1, newstr
        adr     x1, mes_res
        sub     x2, x3, x1
        mov     x8, #64
        svc     #0
        b       smile
L11:
        adr     x0, fd
        ldr     x0, [x0]
        mov     x8, #57
        svc     #0
        b       exit
bad_exit:
        /* add */
exit:
        mov     x0, #0
        mov     x8, #93
        svc     #0
        .size   _start, .-_start
