LedFSM:
	CPI	STATE_LED_FSM, LED_FSM_LIGHTS
	BREQ	ledFSMLights
	CPI	STATE_LED_FSM, LED_FSM_SHUTS_ONCE
	BREQ	ledFSMShutsOnce
	CPI	STATE_LED_FSM, LED_FSM_NOTLIGHTS
	BREQ	ledFSMNotLights
	CPI	STATE_LED_FSM, LED_FSM_BLINKS_ONCE
	BREQ	ledFSMLightsOnce
	RET

;==state==
ledFSMLights:
	; Если есть сообщение 'Верный ключ', выключить диод
	; и перейти в состояние LED_FSM_NOTLIGHTS
	; Если есть сообщение 'Неверный ключ'
	; перейти в состояние LED_FSM_SHUT_ONCE
	READ_MSG 	MSG_READ_VALID_KEY
	BRTS	shutLed
	READ_MSG	MSG_READ_INVALID_KEY
	BRTS	shutLedOnce
	RET
shutLed:
	CBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_NOTLIGHTS
	RET
shutLedOnce:
	CBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_SHUTS_ONCE
	LDI	R16, LED_BLINK_DELAY_COUNTS
	STS	virtual_timers + TIMER_LED_BLINK, R16
	RET

;==state==
ledFSMNotLights:
	READ_MSG	MSG_READ_VALID_KEY
	BRTS	lightLed
	READ_MSG	MSG_READ_INVALID_KEY
	BRTS	lightLedOnce
	RET
lightLed:
	SBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_LIGHTS
	RET
lightLedOnce:
	SBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_BLINKS_ONCE
	LDI	R16, LED_BLINK_DELAY_COUNTS
	STS	virtual_timers + TIMER_LED_BLINK, R16
	RET

;==state==
ledFSMShutsOnce:
	LDS	R16, virtual_timers + TIMER_LED_BLINK
	CPI	R16, 0
	BREQ	stopShutOnce
	RET
stopShutOnce:
	SBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_LIGHTS
	RET

;==state==
ledFSMLightsOnce:
	LDS	R16, virtual_timers + TIMER_LED_BLINK
	CPI	R16, 0
	BREQ	stopLightOnce
	RET
stopLightOnce:
	CBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_NOTLIGHTS
	RET

InitLedFsm:
	SBI	OWLED_DDR, OWLED_DQ
	SBI	OWLED_PORT, OWLED_DQ
	LDI	STATE_LED_FSM, LED_FSM_LIGHTS
	RET