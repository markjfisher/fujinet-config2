.export _fast_call

.import callax

; this is uses a small asm wrapper to call the function passed as a parameter
; which by convention is in A/X automatically

_fast_call:
    jmp callax