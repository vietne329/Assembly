bits 32
global _start
global switch_case: function
%include "read_write.asm"

SECTION .data
	sep				db		' '
	nl				db		0xa

	lua_chon		db		"Cac lua chon", 0xa, 0
	lua_chon_len	equ		$-lua_chon
	lua_chon1		db		"1. Cong", 0xa, 0
	lua_chon1_len	equ		$-lua_chon1
	lua_chon2		db		"2. Tru", 0xa ,0
	lua_chon2_len	equ		$-lua_chon2
	lua_chon3		db		"3. Nhan", 0xa, 0
	lua_chon3_len	equ		$-lua_chon3
	lua_chon4		db		"4. Chia", 0xa, 0
	lua_chon4_len	equ		$-lua_chon4

	msg				db		"Nhap vao so can chon: ", 0
	msg_len			equ		$-msg

	msg2			db		"Nhap vao so thu 1: ", 0
	msg2_len		equ		$-msg2

	msg3			db		"Nhap vao so thu 2: ", 0
	msg3_len		equ		$-msg3

	not_found		db		"Khong co lua chon do", 13, 0
	not_found_len	equ		$-not_found

	jump_table	dd	switch_case.case1, switch_case.case2, switch_case.case3, switch_case.case4


SECTION .bss
	choice			resd	1
	num1			resd	1
	num2			resd	1

section .text
_start:
	push	msg2_len
	push	msg2
	call	print

	push	num1
	call	get_num

	push	msg3_len
	push	msg3
	call	print

	push	num2
	call	get_num

	push	lua_chon_len
	push	lua_chon
	call	print

	push	lua_chon1_len
	push	lua_chon1
	call	print

	push	lua_chon2_len
	push	lua_chon2
	call	print

	push	lua_chon3_len
	push	lua_chon3
	call	print

	push	lua_chon4_len
	push	lua_chon4
	call	print

	push	msg_len
	push	msg
	call	print

	push	choice
	call	get_num

	push	dword [num2]
	push	dword [num1]
	push	dword [choice]
	call	switch_case

	push	eax
	call	print_num

	; ket thuc chuong trinh
	mov		eax, 0x1		; Su dung ham sys_exit
	mov		ebx, 0			; Tra ve khong co loi
	push	switch_case			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi system goi sys_exit


; tuong duong voi: void switch_case(int choice, int num1, int num2)
switch_case:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov		eax, dword [ebp+12]		; eax = num1
	cdq								; edx = signed num1
	mov		ecx, dword [ebp+16]		; ecx = num2
	mov		ebx, dword [ebp+8]		; ebx = choice
	sub		ebx, 1
	cmp		ebx, 4
	ja		.default_case
	jmp		dword [jump_table+ebx*4]

	.case1:
		add		eax, ecx
		jmp		.DONE_switch

	.case2:
		sub		eax, ecx
		jmp		.DONE_switch
	
	.case3:
		imul	ecx
		jmp		.DONE_switch

	.case4:
		idiv	ecx
		jmp		.DONE_switch

	.default_case:
		push	not_found_len
		push	not_found
		call	print

	.DONE_switch:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		12
