; Print hello World #1 (hello.asm)
; This program calls the following Win32 Console functions:

INCLUDE Irvine32.inc
.data
endl EQU <0dh,0ah> ; end of line sequence
message LABEL BYTE
BYTE "Hello World!",endl
messageSize DWORD ($ - message)
consoleHandle HANDLE 0 ; handle to standard output device
bytesWritten DWORD ? ; number of bytes written

.code
main PROC
; Get the console output handle:

INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle,eax

; Write a string to the console:
INVOKE WriteConsole,
consoleHandle, ; console output handle
ADDR message, ; string pointer
messageSize, ; string length
ADDR bytesWritten, ; returns num bytes written
0 ; not used 
INVOKE ExitProcess,0
main ENDP
END main