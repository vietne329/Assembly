.386
.model flat, stdcall
option casemap: none


include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib


.data
    caption         BYTE      "In ra ket qua", 13, 10, 0

    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    stdOutHandle    HANDLE  ?
    buffer          BYTE    32  DUP(0)          ; buffer se gom 32 byte va
                                                ; cac byte do chua duoc thiet lap
    bufferRead      DWORD   ?                   ; khong thiet lap  
    bufferWrite     DWORD   ?
    
.code
    start:
        ;write your code 
        push    STD_INPUT_HANDLE
        call    GetStdHandle                    ; lay stdin handle va luu vao eax
        mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
        push    STD_OUTPUT_HANDLE
        call    GetStdHandle
        mov     stdOutHandle, eax
    
        lea     ebx, buffer
        lea     eax, bufferRead
        push    0
        push    eax
        push    32
        push    ebx
        push    stdInHandle
        call    ReadConsole
    
        lea     eax, caption
        lea     ebx, buffer
        push    MB_OK
        push    eax
        push    ebx
        push    0
        call    MessageBox
        
        ; Thoat chuong trinh
        xor     eax, eax
        ret
    end start