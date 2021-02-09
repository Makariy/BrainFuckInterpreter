
extern exit 
extern printf
extern scanf
extern fopen, fclose, fgetc, fseek, ftell 
extern __getmainargs


section .data
	int_format: db "%d", 10, 0
	int_format_command_comma: db "%d", 0
	FileName: db "main.bf", 0
	ReadMode: db "r", 0
	Command:  db ".", 0


section .bss
	Arr resd 30000
	FileHandler resb 4
	buf resd 4
	argc resd 4
	argv resb 256
	CommandCommaNumber resb 32
	Index: resb 4
	FileIndex: resb 4

section .text
	_main:
	    enter 0,0
	    pusha

	    mov dword [Index], 1
	    mov dword [FileIndex], 0

	    push buf 
	    push argv 
	    push argc 
	    call __getmainargs

	    push ReadMode 

	    cmp dword [argc], 1
	    jnz not_standart_file_name
	    jz standart_file_name
	  
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

	   while_enter_char:

	    call get_char
		
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

	    call exit


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

	command_while_end:
		push 0
		push DWORD [FileIndex]
		push DWORD [FileHandler]
		call fseek
		jmp while_enter_char

	jump_cycle_end:
		call get_char
		cmp DWORD [Command], "]"
		jnz jump_cycle_end

		jmp while_enter_char

	command_dot:
		call print_int
		jmp while_enter_char

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

	command_add:
		mov ecx, [Index]
	  	imul ecx, 4
		add DWORD [Arr+ecx], 1
		jmp while_enter_char

	command_sub:
		mov ecx, [Index]
	  	imul ecx, 4
		sub DWORD [Arr+ecx], 1
		jmp while_enter_char


	command_right:
		add DWORD [Index], 1
		jmp while_enter_char

	command_left:
		sub DWORD [Index], 1
		jmp while_enter_char

	get_char:
		;Get a caracter from file 
		enter 0, 0
		pusha 

	    push dword [FileHandler]
	    call fgetc
	    add esp, 4
	    mov [Command], eax

	    popa
	    leave 
	    ret


	print_int:
		enter 0,0
		pusha
		mov ebx, [Index]
		imul ebx, 4
		mov eax, DWORD [Arr+ebx]
		push eax
	    push int_format
	    call printf
	    add esp, 8
	    popa 
	    leave 
	    ret

	print_char:
		enter 0,0
		pusha 
		push Command
		call printf 
		add esp, 4
		popa 
		leave 
		ret

	finish_exit:
	    popa
		call fclose
		call exit