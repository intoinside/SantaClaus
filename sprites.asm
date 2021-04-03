
SetupSprites: {
		lda #$2c
		sta SCREEN_RAM + $03f8 + $00
		lda #$2d
		sta SCREEN_RAM + $03f8 + $01
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04
		lda #$31
		sta SCREEN_RAM + $03f8 + $05
		lda #$35
		sta SCREEN_RAM + $03f8 + $06
		lda #$34
		sta SCREEN_RAM + $03f8 + $07

		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #$02
		sta $d027			// Sprite #0 color
		lda #$09
		sta $d028			// Sprite #1 color
		sta $d029
		sta $d02a
		sta $d02b
		lda #$05
		sta $d02c
		lda #$00
		sta $d02d
		lda #$01
		sta $d02e

		lda #$02
		sta VIC.SPRITE_EXTRACOLOR1
		lda #$08
		sta VIC.SPRITE_EXTRACOLOR2

		lda #%11111111
		sta VIC.SPRITE_ENABLE

// Y Positioning 
		lda #$80
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b

		lda #$dc
		sta $d00d
		sta $d00f

// X Positioning 
		lda #$30
		sta $d000
		sta $d00a
		lda #$48
		sta $d002
		lda #$5a
		sta $d004
		lda #$6c
		sta $d006
		lda #$7e
		sta $d008

		lda #$90
		sta $d00c
		sta $d00e

		rts
}
