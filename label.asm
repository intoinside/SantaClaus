
VIC: {
	.label PROC_PORT			= $0001

	.label SCREEN_RAM			= $0400
	.label COLOR_RAM			= $d800

	.label SPRITE_ENABLE		= $d015
	.label SPRITE_MULTICOLOR	= $d01c
	.label SPRITE_EXTRACOLOR1	= $d025
	.label SPRITE_EXTRACOLOR2	= $d026

	.label SPRITE_0_X			= $d000
	.label SPRITE_0_Y			= $d001
	.label SPRITE_1_X			= $d002
	.label SPRITE_1_Y			= $d003
	.label SPRITE_2_X			= $d004
	.label SPRITE_2_Y			= $d005
	.label SPRITE_3_X			= $d006
	.label SPRITE_3_Y			= $d007
	.label SPRITE_4_X			= $d008
	.label SPRITE_4_Y			= $d009
	.label SPRITE_5_X			= $d00a
	.label SPRITE_5_Y			= $d00b
	.label SPRITE_6_X			= $d00c
	.label SPRITE_6_Y			= $d00d
	.label SPRITE_7_X			= $d00e
	.label SPRITE_7_Y			= $d00f

	.label SPRITE_EXTRAX		= $d010

	.label RASTER_LINE			= $d012

	.label SCREEN_CONTROL1		= $d011
	.label SCREEN_CONTROL2		= $d016
	.label BANK					= $dd00
	.label MEMORY_CONTROL		= $d018

	.label BORDER_COLOR			= $d020
	.label BACKGROUND_COLOR		= $d021

	.label EXTRA_BACKGROUND1	= $d022
	.label EXTRA_BACKGROUND2	= $d023
	.label EXTRA_BACKGROUND3	= $d024
}

MEMORY: {
	.label INT_SERVICE_LOW		= $fffe
	.label INT_SERVICE_HIGH		= $ffff
}