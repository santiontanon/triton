story_cutscene_1_text:
	db TEXT_CUTSCENE_1_1_BANK, #f0, TEXT_CUTSCENE_1_1_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_1_2_BANK, #f0, TEXT_CUTSCENE_1_2_IDX
	db TEXT_CUTSCENE_1_3_BANK, #f0, TEXT_CUTSCENE_1_3_IDX
	db TEXT_CUTSCENE_1_4_BANK, #f0, TEXT_CUTSCENE_1_4_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_1_5_BANK, #f0, TEXT_CUTSCENE_1_5_IDX
	db #ff  ; end of text

story_cutscene_2_text:
	db TEXT_CUTSCENE_2_1_BANK, #f0, TEXT_CUTSCENE_2_1_IDX
	db TEXT_CUTSCENE_2_2_BANK, #f0, TEXT_CUTSCENE_2_2_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_2_3_BANK, #70, TEXT_CUTSCENE_2_3_IDX
	db TEXT_CUTSCENE_2_4_BANK, #70, TEXT_CUTSCENE_2_4_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_2_5_BANK, #70, TEXT_CUTSCENE_2_5_IDX
	db #ff  ; end of text
story_cutscene_2_sprite:
	db 39,137,16,COLOR_BLUE

story_cutscene_3_text:
	db TEXT_CUTSCENE_3_1_BANK, #70, TEXT_CUTSCENE_3_1_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_3_2_BANK, #70, TEXT_CUTSCENE_3_2_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_3_3_BANK, #70, TEXT_CUTSCENE_3_3_IDX
	db #ff  ; end of text

story_cutscene_4_text:
	db TEXT_CUTSCENE_4_1_BANK, #f0, TEXT_CUTSCENE_4_1_IDX
	db TEXT_CUTSCENE_4_2_BANK, #f0, TEXT_CUTSCENE_4_2_IDX
	db #ff  ; end of text

story_cutscene_5_text:
	db TEXT_CUTSCENE_5_1_BANK, #90, TEXT_CUTSCENE_5_1_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_5_2_BANK, #90, TEXT_CUTSCENE_5_2_IDX
	db TEXT_CUTSCENE_5_3_BANK, #90, TEXT_CUTSCENE_5_3_IDX
	db TEXT_CUTSCENE_5_4_BANK, #90, TEXT_CUTSCENE_5_4_IDX
	db TEXT_CUTSCENE_5_5_BANK, #90, TEXT_CUTSCENE_5_5_IDX
	db #fe	; new line
	db TEXT_CUTSCENE_5_6_BANK, #90, TEXT_CUTSCENE_5_6_IDX
	db #ff  ; end of text


;-----------------------------------------------
state_story:
	call disable_VDP_output
		call setup_ui_gfx

		ld hl,cutscene_gfx_plt
		ld de,cutscene_gfx_buffer
		call unpack_compressed
	call enable_VDP_output

	push iy
		ld ix,decompress_story_song_from_page1
		call call_from_page1
	    ld a,(isComputer50HzOr60Hz)
	    add a,a
	    add a,10	; 10 if 50Hz, 12 if 60Hz
	    call PlayMusic
	pop iy

	; scene 1:
	ld iyh,24*8	
	ld hl,story_cutscene_1_text
	ld de,CHRTBL2+(4*32+4)*8
	call state_story_cutscene
	call set_bitmap_mode

	; scene 2:
	ld hl,cutscene_gfx_buffer
	call draw_cutscene_image
	ld hl,story_cutscene_2_sprite
	ld de,SPRATR2
	ld bc,4
	call fast_LDIRVM
	ld hl,story_cutscene_2_text
	ld de,CHRTBL2+(12*32+4)*8
	call state_story_cutscene
	ld hl,CHRTBL2+(12*32)*8
	ld bc,32*7*8
	xor a
	call fast_FILVRM

	; scene 3:
	ld hl,story_cutscene_3_text
	ld de,CHRTBL2+(12*32+4)*8
	call state_story_cutscene
	ld hl,CHRTBL2+(12*32)*8
	ld bc,32*7*8
	xor a
	call fast_FILVRM
	ld hl,SPRATR2
	ld bc,4
	xor a
	call fast_FILVRM
	ld hl,cutscene_gfx_buffer+6*12
	call draw_cutscene_image

	; scene 4:
	ld hl,story_cutscene_4_text
	ld de,CHRTBL2+(12*32+4)*8
	call state_story_cutscene
	ld hl,CHRTBL2+(12*32)*8
	ld bc,32*7*8
	xor a
	call fast_FILVRM
	ld hl,cutscene_gfx_buffer+6*12*2
	call draw_cutscene_image

	; scene 5:
	ld hl,story_cutscene_5_text
	ld de,CHRTBL2+(12*32+4)*8
	call state_story_cutscene
	call clearScreenLeftToRight

	jp state_braingames_screen


;-----------------------------------------------
; de: pointer to draw
; hl: text lines
; iyh: line width
state_story_cutscene:
	xor a
	ld (text_skip),a
state_story_cutscene_loop:
	ld a,(hl)
	inc hl
	cp #fe	; new line
	jr z,state_story_cutscene_new_line
	cp #ff
	jr z,state_story_cutscene_done_with_text
	ld c,a
	ld a,(hl)	; color
	ld iyl,a
	inc hl
	ld a,(hl)
	inc hl
	push hl
	push de
	push iy
		ld b,iyh
		call draw_text_from_bank_slow
	pop iy
	pop de
	pop hl
state_story_cutscene_new_line:
	ex de,hl
		ld bc,32*8
		add hl,bc
	ex de,hl	
	jr state_story_cutscene_loop

state_story_cutscene_done_with_text:
state_story_loop:
	halt
	push bc
	    call update_keyboard_buffers
	pop bc
	; wait a few seconds and skip to the menu:
    ld a,(keyboard_line_clicks)
    bit 0,a
    jr z,state_story_loop
    ret


;-----------------------------------------------
draw_cutscene_image:
	ld de,CHRTBL2+(4*32+10)*8
	ld c,6
draw_cutscene_image_y_loop:
	ld b,12
draw_cutscene_image_x_loop:
	ld a,(hl)
	inc hl
	push bc
	push hl
		push de
			call draw_tile_bitmap_mode_by_index
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop hl
	pop bc
	djnz draw_cutscene_image_x_loop
	push bc
		ex de,hl
		ld bc,20*8
		add hl,bc
		ex de,hl
	pop bc
	dec c
	jr nz,draw_cutscene_image_y_loop
	ret
