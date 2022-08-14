// правим беск ввод
        .arch   armv8-a
        .data
mes_N:
        .string "Enter N: "
        .equ    len_N, .-mes_N
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
N:
        .skip   3
str:
        .skip   1024
        .align  3
mes_res:
        .ascii  "'"
newstr:
        .skip   1024
        .align  3
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
// read N
2:
        mov     x0, #1
        adr     x1, mes_N
        mov     x2, len_N
        mov     x8, #64
        svc     #0

        mov     x0, #0
        adr     x1, N
        mov     x2, #1023
        mov     x8, #63
        svc     #0
        cmp     x0, #1
        ble     E1
        b       E2
E1:
        bl      writerr
        b       _exit
E2:
        adr     x1, N
        sub     x0, x0, #1
        strb    wzr, [x1, x0]
        ldrb    w20, [x1]
        mov     w10, '0'
        sub     w20, w20, w10
        cmp     w20, #0 // N < 0 ->in err
        ble     _exit
        ldr     x0, [sp, #16] // load filename
        bl work
_exit:
            mov     x8, #93
            svc     #0

        .size   _start, .-_start

        //!!!!!!!!!


////

    .type   work, %function
// reserve first 16 bytes for x29 and x30
// then address of filename, file descriptor and buffer address
    .equ    filename, 16
    .equ    fd, 24
    .equ    buf, 32
work:
    mov     x16, #48 // buf_size = 16 // buffer
    sub     sp, sp, x16
    stp     x29, x30, [sp]
    mov     x29, sp

    str     x0, [x29, filename] // store filename on stack
    str     x1, [x29, N] // store N on stack
// open file
    mov     x1, x0
    mov     x0, #-100
    mov     x2, #0x201
    mov     x8, #56
    svc     #0

    cmp     x0, #0
    bge     0f //
    bl      writerr
    b       4f //

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
    bl      correct

// write data to a file
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
    mov     x16, #48
    add     sp, sp, x16
    ret

    .size   work, .-work



// хз работает ли чекает букву если число есть то возвращет 0. иначе -1
        .type   check, %function
        .data
numbers:
        .asciz  "0123456789"
        .text
        .align      2
check:
        sub     sp, sp, #32
        strb    w0, [sp, 15] // our symbol
        cmp     w0, ' '
        beq     N4
        cmp     w0, '\t'
        beq     N4
        cmp     w0, '\n'
        beq     N4
        str     wzr, [sp, 28]
        mov     w0, -1
        str     w0, [sp, 24] // out result
N1:
        adr    x0, numbers
        add     x1, x0, #1
        ldrsw   x0, [sp, 28]
        ldrb    w0, [x1, x0]
        cmp     w0, 0
        beq     N2
        adr    x0, numbers
        add     x1, x0, #1
        ldrsw   x0, [sp, 28]
        ldrb    w0, [x1, x0]
        ldrb    w1, [sp, 15]
        cmp     w1, w0
        bne     N3
        str     wzr, [sp, 24]
N3:
        ldr     w0, [sp, 28]
        add     w0, w0, 1
        str     w0, [sp, 28]
        b       N1
N2:
        ldr     w0, [sp, 24]
        b   end
N4:
        mov     w0, #2 // значит не нужно менять значение метки
end:
        add     sp, sp, 32
        ret // change x1 and x0 !!!!!!!!!1



/////



    .type   correct, %function
    .data
vowels:
    .asciz  "0123456789"
    .equ    buf_addr, 16
    .equ    fd_out, 24
    .equ    symbol_ptr, 32
    .text
    .align      2
correct:
    sub     sp, sp, #40
    stp     x29, x30, [sp]
    mov     x29, sp
    str     x0, [x29, buf_addr]
    str     x1, [x29, fd]

    mov     x1, x0 // uncorrected string
    mov     x2, x0 // corrected string
    mov     x10, #-1 // buffer size counter
    mov     x19, #0 // another buffer size counter
    b       0f

// skip spaces before the first word

skip_space:
    mov     x11, #0 // **
    mov     w5, #0 // сброс метки
0:
    ldrb    w3, [x1], #1
    add     x10, x10, #1 //сместились на 1 букву +1
    add     x19, x19, #1
    cmp     x10, #16
    bge     string_more_than_buffer

    cmp     w3, ' '
    beq     0b
    cmp     w3, '\t'
    beq     0b
    cmp     w3, '\n'
    beq     end_of_line

    sub     x1, x1, #1 //пробелов нет поэтому смещаемся на 1 назад к адресу начала слова
    sub     x10, x10, #1
    sub     x19, x19, #1

// go to the end of another word and compare last symbol
// and save the beginning of the word
    mov     x6, x1 //вх6 начало слова
    mov     w5, #0 // пусть у нас сначала 0. перезапишем ее если наткнемся на НЕ цифру
4:
    ldrb    w3, [x1], #1 // no first symbol ERR аздесь одну букву пропустили
    str     x1, [x29, symbol_ptr]
    mov     w0, w3
    bl      check // func возникнет проблема если наткнулись на пробел и тд тк он не равен цифре и все перезапишется (можно сделать проверку на это в функцци чек)
    cmp     w0, #-1
    beq     save_mark
    b       no_mark
save_mark:
    mov     w5, w0 // save result in w5 (-1 - no delete, 0 - yes delete word) // будут ошибка т.к перезапись идет. нужно записывать только 0
no_mark:
    ldr     x1, [x29, symbol_ptr]
    add     x10, x10, #1
    add     x11, x11, #1

    mov     x12, #16
    cmp     w3, '\n'
    beq     5f
    cmp     x10, x12
    beq     string_more_than_buffer // если данные = 15 то 16-м будет \n и прыгнем сюда и получим беск цикл

    cmp     w3, ' '
    beq     5f
    cmp     w3, '\t'
    beq     5f

    //mov     w5, w3 не нужно
    b       4b
// now the last word's symbol is in the w5
// compare w4 and w5, if they're equal, write this word to the buffer, else go to the next word
5:
    //cmp     w4, w5
    cmp     w5, #-1
    beq     have_same_symbol // no all number in word
    cmp     w3, ' '
    beq     skip_space
    cmp     w3, '\t'
    beq     skip_space
    cmp     w3, '\n'
    beq     end_of_line

have_same_symbol:
    mov     x1, x6

// write word
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
// add space to the end
// and go to the next
7:
    mov     w3, ' '
    strb    w3, [x2], #1

    b       skip_space

string_more_than_buffer:
// save address of the beggining of the last word
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
    strb    w3, [x1], #1
    add     x12, x12, #1
    b       0b
1:
// read new part of data
    mov     x0, #0
    // buf addr already in the x1
    mov     x2, #16
    sub     x2, x2, x11 // 16 - len
    mov     x8, #63
    svc     #0
// init pointers and read data size
    ldr     x1, [x29, buf_addr]
    ldr     x2, [x29, buf_addr]
    mov     x10, #0

// and go ahead
    b       skip_space


// if end of line was reached
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
    add     sp, sp, #40

    ret


    .size   correct, .-correct

        .type   writerr, %function

        .data
    nofile:
        .string "No such file or directory\n"
        .equ    nofilelen, .-nofile
    permission:
        .string "Permission denied\n"
        .equ    permissionlen, .-permission
    unknown:
        .string "Unknown error\n"
        .equ    unknownlen, .-unknown

        .text
        .align 2

writerr:
        cmp     x0, #-2
        bne     0f
        adr     x1, nofile
        mov     x2, nofilelen
        b       2f
0:
        cmp     x0, #-13
        bne     1f
        adr     x1, permission
        mov     x2, permissionlen
        b       2f
1:
        adr     x1, unknown
        mov     x2, unknownlen
2:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret

        .size   writerr, .-writerr
