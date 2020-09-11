bits 32
global _start
%include "read_write.asm"

SECTION .data
	sep			db		' '
	nl			db		0xa
	msg			db		"Nhap vao so luong cua mang: ", 0
	msg_len		equ		$-msg
	msg2		db		"Nhap vao cac gia tri cua mang (cach nhau boi dau phay): ", 0
	msg_len2	equ		$-msg2

SECTION .bss
	n				resd	1
	len_num1		resd	1
	arr_num_str		resb	300
	result_min		resd	1
	result_max		resd	1

section .text
_start:
	push	msg_len
	push	msg
	call	print

	push	n
	call	get_num

	push	msg_len2
	push	msg2
	call	print
	
	; lay xau 
	push	300
	push	arr_num_str
	call	get

	; tinh toan so lon nhat va nho nha trong mang
	push	dword [n]
	push	arr_num_str
	call	calculate_min_max
	mov		dword [result_min], eax
	mov		dword [result_max], edx

	push	dword [result_min]
	call	print_num

	push	1
	push	sep
	call	print

	push	dword [result_max]
	call	print_num

	push	1
	push	nl
	call	print

	; ket thuc chuong trinh
	mov		eax, 0x1		; Su dung ham sys_exit
	mov		ebx, 0			; Tra ve khong co loi
	push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi system goi sys_exit


; tuong duong voi: int min_max(char *result, int len)
calculate_min_max:
	push	ebp
	mov		ebp, esp
	sub		esp, 38		; ebp-22: char[22]: dung de chua xau so
						; ebp-26: i: dung de dem
						; ebp-30: result_min
						; ebp-34: result_max
						; ebp-38: reserve_num
	push	ebx
	push	esi
	push	edi

	mov		al, 0x0
	lea		edi, [ebp-22]
	mov		ecx, 22
	cld
	rep		stosb
	mov		dword [ebp-26], 0
	mov		dword [ebp-34], 0
	mov		esi, dword [ebp+8] ; esi = *result
	mov		ecx, -1
	.find_str1:
		inc		ecx
		lodsb
		cmp		al, ','
		je		.turn_to_num
		cmp		al, 0xa
		je		.turn_to_num
		mov		byte [ebp-22+ecx], al
		jmp		.find_str1
	
	.turn_to_num:
		mov		dword [ebp-38], ecx
		lea		edi, [ebp-22]
		push	edi
		call	to_num						; bien doi chu do thanh so

		mov		ecx, dword [ebp-26]
		test	ecx, ecx					; Kiem tra xem ecx co la so dau tien ko
		jz		.initialise

		cmp		eax, dword [ebp-30]			; kiem tra xem so do co < result_min
		jae		.check_small				; sai: tiep tuc so tiep theo
		mov		dword [ebp-30], eax			; dung: result_min = eax

		.check_small:
		cmp		eax, dword [ebp-34]			; kiem tra xem so do co > result_max
		jbe		.continue_transformation	; sai: kiem tra so tiep theo
		mov		dword [ebp-34], eax			; dung: result_max = eax

		.continue_transformation:
			; cho temp_num ve gia tri ban dau
			mov		al, 0x0
			lea		edi, [ebp-22]
			mov		ecx, [ebp-38]
			rep		stosb

			inc		dword [ebp-26]			; i++
			mov		ecx, dword [ebp-26]		
			cmp		ecx, dword [ebp+12]		; kiem tra xem len == i chua
			je		.DONE					; dung: thi hoan thanh
			mov		ecx, -1
			jmp		.find_str1				; sai: tiep tuc kiem tra so tiep theo


	.initialise:
		mov		dword [ebp-30], eax
		mov		dword [ebp-34], eax
		jmp		.continue_transformation

	.DONE:
		mov		eax, dword [ebp-30] ; eax chua so be nhat
		mov		edx, dword [ebp-34] ; edx chua so lon nhat
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		8
