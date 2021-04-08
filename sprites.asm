
ReindeerFrame:
	.byte $00
SantaFrame:
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
		lda #$80			// Sleigh, elf and reindeer Y position
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y

		lda #$dd			// Santa and santa shadow Y position
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y

// X Positioning 
		lda #$30			// Sleigh, elf X position
		sta VIC.SPRITE_0_X
		sta VIC.SPRITE_1_X
		lda #$48			// Reindeer 1 X position
		sta VIC.SPRITE_2_X
		lda #$5a			// Reindeer 2 X position
		sta VIC.SPRITE_3_X
		lda #$6c			// Reindeer 3 X position
		sta VIC.SPRITE_4_X
		lda #$7e			// Reindeer 4 X position
		sta VIC.SPRITE_5_X

		lda #$60			// Santa and santa shadow X position
		sta VIC.SPRITE_6_X
		sta VIC.SPRITE_7_X

		rts
}

MoveSanta: {
		jsr SwitchSantaFrame
		rts
}

SwitchSantaFrame: {
		lda SantaFrame
		lsr
		lsr
		lsr
		cmp #$00
		beq Frame1
		ldx #$32
		ldy #$33
		jmp CheckDirection
	Frame1:
		ldx #$34
		ldy #$35
	CheckDirection:
		lda Direction
		cmp #$ff
		beq SantaLeft
		cmp #$01
		beq SetFrame
		jmp SwitchSantaFrameDone
	SantaLeft:
		txa
		clc
		adc #$04
		tax

		tay
		iny
	SetFrame:
		stx SCREEN_RAM + $03f8 + $07	// 3byte, 4cyc
		sty SCREEN_RAM + $03f8 + $06	// 3byte, 4cyc
	CheckSantaFrame:
		lda SantaFrame
		cmp #$0f
		beq ResetSantaFrame
		inc SantaFrame
		jmp SwitchSantaFrameDone
	ResetSantaFrame:
		lda #$00
		sta SantaFrame
	SwitchSantaFrameDone:
		rts
}

MoveSleigh: {
		jsr DetectSleighNewY
		lda Direction
		cmp #$00
		beq NoMove
		cmp #$ff
		beq MoveBackward

	MoveForward:
		lda #$01
		jmp ApplyMove

	NoMove:
		lda #$02
		jmp ApplyMove

	MoveBackward:
		lda #$03

	ApplyMove:
		tax
		clc
		adc VIC.SPRITE_0_X	
		sta VIC.SPRITE_0_X
		sta VIC.SPRITE_1_X
		bcs ToggleExtraXSleigh	// Check if sleigh goes over 255px

	EvaluateReindeer:
		txa
		clc
		adc VIC.SPRITE_2_X
		sta VIC.SPRITE_2_X
		bcs ToggleExtraXReindeer1
	Reindeer2:
		txa
		clc
		adc VIC.SPRITE_3_X
		sta VIC.SPRITE_3_X
		bcs ToggleExtraXReindeer2
	Reindeer3:
		txa
		clc
		adc VIC.SPRITE_4_X
		sta VIC.SPRITE_4_X
		bcs ToggleExtraXReindeer3
	Reindeer4:
		txa
		clc
		adc VIC.SPRITE_5_X
		sta VIC.SPRITE_5_X
		bcs ToggleExtraXReindeer4
	LastReindeerDone:
		jsr SwitchReindeerFrame
		rts

	ToggleExtraXSleigh:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting sleigh and elf extra x position
		cmp #%00100000
		bcs SetExtraXSleigh
		and #%11111100
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXSleighAndElf+
	SetExtraXSleigh:
		ora #%00000011
		sta VIC.SPRITE_EXTRAX
	!ReloadXSleighAndElf:
		jmp EvaluateReindeer

	ToggleExtraXReindeer1:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 1 extra x position
		cmp #%00100000
		bcs SetExtraXReindeer1
		and #%11111011
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer1+
	SetExtraXReindeer1:
		ora #%00000100
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer1:
		jmp Reindeer2

	ToggleExtraXReindeer2:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 2 extra x position
		cmp #%00100000
		bcs SetExtraXReindeer2
		and #%11110111
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer2+
	SetExtraXReindeer2:
		ora #%00001000
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer2:
		jmp Reindeer3

	ToggleExtraXReindeer3:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 3 extra x position
		cmp #%00100000
		bcs SetExtraXReindeer3
		and #%11101111
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer3+
	SetExtraXReindeer3:
		ora #%00010000
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer3:
		jmp Reindeer4

	ToggleExtraXReindeer4:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 4 extra x position
		cmp #%00100000
		bcc SetExtraXReindeer4
		and #%11011111
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer4+
	SetExtraXReindeer4:
		ora #%00100000
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer4:
		jmp LastReindeerDone
}

DetectSleighNewY: {
		lda VIC.SPRITE_5_X
		cmp #$fd
		beq !+
		cmp #$fe
		beq !+
		cmp #$ff
		bne End
	!:
		lda VIC.SPRITE_EXTRAX
		and #%00000001
		cmp #%00000001
		bne End
		lda #$4f
		sta MaxNumberGenerator
		jsr GetRandomNumber
		lda RandomNumber
		clc
		adc #$37
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y
	End:
		rts
}

SwitchReindeerFrame: {
		lda ReindeerFrame
		clc
		lsr
		lsr
		lsr
		bcs CheckReindeerFrame
		adc #$2e
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04
		sta SCREEN_RAM + $03f8 + $05

	CheckReindeerFrame:
		lda ReindeerFrame
		cmp #$1f
		beq ResetReindeerFrame
		inc ReindeerFrame
		jmp SwitchReindeerFrameDone
	ResetReindeerFrame:
		lda #$00
		sta ReindeerFrame
	SwitchReindeerFrameDone:
		rts
}
