section .data
	text db "Hello World",0xA,0xD
	len equ $ - text

section .text
	global _start

_start:
	mov eax,4
	mov ebx,1
	mov ecx,text
	mov edx,len
	int 0x80

	mov eax,1
	int 0x80
