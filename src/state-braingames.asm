;-----------------------------------------------
; Screen with the Brain Games logo
state_braingames_screen:
	call StopMusic	

	; set up the video memory:
	call disable_VDP_output
		ld a,#f0
		call set_bitmap_mode_a_color
	call enable_VDP_output

	; draw the logo line by line:
	; start line 1:
	ld hl,braingames_lines
	ld (line1_next_ptr),hl
	ld ix,line1_state
	call draw_line_start

	; start line 2:
	ld hl,braingames_lines
	ld (line2_next_ptr),hl
	ld ix,line2_state
	call draw_line_start
	ld a,32
	ld (line2_delay),a

state_btaingames_screen_logo_loop:
	halt 

    call update_keyboard_buffers
    ld a,(keyboard_line_clicks)
    bit 0,a
    jr nz,state_braingames_screen_loop_done	

	call state_braingames_screen_loop_draw_cycle
	call state_braingames_screen_loop_draw_cycle
	call state_braingames_screen_loop_draw_cycle
	jr z,state_btaingames_screen_logo_loop

	; fade in:
	ld hl,CLRTBL2+9*256
	ld bc,6*256
	ld a,#00
	call fast_FILVRM

	; draw the logo all in white:
	; restart line 1:
	ld hl,braingames_lines
	ld (line1_next_ptr),hl
	ld ix,line1_state
	call draw_line_start
	ld a,#ff
	ld (line2_delay),a	; mark that we don't need line 2
state_btaingames_screen_logo_loop2:
	call state_braingames_screen_loop_draw_cycle
	jr z,state_btaingames_screen_logo_loop2

	; draw "presents":
	ld c,TEXT_PRESENTS_BANK
	ld a,TEXT_PRESENTS_IDX
	ld de,CHRTBL2+(256+5*32+13)*8
	ld iyl,#00
	call draw_text_from_bank_16

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,5*256
	ld a,#40
	call fast_FILVRM

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,5*256
	ld a,#e0
	call fast_FILVRM

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,5*256
	ld a,#f0
	call fast_FILVRM

	ld c,0
state_braingames_screen_loop:
	halt
	push bc
	    call update_keyboard_buffers
	pop bc
	; wait a few seconds and skip to the story:
	inc c
	jr z,state_braingames_screen_loop_done
    ld a,(keyboard_line_clicks)
    bit 0,a
    jr z,state_braingames_screen_loop

state_braingames_screen_loop_done:
	call clearScreenLeftToRight
	jp state_title_screen


state_braingames_screen_loop_draw_cycle:
	ld hl,(line1_next_ptr)
	ld a,(hl)
	inc a
	jr z,state_btaingames_screen_logo_loop_line1_done
	ld ix,line1_state
	ld c,(ix)
	ld b,(ix+2)
	call draw_white_pixel	
	call draw_line_next_pixel
	jr nz,state_btaingames_screen_logo_loop_line1_no_next
	ld hl,(line1_next_ptr)
	ld bc,4
	add hl,bc
	ld (line1_next_ptr),hl
	call draw_line_start
state_btaingames_screen_logo_loop_line1_no_next:

	ld hl,line2_delay
	ld a,(hl)
	or a
	jr z,state_btaingames_screen_logo_loop_line2_draw
	inc a
	jr z,state_btaingames_screen_logo_loop_line2_no_next
	dec (hl)
	jr state_btaingames_screen_logo_loop_line2_no_next
state_btaingames_screen_logo_loop_line2_draw:
	ld hl,(line2_next_ptr)
	ld a,(hl)
	cp #ff
	jr z,state_btaingames_screen_logo_loop_line2_done
	ld ix,line2_state
	ld c,(ix)
	ld b,(ix+2)
	call draw_black_pixel	
	call draw_line_next_pixel
	jr nz,state_btaingames_screen_logo_loop_line2_no_next
	ld hl,(line2_next_ptr)
	ld bc,4
	add hl,bc
	ld (line2_next_ptr),hl
	call draw_line_start
state_btaingames_screen_logo_loop_line2_no_next:
	xor a
	ret

state_btaingames_screen_logo_loop_line1_done:
	ld hl,line2_delay
	ld a,(hl)
	cp #ff
	jr nz,state_btaingames_screen_logo_loop_line1_no_next

state_btaingames_screen_logo_loop_line2_done:
	or 1
	ret

braingames_lines:
	; B:
	db 0,88, 	83,83
	db 89,89, 	82,78
	db 89,84, 	78,72
	db 84,80, 	72,72
	db 80,80, 	72,82
	db 81,88, 	77,77
	; R:
	db 91,91,	83,72
	db 91,94,	72,72
	db 95,100,	72,77
	db 99,92,	77,77
	db 95,100,	78,83
	; A:
	db 102,102,	83,72
	db 103,105,	72,72
	db 106,111,	72,77
	db 111,111,	78,83
	db 110,103,	77,77
	; I:
	db 113,113,	83,72
	; N:
	db 115,115,	83,72
	db 116,118,	72,72
	db 119,123,	73,77
	db 123,123,	78,83

	; G:
	db 140,137,	72,72
	db 136,131,	72,77
	db 131,131,	78,83
	db 132,140,	83,83
	db 140,140,	82,78
	db 140,139,	77,77
	; A:
	db 142,142,	83,72
	db 142,146,	72,72
	db 147,151,	73,77
	db 151,151, 78,83
	db 150,143, 77,77
	; M:
	db 153,153,	83,72
	db 154,158,	73,77
	db 159,163,	76,72
	db 163,163,	73,83
	; E:
	db 172,165,	72,72
	db 165,165,	73,83
	db 166,172,	83,83
	db 166,170,	77,77
	; S:
	db 174,183,	83,83
	db 183,183,	82,77
	db 182,174,	77,77
	db 175,179, 76,72
	db 180,255,	72,72

	db #ff


;-----------------------------------------------
; methods for drawing lines pixel by pixel, for the brain games logo effect
; "draw_line_start" sets up the necessary data for then calling "draw_line_next_pixel" iteratively
; for each next pixel of the line:
; hl: new line to draw (4 bytes: x1,x2, y1,y2)
; ix: line state
draw_line_start:
	ld a,(hl)
	ld (ix),a	; x1
	inc hl
	sub (hl)
	jr nc,draw_line_start_positice_x_diff
	neg
draw_line_start_positice_x_diff:
	ld (ix+4),a	; |x1-x2|
	ld a,(hl)
	ld (ix+1),a	; x2
	inc hl
	ld a,(hl)
	ld (ix+2),a	; y1
	inc hl
	sub (hl)
	jr nc,draw_line_start_positice_y_diff
	neg
draw_line_start_positice_y_diff:
	ld (ix+5),a	; |y1-y2|
	ld a,(hl)
	ld (ix+3),a	; y2
	ld (ix+6),0
	ret

;-----------------------------------------------
; Bresenham one pixel update for drawing a line (must have called "draw_line_start" first)
; ix: line state
; returns: 
; - z: line complete
; - nz: line still ongoing
draw_line_next_pixel:
	; check if we have already made it to the destination:
	ld a,(ix)
	cp (ix+1)
	jr nz,draw_line_next_pixel_not_done
	ld a,(ix+2)
	cp (ix+3)
	ret z

draw_line_next_pixel_not_done:
	; advance the line state (bresenham):
	ld a,(ix+4)
	cp (ix+5)
	jr c,draw_line_next_pixel_vertical

draw_line_next_pixel_horizontal:
	; update "x"
	ld a,(ix)
	cp (ix+1)
	jr c,draw_line_next_pixel_horizontal_inc_x
	dec (ix)
	jr draw_line_next_pixel_horizontal_done_updating_x
draw_line_next_pixel_horizontal_inc_x:
	inc (ix)
draw_line_next_pixel_horizontal_done_updating_x:

	ld a,(ix+6)	; error term
	add a,(ix+5)	; error += y_diff
	cp (ix+4)	; if error > x_diff
	jr c,draw_line_next_pixel_horizontal_no_carry
	sub (ix+4)
	ld (ix+6),a	; update error term
	; update "y"
	ld a,(ix+2)
	cp (ix+3)
	jr c,draw_line_next_pixel_horizontal_inc_y
	dec (ix+2)
	jr draw_line_next_pixel_horizontal_done_updating_y
draw_line_next_pixel_horizontal_inc_y:
	inc (ix+2)
draw_line_next_pixel_horizontal_done_updating_y:
	or 1	; mark line is not done
	ret
draw_line_next_pixel_vertical_no_carry:
draw_line_next_pixel_horizontal_no_carry:
	ld (ix+6),a	; update error term
	or 1	; mark line is not done
	ret

draw_line_next_pixel_vertical:
	; update "y"
	ld a,(ix+2)
	cp (ix+3)
	jr c,draw_line_next_pixel_vertical_inc_y
	dec (ix+2)
	jr draw_line_next_pixel_vertical_done_updating_y
draw_line_next_pixel_vertical_inc_y:
	inc (ix+2)
draw_line_next_pixel_vertical_done_updating_y:

	ld a,(ix+6)	; error term
	add a,(ix+4)	; error += x_diff
	cp (ix+5)	; if error > y_diff
	jr c,draw_line_next_pixel_vertical_no_carry
	sub (ix+5)
	ld (ix+6),a	; update error term
	; update "x"
	ld a,(ix)
	cp (ix+1)
	jr c,draw_line_next_pixel_vertical_inc_x
	dec (ix)
	jr draw_line_next_pixel_vertical_done_updating_x
draw_line_next_pixel_vertical_inc_x:
	inc (ix)
draw_line_next_pixel_vertical_done_updating_x:
	or 1	; mark line is not done
	ret


;-----------------------------------------------
; auxiliary function for draw_white_pixel and draw_black_pixel:
draw_pixel_get_ptr:
    ; pixel address is: (y/8)*256+y%8 + (x/8)*8
    ; individual bit to draw is x%8
    ld a,b
    rrca
    rrca
    rrca
    and #1f ; a = y/8
    ld h,a
    ld a,b
    and #07
    ld l,a  ; hl = (y/8)*256+y%8
    ld a,c
    and #f8
    add a,l
    ld l,a  ; hl = (y/8)*256+y%8 + (x/8)*8
    ld a,c
    and #07
    ld c,a  ; c = x%8
    ret

; assuming the screen is in screen 2 bitmap mode, it draws one white pixel
; - c: x
; - b: y
draw_white_pixel:
    call draw_pixel_get_ptr
    ; read the current pixel:
    push hl
        push bc
            call RDVRM
        pop bc
        ; we have the byte in "a", now we need to apply a mask to it, and write it back
        ld hl,draw_white_pixel_bitmasks
        ld b,0
        add hl,bc
        or (hl)
    pop hl
    jp WRTVRM

draw_white_pixel_bitmasks:
    db #80, #40, #20, #10, #08, #04, #02, #01 


;-----------------------------------------------
; assuming the screen is in screen 2 bitmap mode, it draws one white pixel
; - c: x
; - b: y
draw_black_pixel:
    call draw_pixel_get_ptr
    ; read the current pixel:
    push hl
        push bc
            call RDVRM
        pop bc
        ; we have the byte in "a", now we need to apply a mask to it, and write it back
        ld hl,draw_black_pixel_bitmasks
        ld b,0
        add hl,bc
        and (hl)
    pop hl
    jp WRTVRM

draw_black_pixel_bitmasks:
    db #7f, #bf, #df, #ef, #f7, #fb, #fd, #fe 


