

SetupSprites:{
		lda #$10
		sta SCREEN_RAM + $03f8 + $00
		sta SCREEN_RAM + $03f8 + $01
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04
		sta SCREEN_RAM + $03f8 + $05
		sta SCREEN_RAM + $03f8 + $06
		sta SCREEN_RAM + $03f8 + $07

		lda #$00
		sta $d027			// Sprite #0 color
		sta $d028
		sta $d029
		sta $d02a
		sta $d02b
		sta $d02c
		sta $d02d
		sta $d02e			// Sprite #7 color

		lda #$00
		sta $d015			// Sprite enable register
		lda #$00
		sta $d01c			// Sprite multicolor mode register

		rts
}
