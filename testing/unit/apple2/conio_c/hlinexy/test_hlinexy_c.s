.export _main
.export t00
.export t00_end
.export t01
.export t01_end
.export t02
.export t02_end
.export t10
.export t10_end
.export t11
.export t11_end
.export t12
.export t12_end
.export t1
.export t1_end

.export gxy_x
.export gxy_y
.export cpc_idx
.export cpc_vs

.export _gotoxy
.export _cputc
.export _cputcxy

.import _lower

.import _hlinexy_c
.import popa
.import pusha

.code
_main:

; simple call, upper case, type TOP(0)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        stx     _lower

        lda     #$00    ; TOP

t00:
        jsr     _hlinexy_c
t00_end:

; simple call, upper case, type MID(1)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        stx     _lower

        lda     #$01    ; MID

t01:
        jsr     _hlinexy_c
t01_end:

; simple call, upper case, type BOTTOM(2)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        stx     _lower

        lda     #$02    ; BOTTOM

t02:
        jsr     _hlinexy_c
t02_end:


; simple call, lower case, type TOP(0)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        inx
        stx     _lower

        lda     #$00    ; TOP

t10:
        jsr     _hlinexy_c
t10_end:

; simple call, lower case, type MID(1)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        inx
        stx     _lower

        lda     #$01    ; MID

t11:
        jsr     _hlinexy_c
t11_end:

; simple call, lower case, type BOTTOM(2)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$05    ; len
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        inx
        stx     _lower
 
        lda     #$02    ; BOTTOM

t12:
        jsr     _hlinexy_c
t12_end:

; no length call does not call cputc, but does call gotoxy
        lda     #$00
        sta     gxy_x
        sta     gxy_y
        sta     cpc_idx

        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$00    ; set length to 0
        sta     _lower
        jsr     pusha

        ldx     #$00
        stx     cpc_idx
        inx
        stx     _lower

t1:
        jsr     _hlinexy_c
t1_end:

        rts


; mocks

        ; capture values gotoxy was called with
_gotoxy:
        sta     gxy_y
        jsr     popa
        sta     gxy_x

        rts

        ; capture A value cputc was called with, and index / count of calls
_cputc:
        ldx     cpc_idx
        sta     cpc_vs, x
        inc     cpc_idx
        rts

; due to all the functions being in a single conio_c.c file, we need to
; mock all external functions, else the real conio functions are pulled in
_cputcxy:
        rts


.bss
gxy_x:          .res 1
gxy_y:          .res 1

; capture the values of A when cputc called
cpc_vs:         .res 10
; keep track of which vs to write to
cpc_idx:        .res 1
