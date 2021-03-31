.label ZP_TEMP = $02

BasicUpstart2(Entry)

#import "scrolling.asm"
#import "sprites.asm"
#import "screen.asm"

Entry:
		sei
		lda #$7f
		sta $dc0d
		sta $dd0d

		lda #$35
		sta $01

		lda #%10			//Select vic bank
		sta $dd00

		lda #%00000010
		sta $d018			// Memory setup register

		lda $d016			// Screen control register #2
		and #%11110111
		ora #%00010111
		sta $d016			// Screen control register #2

		lda #$06
		sta $d020			// Border color
		lda #$06
		sta $d021			// Background color

		lda #$00
		sta $d022  			// Extra background color #1
		lda #$01
		sta $d023			// Extra background color #2

		lda #<Split01
		sta $fffe
		lda #>Split01
		sta $ffff
		lda #$ff
		sta $d012 			// Raster line
		lda $d011			// Screen control register #1
		and #$7f
		sta $d011			// Screen control register #1

		lda #$01
		sta $d01a

		asl $d019			// Interrupt status register

		jsr SetupSprites

		ldx #$00
		jsr DrawMapFull2
		cli

	!Loop:
		lda FrameFlag
		beq !Loop-
		lda #$00
		sta FrameFlag


		//Do shifts here
		ldx #$00
		lda $dc00
		lsr
		lsr
		lsr
		bcs !NoLeft+
		ldx #$ff
	!NoLeft:
		lsr
		bcs !NoRight+
		ldx #$01
	!NoRight:

		stx Direction
		

		lda Direction
		beq !NoMove+
//		jsr ScrollSprites
		jsr ScrollLandscape
		jsr ScrollForeground
	!NoMove:
		jsr ScrollChars

		jmp !Loop-


FrameFlag:
	.byte $00


SpritePositions:
	.byte $80,$00 	//LSB/MSB


MapPositionBottom:
	.byte $07, $00 //Frac/Full
MapPositionLandscape:
	.byte $07, $00 //Frac/Full	

MapSpeed:
	.byte $01,$01
SpriteSpeed:
	.byte $04
Direction:
	.byte $ff


ScrollSprites: {
/*
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
	!exit:*/
		rts
}

ScrollTimer:
	.byte $00
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

//			lda #$00
//			sta $d021 			// Background color

		//Remove borders
		lda $d011			// Screen control register #1
		and #%11110111
		sta $d011			// Screen control register #1

		lda #$ff
		lda $d011			// Screen control register #1
		bpl *-3

		lda $d011			// Screen control register #1
		ora #%00001000
		sta $d011			// Screen control register #1

		inc FrameFlag

		//STATIC SECTION
		lda #%0010000
		sta $d016			// Screen control register #2

		//Do sprites
		clc
		lda #$00
		ldy #$00
	!:
		sta $d001, y
		adc #$15
		iny
		iny
		cpy #$10
		bne !-

		lda SpritePositions + 0
		ldy #$00
	!:
		sta $d000, y
		iny
		iny
		cpy #$10
		bne !-		

		ldx #$00
		lda SpritePositions + 1
		beq !+
		ldx #$ff
	!:
		stx $d010

		lda #<Split01a
		sta $fffe
		lda #>Split01a
		sta $ffff
		lda #$00
		sta $d012 			// Raster line
		lda $d011			// Screen control register #1
		and #$7f
		sta $d011			// Screen control register #1

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

//		lda #$06
//		sta $d021
//		lda #$00
//		sta $d022
//		lda #$01
//		sta $d023

		//landscape
		lda #%0010000
		sta $d016				// Screen control register #2


		lda #<Split02
		sta $fffe
		lda #>Split02
		sta $ffff
		lda #$4a
		sta $d012				// Raster line
	ModA:
		lda #$00
	ModX:
		ldx #$00
	ModY:
		ldy #$00
		asl $d019				// Interrupt status register
		rti

}

Split02: {

		sta ModA + 1
		stx ModX + 1
		sty ModY + 1

		//landscape

		lda MapPositionLandscape + 0
		ora #%00010000
		sta $d016

		lda #<Split03
		sta $fffe
		lda #>Split03
		sta $ffff
		lda #$81
		sta $d012	
	ModA:
		lda #$00
	ModX:
		ldx #$00
	ModY:
		ldy #$00
		asl $d019				// Interrupt status register
		rti

}

Split03: {

		sta ModA + 1
		stx ModX + 1
		sty ModY + 1

		//Foreground
			//waste some cycles to stabilise the line
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
		sta $d016

		lda #<Split03aa
		sta $fffe
		lda #>Split03aa
		sta $ffff
		lda #$a6
		sta $d012

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

		clc
		lda #$a8
		ldy #$00
	!:
		sta $d001, y
		adc #$15
		iny
		iny
		cpy #$10
		bne !-	


		lda #<Split03a
		sta $fffe
		lda #>Split03a
		sta $ffff
		lda #$d1
		sta $d012	

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
		lda $d012
		cmp $d012
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
		sta $d022
		lda #$01
		sta $d023

		lda #<Split01
		sta $fffe
		lda #>Split01
		sta $ffff
		lda #$fa
		sta $d012

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
				lda $d800 + $28 * i + j + 1
				sta $d800 + $28 * i + j + 0
			}
			lda CHAR_MAP + $100 * i, x	
			sta SCREEN_RAM + $28 * i + $26
			tay
			lda COLOR_MAP, y
			sta $d800 + $28 * i + $26

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
* =$8000
CHAR_MAP:
	.import binary "./assets/map.bin"
COLOR_MAP:
	.import binary "./assets/cols.bin"

//VIC BANK
//$c000-$ffff
//screen at $c000
//char set at $c800
.label SCREEN_RAM = $4000
//* = $4400 "sprites"
//	.import binary "./assets/sprites.bin"
* = $4800 "Charset"
	.import binary "./assets/chars.bin"

* = $7fff
	.byte $00

*=$a000
ShiftMapBack: {
		.for(var i=10; i< 25; i++) {
			.for(var j=37; j>=0; j--) {
				lda SCREEN_RAM + $28 * i + j + 0
				sta SCREEN_RAM + $28 * i + j + 1
				lda $d800 + $28 * i + j + 0
				sta $d800 + $28 * i + j + 1
			}
			lda CHAR_MAP + $100 * i, x	
			sta SCREEN_RAM + $28 * i
			tay
			lda COLOR_MAP, y
			sta $d800 + $28 * i

		}
		rts
}
