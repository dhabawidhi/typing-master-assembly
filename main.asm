%include "print_info.asm"
%include "convert_str_int.asm"
%include "convert_int_str.asm"
%include "set_alarm.asm"
%include "bogo_random.asm"
%include "compare_str.asm"
%include "display_story.asm"
%include "measure_wpm.asm"
%include "clear_screen.asm"

%assign no_args			1
%assign	max_args		2
%assign sys_read		3
%assign sys_write		4
%assign sys_open		5
%assign sys_close		6
%assign sys_signal		48

%assign std_in			0
%assign std_out			1
%assign sig_alarm		14

%assign digit			4
%assign default_time	60
%assign max_file_str	1000
%assign max_char_str	20
%assign max_terminal	80

section .data
	msg_welcome db 'welcome.txt', 0
	msg_error db 'error.txt', 0
	len_info equ 150
	msg_type db 10, 10, 'Type here:', 0
	len_msg_type equ $-msg_type
	msg_wpm db 'Words per minute (WPM)	: ', 0
	len_msg_wpm equ $-msg_wpm
	msg_keystrokes db 'Keystrokes 		: ', 0
	len_msg_keystrokes equ $-msg_keystrokes
	msg_correct_words db 'Correct words 		: ', 0
	len_msg_correct_words equ $-msg_correct_words
	msg_wrong_words db 'Wrong words 		: ', 0
	len_msg_wrong_words equ $-msg_wrong_words
	decimal dd 10
	basis_wpm dd 12
	cr db 10
	len_cr equ $-cr
	leftresult db ' (', 0
	len_leftresult equ $-leftresult
	midresult db '|', 0
	len_midresult equ $-midresult
	rightresult db ')', 0
	len_rightresult equ $-rightresult

	;ansi code
	erase_line db 27, '[K', 0
	len_erase_line equ $-erase_line
	cursor_type db 27, '[11;12H', 0
	len_cursor_type equ $-cursor_type
	move_cursor1 db 27, '[8;00H', 0
	len_move_cursor1 equ $-move_cursor1
	save_cursor db 27, '[s', 0
	len_save_cursor equ $-save_cursor
	restore_cursor db 27, '[u', 0
	len_restore_cursor equ $-restore_cursor
	default_bg db 27, '[49m', 0
	len_default_bg equ $-default_bg
	fr_default db 27, '[39m', 0
	len_fr_default equ $-fr_default
	magenta_bg db 27, '[46m', 0
	len_magenta_bg equ $-magenta_bg
	display_cursor db 27, '[8;00H', 27, '[K', 27, '[9;00H', 27, '[K', 27, '[8;00H', 0
	len_display_cursor equ $-display_cursor
	fr_green db 27, '[32m', 0
	len_fr_green equ $-fr_green
	fr_red db 27, '[31m', 0
	len_fr_red equ $-fr_red

	;list file
	p1 db 'paragraph/p1.txt', 0
	p2 db 'paragraph/p2.txt', 0
	p3 db 'paragraph/p3.txt', 0
	p4 db 'paragraph/p4.txt', 0
	p5 db 'paragraph/p5.txt', 0
	p6 db 'paragraph/p6.txt', 0
	p7 db 'paragraph/p7.txt', 0
	p8 db 'paragraph/p8.txt', 0
	p9 db 'paragraph/p9.txt', 0

section .bss
	fd_in resd 1
	info resb len_info
	argu resd digit
	time resd 1
	file_str resb max_file_str
	temp_type resb max_char_str		;untuk menyimpan 1 input kata dari user
	temp_file resb max_char_str		;untuk menyimpan 1 kata dari paragraph
	index resd 1
	wpm resd 1
	display_story resb max_terminal
	one_word resd 1
	temp_str resb 4
	sementara resd 1
	sementara2 resd 1
	condition resd 1
	b_or_s resd 1
	correct_words resd 1
	wrong_words resd 1

section .text
	global main
main:
	push	ebp
	mov		ebp, esp
	cmp		dword [ebp + 4], no_args
	je		random_60s
	cmp		dword [ebp + 4], max_args
	ja		too_many_args
	mov     ebx, 3
	jmp		an_args

;start processing program with exsisting argument (int_time = argument)
an_args:
	mov     esi, dword [ebp + 4 * ebx]
    mov		edi, argu
    movsd  
	;eax = int_time(s)
    call	convert_str_int
    jmp 	start

;start processing program with no argument (default int_time = 60)
random_60s:
	mov 	eax, default_time
	jmp		start

;error handling
too_many_args:
	call 	clear_screen
	;header
	mov		eax, msg_welcome
	call	print
	;print msg_error
	mov		eax, msg_error
	call	print
	jmp		exit

start:
	mov 	dword [time], eax			;set time
	;sys_signal for sig_alarm handler
	mov 	eax, sys_signal
	mov 	ebx, sig_alarm		;untuk menangkap sys_alarm apabila alarm sudah nol
	mov 	ecx, count_wpm		;destination of alarm handler
	int 	0x80
	;start count
	call	alarm
	;take a random story
	call	random

	call 	clear_screen
	;header
	mov		eax, msg_welcome
	call	print
	jmp		user

;starting get string from user
user:
	call 	display 				;display a story
;getting string from user
input:
	;set cursor_type
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, cursor_type
	mov 	edx, len_cursor_type
	int 	0x80
	;erase_line
	mov 	eax, sys_write
	mov 	ebx, std_out
	mov 	ecx, erase_line
	mov 	edx, len_erase_line
	int 	0x80

	mov 	eax, sys_read
	mov 	ebx, std_in
	mov 	ecx, temp_type
	mov 	edx, max_char_str
	int 	0x80
	cmp 	byte [temp_type], 10 	;check if user input nothing
	je		input
	call	compare 			;result wmp are store into wpm, and length are store into one_word

	xor 	ebx, ebx
	mov 	ecx, max_char_str
;clear memory temp_type before start getting string from user
null_temp_type:
	mov 	byte [temp_type + ebx], 0
	inc 	ebx
	loopnz	null_temp_type
	jmp		user

count_wpm:
	call 	clear_screen
	;header
	mov		eax, msg_welcome
	call	print

	;displaying WPM
	mov 	eax, sys_write
	mov 	ebx, std_in
	mov 	ecx, msg_wpm
	mov 	edx, len_msg_wpm
	int 	0x80
	call	wpm_measure			;result are store in eax
	call	convert_int_str		;convert and print the result
	call	cr_print
	;displaying Keystrokes
	mov 	eax, sys_write
	mov 	ebx, std_in
	mov 	ecx, msg_keystrokes
	mov 	edx, len_msg_keystrokes
	int 	0x80
	mov 	eax, [one_word]
	call	convert_int_str
	call	_leftresult
	call	green_result
	mov 	eax, [wpm]
	call	convert_int_str		;convert and print the result
	call 	default_result
	call	_midresult
	call	red_result
	mov 	eax, [one_word]
	sub		eax, [wpm]
	call	convert_int_str		;convert and print the result
	call	default_result
	call	_rightresult
	call 	cr_print
	;displaying Correct word
	mov 	eax, sys_write
	mov 	ebx, std_in
	mov 	ecx, msg_correct_words
	mov 	edx, len_msg_correct_words
	int 	0x80
	call	green_result
	mov 	eax, [correct_words]
	call	convert_int_str		;convert and print the result
	call 	default_result
	call 	cr_print
	;displaying Wrong word
	mov 	eax, sys_write
	mov 	ebx, std_in
	mov 	ecx, msg_wrong_words
	mov 	edx, len_msg_wrong_words
	int 	0x80
	call	red_result
	mov 	eax, [wrong_words]
	call	convert_int_str		;convert and print the result
	call	default_result
	call	cr_print
	call	cr_print

	jmp		exit
;just print enter
cr_print:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, cr
	mov 	edx, len_cr
	int 	0x80
	ret
red_result:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, fr_red
	mov 	edx, len_fr_red
	int 	0x80
	ret
green_result:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, fr_green
	mov 	edx, len_fr_green
	int 	0x80
	ret
default_result:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, fr_default
	mov 	edx, len_fr_default
	int 	0x80
	ret

_leftresult:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, leftresult
	mov 	edx, len_leftresult
	int 	0x80
	ret
_midresult:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, midresult
	mov 	edx, len_midresult
	int 	0x80
	ret
_rightresult:
	mov 	eax, 4
	mov 	ebx, 1
	mov 	ecx, rightresult
	mov 	edx, len_rightresult
	int 	0x80
	ret

exit:
	mov 	eax, 1
	mov 	ebx, 0
	int 	0x80