%ifndef bogo_random_asm
%define bogo_random_asm

%assign sys_time		0x0d
%assign max_paragraph	9

%assign sys_read	3
%assign sys_write	4
%assign sys_open	5
%assign sys_close	6

%assign std_in		0
%assign std_out		1

%assign max_file_str	1000

random:
	mov eax, sys_time
	mov ebx, 0
	int 0x80

	xor edx, edx
	mov ecx, max_paragraph
	div ecx

	dec ecx
	cmp edx, ecx
	je _9
	dec ecx
	cmp edx, ecx
	je _8
	dec ecx
	cmp edx, ecx
	je _7
	dec ecx
	cmp edx, ecx
	je _6
	dec ecx
	cmp edx, ecx
	je _5
	dec ecx
	cmp edx, ecx
	je _4
	dec ecx
	cmp edx, ecx
	je _3
	dec ecx
	cmp edx, ecx
	je _2
	dec ecx
	cmp edx, ecx
	je _1

_1:
	mov esi, p1
	jmp next
_2:
	mov esi, p2
	jmp next
_3:
	mov esi, p3
	jmp next
_4:
	mov esi, p4
	jmp next
_5:
	mov esi, p5
	jmp next
_6:
	mov esi, p6
	jmp next
_7:
	mov esi, p7
	jmp next
_8:
	mov esi, p8
	jmp next
_9:
	mov esi, p9
	jmp next

next:
	;open the file
	mov ebx, esi		;esi contain address of source file
	mov eax, sys_open
	mov ecx, 0 			;for read only access
	mov edx, 0777		;read, write and execute by all
	int 0x80
	mov [fd_in], eax

	;read from the file
	mov eax, sys_read
	mov ebx, [fd_in]
	mov ecx, file_str
	mov edx, max_file_str
	int 0x80

	;close the file
	mov eax, sys_close
	mov ebx, [fd_in]
	int 0x80

	ret

%endif