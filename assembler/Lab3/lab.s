// работает вывод нет смещения
        .arch   armv8-a
        .data
mes2:
        .string "Enter string (Use Ctrl+D to exit) : "
        .equ    len2, .-mes2
errmes1:
        .string "Usage: "
        .equ    errlen1, .-errmes1
errmes2:
        .string " filename\n"
        .equ    errlen2, .-errmes2
newline:
        .string "\n"
        .equ    len_nl, .-newline
        .text
        .align 2
        .global _start
        .type   _start, %function
_start:
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
        b       _exit
2:
        ldr     x0, [sp, #16] // load filename
        bl work
_exit:
        mov     x0, #1
        adr     x1, newline
        mov     x2, len_nl
        mov     x8, #64
        svc     #0
        mov     x8, #93
        svc     #0

        .size   _start, .-_start


        .type   work, %function
        .equ    filename, 16
        .equ    fd, 24
        .equ    correct_result, 32
        .equ    buf, 40
work:
        mov     x16, #56 // buf_size = 16
        sub     sp, sp, x16
        stp     x29, x30, [sp]
        mov     x29, sp

        str     x0, [x29, filename]
// open file
        mov     x1, x0
        mov     x0, #-100
        mov     x2, #0x201
        mov     x8, #56
        svc     #0

        cmp     x0, #0
        bge     0f
        bl      writerr
        b       4f
0:
        str     x0, [x29, fd]
1:
        mov     x0, #1
        adr     x1, mes2
        mov     x2, len2
        mov     x8, #64
        svc     #0
// read data
        mov     x0, #0
        add     x1, x29, buf
        mov     x2, #16 // buffer
        mov     x8, #63
        svc     #0

        cmp     x0, #0
        beq     4f // EOF
        bgt     2f // OK

// error
        ldr     x0, [sp], #16
        bl      writerr
        b       3f

2:
// correct the line
        add     x0, x29, buf // buffer as an argument
        ldr     x1, [x29, fd] // and fd
        bl      string_processing

// write data to a file
// здесь лежит строка с некоторым кол-вом слов для обработки (buf)
        mov     x2, x0
        ldr     x0, [x29, fd]
        add     x1, x29, buf
        mov     x8, #64
        svc     #0

        b       1b

3:
// close file, got error
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #1
        b       5f
4:
// close file, all ok
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #0
5:
        ldp     x29, x30, [sp]
        mov     x16, #56
        add     sp, sp, x16
        ret

        .size   work, .-work


        .type   string_processing, %function
        .data
        .equ    buf_addr, 16
        .equ    fd_out, 24
        .text
        .align      2
string_processing:
        sub     sp, sp, #64
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, buf_addr]
        str     x1, [x29, fd]

        mov     x1, x0 // uncorrected string
        mov     x2, x0 // corrected string
        mov     x10, #-1 // counter 2
        mov     x19, #0 // counter 1
        b       0f

// skip spaces before the word

skip_space:
        mov     x11, #0
0:
        ldrb    w3, [x1], #1
        add     x10, x10, #1
        add     x19, x19, #1
        cmp     x10, #16
        bge     string_more_than_buffer

        cmp     w3, ' '
        beq     0b
        cmp     w3, '\t'
        beq     0b
        cmp     w3, '\n'
        beq     end_of_line

        sub     x1, x1, #1
        sub     x10, x10, #1
        sub     x19, x19, #1

        mov     x6, x1
        mov     x5, #0
4:

        ldrb    w3, [x1], #1

        mov     w0, w3 // load symbol for check func
        bl      check
        cmp     w0, #-1
        bne     no_mark
        mov     w5, w0 // (-1 - no del, 0 - del word)
no_mark:
        add     x10, x10, #1
        add     x11, x11, #1

        mov     x12, #16
        cmp     w3, '\n'
        beq     5f
        cmp     x10, x12
        beq     string_more_than_buffer

        cmp     w3, ' '
        beq     5f
        cmp     w3, '\t'
        beq     5f

        b       4b

/*
        ldrb    w3, [x1], #1
        add     x10, x10, #1
        add     x11, x11, #1

        mov     x12, #16
        cmp     w3, '\n'
        beq     5f
        cmp     x10, x12
        beq     string_more_than_buffer

        cmp     w3, ' '
        beq     5f
        cmp     w3, '\t'
        beq     5f

        b       4b
*/
// write this word to the buffer
5:
/*
        mov     x1, x6
*/
        cmp     w5, #-1
        beq     save_word // no number in word
        cmp     w3, ' '
        beq     skip_space
        cmp     w3, '\t'
        beq     skip_space
        cmp     w3, '\n'
        beq     end_of_line

save_word:
        mov     x1, x6
6:
        ldrb    w3, [x1], #1
        cmp     w3, ' '
        beq     7f
        cmp     w3, '\t'
        beq     7f
        cmp     w3, '\n'
        beq     end_of_line

        strb    w3, [x2], #1
        b       6b

// and go to the next
7:
        mov     w3, ' '
        strb    w3, [x2], #1

        b       skip_space

string_more_than_buffer:
        sub     x10, x1, x11
// write data to a file
        ldr     x0, [x29, fd_out]
        ldr     x1, [x29, buf_addr]
        sub     x2, x2, x1
        mov     x8, #64
        svc     #0
// copy part of not whole data to the beginning
        mov     x12, #0
0:
        cmp     x11, x12
        beq     1f
        ldrb    w3, [x10], #1
        cmp     w3, #2
        beq     skip_stx
        add     x12, x12, #1
        strb    w3, [x1], #1
        b       0b
skip_stx:
        sub     x11, x11, #1
        b       0b
1:
// read new part of data
        mov     x0, #0
        mov     x2, #16
        sub     x2, x2, x11 // 16 - len
        mov     x8, #63
        svc     #0

        ldr     x1, [x29, buf_addr]
        ldr     x2, [x29, buf_addr]
        mov     x10, #-1 // hz

        b       skip_space


end_of_line:
        ldr     w3, [x2, #-1]!
        cmp     w3, ' '
        bne     all_ok
        sub     x2, x2, #1

all_ok:
        add     x2, x2, #1
        mov     w3, '\n'
        strb    w3, [x2], #1

        ldr     x0, [x29, buf_addr]
        sub     x0, x2, x0 // return size of buffer

        mov     sp, x29
        ldp     x29, x30, [sp]
        add     sp, sp, #64

        ret

        .size   string_processing, .-string_processing


        .type   check, %function
        .data
        .equ    result, 16
        .equ    index, 24
        .equ    symbol, 32
        .equ    cmp_symbol, 40
        .equ    save_x1, 48
numbers:
        .asciz "0123456789"
        .text
        .align  2
check:
        sub     sp, sp, #64
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x1, [x29, save_x1]
        strb    w0, [sp, symbol]
        mov     w0, #-1
        str     w0, [sp, result]
        str     wzr, [sp, index]
        ldrb    w0, [sp, symbol]
        cmp     w0, #32
        beq     L2
        ldrb    w0, [sp, symbol]
        cmp     w0, #10 // '\n'
        beq     L2
        ldrb    w0, [sp, symbol]
        cmp     w0, #0 // '\0'
        beq     L2
        ldrb    w0, [sp, symbol]
        cmp     w0, #9 // '\t'
        bne     L3
L2:
        mov     w0, #2
        str     w0, [sp, result]
        ldr     w0, [sp, result]
        b       L4
L3:
        adr     x1, numbers
        ldrb    w0, [x1], #1
        strb    w0, [sp, cmp_symbol]
        mov     x0, #0
        str     x0, [sp, index]
L7:
        ldrb    w0, [sp, cmp_symbol]
        cmp     w0, #0
        beq     L5
        adr     x0, numbers
        ldr     x1, [sp, index]
        ldrb    w0, [x0, x1]
        strb    w0, [sp, cmp_symbol]
        add     x1, x1, #1
        str     x1, [sp, index]
        ldrb    w1, [sp, cmp_symbol]
        ldrb    w0, [sp, symbol]
        cmp     w1, w0
        bne     L7
        str     wzr, [sp, result]
        b       L5
L5:
        ldr     w0, [sp, result]
L4:
        ldr     x1, [x29, save_x1]
        mov     sp, x29
        ldp     x29, x30, [sp]
        add     sp, sp, #64
        ret
        .size   check, .-check


        .type   writerr, %function
        .data
    nofile:
        .string "No such file or directory"
        .equ    nofilelen, .-nofile
    permission:
        .string "Permission denied"
        .equ    permissionlen, .-permission
    wrong_value:
        .string "Offset value must be from 1 to 9"
        .equ    wlen, .-wrong_value
    unknown:
        .string "Unknown error"
        .equ    unknownlen, .-unknown
        .text
        .align 2
writerr:
        cmp     x0, #-2
        bne     0f
        adr     x1, nofile
        mov     x2, nofilelen
        b       3f
0:
        cmp     x0, #-13
        bne     1f
        adr     x1, permission
        mov     x2, permissionlen
        b       3f
1:
        cmp     x0, #-3
        bne     2f
        adr     x1, wrong_value
        mov     x2, wlen
        b       3f
2:
        adr     x1, unknown
        mov     x2, unknownlen
3:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret

        .size   writerr, .-writerr
