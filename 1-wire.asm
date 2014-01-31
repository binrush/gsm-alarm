;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
.equ	OW_PORT	= PORTB
.equ	OW_PIN	= PINB
.equ	OW_DDR	= DDRB
.equ	OW_DQ	= PB2

.def	OWCount = r17
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
.cseg
;------------------------------------------------------------------------------
; Output : T - presence bit
;------------------------------------------------------------------------------
OWReset:
	cbi		OW_PORT,OW_DQ
	sbi		OW_DDR,OW_DQ

	ldi		XH, HIGH(470*C4PUS)
	ldi		XL, LOW(470*C4PUS)
	rcall	Wait4xCycles
	
	cbi		OW_DDR,OW_DQ

	ldi		XH, HIGH(70*C4PUS)
	ldi		XL, LOW(70*C4PUS)
	rcall	Wait4xCycles

	set
	sbis	OW_PIN,OW_DQ
	clt

	ldi		XH, HIGH(240*C4PUS)
	ldi		XL, LOW(240*C4PUS)
	rcall	Wait4xCycles

	ret
;------------------------------------------------------------------------------
; Input : C - bit to write
;------------------------------------------------------------------------------
OWWriteBit:
	brcc	OWWriteZero
	ldi		XH, HIGH(C4PUS)
	ldi		XL, LOW(C4PUS)
	rjmp	OWWriteOne
OWWriteZero:	
	ldi		XH, HIGH(C4PUS*120)
	ldi		XL, LOW(C4PUS*120)
OWWriteOne:
	sbi		OW_DDR, OW_DQ
	rcall	Wait4xCycles
	cbi		OW_DDR, OW_DQ
	
	ldi		XH, HIGH(C4PUS*60)
	ldi		XL, LOW(C4PUS*60)
	rcall	Wait4xCycles
	ret
;------------------------------------------------------------------------------
; Input : r16 - byte to write
;------------------------------------------------------------------------------
OWWriteByte:
	push	OWCount
	ldi		OWCount,0
OWWriteLoop:	
	ror		r16
	rcall	OWWriteBit	
	inc		OWCount
	cpi		OWCount,8
	brne	OWWriteLoop
	pop		OWCount		
	ret
;------------------------------------------------------------------------------
; Output : C - bit from slave
;------------------------------------------------------------------------------
OWReadBit:
	ldi		XH, HIGH(C4PUS)
	ldi		XL, LOW(C4PUS)
	sbi		OW_DDR, OW_DQ
	rcall	Wait4xCycles
	cbi		OW_DDR, OW_DQ
	ldi		XH, HIGH(5*C4PUS)
	ldi		XL, LOW(5*C4PUS)
	rcall	Wait4xCycles
	clt
	sbic	OW_PIN,OW_DQ
	set
	ldi		XH, HIGH(50*C4PUS)
	ldi		XL, LOW(50*C4PUS)
	rcall	Wait4xCycles
	sec
	brts	OWReadBitEnd
	clc
OWReadBitEnd:
	ret
;------------------------------------------------------------------------------
; Output : r16 - byte from slave
;------------------------------------------------------------------------------
OWReadByte:
	push	OWCount
	ldi		OWCount,0
OWReadLoop:
	rcall	OWReadBit
	ror		r16
	inc		OWCount
	cpi		OWCount,8
	brne	OWReadLoop
	pop		OWCount
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
