.label ZP_TEMP = $02
.label ZeroPage1 = $fb
.label ZeroPage2 = $fc
.label ZeroPage3 = $fd
.label ZeroPage4 = $fe

BasicUpstart2(Entry)

Entry:
        sei
        lda #$7f
        sta CIA.IRQ_CONTROL
        sta CIA.NMI_IRQ_CONTROL

        lda #%00110101              // Bit 0-2:
        sta $01                     // RAM visible at $a000-$bfff and $e000-$ffff
                                    // I/O area visible at $d000-$dfff

        lda #%00000010
        sta VIC.BANK                // Select Vic Bank #1, $4000-$7fff

        lda #%00000010
        sta VIC.MEMORY_CONTROL      // Pointer to char memory $0800-$0fff
                                    // Pointer to screen memory $0000-$03ff

        lda VIC.SCREEN_CONTROL2     // Screen control register #2
        and #%11110111
        ora #%00010111
        sta VIC.SCREEN_CONTROL2     // Horizontal raster scroll
                                    // 38 columns
                                    // Multicolor mode on

        lda #<Split01
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split01
        sta MEMORY.INT_SERVICE_HIGH
        lda #$ff
        sta VIC.RASTER_LINE         // Raster line at $ff
        lda VIC.SCREEN_CONTROL1     // Screen control register #1
        and #%01111111
        sta VIC.SCREEN_CONTROL1     // Vertical raster scroll
                                    // 25 rows
                                    // Screen on
                                    // Bitmap mode on
                                    // Extended background mode on

// End setup region, start game
        jmp GameMainLoop

GameMainLoopInit: {
        jsr GameIntro               // Show game intro (until fire pressed)

        lda #%00000001
        sta VIC.INTERRUPT_CTRL      // Raster interrupt enabled
                                    // Sprite-background collision interrupt disabled
                                    // Sprite-sprite collision interrupt disabled
                                    // Light pen interrupt disabled

        asl $d019                   // Interrupt status register

        jsr InitSound

        jsr InitScreen
        jsr SetupSprites

        jsr ClearScreen

        ldx #$00
        jsr DrawMainMap

        cli
        rts
}

GameMainLoop: {
        jsr GameMainLoopInit
    !Loop:
        lda FrameFlag
        beq !Loop-
        lda #$00
        sta FrameFlag

        jsr GetJoystickMove

        lda Direction
        cmp #$00
        bne !SomeMovement+
        lda DirectionY
        cmp #$00
        bne !SomeMovement+
        jmp !NoMove+
    !SomeMovement:
        jsr MoveSanta
        jsr MoveGiftOnDirection
        jsr ScrollLandscape
        jsr ScrollForeground
        jsr SwitchSantaFrame
        jsr StartSantaJumpOrLand
    !NoMove:
        jsr ManageSantaJumpOrLand
        jsr MayGiftExplode
        jsr MoveSleigh
        jsr ScrollChars
        jsr DetectGiftCollision

        jmp !Loop-
}

GameEnded:
    .byte $00

FrameFlag:
    .byte $00

MapPositionBottom:
    .byte $07, $00  //Frac/Full
MapPositionLandscape:
    .byte $07, $00  //Frac/Full

MapSpeed:
    .byte $01,$01
Orientation:        // Actual Santa orientation
    .byte $01       // $01 - right, $ff - left
Direction:          // Actual game direction
    .byte $01       // $00 - no move, $01 - right, $ff - left
DirectionY:         // Actual Santa vertical direction
    .byte $ff       // $00 - no move, $01 - down, $ff - up

FirePressed:
    .byte $00       // Fire pressed = $ff

    /*
ScrollSprites: {
        lda Direction
        bpl !+
        clc
        lda SpritePositions + 0
        adc SpriteSpeed
        sta SpritePositions + 0
        lda SpritePositions + 1
        adc #$00
        and #$01
        sta SpritePositions + 1
        rts

    !:
        sec
        lda SpritePositions + 0
        sbc SpriteSpeed
        sta SpritePositions + 0
        lda SpritePositions + 1
        sbc #$00
        and #$01
        sta SpritePositions + 1
    !exit:
        rts
}
        */
/*
ScrollTimer:
    .byte $00
    */
ScrollChars: {
    /*
        inc ScrollTimer

        lda Direction
        beq !end+
        bpl !forward+

    !backward:
        ldx #$07
    !Loop:
        lda $4a00, x
        asl
        adc #$00
    !:
        sta $4a00, x
        dex
        bpl !Loop-
        jmp !end+


    !forward:
    //4a00
        ldx #$07
    !Loop:
        lda $4a00, x
        lsr
        bcc !+
        ora #$80
    !:
        sta $4a00, x
        dex
        bpl !Loop-


    !end:
        lda ScrollTimer
        and #$03
        bne !end+

        ldy $4a07
        ldx #$06
    !Loop:
        lda $4a00, x
        sta $4a01, x
        dex
        bpl !Loop-
        sty $4a00

    !end:
    */
        rts
}


Split01: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

//      lda #$00
//      sta VIC.BACKGROUND_COLOR            // BACKGROUND COLOR

/*
        // Remove borders
        lda VIC.SCREEN_CONTROL1         // Screen control register #1
        and #%11110111
        sta VIC.SCREEN_CONTROL1         // Screen control register #1

        lda #$ff
        lda VIC.SCREEN_CONTROL1         // Screen control register #1
        bpl *-3

        lda VIC.SCREEN_CONTROL1         // Screen control register #1
        ora #%00001000
        sta VIC.SCREEN_CONTROL1         // Screen control register #1
*/
        inc FrameFlag

/*
        //STATIC SECTION
        lda #%0010000
        sta VIC.SCREEN_CONTROL2         // Screen control register #2
*/

/*
        //Do sprites
        clc
        lda #$00
        ldy #$00
    !:
        sta VIC.SPRITE_0_Y, y
        adc #$15
        iny
        iny
        cpy #$10
        bne !-

        lda SpritePositions + 0
        ldy #$00
    !:
        sta VIC.SPRITE_0_X, y
        iny
        iny
        cpy #$10
        bne !-

        ldx #$00
        lda SpritePositions + 1
        beq !+
        ldx #$ff
    !:
        stx VIC.SPRITE_EXTRAX
*/

        lda #<Split01a
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split01a
        sta MEMORY.INT_SERVICE_HIGH
        lda #$00
        sta VIC.RASTER_LINE             // Raster line
        lda VIC.SCREEN_CONTROL1         // Screen control register #1
        and #%01111111
        sta VIC.SCREEN_CONTROL1     // Vertical raster scroll
                                    // 25 rows
                                    // Screen on
                                    // Bitmap mode on
                                    // Extended background mode on

    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019
        rti
}

Split01a: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

//      lda #$00
//      sta VIC.BACKGROUND_COLOR
//      lda #$00
//      sta $d022
//      lda #$01
//      sta $d023

        //landscape
        lda #%0010000
        sta VIC.SCREEN_CONTROL2         // Screen control register #2


        lda #<Split02
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split02
        sta MEMORY.INT_SERVICE_HIGH
        lda #$4a                        // Raster line $4a - 74
        sta VIC.RASTER_LINE
    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019               // Interrupt status register
        rti
}

Split02: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

        // Landscape
        lda MapPositionLandscape + 0
        ora #%00010000
        sta VIC.SCREEN_CONTROL2

        lda #<Split03
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split03
        sta MEMORY.INT_SERVICE_HIGH
        lda #$81                        // Raster line $81 - 129
        sta VIC.RASTER_LINE
    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019               // Interrupt status register
        rti
}

Split03: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

        // Foreground
        // waste some cycles to stabilize the line
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        lda MapPositionBottom + 0
        ora #%00010000
        sta VIC.SCREEN_CONTROL2

        lda #<Split03aa
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split03aa
        sta MEMORY.INT_SERVICE_HIGH
        lda #$a6
        sta VIC.RASTER_LINE

    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019
        rti
}

Split03aa: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

/*
        clc
        lda #$a8
        ldy #$00
    !:
        sta VIC.SPRITE_0_Y, y
        adc #$15
        iny
        iny
        cpy #$10
        bne !-
*/

        lda #<Split03a
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split03a
        sta MEMORY.INT_SERVICE_HIGH
        lda #$d1
        sta VIC.RASTER_LINE

    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019
        rti
}

Split03a: {
        sta ModA + 1
        stx ModX + 1
        sty ModY + 1

        //Foreground
        lda VIC.RASTER_LINE
        cmp VIC.RASTER_LINE
        bne *-3

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        lda #$00
        sta VIC.EXTRA_BACKGROUND1
        lda #$01
        sta VIC.EXTRA_BACKGROUND2

        lda #<Split01
        sta MEMORY.INT_SERVICE_LOW
        lda #>Split01
        sta MEMORY.INT_SERVICE_HIGH
        lda #$fa
        sta VIC.RASTER_LINE

    ModA:
        lda #$00
    ModX:
        ldx #$00
    ModY:
        ldy #$00
        asl $d019
        rti
}

* = * "ShiftMap"
ShiftMap: {
        txa
        clc
        adc #$26
        tax

        .for(var i=10; i< 25; i++) {
            .for(var j=0; j<38; j++) {
                lda SCREEN_RAM + $28 * i + j + 1
                sta SCREEN_RAM + $28 * i + j + 0
                lda VIC.COLOR_RAM + $28 * i + j + 1
                sta VIC.COLOR_RAM + $28 * i + j + 0
            }
            lda CHAR_MAP + $100 * i, x
            sta SCREEN_RAM + $28 * i + $26
            tay
            lda COLOR_MAP, y
            sta VIC.COLOR_RAM + $28 * i + $26
        }
        rts
}

ShiftMapLandscape: {
        txa
        clc
        adc #$26
        tax

        .for(var i=3; i< 10; i++) {
            .for(var j=0; j<38; j++) {
                lda SCREEN_RAM + $28 * i + j + 1
                sta SCREEN_RAM + $28 * i + j + 0
            }
            lda CHAR_MAP + $100 * i, x
            sta SCREEN_RAM + $28 * i + $26
        }
        rts
}

ShiftMapLandscapeBack: {
        .for(var i=3; i< 10; i++) {
            .for(var j=37; j>=0; j--) {
                lda SCREEN_RAM + $28 * i + j + 0
                sta SCREEN_RAM + $28 * i + j + 1
            }
            lda CHAR_MAP + $100 * i, x
            sta SCREEN_RAM + $28 * i
        }
        rts
}

//Map data
* = $8000 "Map"
CHAR_MAP:
    .import binary "./assets/map.bin"
* = * "ColorMap"
COLOR_MAP:
    .import binary "./assets/cols.bin"

// Bank #1, $4000-$7FFF
// Screen at $4000
// CharSet at $4800
.label SCREEN_RAM = $4000
* = $4800 "Charset"
    .import binary "./assets/chars.bin"
* = $5000 "Sprites"
    .import binary "./assets/sprites.bin"

* = $7fff
    .byte $00

* = $a000 "ShiftMapBack"
ShiftMapBack: {
        .for(var i=10; i< 25; i++) {
            .for(var j=37; j>=0; j--) {
                lda SCREEN_RAM + $28 * i + j + 0
                sta SCREEN_RAM + $28 * i + j + 1
                lda VIC.COLOR_RAM + $28 * i + j + 0
                sta VIC.COLOR_RAM + $28 * i + j + 1
            }
            lda CHAR_MAP + $100 * i, x
            sta SCREEN_RAM + $28 * i
            tay
            lda COLOR_MAP, y
            sta VIC.COLOR_RAM + $28 * i

        }
        rts
}

#import "label.asm"
#import "utils.asm"
#import "scrolling.asm"
#import "sprites.asm"
#import "screen.asm"
#import "sound.asm"
#import "joystick.asm"
#import "intro.asm"
