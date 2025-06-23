.export _main
.export t00
.export t00_end
.export t01
.export t01_end
.export t10
.export t10_end
.export t11
.export t11_end
.export t1
.export t1_end

.export cxy_calls
.export cxy_x_values
.export cxy_y_values
.export cxy_char_values

.export _gotoxy
.export _cputc
.export _cputcxy
.export _cputs
.export _revers

.import _lower

.import _vlinexy_c
.import popa
.import pusha
.import upset_zp

.code
_main:

; t0X are upper case tests
; t1X are lower case tests
; in both cases, X is the right param; 0=left, 1=right

; simple call - upper case, left character
; vlinexy_c(3, 4, 3, false)
        lda     #$03    ; x
        jsr     pusha
        lda     #$04    ; y
        jsr     pusha
        lda     #$03    ; len
        jsr     pusha

        ldx     #$00
        stx     cxy_calls
        stx     _lower

        lda     #$00    ; right = false (left)

t00:
        jsr     _vlinexy_c
t00_end:

; simple call - upper case, right character
; vlinexy_c(5, 2, 3, true)
        lda     #$05    ; x
        jsr     pusha
        lda     #$02    ; y
        jsr     pusha
        lda     #$03    ; len
        jsr     pusha

        ldx     #$00
        stx     cxy_calls
        stx     _lower

        lda     #$01    ; right = true (right)

t01:
        jsr     _vlinexy_c
t01_end:

; simple call - lower case, left character
; vlinexy_c(7, 1, 3, false)
        lda     #$07    ; x
        jsr     pusha
        lda     #$01    ; y
        jsr     pusha
        lda     #$03    ; len
        jsr     pusha

        ldx     #$00
        stx     cxy_calls
        inx
        stx     _lower

        lda     #$00    ; right = false (left)

t10:
        jsr     _vlinexy_c
t10_end:

; simple call - lower case, right character
; vlinexy_c(9, 3, 3, true)
        lda     #$09    ; x
        jsr     pusha
        lda     #$03    ; y
        jsr     pusha
        lda     #$03    ; len
        jsr     pusha

        ldx     #$00
        stx     cxy_calls
        inx
        stx     _lower

        lda     #$01    ; right = true (right)

t11:
        jsr     _vlinexy_c
t11_end:

; no length call does not call cputcxy
; vlinexy_c(11, 5, 0, false)
        lda     #$0B    ; x
        jsr     pusha
        lda     #$05    ; y
        jsr     pusha
        lda     #$00    ; len = 0
        jsr     pusha

        ldx     #$00
        stx     cxy_calls
        stx     _lower

        lda     #$00    ; right = false (left)

t1:
        jsr     _vlinexy_c
t1_end:

        rts


; mocks

        ; capture values cputcxy was called with (x, y, char)
_cputcxy:
        ldx     cxy_calls
        sta     cxy_char_values, x      ; save character (3rd param, in A)
        jsr     popa
        sta     cxy_y_values, x         ; save y (2nd param)
        jsr     popa  
        sta     cxy_x_values, x         ; save x (1st param)
        inc     cxy_calls
        jmp     upset_zp                                ; upset zero page to catch bugs

_cputc:
        jmp     upset_zp                                ; upset zero page to catch bugs

_gotoxy:
        jmp     upset_zp                                ; upset zero page to catch bugs

_revers:
        jmp     upset_zp                                ; upset zero page to catch bugs

_cputs:
        jmp     upset_zp                                ; upset zero page to catch bugs

.bss
; capture the number of cputcxy calls
cxy_calls:      .res 1
; capture x values passed to cputcxy
cxy_x_values:   .res 10
; capture y values passed to cputcxy
cxy_y_values:   .res 10
; capture character values passed to cputcxy
cxy_char_values: .res 10 