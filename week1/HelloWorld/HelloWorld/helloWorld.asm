.386
.model flat,stdcall
option casemap: none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib

.data
	label_box db "Hello Program",0
	content_box db "Hello World!",0

.code
	message:
	push MB_OK				;set behavior as a button OK
	lea eax, label_box			;transfer address of label_box to eax register
	lea ebx, content_box		;transfer address of content_box to ebx register

	push eax					;push content of eax onto stack (box_content)
	push ebx					;push content of ebx onto stack continously (box_title)
			
	push 0					;handle to window (can be null)
		
	call MessageBox			;call MessageBox function with above parameters

	ret						;return this function
	end message				
