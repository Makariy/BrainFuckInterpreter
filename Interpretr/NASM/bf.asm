;
;			Copyright 2021 Makariy  
;	Redistribuition and use of this code is 
; totaly allowed without any permissions of an author 
; or of his fiduciary. The Interpretr is not
; protected from any errors and we don't provide
; any guarantee of it's correct work. Any questions,
; issues or modifications we'll be very exited to 
; listen to you.
;
;									Makariy







extern exit 
extern printf
extern scanf
extern fopen, fclose, fgetc, fseek, ftell, feof 
extern __getmainargs


section .data
	int_format: db "%d", 10, 0				; Format for printing integer with new line 
	int_format_command_comma: db "%d", 0	; Format for printing integer WITHOUT new line 
	FileName: db "main.bf", 0				; File name of the file to interpret (can be 
											; changed with command line arguments)
	ReadMode: db "r", 0						; Mode for C function to only read the file 
	Command:  db ".", 0						; Now executed command 


section .bss
	Arr resd 30000				; An array for modifications 
	FileHandler resb 4			; Pointer to a file provided by the C function fopen 
	buf resd 4					; Buffer to get the command line arguments 
	argc resd 4					; Count of command line arguments passed 
	argv resb 256				; The arguments from command line 
	CommandCommaNumber resb 32	; The number entered from the keyboard during 
								; command ',' is executed 
	Index: resb 4				; Index if the array of the application (Arr)
	FileIndex: resb 4			; Current index in the oppened file 
	FileEndIndex: resb 4		; Index of the end of the file 

section .text
	_main:
	    enter 0,0
	    pusha

	    ; Set up all indexes 
	    mov dword [Index], 1
	    mov dword [FileIndex], 0

	    ; Get the arguments from the command line  
	    push buf 
	    push argv 
	    push argc 
	    call __getmainargs

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


	    ; Set file pointer to the next element 
	    push 2	; SEEK_END 
	    push 0  ; Point to set 
	    push dword [FileHandler] 
	    call fseek
	    add esp, 12

	    ; Get file end number 
	    push dword [FileHandler]
	    call ftell 
	    mov [FileEndIndex], eax 
	    add esp, 4

	    ; Set the file pointer back to the start 
	    push 0
	    push 0
	    push dword [FileHandler]
	    call fseek 
	    add esp, 12


	    ; This cycle is beeing executed while it gets the 
	    ; symbols from the file 
	   while_enter_char:

	    call get_char ; Get symbol from the file 
		
		; Start comparing 
		cmp DWORD [Command], " "
		jz while_enter_char
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

		
		; Get current position in the file 
		push dword [FileHandler]
		call ftell
		add esp, 4 

		; If the current position is the end of the file 
		cmp dword [FileEndIndex], eax 
		jz finish_exit   	; Then exit the programm

		jmp while_enter_char   ; Continue the cycle 


	; The operator '['
	command_while_start:
		mov ecx, [Index]
	  	imul ecx, 4
	  	cmp DWORD [Arr+ecx], 0
	  	jz jump_cycle_end

		push DWORD [FileHandler]
		call ftell
		sub eax, 1		
		mov DWORD [FileIndex], eax

		jmp while_enter_char


	; Operator ']'
	command_while_end:
		push 0
		push DWORD [FileIndex]
		push DWORD [FileHandler]
		call fseek
		jmp while_enter_char

	; Skips all between operator '[' and ']' included 
	jump_cycle_end:
		call get_char
		cmp DWORD [Command], "]"
		jnz jump_cycle_end

		jmp while_enter_char

	; Operator '.'
	command_dot:
		call print_int
		jmp while_enter_char

	; Operator ','
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


	; Print the value of current element in the array (Arr)
	print_int:
		mov ebx, [Index]
		imul ebx, 4
		mov eax, DWORD [Arr+ebx]

		push eax
	    push int_format
	    call printf
	    add esp, 8

	    ret


	; Exit the application 
	finish_exit:
	    popa

	    mov eax, 1
	    mov ebx, 0

	    call exit