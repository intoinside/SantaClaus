; ========================================
; Project   : Santa Claus
; Target    : Commodore 64
; Comments  : 
; Author    : Raffaele Intorcia (raffaele.intorcia@gmail.com)
; ========================================
!TO "SANTACLAUS.PRG,CBM

; 10 SyS (2304)
*=$0801
        byte $0e, $08, $0A, $00, $9e, $20
        byte $28, $32, $33, $30, $34, $29 
        byte $00, $00, $00

*=$0900
        jsr init_screen
        jsr draw_map

; main application rountine
main_loop
        jmp main_loop


draw_map
        ldx #$0
draw_map_loop
        lda map,x
        sta $0400,x
        lda map+$100,x
        sta $0500,x
        lda map+$200,x
        sta $0600,x
        lda map+$2e8,x
        sta $06e8,x
        inx           
        bne draw_map_loop
        ldx #$00
setup_map_color_loop
        ldy $0400,x
        lda attribs,y
        sta $d800,x
        ldy $0500,x
        lda attribs,y
        sta $d900,x
        ldy $0600,x
        lda attribs,y
        sta $da00,x
        ldy $06e8,x
        lda attribs,y
        sta $dae8,x
        inx
        bne setup_map_color_loop
        rts

init_screen
        sei
        lda #$37
        sta $01
        lda #%00011000
        sta SCREEN_CTRL         ;Screen Multicolour mode enabled
        sta MEMORY_SETUP        ;Charset mode set to display custom char $2000-$2800
        lda #$06                ;Set border and background colour
        sta BORDER_COLOR
        sta BACKGROUND_COLOR
        lda #$00
        sta EXTRA_BACKGROUND1   ;Char Multicolour 1
        lda #$01
        sta EXTRA_BACKGROUND2   ;Char Multicolour 2
        rts


; Resources and includes
*=$2000
incbin "charset.bin"

*=$2300
attribs
incbin "charset-attributes.bin"

*=$2400
map
incbin "map.bin"

IncAsm "label.asm"