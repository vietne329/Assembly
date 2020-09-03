bits 32
global _start

SECTION .data
	nl		db		0xa
	msg1	db		"Nhap vao so 1: ", 0
	msg1Len equ		$-msg1
	msg2	db		"Nhap vao so 2: ", 0
	msg2Len equ		$-msg2
	result	db		"Ket qua la: ", 0

SECTION .bss
	num1		resd	1
	num2		resd	1
	result_num	resb	100

SECTION .text
_start:
	; Nhap vao cac so thu nhat
	push	msg1
	push	msg1Len
	call	print
	add		esp, 4

	push	num1
	call	get_num
	add		esp, 4

	; Nhap vao so thu hai
	push	msg2
	push	msg2Len
	call	print
	add		esp, 8

	push	num2
	call	get_num
	add		esp, 4

	; Cong hai so
	mov		eax, [num1]
	add		eax, [num2]

	; In ra ket qua
	push	eax
	call	print_num
	add		esp, 4

	; ket thuc chuong trinh
	mov		eax, 0x1		; Su dung ham sys_exit
	mov		ebx, 0			; Tra ve khong co loi
	push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi system goi sys_exit

# tuong duong voi: void print(char *buf, int len)
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

# tuong duong voi: void print_num(int num)
# nhap vao mot so va in ra man hinh so do
print_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 12			; ebp-4 se la local1
							; ebp-8 se la local2
							; ebp-12 se la local3
	push	esi
	push	edi
	push	ebx

	mov		edi, result_num					; edi = result_num
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
			je		DONE

			lea		edi, [result_num+esi]	; Luu dia chi cua result[i]
# in ra gai tri result[i]
			push	edi
			push	1
			call	print
			add		esp, 8

			dec		esi						; i--
			jmp		LOOP2


	DONE:
# them vao dong moi o cuoi
		mov		ebx, nl
		push	ebx
		push	1
		call	print
		add		esp, 8

		pop		ebx
		pop		edi
		pop		esi
		mov		esp, ebp
		pop		ebp
		ret

get:
	push	ebp				; luu lai ebp truoc
	mov		ebp, esp		; dat mot base pointer rmoi

# Nhap tu stdin vao inp
	mov		eax, 0x3
	mov		ebx, 0
	mov		ecx, [ebp+12]
	mov		edx, [ebp+8]
# chuan bi stack cho sysenter
	push	system_ret_get
	push	ecx
	push	edx
	push	ebp
	mov		ebp, esp
	sysenter
	
	system_ret_get:
		mov		esp, ebp		; loai bo cac bien trong pt nay
		pop		ebp				; Khoi phuc lai vi tri cua ebp truoc
		ret

# tuong duong voi: void get_num(int *num)
get_num:
	push	ebp
	mov		ebp, esp
	sub		esp, 20				; aloocate 20 byte cho local1
	push	edi

	mov		edi, [ebp+8]		; edi = param1
	lea		ebx, [ebp-20]		; ebx = local1
# Luu ket qua nhap vao ban phim vao local1
	push	ebx
	push	20
	call	get
	add		esp, 8

# Bien doi local1 thanh so va luu no vao eax
	lea		ebx, [ebp-20]
	push	ebx
	call	to_num
	add		esp, 4

	mov		[edi], eax			; Luu gia tri cua eax vao param1

	pop		edi
	mov		esp, ebp
	pop		ebp
	ret


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
		ret		
