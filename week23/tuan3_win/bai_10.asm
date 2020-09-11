.386
.model flat, stdcall
option casemap : none

include D:\viettel\tuan3_win\read_write.asm
include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

.data
    nl          BYTE    13, 10
    sep         BYTE    ' '
    msg         BYTE    'nhap vao so luong cua mang: ', 0
    msg_len     EQU     $-msg
    msg2        BYTE    'nhap vao cac gia tri cua mang (vi du: 1,2,3): ', 0
    msg_len2    EQU     $-msg2

.data?
    stdInHandle     HANDLE  ?
    stdOutHandle    HANDLE  ?
    len_arr         DWORD   ?
    len_num1        DWORD   ?
    arr_num_str     BYTE    300     DUP(?)
    result_even     DWORD   ?
    result_odd      DWORD   ?

.code
start:
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax

    lea     ebx, msg
    push    stdOutHandle
    push    msg_len
    push    ebx
    call    print
    
    lea     ebx, len_arr
    push    stdInHandle
    push    ebx
    call    get_num
    
    lea     ebx, msg2
    push    stdOutHandle
    push    msg_len2
    push    ebx
    call    print
    
    lea     ebx,  arr_num_str
    push    stdInHandle
    push    300
    push    ebx
    call    get
    
    mov     eax, dword ptr [len_arr]
    lea     ebx, arr_num_str
    push    eax
    push    ebx
    call    calculate_sum
    mov     dword ptr [result_even], eax
    mov     dword ptr [result_odd], edx
    
    mov     eax, dword ptr [result_even]
    push    stdOutHandle
    push    eax
    call    print_num
    
    lea     ebx, sep
    push    stdOutHandle
    push    1
    push    ebx
    call    print
    
    mov     ebx, dword ptr [result_odd]
    push    stdOutHandle
    push    ebx
    call    print_num
    
    lea     ebx, nl
    push    stdOutHandle
    push    2
    push    ebx
    call    print
    
    ; End process
    xor eax, eax
    ret
    
; tuong duong voi: calculate_sum(char *str, int len)
calculate_sum:
    push    ebp
    mov     ebp, esp
    sub     esp, 38     ; ebp-22: temp_str_num
                        ; ebp-26: i
                        ; ebp-30: sum_even
                        ; ebp-34: sum_odd
                        ; ebp-38: reserve_num
    push    ebx
    push    esi
    push    edi
    
    
    ; khoi diem temp_str_num ve 0x0
    mov     al, 0
    lea     edi, [ebp-22]
    mov     ecx, 22
    rep     stosb
    
    mov     dword ptr [ebp-30], 0   ; sum_even = 0
    mov     dword ptr [ebp-34], 0   ; sum_odd = 0
    mov     dword ptr [ebp-26], 0   ; i = 0
    mov     esi, dword ptr [ebp+8]  ; esi = *str
    xor     ecx, ecx                ; ecx = 0
    
    find_str:   
        lodsb                       ; al = esi++
        cmp     al, ','
        je      short turn_to_num
        cmp     al, 13
        je      short turn_to_num
        mov     byte ptr [ebp-22+ecx], al
        inc     ecx
        jmp     short find_str
        
    turn_to_num:
        mov     dword ptr [ebp-38], ecx     ; tam thoi luu ecx vao reserve_num
        lea     edi, [ebp-22]
        push    ecx
        push    edi
        call    to_num
         
        mov     ecx, dword ptr [ebp-26]
        mov     ebx, eax
        push    ebx
        call    check_odd_even
        
        test    eax, eax
        jz      short sum_even
        add     dword ptr [ebp-34], ebx
        jmp     short continue_transformation
        
        sum_even:
            add     dword ptr [ebp-30], ebx

         continue_transformation:
            ; Cho temp_str_num tro ve gom cac gia tri 0
            mov     al, 0
            lea     edi, [ebp-22]
            mov     ecx, 22
            rep     stosb
            
            inc     dword ptr [ebp-26]          ; i++
            mov     ecx, dword ptr [ebp-26]     ; ecx = i
            cmp     ecx, dword ptr [ebp+12]     ; kiem tra xem ecx = len_arr
            je      DONE_calc
            xor     ecx, ecx
            jmp     find_str
            
    DONE_calc:
        mov     eax, dword ptr [ebp-30]         ; eax = sum_even
        mov     edx, dword ptr [ebp-34]         ; edx = sum_odd
        pop     edi
        pop     esi
        pop     ebx
        mov     esp, ebp
        pop     ebp
        ret     8
        
; tuong duong voi: int check_odd_even(int num)
; neu la chan se tra ve 0
; neu la le se tra ve 1
check_odd_even:
    push    ebp
    mov	    ebp, esp
    push    ebx
    push    esi
    push    edi
    
    xor     edi, edi
    mov	    ebx, 2
    mov	    eax, dword ptr [ebp+8]
    cdq
    idiv    ebx
    test    edx, edx			 ; kiem tra xem num % 2 == 0
    jz	    short DONE_check_odd_even    ; dung: tra ve eax = 0
    inc	    edi			         ; sai: tra ve eax = 1
    
    DONE_check_odd_even:
        mov     eax, edi
        pop	edi
        pop	esi
        pop	ebx
        mov	esp, ebp
        pop	ebp
        ret	4
    
end start
