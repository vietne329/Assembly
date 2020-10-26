SECTION .data
	tab_space	db		"    "
	hex_sig		db		"0x"
	space		db		" ", 0
	hex_digits	db		"0123456789abcdef"
	nl			db		10

SECTION .text
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


	mov		al, 0x0
	lea		edi, [ebp-32]
	mov		ecx, 20
	cld
	rep		stosb
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
		mov		byte [edi], bl				; viet so phan du vao result_num[i]
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

; tuong duong voi: int open_file_read(char *file_name)
open_file_read:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov		eax, 5
	mov		ebx, dword [ebp+8]
	mov		ecx, 2

	; goi sysenter
	push	.sys_done		; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham mo file

	.sys_done:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		4

; tuong duong voi close(int fd)
close_file:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov		eax, 6
	mov		ebx, dword [ebp+8]

	; goi sysenter
	push	.sys_done		; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi ham dong file

	.sys_done:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		4

; tuong duong voi: int mmap_file(int fd)
mmap_file:
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	push	ebx
	push	esi
	push	edi

	push	dword [ebp+8]
	call	GetFileSize
	mov		dword [ebp-4], eax

	push	ebp
	mov		eax, 192
	xor		ebx, ebx
	mov		ecx, dword [ebp-4]
	mov		edx, 3
	mov		esi, 2
	mov		edi, dword [ebp+8]	
	mov		ebp, 0
	int		0x80
	pop		ebp


	.sys_done:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		4

; tuong duong voi: unmap_file(void *addr, int len)
munmap_file:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov		eax, 91
	mov		ebx, dword [ebp+8]
	mov		ecx, dword [ebp+12]

	; goi sysenter
	push	.sys_done		; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp
	sysenter				; Dung sysenter de goi ham unmap

	.sys_done:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		4
	
; tuong duong voi: int GetFileSize(int fd)
GetFileSize:
	push	ebp
	mov		ebp, esp
	sub		esp, 8			; ebp-4: temp_offset
							; ebp-8: result
	push	ebx
	push	esi
	push	edi

	mov		eax, 19
	mov		ebx, dword [ebp+8]
	mov		ecx, 0
	mov		edx, 1

	; goi sysenter
	push	.sys_find_size	; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp
	sysenter				; Dung sysenter de goi ham unmap

	.sys_find_size:
	mov		dword [ebp-4], eax
	mov		eax, 19
	mov		ebx, dword [ebp+8]
	mov		ecx, 0
	mov		edx, 2

	; goi sysenter
	push	.set_back_fd	; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp
	sysenter				; Dung sysenter de goi ham unmap

	.set_back_fd:
	mov		dword [ebp-8], eax
	mov		eax, 19
	mov		ebx, dword [ebp+8]
	mov		ecx, dword [ebp-4]
	mov		edx, 0

	; goi sysenter
	push	.DONE_file_size	; Cho return address vao stack de tra ve sau sysenter
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp
	sysenter				; Dung sysenter de goi ham unmap

	.DONE_file_size:
	mov		eax, dword [ebp-8]
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

; tuong duong voi: print_hex_string(int num, char *str)
convert_num2hex:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov 	edi, dword [ebp+12]
	mov 	ebx, dword [ebp+8]
	
	xor 	edx, edx
	mov 	ecx, 8
	.LOOP_dw2hex_local:
		mov 	eax, ebx
		shr 	eax, 28
		test	eax, eax
		jnz		.normal_process
		test	edx, edx
		jnz		.normal_process
		jmp		.next_num

		.normal_process:
			inc		edx
			
			mov 	al, byte [hex_digits+eax]
			stosb
			
		.next_num:
			shl 	ebx, 4
			loop 	.LOOP_dw2hex_local

	test	edx, edx
	jnz		.DONE
	mov		byte [edi], '0'
	inc		edi
	.DONE:
	mov		byte [edi], 0
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		8

; tuong duong voi: void print_hex(int num)
print_hex:
	push	ebp
	mov		ebp, esp
	sub		esp, 16		;ebp-16: byte: temp_str
	push	ebx
	push	esi
	push	edi
	push	ecx

	lea		ebx, [ebp-16]
	push	ebx
	push	dword [ebp+8]
	call	convert_num2hex

	push	ebx
	call	str_len

	push	eax
	push	ebx
	call	print

	pop		ecx
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

print_tab:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi
	
	push	4
	push	tab_space
	call	print

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret

print_hex_prefix:
	push	ebp
	mov		ebp, esp
	sub		esp, 16		;ebp-16: byte: temp_str
	push	ebx
	push	esi
	push	edi
	push	ecx

	lea		edi, [ebp-16]
	lea		esi, hex_sig
	mov		ecx, 2
	rep 	movsb
	lea		ebx, [ebp-14]
	push	ebx
	push	dword [ebp+8]
	call	convert_num2hex

	lea		ebx, [ebp-16]
	push	ebx
	call	str_len

	push	eax
	push	ebx
	call	print

	pop		ecx
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

print_space:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi
	push	ecx

	push	1
	push	space
	call	print

	pop		ecx
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

print_nl:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi
	push	ecx

	push	1
	push	nl
	call	print

	pop		ecx
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

; tuong duong voi: void print_without_len(char *str)
print_without_len:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi
	push	ecx

	push	dword [ebp+8]
	call	str_len

	push	eax
	push	dword [ebp+8]
	call	print

	pop		ecx
	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4
