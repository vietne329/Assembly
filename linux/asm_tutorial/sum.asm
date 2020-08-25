section .bss
	res resb 2

section .data
	msg db "Sum is: "
	len equ $-msg
section .text
	global _start
_start:
	mov eax, '3'
	sub eax, '0'

	mov ebx, '2'
	sub ebx, '0'

	add eax,ebx
	add eax,'0'

	mov [res], eax

	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,len
	int 0x80

	mov eax,4
	mov ebx,1
	mov ecx,res
	mov edx,2
	int 0x80

	mov eax,1
	int 0x80

 
