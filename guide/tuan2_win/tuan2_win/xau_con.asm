.386
.model flat, stdcall
option casemap : none

include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?
    
    S_str        BYTE    101     DUP(?)
    C_str        BYTE    11      DUP(?)
    output_str   BYTE    1024    DUP(?)
    result       DWORD   1       DUP(?)
    result_pos   DWORD   101     DUP(?)
    written      DWORD   1       DUP(?)
    bufferRead   DWORD   ?
    
    newLine      DB     13, 10
    seperator    DB     " "
    i            DW     0

.code
start:
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax
        
    ; Nhap vao xau S
    lea     eax, bufferRead
    lea     ebx, S_str
    push    0
    push    eax
    push    100
    push    ebx
    push    stdInHandle
    call    ReadConsole
    
    ; Nhap vao xau C
    lea     eax, bufferRead
    lea     ebx, C_str
    push    0
    push    eax
    push    10
    push    ebx
    push    stdInHandle
    call    ReadConsole
    
    ; Tinh so luong xuat hien xcua xau co
    ; dong thoi luu cac vi tri do vao mang result_pos
    lea     eax, C_str
    lea     edx, S_str
    lea     ebx, result_pos
    push    edx
    push    eax
    push    ebx
    call    count
    
    ; In ra man hinh
    mov     result, eax
    ;In ra dong dau tien
    mov     edx, stdOutHandle
    push    edx
    push    eax
    call    print_num
    
    ; In ra lui vao dong tiep theo
    lea     eax, newLine
    mov     edx, stdOutHandle
    push    edx
    push    2
    push    eax
    call    print
    
    ; In ra dong thu hai
    mov     dword ptr [i], 0
    mov     eax, dword ptr [result]
    LOOP_print:
        mov     ecx, dword ptr [i]                    ; Lay vi tri cua i de so sanh
        cmp     ecx, dword ptr [result]               ; Kiem tra xem da den so cuoi chua
        je      DONE
        mov     dword ptr [i], ecx                    ; Luu lai vi tri cua i
        
        ; In ra so thu tu
        mov     edx, dword ptr [result_pos]
        mov     eax, stdOutHandle
        push    eax
        push    edx
        call    print_num
        
        ; in ra dau cach
        lea     eax, seperator
        mov     ebx, stdOutHandle
        push    ebx
        push    1
        push    eax
        call    print
        
        inc     dword ptr [i]
        jmp     LOOP_print
    DONE:
        ; thoat chuong trinh
        mov     ebx, 0
        xor     eax, eax
        ret
    
    
; tuong duong voi void print(char *str, int len, handle stdOutHandle)
print:
        push    ebp
        mov     ebp, esp
 
        mov     edx, [ebp+16]
        mov     edi, dword ptr [ebp+8] ; luu *str
        mov     esi, dword ptr [ebp+12]; luu len

        push    0
        push    written
        push    esi
        push    edi
        push    edx
        call    WriteConsole
    
        mov     esp, ebp
        pop     ebp
        ret     12
count:
	push	  ebp
	mov       ebp, esp
	; [ebp-4]: count
	; [ebp-8]: count_pos
	sub       esp, 8
	push	  esi
	push	  edi
	push	  ebx

	mov	  dword ptr [ebp-4], 0
	mov	  dword ptr [ebp-8], 0
	mov	  edi, [ebp+16]		; edi chua vi tri cua xau
	mov	  esi, [ebp+12]		; esi chua vi tri cua xau con can tim
	mov	  ecx, -1

	LOOP_count:
		inc	ecx

		cmp	byte ptr [edi+ecx], 13  ; Kiem tra xem da den cuoi tu do chua
		je	done_count

		lea	ebx, [edi+ecx]		; push xau do ke tu vi tri thu ecx vao stack
		push	ebx
		lea	ebx, [esi]		; push xau con vao stack
		push	ebx
		call	compare_string          ; kiemt ra xem 2 str do co ban gnhua ko

		cmp	eax, 0                  ; neu vi tri do no bang nhau thi chay equal_str
		je	equal_str
		jmp	LOOP_count

	equal_str:
		inc	dword ptr [ebp-4]
		mov	edx, dword ptr [ebp-8]

		mov	ebx, [ebp+8]			; ebx chua vi tri dau tien cua list mang de ghi vao ket qua
		mov	dword ptr [ebx+4*edx], ecx
		inc	dword ptr [ebp-8]

		jmp	LOOP_count

	done_count:
		mov	eax, [ebp-4]			; Luu ket qua vao eax de tra ve

		pop	ebx
		pop	edi
		pop	esi
		mov	esp, ebp
		pop	ebp
		ret	12

; tuong duong voi: int compare_string(char *str1, char *str2)
compare_string:
	push	ebp
	mov	ebp, esp
	; [ebp-4] lenA: do dai cua xau con
	sub    esp, 4
	push	esi
	push	edi
	push	ebx
	push	ecx

	mov	edi, [ebp+12] ; edi chua vi tri cua xau
	mov	edx, [ebp+8]  ; esi chua vi tri cua xau con can tim

	; Lay do dai cua xau con
	push	edx
	call	str_len
	mov	dword ptr [ebp-4], eax
	mov	ecx, 0
	LOOP_compare:
                mov     esi, edx
                lodsb
		cmp	al, 13
		je	done_compare
                mov     edx, esi
                mov     bl, al              ; tam thoi luu dl la byte cua xau S

                mov     esi, edi            ; Luu 
                lodsb
		cmp	al, 13
		je	done_compare
                mov     edi, esi            ; tra lai vi tri edx moi
                
		cmp	bl, al              ; Kiem tra xem 2 byte do co bang nhau khong
		jne	done_compare
		inc	ecx
		jmp	LOOP_compare

	done_compare:
		mov	eax, -1				; tra ve ket qua eax la khong bang nhau
                mov     edx, dword ptr [ebp-4]
		cmp	ecx, edx
		jne	ret_compare
		mov	eax, 0				; tra ve ket qua la bang nhau
		
	ret_compare:
		pop	ecx
		pop	ebx
		pop	edi
		pop	esi
		mov	esp, ebp
		pop	ebp
		ret	12

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
            push    0               ; reserve
            push    written
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
		cmp		byte ptr [esi+ecx], 13
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
end start