
%assign sys_write		4
%assign std_out			1

section .data
	move_cursor1 db 27, '[8;00H', 0
	len_move_cursor1 equ $-move_cursor1
	save_cursor db 27, '[s', 0
	len_save_cursor equ $-save_cursor
	restore_cursor db 27, '[u', 0
	len_restore_cursor equ $-restore_cursor
	default_bg db 27, '[49m', 0
	len_default_bg equ $-default_bg
	magenta_bg db 27, '[46m', 0
	len_magenta_bg equ $-magenta_bg
	msg db 'hallo', 10, 0
	len_msg equ $-msg
	decimal dd 10
	file_str db 'abcde fghij klmno pqrst uvwxy', 0
section .bss
	one_word resd 1

section .text
	global main
main:
	mov 	eax, [one_word]
	add		eax, 5
	mov 	dword [one_word], eax
	;save_cursor
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, save_cursor
	mov 	edx, len_save_cursor
	int 	0x80
	;convert coordinat into string, used by move_cursor1
	mov 	eax, [one_word]
	xor 	ecx, ecx	;for counter
	jmp 	null_

null_:
	xor edx, edx	;require set before using div
	div dword [decimal]
	push edx		;simpan 1 digit (lsb ke msb) ke stack
	inc ecx			;for counter in lanjut
	cmp eax, 0
	je lanjut
	jmp null_
lanjut:
	xor edx, edx	;for length of temp_str
lanjut_1:
	pop ebx
	add bl, 48
	mov byte [move_cursor1 + 4 + edx], bl		;change coordinat
	inc edx
	loopnz lanjut_1
	mov byte [move_cursor1 + 4 + edx], 'H'
	inc edx
	mov byte [move_cursor1 + 4 + edx], 0
	; dec edx
	add edx, 4 		;for length move_cursor1

	;move_cursor1
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, move_cursor1
	; mov 	edx, len_move_cursor1
	int 	0x80
	;magenta_bg
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, magenta_bg
	mov 	edx, len_magenta_bg
	int 	0x80
	
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, file_str
	add 	ecx, 6
	mov 	edx, 5
	int 	0x80
	;default_bg
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, default_bg
	mov 	edx, len_default_bg
	int 	0x80
	;restor_cursor
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, restore_cursor
	mov 	edx, len_restore_cursor
	int 	0x80

	jmp 	main
exit:
	mov eax, 1
	mov ebx, 0
	int 0x80