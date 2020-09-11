.386
option casemap : none

.data
    digits	db	"0123456789"

.code
; tuong duong voi void print(char *str, int len, handle stdOutHandle)
print:
        push    ebp
        mov     ebp, esp
        sub     esp, 4
        push    ebx
        push    esi
        push    edi
 
        mov     edx, [ebp+16]           ; luu stdoutHandle
        mov     esi, dword ptr [ebp+12] ; luu len
        mov     edi, dword ptr [ebp+8]  ; luu *str

        lea     eax, [esp-4]
        push    0
        push    eax
        push    esi
        push    edi
        push    edx
        call    WriteConsole
    
        pop     edi
        pop     esi
        pop     ebx
        mov     esp, ebp
        pop     ebp
        ret     12
        
; tuong duong voi: void get_num(int *num, handle stdInHandle)
get_num:
    push    ebp
    mov     ebp, esp
    sub     esp, 22         ; tam thoi chua string cua
                            ; so nhap vao tu ban phim
    push    ebx
    push    esi
    push    edi
    
    mov     edi, dword ptr [ebp+8]
    mov     esi, dword ptr [ebp+12]
    
    lea     ebx, [ebp-22]
    push    esi
    push    22
    push    ebx
    call    get
    
    push    ebx
    call    str_len
    
    push    eax
    push    ebx
    call    to_num
    
    mov     ebx, dword ptr [ebp+8]
    mov     dword ptr [ebx], eax
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret     8
    
; tuong duong voi: void get(char *str, int len, handle stdInHandle)
get:
    push    ebp
    mov     ebp, esp
    sub     esp, 4
    push    ebx
    push    esi
    push    edi
    
    lea     ebx, [esp-4]   
    push    0
    push    ebx                 ; push temp_written
    mov     ebx, [ebp+12]       ; push len
    push    ebx
    mov     ebx, [ebp+8]        ; push *str
    push    ebx
    mov     ebx, [ebp+16]       ; push stdInHandle
    push    ebx
    call    ReadConsole
    
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret     12
    
    ; Tuong duong voi int to_num(char *str, int len) 
    to_num:
        push    ebp
        mov     ebp, esp
        ; i = DWORD [ebp-4]
        sub     esp, 4
        push    ebx
        push    esi
        push    edi
        
        mov     eax, 0
        mov     ebx, 0
        mov     edi, [ebp+8]        ; edi chua dia chi cua str
        mov     esi, [ebp+12]       ; esi chua do dai cua str
        mov     dword ptr [ebp-4], 1; i = 1
        
        LOOP1:
            movzx   ebx, byte ptr [edi]
            sub     bl, 30h
            add     eax, ebx
            cmp     dword ptr [ebp-4], esi              ; Kiem tra xem i == do dai cua str ko
            je      DONE1
            
            imul    eax, 10             ; nhan ket qua voi 10 de cong them phan du tiep theo
            inc     dword ptr [ebp-4]   ; i++
            inc     edi                 ; + 1 vao dia chi cua edi de lay phan tu tiep theo trong mang
            jmp     LOOP1         
          
        DONE1:     
            pop     edi
            pop     esi
            pop     ebx
            mov     esp, ebp
            pop     ebp
            ret     12
            
; tuong duong voi: int str_len(char *str)
str_len:
	push	ebp
	mov	ebp, esp
	push	esi
	push	ecx

	mov	esi, [ebp+8]
	mov	eax, 0
	mov	ecx, 0
	LOOP_str_len:
		cmp	byte ptr [esi+ecx], 13
		je	done_str_len
                cmp     byte ptr [esi+ecx], 0
                je      done_str_len
		inc	ecx
		inc	eax
		jmp	LOOP_str_len

	done_str_len:
		pop	ecx
		pop	esi
		mov	esp, ebp
		pop	ebp
		ret	4

; In ra so, tuong duong voi: void print_num(int num, handle *stdOutHandle)
print_num:
        push    ebp
        mov     ebp, esp
        ; i = dword [ebp-4]
        ; j = dword [ebp-8]
        ; divsion = dword [ebp-12]
        ; remainder = dword [ebp-16]
        ; tempStr = BYTE [ebp-26]
        ; result = BYTE [ebp-36]
        ; written = dword [ebp-40]
        sub     esp, 36
        ; Luu ebx, esi, edi, ecx
        push    ebx
        push    esi
        push    edi
        push    ecx
        
        mov     esi, dword ptr [ebp+8]
        mov     dword ptr [ebp-12], esi
        mov     ecx, 10
        mov     dword ptr [ebp-4], 0
        mov     dword ptr [ebp-8], 0
        
        cmp     dword ptr [ebp-12], 0       ; Kiem tra xem no co phai so 0 khong
        je      ZERO_NUMBER
         
        LOOP2:
            cmp     dword ptr [ebp-12], 0
            je      PRINT_NUMBER
            
            mov     edx, 0
            mov     eax, dword ptr [ebp-12]
            div     ecx                     ; chia eax cho 10 va luu phan du vao edx
                                            ; va thuong vao eax
        
            mov     dword ptr [ebp-16], edx         ; edx la phan du
            mov     dword ptr [ebp-12], eax         ; eax la thuong so
            add     dword ptr [ebp-16], 30h         ; bien doi phan du thanh chu cai tuong ung
            movzx   ebx, byte ptr [ebp-16]          ; Luu mot byte remainder vao ebx,
                                                    ; tat ca bit 8->32 deu bang 0
            mov     ecx, dword ptr [ebp-4]          ; tam thoi luu ecx = i
            mov     byte ptr [ebp-26+ecx], bl       ; luu byte do vao tempStr[i]
            
            mov     ecx, 10                         ; Tra lai ecx = 10
            inc     dword ptr [ebp-4]               ; i++
            jmp     LOOP2
           
        ; Dao nguoc tempStr cho ket qua vao result
        PRINT_NUMBER:
            cmp     dword ptr [ebp-4], 0            ; Kiem tra xem i = 0
            je      DONE2
            mov     ecx, dword ptr [ebp-4]          ; tam thoi luu ecx = i
            movzx   ebx, byte ptr [ebp-26+ecx-1]    ; luu ebx = tempStr[i-1]
            mov     ecx, dword ptr [ebp-8]          ; Luu ecx = j
            mov     byte ptr [ebp-36+ecx], bl       ; Luu result[j] = tempStr[i-1]
            dec     dword ptr [ebp-4]
            inc     dword ptr [ebp-8]
            jmp     PRINT_NUMBER
         
        ; Tra ve ket qua la '0' va in ra
        ZERO_NUMBER:
            mov     byte ptr [ebp-36], '0'           ; Luu result[0] = '0'
            inc     dword ptr [ebp-8]
            
        ; gio result chua ket qua cuoi cung, in ra
        DONE2:
            ; Them vao cuoi ket qua ket thuc string
            mov     ecx, dword ptr [ebp-8]           
            mov     [ebp-36+ecx], 0h
            
            ; In ra ket qua
            lea     eax, [ebp-36]
            mov     edx, [ebp+12]
            lea     ebx, [ebp-40]
            push    0               ; reserve
            push    ebx
            push    ecx
            push    eax
            push    edx
            call    WriteConsole
            
            pop     ecx
            pop     edi
            pop     esi
            pop     ebx
            mov     esp, ebp
            pop     ebp
            ret     8
            
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
; copy string(char *src, char *des)
copy_string:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    
    mov     esi, [ebp+8]
    mov     edi, [ebp+12]

    Lx:
        mov     al,[esi]          
        mov     [edi],al           
        inc     esi              
        inc     edi
        cmp     byte ptr [esi],0   ; Check for null terminator
        jne     Lx                 ; loop if not null
    
    ; copy not NULL terminate
    mov     al, [esi]
    mov     [edi], al
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp  
    ret     8