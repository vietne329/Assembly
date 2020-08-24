section .data
	text1 db "Input something please: "
	len equ $ - text1
	text2 db "You just typing: "
	len2 equ $ - text2

section .bss
	input resb 32
section .text
	global _start
_start:
	call _printText1
	call _getInput
	call _printText2
	call _printInput

	;exit program
	mov eax,1
	int 0x80
_printText1:
	mov eax,4
	mov ebx,1
	mov ecx,text1
	mov edx,len
	int 0x80
	ret
_printText2:
	mov eax,4
	mov ebx,1
	mov ecx,text2
	mov edx,len2
	int 0x80
	ret
_printInput:
	mov eax,4
	mov ebx,1
	mov ecx,input
	mov edx,32
	int 0x80
	ret
_getInput:
	mov eax,3
	mov ebx,2
	mov ecx,input
	mov edx,32
	int 0x80
	ret
