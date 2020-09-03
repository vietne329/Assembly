bits 32
global _start

SECTION .data
	nl			db		0xa
	msg			db		"Nhap vao so N: ", 0
	msg_len		equ		$-msg

SECTION .bss
	n			resd	1

section .text
_start:
	; Nhap vao xau can dao nguoc
	push	msg
	push	msg_len
	call	print
	push	n
	call	get_num

	push	1
	push	0
	push	dword [n]
	call	Fibonacci

	push	eax
	call	print_num

	push	nl
	push	1
	call	print
	; ket thuc chuong trinh
	DONE_start:
		mov		eax, 0x1		; Su dung ham sys_exit
		mov		ebx, 0			; Tra ve khong co loi
		push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
		push	ecx				; Luu ecx, edx va ebp
		push	edx
		push	ebp
		mov		ebp, esp		; dat mot base pointer moi cho sysenter
		sysenter				; Dung sysenter de goi system goi sys_exit

; tuong duong voi: int fibonacci(int n, int a, int b)
Fibonacci:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	LOOP_fib:
		mov		esi, [ebp+8]	; esi = n
		mov		edi, [ebp+12]	; edi = a
		mov		ebx, [ebp+16]	; ebx = b

		cmp		esi, 0
		je		esi_equal_0
		cmp		esi, 1
		je		esi_equal_1

		mov		eax, ebx
		add		eax, edi

		; Goi lai fibonacci voi fibonacii(n-1, b, a+b)
		dec		dword [ebp+8]
		mov		dword [ebp+12], ebx
		mov		dword [ebp+16], eax
		jmp		LOOP_fib

	esi_equal_0:
		mov		eax, [ebp+12]
		jmp		DONE_fib
	esi_equal_1:
		mov		eax, [ebp+16]
		jmp		DONE_fib
	
	DONE_fib:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		12

; tuong duong voi: void get_num(int *num)
get_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 20				; aloocate 20 byte cho local1
	push	edi

	mov		edi, [ebp+8]		; edi = param1
	lea		ebx, [ebp-20]		; ebx = local1
; Luu ket qua nhap vao ban phim vao local1
	push	ebx
	push	20
	call	get

; Bien doi local1 thanh so va luu no vao eax
	lea		ebx, [ebp-20]
	push	ebx
	call	to_num

	mov		[edi], eax			; Luu gia tri cua eax vao param1

	pop		edi
	mov		esp, ebp
	pop		ebp
	ret		4

get:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi
	push	edi
	push	esi

	mov		eax, 0x3
	mov		ebx, 0
	mov		ecx, [ebp+12]
	mov		edx, [ebp+8]

	; goi sysenter
	push	system_ret_print; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham in ra

	sys_ret_get:
		pop		esi
		pop		edi
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret		8

; tuong duong voi: void print_num(int num)
; nhap vao mot so va in ra man hinh so do
print_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 32			; ebp-4 se la phan du
							; ebp-8 se la thuong so
							; ebp-12 se la local3
							; ebp-32 se la result_num
	push	esi
	push	edi
	push	ebx
	push	ecx
	push	eax

	mov		byte [ebp-32], 0
	lea		edi, [ebp-32]					; edi = result_num
	mov		esi, [ebp+8]					; esi = param1
	mov		dword [ebp-12], -1				; dat local3 = i, ta se tang i voi moi lan lap
											; Sau khi xong vong lap thi i chinh la do dai cua dau vao
	mov		ecx, 0xa						; Dat ecx = 10 de co the chia lay phan du

	LOOP:
		cmp		esi, 0						; kiem tra xem chay het tung so chua
		je		PRINT_NUMBER

		mov		edx, 0						; dat edx = 0
		mov		eax, esi					
		div		ecx							; chia eax cho ecx

		mov		[ebp-4], edx				; Dat local 1 la phan du
		mov		[ebp-8], eax				; Dat local 2 la ket qua sau khi chia
		add		dword [ebp-4], 0x30			; bien doi phan du thanh chu ascii
		mov		esi, [ebp-12]				; tam thoi luu esi = i

		movzx	ebx, byte [ebp-4]
		mov		byte [edi], bl					; viet so phan du vao result_num[i]
		inc		edi

		mov		esi, [ebp-8]				; Cho esi la phan thuong cua so do voi 10
		inc		dword [ebp-12]				; i++
		jmp		LOOP

	PRINT_NUMBER:
		mov		esi, [ebp-12]

		LOOP2:
			cmp		esi, -1					; Kiem tra xem i = -1
			je		DONE_print

			lea		edi, [ebp-32+esi]	; Luu dia chi cua result[i]
			; in ra gai tri result[i]
			push	edi
			push	1
			call	print

			dec		esi						; i--
			jmp		LOOP2


	DONE_print:
		pop		eax
		pop		ecx
		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		4

; tuong duong voi: int to_num(char *num)
; Nhap vao mot so dang chu va sau do tra ve
; ket qua la mot so kieu int, luu vao eax
to_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 8
	push	esi
	push	edi

	mov		esi, [ebp+8]	; lay param1 vao esi
	mov		eax, 0
	mov		ebx, 0

	to_num_start:
		mov		bl, [esi]
		cmp		bl, 0xa
		je		end_to_num
		imul	eax, 10
		sub		bl, 0x30
		add		eax, ebx
		inc		esi
		jmp		to_num_start

	end_to_num:
		pop		edi
		pop		esi				; Khoi phuc lai esi  truoc
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret		4

; tuong duong voi: void print(char *str, int len)
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

	; Goi sysenter
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
		ret		8

