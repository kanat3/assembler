	.arch armv8-a
	//InsertionSort
	.data
j:
	.byte 5 // row count
n:
    .byte 6 // row lenght
array:
	.byte 55, 11, 33, -77, 79, 16
    .byte -3, 2, -9, 6, 9, 1
	.byte 28, 26, 13, 52, 42, 1
	.byte 4, -1, 0, 8, 0, 1
	.byte 9, 8, 7, 6, 5, 1
	.text
	.align 2
	.global _start
	.type	_start, %function
_start:
	adr x0, n
	ldrb w0, [x0]
	mov x7, #-1 // row index
	adr x1, array
Z:
    mov x2, #0
    add x7, x7, #1
    adr x0, j
    ldrb w0, [x0]
    cmp x7, x0
    adr x0, n
    ldrb w0, [x0]
    beq L3
    b L0
L0:
	add x2, x2, #1
	add x7, x7, #1
	umull x0, w0, w7
	cmp x2, x0
	sub x7, x7, #1
	adr x0, n
	ldrb w0, [x0]
	bge Z
	cmp x7, #0
	bne A
	ldrsb w5, [x1, x2]
	mov x3, x2
L1:
	smull x4, w0, w7
	cmp x3, x4
	mov x4, x3
	ble L2
	sub x3, x3, #1
	ldrsb w6, [x1, x3]
	cmp w5, w6
.ifdef sort
	bgt L2 //ble 9-8-5 etc
.endif
.ifdef rsort
    blt L2
.endif
	strb w6, [x1, x4, lsl #0]
	b L1
L2:
	strb w5, [x1, x4, lsl #0]
	b L0
L3:
	mov x0, #0
	mov x8, #93
	svc #0
	.size	_start, .-_start
A:
	umull x4, w0, w7
	sub x2, x2, x4
	add x2, x2, x4
	ldrsb w5, [x1, x2]
	mov x3, x2
	b L1
