%ifndef set_alarm_asm
%define set_alarm_asm

%assign sys_alarm	0x1b

alarm:
	mov eax, sys_alarm
	mov ebx, [time]
	int 0x80
	ret

%endif