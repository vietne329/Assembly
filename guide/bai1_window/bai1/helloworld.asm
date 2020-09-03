.386
.model flat, stdcall
option casemap: none

include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib

.data
    szCaption   db  'Hello', 0
    szText      db  'Hello, World!', 13, 10, 0

.code
    start:
            ; Goi ham messagebox trong kernal
            ; NULL: handle cho window
            ; ADDR szText dia chi cua szText de in ra trong chuong trinh
            ; ADDR szCaption dia chi de in ra tieu de cho chuong trinh
            ; MB_OK chuong trinh chi bao gom mot nut ok
            push    MB_OK
            lea     eax, szText
            lea     ebx, szCaption
            push    ebx
            push    eax
            push    0
            call    MessageBox
            
            xor     eax, eax
            ret
    end start