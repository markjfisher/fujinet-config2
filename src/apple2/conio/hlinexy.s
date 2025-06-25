        .export     _hlinexy

        .import     _cputc
        .import     _gotoxy
        .import     pusha

        .import     _lower
        .import     tmp_len
        .import     tmp_val
        .import     tmp_x
        .import     hchar_lower
        .import     hchar_upper

        .include    "zeropage.inc"
        .include    "conio.inc"


_hlinexy:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1

        ; extract length and type before calling any cc65 functions
        ldy     #hlinexy_params::len
        lda     (ptr3), y
        sta     tmp_len                                ; save length before ptr3 gets corrupted
        ldy     #hlinexy_params::type
        lda     (ptr3), y
        sta     tmp_x                                  ; save type before ptr3 gets corrupted

        ; always call gotoxy, but we may not put any chars to screen.
        ldy     #hlinexy_params::x_v
        lda     (ptr3), y
        jsr     pusha
        ldy     #hlinexy_params::y_v
        lda     (ptr3), y
        jsr     _gotoxy

        ; check if length is zero (no characters to draw)
        lda     tmp_len
        bne     :+
        rts

        ; length is non-zero, continue with character drawing
        ; get the value we want to write to screen
:       lda     #<hchar_upper
        sta     ptr1
        lda     #>hchar_upper
        sta     ptr1+1

        ; need to check if lower is set for which offset to use
        ldx     #$00                                    ; assume upper case offset
        lda     _lower
        beq     using_upper
        ldx     #$03                                    ; lower case offset

using_upper:
        ; X now contains table offset (0 or 3)
        stx     tmp1                                    ; temporarily save table offset
        lda     tmp_x                                   ; get saved type value
        clc
        adc     tmp1                                    ; add table offset to type
        tay

        lda     (ptr1), y                               ; contains the upper/lower offset, and the type offset

        ; save the value
        sta     tmp_val

        ; now write out using cputc for len bytes
hline_loop:
        lda     tmp_val
        jsr     _cputc

        dec     tmp_len
        bne     hline_loop

        rts
