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
        ; get the type from saved value and add to table offset
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

done:
        rts

_vlinexy_asm:
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

_iputsxy_asm:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1

        ; extract string pointer before calling any cc65 functions
        ldy     #iputsxy_params::str_ptr
        lda     (ptr3), y
        sta     tmp_x                                   ; save string pointer low byte
        iny
        lda     (ptr3), y
        sta     tmp_y                                   ; save string pointer high byte
        
        ; always call gotoxy
        ldy     #iputsxy_params::x_v
        lda     (ptr3), y
        jsr     pusha
        ldy     #iputsxy_params::y_v
        lda     (ptr3), y
        jsr     _gotoxy

        ; check if string pointer is null
        lda     tmp_x
        ora     tmp_y
        bne     :+
        rts                                             ; null pointer, return

        ; check if lower case mode
:       lda     _lower
        bne     iputsxy_lower

        ; upper case mode - use revers(true), cputs, revers(false)
        lda     #$01
        jsr     _revers                                 ; revers(true)
        
        ; use saved string pointer
        lda     tmp_x                                   ; low byte in A
        ldx     tmp_y                                   ; high byte in X
        jsr     _cputs                                  ; cputs(string)
        
        lda     #$00
        jsr     _revers                                 ; revers(false)
        rts

iputsxy_lower:
        ; lower case mode - character by character processing
        lda     #$00
        sta     str_index                               ; start at index 0

iputsxy_loop:
        ; use stored string pointer each iteration
        lda     tmp_x
        sta     ptr1
        lda     tmp_y
        sta     ptr1+1
        
        ldy     str_index
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
        jsr     _cputc                                  ; output modified character (corrupts ptr1, X, Y)
        
        ; increment string index for next character
        inc     str_index
        bne     iputsxy_loop                            ; continue processing
        
iputsxy_done:
        rts

.bss
; Shared temporary variables (safe across cc65 calls since functions can't run concurrently)
tmp_val:        .res 1      ; shared character/value storage
tmp_len:        .res 1      ; shared length counter  
tmp_x:          .res 1      ; x position storage for vlinexy
tmp_y:          .res 1      ; y position storage for vlinexy
; String processing variables for iputsxy_lower
str_ptr_lo:     .res 1      ; string pointer low byte
str_ptr_hi:     .res 1      ; string pointer high byte  
str_index:      .res 1      ; current character index in string

.data
hchar_upper:    .byte $A0, '-', '_'
hchar_lower:    .byte $DC, $D3, '_'

vchar_upper:    .byte '!', '!'
vchar_lower:    .byte $DA, $DF
