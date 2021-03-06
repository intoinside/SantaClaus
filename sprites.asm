
ReindeerFrame:
    .byte $00
SantaFrame:
    .byte $00
IsJumping:
    .byte $00
IsLanding:
    .byte Santa.MAX_JUMP
GiftThrown:
    .byte $00
GiftShouldExplode:
    .byte $00
GiftThrownFrame:
    .byte $00
SantaIsCrying:
    .byte $00

Santa: {
    .label Y            = $dd
    .label MAX_JUMP     = $24
}

SpritePointers: {
    .label ELF          = $40
    .label REINDEER_1   = $41
    .label REINDEER_2   = $42
    .label REINDEER_3   = $43
    .label REINDEER_4   = $44
    .label SANTA_LEFT       = $46
    .label SANTAS_LEFT      = $45
    .label SANTA_RIGHT      = $48
    .label SANTAS_RIGHT = $47
    .label SANTA_LANDING_RIGHT  = $54
    .label SANTAS_LANDING_RIGHT = $53
    .label SANTA_JUMP_LEFT      = $52
    .label SANTAS_JUMP_LEFT     = $51
    .label SANTA_LANDING_LEFT   = $50
    .label SANTAS_LANDING_LEFT  = $4f
    .label SANTA_JUMP_RIGHT     = $4e
    .label SANTAS_JUMP_RIGHT    = $4d

    .label GIFT         = $55
    .label GIFT_EXPLOSION_1     = $56

    .label TEARS_1              = $5b
    .label TEARS_2              = $5c
}

DetectGiftCollision: {
        lda GiftThrown              // Check if there is a gift
        beq NoCollision
        lda VIC.SPRITE_COLLISION
        and #%10000000              // Check if gift had a collision
        beq NoCollision
        lda VIC.SPRITE_7_Y
        sbc VIC.SPRITE_0_Y
        cmp #$10
        bcc NoCollision             // Check if gift is far from elf and reindeer
        lda GiftShouldExplode       // Santa is colliding to gift
        beq SantaSavedGift          // Check if gift is exploding
                                    // Gift is exploding

        jmp NoCollision
    SantaSavedGift:                 // Gift is not exploding, gift saved
        jsr ResetGiftExplodeFrame
        jsr UpdateScore
    NoCollision:
        rts
}

SetupSprites: {
        lda #SpritePointers.ELF
        sta SCREEN_RAM + $03f8 + $00
        lda #SpritePointers.REINDEER_1
        sta SCREEN_RAM + $03f8 + $01
        sta SCREEN_RAM + $03f8 + $02
        sta SCREEN_RAM + $03f8 + $03
        sta SCREEN_RAM + $03f8 + $04
        lda #SpritePointers.SANTA_RIGHT
        sta SCREEN_RAM + $03f8 + $05
        lda #SpritePointers.SANTAS_RIGHT
        sta SCREEN_RAM + $03f8 + $06
        lda #SpritePointers.GIFT
        sta SCREEN_RAM + $03f8 + $07

        lda #%11111111
        sta VIC.SPRITE_MULTICOLOR

        lda #$05
        sta $d027           // Elf Sprite #0 color
        lda #$09
        sta $d028           // Reindeer Sprite #1-4 color
        sta $d029
        sta $d02a
        sta $d02b
        lda #$00
        sta $d02c           // Santa Sprite #5 color
        lda #$01
        sta $d02d           // Santa shadow Sprite #6 color
        sta $d02e           // Gift Sprite #7 color

        lda #$02
        sta VIC.SPRITE_EXTRACOLOR1
        lda #$08
        sta VIC.SPRITE_EXTRACOLOR2

        lda #%01111111
        sta VIC.SPRITE_ENABLE

// Y Positioning
        lda #$80                // Sleigh, elf and reindeer Y position
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y
        sta VIC.SPRITE_2_Y
        sta VIC.SPRITE_3_Y
        sta VIC.SPRITE_4_Y

        lda #Santa.Y            // Santa and Santa shadow Y position
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_6_Y

// X Positioning
        lda #$30                // Sleigh, elf X position
        sta VIC.SPRITE_0_X
        lda #$48                // Reindeer 1 X position
        sta VIC.SPRITE_1_X
        lda #$5a                // Reindeer 2 X position
        sta VIC.SPRITE_2_X
        lda #$6c                // Reindeer 3 X position
        sta VIC.SPRITE_3_X
        lda #$7e                // Reindeer 4 X position
        sta VIC.SPRITE_4_X

        lda #$60                // Santa and Santa shadow X position
        sta VIC.SPRITE_5_X
        sta VIC.SPRITE_6_X

        rts
}

SetSantaLikeCrying: {
        lda IsJumping
        bne End                // When IsJumping = 0 => no jump in progress, check if should start a new jump
        lda IsLanding
        cmp #Santa.MAX_JUMP
        bne End

        lda #$00
        sta Direction
        sta DirectionY
        sta IsJumping
        lda #$01
        sta Orientation
        lda #Santa.MAX_JUMP
        sta IsLanding

        lda #SpritePointers.SANTA_RIGHT
        sta SCREEN_RAM + $03f8 + $06
        lda #SpritePointers.SANTAS_RIGHT
        sta SCREEN_RAM + $03f8 + $07    // Reset Santa sprite
        lda #SpritePointers.TEARS_1
        sta SCREEN_RAM + $03f8 + $05    // Add tears sprite

        lda VIC.SPRITE_5_X
        sta VIC.SPRITE_7_X
        lda VIC.SPRITE_5_Y
        sta VIC.SPRITE_7_Y      // Set position as same as Santa

        lda #$03
        sta $d02c               // Set color for tears
        lda #$00
        sta $d02d           // Santa Sprite #5 color
        lda #$01
        sta $d02e           // Santa shadow Sprite #6 color

        lda #%11111111
        sta VIC.SPRITE_ENABLE

        inc SantaIsCrying
    End:
        rts
}

SwitchSantaLikeCrying: {
        lda SantaIsCrying
        beq End

        lda SCREEN_RAM + $03f8 + $05
        cmp #SpritePointers.TEARS_1
        beq SetTearsFrame2
        lda #SpritePointers.TEARS_1
        jmp SetFrame

    SetTearsFrame2:
        lda #SpritePointers.TEARS_2
    SetFrame:
        sta SCREEN_RAM + $03f8 + $05    // Add tears sprite
    End:
        rts
}

RestartGame: {
        lda #$00
        sta FirePressed
        sta GameEnded
        sta SantaIsCrying
        jmp GameMainLoop
}

StartSantaJumpOrLand: {
        lda DirectionY          // Direction up, check for a jump
        cmp #$ff
        bne !+
        lda IsJumping           // No jump in progress, check if a new jump should start
        cmp #$00
        bne !+                  // Already in a jump session, exit
        inc IsJumping           // No jump, start a new jump session
    !:
        rts
}

ManageSantaJumpOrLand: {
        lda IsJumping
        beq Done                // When IsJumping = 0 => no jump in progress, check if should start a new jump
        cmp #Santa.MAX_JUMP
        beq PerformLand         // When IsJumping = SANTA.MAX_JUMP => jump rise is done, start to land
        jmp PerformJump         // When 0 < IsJumping < SANTA.MAX_JUMP => jump rise is in progress, proceed

    PerformLand:
        lda #Santa.Y            // Get default position
        clc
        sbc IsLanding           // Detect and set new position
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_6_Y
        dec IsLanding
        bmi ResetVars           // Landing done, reset vars
        jmp UpdateFrame         // Update sprite frame

    PerformJump:
        lda #Santa.Y            // Get default position
        clc
        sbc IsJumping           // Detect and set new position
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_6_Y
        inc IsJumping
        jmp UpdateFrame         // Update sprite frame

    ResetVars:
        lda #$00
        sta IsJumping
        sta SantaFrame
        lda #Santa.MAX_JUMP
        sta IsLanding
        lda GameEnded
        beq UpdateFrame
        jsr SetSantaLikeCrying
        jmp Done
    UpdateFrame:
        jsr SwitchSantaFrame
    Done:
        rts
}

SwitchSantaFrame: {
        lda IsJumping       // If IsJumping == 0 => no jump in progress
        beq NoJump
        cmp #Santa.MAX_JUMP
        beq CheckLanding
        lda Orientation
        cmp #$ff
        beq SantaJumpLeft
        ldx #SpritePointers.SANTAS_JUMP_RIGHT
        ldy #SpritePointers.SANTA_JUMP_RIGHT
        jmp SetFrame
    SantaJumpLeft:
        ldx #SpritePointers.SANTAS_JUMP_LEFT
        ldy #SpritePointers.SANTA_JUMP_LEFT
        jmp SetFrame

    CheckLanding:
        lda Orientation
        cmp #$ff
        beq SantaLandLeft
        ldx #SpritePointers.SANTAS_LANDING_LEFT
        ldy #SpritePointers.SANTA_LANDING_LEFT
        jmp SetFrame
    SantaLandLeft:
        ldx #SpritePointers.SANTAS_LANDING_RIGHT
        ldy #SpritePointers.SANTA_LANDING_RIGHT
        jmp SetFrame
    NoJump:
        lda SantaFrame
        lsr
        lsr
        lsr
        cmp #$00
        beq Frame1
        ldx #SpritePointers.SANTAS_LEFT
        ldy #SpritePointers.SANTA_LEFT
        jmp CheckDirection
    Frame1:
        ldx #SpritePointers.SANTAS_RIGHT
        ldy #SpritePointers.SANTA_RIGHT
    CheckDirection:
        lda Orientation
        cmp #$ff
        beq SantaLeft
        cmp #$01
        beq SetFrame
        jmp SwitchSantaFrameDone
    SantaLeft:
        txa
        clc
        adc #$04
        tax
        tay
        iny
    SetFrame:
        stx SCREEN_RAM + $03f8 + $06
        sty SCREEN_RAM + $03f8 + $05
    CheckSantaFrame:
        lda SantaFrame
        cmp #$0f
        beq ResetSantaFrame
        inc SantaFrame
        jmp SwitchSantaFrameDone
    ResetSantaFrame:
        lda #$00
        sta SantaFrame
    SwitchSantaFrameDone:
        rts
}

MoveSleigh: {
        jsr DetectSleighNewY
        jsr ShouldThrowGift
        jsr LetGiftFall
        lda Direction
        cmp #$00
        beq NoMove
        cmp #$ff
        beq MoveBackward

    MoveForward:
        lda #$01
        jmp ApplyMove

    NoMove:
        lda #$02
        jmp ApplyMove

    MoveBackward:
        lda #$03

    ApplyMove:
        tax
        clc
        adc VIC.SPRITE_0_X
        sta VIC.SPRITE_0_X
        bcs ToggleExtraXSleigh  // Check if sleigh goes over 255px

    EvaluateReindeer:
        txa
        clc
        adc VIC.SPRITE_1_X
        sta VIC.SPRITE_1_X
        bcs ToggleExtraXReindeer1
    Reindeer2:
        txa
        clc
        adc VIC.SPRITE_2_X
        sta VIC.SPRITE_2_X
        bcs ToggleExtraXReindeer2
    Reindeer3:
        txa
        clc
        adc VIC.SPRITE_3_X
        sta VIC.SPRITE_3_X
        bcs ToggleExtraXReindeer3
    Reindeer4:
        txa
        clc
        adc VIC.SPRITE_4_X
        sta VIC.SPRITE_4_X
        bcs ToggleExtraXReindeer4
    LastReindeerDone:
        jsr SwitchReindeerFrame
        rts

    ToggleExtraXSleigh:
        lda VIC.SPRITE_EXTRAX           // Setting or resetting sleigh and elf extra x position
        and #%00000001
        beq SetExtraXSleigh
        jsr SetGiftToExplode
        lda VIC.SPRITE_EXTRAX
        and #%11111110
        sta VIC.SPRITE_EXTRAX

        jmp !ReloadXSleighAndElf+
    SetExtraXSleigh:
        lda VIC.SPRITE_EXTRAX
        ora #%00000001
        sta VIC.SPRITE_EXTRAX
    !ReloadXSleighAndElf:
        jmp EvaluateReindeer

    ToggleExtraXReindeer1:
        lda VIC.SPRITE_EXTRAX           // Setting or resetting reindeer 1 extra x position
        and #%00000010
        beq SetExtraXReindeer1
        lda VIC.SPRITE_EXTRAX
        and #%11111101
        sta VIC.SPRITE_EXTRAX
        jmp !ReloadXReindeer1+
    SetExtraXReindeer1:
        lda VIC.SPRITE_EXTRAX
        ora #%00000010
        sta VIC.SPRITE_EXTRAX
    !ReloadXReindeer1:
        jmp Reindeer2

    ToggleExtraXReindeer2:
        lda VIC.SPRITE_EXTRAX           // Setting or resetting reindeer 2 extra x position
        and #%00000100
        beq SetExtraXReindeer2
        lda VIC.SPRITE_EXTRAX
        and #%11111011
        sta VIC.SPRITE_EXTRAX
        jmp !ReloadXReindeer2+
    SetExtraXReindeer2:
        lda VIC.SPRITE_EXTRAX
        ora #%00000100
        sta VIC.SPRITE_EXTRAX
    !ReloadXReindeer2:
        jmp Reindeer3

    ToggleExtraXReindeer3:
        lda VIC.SPRITE_EXTRAX           // Setting or resetting reindeer 3 extra x position
        and #%00001000
        beq SetExtraXReindeer3
        lda VIC.SPRITE_EXTRAX
        and #%11110111
        sta VIC.SPRITE_EXTRAX
        jmp !ReloadXReindeer3+
    SetExtraXReindeer3:
        lda VIC.SPRITE_EXTRAX
        ora #%00001000
        sta VIC.SPRITE_EXTRAX
    !ReloadXReindeer3:
        jmp Reindeer4

    ToggleExtraXReindeer4:
        lda VIC.SPRITE_EXTRAX           // Setting or resetting reindeer 4 extra x position
        and #%00010000
        beq SetExtraXReindeer4
        lda VIC.SPRITE_EXTRAX
        and #%11101111
        sta VIC.SPRITE_EXTRAX
        jmp !ReloadXReindeer4+
    SetExtraXReindeer4:
        lda VIC.SPRITE_EXTRAX
        ora #%00010000
        sta VIC.SPRITE_EXTRAX
    !ReloadXReindeer4:
        jmp LastReindeerDone
}

MoveSanta: {
        lda Direction
        beq End
        cmp #$ff
        beq MoveRight
    MoveLeft:
        lda VIC.SPRITE_5_X
        cmp #$97
        beq End                 // Santa reached right limit
        inc VIC.SPRITE_5_X
        inc VIC.SPRITE_6_X
        jmp ResetDirection
    MoveRight:
        lda VIC.SPRITE_5_X
        cmp #$50
        beq End                 // Santa reached left limit
        dec VIC.SPRITE_5_X
        dec VIC.SPRITE_6_X
    ResetDirection:
        lda #$00
        sta Direction
    End:
        rts
}

DetectSleighNewY: {
        lda VIC.SPRITE_4_X
        cmp #$fa
        bcs !+
        jmp End
    !:
        lda VIC.SPRITE_EXTRAX
        and #%00000001
        beq End
        lda #$4f
        sta MaxNumberGenerator
        jsr GetRandomNumber
        lda RandomNumber
        clc
        adc #$37
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y
        sta VIC.SPRITE_2_Y
        sta VIC.SPRITE_3_Y
        sta VIC.SPRITE_4_Y
    End:
        rts
}

SwitchReindeerFrame: {
        lda ReindeerFrame
        clc
        lsr
        lsr
        lsr
        bcs CheckReindeerFrame
        adc #SpritePointers.REINDEER_1
        sta SCREEN_RAM + $03f8 + $01
        sta SCREEN_RAM + $03f8 + $02
        sta SCREEN_RAM + $03f8 + $03
        sta SCREEN_RAM + $03f8 + $04

    CheckReindeerFrame:
        lda ReindeerFrame
        cmp #$1f
        beq ResetReindeerFrame
        inc ReindeerFrame
        jmp SwitchReindeerFrameDone
    ResetReindeerFrame:
        lda #$00
        sta ReindeerFrame
        jsr SwitchSantaLikeCrying

    SwitchReindeerFrameDone:
        rts
}

ShouldThrowGift: {
        lda GameEnded
        bne GameIsEnded             // Game is ended, no throw
        lda VIC.SPRITE_0_X          // If sleigh is between $50 and $a0 px
        cmp #$90                    // then it can throw a gift
        bcc NoThrow
        cmp #$ff
        bcs NoThrow
        ldx GiftThrown              // If sleigh already thrown 2 gift
        cpx #$01                    // then no more gift should be thrown
        bcs NoThrow
        lda VIC.SPRITE_EXTRAX
        and #%00000001
        bne NoThrow
        lda #$90
        sta MaxNumberGenerator
        jsr GetRandomNumber
        ldx RandomNumber
        cpx #$05
        bcs NoThrow

        inc GiftThrown              // Here we can throw a new gift

        lda VIC.SPRITE_0_X
        sta VIC.SPRITE_7_X
        lda VIC.SPRITE_0_Y
        sta VIC.SPRITE_7_Y

        lda #SpritePointers.GIFT
        sta SCREEN_RAM + $03f8 + $07

        lda VIC.SPRITE_ENABLE
        ora #%10000000
        sta VIC.SPRITE_ENABLE
        jmp NoThrow

    GameIsEnded:
        jsr GetJoystickMove
        lda FirePressed
        bne FireIsPressed
        jmp NoThrow

    FireIsPressed:
        jmp RestartGame

    NoThrow:
        rts
}

LetGiftFall: {
        lda GameEnded
        bne NoGiftNeedsToFall       // Game is ended, no throw
        lda GiftThrown
        beq NoGiftNeedsToFall       // There is no gift
        lda VIC.SPRITE_7_Y
        cmp #Santa.Y
        bcs NoGiftNeedsToFall       // Gift is already on the ground
        inc VIC.SPRITE_7_Y
    NoGiftNeedsToFall:
        rts
}

MoveGiftOnDirection: {
        lda GiftThrown
        beq NoNeedToMove            // There is no gift
        lda Direction
        beq NoNeedToMove
        bpl MoveGiftForward         // Choose direction to move gift

    MoveGiftBackward:
        inc VIC.SPRITE_7_X
        jsr MayGiftExtraXBitSet
        jmp NoNeedToMove

    MoveGiftForward:
        dec VIC.SPRITE_7_X
        jsr MayGiftExtraXBitReset

    NoNeedToMove:
        rts
}

MayGiftExtraXBitReset: {
        lda VIC.SPRITE_7_X
        cmp #$ff
        bne Done
        lda VIC.SPRITE_EXTRAX
        and #%01111111
        sta VIC.SPRITE_EXTRAX
    Done:
        rts
}

MayGiftExtraXBitSet: {
        lda VIC.SPRITE_7_X
        bne Done
        lda VIC.SPRITE_EXTRAX       // Gift moved over 255
        ora #%10000000              // Set extra bit
        sta VIC.SPRITE_EXTRAX
    Done:
        rts
}

SetGiftToExplode: {
        lda GiftThrown              // If no gift is thrown (maybe it's already
        beq Done                    // been saved), no explosion sound should happen
        jsr PlayGiftExplosion
        lda #$01
        sta GiftShouldExplode
        dec CurrentHappiness
        jsr DrawCurrentHappinessBar
    Done:
        rts
}

MayGiftExplode: {
        lda GiftShouldExplode
        beq Done
        lda GiftThrownFrame
        clc
        lsr
        lsr
        lsr
        bcs CheckGiftExplodeFrame
        adc #SpritePointers.GIFT_EXPLOSION_1
        sta SCREEN_RAM + $03f8 + $07

    CheckGiftExplodeFrame:
        lda GiftThrownFrame
        cmp #$1f
        bne IncrementGiftExplodeFrame
        jsr ResetGiftExplodeFrame
        lda GameEnded
        beq Done
        jsr SetSantaLikeCrying
        jmp Done

    IncrementGiftExplodeFrame:
        inc GiftThrownFrame
    Done:
        rts
}

ResetGiftExplodeFrame: {
        lda #$00
        sta GiftThrown
        sta GiftThrownFrame
        sta GiftShouldExplode
        lda VIC.SPRITE_ENABLE
        and #%01111111
        sta VIC.SPRITE_ENABLE
        rts
}
