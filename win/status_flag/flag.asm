;addtion, subtraction and Flags
INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
Rval SDWORD ?
Xval SDWORD 26
Yval SDWORD 30
Zval SDWORD 40

.code
main PROC
	;INC and DEC
	mov ax, 1000h
	inc ax
	dec ax

	;Expression : Rval = -Xval + (Yval - Zval)
	mov eax, Xval
	neg eax
	mov ebx, Yval
	sub ebx, Zval
	add eax, ebx
	mov Rval, eax

	; Zero flag example:
	mov cx, 1
	sub cx, 1
	mov ax, 0FFFFh
	inc ax

	; Sign flag example:8
	mov cx, 0
	sub cx, 1
	mov ax, 7FFFh
	add ax, 2 

	;Carry flag example:
	mov al, 0FFh
	sub al,1

	;Overflow flag example:
	mov al, +127
	add al, 1
	mov al, -128
	sub al, 1

	INVOKE ExitProcess,0
main ENDP
END main