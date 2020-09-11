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
    caption         db      "Ket qua"
    init_2          BYTE    '1', 0
    init_1          BYTE    '0', 0

.data?
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?
    bufferRead      DWORD   ?
    written         DWORD   ?
    result_addr     BYTE    22      DUP(?)
    
    num_str         DWORD   ?

    
.code
start:
    ;write your code here
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax
    
    lea     eax, num_str
    push    stdInHandle
    push    eax
    call    get_num
    
    lea     ebx, init_2
    push    ebx
    lea     ebx, init_1
    push    ebx
    push    eax
    call    Fibonacci
    
    lea     eax, result_addr
    push    eax
    call    str_len
    
    lea     ebx, result_addr
    push    stdOutHandle
    push    eax
    push    ebx
    call    print
    
    ; ket thuc chuong trinh
    xor     eax, eax
    ret

; tuong duong voi: int fibonacci(int n, int a, int b)
Fibonacci:
	push	ebp
	mov	ebp, esp
        sub     esp, 52     ; ebp-22: byte: temp_num1
                            ; ebp-26: int: len_a
                            ; ebp-30: int: len_B
                            ; ebp-52: byte: temp_num2
	push	ebx
	push	esi
	push	edi

        lea     eax, [ebp-22]
        push    eax
        push    dword ptr [ebp+12]
        call    copy_string
        
        lea     eax, [ebp-52]
        push    eax
        push    dword ptr [ebp+16]
        call    copy_string

	LOOP_fib:
		mov	esi, [ebp+8]	; esi = n
		lea	edi, [ebp-22]	; edi = a
		lea	ebx, [ebp-52]	; ebx = b

		cmp	esi, 0
		je	esi_equal_0
		cmp	esi, 1
		je	esi_equal_1

                ; lay do dai xau a
                push    edi
                call    str_len
                mov     dword ptr [ebp-26], eax
                
                ; lay do dai xau b
                push    ebx
                call    str_len
                mov     dword ptr [ebp-30], eax
                
                ; dao nguoc xau a
                push    dword ptr [ebp-26]
                push    edi
                call    reverse_str
                
                ; dao nguoc xau b
                push    dword ptr [ebp-30]
                push    ebx
                call    reverse_str
                
                lea     eax, result_addr
                push    edi         ; xau a
                push    ebx         ; xau b
                push    eax         ; temp_num
                call    big_add
                
                lea     eax, [ebp-52]
                push    eax
                call    str_len
                
                lea     ebx, [ebp-52]
                push    eax
                push    ebx
                call    reverse_str
                
                dec     dword ptr [ebp+8]
                ; copy_string(ebp-52, ebp-22)
                lea     eax, [ebp-22]
                lea     ebx, [ebp-52]
                push    eax
                push    ebx
                call    copy_string
                ; copy_string(result_addr, ebp-52)
                lea     ebx, [ebp-52]
                lea     eax, result_addr
                push    ebx
                push    eax
                call    copy_string
                jmp     LOOP_fib

	esi_equal_0:
		mov	eax, dword ptr [ebp+12]
		jmp	DONE_fib
	esi_equal_1:
		mov	eax, dword ptr [ebp+16]
	DONE_fib:
		pop	edi
		pop	esi
		pop	ebx
		mov	esp, ebp
		pop	ebp
		ret	12
end start
