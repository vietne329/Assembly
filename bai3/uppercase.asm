section .data
str1 db "hello my name is Viet"
len equ $ -str2

section .bss
str2 resb 32

section .text
	global _start

_start:

	mov ecx,len
	mov esi,str1
	mov edi,str2

loop:
	lodsb
	cmp al,0x20
	je change
	mov bl,0x20
	
change:
