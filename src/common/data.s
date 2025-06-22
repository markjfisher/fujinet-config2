        .export    _params
        .export    _lower


.bss

; a common memory location for passing parameters.
; save us from using software stack, but not using too much memory for fixed data.
; the params is shared, no attempt is made to protect functions that call other functions that use params
; so if you are using them in this manner, be wary not to overwrite values you need.
_params:        .res 12


.data

; a boolean value that indicates we are allowing lower mode, default to false. will be 1 (true) for >= APPLE_IIE
_lower:         .byte 0
