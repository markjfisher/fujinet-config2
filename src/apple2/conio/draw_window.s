        .export     _draw_window

        .import     _hlinexy
        .import     _vlinexy
        .import     _gotoxy
        .import     _cputs
        .import     pusha

        .import     tmp_val
        .import     tmp_len
        .import     tmp_x
        .import     tmp_y

        .include    "zeropage.inc"
        .include    "conio.inc"

.bss
; parameter structures for drawing operations
hline_params:   .tag hlinexy_params
vline_params:   .tag vlinexy_params

; variables for draw_window function
draw_x:         .res 1                                  ; window x position
draw_y:         .res 1                                  ; window y position  
draw_width:     .res 1                                  ; window width
draw_height:    .res 1                                  ; window height
title_len:      .res 1                                  ; calculated title length
title_start:    .res 1                                  ; calculated title start position
title_ptr:      .res 2                                  ; save title pointer across function calls

.code

_draw_window:
        ; save the pointer to params in ptr3
        sta     ptr3
        stx     ptr3+1

        ; extract all needed values before calling any cc65 functions
        ldy     #draw_window_params::x_v
        lda     (ptr3), y
        sta     draw_x                                  ; save x position
        ldy     #draw_window_params::y_v
        lda     (ptr3), y
        sta     draw_y                                  ; save y position
        ldy     #draw_window_params::width
        lda     (ptr3), y
        sta     draw_width                              ; save width
        ldy     #draw_window_params::height
        lda     (ptr3), y
        sta     draw_height                             ; save height
        ldy     #draw_window_params::title
        lda     (ptr3), y
        sta     title_ptr                               ; save title pointer low
        iny
        lda     (ptr3), y
        sta     title_ptr+1                             ; save title pointer high

        ; Draw top border with title
        ; hlinexy_c(x+1, y, width-2, TOP);
        lda     draw_x
        clc
        adc     #1
        sta     hline_params + hlinexy_params::x_v
        lda     draw_y
        sta     hline_params + hlinexy_params::y_v
        lda     draw_width
        sec
        sbc     #2
        sta     hline_params + hlinexy_params::len
        lda     #htype::TOP
        sta     hline_params + hlinexy_params::type

        lda     #<hline_params
        ldx     #>hline_params
        jsr     _hlinexy

        ; Handle title if present
        ; Check if title pointer is non-null
        lda     title_ptr
        sta     ptr1
        ora     title_ptr+1
        beq     skip_title                              ; null pointer, skip title

        ; Copy title pointer to zero page for indirect addressing
        lda     title_ptr+1
        sta     ptr1+1

        ; Check if title string is not empty
        ldy     #0
        lda     (ptr1), y
        beq     skip_title                              ; empty string, skip title

        ; Calculate title length
        ldy     #0
title_len_loop:
        lda     (ptr1), y
        beq     title_len_done
        iny
        bne     title_len_loop                          ; loop until null terminator or 255 chars
title_len_done:
        sty     title_len

        ;; Calculate starting position to center title
        ;; if (title_len < width - 2)
        ;; for now, I don't care
        ; lda     tmp_len                                 ; width
        ; sec
        ; sbc     #2                                      ; width - 2 (space for borders)
        ; cmp     title_len
        ; bcc     skip_title                              ; title too long, skip

        ; title_start = x + 1 + (width - 2 - title_len) / 2
        lda     draw_width                              ; width
        sec
        sbc     #2                                      ; width - 2
        sec
        sbc     title_len                               ; (width - 2 - title_len)
        lsr     a                                       ; divide by 2
        clc
        adc     draw_x                                  ; add x
        clc
        adc     #1                                      ; add 1 (x + 1)
        sta     title_start

        ; gotoxy(title_start, y);
        lda     title_start
        jsr     pusha
        lda     draw_y
        jsr     _gotoxy

        ; cputs(title);
        lda     title_ptr
        ldx     title_ptr+1
        jsr     _cputs

skip_title:
        ; Draw left border: vlinexy_c(x, y, height, false);
        lda     draw_x
        sta     vline_params + vlinexy_params::x_v
        lda     draw_y
        sta     vline_params + vlinexy_params::y_v
        lda     draw_height
        sta     vline_params + vlinexy_params::len
        lda     #0                                      ; false (left border)
        sta     vline_params + vlinexy_params::right

        lda     #<vline_params
        ldx     #>vline_params
        jsr     _vlinexy

        ; Draw right border: vlinexy_c(x + width - 1, y, height, true);
        lda     draw_x
        clc
        adc     draw_width                              ; x + width
        sec
        sbc     #1                                      ; x + width - 1
        sta     vline_params + vlinexy_params::x_v
        lda     draw_y
        sta     vline_params + vlinexy_params::y_v
        lda     draw_height
        sta     vline_params + vlinexy_params::len
        lda     #1                                      ; true (right border)
        sta     vline_params + vlinexy_params::right

        lda     #<vline_params
        ldx     #>vline_params
        jsr     _vlinexy

        ; Draw bottom border: hlinexy_c(x+1, y + height - 1, width-2, BOTTOM);
        lda     draw_x
        clc
        adc     #1
        sta     hline_params + hlinexy_params::x_v
        lda     draw_y
        clc
        adc     draw_height                             ; y + height
        sec
        sbc     #1                                      ; y + height - 1
        sta     hline_params + hlinexy_params::y_v
        lda     draw_width
        sec
        sbc     #2
        sta     hline_params + hlinexy_params::len
        lda     #htype::BOTTOM
        sta     hline_params + hlinexy_params::type

        lda     #<hline_params
        ldx     #>hline_params
        jsr     _hlinexy

        rts
