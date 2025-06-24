        .export     _iputsxy

        .import     _cputc
        .import     _gotoxy
        .import     _cputs
        .import     _revers
        .import     pusha
        
        .import     _lower
        .import     tmp_val
        .import     tmp_x
        .import     tmp_y

        .include    "zeropage.inc"
        .include    "conio.inc"

_iputsxy:
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
        jmp     _revers                                 ; revers(false)
        ; implicit rts

iputsxy_lower:
        ; lower case mode - character by character processing
        lda     #$00
        sta     tmp_val                               ; start at index 0

iputsxy_loop:
        ; use stored string pointer each iteration
        lda     tmp_x
        sta     ptr1
        lda     tmp_y
        sta     ptr1+1
        
        ldy     tmp_val
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
        bne     iputsxy_output
        
iputsxy_add80:
        ; character is not 0x40-0x5F, add 0x80
        clc
        adc     #$80
        
iputsxy_output:
        jsr     _cputc                                  ; output modified character (corrupts ptr1, X, Y)
        
        ; increment string index for next character
        inc     tmp_val
        bne     iputsxy_loop                            ; continue processing
        
iputsxy_done:
        rts