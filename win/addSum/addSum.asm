TITLE Add and Subtract, Version 2         (AddSub2.asm)

; This program adds and subtracts 32-bit integers
; and stores the sum in a variable.

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
	sum DWORD 0
.code
main PROC
  	mov eax,5
	add eax,6
	mov sum,eax

	INVOKE ExitProcess,0
main ENDP
END main
