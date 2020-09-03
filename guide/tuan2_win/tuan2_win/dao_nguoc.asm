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
    newLine      DB     13, 10
    seperator    DB     " "
    i            DW      0

.data?
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?
    bufferRead      DWORD   ?
    len_str         DWORD   ?
    written         DWORD   ?

    input_str       BYTE    256     DUP(?)
.code
start:
    ;write your code here
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax
    
    lea     eax, bufferRead
    lea     ebx, input_str
    push    0
    push    eax
    push    256
    push    ebx
    push    stdInHandle
    call    ReadConsole
    
    lea     edx, input_str
    push    edx
    call    str_len
    mov     len_str, eax
    
    lea     edx, input_str
    push    eax
    push    edx
    call    reverse_str
    
    ; In ra ket qua
    add	    dword ptr [len_str], 2  ; them vao 2 ky tu 13, 10 vao cuoi
    mov     edx, stdOutHandle
    mov     esi, len_str
    lea     edi, input_str
    push    edx
    push    esi
    push    edi
    call    print
    
    ; Ket thuc chuong trinh
    xor eax, eax
    ret
    
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
