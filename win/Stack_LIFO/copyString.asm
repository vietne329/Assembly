; Copying a String (CopyStr.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
.data
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP(0)
.code
main PROC
mov esi,0 ; index register
mov ecx,SIZEOF source ; loop counter
L1:
mov al,source[esi] ; get a character from source
mov target[esi],al ; store it in the target
inc esi ; move to next character


loop L1 ; repeat for entire string
invoke ExitProcess,0
main ENDP
END main