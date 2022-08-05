	.arch armv8-a
	//	Sorting columns of matrix by min elements
	//	Shell
	.data
	.align	2
n:
	.word	4
m:
	.word	7
matrix:
	.byte	4, 9, 6, 1, 8, 2, 2
	.byte	1, 11, 2, 3, 4, 5, 5
	.byte	0, 44, -7, 3, -1, -1, 5
	.byte	-11, 90, 33, -6, -7, -10, 5
maxs:
	.skip	56 // m*8 bytes (work for quad)
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
	adr		x2, n
	ldr		w0, [x2]
	adr		x2, m
	ldr		w1, [x2]
	adr		x2, matrix
	adr		x3, maxs
	mov		x4, #0
L0:
	cmp		x4, x1
	bge		L3
	mov		x5, #0
	lsl		x6, x4, #0
	ldrsb		x7, [x2, x6]
	add		x6, x6, x1, lsl #0
	add		x5, x5, #1
L1:
	cmp		x5, x0
	bge		L2
	ldrsb		x8, [x2, x6]
	add		x6, x6, x1, lsl #0
	add		x5, x5, #1
	cmp		x7, x8
	ble		L1
	mov		x7, x8
	b		L1
L2:
	str		x7, [x3, x4, lsl #0]
	add		x4, x4, #1
	b		L0
L3:
	mov		x5, #0
	mov 		x6, #2
	b 		L4
L4:
	// x4 = gap
	udiv		x4, x4, x6
	cmp		x4, #0
	ble		end
	mov		w7, w4 // i = gap
	sub		w7, w7, #1
L5:
	add		w7, w7, #1
	adr		x1, m
	ldr		w1, [x1]
	cmp		w7, w1
	bge		L4
	sub		w8, w7, w4 //j = i - gap
L6:
	cmp		w8, #0
	blt		L5
	add		w9, w8, w4 // j + gap
	ldrsb		w1, [x3, x8, lsl #0] // arr[j]
	ldrsb		w2, [x3, x9, lsl #0] // arr[j+gap]
	cmp		w1, w2
.ifdef sort
	ble		L5
.endif
.ifdef rsort
	bge		L5
.endif
	strb		w2, [x3, x8, lsl #0] // arr[j] = arr[j + gap]
	strb		w1, [x3, x9, lsl #0]
	mov		w13, w2
	mov		w14, w1
	mov		x10, #0 // counter for column swap
	adr		x2, matrix
	add		w11, w2, w8, lsl #0
	add		w12, w2, w9, lsl #0
swap_loop:
	adr		x1, n
	ldr		w1, [x1]
	cmp		w10, w1
	bge		continue
	ldrsb		w13, [x11]
	ldrsb		w14, [x12]
	strb		w13, [x12]
	strb		w14, [x11]
	adr		x1, m
	ldr		w1, [x1]
	add		w11, w11, w1, lsl #0
	add		w12, w12, w1, lsl #0
	add		x10, x10, #1
	b		swap_loop
continue:
	sub		w8, w8, w4 // j - gap
	b		L6
end:
	adr		x0, matrix
	mov		x0, #0
	mov		x8, #93
	svc		#0
	.size	_start, .-_start

