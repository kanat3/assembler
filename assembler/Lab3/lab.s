	.arch armv8-a
	.data
filename:
    .skip   1024
    .align  3
file_descriptor:
    .skip 8
errmes1:
	.string	"Usage: "
	.equ	errlen1, .-errmes1
errmes2:
	.string	" filename\n"
	.equ	errlen2, .-errmes2
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	ldr	x0, [sp]
	cmp	x0, #2
	beq	2f
	mov	x0, #2
	adr	x1, errmes1
	mov	x2, errlen1
	mov	x8, #64
	svc	#0
	mov	x0, #2
	ldr	x1, [sp, #8]
	mov	x2, #0
0:
	ldrb	w3, [x1, x2]
	cbz	w3, 1f
	add	x2, x2, #1
	b	0b
1:
	mov	x8, #64
	svc	#0
	mov	x0, #2
	adr	x1, errmes2
	mov	x2, errlen2
	mov	x8, #64
	svc	#0
	mov	x0, #1
	b	3f
2:
	//ldr	x0, [sp, #16]
    adr x1, filename
    ldr x2, [sp, #16]
    str x2, [x1] // save filename
    mov x0, #-100
    //strb    wzr, [x1, x2]
    ldr x1, filename
    mov x2, #0
    mov x8, #56
    svc #0
    cmp x0, #0
    blt 3f
    adr x1, file_descriptor
    str x0, [x1]
    bl	work
    cbnz x0, 3f
    adr x0, file_descriptor
    ldr x0,[x0]
    mov x8, #57
    svc #0
    mov x0, #0
    b 4f
3:
    bl writeerr
    adr x0, file_descriptor
    ldr x0, [x0]
    mov x8, #57
    svc #0
    mov x0, #1
4:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
	.type	work, %function
    .data
vowels:
    .asciz  "0123456789"
	.equ	fd, 16
	.equ	tmp, 24
    .equ    counter, 32
    .equ    letter, 40
    .equ    word, 44
    .equ    input, 48
    .equ    buffer_size, 5
    .text
    .align 2
work:
    mov x16, buffer_size
    lsl x16, x16, #1
    add x16, x16, input
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, fd]
    str xzr, [x29, counter]
    str xzr, [x29, letter]
0:
    ldr x0, [x29, fd]
    add x1, x29, input
    mov x2, buffer_size
    mov x8, #63
    svc #0
    cmp x0, #0
    ble 10f
    add x0, x0, x29
    add x0, x0, input
    ldr w1, [x29, word]
    add x3, x29, input
    mov x16, buffer_size
    add x16, x16, input
    add x4, x29, x16
    ldr x5, [x29, counter]
    ldr w6, [x29, letter]
    mov w7, ' '
1:
    cmp x3,x0
    bge 8f
    ldrb w2, [x3], #1
    cbz w2,2f
    cmp w2, '\n'
    beq 2f
    cmp w2, ' '
    beq 3f
    cmp w2, '\t'
    beq 3f
    cbz w1, 4f
    cmp w6, #1
    beq 1b
    b 7f
2:
    mov w1, #0
    mov x5, #0
    b 7f
3:
    mov w1, #0
    b 1b
4:
    mov w6, #0
    adr x9, vowels
loop:
    ldrb w10,[x9], #1
    cbz w10, 6f
    cmp w2, w10
    beq 5f
    b loop
5:
    mov w6, #1
6:
    cmp w6, #1
    mov w1, #1
    beq 1b
    add x5, x5, #1
    cmp x5, #1
    beq 7f
    strb w7, [x4], #1
7:
    strb w2, [x4], #1
    b 1b
8:
    str w1, [x29,word]
    str x5, [x29,counter]
    str w6, [x29, letter]
    mov x16, buffer_size
    add x16, x16, input
    add x1, x29, x16
    sub x2, x4, x1
    cbz x2, 0b
    str x2, [x29, tmp]
9:
    mov x0, #1
    mov x8, #64
    svc #0
    cmp x0, #0
    blt 10f
    ldr x2,[x29, tmp]
    cmp x0, x2
    beq 0b
    mov x16, buffer_size
    add x16, x16, input
    add x1, x29, x16
    add x1, x1, x0
    sub x2, x2, x0
    str x2, [x29, tmp]
    b 9b
10:
    ldp x29, x30, [sp]
    mov x16, buffer_size
    lsl x16,x16, #1
    add x16, x16, input
    add sp, sp, x16
    ret
	.size	work, .-work
	.type	writeerr, %function
	.data
nofile:
	.string	"No such file or directory\n"
	.equ	nofilelen, .-nofile
permission:
	.string	"Permission denied\n"
	.equ	permissionlen, .-permission
unknown:
	.string	"Unknown error\n"
	.equ	unknownlen, .-unknown
	.text
	.align	2
writeerr:
	cmp	x0, #-2
	bne	0f
	adr	x1, nofile
	mov	x2, nofilelen
	b	2f
0:
	cmp	x0, #-13
	bne	1f
	adr	x1, permission
	mov	x2, permissionlen
	b	2f
1:
	adr	x1, unknown
	mov	x2, unknownlen
2:
	mov	x0, #2
	mov	x8, #64
	svc	#0
	ret
	.size	writeerr, .-writeerr
