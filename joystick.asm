
GetJoystickMove: {
		ldx #$00
		lda $dc00
		ldy GameEnded
		bne CheckOnlyFirePress
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

	CheckOnlyFirePress:
		jsr GetOnlyFirePress
		rts
}

// A should contain joystick register read
GetOnlyFirePress: {
		ldx #$00
		lsr
		lsr
		lsr
		lsr
		lsr
		bcs !NoFirePressed+
		ldx #$ff
	!NoFirePressed:
		stx FirePressed
		rts
}