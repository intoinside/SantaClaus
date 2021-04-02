
SetupSprites: {
		lda #$2c
		sta SCREEN_RAM + $03f8 + $00
		lda #$2d
		sta SCREEN_RAM + $03f8 + $01
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04

		lda #%00011111
		sta VIC.SPRITE_MULTICOLOR

		lda #$02
		sta $d027			// Sprite #0 color
//		lda #$02
		sta $d028			// Sprite #1 color
		sta $d029
		sta $d02a
		sta $d02b

		lda #$00
		sta VIC.SPRITE_EXTRACOLOR1
		lda #$08
		sta VIC.SPRITE_EXTRACOLOR2

		lda #%00011111
		sta VIC.SPRITE_ENABLE

		lda #$80
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009

		lda #$30
		sta $d000
		lda #$48
		sta $d002
		lda #$5a
		sta $d004
		lda #$6c
		sta $d006
		lda #$7e
		sta $d008
		rts
}
