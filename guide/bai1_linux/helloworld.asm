; Compile with: nasm -f elf32 helloworld.asm
; Link with: gcc -m32 helloworld.o -o helloworld -nostartfiles
; Run with: ./helloworld
bits 32
global _start
SECTION .data
	msg:	db		"Hello world", 0xa, 0
	msgLen  equ		$-msg					; $ co nghia la vi tri hien tai

SECTION .bss

SECTION .text
_start:
	;+---------------------------+ <----+ EBP + 12
	;|      parameter 1          |
	;|                           |
	;+---------------------------+ <----+ EBP + 8
	;|      parameter 2          |
	;|                           |
	;+---------------------------+ <----+ EBP + 4
	;|      return address       |
	;|                           |
	;+---------------------------+ <----+ EBP
	;|      function print       |
	;|                           |
	;+---------------------------+ 

	push	msg				; dua msg vao stack (para1)
	push	msgLen			; dua msgLen vao stack (para2)
	call	print			; goi ham print
	add		esp, 8			; dua esp ve vi tri cu

	; ket thuc chuong trinh
	mov		eax, 0x1		; Su dung ham sys_exit
	mov		ebx, 0			; Tra ve khong co loi
	push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi system goi sys_exit

print:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi
	push	edi				; luu lai edi va esi
	push	esi

	mov		edi, [ebp+12]	; Luu para1 vao edi
	mov		esi, [ebp+8]	; Luu para2 vao esi

	mov		eax, 0x4		; Su dung ham sys_write
	mov		ebx, 1			; Viet vao stdout
	mov		ecx, edi		; lay dia chi cua message
	mov		edx, esi		; lay do dai cua message

	push	system_ret_print; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham in ra
system_ret_print:
	pop		esi				; Khoi phuc lai esi va edi truoc
	pop		edi
	mov		esp, ebp		; loai bo cac bien trong pt nay
	pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
	ret		

