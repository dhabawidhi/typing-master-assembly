%ifndef display_story_asm
%define display_story_asm

%assign max_terminal	80
%assign sys_write		4
%assign std_out			1

display:
	call get_1_word_backward_set
	mov eax, [one_word]
	mov ebx, [sementara]
	cmp eax, ebx
	jae first_display
	jmp edit_cursor

first_display:
	;set display_cursor
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, display_cursor
	mov edx, len_display_cursor
	int 0x80

	mov edx, 81		;for counter
	mov eax, [sementara]
	push eax
	mov dword [sementara2], eax

l_first_display:
	dec edx
	cmp byte [file_str + eax + edx], ' '
	jne l_first_display
	; push edx		;used by second_display
	mov ebx, edx
	add ebx, [sementara]
	mov dword [sementara], ebx

	mov eax, sys_write
	mov ecx, file_str
	pop ebx
	cmp ebx, 0
	je nope
inc_ebx:			;begining condition
	inc ebx
nope:
	add ecx, ebx
	mov ebx, std_out
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, cr
	mov edx, len_cr
	int 0x80

second_display:
	mov edx, 81		;for counter
	mov ebx, [sementara]
	inc ebx
l_second_display:
	dec edx
	cmp byte [file_str + ebx + edx], ' '
	jne l_second_display

	mov eax, sys_write
	mov ecx, file_str
	add ecx, ebx
	mov ebx, std_out
	int 0x80

	;print type here :
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, msg_type
	mov edx, len_msg_type
	int 0x80

edit_cursor:
	;convert coordinat into string, used by move_cursor1
	mov eax, [one_word]
	mov ebx, [sementara2]
	cmp ebx, 0
	je nope2
	inc ebx
nope2:
	sub eax, ebx
	add	eax, 1
	xor ecx, ecx	;for counter
	jmp null_

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
	add edx, 4 		;for length move_cursor1

	;move_cursor1
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, move_cursor1
	int 0x80
	;save_cursor
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, save_cursor
	mov edx, len_save_cursor
	int 0x80
	;magenta_bg
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, magenta_bg
	mov edx, len_magenta_bg
	int 0x80
	;print highlight text
	push ebp
	mov ebp, [one_word]
	mov eax, sys_write
	mov ebx, std_out
	mov edx, -1
get_1_word_forward:
	inc	edx
	cmp	byte [file_str + ebp + edx], ' '
	jne	get_1_word_forward
	mov ecx, file_str
	add	ecx, ebp
	pop	ebp
	int 0x80
	;default_bg
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, default_bg
	mov edx, len_default_bg
	int 0x80
	jmp kembali

	;print correct or wrong word
get_1_word_backward_set:
	cmp dword [one_word], 0
	je ret_edit_cursor
	;restore_cursor
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, restore_cursor
	mov edx, len_restore_cursor
	int 0x80
	cmp dword [b_or_s], 0
	je red_color
green_color:
	;set fr_green
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, fr_green
	mov edx, len_fr_green
	int 0x80
	jmp eksekusi
red_color:
	;set fr_red
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, fr_red
	mov edx, len_fr_red
	int 0x80
	jmp eksekusi
eksekusi:
	;print fr_green text
	push ebp
	mov ebp, [one_word]
	sub ebp, 1
	mov eax, sys_write
	mov ebx, std_out
	mov edx, -1
get_1_word_backward:
	inc	edx				;length
	cmp ebp, 0
	je 	first_sentences		
	dec ebp
	cmp	byte [file_str + ebp], ' '
	jne	get_1_word_backward
add_ebp:
	inc ebp
first_sentences:
	mov ecx, file_str
	add	ecx, ebp
	int 0x80
	pop	ebp
	;set fr_default
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, fr_default
	mov edx, len_fr_default
	int 0x80
ret_edit_cursor:
	ret

kembali:
	;set to cursor_type
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, cursor_type
	mov edx, len_cursor_type
	int 0x80

	ret

%endif