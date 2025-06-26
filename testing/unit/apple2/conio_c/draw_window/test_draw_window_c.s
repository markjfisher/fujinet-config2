;
; Test draw_window_c function
; Tests window drawing with different sizes and titles
;

.export _main
.export start_test
.export window1_end
.export window2_end
.export window3_end
.export window4_end
.export end

.import _draw_window_c

.import _lower
.import screen_init
.import screen_memory

.include "conio.inc"

.code

_main:
        lda     #$01
        sta     _lower
        ; Initialize screen with spaces
        jsr     screen_init

start_test:
        ; Test 1: Small window with title at (2, 1)
        lda     #<window1_params
        ldx     #>window1_params
        jsr     _draw_window_c

window1_end:

        ; Test 2: Medium window with longer title at (10, 3)
        lda     #<window2_params
        ldx     #>window2_params
        jsr     _draw_window_c

window2_end:

        ; Test 3: Large window with title at (5, 8)
        lda     #<window3_params
        ldx     #>window3_params
        jsr     _draw_window_c

window3_end:

        ; Test 4: overlapping window
        lda     #<window4_params
        ldx     #>window4_params
        jsr     _draw_window_c

window4_end:

end:
        rts

.rodata
window1_title:  .asciiz "Menu"
window2_title:  .asciiz "Settings"
window3_title:  .asciiz "File Browser"
window4_title:  .asciiz "Overlap"

.data
; "Menu"
window1_params:
        .byte   2                       ; x
        .byte   1                       ; y
        .byte   8                       ; width
        .byte   4                       ; height
        .word   window1_title           ; title

window2_params:
        .byte   10                      ; x
        .byte   3                       ; y
        .byte   12                      ; width
        .byte   5                       ; height
        .word   window2_title           ; title

window3_params:
        .byte   5                       ; x
        .byte   8                       ; y
        .byte   18                      ; width
        .byte   6                       ; height
        .word   window3_title           ; title

window4_params:
        .byte   4                       ; x
        .byte   4                       ; y
        .byte   12                      ; width
        .byte   6                       ; height
        .word   window4_title           ; title 