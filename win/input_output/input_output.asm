; Description: input string and print this string on console. Window API 32bit

 INCLUDE Irvine32.inc
 BufSize = 80

.data
  endl EQU <0dh,0ah>            ; end of line 

;messages for getting input
 fName LABEL BYTE
BYTE "Enter your first name", endl
 fNameSize DWORD ($-fName)

;output handlers
 consoleHandle HANDLE 0     ; handle to standard output device
 bytesWritten  DWORD ?      ; number of bytes written

;input handlers
 buffer BYTE BufSize DUP(?)
 stdInHandle HANDLE ?
 bytesRead   DWORD ?

.code
 main PROC
; Get the console output handle:
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
  mov consoleHandle,eax

; Write a string to the console:
INVOKE WriteConsole,
  consoleHandle,        ; console output handle
  ADDR fName,           ; string pointer
  fNameSize,            ; string length
  ADDR bytesWritten,    ; returns num bytes written
  0                     ; not used

; Get handle to standard input
INVOKE GetStdHandle, STD_INPUT_HANDLE
   mov   stdInHandle,eax

; Wait for user input
 INVOKE ReadConsole, stdInHandle, ADDR buffer,
  BufSize, ADDR bytesRead, 0

; Write a string to the console:
INVOKE WriteConsole,
  consoleHandle,        ; console output handle
  ADDR buffer,          ; string pointer
  bytesRead,            ; string length
  ADDR bytesWritten,    ; returns num bytes written
  0 

INVOKE ExitProcess,0
   main ENDP
  END main