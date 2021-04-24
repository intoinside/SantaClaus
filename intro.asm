
InitIntro: {
		lda #$00
		sta VIC.BORDER_COLOR			// Border color
		lda #$00
		sta VIC.BACKGROUND_COLOR		// Background color

		jsr ClearScreen
		rts
}

GameIntro: {
		jsr InitIntro

		// Draw introscreen

	NoFirePressed:
		jsr GetJoystickMove
		lda FirePressed
		beq NoFirePressed

		rts
}