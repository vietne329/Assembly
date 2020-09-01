; Reverse string (reverse.asm)

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

.data
aName BYTE "abcdefghijklmnoq",0
nameSize = ($ - aName) - 1

.code
main PROC
	;push the name on stack
	mov ecx, nameSize
	mov esi, 0
L1:
	movzx eax,aName[esi]
	push eax
	inc esi
	loop  L1

	;Pop the name from stack, in reverse, and store in aName array
	mov ecx, nameSize
	mov esi,0
L2:
	pop eax
	mov aName[esi],al
	inc esi
	loop L2

	INVOKE ExitProcess, 0
main ENDP
END main