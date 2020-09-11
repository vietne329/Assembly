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
    caption     BYTE    'Ket qua', 0
    msg         BYTE    'nhap vao so luong cua mang: ', 0
    msg_len     EQU     $-msg
    msg2        BYTE    'nhap vao cac gia tri cua mang: ', 0
    msg_len2    EQU     $-msg2

.data?
    stdInHandle     HANDLE  ?
    stdOutHandle    HANDLE  ?
    len_arr         DWORD   ?
    len_num1        DWORD   ?
    arr_num_str     BYTE    300     DUP(?)
    result_min      DWORD   ?
    result_max      DWORD   ?

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
    call    calculate_min_max
    mov     dword ptr [result_min], eax
    mov     dword ptr [result_max], edx
    
    mov     eax, dword ptr [result_min]
    push    stdOutHandle
    push    eax
    call    print_num
    
    lea     ebx, sep
    push    stdOutHandle
    push    1
    push    ebx
    call    print
    
    mov     ebx, dword ptr [result_max]
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

; tuong duong voi: calculate_min_max(char *str, int len)
calculate_min_max:
    push    ebp
    mov     ebp, esp
    sub     esp, 38     ; ebp-22: temp_str_num
                        ; ebp-26: i
                        ; ebp-30: result_min
                        ; ebp-34: result_max
                        ; ebp-38: reserve_num
    push    ebx
    push    esi
    push    edi
    
    
    ; khoi diem temp_str_num ve 0x0
    mov     al, 0
    lea     edi, [ebp-22]
    mov     ecx, 22
    rep     stosb
    
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
        test    ecx, ecx
        jz      short initialise
        
        cmp     eax, dword ptr [ebp-30]         ; kiem tra xem eax < result_min
        jae     short check_max                 ; sai kiem tra phan tiep result_max
        mov     dword ptr [ebp-30], eax         ; dung: result_max = eax
        
        check_max:
        cmp     eax, dword ptr [ebp-34]         ; kiem tra xem eax > result_max
        jbe     short continue_transformation   ; sai: tiep tuc lap
        mov     dword ptr [ebp-34], eax         ; dung: result_max = eax
        jmp     short continue_transformation
        
        initialise:
            mov     dword ptr [ebp-34], eax
            mov     dword ptr [ebp-30], eax
            
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
        mov     eax, dword ptr [ebp-30]
        mov     edx, dword ptr [ebp-34]
        pop     edi
        pop     esi
        pop     ebx
        mov     esp, ebp
        pop     ebp
        ret     8
    
    
end start
