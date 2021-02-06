;-----------------------------------------------
; Title screen state
state_title_screen:
	call StopMusic
	call disable_VDP_output
		call clearScreen
		ld hl,CHRTBL2
		ld bc,768*8
		xor a
		call fast_FILVRM

		; tiles:
		ld hl,title_screen_tiles_plt
		ld de,buffer
		call unpack_compressed
		ld hl,buffer
		ld bc,1056
		push hl
		push bc
			ld de,CHRTBL2+8
			call fast_LDIRVM
		pop bc
		pop hl
		push bc
			ld de,CHRTBL2+256*8+8
			call fast_LDIRVM
		pop bc
		ld hl,buffer+1056
		push hl
		push bc
			ld de,CLRTBL2+8
			call fast_LDIRVM
		pop bc
		pop hl
		ld de,CLRTBL2+256*8+8
		call fast_LDIRVM

		; name table:
		ld hl,title_screen_data_plt
		ld de,buffer
		push de
			call unpack_compressed
		pop hl
		ld de,NAMTBL2+32
		ld bc,14*32
		call fast_LDIRVM

		call set_bitmap_name_table_bank3

		; sprites:
		ld hl,buffer+14*32
		ld de,SPRTBL2
		ld bc,13*32
		call fast_LDIRVM

		ld hl,buffer+14*32+13*32
		ld de,SPRATR2
		ld bc,13*4
		call fast_LDIRVM
	call enable_VDP_output

	; draw "THE MENACE FROM":
	ld c,TEXT_SUBTITLE_BANK
	ld a,TEXT_SUBTITLE_IDX
	ld de,CHRTBL2+(256+224)*8-2
	ld iyl,COLOR_GREEN*16
	call draw_text_from_bank_16

	; draw credits:
	ld c,TEXT_CREDITS_BANK
	ld a,TEXT_CREDITS_IDX
	ld de,CHRTBL2+(512+5*32+8)*8
	ld iyl,COLOR_WHITE*16
	call draw_text_from_bank_16

	; draw version:
	ld bc,TEXT_VERSION_BANK + 4*8*256
	ld a,TEXT_VERSION_IDX
	ld de,CHRTBL2+(512+7*32)*8
	ld iyl,COLOR_WHITE*16
	call draw_text_from_bank

	ld bc,300	; after some time, jump to story
state_title_screen_loop:
	halt
	dec bc
	ld a,b
	or c
	jr z,state_title_screen_loop_go_to_story

	push bc
	    call update_keyboard_buffers
	pop bc
    ld a,(keyboard_line_clicks)
;     bit 0,a
;     jr nz,state_title_screen_loop_done
    rra
    jr c,state_title_screen_loop_done

	ld a,(interrupt_cycle)
	and #10
	jr nz,state_title_screen_loop_clear
state_title_screen_loop_draw:
	; draw press fire to start:
	push bc	
		ld c,TEXT_PRESS_FIRE_BANK
		ld a,TEXT_PRESS_FIRE_IDX
		ld de,CHRTBL2+(512+1*32+10)*8
		ld iyl,COLOR_WHITE*16
		call draw_text_from_bank_16
	pop bc
	jr state_title_screen_loop
state_title_screen_loop_clear:
	push bc
		ld hl,CHRTBL2+(512+1*32+10)*8
		ld bc,13*8
		xor a
		call FILVRM
	pop bc
	jr state_title_screen_loop

state_title_screen_loop_done:
	call clearScreenLeftToRight
	jp state_mission_screen_new_game

state_title_screen_loop_go_to_story:
	call clearScreenLeftToRight
	jp state_story
