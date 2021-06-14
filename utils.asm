
MaxNumberGenerator:
    .byte $00
RandomNumber:
    .byte $00

GetRandomNumber: {
        lda $d012
        eor $dc04
        sbc $dc05
        cmp MaxNumberGenerator
        bcs GetRandomNumber
        sta RandomNumber
        rts
}

WaitRoutine: {
    VBLANKWAITLOW:
        lda $d011
        bpl VBLANKWAITLOW
    VBLANKWAITHIGH:
        lda $d011
        bmi VBLANKWAITHIGH
        rts
}

StupidWaitRoutine: {
        ldy #$bf
    LoopY:
        ldx #$ff
    LoopX:
        nop
        nop
        dex
        bne LoopX
        dey
        bne LoopY
        rts
}
