KeyFSM:
	CPI	STATE_KEY_FSM, KEY_FSM_NOKEY
	BREQ	keyFSMNoKey
	CPI	STATE_KEY_FSM, KEY_FSM_DELAY
	BREQ	keyFSMDelay
	CPI	STATE_KEY_FSM, KEY_FSM_NOTRELEASED
	BREQ	keyFSMWaitRelease
	RET

;==state==
keyFSMNoKey:
	CLI
	RCALL	OWReset
	BRTS	keyFSMExit
	RCALL	CRC8Init
	LDI	R16, 0x33
	RCALL	OWWriteByte
	LDI	ZL, low(stored_key*2)
	LDI	ZH, high(stored_key*2)
	LDI	R17, 8
checkLoop:
	RCALL	OWReadByte
	LPM	R18, Z+
	CP	R16, R18
	BRNE	invalidKey
	RCALL	CRC8Update
	DEC	R17
	BRNE	checkLoop
	RCALL	GetCRC8
	CPI	R16, 0
	BRNE	invalidKey
	RJMP	validKey

invalidKey:
	; Передать сообщение "Считан неверный ключ"
	SEND_MSG	MSG_READ_INVALID_KEY
	RJMP	keyRead
validKey:
	; Передать сообщение "Считан верный ключ"
	SEND_MSG	MSG_READ_VALID_KEY
	RJMP	keyRead
keyRead:
	LDI	R16, KEY_READ_DELAY_COUNTS
	STS	virtual_timers + TIMER_KEY_DELAY, R16
	LDI	STATE_KEY_FSM, KEY_FSM_DELAY
keyFSMExit:
	SEI
	RET
;==state==
keyFSMDelay:
	LDS	R16, virtual_timers + TIMER_KEY_DELAY
	CPI	R16, 0
	BREQ	stopDelay
	RET
stopDelay:
	LDI	STATE_KEY_FSM, KEY_FSM_NOTRELEASED
	RET

;==state==
keyFSMWaitRelease:
	CLI
	RCALL	OWReset
	SEI
	BRTS	keyReleased
	RET
keyReleased:
	LDI	STATE_KEY_FSM, KEY_FSM_NOKEY
	RET


InitKeyFsm:
	LDI	STATE_KEY_FSM, KEY_FSM_NOKEY
	RET
