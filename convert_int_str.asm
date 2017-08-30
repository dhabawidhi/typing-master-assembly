%ifndef convert_int_str_asm
%define convert_int_str_asm

%assign sys_write		4
%assign std_out			1

;int come from register eax
;the result are store in ecx and directly print in this function

convert_int_str:
	xor ecx, ecx	;for counter
	jmp null_eax

null_eax:
	xor edx, edx	;require set before using div
	div dword [decimal]
	push edx		;simpan 1 digit (lsb ke msb) ke stack
	inc ecx			;for counter in continue
	cmp eax, 0
	je continue
	jmp null_eax

continue:
	xor edx, edx	;for length of temp_str
continue_1:
	pop ebx
	and ebx, 0xff
	add ebx, 48
	mov dword [temp_str + edx], ebx
	inc edx
	loopnz continue_1

	mov eax, sys_write
	mov ebx, std_out
	mov ecx, temp_str
	int 0x80

	ret

%endif