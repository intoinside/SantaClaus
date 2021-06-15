
GameIntro: {
        jsr InitIntro
        jsr DrawIntroMap
        jsr SetupIntroSprites
        jsr StupidWaitRoutine

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

SetupIntroSprites: {
        lda #SpritePointers.SANTA_RIGHT
        sta SCREEN_RAM + $03f8 + $00
        lda #SpritePointers.SANTAS_RIGHT
        sta SCREEN_RAM + $03f8 + $01
        lda #SpritePointers.GIFT
        sta SCREEN_RAM + $03f8 + $02

        lda #%00000111
        sta VIC.SPRITE_MULTICOLOR

        lda #$00
        sta $d027           // Santa Sprite
        lda #$01
        sta $d028           // Santa shadow Sprite
        sta $d029           // Gift Sprite

        lda #$02
        sta VIC.SPRITE_EXTRACOLOR1
        lda #$08
        sta VIC.SPRITE_EXTRACOLOR2

        lda #%00000111
        sta VIC.SPRITE_ENABLE

// Y Positioning
        lda #Santa.Y
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y
        sta VIC.SPRITE_2_Y

// X Positioning
        lda #$5a                // Santa and Santa shadow position
        sta VIC.SPRITE_0_X
        sta VIC.SPRITE_1_X
        lda #$c0                // Gift position
        sta VIC.SPRITE_2_X

        lda #$00                // Sprite extra-x bit set to 0
        sta VIC.SPRITE_EXTRAX

        rts
}

AnimateAllSnowFlakes: {
        .for(var i = 0; i < 10; i++) {
            ldx SnowFlakesX + i
            ldy SnowFlakesY + i
            jsr AnimateSnowFlake
            sty SnowFlakesY + i
        }

        rts
}

// Snowflakes start x/y position
SnowFlakesX:
    .byte $04, $07, $0a, $0e, $12, $17, $1b, $1e, $22, $25
SnowFlakesY:
    .byte $0a, $05, $0c, $01, $08, $15, $0b, $12, $00, $0b
SnowFlakeXPtr:
    .byte $00
SnowFlakeYPtr:
    .byte $00

AnimateSnowFlake: {
    .label SNOW_FLAKE_CHAR  = $9e
    .label SNOW_FLAKE_COLOR = $0b

        stx SnowFlakeXPtr
        sty SnowFlakeYPtr

    UpdateSnowFlakes:
        ldx CharAnimationFrame
        cpx #$03
        bne End

        // Remove snow flake position from old position
        lda SnowFlakeYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wScreenRAMRowStart, y   // load low address byte
        sta ZeroPage1
        lda wScreenRAMRowStart + 1, y   // load high address byte
        sta ZeroPage2
        ldy SnowFlakeXPtr          // load x position into y register
        lda (ZeroPage1), y
        cmp #SNOW_FLAKE_CHAR
        bne CheckNewPosition
        lda #$00
        sta (ZeroPage1), y

    CheckNewPosition:
        inc SnowFlakeYPtr

        // Check if new snow flake position is already used
        lda SnowFlakeYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wScreenRAMRowStart, y   // load low address byte
        sta ZeroPage1
        lda wScreenRAMRowStart + 1, y   // load high address byte
        sta ZeroPage2
        ldy SnowFlakeXPtr          // load x position into Y register
        lda (ZeroPage1), y
        bne CheckYReset             // New snow flake position already used

        // New position is free, setting snow flake char
        lda #SNOW_FLAKE_CHAR
        sta (ZeroPage1), y

        // Set color for new position
        lda SnowFlakeYPtr          // load y position as index into list
        asl                         // X2 as table is in words
        tay                         // Copy A to Y
        lda wColorRAMRowStart, y    // load low address byte
        sta ZeroPage1
        lda wColorRAMRowStart+1, y  // load high address byte
        sta ZeroPage2
        ldy SnowFlakeXPtr          // load x position into Y register
        lda #SNOW_FLAKE_COLOR
        sta (ZeroPage1), y

    CheckYReset:
        ldy SnowFlakeYPtr
        cpy #$18
        beq ResetYCounter
        jmp End

    ResetYCounter:                  // Snow flake on the floor, restart
        ldy #$00
        sty SnowFlakeYPtr

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
        cmp #$7c
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
        cmp #$7c
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

* = $c500 "IntroMap"
CHAR_INTRO_MAP:
    .import binary "./assets/intro-map.bin"
