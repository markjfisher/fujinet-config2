        .export     _draw_window
        .export     hline_params
        .export     vline_params
        .export     isxy_params
        .export     draw_x
        .export     draw_y
        .export     draw_width
        .export     draw_height
        .export     title_len
        .export     title_start
        .export     title_ptr
        .export     inverse_title
        .export     clear_window

        .import     _hlinexy
        .import     _vlinexy
        .import     _gotoxy
        .import     _cputs
        .import     _cputc
        .import     _iputsxy
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
isxy_params:    .tag iputsxy_params

; variables for draw_window function
draw_x:         .res 1                                  ; window x position
draw_y:         .res 1                                  ; window y position  
draw_width:     .res 1                                  ; window width
draw_height:    .res 1                                  ; window height
title_len:      .res 1                                  ; calculated title length
title_start:    .res 1                                  ; calculated title start position
title_ptr:      .res 2                                  ; save title pointer across function calls
clear_row:      .res 1                                  ; current row for clearing interior
clear_col:      .res 1                                  ; current column for clearing interior
inverse_title:  .res 1
clear_window:   .res 1

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
        ldy     #draw_window_params::inverse_title
        lda     (ptr3), y
        sta     inverse_title
        ldy     #draw_window_params::clear_window
        lda     (ptr3), y
        sta     clear_window

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

        lda     inverse_title
        beq     not_inverse

        ; setup params for iputsxy
        lda     title_ptr
        sta     isxy_params + iputsxy_params::str_ptr
        lda     title_ptr+1
        sta     isxy_params + iputsxy_params::str_ptr+1

        lda     title_start
        sta     isxy_params + iputsxy_params::x_v
        lda     draw_y
        sta     isxy_params + iputsxy_params::y_v

        lda     #<isxy_params
        ldx     #>isxy_params
        jsr     _iputsxy
        clc
        bcc     skip_title

not_inverse:
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

        lda     clear_window
        beq     clear_done

        ; Clear window interior (blank out contents)
        ; for (i = 1; i < height - 1; i++)
        lda     #1                                      ; start at row 1 (skip top border)
        sta     clear_row

clear_row_loop:
        lda     clear_row
        clc
        adc     #1                                      ; i + 1
        cmp     draw_height                             ; compare with height
        bcs     clear_done                              ; if i+1 >= height, done (i < height-1)

        ; gotoxy(x + 1, y + i);
        lda     draw_x
        clc
        adc     #1                                      ; x + 1
        jsr     pusha
        lda     draw_y
        clc
        adc     clear_row                               ; y + i
        jsr     _gotoxy

        ; for (j = 0; j < width - 2; j++)
        lda     #0
        sta     clear_col

clear_col_loop:
        lda     clear_col
        clc
        adc     #2                                      ; j + 2
        cmp     draw_width                              ; compare with width
        bcs     clear_col_done                          ; if j+2 >= width, done (j < width-2)

        ; cputc(' ');
        lda     #' '
        jsr     _cputc

        inc     clear_col
        bne     clear_col_loop

clear_col_done:
        inc     clear_row
        bne     clear_row_loop

clear_done:
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
        jmp     _hlinexy
