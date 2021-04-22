
ReindeerFrame:
	.byte $00
SantaFrame:
	.byte $00
IsJumping:
	.byte $00
IsLanding:
	.byte Santa.MAX_JUMP

Santa: {
	.label Y 			= $dd
	.label MAX_JUMP 	= $24

	.label PREV_X   	= $00
	.label PREV_Y   	= $00

	.label PREV_X_S 	= $00
	.label PREV_Y_S 	= $00

	.label PREV_MBSX	= $00
}

SetupSprites: {
		lda #$30						// Elf (0)
		sta SCREEN_RAM + $03f8 + $00
		lda #$31						// Reindeer(s) (1-2-3-4)
		sta SCREEN_RAM + $03f8 + $01
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04
		lda #$38						// Santa (6)
		sta SCREEN_RAM + $03f8 + $05
		lda #$37						// Santa shadow (5)
		sta SCREEN_RAM + $03f8 + $06
		lda #$42						// Gift (7)
		sta SCREEN_RAM + $03f8 + $07

		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #$05
		sta $d027			// Elf Sprite #0 color
		lda #$09
		sta $d028			// Reindeer Sprite #1-4 color
		sta $d029
		sta $d02a
		sta $d02b
		lda #$00
		sta $d02c			// Santa Sprite #5 color
		lda #$01
		sta $d02d			// Santa shadow Sprite #6 color
		sta $d02e			// Gift Sprite #7 color

		lda #$02
		sta VIC.SPRITE_EXTRACOLOR1
		lda #$08
		sta VIC.SPRITE_EXTRACOLOR2

		lda #%01111111
		sta VIC.SPRITE_ENABLE

// Y Positioning
		lda #$80				// Sleigh, elf and reindeer Y position
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y

		lda #Santa.Y			// Santa and santa shadow Y position
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y

// X Positioning
		lda #$30				// Sleigh, elf X position
		sta VIC.SPRITE_0_X
		lda #$48				// Reindeer 1 X position
		sta VIC.SPRITE_1_X
		lda #$5a				// Reindeer 2 X position
		sta VIC.SPRITE_2_X
		lda #$6c				// Reindeer 3 X position
		sta VIC.SPRITE_3_X
		lda #$7e				// Reindeer 4 X position
		sta VIC.SPRITE_4_X

		lda #$60				// Santa and Santa shadow X position
		sta VIC.SPRITE_5_X
		sta VIC.SPRITE_6_X

		rts
}

StartSantaJumpOrLand: {
		lda DirectionY			// Direction up, check for a jump
		cmp #$ff
		bne !+
		lda IsJumping			// No jump in progress, check if a new jump should start
		cmp #$00
		bne !+					// Already in a jump session, exit
		inc IsJumping			// No jump, start a new jump session
	!:
		rts
}

ManageSantaJumpOrLand: {
		lda IsJumping
		beq Done				// When IsJumping = 0 => no jump in progress, check if should start a new jump
		cmp #Santa.MAX_JUMP
		beq PerformLand			// When IsJumping = SANTA.MAX_JUMP => jump rise is done, start to land
		jmp PerformJump			// When 0 < IsJumping < SANTA.MAX_JUMP => jump rise is in progress, proceed

	PerformLand:
		lda #Santa.Y 			// Get default position
		clc
		sbc IsLanding			// Detect and set new position
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		dec IsLanding
		bmi ResetVars			// Landing done, reset vars
		jmp UpdateFrame			// Update sprite frame

	PerformJump:
		lda #Santa.Y 			// Get default position
		clc
		sbc IsJumping			// Detect and set new position
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		inc IsJumping
		jmp UpdateFrame			// Update sprite frame

	ResetVars:
		lda #$00
		sta IsJumping
		sta SantaFrame
		lda #Santa.MAX_JUMP
		sta IsLanding
	UpdateFrame:
		jsr SwitchSantaFrame
	Done:
		rts
}

SwitchSantaFrame: {
		lda IsJumping		// If IsJumping == 0 => no jump in progress
		beq NoJump
		cmp #Santa.MAX_JUMP
		beq CheckLanding
		lda Orientation
		cmp #$ff
		beq SantaJumpLeft
		ldx #$3d			// Santa is rising (face on right)
		ldy #$3e
		jmp SetFrame
	SantaJumpLeft:
		ldx #$41			// Santa is rising (face on left)
		ldy #$42
		jmp SetFrame

	CheckLanding:
		lda Orientation
		cmp #$ff
		beq SantaLandLeft
		ldx #$3f			// Santa is landing (face on left)
		ldy #$40
		jmp SetFrame
	SantaLandLeft:
		ldx #$43			// Santa is landing (face on right)
		ldy #$44
		jmp SetFrame
	NoJump:
		lda SantaFrame
		lsr
		lsr
		lsr
		cmp #$00
		beq Frame1
		ldx #$35
		ldy #$36
		jmp CheckDirection
	Frame1:
		ldx #$37
		ldy #$38
	CheckDirection:
		lda Orientation
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
		stx SCREEN_RAM + $03f8 + $06	// 3byte, 4cyc
		sty SCREEN_RAM + $03f8 + $05	// 3byte, 4cyc
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
		bcs ToggleExtraXSleigh	// Check if sleigh goes over 255px

	EvaluateReindeer:
		txa
		clc
		adc VIC.SPRITE_1_X
		sta VIC.SPRITE_1_X
		bcs ToggleExtraXReindeer1
	Reindeer2:
		txa
		clc
		adc VIC.SPRITE_2_X
		sta VIC.SPRITE_2_X
		bcs ToggleExtraXReindeer2
	Reindeer3:
		txa
		clc
		adc VIC.SPRITE_3_X
		sta VIC.SPRITE_3_X
		bcs ToggleExtraXReindeer3
	Reindeer4:
		txa
		clc
		adc VIC.SPRITE_4_X
		sta VIC.SPRITE_4_X
		bcs ToggleExtraXReindeer4
	LastReindeerDone:
		jsr SwitchReindeerFrame
		rts

	ToggleExtraXSleigh:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting sleigh and elf extra x position
		cmp #%00010000
		bcs SetExtraXSleigh
		and #%11111110
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXSleighAndElf+
	SetExtraXSleigh:
		ora #%00000001
		sta VIC.SPRITE_EXTRAX
	!ReloadXSleighAndElf:
		jmp EvaluateReindeer

	ToggleExtraXReindeer1:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 1 extra x position
		cmp #%00010000
		bcs SetExtraXReindeer1
		and #%11111101
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer1+
	SetExtraXReindeer1:
		ora #%00000010
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer1:
		jmp Reindeer2

	ToggleExtraXReindeer2:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 2 extra x position
		cmp #%00010000
		bcs SetExtraXReindeer2
		and #%11111011
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer2+
	SetExtraXReindeer2:
		ora #%00000100
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer2:
		jmp Reindeer3

	ToggleExtraXReindeer3:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 3 extra x position
		cmp #%00010000
		bcs SetExtraXReindeer3
		and #%11110111
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer3+
	SetExtraXReindeer3:
		ora #%00001000
		sta VIC.SPRITE_EXTRAX
	!ReloadXReindeer3:
		jmp Reindeer4

	ToggleExtraXReindeer4:
		lda VIC.SPRITE_EXTRAX 			// Setting or resetting reindeer 4 extra x position
		cmp #%00010000
		bcc SetExtraXReindeer4
		and #%11101111
		sta VIC.SPRITE_EXTRAX
		jmp !ReloadXReindeer4+
	SetExtraXReindeer4:
		ora #%00010000
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
		adc #$31
		sta SCREEN_RAM + $03f8 + $01
		sta SCREEN_RAM + $03f8 + $02
		sta SCREEN_RAM + $03f8 + $03
		sta SCREEN_RAM + $03f8 + $04

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
