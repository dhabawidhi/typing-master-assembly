%ifndef just_print_asm
%define just_print_asm

%assign sys_read	3
%assign sys_write	4
%assign sys_open	5
%assign sys_close	6

%assign std_in		0
%assign std_out		1

; print a msg from the file to stdout
; parameter eax is a source file e.g. 'welcome.txt'

print:

	;open the file
	mov ebx, eax
	mov eax, sys_open
	mov ecx, 0 			;for read only access
	mov edx, 0777		;read, write and execute by all
	int 0x80
	mov [fd_in], eax

	;read from the file
	mov eax, sys_read
	mov ebx, [fd_in]
	mov ecx, info
	mov edx, len_info
	int 0x80

	;close the file
	mov eax, sys_close
	mov ebx, [fd_in]
	int 0x80

	; print the info
	mov eax, sys_write
	mov ebx, std_out
	mov ecx, info
	mov edx, len_info
	int 0x80
	
	xor ebx, ebx
	mov ecx, len_info
	;clear isi memory info
null_info:
	mov byte [info + ebx], 0
	inc ebx
	loopnz	null_info

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	ret

%endif