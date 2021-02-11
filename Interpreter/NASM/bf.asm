;
;			Copyright 2021 Makariy  
;
;	Redistribuition and use of this code is 
; totaly allowed without any permissions of an author 
; or of his fiduciary. The Interpreter is not
; protected from any errors and we don't provide
; any guarantee of it's correct work. Any questions,
; issues or modifications we'll be very exited to 
; find it out in the comments 
;									Makariy




;
; In BrainFuck language there are 8 commands:
;
;	. - Print the value of the current element 
;		in array 
;	, - Enter the value from command line to 
;		the current element in the array 
;	+ - Add 1 to the value of the current element  
;		in array 
;	- - Subtract 1 to the value of the current element  
;		in array 
;	< - Move pointer to the current element in array to the 
;		next element 
;	> - Move pointer to the current element in array to the
;		past element 
;	[ - Start the cycle if the value of the current element 
;		in array is not zero if it is zero, then go the ] caracter 
;	] - Go back to the start of cycle 
;
;	In this interpreter nested cycles are allowed! 	
;


;
; 	By personal ideas I've introduced comments:
;
; There are two types of comments supported:
;	'#' comments - one line comments. All the caracters on the line	
;		after '#' symbol are not interpreting 
;	'/' comments - are multi line comments. All the caracters 
;		between the first and the second '/' are not interpreting  
;




extern exit 
extern printf
extern scanf
extern fopen, fclose, fgetc, fseek, ftell, fgets
extern fopen, fclose, fgetc, fseek, ftell
extern __getmainargs


section .data
	int_format: db "%d", 10, 0				; Format for printing integer with new line 
	int_format_command_comma: db "%d", 0	; Format for printing integer WITHOUT new line 
	FileName: db "main.bf", 0				; File name of the file to interpret (can be 
											; changed with command line arguments)
	ReadMode: db "r", 0						; Mode for C function to only read the file 
	Command:  db ".", 0						; Now executed command 


section .bss
	Arr: resd 30000				; An array for modifications 
	FileHandler: resb 4			; Pointer to a file provided by the C function fopen 
	buf: resd 4					; Buffer to get the command line arguments 
	argc: resd 4					; Count of command line arguments passed 
	argv: resb 256				; The arguments from command line 
	CommandCommaNumber: resb 32	; The number entered from the keyboard during 
								; command ',' is executed 
	Index: resb 4				; Index if the array of the application (Arr)
	FileEndIndex: resb 4		; Index of the end of the file 

section .text
	_main:
		
	    enter 0,0
	    pusha

	    ; Set up array index (Index) 
	    mov dword [Index], 1

	    ; Get the arguments from the command line  
	    push buf 
	    push argv 
	    push argc 
	    call __getmainargs

	   ; add esp, 12
	   ; __stdcall, doesn't need to clear the stack


	    push ReadMode 

	    cmp dword [argc], 1			; If there ARE arguments in the command line  
	    jnz not_standart_file_name 	; then execute not standart file name 

	    jz standart_file_name 		; Execute standart file name 
	  
	 not_standart_file_name:
	  	mov eax, [argv]
	  	push dword [eax+4]
	  	jmp call_open_file

	 standart_file_name:
	  	push FileName

	 call_open_file: 
	    call fopen 
	    mov [FileHandler], eax 
	    add esp, 16



	    ; Finding the file end index 

	    ; Set file pointer to the next element 
	    push 2	; SEEK_END 
	    push 0  ; Point to set 
	    push dword [FileHandler] 
	    call fseek
	    add esp, 12

	    ; Get end of file index number  
	    push dword [FileHandler]
	    call ftell 
	    mov [FileEndIndex], eax 
	    add esp, 4

	    ; After finding the end of file setting the pointer back 
	    ; Set the file pointer back to the start 
	    push 0
	    push 0
	    push dword [FileHandler]
	    call fseek 
	    add esp, 12


	    ; Start interpreting the file 
	    call start 
	    call finish_exit 

	start:
		; Get cycle start index number 
	    push dword [FileHandler]
	    call ftell 
	    add esp, 4

;-----------------------
	    push eax  	; Save cycle start index in stack 
;-----------------------

	    ; This cycle is beeing executed while it gets the 
	    ; symbols from the file 
	   while_enter_char:

	    ; Get current position in the file 
		push dword [FileHandler]
		call ftell
		add esp, 4 

		; If the current position is the end of the file 
		cmp dword [FileEndIndex], eax 
		jz finish_exit   	; Then exit the programm



	    call get_char ; Get symbol from the file 
		; Start comparing 
		  cmp DWORD [Command], "."
		  jz command_dot
		  cmp DWORD [Command], ","
		  jz command_comma
		  cmp DWORD [Command], "<"
		  jz command_right
		  cmp DWORD [Command], ">"
		  jz command_left
		  cmp DWORD [Command], "+"
		  jz command_add
		  cmp DWORD [Command], "-"
		  jz command_sub
		  cmp DWORD [Command], "["
		  jz command_while_start 
		  cmp DWORD [Command], "]"
		  jz command_while_end

		  ; Comments 
		  cmp DWORD [Command], "#"
		  jz enter_comment_line 
		  cmp DWORD [Command], "/"
		  jz enter_comment_multi_line


		jmp while_enter_char   ; Continue the cycle 


	; Pass all the caracters between '/' caracters
	enter_comment_multi_line:
		call get_char

		cmp DWORD [Command], "/"
		jnz enter_comment_multi_line

		jmp while_enter_char

	; Pass all the line after '#' caracter 
	enter_comment_line:
		call get_char
	    
		push dword [FileHandler]
		call ftell
		add esp, 4 
		cmp dword [FileEndIndex], eax 
		jz finish_exit   	

		cmp DWORD [Command], 10
		jnz enter_comment_line

		jmp while_enter_char


	; The operator '['
	command_while_start:

		mov ecx, [Index]
	  	imul ecx, 4
	  	cmp DWORD [Arr+ecx], 0
	  	jz jump_cycle_end

	  	call start 
		jmp while_enter_char


	; Operator ']'
	command_while_end:


		mov ecx, [Index]
	  	imul ecx, 4
	  	cmp DWORD [Arr+ecx], 0
	  	jz return 	; If the value in at the array (Arr)
	  				; indexed by index (Index) is 0,
	  				; then return from function and pop the 
	  				; cycle end index 
	  	jnz seek  	; Else: set the pointer in file to the 
	  				; cycle start 

	  return:
	    add esp, 4	; Clear the cycle start index pushed before
	  	ret

	  seek:
	  	pop eax
		push eax

		push 0
		push eax
		push DWORD [FileHandler]
		call fseek
		add esp, 12
		jmp while_enter_char


	; Skips all between operator '[' and ']' included 
	jump_cycle_end:
		call get_char

		cmp DWORD [Command], "]"
		jnz jump_cycle_end

		jmp while_enter_char

	; Operator '.'
	; Print the value of current element in the array (Arr)
	command_dot:

		mov ebx, [Index]
		imul ebx, 4
		mov eax, DWORD [Arr+ebx]

		push eax
	    push int_format
	    call printf
	    add esp, 8

		jmp while_enter_char


	; Operator ','
	; Gets integer from the keyboard 
	; and sets the value of the element 
	; on current index (Index) in the array (Arr)
	command_comma:
		push CommandCommaNumber
		push int_format_command_comma
		call scanf
		add esp, 8 

		mov ecx, [Index]
		imul ecx, 4

		mov eax, dword [CommandCommaNumber]
		mov DWORD [Arr+ecx], eax

		jmp while_enter_char


	; Operator '+'
	command_add:
		mov ecx, [Index]
	  	imul ecx, 4
		add DWORD [Arr+ecx], 1
		jmp while_enter_char
	

	; Operator '-'
	command_sub:
		mov ecx, [Index]
	  	imul ecx, 4
		sub DWORD [Arr+ecx], 1
		jmp while_enter_char


	; Operator '<'
	command_right:
		add DWORD [Index], 1
		jmp while_enter_char


	; Operator '>'
	command_left:
		sub DWORD [Index], 1
		jmp while_enter_char


	; Get symbol from file 
	get_char:
	    push dword [FileHandler]
	    call fgetc
	    add esp, 4
	    mov [Command], eax

	    ret


	; Exit the application 
	finish_exit:
	    popa


	    ; Close the file 
	    push dword [FileHandler]
	    call fclose 
	    add esp, 4

	    mov eax, 0
	    mov ebx, 0

	    push eax  	; Push the return code 
	    call exit	; Exit the application 
