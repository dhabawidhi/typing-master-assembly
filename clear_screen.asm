%ifndef clear_screen_asm
%define clear_screen_asm

%assign sys_write	4
%assign std_out		1

	;27 are ascii code for ESC
	;ESC[H are ansi escape code for move cursor to upper left corner 
	;ESC[2J are ansi escape code for clear entire screen
	;for more ansi escape code, visit http://ascii-table.com/ansi-escape-sequences-vt-100.php
	
section .data
	clr_scr db 27, '[H' , 27, '[2J', 0
	len_clr_scr equ $-clr_scr

clear_screen:
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, clr_scr
	mov edx, len_clr_scr
	int 0x80

	ret

%endif