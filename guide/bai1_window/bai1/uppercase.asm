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
    caption         db      "In ra ket qua", 13, 10, 0
   
    stdInHandle     HANDLE  ?                   ; stdInHandle se chua duoc thiet lap
    buffer          BYTE    32  DUP(?)          ; buffer se gom 32 byte va
                                                ; cac byte do chua duoc thiet lap
    bufferRead      DWORD   ?                   ; khong thiet lap  
    bufferWrite     DWORD   ?
    
.code
    start:
        ;write your code here
        push    STD_INPUT_HANDLE
        call    GetStdHandle                    ; lay stdin handle va luu vao eax
        mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
        lea     ebx, buffer
        lea     eax, bufferRead
        push    0
        push    eax
        push    32
        push    ebx
        push    stdInHandle
        call    ReadConsole
        
        lea     ebx, buffer
        push    ebx
        call    strLen
        mov     ebx, eax
        lea     eax, buffer                     ; Luu dia chi buffer vao eax de 
                                                ; nhap vao ham Uppercase
        push    eax                             ; char *str
        push    ebx                             ; int len
        call    UpperCase
    
        lea     ebx, caption
        lea     eax, buffer
        push    MB_OK
        push    ebx
        push    eax
        push    0
        call    MessageBox
        
        xor     eax, eax
        ret

    ; tuong duong voi void UpperCase(char *str)
    UpperCase:
        ; Setup cho stack
        push    ebp
        mov     ebp, esp           
        ; Su dung cac bien esi, ecx va edi
        push    ecx             ; nen ta luu vao stack de ve sau khoi phuc lai
        push    edi
        push    ebx
        
        mov     esi, [ebp+8]
        mov     edi, [ebp+12]
        mov     ecx, -1
        L1:
            inc     ecx                         ; ecx++
            
            mov     bl, byte ptr [edi+ecx]          ; Luu vao cl mot phan tu cua str
            cmp     bl, 0Dh                        ; Kiem tra xem da den cuoi chua
            je      DONE
            sub     bl, 97                          ; Kiem tra xem byte do thuoc a->z khong
            cmp     bl, 26
            ja      L1
            
            add     bl, 65                      ; Tru di cho 32 de bien no thanh phan 
            mov     byte ptr [edi+ecx], bl      ; str[i] = bl
            jmp     L1
     
        DONE:
            pop     ebx
            pop     edi
            pop     ecx
            mov     esp, ebp
            pop     ebp
            ret     8                           ; Don 8 byte dau vao cho ham nay
        
   strLen:
        push    ebp
        mov     ebp, esp
        sub     esp, 4
        push    ebx
        push    esi
        
        mov     esi, [ebp+8]
        mov     eax, 0
        LOOP3:
            mov     bl, [esi]
            cmp     bl, 0
            je      DONE3
            inc     eax
            inc     esi
            jmp     LOOP3
            
        DONE3:
            pop     esi
            pop     ebx
            mov     esp, ebp
            pop     ebp
            ret     4
end start