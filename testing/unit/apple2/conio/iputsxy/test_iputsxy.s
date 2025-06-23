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
.export cps_calls
.export cps_strings_a
.export cps_strings_x
.export rev_calls
.export rev_values
.export test_str1
.export test_str2
.export test_str3
.export empty_str

.export _gotoxy
.export _cputc
.export _cputcxy
.export _cputs
.export _revers

.import _iputsxy_asm
.import popa

.import _params
.import _lower

.include "conio.inc"

.code
_main:

; t0X are upper case tests (lower = false)
; t1X are lower case tests (lower = true)

; simple call - upper case, normal string
        lda     #<test_str1
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_str1
        sta     _params + iputsxy_params::str_ptr + 1
        
        lda     #$05
        sta     _params + iputsxy_params::x_v
        lda     #$03
        sta     _params + iputsxy_params::y_v

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

t00:
        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy_asm
t00_end:

; simple call - upper case, empty string
        lda     #<empty_str
        sta     _params + iputsxy_params::str_ptr
        lda     #>empty_str
        sta     _params + iputsxy_params::str_ptr + 1
        
        lda     #$08
        sta     _params + iputsxy_params::x_v
        lda     #$06
        sta     _params + iputsxy_params::y_v

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

t01:
        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy_asm
t01_end:

; simple call - lower case, mixed character types
        lda     #<test_str2
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_str2
        sta     _params + iputsxy_params::str_ptr + 1
        
        lda     #$02
        sta     _params + iputsxy_params::x_v
        lda     #$08
        sta     _params + iputsxy_params::y_v

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        lda     #$01
        sta     _lower

t10:
        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy_asm
t10_end:

; simple call - lower case, all 0x40-0x5F range characters
        lda     #<test_str3
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_str3
        sta     _params + iputsxy_params::str_ptr + 1
        
        lda     #$01
        sta     _params + iputsxy_params::x_v
        lda     #$0A
        sta     _params + iputsxy_params::y_v

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        lda     #$01
        sta     _lower

t11:
        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy_asm
t11_end:

; no length call with null pointer should not crash
        lda     #$00
        sta     _params + iputsxy_params::str_ptr
        sta     _params + iputsxy_params::str_ptr + 1
        
        lda     #$0C
        sta     _params + iputsxy_params::x_v
        lda     #$0F
        sta     _params + iputsxy_params::y_v

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

t1:
        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy_asm
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

        ; capture string pointer cputs was called with
_cputs:
        ldy     cps_calls
        sta     cps_strings_a, y    ; low byte of string pointer (A)
        txa
        sta     cps_strings_x, y    ; high byte of string pointer (X)
        inc     cps_calls
        rts

        ; capture reverse video calls
_revers:
        ldx     rev_calls
        sta     rev_values, x
        inc     rev_calls
        rts

_cputcxy:
        rts

.data
test_str1:      .asciiz "Hello"
test_str2:      .asciiz "Test@ABC"     ; mix of regular and 0x40-0x5F chars
test_str3:      .asciiz "ABCDE"        ; all 0x40-0x5F range
empty_str:      .asciiz ""

.bss
; capture the number of gotoxy calls
gxy_calls:      .res 1
; capture x values passed to gotoxy
gxy_x_values:   .res 10
; capture y values passed to gotoxy
gxy_y_values:   .res 10

; capture the values of A when cputc called
cpc_vs:         .res 20
; keep track of which vs to write to
cpc_idx:        .res 1

; capture cputs calls
cps_calls:      .res 1
cps_strings_a:  .res 10         ; low byte of string pointer (A register)
cps_strings_x:  .res 10         ; high byte of string pointer (X register)

; capture revers calls
rev_calls:      .res 1
rev_values:     .res 10 