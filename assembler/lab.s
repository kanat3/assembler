	.arch   armv8-a
 // Shell sorting
	.data
	.align  3
m:
	.quad   4
p:
	.quad   16
matrix:
	.quad   2, 2, 4, 7, -3, 1, 8, 4, 5, 9, 3, 9, 4, 6, 5, 1

//m:
//    .quad   5
//p:
//    .quad   25
//matrix:
//    .quad   46, 123, 32, 73, 82, 44, 180, 199, 118, 164, 244, 127, 90, 11, 166, 72, 70, 223, 65, 234, 217, 295, 293, 189, 59
diag:
	.skip   32
temp:
	.skip   32 // m
	.skip   40
 	.text
 	.align  2
 	.global _start
 	.type   _start, %function
_start:
	adr     x0, m
	ldr     x0, [x0]
	adr     x1, p
	ldr     x1, [x1]
	adr     x2, diag
	adr     x3, matrix
	adr     x4, temp

L0:
	 // x4 -> h = m - 1
	sub     x5, x0, #1
	mov     x6, #0 // i = 0
L1:
	add     x6, x6, #1
	cmp     x6, x0
	bge     L5
	mov     x7, #0 // j = 0
	b       L2
L2:
	cmp     x7, x6
	bgt     L3
	mul     x8, x7, x5 // j*h
	add     x9, x8, x6 // i+j*h
	ldr     x10, [x3, x9, lsl #3]
	str     x10, [x4, x7, lsl #3]
	add     x7, x7, #1
	b       L2
L3:
       // shell(b, i+1)
	add     x8, x6, #1 // i+1
	mov     x20, x8
	b       shell1
after_shell1:
	mov     x7, #0 // j = 0
L4:
	cmp     x7, x6
	bgt     L1
	mul     x8, x7, x5 // j*h
	add     x9, x8, x6 // i+j*h
	ldr     x10, [x4, x7, lsl #3]
	str     x10, [x3, x9, lsl #3]
	add     x7, x7, #1
	b       L4
L5:
	mov     x6, #0
	sub     x11, x0, #1     // x11 = m-1
L6:
	add     x6, x6, #1
	cmp     x6, x11 // i < m-1
	blt     L7
	b       exit
L7:
	mov     x7, #0
	sub     x12, x0, x6 // m-i
L8:
	cmp     x7, x12
	bge     L9
	add     x8, x6, #1 // i+1
	mul     x8, x8, x0 // m*(i+1)
	sub     x8, x8, #1
	mul     x9, x7, x5 // j*h
	add     x8, x8, x9
	ldr     x10, [x3, x8, lsl #3]
	str     x10, [x4, x7, lsl #3]
	add     x7, x7, #1
	b       L8
L9:
       // shell(b, m-i+1)
	sub     x8, x0, x6
      //  add     x8, x8, #1  // x8 = m-i+1
      //  sub     x8, x8, #1
	mov     x20, x8
	b       shell2
after_shell2:
L10:
        // x12 -> m-i
	mov     x26, x17       // add 1
	cmp     x7, x12
	bge     L6
	add     x8, x6, #1 // i+1
	mul     x8, x8, x0 // m*(i+1)
	sub     x8, x8, #1
	mul     x9, x7, x5 // j*h
	add     x8, x8, x9
	ldr     x10, [x4, x7, lsl #3]
	str     x10, [x3, x8, lsl #3]
	add     x7, x7, #1
	b       L10
	// x20 - n
shell1:
	mov     x11, x20
	mov     x25, #2
	sdiv     x11, x11, x25
	b       L11
L11:
	cmp     x11, #0
	ble     after_shell1
	mov     x16, #-1
	sub     x13, x20, x11
L12:
	add     x16, x16, #1
	cmp     x16, x13
	bge     L14
	mov     x17, x16
L13:
	cmp     x17, #0
	blt     L12
	add     x21, x17, x11
	ldr     x19, [x4, x21, lsl #3] // A[j+d]
	ldr     x18, [x4, x17, lsl #3] // A[j]
	cmp     x18, x19

 //.ifdef reverse
	bge     L12
//.else
//	ble	L12
//.endif

	str     x19, [x4, x17, lsl #3]
	str     x18, [x4, x21, lsl #3]
	sub     x17, x17, #1
	b       L13
L14:
	sdiv     x11, x11, x25
	b       L11
shell2:
	mov     x23, x20
	mov     x25, #2
	sdiv    x23, x23, x25
	b       L21
L21:
	cmp     x23, #0
	ble     after_shell2
	mov     x16, #-1
	sub     x13, x20, x23
	b       L22
L22:
	add     x16, x16, #1
	cmp     x16, x13
	bge     L24
	mov     x17, x16
L23:
	cmp     x17, #0
	blt     L22
	add     x21, x17, x23
	ldr     x19, [x4, x21, lsl #3] // A[j+d]
	ldr     x18, [x4, x17, lsl #3] // A[j]
	cmp     x18, x19

 //.ifdef reverse
	bge     L22
//.else
//    ble     L22
//.endif

	str     x19, [x4, x17, lsl #3]
	str     x18, [x4, x21, lsl #3]
	sub     x17, x17, #1
	b       L23
L24:
	mov     x25, #2
	sdiv    x23, x23, x25
	b       L21
exit:
	mov     x0, #0
	mov     x8, #93
	svc     #0
	.size   _start, .-_start

