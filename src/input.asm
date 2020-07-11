;-----------------------------------------------
; In the weapons screen we need some additional keyboard matrix rows
update_keyboard_buffers_weapons_screen:
    call update_keyboard_buffers
    ld a,#07
    call SNSMAT ; RET SELECT BS STOP TAB ESC F5 F4
    bit 2,a
    ret nz
    ld hl,keyboard_line_state+2
    ld a,(hl)
    and #fb     ; button2 if "ESC" is pressed
    ld (hl),a
    ret


;-----------------------------------------------
; updates the 'keyboard_line_state' and 'keyboard_line_state_prev' buffers
update_keyboard_buffers:
    ld de,keyboard_line_state
    ld hl,keyboard_line_state_prev
    ld bc,#0301
update_keyboard_buffers_loop:
        ld a,(de)
        xor (hl)
        and (hl)    ; a now has the value to save in "keyboard_line_clicks" (which is "keyboard_line_state", offset by 1)
        ex de,hl
        ldi
        inc c
        ex de,hl
        ld (de),a   ; save the click in "keyboard_line_clicks"
        inc de
    djnz update_keyboard_buffers_loop

    ld a,#08
    call SNSMAT
    ld (keyboard_line_state),a  ; RIGHT, DOWN, UP, LEFT, DEL, INS, HOME, SPACE

    ld a,#04
    call SNSMAT
    ld (keyboard_line_state+2),a    ; R, Q, P, O, N, M, L, K

    ld a,#06
    call SNSMAT
    ld (keyboard_line_state+4),a    ; F3, F2, F1, CODE, CAPS, GRAPH, CTRL, SHIFT

    ; jp read_joystick


;-----------------------------------------------
; Reads the joystick status, and updates the corresponding keyboard_line_state to treat it as if it was the keyboard
read_joystick:   
    ld a,15 ; read the joystick 1 status:
    call RDPSG
    and #bf
    ld e,a
    ld a,15
    call WRTPSG
    dec a
    call RDPSG  ; a = -, -, B, A, right, left, down, up
    ; convert the joystick input to keyboard input
    ld c,a
    ; arrows/space:
    ld hl,keyboard_line_state
    ld a,(hl)
    
    rr c
    jr c,read_joystick_noUp
    and #df
read_joystick_noUp:

    rr c
    jr c,read_joystick_noDown
    and #bf
read_joystick_noDown:

    rr c
    jr c,read_joystick_noLeft
    and #ef
read_joystick_noLeft:

    rr c
    jr c,read_joystick_noRight
    and #7f
read_joystick_noRight:

    rr c
    jr c,read_joystick_noA
    and #fe
read_joystick_noA:

    ld (hl),a   ; we add the joystick input to the keyboard input

    ; m (button 2):
    inc hl
    inc hl  ; hl = keyboard_line_state+2
    ld a,(hl)
    rr c
    jr c,read_joystick_noB
    and #fb
read_joystick_noB:
    ld (hl),a   ; we add the joystick input to the keyboard input

    ret


;-----------------------------------------------
; Waits until the player presses space
; wait_for_space:
;     call update_keyboard_buffers
;     ld a,(keyboard_line_clicks)
;     bit 0,a
;     ret nz
;     halt
;     jr wait_for_space
