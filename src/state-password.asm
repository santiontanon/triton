	include "password-constants.asm"


;-----------------------------------------------
text_from_current_password:
	exx
		ld hl,password_text_buffer
	exx
	ld c,PASSWORD_CHARACTERS_SIZE-1
	ld hl,password_buffer
	ld e,8
	ld d,(hl)

text_from_current_password_loop:
	ld b,5
	xor a
text_from_current_password_bit_loop:
	call password_get_next_bit
	djnz text_from_current_password_bit_loop

	exx
		ld (hl),a
		inc hl
	exx
	dec c
	jr nz,text_from_current_password_loop
	; finally the check-sum can be written directly:
	ld a,(hl)
	exx
		ld (hl),a
	exx	
	ret


;-----------------------------------------------
draw_current_password:
; 	ld de,text_buffer
	ld c,TEXT_PASSWORD_TABLE_BANK
	ld a,TEXT_PASSWORD_TABLE_IDX
	call get_text_from_bank
	call clear_text_rendering_buffer

	ld de,buffer5
	ld a,1
	ld (de),a	; length 1
	inc de

	ld ix,password_text_buffer
	ld hl,CHRTBL2+(8*32+16-(PASSWORD_CHARACTERS_COLUMNS/2))*8
	ld (password_draw_ptr),hl

	ld b,PASSWORD_CHARACTERS_ROWS
draw_current_password_loop_y:
	push bc
		ld b,PASSWORD_CHARACTERS_COLUMNS
draw_current_password_loop_x:
		push bc
		push de
			push ix
				ld b,0
				ld c,(ix)
				ld hl,text_buffer+1
				add hl,bc
				ld a,(hl)
				ld (de),a
				ld bc,1*8
				ld de,(password_draw_ptr)
				ld h,d
				ld l,e
				add hl,bc
				ld (password_draw_ptr),hl
				ld hl,buffer5
				ld iyl,COLOR_WHITE*16
				call draw_sentence
				call clear_text_rendering_buffer
			pop ix
		inc ix
		pop de
		pop bc
		djnz draw_current_password_loop_x

		; next line:
		ld hl,(password_draw_ptr)
		ld bc,8*(32-PASSWORD_CHARACTERS_COLUMNS)
		add hl,bc
		ld (password_draw_ptr),hl

	pop bc
	djnz draw_current_password_loop_y

	ret


;-----------------------------------------------
state_password_draw_cursor:
	ld hl,ui_cursor_sprites
	ld bc,2*4-1
	call clear_memory

	ld a,(interrupt_cycle)
	bit 3,a
	ret z

	ld a,(ui_cursor_area)
	cp PASSWORD_CHARACTERS_ROWS
	jr z,state_password_draw_cursor_buttons

	; letters:
	add a,a
	add a,a
	add a,a
	add a,8*8-4
	ld c,a
	ld a,(ui_cursor_position)
	add a,a
	add a,a
	add a,a
	add a,(16-(PASSWORD_CHARACTERS_COLUMNS/2))*8-2
	ld d,a
	add a,-6
	ld e,a
	jp state_mission_draw_cursor_buttons_continue

state_password_draw_cursor_buttons:
	ld c,131
	ld a,(ui_cursor_position)
	cp PASSWORD_CHARACTERS_COLUMNS/2
	jr nc,state_password_draw_cursor_buttons_back
	ld de,78*256+98
	jr state_password_draw_cursor_buttons_continue
state_password_draw_cursor_buttons_back:	
	ld de,142*256+162
state_password_draw_cursor_buttons_continue:
	jp state_mission_draw_cursor_buttons_continue


;-----------------------------------------------
state_password_move_cursor:
	ld a,(keyboard_line_clicks)
	bit KEY_UP_BIT,a
	jr nz,state_password_move_cursor_up
	bit KEY_DOWN_BIT,a
	jr nz,state_password_move_cursor_down
	bit KEY_RIGHT_BIT,a
	jr nz,state_password_move_cursor_right
	bit KEY_LEFT_BIT,a
	jr nz,state_password_move_cursor_left
	bit KEY_BUTTON1_BIT,a
	jr nz,state_password_move_cursor_button1
	ret

state_password_move_cursor_up:
	ld hl,ui_cursor_area
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	

state_password_move_cursor_down:
	ld hl,ui_cursor_area
	ld a,(hl)
	cp PASSWORD_CHARACTERS_ROWS
	ret z
	inc (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	

state_password_move_cursor_right:
	ld a,(ui_cursor_area)
	cp PASSWORD_CHARACTERS_ROWS
	ld hl,ui_cursor_position
	jr z,state_password_move_cursor_right_buttons
	ld a,(hl)
	cp PASSWORD_CHARACTERS_COLUMNS-1
	ret z
	inc (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	
state_password_move_cursor_right_buttons:
	ld a,(hl)
	cp PASSWORD_CHARACTERS_COLUMNS-1
	ret z
	ld (hl),PASSWORD_CHARACTERS_COLUMNS-1
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	


state_password_move_cursor_left:
	ld a,(ui_cursor_area)
	cp PASSWORD_CHARACTERS_ROWS
	ld hl,ui_cursor_position
	jr z,state_password_move_cursor_let_buttons
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	
state_password_move_cursor_let_buttons:
	ld a,(hl)
	or a
	ret z
	ld (hl),0
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	


state_password_move_cursor_button1:
	ld a,(ui_cursor_area)
	cp PASSWORD_CHARACTERS_ROWS
	ret nz
	ld a,(ui_cursor_position)
	cp PASSWORD_CHARACTERS_COLUMNS/2
	jr nc,state_password_move_cursor_button1_back
state_password_move_cursor_button1_load:
	call password_bits_from_text
	call password_get_checksum
	cp (hl)
	jr z,state_password_move_cursor_button1_load_ok
	ld hl,SFX_ui_wrong
	jp play_SFX_with_high_priority
state_password_move_cursor_button1_load_ok:
	call init_game_from_password	
state_password_move_cursor_button1_back:
	ld hl,SFX_ui_select
	call play_SFX_with_high_priority
	call clearScreenLeftToRight
	jp state_mission_screen_from_password


;-----------------------------------------------
state_password:
	call StopMusic

	call disable_VDP_output
		call set_bitmap_mode
		ld hl,ui_tiles_plt
		ld de,buffer
		call unpack_compressed

		ld hl,CHRTBL2+(6*32+(14-PASSWORD_CHARACTERS_COLUMNS/2))*8
		ld bc,(PASSWORD_CHARACTERS_COLUMNS+4) + (PASSWORD_CHARACTERS_ROWS+4)*256
		call ui_draw_frame

		; buttons:
		; load:
		ld hl,CHRTBL2+(32*16+10)*8
		ld bc,3*256+4*8
		push bc
			ld a,COLOR_DARK_BLUE
			call draw_button
			ld bc,TEXT_LOAD_BANK + 4*8*256
			ld a,TEXT_LOAD_IDX
			ld de,CHRTBL2+(32*17+10)*8
			ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
			call draw_text_from_bank

			; back:
			ld hl,CHRTBL2+(32*16+18)*8
		pop bc
		ld a,COLOR_DARK_BLUE
		call draw_button
		ld bc,TEXT_BACK_BANK + 4*8*256
		ld a,TEXT_BACK_IDX
		ld de,CHRTBL2+(32*17+18)*8
		ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
		call draw_text_from_bank

		call password_from_current_state
		call text_from_current_password
		call draw_current_password

	call enable_VDP_output

	ld ix,decompress_weapons_song_from_page1
	call call_from_page1
    ld a,(isComputer50HzOr60Hz)
    add a,5	; 5 if 50Hz, 6 if 60Hz
    call PlayMusic

	xor a
	ld hl,ui_cursor_area
	ld (hl),a
	inc hl  ; ui_cursor_position
	ld (hl),a

    call getcharacter_nonwaiting_reset	

state_password_loop:
	halt

    call update_keyboard_buffers
    call state_password_move_cursor

	; draw the cursor:
	call state_password_draw_cursor
	ld hl,ui_cursor_sprites
	ld de,SPRATR2
	ld bc,8
	call fast_LDIRVM

    call getcharacter_nonwaiting
    or a
    jr z,state_password_loop
	
	; key pressed, modify password:
	cp '0'
	jr c,state_password_loop
	cp '9'+1
	jr c,state_password_loop_number_pressed
    and #df ; make it upper case
	cp 'A'
	jr c,state_password_loop
	cp 'V'+1
	jr c,state_password_loop_letter_pressed
	jr state_password_loop

state_password_loop_number_pressed:
	sub '0'
	jr write_password_character

state_password_loop_letter_pressed:
	sub 'A'-10
; 	jr write_password_character

write_password_character:
	ld e,a
	ld hl,ui_cursor_area
	ld d,(hl)
	xor a
write_password_character_loop:
	add a,PASSWORD_CHARACTERS_COLUMNS
	dec d
	jr nz,write_password_character_loop
	ld hl,ui_cursor_position
	add a,(hl)
	ld b,0
	ld c,a

	inc (hl)	
	ld a,(hl)
	cp PASSWORD_CHARACTERS_COLUMNS
	jr nz,write_password_character_no_next_line
	ld (hl),0
	ld hl,ui_cursor_area
	inc (hl)
write_password_character_no_next_line:
	ld hl,password_text_buffer
	add hl,bc
	ld (hl),e
	call draw_current_password
	jr state_password_loop
