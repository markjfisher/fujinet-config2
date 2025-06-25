;
; Screen Mock Implementation for Visual Testing
; Provides mock implementations of conio functions that write to actual screen memory
; for testing visual output with multiline string assertions
;

.export screen_memory
.export screen_init
.export _gotoxy
.export _cputc
.export _cputs
.export _cputcxy
.export _cputsxy
.export _revers

.import popa
.import _mul40


.include "zeropage.inc"

; Apple II text screen is 40 columns x 24 rows
SCREEN_WIDTH = 40
SCREEN_HEIGHT = 24
SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT

.code

;
; Initialize screen memory with spaces (0x20)
;
.proc screen_init
        lda     #$20                    ; space character
        ldy     #$00

        ; Fill 3 pages at once (768 bytes total)
        ; This fills screen_memory[0-255], screen_memory[256-511], screen_memory[512-767]
main_loop:
        sta     screen_memory, y
        sta     screen_memory + $100, y
        sta     screen_memory + $200, y
        iny
        bne     main_loop

        ; Fill remaining bytes (screen_memory + 768 to screen_memory + 959)
        ; That's 192 more bytes (960 - 768 = 192 = $C0)
        ldy     #$00
final_loop:
        sta     screen_memory + $300, y
        iny
        cpy     #$C0                    ; 192 bytes remaining
        bne     final_loop

        ; initialize cursor position to 0,0
        lda     #$00
        sta     cursor_x
        sta     cursor_y
        sta     reverse_flag
        rts
.endproc

;
; gotoxy(x, y) - move cursor to position
; Parameters: A = y, stack = x (cc65 calling convention)
;
.proc _gotoxy
        sta     cursor_y                ; store Y coordinate
        jsr     popa                    ; get X from stack
        sta     cursor_x                ; store X coordinate
        rts
.endproc

;
; cputc(c) - put character at current cursor position
; Parameters: A = character
;
.proc _cputc
        pha                             ; save character

        ; calculate line start: screen_memory + (cursor_y * 40)
        ; Step 1: start with screen_memory base address in ptr1
        lda     #<screen_memory
        sta     ptr1
        lda     #>screen_memory
        sta     ptr1+1

        ; Step 2: add y*40 as 16-bit addition to ptr1
        lda     cursor_y
        jsr     _mul40                  ; multiply by 40, result in A/X (low/high)
        clc
        adc     ptr1                    ; add low byte of y*40 to ptr1 low
        sta     ptr1
        txa                             ; get high byte of y*40
        adc     ptr1+1                  ; add high byte of y*40 to ptr1 high (with carry)
        sta     ptr1+1

        ; get character back and apply reverse video if needed
        pla
        bit     reverse_flag
        bpl     :+                      ; branch if reverse not set
        eor     #$80                    ; apply reverse video (toggle bit 7)

:       ; write character to screen using cursor_x as index
        ldy     cursor_x
        sta     (ptr1), y

        ; advance cursor
        inc     cursor_x
        lda     cursor_x
        cmp     #SCREEN_WIDTH
        bcc     done                    ; branch if still in bounds

        ; wrap to next line
        lda     #$00
        sta     cursor_x
        inc     cursor_y
        lda     cursor_y
        cmp     #SCREEN_HEIGHT
        bcc     done
        lda     #$00                    ; wrap to top if past bottom
        sta     cursor_y

done:   rts
.endproc

;
; cputs(s) - put string at current cursor position
; Parameters: A/X = pointer to string (low/high)
;
.proc _cputs
        sta     ptr2                    ; store string pointer
        stx     ptr2+1

        ldy     #$00
loop:   lda     (ptr2), y               ; get character
        beq     done                    ; exit if null terminator
        sty     @y_val                  ; save Y value destroyed by cputc
        jsr     _cputc                  ; output character
        ldy     #$00                    ; will be amend
@y_val  = *-1
        iny
        bne     loop                    ; continue if Y didn't wrap
        inc     ptr2+1                  ; increment high byte
        bne     loop                    ; should always branch

done:   rts
.endproc

;
; cputcxy(x, y, c) - put character at specific position and move cursor there
; Parameters: A = character, stack = y, x (cc65 calling convention)
; This is equivalent to gotoxy(x, y) followed by cputc(c)
;
.proc _cputcxy
        ; Save character and get coordinates from stack
        pha                             ; save character
        jsr     popa                    ; get Y from stack (into A)
        jsr     _gotoxy                 ; gotoxy(x=stack, y=A)                

        ; output character (cputc functionality)
        pla                             ; get character back
        jmp     _cputc                  ; tail call to cputc (handles cursor advance)
.endproc

;
; cputsxy(x, y, s) - put string at specific position and move cursor there
; Parameters: A/X = pointer to string (low/high), stack = y, x (cc65 calling convention)
; This is equivalent to gotoxy(x, y) followed by cputs(s)
;
.proc _cputsxy
        ; Save string pointer and get coordinates from stack  
        pha                             ; save string low byte
        txa                             ; get string high byte
        pha                             ; save string high byte
        
        ; Stack currently has [x, y] (y on top)
        ; _gotoxy expects gotoxy(x, y) = A=y, stack=x
        jsr     popa                    ; get Y from stack (into A)
        ; Stack now has [x], A=y
        ; This is exactly what _gotoxy expects: A=y, stack=x
        jsr     _gotoxy                 ; gotoxy(x=stack, y=A)

        ; output string (cputs functionality)
        pla                             ; get string high byte
        tax                             ; put in X
        pla                             ; get string low byte
        jmp     _cputs                  ; tail call to cputs
.endproc

;
; revers(flag) - set reverse video mode
; Parameters: A = flag (0 = normal, non-zero = reverse)
; Returns: previous reverse state in A (0 = was normal, non-zero = was reverse)
;
.proc _revers
        ldx     reverse_flag            ; get current state to return
        cmp     #$00                    ; check input parameter A
        beq     :+                      ; if input A is zero, clear flag
        lda     #$80                    ; set reverse flag (non-zero input)
        bne     store                   ; always branch
:       lda     #$00                    ; clear reverse flag (zero input)
store:  sta     reverse_flag
        txa                             ; return previous state in A
        rts
.endproc


.bss
; Screen memory buffer (40x24 = 960 bytes)
screen_memory:  .res SCREEN_SIZE

; Cursor position
cursor_x:       .res 1
cursor_y:       .res 1

; Reverse video flag
reverse_flag:   .res 1 