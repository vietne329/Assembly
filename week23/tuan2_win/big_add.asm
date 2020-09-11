.386
.model flat, stdcall
option casemap : none

include D:\viettel\tuan2_win\read_write.asm
include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
    digits	db	"0123456789"
    nl		db	13, 10
    msg		db	"Nhap vao so thu 1: ", 0
    msg_len	equ	$-msg
    msg2	db	"Nhap vao so thu 2: ", 0
    msg_len2	equ	$-msg2
    caption     db      "Ket qua"
    
.data?
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?

    num1            BYTE    22  DUP(?)
    num2            BYTE    22  DUP(?)
    result          BYTE    23  DUP(?)
    bufferRead      DWORD   ?
    written         DWORD   ?
    len_num1        DWORD   ?
    len_num2        DWORD   ?
    len_result      DWORD   ?
    
.code
start:
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax
    
    ; Nhap vao so thu nhat
    lea     eax, msg
    mov     ebx, msg_len
    push    stdOutHandle
    push    ebx
    push    eax
    call    print
    
    lea     ebx, num1
    push    stdInHandle
    push    22
    push    ebx
    call    get
    
    ; lay do dai num1
    lea     eax, num1
    push    eax
    call    str_len
    
    mov	    [len_num1], eax
    mov	    byte ptr [num1+eax], 0
    mov     byte ptr [num1+eax+1], 0
    
    ; Nhap vao so thu hai
    lea     eax, msg2
    mov     ebx, msg_len2
    push    stdOutHandle
    push    ebx
    push    eax
    call    print
    
    lea     ebx, num2
    push    stdInHandle
    push    22
    push    ebx
    call    get
    
    ; lay do dai num2
    lea     eax, num2
    push    eax
    call    str_len
    
    mov	    [len_num2], eax
    mov	    byte ptr [num2+eax], 0		; Cho NULL Terminate vao cuoi thay cho \n
    mov     byte ptr [num2+eax+1], 0
    
    ; bien doi num1 va num2 nguoc lai de de dang cong voi nhau
    lea     eax, num1
    push    dword ptr [len_num1]
    push    eax
    call    reverse_str
	
    lea     eax, num2
    push    dword ptr [len_num2]
    push    eax
    call    reverse_str
    
    lea     eax, num1
    lea     ebx, num2
    lea     edx, result
    push    eax
    push    ebx
    push    edx
    call    big_add
    
    ; lay do dai cua xau ket qua
    lea     eax, result
    push    eax
    call    str_len
    mov     dword ptr [len_result], eax
    
    ; In ra ket qua
    lea     eax, result
    push    stdOutHandle
    push    dword ptr [len_result]
    push    eax
    call    print
    ;write your code here
    xor eax, eax
    ret
    

; tuong duong voi: void big_add(char *result, char *num2, char *num1)
; num1 va num2 phai duoc nguoc lai tu truoc
big_add:
	push	ebp
	mov	ebp, esp
	sub	esp, 24		; ebp-4: len_num1
				; ebp-8: len_num2
				; ebp-12: do dai lon nhat
				; ebp-16: i
				; ebp-17: carry
				; ebp-18: temp_num1
				; ebp-19: temp_num2
				; ebp-20: sum
				; ebp-24: len_result
                                ; ebp-28: temp_num
	push	ebx
	push	edi
	push	esi

	; Luu cac dau vao
        mov     dword ptr [ebp-28], 10
	mov	esi, [ebp+16]	; esi = num1
	mov	edi, [ebp+12]	; edi = num2
	mov	dword ptr [ebp-16], 0 ; i
	mov	byte ptr [ebp-17], 0 ; carry = 0
	mov	byte ptr [ebp-20], 0

	; lay do dai cua num1 va num2
	push	esi
	call	str_len
	mov	dword ptr [ebp-4], eax
	push	edi
	call	str_len
	mov	dword ptr [ebp-8], eax

	; Tim do dai lon nhat
	mov	eax, dword ptr [ebp-4]
	cmp	eax, dword ptr [ebp-8]		; neu do dai so thu nhat lon hon so thu hai
	jg	str1_largest_length
	mov	eax, dword ptr [ebp-8]
	mov	dword ptr [ebp-12], eax
	jmp	loop_calc

	str1_largest_length:
		mov	dword ptr [ebp-12], eax
	loop_calc:
		; Vong lap cho den so lon nhat hoac la phan du van con
		mov	ecx, dword ptr [ebp-16]
		; tuong duong voi for (i = 0; i < n || carry == 1; i++)
		cmp	ecx, dword ptr [ebp-12]
		jl	start_doing_calc
		cmp	byte ptr [ebp-17], 1
		je	start_doing_calc

		; Neu nhu hai dk tren khong thoa man thi ket thuc vong lap
		jmp	Done_doing_calc

		start_doing_calc:
			; tuong duong voi if(*num1 == '\0' && *num2 == '\0')
			cmp	byte ptr [edi], 0
			jne	ELSE_calc
			cmp	byte ptr [esi], 0
			jne	ELSE_calc

			mov	byte ptr [ebp-18], 0
			mov	byte ptr [ebp-19], 0
			jmp	add_big_num
			ELSE_calc:
				cmp	byte ptr [edi], 0
				je	str1_null
				cmp	byte ptr [esi], 0
				je	str2_null
				; luu so thu nhat vao temp_num1
				lodsb
				sub	al, 30h
				mov	byte ptr [ebp-18], al
				; Luu so thu hai vao temp_num2
				push	esi					; Luu vi tri truoc cua esi
				mov	esi, edi			; lay num2 tu edi
				lodsb
				mov	edi, esi			; luu esi vao num2 cua edi
				pop	esi					; Lay lai vi tri truoc cua esi

				sub	al, 30h
				mov	byte ptr [ebp-19], al
				jmp	add_big_num

				str1_null:
					mov	byte ptr [ebp-18], 0
					lodsb
					sub	al, 30h
					mov	byte ptr [ebp-19], al
					jmp	add_big_num

				str2_null:
					mov	byte ptr [ebp-19], 0

					push	esi
					mov	esi, edi
					lodsb	
					mov	edi, esi
					pop	esi

					sub	al, 30h
					mov	byte ptr [ebp-18], al

			add_big_num:
				mov	edx, 0
				add	dl, byte ptr [ebp-18]	; dl += temp_num1
				add	dl, byte ptr [ebp-19]	; dl += temp_num2
				add	dl, byte ptr [ebp-17]	; dl += carry
				movzx	eax, dl				; eax = temp_num1
				cdq							; edx:eax la tu so
				idiv	dword ptr [ebp-28]		; phan thuong se duoc luu vao eax
											; phan du se duoc luu vao edx
				mov	byte ptr [ebp-17], al	; luu phan du vao carry
				mov	ecx, dword ptr [ebp-16]
				movzx	ebx, dl				; luu thuong so vao ebx
				mov	ah, byte ptr [digits+ebx] ; lay chu so tuong ung voi chu do
                                mov     edx, dword ptr [ebp+8]
				mov	byte ptr [edx+ecx], ah

			inc	dword ptr [ebp-16]
			jmp	loop_calc

	Done_doing_calc:
		; them null terminate vao cuoi result
		mov	ecx, dword ptr [ebp-16]
                mov     edx, dword ptr [ebp+8]
		mov	byte ptr [edx+ecx], 0

		; lay do dai cua ket qua
                mov     eax, [ebp+8]
		push	eax
		call	str_len
		mov	dword ptr [ebp-24], eax
                ; Dao nguoc ket qua
                mov     eax, [ebp+8]
                mov     ebx, dword ptr [ebp-24]
		push	ebx
		push	eax
		call	reverse_str

		pop	esi
		pop	edi
		pop	ebx
		mov	esp, ebp
		pop	ebp
		ret	12
    
; tuong duong voi: void reverse_str(char *str, int len)
reverse_str:
	push	ebp
	mov	ebp, esp
	sub	esp, 2		; ebp-1: temp: byte
				; ebp-2: temp2: byte
	push	esi
	push	edi
	push	ebx

	mov	esi, [ebp+12]	; esi = str_len
	mov	edi, [ebp+8]	; edi = char *str
	mov	ecx, 0
	LOOP_reverse_str:
		mov	ebx, ecx		; tam thoi luu ecx vao ebx
		imul	ecx, 2
		cmp	ecx, esi		; Kiem tra xem i < n/2
		jge	DONE_reverse_str

		mov	ecx, ebx		; Tra ve vi tri cua ecx luc truoc
		movzx	ebx, byte ptr [edi+ecx] ; temp = str[i]
		mov	[ebp-1], bl

		mov	edx, esi		; edx = str_len-1-i
		sub	edx, 1
		sub	edx, ecx

		movzx	ebx, byte ptr [edi+edx]	; temp2 = str[edx]
		mov	[ebp-2], bl

                ; hoan doi vi tri cua temp va temp2
		mov	bl, byte ptr [ebp-2]
		mov	[edi+ecx], bl
		mov	bl, byte ptr [ebp-1]
		mov	[edi+edx], bl

		inc	ecx
		jmp	LOOP_reverse_str

	DONE_reverse_str:
		pop	ebx
		pop	edi
		pop	esi
		mov	esp, ebp
		pop	ebp
		ret	8
            
end start
