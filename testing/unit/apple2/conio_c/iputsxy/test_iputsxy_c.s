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
.export _cputs
.export _revers
.export _cputcxy

.import _lower

.import _iputsxy_c
.import popa
.import pusha
.import upset_zp

.code
_main:

; t0X are upper case tests (lower = false)
; t1X are lower case tests (lower = true)

; simple call - upper case, normal string
; iputsxy_c(5, 3, "Hello")
        lda     #$05                ; x
        jsr     pusha
        lda     #$03                ; y
        jsr     pusha

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

        lda     #<test_str1         ; string pointer (low byte)
        ldx     #>test_str1         ; string pointer (high byte)

t00:
        jsr     _iputsxy_c
t00_end:

; simple call - upper case, empty string
; iputsxy_c(8, 6, "")
        lda     #$08                ; x
        jsr     pusha
        lda     #$06                ; y
        jsr     pusha

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

        lda     #<empty_str         ; string pointer (low byte)
        ldx     #>empty_str         ; string pointer (high byte)

t01:
        jsr     _iputsxy_c
t01_end:

; simple call - lower case, mixed character types
; iputsxy_c(2, 8, "Test@ABC")
        lda     #$02                ; x
        jsr     pusha
        lda     #$08                ; y
        jsr     pusha

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        lda     #$01
        sta     _lower

        lda     #<test_str2         ; string pointer (low byte)
        ldx     #>test_str2         ; string pointer (high byte)

t10:
        jsr     _iputsxy_c
t10_end:

; simple call - lower case, all 0x40-0x5F range characters
; iputsxy_c(1, 10, "ABCDE")
        lda     #$01                ; x
        jsr     pusha
        lda     #$0A                ; y
        jsr     pusha

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        lda     #$01
        sta     _lower

        lda     #<test_str3         ; string pointer (low byte)
        ldx     #>test_str3         ; string pointer (high byte)

t11:
        jsr     _iputsxy_c
t11_end:

; null pointer call should not crash
; iputsxy_c(12, 15, NULL)
        lda     #$0C                ; x
        jsr     pusha
        lda     #$0F                ; y
        jsr     pusha

        lda     #$00
        sta     gxy_calls
        sta     cpc_idx
        sta     cps_calls
        sta     rev_calls
        sta     _lower

        lda     #$00                ; null pointer (low byte)
        ldx     #$00                ; null pointer (high byte)

t1:
        jsr     _iputsxy_c
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
        jmp     upset_zp                                ; upset zero page to catch bugs

        ; capture A value cputc was called with, and index / count of calls
_cputc:
        ldx     cpc_idx
        sta     cpc_vs, x
        inc     cpc_idx
        jmp     upset_zp                                ; upset zero page to catch bugs

        ; capture string pointer cputs was called with
_cputs:
        ldy     cps_calls
        sta     cps_strings_a, y    ; low byte of string pointer (A)
        txa
        sta     cps_strings_x, y    ; high byte of string pointer (X)
        inc     cps_calls
        jmp     upset_zp                                ; upset zero page to catch bugs

        ; capture reverse video calls
_revers:
        ldx     rev_calls
        sta     rev_values, x
        inc     rev_calls
        jmp     upset_zp                                ; upset zero page to catch bugs

; due to all the functions being in a single conio_c.c file, we need to
; mock all external functions, else the real conio functions are pulled in
_cputcxy:
        jmp     upset_zp                                ; upset zero page to catch bugs

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