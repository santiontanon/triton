game_ending_text:
	db TEXT_E_CUTSCENE_1_BANK, TEXT_E_CUTSCENE_1_IDX
	db TEXT_E_CUTSCENE_2_BANK, TEXT_E_CUTSCENE_2_IDX
	db TEXT_E_CUTSCENE_3_BANK, TEXT_E_CUTSCENE_3_IDX
	db TEXT_E_CUTSCENE_4_BANK, TEXT_E_CUTSCENE_4_IDX
	db TEXT_E_CUTSCENE_5_BANK, TEXT_E_CUTSCENE_5_IDX
	db TEXT_E_CUTSCENE_6_BANK, TEXT_E_CUTSCENE_6_IDX
	db TEXT_E_CUTSCENE_7_BANK, TEXT_E_CUTSCENE_7_IDX
	db TEXT_E_CUTSCENE_8_BANK, TEXT_E_CUTSCENE_8_IDX
	db TEXT_E_CUTSCENE_9_BANK, TEXT_E_CUTSCENE_9_IDX
	db TEXT_E_CUTSCENE_7_BANK, TEXT_E_CUTSCENE_7_IDX
	db TEXT_E_CUTSCENE_10_BANK, TEXT_E_CUTSCENE_10_IDX
	db TEXT_E_CUTSCENE_11_BANK, TEXT_E_CUTSCENE_11_IDX
	db TEXT_E_CUTSCENE_12_BANK, TEXT_E_CUTSCENE_12_IDX


;-----------------------------------------------
state_game_ending:
    ; reset the stack:
    ld sp,#F380

    call StopMusic

	call disable_VDP_output
		call clearAllTheSprites
		call set_bitmap_mode

		; load UI tiles into bank 0:
		ld hl,ui_tiles_plt
		ld de,buffer
		call unpack_compressed
		call load_groupped_tile_data_into_vdp_bank0
		ld a,31
		ld hl,NAMTBL2
		ld bc,256
		call fast_FILVRM
		; set vertical bitmap mode in bank 1:
		call set_vertical_bitmap_name_table_bank1
		; bank 2 was already cleared by set_bitmap_mode above

		; render all the text lines in a buffer:
		ld (hl),0
		ld hl,buffer
		ld de,buffer+1
		ld bc,16*8*14-1	; we clear 13 lines (one more than needed, to have an empty line at the end)
		ldir

		ld b,13
		ld hl,game_ending_text
		ld de,buffer
state_game_ending_pre_render_text_loop:
		push bc
			ld c,(hl)
			inc hl
			ld a,(hl)
			inc hl
			push hl
				push de
				    ld de,text_buffer
 				    call get_text_from_bank
 				    call clear_text_rendering_buffer
					ld hl,text_buffer
					ld bc,16*8
 					call draw_sentence_pre_render
 				pop de
 				push de
 					; copy to buffer:
 					ld hl,text_draw_buffer
 					ld bc,16*8
 					ldir
				pop hl
				ld bc,16*8
				add hl,bc
				ex de,hl
			pop hl
		pop bc
		djnz state_game_ending_pre_render_text_loop

		; set the attributes for the scroll area:
		ld a,#f0
		ld hl,CLRTBL2+256*8
		ld bc,256*8
		call fast_FILVRM

		; load name tables:
		ld hl,cutscene_gfx_plt
		ld de,cutscene_gfx_buffer
		call unpack_compressed

	call enable_VDP_output

	; play music:
	ld ix,decompress_ending_song_from_page1
	call call_from_page1
    ld a,(isComputer50HzOr60Hz)
    add a,a
    add a,10	; 10 if 50Hz, 12 if 60Hz
    call PlayMusic

    ld hl,0
    ld (ending_timer),hl
state_game_ending_loop:
	halt

    call update_keyboard_buffers
    ld a,(keyboard_line_clicks)
    bit 0,a
    jp nz,state_gameover_screen

	ld a,(interrupt_cycle)
	and #07
	jr nz,state_game_ending_loop

	; scroll the middle of page 1 pixel up:
    call ending_scroll_bank1_up

    ; draw one line of text at the bottom:
    call ending_draw_next_text_line

    ; at certain times draw/delete the cutscene images in bank 0:
    ld a,(ending_timer)
    cp 8
    call z,ending_scroll_draw_image1
    cp 96
    call z,ending_scroll_clear_image
    cp 104
    call z,ending_scroll_draw_image2
    cp 192
    call z,ending_scroll_clear_image

	; jp state_braingames_screen

    jr state_game_ending_loop



;-----------------------------------------------
ending_scroll_clear_image:
	ld a,31
	ld hl,NAMTBL2
	ld bc,256
	jp fast_FILVRM


ending_scroll_draw_image1:
	ld hl,cutscene_gfx_buffer+12*6*3
ending_scroll_draw_image1_entry_point:
	ld de,NAMTBL2+32+10
	ld b,6
ending_scroll_draw_image1_loop:	
	push bc
		push hl
			push de
				ld bc,10
				call fast_LDIRVM
			pop hl
			ld bc,32
			add hl,bc
			ex de,hl
		pop hl
		ld c,12
		add hl,bc
	pop bc
	djnz ending_scroll_draw_image1_loop
	ret

ending_scroll_draw_image2:
	ld hl,cutscene_gfx_buffer+12*6*4
	jr ending_scroll_draw_image1_entry_point


;-----------------------------------------------
ending_scroll_bank1_up:
	ld hl,CHRTBL2+256*8+8*8*8+1
	ld b,16
ending_scroll_bank1_up_loop:
	push bc
		ld de,buffer5
		ld bc,8*8-1
		push hl
		push de
		push bc
			call fast_LDIRMV
		pop bc
		pop hl	; notice we are swapping hl and de
		pop de
		dec de
		; hl = buffer5
		; de = CHRTBL2+...
		push de
			call fast_LDIRVM
		pop hl
		ld bc,8*8+1
		add hl,bc
	pop bc
	djnz ending_scroll_bank1_up_loop
	ret


;-----------------------------------------------
ending_draw_next_text_line:
	ld hl,(ending_timer)
	inc hl
	ld (ending_timer),hl

	bit 3,l
	jr z,ending_draw_next_text_line_text
ending_draw_next_text_line_intertext:
	ld de,buffer+16*8*8	; select the empty line
	jr ending_draw_next_text_line_ptr_set

ending_draw_next_text_line_text:
	ex de,hl
	ld a,e
    and #07
    ld hl,buffer
    ld b,l	; buffer ix 256 aligned, so l == 0
    ld c,a
    add hl,bc
    ld bc,16*8
    ld a,e
    srl d	; we take the lsb of d, so that the counter is 9 bit
    rr a
    rrca
    rrca
    rrca
    and #1f	; line
    jr z,ending_draw_next_text_line_text_loop_end
    cp 1
    jr c,ending_draw_next_text_line_text_loop
    jr z,ending_draw_next_text_line_intertext
    dec a
    cp 5
    jr c,ending_draw_next_text_line_text_loop
    jr z,ending_draw_next_text_line_intertext
    dec a
    cp 7
    jr c,ending_draw_next_text_line_text_loop
    jr z,ending_draw_next_text_line_intertext
    dec a
    cp 9
    jr c,ending_draw_next_text_line_text_loop
    jr z,ending_draw_next_text_line_intertext
    dec a
    cp 12
    jr c,ending_draw_next_text_line_text_loop
    jr z,ending_draw_next_text_line_intertext
    dec a
    cp 13
    jr nc,ending_draw_next_text_line_intertext

ending_draw_next_text_line_text_loop:
    add hl,bc
    dec a
    jr nz,ending_draw_next_text_line_text_loop
ending_draw_next_text_line_text_loop_end:
	ex de,hl
ending_draw_next_text_line_ptr_set:

    ld hl,CHRTBL2+256*8+71*8+7
    ld b,16
ending_draw_next_text_line_loop:
    push bc
	    push hl
		    push de
		    	ld a,(de)
			    call writeByteToVDP
			pop hl
			ld bc,8
			add hl,bc
			ex de,hl
		pop hl
		ld c,8*8
		add hl,bc
	pop bc
	djnz ending_draw_next_text_line_loop
	ret


;-----------------------------------------------
load_groupped_tile_data_into_vdp_bank0:
	ld hl,buffer
	ld de,CHRTBL2
	ld b,11*16

load_groupped_tile_data_into_vdp_bank0_loop:
	push bc
		push hl
			push de
				ld bc,8
				call fast_LDIRVM
			pop hl
			ld bc,CLRTBL2-CHRTBL2
			add hl,bc
			ex de,hl
		pop hl
		ld bc,8
		add hl,bc
		push hl
			push de
; 				ld bc,8
				call fast_LDIRVM
			pop hl
			ld bc,CHRTBL2+8-CLRTBL2
			add hl,bc
			ex de,hl
		pop hl
		ld bc,8
		add hl,bc
	pop bc
	djnz load_groupped_tile_data_into_vdp_bank0_loop
	ret
