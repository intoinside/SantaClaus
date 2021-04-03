
SleighFrame:
	.byte $00

SetupSprites: {
		lda #$2c						// Sleigh (0)
		sta SCREEN_RAM + $03f8 + $00
		lda #$2d						// Elf (1)
		sta SCREEN_RAM + $03f8 + $01
		lda #$2e						// Reindeer(s) (2-3-4-5)
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04
		sta SCREEN_RAM + $03f8 + $05
		lda #$35						// Santa (7)
		sta SCREEN_RAM + $03f8 + $06
		lda #$34						// Santa shadow (6)
		sta SCREEN_RAM + $03f8 + $07

		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #$02
		sta $d027			// Sleigh Sprite #0 color
		lda #$05
		sta $d028			// Elf Sprite #1 color
		lda #$09
		sta $d029			// Reindeer Sprite #2-5 color
		sta $d02a
		sta $d02b
		sta $d02c
		lda #$00
		sta $d02d			// Santa Sprite #6 color
		lda #$01
		sta $d02e			// Santa shadow Sprite #7 color

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
		sta $d002
		lda #$48
		sta $d004
		lda #$5a
		sta $d006
		lda #$6c
		sta $d008
		lda #$7e
		sta $d00a

		lda #$90
		sta $d00c
		sta $d00e

		rts
}

MoveSleigh: {
		lda $d000
		clc
		adc #$01
		sta $d000
		sta $d002
		bcs ToggleExtraXSleigh

	EvaluateReindeer:
		lda $d004
		clc
		adc #$01
		sta $d004
		bcs ToggleExtraXReindeer1
	Reindeer2:
		lda $d006
		clc
		adc #$01
		sta $d006
		bcs ToggleExtraXReindeer2
	Reindeer3:
		lda $d008
		clc
		adc #$01
		sta $d008
		bcs ToggleExtraXReindeer3
	Reindeer4:
		lda $d00a
		clc
		adc #$01
		sta $d00a
		bcs ToggleExtraXReindeer4
	LastReindeerDone:
		rts

	ToggleExtraXSleigh:
		lda $d010
		cmp #%00100000
		bcs SetExtraXSleigh
		and #%11111100
		sta $d010
		jmp !ReloadXSleighAndElf+
	SetExtraXSleigh:
		ora #%00000011
		sta $d010
	!ReloadXSleighAndElf:
		jmp EvaluateReindeer

	ToggleExtraXReindeer1:
		lda $d010
		cmp #%00100000
		bcs SetExtraXReindeer1
		and #%11111011
		sta $d010
		jmp !ReloadXReindeer1+
	SetExtraXReindeer1:
		ora #%00000100
		sta $d010
	!ReloadXReindeer1:
		jmp Reindeer2

	ToggleExtraXReindeer2:
		lda $d010
		cmp #%00100000
		bcs SetExtraXReindeer2
		and #%11110111
		sta $d010
		jmp !ReloadXReindeer2+
	SetExtraXReindeer2:
		ora #%00001000
		sta $d010
	!ReloadXReindeer2:
		jmp Reindeer3

	ToggleExtraXReindeer3:
		lda $d010
		cmp #%00100000
		bcs SetExtraXReindeer3
		and #%11101111
		sta $d010
		jmp !ReloadXReindeer3+
	SetExtraXReindeer3:
		ora #%00010000
		sta $d010
	!ReloadXReindeer3:
		jmp Reindeer4

	ToggleExtraXReindeer4:
		lda $d010
		cmp #%00100000
		bcc SetExtraXReindeer4
		and #%11011111
		sta $d010
		jmp !ReloadXReindeer4+
	SetExtraXReindeer4:
		ora #%00100000
		sta $d010
	!ReloadXReindeer4:
		jmp LastReindeerDone
}
