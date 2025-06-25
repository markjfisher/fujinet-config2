;
; Visual hlinexy test using screen memory assertions
; This replaces the traditional mock function call counting with visual screen testing
;

.export _main
.export start_draw
.export end

.import _hlinexy
.import screen_init
.import screen_memory

.import _params
.import _lower

.include "conio.inc"

.code

_main:
        ; Initialize screen with spaces
        jsr     screen_init

start_draw:
        ; Test 1: Draw a simple horizontal line (uppercase mode)
        lda     #$05                    ; x = 5
        sta     _params + hlinexy_params::x_v
        lda     #$03                    ; y = 3
        sta     _params + hlinexy_params::y_v
        lda     #$10                    ; length = 16
        sta     _params + hlinexy_params::len
        lda     #$00                    ; TOP type
        sta     _params + hlinexy_params::type

        lda     #$00
        sta     _lower                  ; uppercase mode

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

        ; Test 2: Draw bottom line (uppercase mode)
        lda     #$02                    ; x = 2
        sta     _params + hlinexy_params::x_v
        lda     #$05                    ; y = 5
        sta     _params + hlinexy_params::y_v
        lda     #$20                    ; length = 32
        sta     _params + hlinexy_params::len
        lda     #$02                    ; BOTTOM type
        sta     _params + hlinexy_params::type

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

        ; Test 3: Draw middle line (lowercase mode)
        lda     #$08                    ; x = 8
        sta     _params + hlinexy_params::x_v
        lda     #$07                    ; y = 7
        sta     _params + hlinexy_params::y_v
        lda     #$0C                    ; length = 12
        sta     _params + hlinexy_params::len
        lda     #$01                    ; MID type
        sta     _params + hlinexy_params::type

        lda     #$01
        sta     _lower                  ; lowercase mode

        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy

end:
        rts
