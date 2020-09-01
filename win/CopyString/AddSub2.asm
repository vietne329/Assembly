TITLE Add and Subtract, Version 2         (AddSub2.asm)

; This program adds and subtracts 32-bit integers
; and stores the sum in a variable.

INCLUDE Irvine32.inc

.data
val1     dword  50
val2     dword  30
val3     dword  10
finalVal dword  ?

.code
main PROC

	mov	eax,val1			; start with 10000h
	add	eax,val2			; add 40000h
	sub	eax,val3			; subtract 20000h
	mov	finalVal,eax		; store the result (30000h)
	call	DumpRegs			; display the registers

	exit
main ENDP
END main