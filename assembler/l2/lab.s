	.arch armv8-a
//	Sorting columns of matrix by min elements
//	Odd-even sort
	.data
	.align	3
n:
	.word 4
m:
	.word 6
matrix:
	.quad	4, 6, 1, 8, 2, -12
	.quad	1, 2, 3, 4, 5, 53
	.quad	0, 8, 3, -1, -1, 0
	.quad   0, 3, -33, -4, 5, 0
maxs:
	.skip 40 // m*8-bit
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr	x2, n
	ldr	w0, [x2]
	adr	x2, m
	ldr	w1, [x2]
	adr	x2, matrix
	adr	x3, maxs // array of min columns elements
	mov	x4, #0
L0:
	cmp	x4, x1
	bge	L3
	mov	x5, #0
	lsl	x6, x4, #3
	ldr	x7, [x2, x6]
	add	x6, x6, x1, lsl #3
	add	x5, x5, #1
L1:
	cmp	x5, x0
	bge	L2
	ldr	x8, [x2, x6]
	add	x6, x6, x1, lsl #3
	add	x5, x5, #1
	cmp	x7, x8
	ble	L1
	mov	x7, x8
	b	L1
L2:
	str	x7, [x3, x4, lsl #3]
	add	x4, x4, #1
	b	L0
L3:
	sub	x4, x1, #1
	mov	x5, #0 // sorted - 1, 0 - no
	mov	 x11, #1 // index
	mov	 x12, #1
L4:
	mov	x6, x11
	mov	x7, x11
	cmp	x5, #1
	beq	L9 // array is sorted
	ldr	x9, [x3, x6, lsl #3]
	b	L5
0:
	mov	x11, #1
	mov	x5, x12
	mov	x12, #1
	b	L4
check:
	tst	x11, #1
	beq	0b
	mov	x11, #0
	mov	x6, x11
	mov	x7, x11
	ldr	x9, [x3, x6, lsl #3]
L5:
	add	x6, x6, #1
	cmp	x6, x4
	bgt	check
	mov	x5, #1
	ldr	x8, [x3, x6, lsl #3]
	cmp	x8, x9
.ifdef sort
	bge	0f
.endif
.ifdef rsort
	ble 0f
.endif
	mov	x7, x6
	mov	x9, x8
	mov	x5, #0 // yes swap
	mov	x12, #0 // swap in iteration
	b	L6
0:
	add	x11, x11, #2
	mov	x6, x11
	mov	x7, x11
	mov	x5, x12
	ldr	x9, [x3, x6, lsl #3]
	b	L5
L6:
	ldr	x8, [x3, x11, lsl #3]
	str	x8, [x3, x7, lsl #3]
	str	x9, [x3, x11, lsl #3]
	mov	x10, #0
	add	x6, x2, x11, lsl #3
	add	x7, x2, x7, lsl #3
L7:
	cmp	x10, x0
	bge	L8
	ldr	x8, [x6]
	ldr	x9, [x7]
	str	x8, [x7]
	str	x9, [x6]
	add	x6, x6, x1, lsl #3
	add	x7, x7, x1, lsl #3
	add	x10, x10, #1
	b	L7
L8:
	add	x11, x11, #2
	mov	x5, x12
	b	L4
L9:
	mov	x0, #0
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
