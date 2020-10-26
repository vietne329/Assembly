.386
.model flat, stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib



WinMain proto

.const
    
    IDM_in     equ 52
    IDM_out    equ 25
    lenMaxText equ 1000
.data

    msgEr db "Er",0
	
    class_name db "Simple Win lass",0
	win_name   db "Reverse Text",0

    class_in   db "EDIT",0                                      ;predefined control class
    class_out  db "STATIC",0                                    ;predefined control class

    tbuffer    db lenMaxText dup(0)


.data?

	hInstance  dd ?
    
    hParent    dd ?
    hIn        dd ?
    hOut       dd ?
	

	CommandLine dd ?

	wc WNDCLASSEX <?>
	msg MSG <?>


.code
start:

	invoke GetModuleHandle, 0
	mov    hInstance,eax

	call WinMain
 
	invoke ExitProcess, eax



WinMain proc

	mov   wc.cbSize, SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra, 0
	mov   wc.cbWndExtra, 0
	
	push  hInstance
	pop   wc.hInstance
	
	mov   wc.hbrBackground, COLOR_WINDOW + 1
	mov   wc.lpszMenuName, 0
	mov   wc.lpszClassName, OFFSET class_name
	
	push IDI_APPLICATION
	push 0
	call LoadIcon

	
	mov   wc.hIcon, eax
	mov   wc.hIconSm, eax
	
	push IDC_ARROW
	push 0
	call LoadCursor
	mov  wc.hCursor, eax

	lea ecx, wc
	push ecx
	call RegisterClassEx
    
    or eax,eax
    jz @endE


    push 0                          ;lpParam
    push hInstance                      ;handle instance of the module to be associated with the window.
	push 0                                ;hMenu: hande to a menu  -> child-window indentifier
    push 0                                 ;handle to the parent or owner window
    push 300    
    push 800                                ; nwith  
    push 200                                ;y upper-left conner
    push 300                                ;x upper-left conner
    push WS_OVERLAPPEDWINDOW or WS_THICKFRAME           ;win style
    push offset win_name
    push offset class_name
    push 0                              ;extend window style
    call CreateWindowEx

    mov hParent, eax
    or eax,eax
    jz @endL
	
;create input box
    push 0                            ;lpParam
    push hInstance                        ;handle instance of the module to be associated with the window.
	push IDM_in                       ;hMenu: hande to a menu  -> child-window indentifier
    push hParent                       ;handle to the parent or owner window
    push 50    
    push 760                           ; nwith  
    push 50                            ;y upper-left conner
    push 20                            ;x upper-left conner
    push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL            ;win style
    push 0
    push offset class_in
    push WS_EX_CLIENTEDGE                              ;extend window style
    call CreateWindowEx

    mov hIn, eax
    
;create output box
    
    push 0                                 ;lpParam
    push hInstance                             ;handle instance of the module to be associated with the window.
	push IDM_out                           ;hMenu: hande to a menu  -> child-window indentifier
    push hParent                           ;handle to the parent or owner window
    push 50   
    push 760                                ; nwith  
    push 150                                 ;y upper-left conner
    push 20                                 ;x upper-left conner
    push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL            ;win style
    push 0
    push offset class_out
    push WS_EX_CLIENTEDGE                              ;extend window style
    call CreateWindowEx

    mov hOut,eax


	push SW_SHOWDEFAULT
	push hParent
	call ShowWindow
	
	push hParent
	call UpdateWindow

;loop message

@L1:
		
		push 0
		push 0
		push 0
		push offset msg
		call GetMessage
		
		or eax,eax
		jz @endL
		
		
		push offset msg
		call TranslateMessage
		
		push offset msg
		call DispatchMessage
		
		jmp @L1
				
@endL:	
		mov eax, msg.wParam
		ret
@endE:
        push MB_OK
        push 0
        push 0
        push 0
        call MessageBox
        ret
		
WinMain endp




WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	
	
		cmp uMsg,WM_DESTROY									
		je  @quit							;if user closes windows

        cmp uMsg,WM_COMMAND
        je @WMCOMMAND

        push lParam
		push wParam
		push uMsg
		push hWnd
		call DefWindowProc					;default message processing
		
		ret

@WMCOMMAND:

        mov eax,wParam                      ;low word of wParam stores menu identify
        cmp ax, IDM_in                         
        jne @return

        ;get input text
        push lenMaxText
        push offset tbuffer
        push hIn 
        call GetWindowText

        mov esi, offset tbuffer
        call reverseText

        push offset tbuffer
        push hOut
        call SetWindowText
        ret

		
@quit:
		push 0
		call PostQuitMessage				;quit application
		xor eax,eax

@return:
		ret 	
WndProc endp

;--------------reverse input text
;in: esi point to start of tbuffer
;out: e
reverseText proc 

        mov edi,esi
        xor eax,eax
        dec edi

@end_text:
        inc edi
        mov al, byte ptr [edi]
        or al,al
        jnz @end_text
        dec edi                                                 ;edi points to end char (not null) of text
        
@swap:
        cmp esi,edi
        jge @fi

        mov al, byte ptr [edi]
        xchg al, byte ptr [esi]
        mov byte ptr [edi],al

        inc esi
        dec edi
        jmp @swap
@fi:
        ret

reverseText endp

end start