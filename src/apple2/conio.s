        .export     _hlinexy_asm

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

.data
hchar_upper:    .byte $A0, '-', '_'
hchar_lower:    .byte $DC, $D3, '_'

vchar_upper:    .byte '!', '!'
vchar_lower:    .byte $DA, $DF
