; print Hello world on the console window
include irvine32.inc  ;using library of window pi 32bit

.data

	endl EQU <0dh,0ah>			; endline and linefeed
	message LABEL BYTE 
	BYTE "Hello World",endl	; save string "Hello World" to message variable.
	messageSize DWORD ($-message)			; init and save size of string "message".

	consoleHandle HANDLE 0	; handle to standard ouput device
	byteWritten DWORD ?		

.code
main PROC
	;Get the console output handle
	INVOKE GetStdHandle , STD_OUTPUT_HANDLE
	mov consoleHandle, eax
	
	;Write  string to the console
	INVOKE WriteConsole,
		consoleHandle,			;console output handle
		ADDR message,			;string pointer
		messageSize,			;string length
		ADDR byteWritten,		;return num bytes written
		0					;not used, standard is 0

		INVOKE ExitProcess, 0

main ENDP
END main