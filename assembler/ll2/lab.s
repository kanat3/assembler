	.arch armv8-a
//	Sorting columns of matrix by min elements
//	Try Shell
//
	.data
	.align	3
n:
	.word	4
m:
	.word	6
matrix:
	.quad	4, 6, 1, 8, 2, 2
	.quad	1, 2, 3, 4, 5, 5
	.quad	0, -7, 3, -1, -1, 5
	.quad	-11, 33, -6, -7, -10, 5
maxs:
	.skip	48
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
	adr	x3, maxs
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
	// no need sub	x4, x1, #1
	mov	x5, #0
//*****************************//
// array length m
// x3 busy
	mov x6, #2
	b L4
L4:
	// x4 = gap
	udiv	x4, x4, x6
	cmp		x4, #0
	ble		end // <=
	mov		x7, x4 // i = gap
	sub		x7, x7, #1
L5:
	add		x7, x7, #1
	adr		x1, m
	ldr		w1, [x1] // load m
	cmp		x7, x1
	bge		L4 // >=
	b 		L6
L6:
	sub		x8, x7, x4 //j = i - gap
	cmp		x8, #0
	blt		L5 // <
	add		x9, x8, x4 // j + gap
	ldr		x1, [x3, x8, lsl #3] // arr[j]
	ldr		x2, [x3, x9, lsl #3] // arr[j+gap]
	cmp		x1, x2
.ifdef sort
	ble		L5
.endif
.ifdef rsort
	bge		L5
.endif
	// j+gap in x9 | j in x8
	str 	x2, [x3, x8, lsl #3] // arr[j] = arr[j + gap]
	str 	x1, [x3, x9, lsl #3]
	mov 	x13, x2
	mov 	x14, x1
	// swap is done
	mov		x10, #0 // counter for column swap
	adr		x2, matrix
	add		x11, x2, x8, lsl #3
	add		x12, x2, x9, lsl #3
swap_loop:
	adr		x1, n
	ldr		w1, [x1] // load n
	cmp		x10, x1
	bge		continue
	ldr		x13, [x11]
	ldr		x14, [x12]
	str 	x13, [x12]
	str 	x14, [x11]
	adr		x1, m
	ldr		w1, [x1] // load m
	add		x11, x11, x1, lsl #3
	add		x12, x12, x1, lsl #3
	add		x10, x10, #1
	b 		swap_loop
continue:
	sub		x8, x8, x4
	b 		L6
end:
	adr		x0, matrix
	mov		x0, #0
	mov		x8, #93
	svc		#0
	.size	_start, .-_start
