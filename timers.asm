.DSEG
virtual_timers: .byte VIRTUAL_TIMERS_COUNT

.CSEG
; Макрос для запуска таймера
.macro START_TIMER
	LDI	R16, @0
	STS	virtual_timers + @1, R16
.endm


; Декрементируем виртуальные таймеры
UpdateCounters:
	PUSH	R16
	IN	R16, SREG
	PUSH	R16
	PUSH	YL
	PUSH	YH
	PUSH	R17

	LDI	YL, low(virtual_timers)
	LDI	YH, high(virtual_timers)
	MOV	R16, YL
	MOV	R16, YH
	LDI	R17, VIRTUAL_TIMERS_COUNT
decLoop:
	LD	R16, Y
	CPI	R16, 0
	BREQ	storeTimer
	DEC	R16
storeTimer:
	ST	Y+, R16
	DEC	R17
	CPI	R17, 0
	BRNE	decLoop

	POP	R17
	POP	YH
	POP	YL
	POP	R16
	OUT	SREG, R16
	POP	R16
	RETI

InitTimers:
	; Инициализация таймера
	LDI	R16, (1<<CS11)|(1<<CS10)
	OUT	TCCR1B, R16
	LDI	R16, (1<<TOIE1)
	OUT	TIMSK, R16
	RET


