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
    caption         BYTE    "Ket qua la", 0

    input_num1      BYTE    "Nhap vao so thu nhat: ", 0
    input_num1_len  DWORD   $-input_num1
    input_num2      BYTE    "Nhap vao so thu hai: ", 0
    input_num2_len  DWORD   $-input_num2

    msg2            BYTE    "Lua chon cua ban:", 0
    msg_len2        DWORD   $-msg2
    msg             BYTE    "Cac lua chon bao gom", 13, 10, 0
    msg_len         DWORD   $-msg
    
    lua_chon1       BYTE    "1. Cong", 13, 10, 0
    lua_chon_len1   DWORD   $-lua_chon1
    lua_chon2       BYTE    "2. Tru", 13, 10, 0
    lua_chon_len2   DWORD   $-lua_chon2
    lua_chon3       BYTE    "3. Nhan", 13, 10, 0
    lua_chon_len3   DWORD   $-lua_chon3
    lua_chon4       BYTE    "4. Chia", 13, 10, 0
    lua_chon_len4   DWORD   $-lua_chon4
    
    error           BYTE    "loi khong co gia tri"
    error_len       DWORD   $-error
    
    jump_table      DWORD   case1, case2, case3, case4

.data?
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?
    bufferRead      DWORD   ?
    written         DWORD   ?
    
    choice          DWORD   ?
    num1            DWORD   ?
    num2            DWORD   ?


.code
start:
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax
    
    ; Nhap vao so thu nhat
    push    stdOutHandle
    mov     eax, input_num1_len
    push    eax
    lea     eax, input_num1
    push    eax
    call    print
    
    lea     eax, num1
    push    stdInHandle
    push    eax
    call    get_num
    
    ; Nhap vao so thu hai
    push    stdOutHandle
    mov     eax, input_num2_len
    push    eax
    lea     eax, input_num2
    push    eax
    call    print
    
    lea     eax, num2
    push    stdInHandle
    push    eax
    call    get_num
    
    
    ; in ra cac lua chon
    push    stdOutHandle
    mov     eax, msg_len
    push    eax
    lea     eax, msg
    push    eax
    call    print
    
    ; in ra lua chon 1
    push    stdOutHandle
    mov     eax, lua_chon_len1
    push    eax
    lea     eax, lua_chon1
    push    eax
    call    print
    
    ; in ra lua chon 2
    push    stdOutHandle
    mov     eax, lua_chon_len2
    push    eax
    lea     eax, lua_chon2
    push    eax
    call    print
    
    ; in ra lua chon 2
    push    stdOutHandle
    mov     eax, lua_chon_len3
    push    eax
    lea     eax, lua_chon3
    push    eax
    call    print
    
    ; in ra lua chon 2
    push    stdOutHandle
    mov     eax, lua_chon_len4
    push    eax
    lea     eax, lua_chon4
    push    eax
    call    print 
    
    ; in ra chon lua chon
    push    stdOutHandle
    mov     eax, msg_len2
    push    eax
    lea     eax, msg2
    push    eax
    call    print
    
    lea     eax, choice
    push    stdInHandle
    push    eax
    call    get_num
    
    mov     edx, dword ptr [num2]
    push    edx
    mov     edx, dword ptr [num1]
    push    edx
    mov     edx, dword ptr [choice]
    push    edx
    call    switch_case
    
    push    stdOutHandle
    push    eax
    call    print_num
    
    xor     eax, eax
    ret

; tuong duong voi: int switch_case(int choice, int num1, int num2)
switch_case:
    push    ebp
    mov     ebp, esp
    sub     esp, 20
    push    ebx
    push    esi
    push    edi
    
    mov     edi, dword ptr [ebp+8]
    mov     eax, dword ptr [ebp+12]
    mov     ebx, dword ptr [ebp+16]
    sub     edi, 1
    cmp     edi, 3
    ja      short default_case
    jmp     dword ptr [jump_table + edi*4]
    case1:
        add     eax, ebx
        jmp     short DONE_switch_case
    case2:
        sub     eax, ebx
        jmp     short DONE_switch_case
    case3:
        imul    ebx
        jmp     short DONE_switch_case
    case4:
        cdq
        idiv    ebx
        jmp     short DONE_switch_case
    
    default_case:
        push    stdOutHandle
        push    error_len
        lea     edx, error
        push    edx
        call    print
    
    DONE_switch_case:
        pop     edi
        pop     esi
        pop     ebx
        mov     esp, ebp
        pop     ebp
        ret     12
end start