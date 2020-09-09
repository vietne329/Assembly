.386
.model flat,stdcall
option casemap: none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.data
message1 db "Input first number:",10,13,0
message2 db "Input second number:",10,13,0

captionBox db "Result",0

stdInHandle HANDLE ?
stdOutHandle HANDLE ?

num1Str BYTE 32 DUP(?)
num2Str BYTE 32 DUP(?)

byteWrite dword ?
byteRead dword ?

.code
	start:
	;show message number1 to user
	push offset message1
	call StdOut

	;get stdInHandle from eax and save to variable
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov stdInHandle, eax

	;get data from user 
	lea eax, byteRead
	lea ebx, num1Str
	push 0
	push eax
	push 32
	push ebx
	push stdInHandle
	call ReadConsole

	;show message number2 to user
	push offset message2
	call StdOut

	;get data from user
	lea eax,byteRead
	lea ebx,num2Str
	push 0
	push eax
	push 32
	push ebx
	push stdInHandle
	call ReadConsole

	lea eax,num1Str
	push eax
	call strLen

	sub eax, 2		;subtract: 0xa 0xd
	lea ebx, num1Str
	push eax
	push ebx
	call to_num
	mov ebx,eax

	lea eax,num2Str
	push eax
	call strLen
	sub eax,2			;subtract: 0xa 0xd	
	lea esi,num2Str

	push eax
	push esi
	call to_num

	;add esi + eax  = num1Str + num2Str
	add eax,ebx

	;print result
	push eax
	call print_num

	xor eax,eax
	ret

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
            ret     8
     
     ; In ra so, tuong duong voi: void print_num(int num)
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
            movzx   ebx, byte ptr [ebp-26+ecx-1]   ; luu ebx = tempStr[i-1]
            mov     ecx, dword ptr [ebp-8]          ; Luu ecx = j
            mov     byte ptr [ebp-36+ecx], bl       ; Luu result[j] = tempStr[i-1]
            dec     dword ptr [ebp-4]
            inc     dword ptr [ebp-8]
            jmp     PRINT_NUMBER
            
        ; gio result chua ket qua cuoi cung, in ra
        DONE2:
            ; Them vao cuoi ket qua ket thuc string
            mov     ecx, dword ptr [ebp-8]           
            mov     [ebp-36+ecx], 0h
            
            ; In ra ket qua
            lea     eax, [ebp-36]
            lea     ebx, captionBox
            push    MB_OK
            push    ebx
            push    eax
            push    0
            call    MessageBox
            
            pop     ecx
            pop     edi
            pop     esi
            pop     ebx
            mov     esp, ebp
            pop     ebp
            ret     4
    
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