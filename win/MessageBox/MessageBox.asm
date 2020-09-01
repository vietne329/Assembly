INCLUDE Irvine32.inc

.data
captionW		BYTE "WARNING",0
warningMsg	BYTE	"Warning! Your access is denied!",0

captionQ		BYTE "Question",0
questionMsg	BYTE "Are you want to monney?"
			BYTE 0dh,0h,"Do you coutinue ?",0

captionC		BYTE "Information",0
infoMsg		BYTE "Select Yes to save a backup file "
			BYTE "before continuing,",0dh,0ah
			BYTE "or click Cancel to stop the operation",0

captionH		BYTE "Cannot View User List",0
haltMsg		BYTE "This operation not supported by your user account. ",0

.code
main PROC

	;Display Exclamation icon with OK button
		INVOKE MessageBox, NULL, ADDR warningMsg, ADDR captionW, MB_OK + MB_ICONEXCLAMATION
	
	;Display Question icon with Yes/NO buttons
	INVOKE MessageBox, NULL, ADDR questionMsg, ADDR captionQ, MB_YESNO + MB_ICONQUESTION

	;interpret the button click by user
	cmp eax,IDYES			;YES button click?
	; Display Information icon with Yes/No/Cancel buttons
	INVOKe MessageBox , NULL, ADDR infoMsg, ADDR captionC, MB_YESNOCANCEL + MB_ICONINFORMATION + MB_DEFBUTTON2

	;Display stop icon with OK button
		INVOKE MessageBox, NULL , ADDR haltMsg, ADDR captionH , MB_OK + MB_ICONSTOP
	exit
main ENDP
END main





