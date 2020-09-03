; Compile with: nasm -f elf32 echo.asm
; Link with: gcc -m32 echo.o -o echo
; Run with: ./echo

bits 32
global _start

SECTION .data
	msg			db		"Nhap vao: ", 0
	msgLen		equ		$-msg
	result		db		"Ket qua la: ", 0
	resultLen	equ		$-result

SECTION .bss
	inp		resb	32

SECTION .text
_start:
	; In ra "Nhap vao"
	push	msg
	push	msgLen
	call	print
	add		esp, 8

	; Nhap vao cac ky tu
	push	inp
	push	32
	call	get
	add		esp, 8

	; Vong lap tu dau ky tu den cuoi ky tu
	mov		esi, inp
	mov		ecx , -1
loop1:
	inc		ecx

	cmp		byte [esi+ecx], 0xa	; Kiem tra xem da den cuoi chua
	je		done

	mov		al, byte[esi+ecx]
	sub		al, 97
	cmp		al, 26
	ja		loop1

	mov		al, byte [esi+ecx]	; Lay ky tu tai vi tri thu $ecx
	sub		al, 32				; Lay ky tu do tru cho 32 de duoc ky tu in hoa cua no
	mov		byte [esi+ecx], al	; Dat lai ky tu do
	jmp		loop1
done:
	; In ra ket qua
	push	result
	push	resultLen
	call	print
	add		esp, 8

	push	inp
	push	32
	call	print
	add		esp, 8

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

