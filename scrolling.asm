
ScrollForeground: {
        lda Direction
        beq !NoShift+
        bpl !Forward+

    !Backward:
        //Increment map-position
        lda MapPositionBottom + 0
        clc
        adc MapSpeed
        sta MapPositionBottom + 0
        cmp #$08
        bcc !NoShift+
        //Shift map
        sbc #$08
        sta MapPositionBottom + 0
        dec MapPositionBottom + 1
        ldx MapPositionBottom + 1
        jsr ShiftMapBack
    !NoShift:
        rts

    !Forward:
        //Increment map-position
        lda MapPositionBottom + 0
        sec
        sbc MapSpeed
        sta MapPositionBottom + 0
        bcs !NoShift+
        //Shift map
        adc #$08
        sta MapPositionBottom + 0
        inc MapPositionBottom + 1
        ldx MapPositionBottom + 1
        jsr ShiftMap
    !NoShift:
        rts
}

ScrollLandscape: {
        lda Direction
        beq !NoShift+
        bpl !Forward+

    !Backward:
        //Increment map-position
        lda MapPositionLandscape + 0
        clc
        adc MapSpeed + 1
        sta MapPositionLandscape + 0
        cmp #$08
        bcc !NoShift+

        //Shift map
        sbc #$08
        sta MapPositionLandscape + 0
        dec MapPositionLandscape + 1
        ldx MapPositionLandscape + 1
        jsr ShiftMapLandscapeBack
    !NoShift:
        rts

    !Forward:
        //Increment map-position
        lda MapPositionLandscape + 0
        sec
        sbc MapSpeed + 1
        sta MapPositionLandscape + 0
        bcs !NoShift+
        //Shift map
        adc #$08
        sta MapPositionLandscape + 0
        inc MapPositionLandscape + 1
        ldx MapPositionLandscape + 1
        jsr ShiftMapLandscape
    !NoShift:
        rts
}
