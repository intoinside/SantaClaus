
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