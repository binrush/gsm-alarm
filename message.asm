; Инициализируем отправленные сообщения
ClearMessages:
	MOV	R16, MSG_LOW
	MOV	R17, MSG_HIGH
	EOR	MSG_LOW, R17
	EOR	MSG_HIGH, R16
	RET

InitMessages:
	LDI	MSG_LOW, 0
	LDI	MSG_HIGH, 0
	RET

.macro SEND_MSG
	CBR	MSG_HIGH, (1<<@0)
	SBR	MSG_LOW, (1<<@0)
.endm

.macro READ_MSG
	MOV	R16, MSG_HIGH
	AND	R16, MSG_LOW
	CLT
	SBRC	R16, @0
	SET
.endm

