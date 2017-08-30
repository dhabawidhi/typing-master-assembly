%ifndef wpm_asm
%define wpm_asm

wpm_measure:
	xor edx, edx
	mov eax, [time]
	div dword [basis_wpm]
	cmp edx, 0
	je without_dec
	cmp eax, 0
	je just_dec

	push edx
	xor edx, edx
	mov ebx, eax
	mov eax, [wpm]
	div ebx
	pop ebx
	push eax
	mov eax, ebx
	mul dword [decimal]
	xor edx, edx
	div dword [basis_wpm]
	mov ebx, eax
	pop eax
	push eax
	xor edx, edx
	div ebx
	mov ebx, eax
	pop eax
	sub eax, ebx
	ret
just_dec:
	mov eax, edx
	mul dword [decimal]
	xor edx, edx
	div dword [basis_wpm]
	mul dword [wpm]
	xor edx, edx
	div dword [decimal]
	ret

without_dec:
	cmp eax, 0
	je eax0
	mov ebx, eax
	mov eax, [wpm]
	div ebx
	ret

eax0:
	ret

%endif