
initSound: {
		lda #0
		sta SID.VOICE1_FREQ_1
		lda #10
		sta SID.VOICE1_FREQ_2
		lda #04
		sta SID.VOICE1_ATTACK_DECAY
		lda #$19
		sta SID.VOICE1_SUSTAIN_RELEASE
		lda #15
		sta SID.VOLUME_FILTER_MODES
		rts
}

playGiftExplosion: {
		ldx #$05
		stx SID.VOICE1_FREQ_2
		lda #%00000111					// 0 sustain volume, 240ms release
		sta SID.VOICE1_SUSTAIN_RELEASE
		lda #%00001010					// 2ms attack, 300ms decay
		sta SID.VOICE1_ATTACK_DECAY

		lda #%00000000
		sta SID.VOICE1_CTRL

		lda #%10000001     		// Noise for explosion
		sta SID.VOICE1_CTRL

	End:
		rts
}
