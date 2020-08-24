section .data
	;declare system call number
	sys_exit equ 1
	sys_write equ 4
	sys_read equ 3
	stdin equ 0
	stdout equ 1

	;message for user
	msg1 db "Enter the first number: ",0xA,0xD
	len1 equ $ - msg1
	msg2 db "Enter the second number: ",0xA,0xD
	len2 equ $ - msg2

	msg3 db "Sum: "
	len3 equ $ - msg3

section .bss

	num1 resw 10
	num2 resw 10
	res resw 10

section .text
	global _start

_start:
	;message 1
	mov eax, sys_write
	mov ebx, stdout
	mov ecx, msg1
	mov edx, len1
	int 0x80

	;input first number
	mov eax, sys_read
	mov ebx, stdin
	mov ecx, num1
	mov edx, 10
	int 0x80

	;message 2
	mov eax, sys_write
	mov ebx, stdout
	mov ecx, msg2
	mov edx, len2
	int 0x80

	;input second number
	mov eax, sys_read
	mov ebx, stdin
	mov ecx, num2
	mov edx, 10
	int 0x80

	;message result
	mov eax, sys_write
	mov ebx, stdout
	mov ecx, msg3
	mov edx, len3
	int 0x80

	mov eax,[num1]
	sub eax,'0'

	mov ebx,[num2]
	sub ebx,'0'

	;add eax and ebx
	add eax, ebx
	add eax,'0'

	;store the sum into memory has name: res
	mov [res], eax

	;print the sum
	mov eax,sys_write
	mov ebx,stdout
	mov ecx,res
	mov edx,10
	int 0x80

	;exit the program
	mov eax,1
	int 0x80
