.include "m8def.inc"

.include "defs.asm"

.CSEG
.ORG 0x0000
RJMP	Reset

.ORG OVF1addr
RJMP	UpdateCounters

.include "wait.asm"
.include "1-wire.asm"
.include "usart.asm"
.include "crc8.asm"
.include "message.asm"
.include "timers.asm"
.include "key.asm"
.include "led.asm"
.include "alarm.asm"

Reset:
; Инициализация стека
LDI	R16,Low(RAMEND)
OUT	SPL,R16
LDI	R16,High(RAMEND)
OUT	SPH,R16



; Инициализация USART
LDI	R16, low(bauddivider)
OUT	UBRRL, R16
LDI	R16, high(bauddivider)
OUT	UBRRH, R16
LDI	R16, 0
OUT	UCSRA, R16
LDI	R16, 1<<TXEN
OUT	UCSRB, R16  


RCALL	InitTimers
RCALL	InitMessages
RCALL	InitKeyFsm
RCALL	InitLedFsm
RCALL	InitAlarmFsm

SEI

Main:
	RCALL	KeyFSM
	RCALL	LedFSM
	RCALL	AlarmFSM
	RCALL	ClearMessages
RJMP	Main

stored_key: .db 0x01,0x7a,0x4b,0x69,0x01,0x00,0x00,0x5b
;stored_key: .db 0x01,0x7a,0x4b,0x69,0x01,0x00,0x00,0x5b
