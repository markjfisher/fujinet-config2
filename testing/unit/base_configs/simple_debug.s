.export debug
.export upset_zp

.include "zeropage.inc"

.proc debug
        rts
.endproc

.proc upset_zp
        ; set all tmp and ptr variables to 0xFF to catch illegal usage
        lda     #$FF
        sta     tmp1
        sta     tmp2
        sta     tmp3
        sta     tmp4
        sta     ptr1
        sta     ptr1+1
        sta     ptr2
        sta     ptr2+1
        sta     ptr3
        sta     ptr3+1
        ; also corrupt X and Y registers to catch more bugs
        tax
        tay
        rts
.endproc
