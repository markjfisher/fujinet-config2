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
.export _cputs
.export _revers

.import _hlinexy
.import popa
.import upset_zp

.import _params
.import _lower

.include "conio.inc"

.code
_main:

; t0X are upper case tests
; t1X are lower case tests
; in both cases, X is the type param; TOP, MID, BOTTOM

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     _lower
        ; lda     #$00          ; TOP
        sta     _params + hlinexy_params::type

t00:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t00_end:

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     _lower
        lda     #$01            ; MID
        sta     _params + hlinexy_params::type

t01:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t01_end:

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        sta     _lower
        lda     #$02            ; BOTTOM
        sta     _params + hlinexy_params::type

t02:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t02_end:

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        lda     #$01
        sta     _lower
        lda     #$00          ; TOP
        sta     _params + hlinexy_params::type

t10:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t10_end:

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        lda     #$01
        sta     _lower
        ; lda     #$01            ; MID
        sta     _params + hlinexy_params::type

t11:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t11_end:

; simple call
        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

        lda     #$05
        sta     _params + hlinexy_params::len

        lda     #$00
        sta     cpc_idx
        lda     #$01
        sta     _lower
        lda     #$02            ; BOTTOM
        sta     _params + hlinexy_params::type

t12:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t12_end:



; no length call does not call cputc, but does call gotoxy
        lda     #$00
        sta     _params + hlinexy_params::len
        sta     gxy_x
        sta     gxy_y
        sta     cpc_idx

        ldx     #$03
        stx     _params + hlinexy_params::x_v
        inx
        stx     _params + hlinexy_params::y_v

t1:
        lda     #<_params
        ldx     #>_params
        jsr     _hlinexy
t1_end:

        rts


; mocks

        ; capture values gotoxy was called with
_gotoxy:
        sta     gxy_y
        jsr     popa
        sta     gxy_x
        jmp     upset_zp                                ; upset zero page to catch bugs

        ; capture A value cputc was called with, and index / count of calls
_cputc:
        ldx     cpc_idx
        sta     cpc_vs, x
        inc     cpc_idx
        jmp     upset_zp                                ; upset zero page to catch bugs

_cputs:
        jmp     upset_zp                                ; upset zero page to catch bugs

_cputcxy:
        jmp     upset_zp                                ; upset zero page to catch bugs

_revers:
        jmp     upset_zp                                ; upset zero page to catch bugs

.bss
gxy_x:          .res 1
gxy_y:          .res 1

; capture the values of A when cputc called
cpc_vs:         .res 10
; keep track of which vs to write to
cpc_idx:        .res 1
