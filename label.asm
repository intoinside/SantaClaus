
VIC: {
	.label PROC_PORT			= $0001

	.label SCREEN_RAM			= $0400
	.label COLOR_RAM			= $d800

	.label SPRITE_ENABLE		= $d015
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