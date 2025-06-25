;
; Visual Screen Mock Demonstration Test
; Shows how to use the new screen mock for visual testing
;

.export _main
.export start_draw
.export end
.export end_p01
.export end_p02
.export end_p03
.export end_p04
.export end_p05
.export end_p06
.export end_p07
.export end_p08
.export end_p09
.export end_p10
.export end_p11
.export end_p12
.export end_p13
.export end_p14

.import _hlinexy
.import _vlinexy
.import _cputsxy
.import pusha

.import screen_init
.import screen_memory

.import _params
.import _lower

.include "conio.inc"

.code

_main:
        ; Initialize screen with spaces
        jsr     screen_init

        lda     #$00
        sta     _lower                  ; uppercase mode
start_draw:
        ; Draw a simple box with title
        ; Top horizontal line
        lda     #$01                    ; x = 1
        sta     _params + hlinexy_params::x_v
        lda     #$02                    ; y = 2  
        sta     _params + hlinexy_params::y_v
        lda     #$20                    ; length = 32
        sta     _params + hlinexy_params::len
        lda     #$00                    ; TOP type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p01:

        ; Left vertical line
        lda     #$01                    ; x = 1
        sta     _params + vlinexy_params::x_v
        lda     #$03                    ; y = 3
        sta     _params + vlinexy_params::y_v
        lda     #$05                    ; length = 5
        sta     _params + vlinexy_params::len
        lda     #$00                    ; left side
        sta     _params + vlinexy_params::right

        lda     #<_params
        ldx     #>_params
        jsr     _vlinexy

end_p02:

        ; Right vertical line  
        lda     #$20                    ; x = 32
        sta     _params + vlinexy_params::x_v
        lda     #$03                    ; y = 3
        sta     _params + vlinexy_params::y_v
        lda     #$05                    ; length = 5
        sta     _params + vlinexy_params::len
        lda     #$01                    ; right side
        sta     _params + vlinexy_params::right

        lda     #<_params
        ldx     #>_params
        jsr     _vlinexy

end_p03:
        ; Bottom horizontal line
        lda     #$01                    ; x = 1
        sta     _params + hlinexy_params::x_v
        lda     #$08                    ; y = 8
        sta     _params + hlinexy_params::y_v
        lda     #$20                    ; length = 32
        sta     _params + hlinexy_params::len
        lda     #$02                    ; BOTTOM type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p04:

        ; Add title text
        lda     #$04                    ; x = 4
        jsr     pusha                   ; push x to software stack
        lda     #$02                    ; y = 2 (on top border)
        jsr     pusha                   ; push y to software stack
        lda     #<title_text
        ldx     #>title_text
        jsr     _cputsxy

end_p05:

        ; Add content text
        lda     #$03                    ; x = 3
        jsr     pusha                   ; push x to software stack
        lda     #$04                    ; y = 4
        jsr     pusha                   ; push y to software stack
        lda     #<content_text1
        ldx     #>content_text1
        jsr     _cputsxy

end_p06:

        lda     #$03                    ; x = 3
        jsr     pusha                   ; push x to software stack
        lda     #$05                    ; y = 5
        jsr     pusha                   ; push y to software stack
        lda     #<content_text2
        ldx     #>content_text2
        jsr     _cputsxy

end_p07:

        lda     #$03                    ; x = 3
        jsr     pusha                   ; push x to software stack
        lda     #$06                    ; y = 6
        jsr     pusha                   ; push y to software stack
        lda     #<content_text3
        ldx     #>content_text3
        jsr     _cputsxy

end_p08:

        ; Bottom horizontal line
        lda     #$02                    ; x = 1
        sta     _params + hlinexy_params::x_v
        lda     #$07                    ; y = 7
        sta     _params + hlinexy_params::y_v
        lda     #$1E                    ; length = 30
        sta     _params + hlinexy_params::len
        lda     #$01                    ; MID type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p09:

        ; Switch to lowercase mode for additional testing
        lda     #$01
        sta     _lower                  ; lowercase mode

        ; Add lowercase TOP horizontal line extending beyond the box
        lda     #$00                    ; x = 0
        sta     _params + hlinexy_params::x_v
        lda     #$01                    ; y = 1 (above the box)
        sta     _params + hlinexy_params::y_v
        lda     #$26                    ; length = 38 (wider than box)
        sta     _params + hlinexy_params::len
        lda     #$00                    ; TOP type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p10:

        ; Add lowercase LEFT vertical line extending down
        lda     #$00                    ; x = 0 (left of the box)
        sta     _params + vlinexy_params::x_v
        lda     #$02                    ; y = 2 (start at title line)
        sta     _params + vlinexy_params::y_v
        lda     #$08                    ; length = 8 (extends below box)
        sta     _params + vlinexy_params::len
        lda     #$00                    ; left side
        sta     _params + vlinexy_params::right

        lda     #<_params
        ldx     #>_params
        jsr     _vlinexy

end_p11:

        ; Add lowercase RIGHT vertical line extending down
        lda     #$27                    ; x = 39 (right edge of screen)
        sta     _params + vlinexy_params::x_v
        lda     #$02                    ; y = 2 (start at title line)
        sta     _params + vlinexy_params::y_v
        lda     #$08                    ; length = 8 (extends below box)
        sta     _params + vlinexy_params::len
        lda     #$01                    ; right side
        sta     _params + vlinexy_params::right

        lda     #<_params
        ldx     #>_params
        jsr     _vlinexy

end_p12:

        ; Add lowercase MID horizontal line through the middle
        lda     #$05                    ; x = 5 (overlaps content area)
        sta     _params + hlinexy_params::x_v
        lda     #$05                    ; y = 5 (through content line 2)
        sta     _params + hlinexy_params::y_v
        lda     #$1C                    ; length = 28 (crosses the box)
        sta     _params + hlinexy_params::len
        lda     #$01                    ; MID type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p13:

        ; Add lowercase BOTTOM horizontal line extending beyond box
        lda     #$00                    ; x = 0
        sta     _params + hlinexy_params::x_v
        lda     #$0A                    ; y = 10 (below the box)
        sta     _params + hlinexy_params::y_v
        lda     #$26                    ; length = 38 (wider than box)
        sta     _params + hlinexy_params::len
        lda     #$02                    ; BOTTOM type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end_p14:

        nop
end:
        rts

.rodata
title_text:     .asciiz " TEST WIDGET "
content_text1:  .asciiz "This is line 1 of content"
content_text2:  .asciiz "This is line 2 of content"  
content_text3:  .asciiz "This is line 3 of content" 