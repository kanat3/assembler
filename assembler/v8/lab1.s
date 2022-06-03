	.arch armv8-a
	.data
	.align	3
res:
	.skip	8
a:
	.4byte	4
b:
	.byte	7
c:
	.2byte	3
d:
	.4byte	11
e:
	.4byte	5
	.text
	.align	2
	.global	_start
	.type	_start, %function
_start:
	adr x0, a
	ldr w1,	[x0]
	adr x0, b
	ldrb w2, [x0]
	adr x0, c
	ldrh w3, [x0]
	adr x0, d
	ldr w4, [x0]
	adr x0, e
	ldr w5, [x0]
    	umull x6, w4, w1 // d*a
	madd x7, x2, x3, x1 // a+b*c
	cbz x7, BAD // if a+b*c == 0 exit
	udiv x6, x6, x7 // d*a/(a+b*c)
	add x3, x4, x2 // d+b
	subs w7, w5, w1 // e-a
	bmi BAD // e-a < 0 exit
	cbz w7, BAD // e-a == 0 exit
	udiv x7, x3, x7 // (d+b)/(e-a)
	adds x1, x6, x7 // result
	bcs BAD // unsigned overflow
	adr x0, res
	str x1, [x0]
	b SUCCES
CALL:
	mov x8, #93
	svc #0
SUCCES:
	mov x0, #0
	b CALL
BAD:
	mov x0, #1
	b CALL
	.size _start, .-_start
