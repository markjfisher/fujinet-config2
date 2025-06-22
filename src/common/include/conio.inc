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
