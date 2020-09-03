bits 32
global _start

SECTION .data
	nl			db		0xa
	msg			db		"Nhap vao xau can dao nguoc: ", 0
	msg_len		equ		$-msg

SECTION .bss
	string			resb	257
	len_str			resd	1

section .text
_start:
	; Nhap vao xau can dao nguoc
	push	msg
	push	msg_len
	call	print
	push	string
	push	100
	call	get

	push	string
	call	str_len

	mov		[len_str], eax
	push	string
	push	len_str
	call	reverse_str

	add		dword [len_str], 1
	push	string
	push	len_str
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
	LOOP_reverse_str:
		mov		ebx, ecx		; tam thoi luu ecx vao ebx
		imul	ecx, 2
		cmp		ecx, [esi]		; Kiem tra xem i < n/2
		jge		DONE_reverse_str

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
		jmp		LOOP_reverse_str

	DONE_reverse_str:
		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret		8
