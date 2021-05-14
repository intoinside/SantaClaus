
GameIntro: {
		jsr InitIntro
		jsr DrawIntroMap

		cli

	NoFirePressed:
		jsr AnimateMap
		jsr GetJoystickMove
		lda FirePressed
		beq NoFirePressed

		sei
		rts
}

CharAnimationFrame:
		.byte $00

AnimateMap: {
	.label LEFT_SMOKE = SCREEN_RAM + $2a9
	.label RIGHT_SMOKE = SCREEN_RAM + $314
	.label STAR1 = SCREEN_RAM + $52
	.label STAR2 = SCREEN_RAM + $61
	.label STAR3 = SCREEN_RAM + $99
	.label STAR4_R = SCREEN_RAM + $db
	.label STAR5_R = SCREEN_RAM + $112
	.label STAR6 = SCREEN_RAM + $16a

		jsr WaitRoutine

		ldx CharAnimationFrame
		cpx #$0f
		bne CheckCharAnimationFrame
		lda LEFT_SMOKE
		cmp #$7e
		beq AddChar
		dec LEFT_SMOKE
		dec RIGHT_SMOKE
		dec STAR1
		dec STAR2
		dec STAR3
		inc STAR4_R
		inc STAR5_R
		dec STAR6
		jmp CheckCharAnimationFrame
	AddChar:
		inc LEFT_SMOKE
		inc RIGHT_SMOKE
		inc STAR1
		inc STAR2
		inc STAR3
		dec STAR4_R
		dec STAR5_R
		inc STAR6
	CheckCharAnimationFrame:
		cpx #$0f
		beq ResetCharAnimationFrame
		inc CharAnimationFrame
		jmp SwitchCharAnimationFrameDone
	ResetCharAnimationFrame:
		lda #$00
		sta CharAnimationFrame
	SwitchCharAnimationFrameDone:

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
