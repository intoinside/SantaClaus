
GameIntro: {
        jsr InitIntro
        jsr DrawIntroMap

        cli

    NoFirePressed:
        jsr WaitRoutine
        jsr AnimateMap
        jsr AnimateMapStep2

        jsr AnimateAllSnowFlakes

        jsr GetJoystickMove
        lda FirePressed
        beq NoFirePressed

        sei
        rts
}

AnimateAllSnowFlakes: {
        .for(var i = 0; i < 10; i++) {
            ldx SnowFlakesX + i
            ldy SnowFlakesY + i
            jsr AnimateSnowFlakes
            sty SnowFlakesY + i
        }

        rts
}

// Snowflakes start x/y position
SnowFlakesX:
    .byte $04, $07, $0a, $0e, $12, $17, $1b, $1e, $22, $25
SnowFlakesY:
    .byte $0a, $03, $0c, $01, $08, $01, $0b, $14, $00, $0a
SnowFlakesXPtr:
    .byte $00
SnowFlakesYPtr:
    .byte $00

AnimateSnowFlakes: {
    .label SNOW_FLAKE_CHAR  = $a0
    .label SNOW_FLAKE_COLOR = $0b

        stx SnowFlakesXPtr
        sty SnowFlakesYPtr

    UpdateSnowFlakes:
        ldx CharAnimationFrame
        cpx #$03
        bne End

        // Remove snow flake position from old position
        lda SnowFlakesYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wScreenRAMRowStart, y   // load low address byte
        sta ZeroPage1
        lda wScreenRAMRowStart + 1, y   // load high address byte
        sta ZeroPage2
        ldy SnowFlakesXPtr          // load x position into y register
        lda (ZeroPage1), y
        cmp #SNOW_FLAKE_CHAR
        bne CheckNewPosition
        lda #$00
        sta (ZeroPage1), y

    CheckNewPosition:
        inc SnowFlakesYPtr

        // Check if new snow flake position is already used
        lda SnowFlakesYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wScreenRAMRowStart, y   // load low address byte
        sta ZeroPage1
        lda wScreenRAMRowStart + 1, y   // load high address byte
        sta ZeroPage2
        ldy SnowFlakesXPtr          // load x position into Y register
        lda (ZeroPage1), y
        bne CheckYReset             // New snow flake position already used

        // New position is free, setting snow flake char
        lda #SNOW_FLAKE_CHAR
        sta (ZeroPage1), y

        // Set color for new position
        lda SnowFlakesYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wColorRAMRowStart, y    // load low address byte
        sta ZeroPage1
        lda wColorRAMRowStart+1, y  // load high address byte
        sta ZeroPage2
        ldy SnowFlakesXPtr          // load x position into Y register
        lda #SNOW_FLAKE_COLOR
        sta (ZeroPage1), y

    CheckYReset:
        ldy SnowFlakesYPtr
        cpy #$18
        beq ResetYCounter
        jmp End

    ResetYCounter:                  // Snow flake on the floor, restart
        ldy #$00
        sty SnowFlakesYPtr

    End:
        rts
}

CharAnimationFrame:
        .byte $00
CharAnimationFrameStep2:
        .byte $00

AnimateMap: {
    .label RIGHT_SMOKE = SCREEN_RAM + 28 + (40 * 19)
    .label STAR2 = SCREEN_RAM + 2 + (40 * 2)
    .label STAR3 = SCREEN_RAM + 36 + (40 * 3)
    .label STAR4_R = SCREEN_RAM + 22 + (40 * 5)

        ldx CharAnimationFrame
        cpx #$06
        bne CheckCharAnimationFrame
        lda RIGHT_SMOKE
        cmp #$7e
        beq AddChar
        dec RIGHT_SMOKE
        dec STAR2
        dec STAR3
        inc STAR4_R
        jmp CheckCharAnimationFrame
    AddChar:
        inc RIGHT_SMOKE
        inc STAR2
        inc STAR3
        dec STAR4_R
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
    .label LEFT_SMOKE = SCREEN_RAM + 1 + (40 * 17)
    .label STAR1 = SCREEN_RAM + 17 + (40 * 1)
    .label STAR5_R = SCREEN_RAM + 31 + (40 * 6)
    .label STAR6 = SCREEN_RAM + 3 + (40 * 9)

        jsr WaitRoutine

        ldx CharAnimationFrameStep2
        cpx #$0a
        bne CheckCharAnimationFrameStep2
        lda LEFT_SMOKE
        cmp #$7e
        beq AddChar
        dec LEFT_SMOKE
        dec STAR1
        dec STAR6
        inc STAR5_R
        jmp CheckCharAnimationFrameStep2
    AddChar:
        inc LEFT_SMOKE
        inc STAR1
        inc STAR6
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
        sta VIC.BORDER_COLOR            // Border color
        lda #$00
        sta VIC.BACKGROUND_COLOR        // Background color
        lda #$00
        sta VIC.EXTRA_BACKGROUND1       // Extra background color #1
        lda #$01
        sta VIC.EXTRA_BACKGROUND2       // Extra background color #2

        rts
}

DrawIntroMap: {
        ldx #$00
    LoopMap:
        lda CHAR_INTRO_MAP, x           // Get data from map
        sta SCREEN_RAM, x               // Put data into SCREEN RAM
        lda CHAR_INTRO_MAP + $100, x    // Fetch the next 256 bytes of data from binary
        sta SCREEN_RAM + $100, x        // Store the next 256 bytes to screen
        lda CHAR_INTRO_MAP + $200, x    // ... and so on
        sta SCREEN_RAM + $200, x
        lda CHAR_INTRO_MAP + $2e8, x
        sta SCREEN_RAM + $2e8, x
        inx                             // Increment accumulator until 256 bytes read
        bne LoopMap

        ldx #$00
    LoopCols:
        ldy SCREEN_RAM, x           // Read screen position
        lda COLOR_MAP, y            // Read attributes table
        sta $d800, x                // Store to COLOUR RAM
        ldy SCREEN_RAM + $100, x    // Read next 256 screen positions
        lda COLOR_MAP, y            // Store to COLOUR RAM + $100
        sta $d900, x                // ... and so on
        ldy SCREEN_RAM + $200, x
        lda COLOR_MAP, y
        sta $da00, x
        ldy SCREEN_RAM + $2e8, x
        lda COLOR_MAP, y
        sta $dae8, x
        inx                         // Increment accumulator until 256 bytes read
        bne LoopCols

        rts
}

* = $c300 "IntroMap"
CHAR_INTRO_MAP:
    .import binary "./assets/intro-map.bin"
