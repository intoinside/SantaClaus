
CurrentPower:
    .byte $00

InitScreen: {
        lda #$06
        sta VIC.BORDER_COLOR            // Border color
        lda #$06
        sta VIC.BACKGROUND_COLOR        // Background color

        lda #$00
        sta VIC.EXTRA_BACKGROUND1       // Extra background color #1
        lda #$01
        sta VIC.EXTRA_BACKGROUND2       // Extra background color #2

        lda #$08
        sta CurrentPower
}

UpdateScore: {
        ldy #10
        dey
    UpdateScoreImpl:
        inc SCREEN_RAM + $0c
        lda SCREEN_RAM + $0c
        cmp #$59                // >9? (the #0 in the charset is $30,up to $39 for the #9)
        bne Done                // if not, stop
        lda #$50                // else reset last digit to "0" ($30)
        sta SCREEN_RAM + $0c
        inc SCREEN_RAM + $0b    // increase left digit
        lda SCREEN_RAM + $0b    // start again with the other digit
        cmp #$59
        bne Done
        lda #$50
        sta SCREEN_RAM + $0b
        inc SCREEN_RAM + $0a
        lda SCREEN_RAM + $0a
        cmp #$59
        bne Done
        lda #$50
        sta SCREEN_RAM + $0a
        inc SCREEN_RAM + $09
    Done:
        dey
        bne UpdateScoreImpl
        rts
}

DrawCurrentPowerBar: {
        ldx #7
    Loop:
        cpx CurrentPower
        bcs IsZero
        lda #$0f
        jmp UpdateBarItem
    IsZero:
        lda #$0a
    UpdateBarItem:
        sta $d819, x                // Store to COLOUR RAM
        dex
        bne Loop
        rts
}

ClearScreen: {
        lda #$00
        ldx #$00
    !:
        sta SCREEN_RAM, x
        sta SCREEN_RAM + $100, x
        sta SCREEN_RAM + $200, x
        dex
        bne !-
        ldx #$f7
    !:
        sta SCREEN_RAM + $300, x
        dex
        bne !-

        rts
}

DrawMainMap: {
        lda #>SCREEN_RAM
        sta ScrMod + 2
        lda #$d8
        sta ColMod + 2
        lda #$00
        sta ScrMod + 1
        sta ColMod + 1

        lda #>CHAR_MAP
        sta MapMod + 2
        stx MapMod + 1

        ldy #$19
        sty ZP_TEMP
    !OuterLoop:
        ldx #$27
    !Loop:
    MapMod:
        lda $BEEF, x
    ScrMod:
        sta $BE00, x
        tay
        lda COLOR_MAP, y
    ColMod:
        sta $BE00, x
        dex
        bpl !Loop-

        inc MapMod + 2

        clc
        lda ScrMod + 1
        adc #$28
        sta ScrMod + 1
        sta ColMod + 1
        bcc !+
        inc ScrMod + 2
        inc ColMod + 2
    !:
        dec ZP_TEMP
        bne !OuterLoop-

        rts
}
