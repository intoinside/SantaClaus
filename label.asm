
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

	.label COLLISION_REGISTRY   = $d01f

	.label RASTER_LINE			= $d012

	.label SCREEN_CONTROL1		= $d011
	.label SCREEN_CONTROL2		= $d016
	.label BANK					= $dd00
	.label MEMORY_CONTROL		= $d018

	.label INTERRUPT_CTRL		= $d01a

	.label BORDER_COLOR			= $d020
	.label BACKGROUND_COLOR		= $d021

	.label EXTRA_BACKGROUND1	= $d022
	.label EXTRA_BACKGROUND2	= $d023
	.label EXTRA_BACKGROUND3	= $d024
}

SID: {
	.label VOICE1_FREQ_1		= $d400
	.label VOICE1_FREQ_2		= $d401
	.label VOICE1_CTRL			= $d404
	.label VOICE1_ATTACK_DECAY	= $d405
	.label VOICE1_SUSTAIN_RELEASE	= $d406
	.label VOLUME_FILTER_MODES	= $d418
}

CIA: {
	.label IRQ_CONTROL			= $dc0d
	.label NMI_IRQ_CONTROL		= $dd0d
}

MEMORY: {
	.label INT_SERVICE_LOW		= $fffe
	.label INT_SERVICE_HIGH		= $ffff
}

wScreenRAMRowStart: // SCREEN_RAM + 40*0, 40*1, 40*2, 40*3, 40*4 ... 40*24
    .word SCREEN_RAM,     SCREEN_RAM+40,  SCREEN_RAM+80,  SCREEN_RAM+120, SCREEN_RAM+160
    .word SCREEN_RAM+200, SCREEN_RAM+240, SCREEN_RAM+280, SCREEN_RAM+320, SCREEN_RAM+360
    .word SCREEN_RAM+400, SCREEN_RAM+440, SCREEN_RAM+480, SCREEN_RAM+520, SCREEN_RAM+560
    .word SCREEN_RAM+600, SCREEN_RAM+640, SCREEN_RAM+680, SCREEN_RAM+720, SCREEN_RAM+760
    .word SCREEN_RAM+800, SCREEN_RAM+840, SCREEN_RAM+880, SCREEN_RAM+920, SCREEN_RAM+960

wColorRAMRowStart: // VIC.COLOR_RAM + 40*0, 40*1, 40*2, 40*3, 40*4 ... 40*24
    .word VIC.COLOR_RAM,     VIC.COLOR_RAM+40,  VIC.COLOR_RAM+80,  VIC.COLOR_RAM+120, VIC.COLOR_RAM+160
    .word VIC.COLOR_RAM+200, VIC.COLOR_RAM+240, VIC.COLOR_RAM+280, VIC.COLOR_RAM+320, VIC.COLOR_RAM+360
    .word VIC.COLOR_RAM+400, VIC.COLOR_RAM+440, VIC.COLOR_RAM+480, VIC.COLOR_RAM+520, VIC.COLOR_RAM+560
    .word VIC.COLOR_RAM+600, VIC.COLOR_RAM+640, VIC.COLOR_RAM+680, VIC.COLOR_RAM+720, VIC.COLOR_RAM+760
    .word VIC.COLOR_RAM+800, VIC.COLOR_RAM+840, VIC.COLOR_RAM+880, VIC.COLOR_RAM+920, VIC.COLOR_RAM+960
