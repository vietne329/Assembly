.386
.model flat, stdcall
option casemap: none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.data
	message1 db "Input something please: ",0
	message2 db "You just input: ",0
	size_message1 dw $-message1
	
	buffer byte 32 dup(0)
	num_buffer dword ?
	byteRead dword ?

	stdOutHandle HANDLE 0
	stdInHandle  HANDLE ?
.code
	start:
	;Print message1 on Window Console	
	push offset message1
	call StdOut

	;save handle from eax to variables.
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov stdInHandle, eax
	
	push STD_OUTPUT_HANDLE
     call GetStdHandle
     mov stdOutHandle, eax

		
	;get input's user 
	lea ebx, offset buffer
	lea eax, byteRead
	push 0
	push eax
	push 32
	push ebx
	push stdInHandle
	call ReadConsole

	;Show content just input on MessageBox
	lea eax, message2
	lea ebx, buffer
	push MB_OK
	push eax
	push ebx
	push 0
	call MessageBox

	;Exit program
	xor eax,eax
	ret

	end start