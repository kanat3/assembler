// правим беск ввод
// во-первых данные выводятся вдвух места в зависимости от нахождения в буфере
// значит надо добавить работу смещения в функции work но она попротит все данные (значит каждый используемый регистр надо сохранить)
// функция смещения считывает всю строку до символа \0
// если слово у нас на стыке, то буфер для вывода выглядит немного странно. там на месте разрыва находится \0. а это потит работу алгоса
// надо проверить как в исходном коде выгдлядит буфер (мб я напутала с индексами). и если так и должно быть, то нужно склеить местро разрыва для
// загрузки в алгос смещения
// все хочу спать всем привет
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


    .type   left_offset, %function

left_offset:
// в х1 получаем буфер
// в х0 получаем кол-во букв!
        adr     x20, N
        ldrb    w20, [x20]
        mov     w22, '0'
        sub     w20, w20, w22
        mov     x12, #0 // кол-во букв в конкретном слове
        mov     x3, x1 // по этому указателю пишем буквы
        mov     x4, x3 // указатель на начало нашего слова в буфере
        sub     x15, x0, #1// кол-во символов в строке
        ldrb    w11, [x1, x15, lsl #0] //проверяем последний символ \n или ' '
        cmp     w11, '\n'
        mov     x11, #-3 // запомним что надо заменить конец на ' '
        bne     L0
        //mov     w22, ' '
        //strb    w22, [x1, x15, lsl #0] // конец строки имеет вид ' \n'
        //add     x15, x15, #1
        strb    wzr, [x1, x15] // обзяательно окончание строки в конце
        //sub     x15, x15, #1
        mov     x11, #3 // в конце был \n потом заменим
        mov     x10, #0

L0:
        ldrb    w0, [x1], #1 // По х1 смещаемся как по строчке. в х0 символ
        cbz     w0, L9 // строка закончилась
        cmp     w0, ' '
        beq     L0
        cmp     w0, '\t'
        beq     L0
        cmp     x4, x3 // сравнили адреса строк
        beq     L1
        mov     w0, ' '
        strb    w0, [x3], #1
        b       L1
L1:
        sub     x2, x1, #1 //запишем начало слова без пробелов в х2
        mov     x12, #0
L2:
        ldrb    w0, [x1], #1 //идем по слову до пробела
        add     x12, x12, #1
        cbz     w0, L3
        cmp     w0, ' '
        beq     L3
        cmp     w0, '\n'
        beq     L3
        cmp     w0, '\t'
        bne     L2
L3:
        sub     x12, x12, #1 // размер слова - 1 лежит
        mov     w21, #0
L4:
        cmp     w21, w20 // в w20 лежит N идем по циклу до w21 = w20 L4 -L6
        bge     L7 // смещение завершено прыгаем на л7
        add     w21, w21, #1
        mov     x6, x2 // Положили начало слова
        ldrb    w7, [x6, #0]! //-1 сохраняем первую букву слова
        mov     x10, #0 //x12
L5:
        cmp     x10, x12 // index < len
        bgt     L6
        ldrb    w0, [x6, #1]! // смещаемся на след букву
        strb    w0, [x2, x10, lsl #0] // делаем смещение в регистре х2 (это наш Out)
        add     x10, x10, #1 // счетчик
        cmp     x10, x12 // проверяем счетчик и кол-во букв - 1
        bgt     L6
        b       L5
L6:
        strb    w7, [x2, x12, lsl #0]
        b L4
L7:
        add     x12, x12, #1 // кол-во буквы в слове
        sub     x1, x1, #1 // следующий адрес после конца слова
        mov     x10, #0
L8:
        cmp     x10, x12
        bge     L0 // смещение закончено. обрабатываем след. слово
        ldrb    w0, [x2, x10, lsl #0]
        strb    w0, [x3], #1
        add     x10, x10, #1
        b       L8
L9:
        mov     x0, x4
        cmp     x11, #3
        beq     add_end
        bne     add_space
add_end:
        mov     w11, '\n'
        strb    w11, [x0, x15, lsl #0]
        b to_ret
add_space:
        mov     w11, ' '
        strb    w11, [x0, x15, lsl #0]
to_ret:
        ret

    .size   left_offset, .-left_offset


////

    .type   work, %function
// reserve first 16 bytes for x29 and x30
// then address of filename, file descriptor and buffer address
    .equ    filename, 16
    .equ    fd, 24
    .equ    correct_result, 32
    .equ    buf, 40
work:
    mov     x16, #56 // buf_size = 16 // buffer
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
// здесь лежит строка с некоторым кол-вом слов для обработки (buf)
    str     x0, [x29, correct_result]
    add     x1, x29, buf
    bl      left_offset
    mov     x1, x0
    ldr     x2, [x29, correct_result]
    ldr     x0, [x29, fd]
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


    .type   correct, %function
    .data
vowels:
    .asciz  "0123456789"
    .equ    buf_addr, 16
    .equ    fd_out, 24
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
4:
    ldrb    w3, [x1], #1 // no first symbol ERR аздесь одну букву пропустили
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

    b       4b
// write this word to the buffer, else go to the next word
5:
    b     write_word // write full word

write_word:
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
