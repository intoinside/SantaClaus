.label ZP_TEMP = $02

BasicUpstart2(Entry)

#import "label.asm"
#import "utils.asm"
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

		lda #%10					// Select vic bank
		sta VIC.BANK

		lda #%00000010
		sta VIC.MEMORY_CONTROL		// Memory setup register

		lda VIC.SCREEN_CONTROL2		// Screen control register #2
		and #%11110111
		ora #%00010111
		sta VIC.SCREEN_CONTROL2		// Screen control register #2

		jsr InitScreen

		lda #<Split01
		sta MEMORY.INT_SERVICE_LOW
		lda #>Split01
		sta MEMORY.INT_SERVICE_HIGH
		lda #$ff
		sta VIC.RASTER_LINE 					// Raster line
		lda VIC.SCREEN_CONTROL1		// Screen control register #1
		and #$7f
		sta VIC.SCREEN_CONTROL1		// Screen control register #1

		lda #$01
		sta $d01a

		asl $d019					// Interrupt status register

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
		bcs !NoUp+
		ldx #$ff
	!NoUp:
		lsr
		bcs !NoDown+
		ldx #$01
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

		lda Direction
		cmp #$00
		bne !SomeMovement+
		lda DirectionY
		cmp #$00
		bne !SomeMovement+
		jmp !NoMove+
	!SomeMovement:
		jsr ScrollLandscape
		jsr ScrollForeground
		jsr SwitchSantaFrame
		jsr StartSantaJumpOrLand
	!NoMove:
		jsr ManageSantaJumpOrLand
		jsr MoveSleigh
		jsr ScrollChars

		jmp !Loop-

FrameFlag:
	.byte $00

SpritePositions:
	.byte $80,$00 	//LSB/MSB

MapPositionBottom:
	.byte $07, $00 	//Frac/Full
MapPositionLandscape:
	.byte $07, $00 	//Frac/Full

MapSpeed:
	.byte $01,$01
SpriteSpeed:
	.byte $04

Orientation:		// Actual Santa orientation
	.byte $01 		// $01 - right, $ff - left
Direction:			// Actual game direction
	.byte $01		// $00 - no move, $01 - right, $ff - left
DirectionY:			// Actual Santa vertical direction
	.byte $ff		// $00 - no move, $01 - down, $ff - up

FirePressed:
	.byte $00		// Fire pressed = $ff

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
		*/
	!exit:
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

//		lda #$00
//		sta VIC.BACKGROUND_COLOR 			// BACKGROUND COLOR

		//Remove borders
		lda VIC.SCREEN_CONTROL1			// Screen control register #1
		and #%11110111
		sta VIC.SCREEN_CONTROL1			// Screen control register #1

		lda #$ff
		lda VIC.SCREEN_CONTROL1			// Screen control register #1
		bpl *-3

		lda VIC.SCREEN_CONTROL1			// Screen control register #1
		ora #%00001000
		sta VIC.SCREEN_CONTROL1			// Screen control register #1

		inc FrameFlag

		//STATIC SECTION
		lda #%0010000
		sta VIC.SCREEN_CONTROL2			// Screen control register #2

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
		sta VIC.RASTER_LINE 						// Raster line
		lda VIC.SCREEN_CONTROL1			// Screen control register #1
		and #$7f
		sta VIC.SCREEN_CONTROL1			// Screen control register #1
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

//		lda #$00
//		sta VIC.BACKGROUND_COLOR
//		lda #$00
//		sta $d022
//		lda #$01
//		sta $d023

		//landscape
		lda #%0010000
		sta VIC.SCREEN_CONTROL2				// Screen control register #2


		lda #<Split02
		sta MEMORY.INT_SERVICE_LOW
		lda #>Split02
		sta MEMORY.INT_SERVICE_HIGH
		lda #$4a
		sta VIC.RASTER_LINE				// Raster line
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
		sta VIC.SCREEN_CONTROL2

		lda #<Split03
		sta MEMORY.INT_SERVICE_LOW
		lda #>Split03
		sta MEMORY.INT_SERVICE_HIGH
		lda #$81
		sta VIC.RASTER_LINE
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
COLOR_MAP:
	.import binary "./assets/cols.bin"

//VIC BANK
//$c000-MEMORY.INT_SERVICE_HIGH
//screen at $c000
//char set at $c800
.label SCREEN_RAM = $4000
* = $4800 "Charset"
	.import binary "./assets/chars.bin"
* = $4b00 "Sprites"
	.import binary "./assets/sprites.bin"

* = $7fff
	.byte $00

*=$a000
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
