;
; Screen Inverse Character Test
; Tests _iputsxy and _cputsxy functionality with systematic character transformations
; Uses single test string "Ab@1" to show all transformation cases clearly
;

.export _main
.export start_test
.export test1_end
.export test2_end
.export test3_end
.export test4_end
.export test5_end
.export test6_end
.export test7_end
.export test8_end
.export end

.import _iputsxy
.import _cputsxy
.import _revers
.import pusha

.import screen_init
.import screen_memory

.import _params
.import _lower

.include "conio.inc"

.code

_main:
        ; Initialize screen with spaces
        jsr     screen_init

start_test:
        ; Test string "Ab@1" in all 8 variations:
        ; iputsxy: upper normal, upper inverse, lower normal, lower inverse  
        ; cputsxy: upper normal, upper inverse, lower normal, lower inverse

        ; Test 1: iputsxy - upper mode, normal (iputsxy always inverse)
        lda     #$00
        sta     _lower                  ; uppercase mode
        lda     #$00
        jsr     _revers                 ; normal video
        
        lda     #<test_string
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_string
        sta     _params + iputsxy_params::str_ptr + 1
        lda     #$02                    ; x = 2
        sta     _params + iputsxy_params::x_v
        lda     #$00                    ; y = 0
        sta     _params + iputsxy_params::y_v

        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy

test1_end:

        ; Test 2: iputsxy - upper mode, reverse (iputsxy always inverse)
        lda     #$00
        sta     _lower                  ; uppercase mode
        lda     #$01
        jsr     _revers                 ; reverse video
        
        lda     #<test_string
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_string
        sta     _params + iputsxy_params::str_ptr + 1
        lda     #$08                    ; x = 8
        sta     _params + iputsxy_params::x_v
        lda     #$00                    ; y = 0
        sta     _params + iputsxy_params::y_v

        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy

test2_end:

        ; Test 3: iputsxy - lower mode, normal
        lda     #$01
        sta     _lower                  ; lowercase mode
        lda     #$00
        jsr     _revers                 ; normal video
        
        lda     #<test_string
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_string
        sta     _params + iputsxy_params::str_ptr + 1
        lda     #$0E                    ; x = 14
        sta     _params + iputsxy_params::x_v
        lda     #$00                    ; y = 0
        sta     _params + iputsxy_params::y_v

        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy

test3_end:

        ; Test 4: iputsxy - lower mode, reverse
        lda     #$01
        sta     _lower                  ; lowercase mode
        lda     #$01
        jsr     _revers                 ; reverse video
        
        lda     #<test_string
        sta     _params + iputsxy_params::str_ptr
        lda     #>test_string
        sta     _params + iputsxy_params::str_ptr + 1
        lda     #$14                    ; x = 20
        sta     _params + iputsxy_params::x_v
        lda     #$00                    ; y = 0
        sta     _params + iputsxy_params::y_v

        lda     #<_params
        ldx     #>_params
        jsr     _iputsxy

test4_end:

        ; Test 5: cputsxy - upper mode, normal
        lda     #$00
        sta     _lower                  ; uppercase mode
        lda     #$00
        jsr     _revers                 ; normal video
        
        lda     #$02                    ; x = 2
        jsr     pusha
        lda     #$02                    ; y = 2
        jsr     pusha
        lda     #<test_string           ; string low
        ldx     #>test_string           ; string high
        jsr     _cputsxy

test5_end:

        ; Test 6: cputsxy - upper mode, reverse
        lda     #$00
        sta     _lower                  ; uppercase mode
        lda     #$01
        jsr     _revers                 ; reverse video
        
        lda     #$08                    ; x = 8
        jsr     pusha
        lda     #$02                    ; y = 2
        jsr     pusha
        lda     #<test_string           ; string low
        ldx     #>test_string           ; string high
        jsr     _cputsxy

test6_end:

        ; Test 7: cputsxy - lower mode, normal
        lda     #$01
        sta     _lower                  ; lowercase mode
        lda     #$00
        jsr     _revers                 ; normal video
        
        lda     #$0E                    ; x = 14
        jsr     pusha
        lda     #$02                    ; y = 2
        jsr     pusha
        lda     #<test_string           ; string low
        ldx     #>test_string           ; string high
        jsr     _cputsxy

test7_end:

        ; Test 8: cputsxy - lower mode, reverse
        lda     #$01
        sta     _lower                  ; lowercase mode
        lda     #$01
        jsr     _revers                 ; reverse video
        
        lda     #$14                    ; x = 20
        jsr     pusha
        lda     #$02                    ; y = 2
        jsr     pusha
        lda     #<test_string           ; string low
        ldx     #>test_string           ; string high
        jsr     _cputsxy

test8_end:

end:
        rts

.rodata
test_string:    .asciiz "Ab@1" 