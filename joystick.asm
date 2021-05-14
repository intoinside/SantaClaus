
GetJoystickMove: {
		ldx #$00
		lda $dc00
		lsr
		bcs !NoUp+
		ldx #$ff
	!NoUp:
		lsr
		bcs !NoDown+
	!NoDown:
		stx DirectionY
		ldx #$00
		lsr
		bcs !NoLeft+
		ldx #$ff
		stx Orientation
	!NoLeft:
		lsr
		bcs !NoRight+
		ldx #$01
		stx Orientation
	!NoRight:
		stx Direction
		ldx #$00
		lsr
		bcs !NoFirePressed+
		ldx #$ff
	!NoFirePressed:
		stx FirePressed
		rts
}
