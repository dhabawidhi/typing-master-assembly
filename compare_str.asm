%ifndef compare_str_asm
%define compare_str_asm

%assign max_char_str	20

compare:
	;requires set before start comparing
	xor eax, eax
	xor ebx, ebx
	jmp get_len_1_word

get_len_1_word:
	mov eax, [index]
	cmp byte [file_str + eax + ebx], ' '
	je mov_str
	inc ebx						;ebx contain length of 1 word
	jmp get_len_1_word

mov_str:
	mov eax, ebx				;eax contain length of 1 word for used for comparing
	mov ecx, ebx
	mov esi, file_str
	add esi, [index]
	add ebx, [index]
	mov dword [index], ebx
	mov edi, temp_file

	rep	movsb

	mov ebx, [index]
	inc ebx						;to set pointer to the next char after ' '
	mov dword [index], ebx

	;now temp_file contain sub-string of file_str
	;and eax contain length of temp_file
	;first, count length of temp_type, then remove char newline and set null
	mov ecx, 0

get_len_type:
	cmp byte [temp_type + ecx], 10
	je remove
	inc ecx						;ebx contain length of 1 word
	jmp get_len_type

remove:
	mov byte [temp_type + ecx], 0		;change newline with null

	;start comparing temp_file with temp_type
	cmp eax, ecx
	je start_comparing
	jmp not_equal

start_comparing:
	mov esi, temp_file
	mov edi, temp_type
	rep cmpsb

	jecxz equal
	jmp not_equal

equal:
	xor ebx, ebx
	mov ecx, max_char_str
	;clear memory temp_file before return
null_equal:
	mov byte [temp_file + ebx], 0
	inc ebx
	loopnz null_equal
	;return
	;eax contain length of correct character
	mov ebx, eax				;ebx used for shift right story_display
	add	eax, [wpm]
	inc eax					;update wpm with space
	mov dword [wpm], eax
	add	ebx, [one_word]
	inc ebx						;update one_word with space
	mov dword [one_word], ebx	;update one_word
	mov dword [b_or_s], 1 		;used by coloring green
	add dword [correct_words], 1 	;inc correct_words
	ret

not_equal:
	xor ebx, ebx
	mov ecx, max_char_str
	;clear memory temp_file before return
null_not_equal:
	mov byte [temp_file + ebx], 0
	inc ebx
	loopnz null_not_equal
	;return
	add	eax, [one_word]
	inc eax						;update one_word with space
	mov dword [one_word], eax	;update one_word
	;eax set to 0 because temp_file and temp_type are not equal
	mov eax, 0
	mov dword [b_or_s], 0 		;used by coloring red
	add dword [wrong_words], 1 	;inc wrong_words
	ret

%endif