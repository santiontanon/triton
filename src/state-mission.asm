general_sprites:
	db 17*8-1,27,8,COLOR_RED
	db 17*8,31,12,COLOR_LIGHT_RED

mission_cutscene_0_text:	; when a mission fails
	db TEXT_M_CUTSCENE_0_1_BANK, #f0, TEXT_M_CUTSCENE_0_1_IDX
	db TEXT_M_CUTSCENE_0_2_BANK, #f0, TEXT_M_CUTSCENE_0_2_IDX
	db TEXT_M_CUTSCENE_0_3_BANK, #f0, TEXT_M_CUTSCENE_0_3_IDX
	db #ff  ; end of text

mission_cutscene_1_text:
	db TEXT_M_CUTSCENE_1_1_BANK, #f0, TEXT_M_CUTSCENE_1_1_IDX
	db TEXT_M_CUTSCENE_1_2_BANK, #f0, TEXT_M_CUTSCENE_1_2_IDX
	db TEXT_M_CUTSCENE_1_3_BANK, #f0, TEXT_M_CUTSCENE_1_3_IDX
	db TEXT_M_CUTSCENE_1_4_BANK, #f0, TEXT_M_CUTSCENE_1_4_IDX
	db TEXT_M_CUTSCENE_1_5_BANK, #f0, TEXT_M_CUTSCENE_1_5_IDX
	db #ff  ; end of text

mission_cutscene_2_text:
	db TEXT_M_CUTSCENE_2_1_BANK, #f0, TEXT_M_CUTSCENE_2_1_IDX
	db TEXT_M_CUTSCENE_2_2_BANK, #f0, TEXT_M_CUTSCENE_2_2_IDX
	db TEXT_M_CUTSCENE_2_3_BANK, #f0, TEXT_M_CUTSCENE_2_3_IDX
	db #ff  ; end of text

mission_cutscene_3_text:
	db TEXT_M_CUTSCENE_3_1_BANK, #f0, TEXT_M_CUTSCENE_3_1_IDX
	db TEXT_M_CUTSCENE_3_2_BANK, #f0, TEXT_M_CUTSCENE_3_2_IDX
	db TEXT_M_CUTSCENE_3_3_BANK, #f0, TEXT_M_CUTSCENE_3_3_IDX
	db #ff  ; end of text

mission_cutscene_4_text:
	db TEXT_M_CUTSCENE_4_1_BANK, #f0, TEXT_M_CUTSCENE_4_1_IDX
	db TEXT_M_CUTSCENE_4_2_BANK, #f0, TEXT_M_CUTSCENE_4_2_IDX
	db TEXT_M_CUTSCENE_4_3_BANK, #f0, TEXT_M_CUTSCENE_4_3_IDX
	db TEXT_M_CUTSCENE_4_4_BANK, #f0, TEXT_M_CUTSCENE_4_4_IDX
	db TEXT_M_CUTSCENE_4_5_BANK, #f0, TEXT_M_CUTSCENE_4_5_IDX
	db #ff  ; end of text

mission_cutscene_5_text:
	db TEXT_M_CUTSCENE_5_1_BANK, #f0, TEXT_M_CUTSCENE_5_1_IDX
	db TEXT_M_CUTSCENE_5_2_BANK, #f0, TEXT_M_CUTSCENE_5_2_IDX
	db TEXT_M_CUTSCENE_5_3_BANK, #f0, TEXT_M_CUTSCENE_5_3_IDX
	db #ff  ; end of text

mission_cutscene_6_text:
	db TEXT_M_CUTSCENE_6_1_BANK, #f0, TEXT_M_CUTSCENE_6_1_IDX
	db TEXT_M_CUTSCENE_6_2_BANK, #f0, TEXT_M_CUTSCENE_6_2_IDX
	db TEXT_M_CUTSCENE_6_3_BANK, #f0, TEXT_M_CUTSCENE_6_3_IDX
	db TEXT_M_CUTSCENE_6_4_BANK, #f0, TEXT_M_CUTSCENE_6_4_IDX
	db #ff  ; end of text

mission_cutscene_7_text:
	db TEXT_M_CUTSCENE_7_1_BANK, #f0, TEXT_M_CUTSCENE_7_1_IDX
	db TEXT_M_CUTSCENE_7_2_BANK, #f0, TEXT_M_CUTSCENE_7_2_IDX
	db TEXT_M_CUTSCENE_7_3_BANK, #f0, TEXT_M_CUTSCENE_7_3_IDX
	db TEXT_M_CUTSCENE_7_4_BANK, #f0, TEXT_M_CUTSCENE_7_4_IDX
	db #ff  ; end of text


;-----------------------------------------------
play_mission_song:
	call StopMusic
; 	ld ix,decompress_mission_song_from_page1
; 	call call_from_page1
	ld hl,mission_song_pletter
	ld de,music_buffer
	call unpack_compressed
    ld a,(isComputer50HzOr60Hz)
    add a,5	; 6 if 50Hz, 7 if 60Hz
    jp PlayMusic


;-----------------------------------------------
state_mission_screen_new_game:	
	ld ix,decompress_weapon_data_from_page1
	call call_from_page1

	ld a,INITIAL_CREDITS
	ld (global_state_credits),a	; initial credits
	xor a
	ld (global_state_levels_completed),a
	ld (global_state_bosses_defeated),a

	ld hl,weapon_configuration_default_ROM
	ld de,global_state_weapon_configuration
	ld bc,8
	ldir

	ld hl,global_state_weapon_upgrade_level
	ld de,global_state_weapon_upgrade_level+1
	ld (hl),0
	ld bc,N_WEAPONS-1
	ldir
	ld a,#ff
	ld hl,global_state_weapon_upgrade_level
	ld (hl),a	; mark the "NONE" weapon as special	
	inc hl
	ld a,1
	ld (hl),a	; we start with "WEAPON_SPEED" level 1
	inc hl
	inc hl
	ld (hl),a	; we start with "WEAPON_TRANSFER" level 1
	inc hl
	ld (hl),a	; we start with "WEAPON_BULLET" level 1
	ld hl,global_state_weapon_upgrade_level+WEAPON_PILOTS
	ld (hl),INITIAL_NUMBER_OF_LIVES

	call generate_minimap	

	call play_mission_song

	call state_mission_screen_cutscene_game_start

	; start in ITHAKI:
	xor a
	ld (ui_cursor_position),a
	ld a,4
	ld (ui_cursor_area),a


;-----------------------------------------------
state_mission_screen:
	ld sp,#F380	; we might come here from within some function for convenience, so, just reset stack

	; draw the text:
	ld c,TEXT_MISSION_INSTRUCTIONS_BANK
	ld a,TEXT_MISSION_INSTRUCTIONS_IDX
	ld de,CHRTBL2+(16*32+1)*8
	ld iyl,COLOR_WHITE*16
	ld b,30*8
	call draw_text_from_bank

	; button "upgrade":
	ld hl,CHRTBL2+(32*18+8)*8
	ld bc,3*256+7*8
	ld a,COLOR_DARK_BLUE
	call draw_button
	ld c,TEXT_UPGRADE_BANK
	ld a,TEXT_UPGRADE_IDX
	ld de,CHRTBL2+(32*19+9)*8-1
	ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
	ld b,6*8
	call draw_text_from_bank	

	; button "quit":
	ld hl,CHRTBL2+(32*18+18)*8
	ld bc,3*256+6*8
	ld a,COLOR_DARK_BLUE
	call draw_button
	ld c,TEXT_QUIT_BANK
	ld a,TEXT_QUIT_IDX
	ld de,CHRTBL2+(32*19+20)*8-1
	ld iyl,COLOR_DARK_BLUE + COLOR_WHITE*16
	ld b,4*8
	call draw_text_from_bank	


state_mission_screen_loop:
	halt

	; move the cursor:
    call update_keyboard_buffers
    call state_mission_move_cursor

    ld a,(global_state_bosses_defeated)
    or a
    jr z,state_mission_screen_loop_skip_boss_draw

    ; draw the bosses:
    ld bc,12
    ld a,(global_state_boss2_position)
    call draw_boss_position

    ; draw the bosses:
    ld bc,18
    ld a,(global_state_boss3_position)
    call draw_boss_position
state_mission_screen_loop_skip_boss_draw:

	; draw the cursor:
	call state_mission_draw_cursor
	ld hl,ui_cursor_sprites
	ld de,SPRATR2
	ld bc,8
	call fast_LDIRVM
    jr state_mission_screen_loop

	jp state_weapons_screen


;-----------------------------------------------
draw_boss_position: ; this function assumes CHRTBL2 == 0
	push af
		ld hl,global_state_minimap
		add hl,bc
		ld de,MINIMAP_WIDTH
		or a
		jr z,draw_boss_position_planet_loop_done
draw_boss_position_planet_loop:
		add hl,de
		dec a
		jr nz,draw_boss_position_planet_loop
draw_boss_position_planet_loop_done:
		ld a,(hl)
		ld e,a
		cp 89
		jr nc,draw_boss_position_no_boss

		ld a,(interrupt_cycle)
		bit 4,a
		jr z, draw_boss_position_skull

draw_boss_position_no_boss:
	pop af
	jr draw_boss_position_continue

draw_boss_position_skull:
	pop af
    ld e,127
draw_boss_position_continue:	
	; draw the skull:
	add a,3
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,bc
	ld bc,3
	add hl,bc

	add hl,hl
	add hl,hl
	add hl,hl
    ex de,hl
    ld a,l	; what was "e" before
    jp draw_tile_bitmap_mode_by_index


;-----------------------------------------------
state_mission_screen_from_game_failed:
	call setup_mission_screen_frames
	call play_mission_song
	; debug (to jump directly to the ending):
	; jp state_mission_screen_cutscene_boss4
	jp state_mission_screen_cutscene_mission_failed


;-----------------------------------------------
state_mission_screen_from_game_complete:
	; mark the level as complete:
	ld hl,global_state_selected_level
	ld de,ui_cursor_area
	ldi
	ldi
	call get_minimap_pointer
	ld a,(hl)
	add a,4
	ld (hl),a

	; mark new paths as green:
	call enable_nearby_minimap_paths

	call setup_mission_screen_frames

	call play_mission_song

	; trigger any necessary cutscenes:
	ld hl,global_state_levels_completed
	inc (hl)
	ld a,(hl)
	dec a
	jp z,state_mission_screen_cutscene_level1
	dec a
	jp z,state_mission_screen_cutscene_level2

	; if we just defeated a boss, show the cut scene:
	ld a,(global_state_selected_level_boss)
	or a
	jp z,state_mission_screen
	ld a,(global_state_bosses_defeated)
	dec a
	jp z,state_mission_screen_cutscene_boss1
	dec a
	jp z,state_mission_screen_cutscene_boss2
	dec a
	jp z,state_mission_screen_cutscene_boss3
	dec a
	jp z,state_mission_screen_cutscene_boss4

	jp state_mission_screen


state_mission_screen_from_upgrade:
	call setup_mission_screen_frames

	call play_mission_song

	; start in UPGRADE:
	xor a
	ld (ui_cursor_position),a
	ld a,5
	ld (ui_cursor_area),a

	jp state_mission_screen


;-----------------------------------------------
setup_mission_screen_frames:
	call setup_ui_gfx

	ld hl,CHRTBL2+(0+0)*8
	ld bc,32 + 14*256
	call ui_draw_frame

	ld hl,CHRTBL2+(14*32+0)*8
	ld bc,32 + 10*256
	call ui_draw_frame

	jp draw_minimap


;-----------------------------------------------
setup_ui_gfx:
	call set_bitmap_mode

	ld hl,ui_sprites_plt
	ld de,buffer
	call unpack_compressed
	ld hl,buffer
	ld de,SPRTBL2
	ld bc,6*32
	call fast_LDIRVM

	ld hl,ui_tiles_plt
	ld de,buffer
	jp unpack_compressed


;-----------------------------------------------
state_mission_move_cursor:
	ld a,(keyboard_line_clicks)
	bit KEY_UP_BIT,a
	jp nz,state_mission_move_cursor_up
	bit KEY_DOWN_BIT,a
	jp nz,state_mission_move_cursor_down
	bit KEY_RIGHT_BIT,a
	jp nz,state_mission_move_cursor_right
	bit KEY_LEFT_BIT,a
	jp nz,state_mission_move_cursor_left
	bit KEY_BUTTON1_BIT,a
	jr nz,state_mission_move_cursor_button1
	ret

state_mission_move_cursor_up:
	ld hl,ui_cursor_area
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	

state_mission_move_cursor_down:
	ld hl,ui_cursor_area
	ld a,(hl)
	cp 5
	ret z
	inc (hl)
	jr state_mission_move_cursor_sfx

state_mission_move_cursor_left:
	ld hl,ui_cursor_position
	ld a,(ui_cursor_area)
	cp 5
	jr z,state_mission_move_cursor_left_buttons
	ld a,(hl)
	or a
	ret z
	dec (hl)
state_mission_move_cursor_sfx:
	ld hl,SFX_ui_move
	jp play_SFX_with_high_priority	

state_mission_move_cursor_left_buttons:
	ld a,(hl)
	cp 7
	ret c
	ld (hl),4
	jr state_mission_move_cursor_sfx

state_mission_move_cursor_right:
	ld hl,ui_cursor_position
	ld a,(ui_cursor_area)
	cp 5
	jr z,state_mission_move_cursor_right_buttons
	ld a,(hl)
	cp 12
	ret z
	inc (hl)
	jr state_mission_move_cursor_sfx

state_mission_move_cursor_right_buttons:	
	ld a,(hl)
	cp 7
	ret nc
	ld (hl),9
	jr state_mission_move_cursor_sfx

state_mission_move_cursor_button1:
	ld a,(ui_cursor_area)
	cp 5
	jr z,state_mission_move_cursor_button1_buttons

	; clicked on the minimap:
	call state_mission_screen_pointer_over_playable_planet
	jr nz,state_mission_move_cursor_button1_wrong

	; check if it's the nebula, and clear it:
	call get_minimap_pointer
	ld a,(hl)
	cp 83 ; nebula
	jr nz,state_mission_move_cursor_button1_no_nebula
	ld (hl),159 ; crossed nebula
	call enable_nearby_minimap_paths
	jp draw_minimap

state_mission_move_cursor_button1_wrong:
	ld hl,SFX_ui_wrong
	jp play_SFX_with_high_priority


state_mission_move_cursor_button1_buttons:
	ld a,(ui_cursor_position)
	cp 7
	jp c,state_mission_move_cursor_button1_selected_upgrade

	jp state_gameover_screen

state_mission_move_cursor_button1_no_nebula:

	; store which map we are playing:
	ld hl,ui_cursor_area
	ld de,global_state_selected_level
	ldi
	ldi

	; level type:
	call get_minimap_pointer
	ld a,(hl)
	sub 85
	ld hl,global_state_selected_level_type
		
	; debug: 
;	and #01	; limit to moai / tech
;	ld a,0	; moai
; 	ld a,1	; tech
;	ld a,2	; water
;	ld a,3	; temple
	ld (hl),a

	; mark if there is a boss or not:
	inc hl	; hl = global_state_selected_level_boss
	ld (hl),0

    ; debug:
;     ld (hl),1	; polyphemus
;     ld (hl),2	; scylla
;     ld (hl),3	; charybdis
;     ld (hl),4	; triton
	
	ld a,(global_state_levels_completed)
	cp 2
	jr z,state_mission_move_cursor_button1_boss
	
	ld a,(global_state_boss2_position)
	ld c,a
	ld a,(ui_cursor_position)
	cp 6	; x position of boss 2
	jr z,state_mission_move_cursor_button1_check_if_boss

	ld a,(global_state_boss3_position)
	ld c,a
	ld a,(ui_cursor_position)
	cp 9	; x position of boss 3
	jr z,state_mission_move_cursor_button1_check_if_boss

	ld a,(ui_cursor_position)
	cp 12	; x position of boss 4
	jr z,state_mission_move_cursor_button1_boss

	jr state_mission_move_cursor_button1_no_boss

state_mission_move_cursor_button1_check_if_boss:
	ld a,(ui_cursor_area)
	add a,a
	cp c
	jr nz,state_mission_move_cursor_button1_no_boss

state_mission_move_cursor_button1_boss:
	; There is a boss:
	ld a,(global_state_bosses_defeated)
	inc a
	ld (hl),a
state_mission_move_cursor_button1_no_boss:	
	jp state_game_start

state_mission_move_cursor_button1_selected_upgrade:
	ld hl,SFX_ui_select
	call play_SFX_with_high_priority
	jp state_weapons_screen


;-----------------------------------------------
state_mission_draw_cursor:
	ld hl,ui_cursor_sprites
	ld de,ui_cursor_sprites+1
	ld (hl),0
	ld bc,2*4-1
	ldir

	ld a,(interrupt_cycle)
	bit 3,a
	ret z

	ld iyl,COLOR_RED
	call state_mission_screen_pointer_over_playable_planet
	jr nz,state_mission_draw_cursor_no_playable_planet
	ld iyl,COLOR_GREEN
state_mission_draw_cursor_no_playable_planet:

	ld a,(ui_cursor_area)	; y
	cp 5
	jr z,state_mission_draw_cursor_buttons
	add a,a
	add a,a
	add a,a
	add a,a
	add a,22
	ld hl,ui_cursor_sprites
	ld (hl),a	; y
	ld a,(ui_cursor_position)
	add a,a
	add a,a
	add a,a
	add a,a
	add a,23
	inc hl
	ld (hl),a	; x
	inc hl
	ld (hl),20
	inc hl
	ld a,iyl
	ld (hl),a
	ret

state_mission_draw_cursor_buttons:
	ld a,(ui_cursor_position)
	cp 7
	jr nc,state_mission_draw_cursor_buttons_quit
	ld de,62*256+106
	jr state_mission_draw_cursor_buttons_continue
state_mission_draw_cursor_buttons_quit:	
	ld de,142*256+178

state_mission_draw_cursor_buttons_continue:
	ld hl,ui_cursor_sprites
	ld (hl),147
	inc hl
	ld (hl),d
	inc hl
	ld (hl),0
	inc hl
	ld (hl),COLOR_DARK_YELLOW
	inc hl
	ld (hl),147
	inc hl
	ld (hl),e
	inc hl
	ld (hl),4
	inc hl
	ld (hl),COLOR_DARK_YELLOW
	ret


;-----------------------------------------------
; output:
; - b,c: y,x coordinate of the cursor
; - hl: ptr
get_minimap_pointer:
	ld hl,ui_cursor_area
	ld b,(hl)
	inc hl
	ld c,(hl)

	; calculate pointer:
	push de
	push bc
		ld hl,global_state_minimap
		ld a,b
		ld de,MINIMAP_WIDTH*2
		or a
		jr z,get_minimap_pointer_done
get_minimap_pointer_y_loop:
		add hl,de
		djnz get_minimap_pointer_y_loop
get_minimap_pointer_done:
		add hl,bc	; b here is 0
		add hl,bc	; b here is 0
	pop bc
	pop de
	ret


;-----------------------------------------------
; return:
; - z: playable planet
; - nz: no playable planet
state_mission_screen_pointer_over_playable_planet:
	; check if clicked over triton: (position 0,12)
	call get_minimap_pointer
	ld a,(ui_cursor_area)
	or a
	jr nz,state_mission_screen_pointer_over_playable_planet_not_triton
	ld a,(ui_cursor_position)
	cp 12
	jr nz,state_mission_screen_pointer_over_playable_planet_not_triton
	; clicked on triton!
	jr state_mission_screen_pointer_over_playable_planet_continue

state_mission_screen_pointer_over_playable_planet_not_triton:
	ld a,(hl)
	cp 83	; nebula
	jr z,state_mission_screen_pointer_over_playable_planet_nebula
	cp 85
	jr c,state_mission_screen_pointer_over_playable_planet_no
	cp 89
	jr nc,state_mission_screen_pointer_over_playable_planet_no

state_mission_screen_pointer_over_playable_planet_continue:

; 	; debug:
; 	xor a
; 	ret

	; check if we have a green path around:
	; 99/102 	- 101 	- 100/102
	; 98 		-  / 	- 98
	; 100/102 	- 101 	- 99/102
	ld bc,-(MINIMAP_WIDTH+1)
	add hl,bc	; top left
	ld d,3	; we need to check 3 rows
	ld a,(ui_cursor_area)
	or a
	jr z,state_mission_screen_pointer_over_playable_planet_skip_first_row

state_mission_screen_pointer_over_playable_planet_loop:
	ld e,0
	; check one row:
	ld a,(ui_cursor_position)
	or a
	jr z,state_mission_screen_pointer_over_playable_planet_row_2
	call state_mission_screen_pointer_over_playable_planet_is_green_path
	jr z,state_mission_screen_pointer_over_playable_planet_yes
state_mission_screen_pointer_over_playable_planet_row_2:
	inc e
	inc hl
	call state_mission_screen_pointer_over_playable_planet_is_green_path
	jr z,state_mission_screen_pointer_over_playable_planet_yes
	inc e
	inc hl
	call state_mission_screen_pointer_over_playable_planet_is_green_path
	jr z,state_mission_screen_pointer_over_playable_planet_yes

	ld bc,MINIMAP_WIDTH-2
	add hl,bc
	dec d
	jr nz,state_mission_screen_pointer_over_playable_planet_loop

state_mission_screen_pointer_over_playable_planet_no:
	or 1
	ret

state_mission_screen_pointer_over_playable_planet_yes:
	xor a
	ret

state_mission_screen_pointer_over_playable_planet_nebula:
	; check that we have the 3 maps:
	ld a,(global_state_bosses_defeated)
	cp 3
	jr nc,state_mission_screen_pointer_over_playable_planet_continue
	jr state_mission_screen_pointer_over_playable_planet_no

state_mission_screen_pointer_over_playable_planet_skip_first_row:
	ld bc,MINIMAP_WIDTH
	add hl,bc
	dec d
	jr state_mission_screen_pointer_over_playable_planet_loop

state_mission_screen_pointer_over_playable_planet_is_green_path:
	ld a,(hl)
	cp 98
	jr c,state_mission_screen_pointer_over_playable_planet_is_green_path_no
	cp 103
	jr nc,state_mission_screen_pointer_over_playable_planet_is_green_path_no

	; if d == 3, e == 0 or d == 1, e == 2: 100 is not a valid one
	; if d == 3, e == 2 or d == 1, e == 0; 99 is not a valid one
	; thus:
	; - if (d+e)#03 == 3 -> 100 is not valid (diag1)
	; - if (d+e)#03 == 1 -> 99 is not valid (diag2)
	ld a,d
	add a,e
	and #03
	dec a
	jr z,state_mission_screen_pointer_over_playable_planet_is_green_path_diag2
	dec a
	dec a
	jr z,state_mission_screen_pointer_over_playable_planet_is_green_path_diag1

	xor a
	ret

state_mission_screen_pointer_over_playable_planet_is_green_path_diag1:
	ld a,(hl)
	cp 100
	jr z,state_mission_screen_pointer_over_playable_planet_is_green_path_no
	xor a
	ret

state_mission_screen_pointer_over_playable_planet_is_green_path_diag2:
	ld a,(hl)
	cp 99
	jr z,state_mission_screen_pointer_over_playable_planet_is_green_path_no
	xor a
	ret

state_mission_screen_pointer_over_playable_planet_is_green_path_no:
	or 1
	ret


;-----------------------------------------------
enable_nearby_minimap_paths:
	call get_minimap_pointer

	; change all blue paths to green paths:
	ld bc,-(MINIMAP_WIDTH+1)
	add hl,bc	; top left
	ld e,3	; we need to check 3 rows
	ld a,(ui_cursor_area)
	or a
	jr z,enable_nearby_minimap_paths_skip_first_row

enable_nearby_minimap_paths_loop:
	; check one row:
	ld a,(ui_cursor_position)
	or a
	jr z,enable_nearby_minimap_paths_row_2
	call enable_nearby_minimap_paths_change_path
enable_nearby_minimap_paths_row_2:
	inc hl
	call enable_nearby_minimap_paths_change_path
	inc hl
	call enable_nearby_minimap_paths_change_path

	ld bc,MINIMAP_WIDTH-2
	add hl,bc
	dec e
	jr nz,enable_nearby_minimap_paths_loop
	ret

enable_nearby_minimap_paths_skip_first_row:
	ld bc,MINIMAP_WIDTH
	add hl,bc
	dec e
	jr enable_nearby_minimap_paths_loop

enable_nearby_minimap_paths_change_path:
	ld a,(hl)
	cp 93
	ret c
	cp 98
	ret nc

	cp 94	; \ connection
	jr z,enable_nearby_minimap_paths_change_path_94
	cp 95   ; / connection
	jr z,enable_nearby_minimap_paths_change_path_95

enable_nearby_minimap_paths_change_path_change:
	ld a,(hl)
	add a,5
	ld (hl),a
	ret

	; make sure we only activate the correct diagonals:
enable_nearby_minimap_paths_change_path_94:	; \
	push hl
		ld bc,MINIMAP_WIDTH+1
		add hl,bc
		ld a,(hl)
	pop hl
	cp 89
	jr nc,enable_nearby_minimap_paths_change_path_change
	push hl
		ld bc,-(MINIMAP_WIDTH+1)
		add hl,bc
		ld a,(hl)
	pop hl
	cp 89
	jr nc,enable_nearby_minimap_paths_change_path_change
	ret

enable_nearby_minimap_paths_change_path_95:	; /
	push hl
		ld bc,MINIMAP_WIDTH-1
		add hl,bc
		ld a,(hl)
	pop hl
	cp 89
	jr nc,enable_nearby_minimap_paths_change_path_change
	push hl
		ld bc,-(MINIMAP_WIDTH-1)
		add hl,bc
		ld a,(hl)
	pop hl
	cp 89
	jr nc,enable_nearby_minimap_paths_change_path_change
	ret


;-----------------------------------------------
state_mission_screen_cutscene_game_start:
	call disable_VDP_output
		call setup_mission_screen_frames
		call draw_general
	call enable_VDP_output

	ld iyh,23*8	
	ld hl,mission_cutscene_1_text
	ld de,CHRTBL2+(16*32+8)*8
	call state_story_cutscene

	; clear the bottom frame:
	ld bc,8*256+30
	ld hl,CLRTBL2+(15*32+1)*8
	call clear_rectangle_bitmap_mode

	; clear the sprites:
	ld bc,4*32
	ld hl,SPRATR2
	xor a
	jp fast_FILVRM


state_mission_screen_cutscene_mission_failed:
	call draw_general
	ld hl,mission_cutscene_0_text
	jr state_mission_screen_cutscene_level1_continue


state_mission_screen_cutscene_level1:
	call draw_general

	ld hl,mission_cutscene_2_text

state_mission_screen_cutscene_level1_continue:
	ld iyh,23*8	
	ld de,CHRTBL2+(16*32+8)*8
	call state_story_cutscene

	; clear the bottom frame:
	ld bc,8*256+30
	ld hl,CLRTBL2+(15*32+1)*8
	call clear_rectangle_bitmap_mode

	; clear the sprites:
	ld bc,4*32
	ld hl,SPRATR2
	xor a
	call fast_FILVRM

	jp state_mission_screen

state_mission_screen_cutscene_level2:
	call draw_general
	ld hl,mission_cutscene_3_text
	jr state_mission_screen_cutscene_level1_continue

state_mission_screen_cutscene_boss1:
	call draw_general
	ld hl,mission_cutscene_4_text
	jr state_mission_screen_cutscene_level1_continue

state_mission_screen_cutscene_boss2:
	call draw_general
	ld hl,mission_cutscene_5_text
	jr state_mission_screen_cutscene_level1_continue

state_mission_screen_cutscene_boss3:
	call draw_general
	ld hl,mission_cutscene_6_text
	jr state_mission_screen_cutscene_level1_continue

state_mission_screen_cutscene_boss4:
	call draw_general
	ld hl,mission_cutscene_7_text
	ld iyh,23*8	
	ld de,CHRTBL2+(16*32+8)*8
	call state_story_cutscene
	jp state_game_ending


;-----------------------------------------------
draw_minimap:
	ld de,CHRTBL2+(3*32+3)*8
	ld hl,global_state_minimap

	ld c,9
draw_minimap_y_loop:
	ld b,26
draw_minimap_x_loop:
	push bc
	push hl
		push de
			ld a,(hl)
			cp 31	; background
			jr nz,draw_minimap_not_bg
draw_minimap_bg:
			call random
			cp 16
			jr nc,draw_minimap_bg_empty
			ld a,80
			jr draw_minimap_not_bg
draw_minimap_bg_empty:
			ld a,31
draw_minimap_not_bg:
			call draw_tile_bitmap_mode_by_index
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop hl
	pop bc
	inc hl
	djnz draw_minimap_x_loop
	push bc
		ex de,hl
			ld bc,6*8
			add hl,bc
		ex de,hl
	pop bc
	dec c
	jr nz,draw_minimap_y_loop

	; draw the text:
	ld c,TEXT_GALAXY_MAP_BANK
	ld a,TEXT_GALAXY_MAP_IDX
	ld de,CHRTBL2+(1*32+1)*8
	ld iyl,COLOR_WHITE*16
	call draw_text_from_bank_16

	ld c,TEXT_ITHAKI_BANK
	ld a,TEXT_ITHAKI_IDX
	ld de,CHRTBL2+(12*32+2)*8
	ld iyl,COLOR_WHITE*16
	call draw_text_from_bank_16

	ld c,TEXT_TRITON_BANK
	ld a,TEXT_TRITON_IDX
	ld de,CHRTBL2+(2*32+26)*8-1
	ld iyl,COLOR_WHITE*16
	ld b,8*4
	call draw_text_from_bank

	ld c,TEXT_AIGAI_BANK
	ld a,TEXT_AIGAI_IDX
	ld de,CHRTBL2+(5*32+25)*8
	ld iyl,COLOR_WHITE*16
	ld b,8*4
	call draw_text_from_bank

	ld c,TEXT_NEBULA_BANK
	ld a,TEXT_NEBULA_IDX
	ld de,CHRTBL2+(6*32+25)*8
	ld iyl,COLOR_WHITE*16
	ld b,8*4
	call draw_text_from_bank

	; draw collected maps:
	ld a,(global_state_bosses_defeated)
	and #03	; at most 3 maps
	ret z
	ld de,CHRTBL2+(11*32+28)*8
	ld b,a
draw_minimap_map_loop:
	push bc
		push de
			ld a,143	; map tile
			call draw_tile_bitmap_mode_by_index
		pop hl
		ld bc,8
		add hl,bc
		ex de,hl
	pop bc
	djnz draw_minimap_map_loop
	ret 


;-----------------------------------------------
draw_general:
	ld hl,mission_cutscenes_gfx
	ld de,CHRTBL2+(16*32+2)*8
	ld c,5
draw_general_y_loop:
	ld b,5
draw_general_x_loop:
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
	djnz draw_general_x_loop
	push bc
		ex de,hl
		ld bc,27*8
		add hl,bc
		ex de,hl
	pop bc
	dec c
	jr nz,draw_general_y_loop

	; sprites:
	ld hl,general_sprites
	ld de,SPRATR2
	ld bc,8
	jp fast_LDIRVM
