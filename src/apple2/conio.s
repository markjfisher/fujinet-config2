        .export     _hlinexy_asm
        .export     _vlinexy_asm

        .import     _cputc
        .import     _gotoxy
        .import     pusha
        
        .import     _params
        .import     _lower

        .include    "zeropage.inc"
        .include    "macros.inc"
        .include    "conio.inc"

_hlinexy_asm:
        ; always call gotoxy, but we may not put any chars to screen.
        lda     _params + hlinexy_params::x_v
        jsr     pusha
        lda     _params + hlinexy_params::y_v
        jsr     _gotoxy

        lda     _params + hlinexy_params::len
        bne     :+
        rts

        ; get the value we want to write to screen
:       lda     #<hchar_upper
        sta     ptr1
        lda     #>hchar_upper
        sta     ptr1+1
        ldy     #$00

        ; need to check if lower is set for which offset to use
        lda     _lower
        beq     using_upper
        ldy     #$3

using_upper:
        ; add the type offset so we point to the correct element in the hchar_* tables
        tya
        clc
        adc     _params + hlinexy_params::type
        tay

        lda     (ptr1), y                               ; contains the upper/lower offset, and the type offset
        sta     _params + hlinexy_params::x_v           ; reuse X as a save location for the writing value


        ; now write out using cputc for len bytes
:
        jsr     _cputc

        dec     _params + hlinexy_params::len
        beq     done
        lda     _params + hlinexy_params::x_v           ; restore the value for cputc, never 0
        bne     :-

done:
        rts

_vlinexy_asm:
        ; check if length is zero first
        lda     _params + vlinexy_params::len
        bne     vline_start
        rts

vline_start:
        ; get the value we want to write to screen
        lda     #<vchar_upper
        sta     ptr1
        lda     #>vchar_upper
        sta     ptr1+1
        ldy     #$00

        ; need to check if lower is set for which offset to use
        lda     _lower
        beq     vline_using_upper
        ldy     #$02                                    ; vchar table has 2 entries per row (left, right)

vline_using_upper:
        ; add the right flag offset so we point to the correct element in the vchar_* tables
        tya
        clc
        adc     _params + vlinexy_params::right
        tay

        lda     (ptr1), y                               ; contains the upper/lower offset, and the right offset
        sta     _params + vlinexy_params::right         ; reuse right as a save location for the writing value

        ; y_v already contains the starting y position, we'll increment it directly

vline_loop:
        ; position cursor at current x,y
        lda     _params + vlinexy_params::x_v
        jsr     pusha
        lda     _params + vlinexy_params::y_v           ; current y position
        jsr     _gotoxy

        ; write the character
        lda     _params + vlinexy_params::right         ; character to write
        jsr     _cputc

        ; increment y position and decrement length
        inc     _params + vlinexy_params::y_v
        dec     _params + vlinexy_params::len
        bne     vline_loop

        rts

.data
hchar_upper:    .byte $A0, '-', '_'
hchar_lower:    .byte $DC, $D3, '_'

vchar_upper:    .byte '!', '!'
vchar_lower:    .byte $DA, $DF
