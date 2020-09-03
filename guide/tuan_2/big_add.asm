bits 32
global _start
%include "read_write.asm"

SECTION .data
	digits		db		"0123456789"
	nl			db		0xa
	msg			db		"Nhap vao so thu 1: ", 0
	msg_len		equ		$-msg
	msg2		db		"Nhap vao so thu 2: ", 0
	msg_len2	equ		$-msg2

SECTION .bss
	num1			resb	22
	len_num1		resd	1
	num2			resb	22
	len_num2		resd	1
	result			resb	23
	len_result		resd	1

section .text
_start:
	; Nhap vao num1
	push	msg
	push	msg_len
	call	print
	push	num1
	push	22
	call	get

	; lay do dai num1
	push	num1
	call	str_len
	mov		[len_num1], eax
	mov		byte [num1+eax], 0		; Cho NULL Terminate vao cuoi thay cho \n

	; nhap vao num2
	push	msg2
	push	msg_len2
	call	print
	push	num2
	push	22
	call	get

	; lay do dai num2
	push	num2
	call	str_len
	mov		[len_num2], eax
	mov		byte [num2+eax], 0		; Cho NULL Terminate vao cuoi thay cho \n

	; bien doi num1 va num2 nguoc lai de de dang cong voi nhau
	push	num1
	push	len_num1
	call	reverse_str
	
	push	num2
	push	len_num2
	call	reverse_str

	push	num1
	push	num2
	push	result
	call	big_add

	push	result
	call	str_len
	mov		[len_result], eax

	.print_result:
	push	result
	push	dword [len_result]
	call	print

	push	nl
	push	1
	call	print

	; ket thuc chuong trinh
	.DONE_start:
		mov		eax, 0x1		; Su dung ham sys_exit
		mov		ebx, 0			; Tra ve khong co loi
		push	.DONE_start		; Khong quan trong do sau khi sysenter thi chuong trinh thoat
		push	ecx				; Luu ecx, edx va ebp
		push	edx
		push	ebp
		mov		ebp, esp		; dat mot base pointer moi cho sysenter
		sysenter				; Dung sysenter de goi system goi sys_exit

; tuong duong voi: void big_add(char *num1, char *num2, char *result)
; num1 va num2 phai duoc nguoc lai tu truoc
big_add:
	push	ebp
	mov		ebp, esp
	sub		esp, 24		; ebp-4: len_num1
						; ebp-8: len_num2

						; ebp-12: do dai lon nhat
						; ebp-16: i
						; ebp-17: carry
						; ebp-18: temp_num1
						; ebp-19: temp_num2
						; ebp-20: sum
						; ebp-24: reserve
	push	ebx
	push	edi
	push	esi

	; Luu cac dau vao
	mov		esi, [ebp+16]	; esi = num1
	mov		edi, [ebp+12]	; edi = num2
	mov		dword [ebp-16], 0 ; i
	mov		byte [ebp-17], 0 ; carry = 0
	mov		byte [ebp-20], 0
	mov		dword [ebp-24], 0xa

	; lay do dai cua num1 va num2
	push	esi
	call	str_len
	mov		dword [ebp-4], eax
	push	edi
	call	str_len
	mov		dword [ebp-8], eax

	; Tim do dai lon nhat
	mov		eax, dword [ebp-4]
	cmp		eax, dword [ebp-8]		; neu do dai so thu nhat lon hon so thu hai
	jg		.str1_largest_length
	mov		eax, dword [ebp-8]
	mov		dword [ebp-12], eax
	jmp		.loop_calc

	.str1_largest_length:
		mov		dword [ebp-12], eax
	.loop_calc:
		; Vong lap cho den so lon nhat hoac la phan du van con
		mov		ecx, dword [ebp-16]
		; tuong duong voi for (i = 0; i < n || carry == 1; i++)
		cmp		ecx, dword [ebp-12]
		jl		.start_doing_calc
		cmp		byte [ebp-17], 1
		je		.start_doing_calc

		; Neu nhu hai dk tren khong thoa man thi ket thuc vong lap
		jmp		.Done_doing_calc

		.start_doing_calc:
			; tuong duong voi if(*num1 == '\0' && *num2 == '\0')
			cmp		byte [edi], 0
			jne		.ELSE
			cmp		byte [esi], 0
			jne		.ELSE

			mov		byte [ebp-18], 0
			mov		byte [ebp-19], 0
			jmp		.add_big_num
			.ELSE:
				cmp		byte [edi], 0
				je		.str1_null
				cmp		byte [esi], 0
				je		.str2_null
				; luu so thu nhat vao temp_num1
				lodsb
				sub		al, 0x30
				mov		byte [ebp-18], al
				; Luu so thu hai vao temp_num2
				push	esi					; Luu vi tri truoc cua esi
				mov		esi, edi			; lay num2 tu edi
				lodsb
				mov		edi, esi			; luu esi vao num2 cua edi
				pop		esi					; Lay lai vi tri truoc cua esi

				sub		al, 0x30
				mov		byte [ebp-19], al
				jmp		.add_big_num

				.str1_null:
					mov		byte [ebp-18], 0
					lodsb
					sub		al, 0x30
					mov		byte [ebp-19], al
					jmp		.add_big_num

				.str2_null:
					mov		byte [ebp-19], 0

					push	esi
					mov		esi, edi
					lodsb	
					mov		edi, esi
					pop		esi

					sub		al, 0x30
					mov		byte [ebp-18], al

			.add_big_num:
				mov		edx, 0
				add		dl, byte [ebp-18]	; dl += temp_num1
				add		dl, byte [ebp-19]	; dl += temp_num2
				add		dl, byte [ebp-17]	; dl += carry
				movzx	eax, dl				; eax = temp_num1
				cdq							; edx:eax la tu so
				idiv	dword [ebp-24]		; phan thuong se duoc luu vao eax
											; phan du se duoc luu vao edx
				mov		byte [ebp-17], al	; luu phan du vao carry
				mov		ecx, dword [ebp-16]
				movzx	ebx, dl				; luu thuong so vao ebx
				mov		ah, byte [digits+ebx] ; lay chu so tuong ung voi chu do
				mov		byte [result+ecx], ah

			inc		dword [ebp-16]
			jmp		.loop_calc

	.Done_doing_calc:
		; them null terminate vao cuoi result
		mov		ecx, dword [ebp-16]
		mov		byte [result+ecx], 0

		; Dao nguoc ket qua
		push	result
		call	str_len
		mov		[len_result], eax
		push	result
		push	len_result
		call	reverse_str

		pop		esi
		pop		edi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		12

; tuong duong voi: void reverse_str(char *str1, int len)
reverse_str:
	push	ebp
	mov		ebp, esp
	sub		esp, 2			; ebp-4: temp
							; ebp-8: temp2
	push	esi
	push	edi
	push	ebx

	mov		esi, [ebp+8]	; esi = str_len
	mov		edi, [ebp+12]	; edi = char *str
	mov		ecx, 0
	.LOOP_reverse_str:
		mov		ebx, ecx		; tam thoi luu ecx vao ebx
		imul	ecx, 2
		cmp		ecx, [esi]		; Kiem tra xem i < n/2
		jge		.DONE_reverse_str

		mov		ecx, ebx		; Tra ve vi tri cua ecx luc truoc
		movzx	ebx, byte [edi+ecx]		 ; str[i]
		mov		[ebp-1], bl
		mov		edx, [esi]				 ; edx = str_len-1-i
		sub		edx, 1
		sub		edx, ecx
		movzx	ebx, byte [edi+edx]		 ; str[edx]
		mov		[ebp-2], bl

		mov		bl, byte [ebp-2]
		mov		[edi+ecx], bl
		mov		bl, byte [ebp-1]
		mov		[edi+edx], bl

		inc		ecx
		jmp		.LOOP_reverse_str

	.DONE_reverse_str:
		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		8
