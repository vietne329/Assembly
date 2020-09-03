bits 32
global _start

SECTION .data
	seprator	db		" "
	nl			db		0xa
	msg			db		"Nhap vao: ", 0
	msg_len		equ		$-msg
	result		db		"Ket qua la: ", 0
	result_len	equ		$-result

SECTION .bss
	long_str	resb	101
	short_str	resb	11
	result_pos	resd	100
	result_num	resb	32
	temp		resd	1
	i			resd	1

SECTION .text
_start:
	; Nhap vao xau
	push	msg
	push	msg_len
	call	print
	push	long_str
	push	100
	call	get

	; Nhap vao xau con
	push	msg
	push	msg_len
	call	print
	push	short_str
	push	10
	call	get

	; Tinh so luong xuat hien xcua xau con
	; dong thoi luu cac vi tri do vao mang result_pos
	push	long_str
	push	short_str
	push	result_pos
	call	count
	mov		[temp], eax			; Tam thoi luu ket qua so luong xuat hien sau con vao temp

	; In ra so luong
	push	eax
	call	print_num
	push	nl
	push	1
	call	print

	; In ra tat ca cac vi tri
	mov		dword [i], 0
	LOOP_start:
		mov		ecx, [i]				; Luu i vao ecx
		cmp		ecx, [temp]				; kiem tra den khi nao i = so luong xuat hien
		je		DONE_start

		; In ra result_pos[i]
		push	dword [result_pos+4*ecx]
		call	print_num

		; In ra dau cach
		push	seprator
		push	1
		call	print

		inc		dword [i]
		jmp		LOOP_start

	; ket thuc chuong trinh
	DONE_start:
		; In xuong dong
		push	nl
		push	1
		call	print
		
		mov		eax, 0x1		; Su dung ham sys_exit
		mov		ebx, 0			; Tra ve khong co loi
		push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
		push	ecx				; Luu ecx, edx va ebp
		push	edx
		push	ebp
		mov		ebp, esp		; dat mot base pointer moi cho sysenter
		sysenter				; Dung sysenter de goi system goi sys_exit

# tuong duong voi: void print(char *str, int len)
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

		mov		ebx, 0
		mov		bl, byte [ebp-4]
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
# in ra gai tri result[i]
			push	edi
			push	1
			call	print
			add		esp, 8

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

get:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi

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
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret		8

; tuong duong voi: int count(char *long_str, char *short_str, int *result_list)
count:
	push	ebp
	mov		ebp, esp
	; [ebp-4]: count
	; [ebp-8]: count_pos
	sub		esp, 8
	push	esi
	push	edi
	push	ebx

	mov		dword [ebp-4], 0
	mov		dword [ebp-8], 0
	mov		edi, [ebp+16]		; edi chua vi tri cua xau
	mov		esi, [ebp+12]		; esi chua vi tri cua xau con can tim
	mov		ecx, -1

	LOOP_count:
		inc		ecx

		cmp		byte [edi+ecx], 0xa ; Kiem tra xem da den cuoi tu do chua
		je		done_count

		lea		ebx, [edi+ecx]		; push xau do ke tu vi tri thu ecx vao stack
		push	ebx
		lea		ebx, [esi]			; push xau con vao stack
		push	ebx
		call	compare_string

		cmp		eax, 0
		je		equal_str
		jmp		LOOP_count

	equal_str:
		inc		dword [ebp-4]
		mov		edx, dword [ebp-8]

		mov		ebx, [ebp+8]			; ebx chua vi tri dau tien cua list mang de ghi vao ket qua
		mov		dword [ebx+4*edx], ecx
		inc		dword [ebp-8]

		jmp		LOOP_count

	done_count:
		mov		eax, [ebp-4]			; Luu ket qua vao eax de tra ve

		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		8

; tuong duong voi: int compare_string(char *str1, char *str2)
compare_string:
	push	ebp
	mov		ebp, esp
	; [ebp-4] lenA: do dai cua xau con
	sub		esp, 4
	push	esi
	push	edi
	push	ebx
	push	ecx

	mov		edi, [ebp+12] ; edi chua vi tri cua xau
	mov		esi, [ebp+8]  ; esi chua vi tri cua xau con can tim

	; Lay do dai cua xau con
	push	esi
	call	str_len

	mov		dword [ebp-4], eax
	mov		ecx, 0
	LOOP_compare:
		cmp		byte [esi+ecx], 0xa
		je		done_compare
		cmp		byte [edi+ecx], 0xa
		je		done_compare
		mov		bl, byte [edi+ecx]
		cmp		byte [esi+ecx], bl
		jne		done_compare
		inc		ecx
		jmp		LOOP_compare

	done_compare:
		mov		eax, -1				; tra ve ket qua eax la khong bang nhau
		cmp		ecx, dword [ebp-4]
		jne		ret_compare
		mov		eax, 0				; tra ve ket qua la bang nhau
		
	ret_compare:
		pop		ecx
		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
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
	LOOP_str_len:
		cmp		byte [esi+ecx], 0xa
		je		done_str_len
		inc		ecx
		inc		eax
		jmp		LOOP_str_len

	done_str_len:
		pop		ecx
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		4

