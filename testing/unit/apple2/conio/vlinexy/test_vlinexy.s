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

.export gxy_calls
.export gxy_x_values
.export gxy_y_values
.export cpc_idx
.export cpc_vs

.export _gotoxy
.export _cputc

.import _vlinexy_asm
.import popa

.import _params
.import _lower

.include "conio.inc"

.code
_main:

; t0X are upper case tests
; t1X are lower case tests
; in both cases, X is the right param; 0=left, 1=right

; simple call - upper case, left character
        ldx     #$03
        stx     _params + vlinexy_params::x_v
        inx
        stx     _params + vlinexy_params::y_v

        lda     #$03
        sta     _params + vlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     gxy_calls
        sta     _lower
        ; lda     #$00          ; left character
        sta     _params + vlinexy_params::right

t00:
        jsr     _vlinexy_asm
t00_end:

; simple call - upper case, right character
        ldx     #$05
        stx     _params + vlinexy_params::x_v
        ldx     #$02
        stx     _params + vlinexy_params::y_v

        lda     #$03
        sta     _params + vlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     gxy_calls
        sta     _lower
        lda     #$01            ; right character
        sta     _params + vlinexy_params::right

t01:
        jsr     _vlinexy_asm
t01_end:

; simple call - lower case, left character
        ldx     #$07
        stx     _params + vlinexy_params::x_v
        ldx     #$01
        stx     _params + vlinexy_params::y_v

        lda     #$03
        sta     _params + vlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     gxy_calls
        lda     #$01
        sta     _lower
        lda     #$00          ; left character
        sta     _params + vlinexy_params::right

t10:
        jsr     _vlinexy_asm
t10_end:

; simple call - lower case, right character
        ldx     #$09
        stx     _params + vlinexy_params::x_v
        ldx     #$03
        stx     _params + vlinexy_params::y_v

        lda     #$03
        sta     _params + vlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     gxy_calls
        lda     #$01
        sta     _lower
        lda     #$01            ; right character
        sta     _params + vlinexy_params::right

t11:
        jsr     _vlinexy_asm
t11_end:

; no length call does not call cputc or gotoxy
        lda     #$00
        sta     _params + vlinexy_params::len
        sta     gxy_calls
        sta     cpc_idx

        ldx     #$0B
        stx     _params + vlinexy_params::x_v
        ldx     #$05
        stx     _params + vlinexy_params::y_v

t1:
        jsr     _vlinexy_asm
t1_end:

        rts


; mocks

        ; capture values gotoxy was called with
_gotoxy:
        ldx     gxy_calls
        sta     gxy_y_values, x
        jsr     popa
        sta     gxy_x_values, x
        inc     gxy_calls

        rts

        ; capture A value cputc was called with, and index / count of calls
_cputc:
        ldx     cpc_idx
        sta     cpc_vs, x
        inc     cpc_idx
        rts

.bss
; capture the number of gotoxy calls
gxy_calls:      .res 1
; capture x values passed to gotoxy
gxy_x_values:   .res 10
; capture y values passed to gotoxy
gxy_y_values:   .res 10

; capture the values of A when cputc called
cpc_vs:         .res 10
; keep track of which vs to write to
cpc_idx:        .res 1 