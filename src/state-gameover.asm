;-----------------------------------------------
state_gameover_screen:
    ; reset the stack:
    ld sp,#F380

    call StopMusic

	; set up the video memory:
	call disable_VDP_output
		call clearAllTheSprites
		call set_bitmap_name_table_all_banks
		ld hl,CLRTBL2
		ld bc,8*256*3
		ld a,#f0
		call fast_FILVRM
		ld hl,CHRTBL2
		ld bc,8*256*3
		xor a
		call fast_FILVRM

		; draw "game over":
		ld c,TEXT_GAMEOVER_BANK
		ld a,TEXT_GAMEOVER_IDX
		ld de,CHRTBL2+(256+1*32+13)*8
		ld iyl,#00
		call draw_text_from_bank_16
	call enable_VDP_output

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,256
	ld a,#40
	call fast_FILVRM

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,256
	ld a,#e0
	call fast_FILVRM

	ld b,8
	call wait_b_halts

	ld hl,CLRTBL2+9*256
	ld bc,256
	ld a,#f0
	call fast_FILVRM


	ld c,0
state_gameover_screen_loop:
	halt
	push bc
	    call update_keyboard_buffers
	pop bc
	inc c
	jr z,state_gameover_screen_loop_done
    ld a,(keyboard_line_clicks)
    bit 0,a
    jr z,state_gameover_screen_loop

state_gameover_screen_loop_done:
	call clearScreenLeftToRight
	jp COMPRESSED_state_braingames_screen

