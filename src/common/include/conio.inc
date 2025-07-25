; conio params, enums etc.
; this include file is common to all platforms, no platform specific values should exist in it

.enum htype
    TOP
    MID
    BOTTOM
    SIZE
.endenum

.struct hlinexy_params
    x_v     .byte
    y_v     .byte
    len     .byte
    type    .byte
.endstruct

.struct vlinexy_params
    x_v     .byte
    y_v     .byte
    len     .byte
    right   .byte
.endstruct

.struct iputsxy_params
    x_v     .byte
    y_v     .byte
    str_ptr .word
.endstruct

.struct draw_window_params
    x_v             .byte
    y_v             .byte
    width           .byte
    height          .byte
    title           .word
    inverse_title   .byte
    clear_window    .byte
.endstruct
