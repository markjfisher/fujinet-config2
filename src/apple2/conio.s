        .export     _hlinexy_asm
        .export     _vlinexy_asm
        .export     _iputsxy_asm

        .import     _cputc
        .import     _gotoxy
        .import     _cputs
        .import     _revers
        .import     pusha
        
        .import     _params
        .import     _lower

        .include    "zeropage.inc"
        .include    "macros.inc"
        .include    "conio.inc"

_hlinexy_asm:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1
        
        ; always call gotoxy, but we may not put any chars to screen.
        ldy     #hlinexy_params::x_v
        lda     (ptr3), y
        jsr     pusha
        ldy     #hlinexy_params::y_v
        lda     (ptr3), y
        jsr     _gotoxy

        ldy     #hlinexy_params::len
        lda     (ptr3), y
        bne     :+
        rts

        ; keep the len value to save doing more indirect lookups
:       sta     tmp_len

        ; get the value we want to write to screen
        lda     #<hchar_upper
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
        ; get the type from params and add to table offset
        ldy     #hlinexy_params::type
        lda     (ptr3), y
        clc
        adc     tmp1                                    ; add table offset to type
        tay

        lda     (ptr1), y                               ; contains the upper/lower offset, and the type offset
        
        ; save the value
        sta     tmp_val

        ; now write out using cputc for len bytes
hline_loop:
        jsr     _cputc

        dec     tmp_len
        beq     done
        lda     tmp_val
        bne     hline_loop

done:
        rts

_vlinexy_asm:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1
        
        ; check if length is zero first
        ldy     #vlinexy_params::len
        lda     (ptr3), y
        bne     vline_start
        rts

vline_start:
        ; copy length to temp storage
        sta     tmp_len
        
        ; copy x and y values to temp storage for efficient access
        ldy     #vlinexy_params::x_v
        lda     (ptr3), y
        sta     tmp1                                    ; tmp1 = x_v
        ; ldy     #vlinexy_params::y_v
        iny
        lda     (ptr3), y
        sta     tmp2                                    ; tmp2 = y_v (will be incremented)
        
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
        ; get the right flag from params and add to table offset
        ldy     #vlinexy_params::right
        lda     (ptr3), y
        stx     tmp3                                    ; temporarily save table offset
        clc
        adc     tmp3                                    ; add table offset to right flag
        tay

        lda     (ptr1), y                               ; get the character to write
        sta     tmp_val                                 ; save character value

vline_loop:
        ; position cursor at current x,y
        lda     tmp1                                    ; x position (constant)
        jsr     pusha
        lda     tmp2                                    ; current y position
        jsr     _gotoxy

        ; write the character
        lda     tmp_val                                 ; character to write
        jsr     _cputc

        ; increment y position and decrement length
        inc     tmp2
        dec     tmp_len
        bne     vline_loop

        rts

_iputsxy_asm:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1
        
        ; always call gotoxy first
        ldy     #iputsxy_params::x_v
        lda     (ptr3), y
        jsr     pusha
        ldy     #iputsxy_params::y_v
        lda     (ptr3), y
        jsr     _gotoxy

        ; check if string pointer is null
        ldy     #iputsxy_params::str_ptr
        lda     (ptr3), y
        iny
        ora     (ptr3), y
        bne     :+
        rts                                             ; null pointer, return

        ; check if lower case mode
:       lda     _lower
        bne     iputsxy_lower

        ; upper case mode - use revers(true), cputs, revers(false)
        lda     #$01
        jsr     _revers                                 ; revers(true)
        
        ldy     #iputsxy_params::str_ptr
        lda     (ptr3), y
        sta     tmp1                                    ; save low byte
        iny
        lda     (ptr3), y                               ; get high byte
        tax                                             ; high byte in X
        lda     tmp1                                    ; low byte in A
        jsr     _cputs                                  ; cputs(string)
        
        lda     #$00
        jsr     _revers                                 ; revers(false)
        rts

iputsxy_lower:
        ; lower case mode - character by character processing
        ; copy string pointer to ptr1 for easier access
        ldy     #iputsxy_params::str_ptr
        lda     (ptr3), y
        sta     ptr1
        iny
        lda     (ptr3), y
        sta     ptr1+1
        
        ldy     #$00

iputsxy_loop:
        lda     (ptr1), y                               ; get character
        beq     iputsxy_done                            ; null terminator, done
        
        ; check if character is in range 0x40-0x5F
        cmp     #$40
        bcc     iputsxy_add80                           ; < 0x40, add 0x80
        cmp     #$60
        bcs     iputsxy_add80                           ; >= 0x60, add 0x80
        
        ; character is 0x40-0x5F, add 0x40
        clc
        adc     #$40
        jmp     iputsxy_output
        
iputsxy_add80:
        ; character is not 0x40-0x5F, add 0x80
        clc
        adc     #$80
        
iputsxy_output:
        jsr     _cputc                                  ; output modified character
        
        iny
        bne     iputsxy_loop                            ; continue if y didn't wrap
        
iputsxy_done:
        rts

.bss
tmp_val:        .res 1
tmp_len:        .res 1

.data
hchar_upper:    .byte $A0, '-', '_'
hchar_lower:    .byte $DC, $D3, '_'

vchar_upper:    .byte '!', '!'
vchar_lower:    .byte $DA, $DF
