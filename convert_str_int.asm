%ifndef convert_str_int_asm
%define convert_str_int_asm

;string come from memory argu
;the result is store in eax

section .data
	basis dd 10

convert_str_int:
	mov eax, 0
	mov ebx, 0
	mov edx, 0

looping:
	jb return
	mov ecx, dword [argu + ebx]
	and ecx, 0xff
	cmp ecx, 48
	jb return
	cmp ecx, 58
	ja return
	sub ecx, 48
	mul dword [basis]
	add eax, ecx
	inc ebx
	jmp looping

return:
	ret

%endif