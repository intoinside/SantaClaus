
GameIntro: {
		jsr InitIntro
		jsr DrawIntroMap

		cli

	NoFirePressed:
		jsr AnimateMap
		jsr AnimateMapStep2
		jsr GetJoystickMove
		lda FirePressed
		beq NoFirePressed

		sei
		rts
}

CharAnimationFrame:
		.byte $00
CharAnimationFrameStep2:
		.byte $00

AnimateMap: {
	.label RIGHT_SMOKE = SCREEN_RAM + $314
	.label STAR2 = SCREEN_RAM + $61
	.label STAR3 = SCREEN_RAM + $99
	.label STAR6 = SCREEN_RAM + $16a

		jsr WaitRoutine

		ldx CharAnimationFrame
		cpx #$06
		bne CheckCharAnimationFrame
		lda RIGHT_SMOKE
		cmp #$7e
		beq AddChar
		dec RIGHT_SMOKE
		dec STAR2
		dec STAR3
		dec STAR6
		jmp CheckCharAnimationFrame
	AddChar:
		inc RIGHT_SMOKE
		inc STAR2
		inc STAR3
		inc STAR6
	CheckCharAnimationFrame:
		cpx #$06
		beq ResetCharAnimationFrame
		inc CharAnimationFrame
		jmp SwitchCharAnimationFrameDone
	ResetCharAnimationFrame:
		lda #$00
		sta CharAnimationFrame
	SwitchCharAnimationFrameDone:

		rts
}

AnimateMapStep2: {
	.label LEFT_SMOKE = SCREEN_RAM + $2a9
	.label STAR1 = SCREEN_RAM + $52
	.label STAR4_R = SCREEN_RAM + $db
	.label STAR5_R = SCREEN_RAM + $112

		jsr WaitRoutine

		ldx CharAnimationFrameStep2
		cpx #$0a
		bne CheckCharAnimationFrameStep2
		lda LEFT_SMOKE
		cmp #$7e
		beq AddChar
		dec LEFT_SMOKE
		dec STAR1
		inc STAR4_R
		inc STAR5_R
		jmp CheckCharAnimationFrameStep2
	AddChar:
		inc LEFT_SMOKE
		inc STAR1
		dec STAR4_R
		dec STAR5_R
	CheckCharAnimationFrameStep2:
		cpx #$0a
		beq ResetCharAnimationFrameStep2
		inc CharAnimationFrameStep2
		jmp SwitchCharAnimationFrameStep2Done
	ResetCharAnimationFrameStep2:
		lda #$00
		sta CharAnimationFrameStep2
	SwitchCharAnimationFrameStep2Done:

		rts
}


InitIntro: {
		lda #$00
		sta VIC.BORDER_COLOR			// Border color
		lda #$00
		sta VIC.BACKGROUND_COLOR		// Background color
		lda #$00
		sta VIC.EXTRA_BACKGROUND1		// Extra background color #1
		lda #$01
		sta VIC.EXTRA_BACKGROUND2		// Extra background color #2

		rts
}

DrawIntroMap: {
        ldx #$00
    LoopMap:
        lda CHAR_INTRO_MAP, x   		// Get data from map
        sta SCREEN_RAM, x    			// Put data into SCREEN RAM
        lda CHAR_INTRO_MAP + $100, x	// Fetch the next 256 bytes of data from binary
        sta SCREEN_RAM + $100, x     	// Store the next 256 bytes to screen
        lda CHAR_INTRO_MAP + $200, x 	// ... and so on
        sta SCREEN_RAM + $200, x
        lda CHAR_INTRO_MAP + $2E8, x
        sta SCREEN_RAM + $2e8, x
        inx                				// Increment accumulator until 256 bytes read
        bne LoopMap

        ldx #$00
	LoopCols:
        ldy SCREEN_RAM, x	  		// Read screen position
        lda COLOR_MAP, y    		// Read attributes table
        sta $D800, x        		// Store to COLOUR RAM
        ldy SCREEN_RAM + $100, x  	// Read next 256 screen positions
        lda COLOR_MAP, y     		// Store to COLOUR RAM + $100
        sta $D900, x        		// ... and so on
        ldy SCREEN_RAM + $200, x
        lda COLOR_MAP, y
        sta $DA00, x
        ldy SCREEN_RAM + $2e8, x
        lda COLOR_MAP, y
        sta $DAE8, x
        inx               			// Increment accumulator until 256 bytes read
        bne LoopCols

        rts
}

* = $c200 "IntroMap"
CHAR_INTRO_MAP:
	.import binary "./assets/intro-map.bin"
