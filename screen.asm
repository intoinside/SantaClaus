
ClearScreen: {
		ldx #$00
	!:
		sta SCREEN_RAM, x
		sta SCREEN_RAM + $100, x
		sta SCREEN_RAM + $200, x
		sta SCREEN_RAM + $300, x
		dex
		bne !-
		rts
}

DrawMapFull2: {

		lda #>SCREEN_RAM
		sta ScrMod + 2
		lda #$d8
		sta ColMod + 2
		lda #$00
		sta ScrMod + 1
		sta ColMod + 1

		lda #>CHAR_MAP
		sta MapMod + 2
		stx MapMod + 1

		ldy #$19
		sty ZP_TEMP
	!OuterLoop:
		ldx #$27
	!Loop:
	MapMod:
		lda $BEEF, x
	ScrMod:
		sta $BE00, x
		tay
		lda COLOR_MAP, y 
	ColMod:
		sta $BE00, x
		dex
		bpl !Loop-

		inc MapMod + 2

		clc 
		lda ScrMod + 1
		adc #$28
		sta ScrMod + 1
		sta ColMod + 1
		bcc !+
		inc ScrMod + 2
		inc ColMod + 2
	!:
		dec ZP_TEMP
		bne !OuterLoop-

		rts
}
