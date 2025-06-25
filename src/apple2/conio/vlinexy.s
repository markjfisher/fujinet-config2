        .export     _vlinexy

        .import     _cputc
        .import     _gotoxy
        .import     pusha

        .import     _lower
        .import     tmp_len
        .import     tmp_val
        .import     tmp_x
        .import     tmp_y
        .import     vchar_lower
        .import     vchar_upper

        .include    "zeropage.inc"
        .include    "conio.inc"

_vlinexy:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1

        ; extract all needed values before calling any cc65 functions
        ldy     #vlinexy_params::len
        lda     (ptr3), y
        bne     :+
        rts                                             ; zero length, return immediately

:       sta     tmp_len                                 ; save length
        ldy     #vlinexy_params::x_v
        lda     (ptr3), y
        sta     tmp_x                                   ; save x position
        ldy     #vlinexy_params::y_v
        lda     (ptr3), y
        sta     tmp_y                                   ; save y position (will be incremented)
        ldy     #vlinexy_params::right
        lda     (ptr3), y
        sta     tmp2                                    ; save right flag on stack temporarily

        ; get the value we want to write to screen
        lda     #<vchar_upper
        sta     ptr1
        lda     #>vchar_upper
        sta     ptr1+1

        ; need to check if lower is set for which offset to use
        ldx     #$00                                    ; assume upper case offset
        lda     _lower
        beq     vline_using_upper
        ldx     #$02                                    ; lower case offset (vchar table has 2 entries per row)

vline_using_upper:
        stx     tmp1                                    ; temporarily save table offset
        ; get the right flag and add to table offset
        lda     tmp2                                    ; restore right flag
        clc
        adc     tmp1                                    ; add table offset to right flag
        tay

        lda     (ptr1), y                               ; get the character to write
        sta     tmp_val                                 ; save character value

vline_loop:
        ; position cursor at current x,y
        lda     tmp_x                                   ; x position (constant)
        jsr     pusha
        lda     tmp_y                                   ; current y position
        jsr     _gotoxy

        ; write the character
        lda     tmp_val                                 ; character to write
        jsr     _cputc

        ; increment y position and decrement length
        inc     tmp_y
        dec     tmp_len
        bne     vline_loop

        rts
