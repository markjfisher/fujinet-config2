        .export tmp_val, tmp_len, tmp_x, tmp_y
        .export hchar_lower, hchar_upper
        .export vchar_lower, vchar_upper

; common data fields for various conio routines

.bss
tmp_val:        .res 1      ; shared character/value/index storage
tmp_len:        .res 1      ; shared length counter  
tmp_x:          .res 1      ; x position storage for vlinexy, also general tmp value for pointers
tmp_y:          .res 1      ; y position storage for vlinexy, also general tmp value for pointers

; horizontal line drawing characters to use, indexed by TOP, MID, BOTTOM
; vertical line drawing characters to use, indexed by LEFT, RIGHT
.data

.ifdef SIMPLE_GFX
; Simple ASCII characters for visual testing
hchar_upper:    .byte '=', '-', '_'     ; TOP, MID, BOTTOM
hchar_lower:    .byte '%', '+', '~'     ; TOP, MID, BOTTOM
vchar_upper:    .byte '[', ']'          ; LEFT, RIGHT
vchar_lower:    .byte '{', '}'          ; LEFT, RIGHT
.else
; Apple II specific characters for production
hchar_upper:    .byte $A0, '-', '_'     ; TOP, MID, BOTTOM
hchar_lower:    .byte $DC, $D3, '_'     ; TOP, MID, BOTTOM
vchar_upper:    .byte '!', '!'          ; LEFT, RIGHT
vchar_lower:    .byte $DA, $DF          ; LEFT, RIGHT
.endif

;; NOTES for conio apple2 chars
;
; https://retrocomputing.stackexchange.com/questions/8652/why-did-the-original-apple-e-have-two-sets-of-inverse-video-characters:
; $00..$1F Inverse  Uppercase Letters
; $20..$3F Inverse  Symbols/Numbers
; $40..$5F Normal   MouseText
; $60..$7F Inverse  Lowercase Letters (the reason why flashing got dropped)
; $80..$9F Normal   Uppercase Letters
; $A0..$BF Normal   Symbols/Numbers   (like ASCII + $80)
; $C0..$DF Normal   Uppercase Letters (like ASCII + $80)
; $E0..$FF Normal   Lowercase Letters (like ASCII + $80)

; Because cputc() does an EOR #$80 internally:
; $00..$1F Normal   Uppercase Letters
; $20..$3F Normal   Symbols/Numbers   (like ASCII)
; $40..$5F Normal   Uppercase Letters (like ASCII)
; $50..$7F Normal   Lowercase Letters (like ASCII)
; $80..$9F Inverse  Uppercase Letters
; $A0..$BF Inverse  Symbols/Numbers
; $C0..$DF Normal   MouseText
; $E0..$FF Inverse  Lowercase Letters