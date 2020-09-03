; tuong duong voi get(char *str, int len)
get:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi

	mov		eax, 0x3
	mov		ebx, 0
	mov		ecx, [ebp+8]
	mov		edx, [ebp+12]

	; goi sysenter
	push	.sys_ret_get	; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham in ra

	.sys_ret_get:
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret		8

; tuong duong voi: void print(char *str, int len)
print:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi
	push	edi				; luu lai edi va esi
	push	esi

	mov		edi, [ebp+8]	; edi = *str
	mov		esi, [ebp+12]	; esi = len

	mov		eax, 0x4		; Su dung ham sys_write
	mov		ebx, 1			; Viet vao stdout
	mov		ecx, edi		; lay dia chi cua message
	mov		edx, esi		; lay do dai cua message

	; Goi sysenter
	push	.system_ret_print; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham in ra

	.system_ret_print:
		pop		esi				; Khoi phuc lai esi va edi truoc
		pop		edi
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret		8

; tuong duong voi: int str_len(char *str)
str_len:
	push	ebp
	mov		ebp, esp
	push	esi
	push	ecx

	mov		esi, [ebp+8]
	mov		eax, 0
	mov		ecx, 0
	.LOOP_str_len:
		cmp		byte [esi+ecx], 0xa
		je		.done_str_len
		cmp		byte [esi+ecx], 0x0
		je		.done_str_len
		inc		ecx
		inc		eax
		jmp		.LOOP_str_len

	.done_str_len:
		pop		ecx
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		4

# tuong duong voi: void print_num(int num)
# nhap vao mot so va in ra man hinh so do
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

	.LOOP:
		cmp		esi, 0						; kiem tra xem chay het tung so chua
		je		.PRINT_NUMBER

		mov		edx, 0						; dat edx = 0
		mov		eax, esi					
		div		ecx							; chia eax cho ecx

		mov		[ebp-4], edx				; Dat local 1 la phan du
		mov		[ebp-8], eax				; Dat local 2 la ket qua sau khi chia
		add		dword [ebp-4], 0x30			; bien doi phan du thanh chu ascii
		mov		esi, [ebp-12]				; tam thoi luu esi = i

		mov		ebx, 0
		mov		bl, byte [ebp-4]
		mov		byte [edi], bl					; viet so phan du vao result_num[i]
		inc		edi

		mov		esi, [ebp-8]				; Cho esi la phan thuong cua so do voi 10
		inc		dword [ebp-12]				; i++
		jmp		.LOOP

	.PRINT_NUMBER:
		mov		esi, [ebp-12]

		.LOOP2:
			cmp		esi, -1					; Kiem tra xem i = -1
			je		.DONE_print

			lea		edi, [ebp-32+esi]	; Luu dia chi cua result[i]
			; in ra gai tri result[i]
			push	1
			push	edi
			call	print
			add		esp, 8

			dec		esi						; i--
			jmp		.LOOP2

	.DONE_print:
		pop		eax
		pop		ecx
		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		4

; tuong duong voi: void get_num(int *num)
get_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 20				; aloocate 20 byte cho local1
	push	edi

	mov		edi, [ebp+8]		; edi = param1
	lea		ebx, [ebp-20]		; ebx = local1
	; Luu ket qua nhap vao ban phim vao local1
	push	20
	push	ebx
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

# tuong duong voi: int to_num(char *num)
# Nhap vao mot so dang chu va sau do tra ve
# ket qua la mot so kieu int, luu vao eax
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
		cmp		bl, 0x0
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
