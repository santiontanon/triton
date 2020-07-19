;-----------------------------------------------
state_weapons_screen:

	call StopMusic

	call disable_VDP_output
		call set_bitmap_mode
		ld hl,ui_tiles_plt
		ld de,buffer
		call unpack_compressed

		ld hl,CHRTBL2+(32+1)*8
		ld bc,11 + 23*256
		call ui_draw_frame

		ld hl,CHRTBL2+(32*4+12)*8
		ld bc,19 + 8*256
		call ui_draw_frame

		ld hl,CHRTBL2+(32*12+12)*8
		ld bc,19 + 12*256
		call ui_draw_frame

		; text "weapon configuration":
		ld c,TEXT_EQUIPSHIP_BANK
		ld a,TEXT_EQUIPSHIP_IDX
		ld de,CHRTBL2+(13)*8
		ld iyl,#f0
		call draw_text_from_bank_16

		; text "equipped":
		ld c,TEXT_EQUIPPED_BANK
		ld a,TEXT_EQUIPPED_IDX
		ld de,CHRTBL2+(1*32+6)*8
		ld iyl,COLOR_DARK_YELLOW*16
		ld b,5*8
		call draw_text_from_bank

		; text "UPGRADES":
		ld c,TEXT_UPGRADE_BANK
		ld a,TEXT_UPGRADE_IDX
		ld de,CHRTBL2+(12*32+25)*8
		ld iyl,COLOR_DARK_YELLOW*16
		ld b,5*8
		call draw_text_from_bank

		; text "credits":
		ld c,TEXT_MONEY_BANK
		ld a,TEXT_MONEY_IDX
		ld de,CHRTBL2+(32*2+13)*8
		ld iyl,#f0
		call draw_text_from_bank_16

		; # of credits:
		ld a,(global_state_credits)
		ld de,CHRTBL2+(32*2+18)*8
		ld iyl,#a0	; yellow
		call draw_text_number_of_credits

		; buttons:
		; back:
		ld hl,CHRTBL2+(32*1+26)*8
		ld bc,3*256+4*8
		ld a,COLOR_DARK_BLUE
		call draw_button
		ld c,TEXT_BACK_BANK
		ld a,TEXT_BACK_IDX
		ld de,CHRTBL2+(32*2+26)*8
		ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
		ld b,4*8
		call draw_text_from_bank

		; draw selected weapon list:
		ld hl,weapon_gfx_and_names+(WEAPON_SPEED*6)
		ld de,CHRTBL2+(32*2+2)*8
		call draw_weapon_gfx_narrow

		ld hl,weapon_gfx_and_names+(WEAPON_TRANSFER*6)
		ld de,CHRTBL2+(32*22+2)*8
		call draw_weapon_gfx_narrow

		xor a
		ld (ui_cursor_position),a
		inc a
		ld (ui_selected_weapon),a
		ld (ui_upgrade_scroll_position),a	; we cannot go to 0, as that is "NONE"
		inc a
		ld (ui_cursor_area),a

		ld a,#f0
		ld (ui_upgrade_scroll_position_last),a	; some position we cannot reach

		ld hl,ui_cursor_sprites
		ld de,ui_cursor_sprites+1
		ld (hl),0
		ld bc,4*4-1
		ldir

		; draw the "EQP" text for the EQP buttons (that will never change):
		ld de,CHRTBL2+(32*14+23)*8
		ld bc,TEXT_EQP_BANK + 2*8*256
		ld a,TEXT_EQP_IDX
		call draw_text_from_bank_reusing	
		ld de,CHRTBL2+(32*17+23)*8
		ld bc,TEXT_EQP_BANK + 2*8*256
		ld a,TEXT_EQP_IDX
		call draw_text_from_bank_reusing	
		ld de,CHRTBL2+(32*20+23)*8
		ld bc,TEXT_EQP_BANK + 2*8*256
		ld a,TEXT_EQP_IDX
		call draw_text_from_bank_reusing

		call state_weapons_draw_equipped_weapons
		call state_weapons_draw_selected_weapon_details
		call state_weapons_draw_upgrades

	call enable_VDP_output

	ld ix,decompress_weapons_song_from_page1
	call call_from_page1
    ld a,(isComputer50HzOr60Hz)
    add a,5	; 5 if 50Hz, 6 if 60Hz
    call PlayMusic


state_weapons_screen_loop:	
	halt
	; move the cursor:
    call update_keyboard_buffers_weapons_screen
    call state_weapons_move_cursor

	; draw the cursor:
	call state_weapons_draw_cursor
	ld hl,ui_cursor_sprites
	ld de,SPRATR2
	ld bc,16
	call fast_LDIRVM
    jr state_weapons_screen_loop

state_weapons_screen_loop_back:
	ld hl,SFX_ui_select
	call play_SFX_with_high_priority	
	call clearScreenLeftToRight
	jp state_mission_screen_from_upgrade


;-----------------------------------------------
state_weapons_wrong_sfx:
	ld hl,SFX_ui_wrong
	jp play_SFX_with_high_priority


;-----------------------------------------------
state_weapons_move_cursor:
	ld a,(keyboard_line_clicks)
	bit KEY_UP_BIT,a
	jp nz,state_weapons_move_cursor_up
	bit KEY_DOWN_BIT,a
	jp nz,state_weapons_move_cursor_down
	bit KEY_RIGHT_BIT,a
	jp nz,state_weapons_move_cursor_right
	bit KEY_LEFT_BIT,a
	jp nz,state_weapons_move_cursor_left
	bit KEY_BUTTON1_BIT,a
	jr nz,state_weapons_move_cursor_button1
	ld a,(keyboard_line_clicks+2)
	bit KEY_BUTTON2_BIT,a
	jr nz,state_weapons_move_cursor_button2
	bit KEY_BUTTON2_BIT_ALTERNATIVE,a
	jr nz,state_weapons_move_cursor_button2
	ret

state_weapons_move_cursor_button2:
	ld a,(ui_cursor_area)
	or a
	jr z,state_weapons_move_cursor_button2_not_in_back
	ld a,(ui_cursor_position)
	or a
	jr nz,state_weapons_move_cursor_button2_not_in_back
	jr state_weapons_screen_loop_back

state_weapons_move_cursor_button2_not_in_back:
	ld a,3
	ld (ui_cursor_area),a
	xor a
	ld (ui_cursor_position),a
	ret

state_weapons_move_cursor_button1:
	ld a,(ui_cursor_area)
	or a
	jr z,state_weapons_move_cursor_button1_area0
	dec a
	jr z,state_weapons_move_cursor_button1_area1
	dec a
	jr z,state_weapons_move_cursor_button1_area2
	dec a
	jp z,state_weapons_move_cursor_button1_area3
	ret

state_weapons_move_cursor_button1_area0:
	ld hl,SFX_ui_select
	call play_SFX_with_high_priority
	ld a,(ui_cursor_position)
	ld hl,global_state_weapon_configuration
	ADD_HL_A
	ld a,(hl)
	ld (ui_selected_weapon),a
	jp state_weapons_draw_selected_weapon_details


state_weapons_move_cursor_button1_area1:
	ld a,(ui_cursor_position)
	or a
	jr z,state_weapons_screen_loop_back

	dec a
	ld hl,ui_upgrade_scroll_position
	add a,(hl)
	ld (ui_selected_weapon),a

	ld hl,SFX_ui_select
	call play_SFX_with_high_priority

	jp state_weapons_draw_selected_weapon_details

state_weapons_move_cursor_button1_area2:
	ld a,(ui_cursor_position)
	or a
	jp z,state_weapons_screen_loop_back

	; - if we don't have the weapon, we cannot equip it
	; - if its slot number is #ff, we cannot equip it
	dec a
	ld hl,ui_upgrade_scroll_position
	add a,(hl)

	push af
		ld (ui_selected_weapon),a
		call state_weapons_draw_selected_weapon_details
	pop af
	ld ixl,a

	ld hl,global_state_weapon_upgrade_level
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	or a
	jp z,state_weapons_wrong_sfx 	; we don't have it

	; EQP button:
 	ld hl,weapon_slot_number-1
 	add hl,bc

	; equip:
	ld a,(hl)
	cp #ff
	jp z,state_weapons_wrong_sfx 	; not equipable

	ld hl,global_state_weapon_configuration
	ld c,a	; b is already 0
	add hl,bc
	ld a,ixl

	; check if it's alredy equipped:
	cp (hl)
	jr z,state_weapons_move_cursor_button1_area2_unequip
	ld (hl),a

state_weapons_move_cursor_button1_area2_continue:
	; update the left bar
	call state_weapons_draw_equipped_weapons
	; update te EQP button:
	ld a,#f0
	ld (ui_upgrade_scroll_position_last),a	; some position we cannot reach (to force full redraw)
	call state_weapons_draw_upgrades

	ld hl,SFX_ui_select
	jp play_SFX_with_high_priority

state_weapons_move_cursor_button1_area2_unequip:
	cp WEAPON_SPEED
	jr z,state_weapons_move_cursor_button1_area2_continue
	cp WEAPON_BULLET
	jr z,state_weapons_move_cursor_button1_area2_continue
	cp WEAPON_TRANSFER
	jr z,state_weapons_move_cursor_button1_area2_continue
	ld (hl),WEAPON_NONE
	jr state_weapons_move_cursor_button1_area2_continue

state_weapons_move_cursor_button1_area3:
	ld a,(ui_cursor_position)
	or a
	jp z,state_weapons_screen_loop_back

	; upgrade button:
	dec a
	ld hl,ui_upgrade_scroll_position
	add a,(hl)

	push af
		ld (ui_selected_weapon),a
		call state_weapons_draw_selected_weapon_details
	pop af

	ld hl,weapon_price-1
	ld b,0
	ld c,a
	add hl,bc
	ld a,(global_state_credits)
	cp (hl)
	jp c,state_weapons_wrong_sfx 	; not enough money

	ex de,hl	; save pointer to price
	ld ix,global_state_weapon_upgrade_level
	ld hl,weapon_max_buyable_upgrades-1
	add hl,bc
	add ix,bc
	ld a,(ix)
	cp (hl)
	jp z,state_weapons_wrong_sfx 	; already maximally upgraded

	; upgrade!
	inc (ix)
	ex de,hl
	ld de,global_state_credits
	ld a,(de)
	sub (hl)	; cost
	ld (de),a

	push af	
		; auto equip:
		ld a,(ui_cursor_position)
		dec a
		ld hl,ui_upgrade_scroll_position
		add a,(hl)
		ld ixl,a
		ld c,a
	  	ld hl,weapon_slot_number-1
	  	add hl,bc
	 	ld a,(hl)
	 	cp #ff
	 	jp z,state_weapons_move_cursor_button1_area3_not_equipable 	; not equipable
	 	ld hl,global_state_weapon_configuration
	 	ld c,a	; b is already 0
	 	add hl,bc
	 	ld a,ixl
	 	ld (hl),a

state_weapons_move_cursor_button1_area3_not_equipable:
	pop af
	; redraw:
	ld de,CHRTBL2+(32*2+18)*8
	ld iyl,#a0	; yellow
	call draw_text_number_of_credits
	call state_weapons_draw_equipped_weapons
	call state_weapons_draw_selected_weapon_details
	call state_weapons_draw_upgrades

	ld hl,SFX_ui_select
	jp play_SFX_with_high_priority

state_weapons_move_cursor_up:
	ld a,(ui_cursor_position)
	or a
	ret z
	cp 1
	jr nz,state_weapons_move_cursor_up_directly

	ld a,(ui_cursor_area)
	or a
	jr z,state_weapons_move_cursor_up_directly_reload_a
	ld a,(ui_upgrade_scroll_position)
	cp 1
	jr z,state_weapons_move_cursor_up_directly_reload_a
	dec a
	ld (ui_upgrade_scroll_position),a
	ld hl,SFX_ui_move
	call play_SFX_with_high_priority	
	jp state_weapons_draw_upgrades

state_weapons_move_cursor_up_directly_reload_a:
	ld a,(ui_cursor_position)
state_weapons_move_cursor_up_directly:
	dec a
	ld (ui_cursor_position),a

	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority

state_weapons_move_cursor_down:
	ld a,(ui_cursor_area)
	or a
	jr z,state_weapons_move_cursor_down_area0

	; areas 1/2/3 (either "back" or upgrades window)
	ld a,(ui_cursor_position)
	cp 3
	jr z,state_weapons_move_cursor_down_area1_2
	jr state_weapons_move_cursor_down_directly

state_weapons_move_cursor_down_area0:
	ld a,(ui_cursor_position)
	cp 7
	ret z

state_weapons_move_cursor_down_directly:
	inc a
	ld (ui_cursor_position),a

	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority

state_weapons_move_cursor_down_area1_2:
	ld a,(ui_upgrade_scroll_position)
	cp N_WEAPONS-3
	ret z
	inc a
	ld (ui_upgrade_scroll_position),a
	ld hl,SFX_ui_move
	call play_SFX_with_high_priority	
	jp state_weapons_draw_upgrades

state_weapons_move_cursor_right:
	ld a,(ui_cursor_area)
	cp 3
	ret z

	ld b,a
	ld a,(ui_cursor_position)
	or a
	ld a,b
	jr nz,state_weapons_move_cursor_right_continue
	ld a,2
state_weapons_move_cursor_right_continue:
	inc a
	ld (ui_cursor_area),a
	cp 1
	jr nz,state_weapons_move_cursor_right_continue4
	ld hl,ui_cursor_position
	ld a,(hl)
	or a
	jr z,state_weapons_move_cursor_right_continue4
	sub 3
	jp p,state_weapons_move_cursor_right_continue2
	ld a,3
	ld (ui_cursor_area),a
	xor a
state_weapons_move_cursor_right_continue2:
	cp 4
	jr c,state_weapons_move_cursor_right_continue3
	ld a,3
state_weapons_move_cursor_right_continue3:
	ld (hl),a

state_weapons_move_cursor_right_continue4:
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority

state_weapons_move_cursor_left:
	ld hl,ui_cursor_area
	ld a,(hl)
	or a
	ret z

	ld a,(ui_cursor_position)
	or a
	jr z,state_weapons_move_cursor_left_button

	dec (hl)
	ld a,(hl)
	or a
	jr nz,state_weapons_move_cursor_left_continue

state_weapons_move_cursor_left_continue2:
	ld hl,ui_cursor_position
	ld a,(hl)
	or a
	jr z,state_weapons_move_cursor_left_continue
	add a,3
	ld (ui_cursor_position),a	

state_weapons_move_cursor_left_continue:
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority

state_weapons_move_cursor_left_button:
	ld (hl),0
	jr state_weapons_move_cursor_left_continue2


;-----------------------------------------------
state_weapons_draw_cursor:
	; cursor:
	ld e,COLOR_DARK_YELLOW
	ld hl,ui_cursor_sprites

	ld a,(interrupt_cycle)
	bit 3,a
	jr z,state_weapons_draw_cursor_show
	; blink:
	xor a
	ld (ui_cursor_sprites+3),a
	ld (ui_cursor_sprites+4+3),a
	ret
state_weapons_draw_cursor_show:
	ld a,(ui_cursor_area)
	or a
	jr z,state_weapons_draw_cursor_area0
	dec a
	jr z,state_weapons_draw_cursor_area1
	dec a
	jr z,state_weapons_draw_cursor_area2
state_weapons_draw_cursor_area3:
	ld bc,12*256 + 206
	ld a,(ui_cursor_position)
	or a
	jr z,state_weapons_draw_cursor_32w
	ld b,a
	ld a,88
state_weapons_draw_cursor_area3_loop:
	add a,24
	djnz state_weapons_draw_cursor_area3_loop
	ld b,a
	jr state_weapons_draw_cursor_32w
	
state_weapons_draw_cursor_area2:
	ld a,(ui_cursor_position)
	or a
	jr z,state_weapons_draw_cursor_area3	; dispatch to "back" button
	ld c,182
	ld b,a
	ld a,88
state_weapons_draw_cursor_area2_loop:
	add a,24
	djnz state_weapons_draw_cursor_area2_loop
	ld b,a
	jr state_weapons_draw_cursor_16w

state_weapons_draw_cursor_area1:
	ld a,(ui_cursor_position)
	or a
	jr z,state_weapons_draw_cursor_area3	; dispatch to "back" button
	ld c,102
	ld b,a
	ld a,88
	jr state_weapons_draw_cursor_area2_loop


state_weapons_draw_cursor_area0:
	; currently equipped weapons:
	ld a,(ui_cursor_position)
state_weapons_draw_cursor_area0_a_set:
	ld c,14
	or a
	jr z,state_weapons_draw_cursor_area0_speed
	cp 7
	jr z,state_weapons_draw_cursor_area0_transfer
	dec a
	ld d,a
	ld a,4
	add a,d
	add a,d
	add a,d
	add a,a
	add a,a
	add a,a 	; y tile coordinate
	ld b,a
	jr state_weapons_draw_cursor_16w

state_weapons_draw_cursor_area0_speed:
	ld b,12
	jr state_weapons_draw_cursor_16w

state_weapons_draw_cursor_area0_transfer:
	ld b,172
	;jr state_weapons_draw_cursor_16w

state_weapons_draw_cursor_16w:
	dec b
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),0
	inc hl
	ld (hl),e
	inc hl

	ld (hl),b
	inc hl
	ld a,c
	add a,4
	ld (hl),a
	inc hl
	ld (hl),4
	inc hl
	ld (hl),e
	ret


state_weapons_draw_cursor_32w:
	dec b
	ld hl,ui_cursor_sprites
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),0
	inc hl
	ld (hl),COLOR_DARK_YELLOW
	inc hl

	ld (hl),b
	inc hl
	ld a,c
	add a,20
	ld (hl),a
	inc hl
	ld (hl),4
	inc hl
	ld (hl),COLOR_DARK_YELLOW
	ret


;-----------------------------------------------
state_weapons_draw_upgrades:
	; out (#2c),a

	ld a,(ui_upgrade_scroll_position)
	push af
		dec a
		jr z,state_weapons_draw_upgrades_no_up_arrow
		ld a,12
		ld de,CHRTBL2+(13*32+13)*8
		call draw_tile_bitmap_mode_by_index
		ld a,13
		ld de,CHRTBL2+(13*32+14)*8
		call draw_tile_bitmap_mode_by_index
		jr state_weapons_draw_upgrades_done_with_up_arrow
state_weapons_draw_upgrades_no_up_arrow:
		xor a
		ld hl,CLRTBL2+(13*32+13)*8
		ld bc,16
		call fast_FILVRM
state_weapons_draw_upgrades_done_with_up_arrow:
	pop af

	push af
		cp N_WEAPONS-3
		jr z,state_weapons_draw_upgrades_no_down_arrow
		ld a,14
		ld de,CHRTBL2+(22*32+13)*8
		call draw_tile_bitmap_mode_by_index
		ld a,15
		ld de,CHRTBL2+(22*32+14)*8
		call draw_tile_bitmap_mode_by_index
		jr state_weapons_draw_upgrades_done_with_down_arrow
state_weapons_draw_upgrades_no_down_arrow:
		xor a
		ld hl,CLRTBL2+(22*32+13)*8
		ld bc,16
		call fast_FILVRM
state_weapons_draw_upgrades_done_with_down_arrow:
	pop af

	ld hl,ui_upgrade_scroll_position_last
	ld b,(hl)
	ld (hl),a	; store the last scroll position we have drawn
	dec b
	cp b
	jr z,state_weapons_draw_upgrades_scroll_down
	inc b
	inc b
	cp b
	jr z,state_weapons_draw_upgrades_scroll_up

	ld de,CHRTBL2+(14*32+13)*8
	ld b,3
state_weapons_draw_upgrades_loop:
	push bc
	push af
 		push de
 			call state_weapons_draw_one_upgrade
		pop hl
		ld bc,32*3*8
		add hl,bc
		ex de,hl
	pop af
	pop bc
	inc a
	djnz state_weapons_draw_upgrades_loop
	; out (#2d),a	
	ret

state_weapons_draw_upgrades_scroll_down:
	; copy the first 2 positions down, and only redraw the top position
	push af
		; copy the last 2 positions up, and only redraw the bottom position
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8*2
		ld bc,17*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8*2 + 32*8
		ld bc,17*8
		call ui_copy_VDP_to_VDP

		ld hl,CHRTBL2+(14*32+13)*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8
		ld bc,17*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8 + 32*8
		ld bc,17*8
		call ui_copy_VDP_to_VDP
	pop af

	ld de,CHRTBL2+(14*32+13)*8
	call state_weapons_draw_one_upgrade
	out (#2d),a	
	ret

state_weapons_draw_upgrades_scroll_up:
	push af
		; copy the last 2 positions up, and only redraw the bottom position
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8
		ld de,CHRTBL2+(14*32+13)*8
		ld bc,8*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8 + 8*8
		ld de,CHRTBL2+(14*32+13)*8 + 8*8
		ld bc,9*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*8
		ld bc,8*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8 + 8*8 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 8*8 + 32*8
		ld bc,9*8
		call ui_copy_VDP_to_VDP

		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8*2
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8
		ld bc,8*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8*2 + 8*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8 + 8*8
		ld bc,9*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8*2 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8 + 32*8
		ld bc,8*8
		call ui_copy_VDP_to_VDP
		ld hl,CHRTBL2+(14*32+13)*8 + 32*3*8*2 + 8*8 + 32*8
		ld de,CHRTBL2+(14*32+13)*8 + 32*3*8 + 8*8 + 32*8
		ld bc,9*8
		call ui_copy_VDP_to_VDP
	pop af

	ld de,CHRTBL2+(14*32+13)*8 + 32*3*8*2
	add a,2
	call state_weapons_draw_one_upgrade
	out (#2d),a	
	ret


ui_copy_VDP_to_VDP:
	push bc
		push hl
			push de
				push de
				push bc
					ld de,text_draw_buffer
					call fast_LDIRMV
				pop bc
				pop de
				ld hl,text_draw_buffer
				call fast_LDIRVM
			pop hl
			ld bc,CLRTBL2-CHRTBL2
			add hl,bc
			ex de,hl
		pop hl
; 		ld bc,CLRTBL2-CHRTBL2
		add hl,bc
	pop bc
	push de
	push bc
		ld de,text_draw_buffer
		call fast_LDIRMV
	pop bc
	pop de
	ld hl,text_draw_buffer
	jp fast_LDIRVM


;-----------------------------------------------
; input:
; - a: scroll position
; - de: ptr to draw
state_weapons_draw_one_upgrade:
	ld hl,global_state_weapon_upgrade_level
	ld b,0
	ld c,a
	add hl,bc
	ld c,(hl)
	ld ixl,c	; level
	ld ixh,a	; weapon idx
	push de
	push ix
		add a,a
		ld c,a
		add a,a
		add a,c
		ld hl,weapon_gfx_and_names
		ld c,a
		add hl,bc
		call draw_weapon_gfx
	pop ix
	pop hl
	push hl
	push ix
		ld bc,(32+5)*8
		add hl,bc
		ex de,hl
		ld a,ixl

		; weapon level:
		cp #ff
		call nz,draw_weapon_level
	pop ix
	pop de	; we save the potr to draw in de

	; draw buttons:
	; EQP:
	; - if we don't have the weapon, we cannot equip it
	ld a,ixh	; ixh = weapon idx
	ld hl,weapon_slot_number-1
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	inc a
	jr z,state_weapons_draw_one_upgrade_not_equipable	; not equipable

	push hl
		ld hl,global_state_weapon_upgrade_level
		add hl,bc
		ld a,(hl)
		or a
	pop hl
	jr z,state_weapons_draw_one_upgrade_red_equip	; we don't have it

	; if we have it equipped, show it green color:
	ld c,(hl)	; we recover the slot again
	ld hl,global_state_weapon_configuration
	add hl,bc
	ld a,(hl)
	cp ixh
	jr z,state_weapons_draw_one_upgrade_already_equipped

	ld a,COLOR_DARK_BLUE + COLOR_WHITE*16
	jr state_weapons_draw_one_upgrade_equip_color_set
state_weapons_draw_one_upgrade_already_equipped:
	ld a,COLOR_DARK_GREEN + COLOR_WHITE*16
	jr state_weapons_draw_one_upgrade_equip_color_set
state_weapons_draw_one_upgrade_not_equipable:
	ld a,COLOR_BLACK + COLOR_BLACK*16
	jr state_weapons_draw_one_upgrade_equip_color_set
state_weapons_draw_one_upgrade_red_equip:
	ld a,COLOR_DARK_RED + COLOR_WHITE*16
state_weapons_draw_one_upgrade_equip_color_set:
	push de
		ex de,hl	; we restore the ptr to draw in hl
		ld bc,10*8
		add hl,bc
		ld bc,2*256+2*8
		call change_button_color
	pop de

	; UPGRADE:
	; can this weapon be upgraded? we have enough money, and it's not maxed out
	ld a,ixh
	ld hl,weapon_max_buyable_upgrades-1
	ld b,0
	ld c,a
	add hl,bc
	ld a,ixl
	cp (hl)
	jr z,state_weapons_draw_one_upgrade_maxed_out

	ld hl,weapon_price-1
	add hl,bc
	ld a,(global_state_credits)
	cp (hl)
	ld a,(hl)
	ld ixh,a	; we now store the cost in ixh
	jr c,state_weapons_draw_one_upgrade_no_upgrade

	ld a,COLOR_DARK_BLUE
	ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
	jr state_weapons_draw_one_upgrade_upgrade_color_set
state_weapons_draw_one_upgrade_maxed_out:
	ld a,COLOR_DARK_RED
	ld iyl,COLOR_DARK_RED + COLOR_WHITE*16
	ex de,hl	; we restore the ptr to draw in hl
	ld bc,13*8
	add hl,bc
	push hl
		ld bc,2*256+4*8
		call draw_button
	pop de
	push de
		ld bc,TEXT_MAX_BANK + 4*8*256
		ld a,TEXT_MAX_IDX
		call draw_text_from_bank_reusing 		
	pop hl
	ret

state_weapons_draw_one_upgrade_no_upgrade:
	ld a,COLOR_DARK_RED
	ld iyl,COLOR_DARK_RED + COLOR_WHITE*16
state_weapons_draw_one_upgrade_upgrade_color_set:

	ex de,hl	; we restore the ptr to draw in hl
	ld bc,13*8
	add hl,bc
	push hl
		ld bc,2*256+4*8
		call draw_button
	pop de
	push ix
	push de
		ld bc,TEXT_UPGRD_BANK + 4*8*256
		ld a,TEXT_UPGRD_IDX
		call draw_text_from_bank_reusing 		
	pop hl
	pop ix

	; draw cost:
	ld bc,(32+1)*8
	add hl,bc
	ex de,hl
	ld a,ixh	; weapon cost
	jp draw_weapon_cost


;-----------------------------------------------
state_weapons_draw_selected_weapon_details:
	ld bc,6*256+17
	ld hl,CLRTBL2+(5*32+13)*8
	call clear_rectangle_bitmap_mode

	ld a,(ui_selected_weapon)
	or a
	ret z

	push af
		add a,a
		ld c,a
		add a,a
		add a,c
		ld hl,weapon_gfx_and_names
		ld b,0
		ld c,a
		add hl,bc
		ld de,CHRTBL2+(5*32+13)*8
		call draw_weapon_gfx
	pop af	; a = selected weapon

	push af
		; weapon level:
		ld hl,global_state_weapon_upgrade_level
		ADD_HL_A
		ld a,(hl)
		ld de,CHRTBL2+(5*32+27)*8
		cp #ff
		call nz,draw_weapon_level
	pop af

	; weapon detailed description:
	ld hl,weapon_detailed_descritions
	ld de,CHRTBL2+(7*32+13)*8
	ld iyl,COLOR_WHITE*16
	dec a	
	add a,a
	add a,a
	add a,a
	ADD_HL_A

	ld b,4

state_weapons_draw_selected_weapon_details_text_loop:
	push bc
	push hl
		push de
			ld c,(hl)
			inc hl
			ld a,(hl)
			cp #ff
			ld b,17*8
			call nz,draw_text_from_bank_reusing
		pop hl
		ld bc,32*8
		add hl,bc
		ex de,hl
	pop hl
	inc hl
	inc hl
	pop bc
	djnz state_weapons_draw_selected_weapon_details_text_loop
	ret


;-----------------------------------------------
state_weapons_draw_equipped_weapons:
	ld hl,global_state_weapon_configuration+1
	ld de,CHRTBL2+(32*4+2)*8
	ld b,6
state_weapons_draw_equipped_weapons_loop:
	push bc
	push hl
		push de
			ld a,(hl)
			ld hl,global_state_weapon_upgrade_level
			ld b,0
			ld c,a
			add hl,bc
			ld c,(hl)
			ld ixl,c
			push de
			push ix
				add a,a
				ld c,a
				add a,a
				add a,c
				ld hl,weapon_gfx_and_names
				ld c,a
				add hl,bc
				call draw_weapon_gfx
			pop ix
			pop hl
			ld bc,(32+5)*8
			add hl,bc
			ex de,hl
			ld a,ixl
			; weapon level:
			cp #ff
			jr z,state_weapons_draw_equipped_weapons_clear_weapon_level
			call draw_weapon_level
state_weapons_draw_equipped_weapons_clear_weapon_level_continue:
		pop hl
		ld bc,32*3*8
		add hl,bc
		ex de,hl
	pop hl
	inc hl
	pop bc
	djnz state_weapons_draw_equipped_weapons_loop
	ret
state_weapons_draw_equipped_weapons_clear_weapon_level:
	push de
		call clear_text_rendering_buffer
	pop de
	ld bc,3*8
	push de
		call render_text_draw_buffer
	pop de
	jr state_weapons_draw_equipped_weapons_clear_weapon_level_continue


;-----------------------------------------------
; - hl: ptr to where to draw
; - c: width in bytes (8 bytes for 1 tile)
; - b height in tiles
; - a: color (attribute byte)
draw_button:
	push bc
	push af
		ld b,0
		push hl
			push hl
			push af
			push bc
				xor a
				call fast_FILVRM
			pop bc
			pop af
			pop hl
			ld de,CLRTBL2-CHRTBL2
			add hl,de
			call fast_FILVRM
		pop hl
		ld bc,32*8
		add hl,bc
	pop af
	pop bc
	djnz draw_button
	ret


change_button_color:
	push bc
	push af
		ld b,0
		push hl
			ld de,CLRTBL2-CHRTBL2
			add hl,de
			call fast_FILVRM
		pop hl
		ld bc,32*8
		add hl,bc
	pop af
	pop bc
	djnz change_button_color
	ret


;-----------------------------------------------
; a: level
; de: ptr to draw
; iyl: attribute
draw_weapon_level:
	push de
		push af
			call clear_text_rendering_buffer
		pop af

		ld hl,text_buffer
		ld (hl),5	; string is "LVL N"
		inc hl
		ld (hl),70	; "L"
		inc hl
		ld (hl),98	; "V"
		inc hl
		ld (hl),70	; "L"
		inc hl
		ld (hl),0	; " "
		inc hl
		push hl
			ld hl,digit_indexes
			ADD_HL_A
			ld a,(hl)
		pop hl
		ld (hl),a
	pop de
	; - hl: sentence to draw (first byte is the length)
	; - de: target VRAM address
	; - iyl: color (attribute byte)
	; - bc: expected length in bytes
	ld hl,text_buffer
	ld bc,3*8
	jp draw_sentence	


;-----------------------------------------------
; a: cost
; de: ptr to draw
; iyl: attribute
draw_weapon_cost:	
	push de
		push af
			call clear_text_rendering_buffer
		pop af

		ld hl,text_buffer
		ld (hl),2	; string is "$N"
		inc hl
		ld (hl),3	; "$"
		inc hl
		push hl
			ld hl,digit_indexes
			ADD_HL_A
			ld a,(hl)
		pop hl
		ld (hl),a
	pop de
	; - hl: sentence to draw (first byte is the length)
	; - de: target VRAM address
	; - iyl: color (attribute byte)
	; - bc: expected length in bytes
	ld hl,text_buffer
	ld bc,2*8
	jp draw_sentence	


;-----------------------------------------------
ui_draw_frame:
	ld a,c
	ld (frame_width),a
	ld a,b
	ld (frame_height),a

ui_draw_frame_y_loop:
	push bc
		push hl
			ld a,(frame_width)
ui_draw_frame_x_loop:
			push af
				push af
					; draw tiles:
					ld a,(frame_height)
					cp b
					jr z,ui_draw_frame_x_loop_first_row
					ld a,b
					dec a
					jr z,ui_draw_frame_x_loop_last_row


ui_draw_frame_x_loop_middle_rows:
				pop af
				; if a == 1 || c: draw tile 5
				cp c
				call z,ui_draw_frame_draw_tile5
				cp 1
				call z,ui_draw_frame_draw_tile5
				jr ui_draw_frame_x_loop_continue


ui_draw_frame_x_loop_last_row:
				pop af
				; if b == 1 && a == c: draw tile 3
				; if b == 1 && a == 1: draw tile 4
				; if b == 1 && a == anything else: draw tile 1
				cp c
				jr nz,ui_draw_frame_x_loop_last_row_notc
				call ui_draw_frame_draw_tile3
				jr ui_draw_frame_x_loop_continue
ui_draw_frame_x_loop_last_row_notc:
				cp 1
				jr nz,ui_draw_frame_x_loop_last_row_not1
				call ui_draw_frame_draw_tile4
				jr ui_draw_frame_x_loop_continue
ui_draw_frame_x_loop_last_row_not1:
				call ui_draw_frame_draw_tile1
				jr ui_draw_frame_x_loop_continue


ui_draw_frame_x_loop_first_row:
				pop af
				; if b == ? && a == c: draw tile 0
				; if b == ? && a == 1: draw tile 2
				; if b == ? && a == anything else: draw tile 1
				cp c
				jr nz,ui_draw_frame_x_loop_first_row_notc
				call ui_draw_frame_draw_tile0
				jr ui_draw_frame_x_loop_continue
ui_draw_frame_x_loop_first_row_notc:
				cp 1
				jr nz,ui_draw_frame_x_loop_first_row_not1
				call ui_draw_frame_draw_tile2
				jr ui_draw_frame_x_loop_continue
ui_draw_frame_x_loop_first_row_not1:
				call ui_draw_frame_draw_tile1


ui_draw_frame_x_loop_continue:

				push bc
					ld bc,8
					add hl,bc	
				pop bc
			pop af
			dec a
			jr nz,ui_draw_frame_x_loop

		pop hl
		push bc
			ld bc,32*8
			add hl,bc	
		pop bc
	pop bc
	djnz ui_draw_frame_y_loop
	ret

ui_draw_frame_draw_tile5:
	ld de,buffer+5*16
	jr ui_draw_frame_draw_tile

ui_draw_frame_draw_tile4:
	ld de,buffer+4*16
	jr ui_draw_frame_draw_tile

ui_draw_frame_draw_tile3:
	ld de,buffer+3*16
	jr ui_draw_frame_draw_tile

ui_draw_frame_draw_tile2:
	ld de,buffer+2*16
	jr ui_draw_frame_draw_tile

ui_draw_frame_draw_tile1:
	ld de,buffer+1*16
	jr ui_draw_frame_draw_tile

ui_draw_frame_draw_tile0:
	ld de,buffer
ui_draw_frame_draw_tile:
	push hl
	push bc
		ex de,hl
		call draw_tile_bitmap_mode
	pop bc
	pop hl
	ret


;-----------------------------------------------
; hl: weapon data (gfx, text)
; de: ptr to draw
draw_weapon_gfx_narrow:
	; weapon gfx:
	push hl
		push de
			call draw_weapon_gfx_row
		pop hl
		ld bc,3*8
		add hl,bc
		ex de,hl
	pop hl
	ld c,4
	add hl,bc

	; weapon name:
	ld c,(hl)
	inc hl
	ld a,(hl)
	cp #ff	; if there is no text
	jr z,draw_weapon_gfx_narrow_clear_text
	ld iyl,COLOR_WHITE*16
	ld b,6*8
	jp draw_text_from_bank_reusing
draw_weapon_gfx_narrow_clear_text:
    push de
		call clear_text_rendering_buffer
	pop de
	ld bc,6*8
	jp render_text_draw_buffer

; a: level
draw_weapon_gfx:
	push hl
		push de
			call draw_weapon_gfx_narrow
		pop hl
		ld bc,32*8
		add hl,bc
		ex de,hl
	pop hl
	inc hl
	inc hl
; 	jp draw_weapon_gfx_row

draw_weapon_gfx_row:
	ld a,(hl)
	push hl
		push de
			call draw_tile_bitmap_mode_by_index
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop hl
	inc hl
	ld a,(hl)
	jp draw_tile_bitmap_mode_by_index
