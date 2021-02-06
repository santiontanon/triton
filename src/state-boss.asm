;-----------------------------------------------
state_boss:
	ld hl,boss_variables_start
	ld bc,(boss_variables_end-boss_variables_start)-1
	call clear_memory
	
	xor a
	ld (scroll_x_half_pixel),a
	ld (starfield_scroll_speed),a
	inc a
	ld (in_boss),a

	call power_pellets_restore_bg
	ld hl,power_pellets
	ld bc,MAX_POWER_PELLETS*POWER_PELLET_STRUCT_SIZE-1
	call clear_memory

	ld hl,pcg_map_pattern_buffer
	ld bc,PCG_PATTERN_WIDTH*MAP_HEIGHT-1
	call clear_memory

	ld ix,decompress_boss_song_from_page1
	call call_from_page1
    ld a,(isComputer50HzOr60Hz)
    add a,9	; 9 if 50Hz, 10 if 60Hz
    call PlayMusic

state_boss_loop:
	halt
    call update_sprites
	call update_scroll_boss
    ld a,(scroll_x_half_pixel)
    and #01
    jr z,boss_loop_even

    ; ---- odd cycles: ----
boss_loop_odd:
	    call update_keyboard_buffers
		call update_player
		call restore_player_bullets_bg
	    call explosions_restore_bg
	 	call starfield_update_odd
	    call update_boss

	    ld a,(scroll_x_half_pixel)
	    dec a
	    jr nz,boss_loop_skip_player_bullet_adjust
		ld a,(scroll_x_tile)
		and #3f
		call z,game_loop_adjust_positions_after_scroll_restart
boss_loop_skip_player_bullet_adjust:
		call update_explosions
		call update_player_bullets
	    jr boss_loop_continue

	; ---- even cycles: ----
boss_loop_even:
	 	call starfield_update_even	
		call draw_map	; only update the map on the even frames, as nothing changes in the odd ones!
		call update_enemies	
	    call update_enemy_bullets	; only update enemy bullets on the odd frames, when the map is not updated
	    call update_keyboard_buffers
	    call update_player
		call update_player_secondary_bullets

boss_loop_continue:
	ld hl,player_weapon_change_signal
	ld a,(hl)
	or a
	call nz,check_for_weapon_change
	ld a,(player_lose_life_signal)
	or a
	call nz,game_life_lost
    ld a,(keyboard_line_clicks+KEY_PAUSE_BYTE)
    bit KEY_PAUSE_BIT,a
    call nz,game_pause
	jr state_boss_loop


;-----------------------------------------------
update_scroll_boss:
	ld a,(scroll_x_half_pixel)
	inc a
	and #0f
	ld (scroll_x_half_pixel),a
	jr nz,update_scroll_boss_no_tile_increase
	ld a,(scroll_x_tile)
	inc a
	and #3f
	ld (scroll_x_tile),a
	call z,adjust_enemy_positions_after_scroll_restart
update_scroll_boss_no_tile_increase:

	ld a,(scroll_x_half_pixel)
	dec a
	call z,check_for_enemies_to_spawn

	ld a,(scroll_x_tile)
	and #0f
	cp 8
	ret nz
	ld a,(scroll_x_half_pixel)
	dec a
	ret nz
	; clear the map ahead (this plays the role of the PCG during game, but just clears the map ahead):
	call update_scroll_pcg_update_frame1_copy1
	jp update_scroll_pcg_update_frame1_copy2


;-----------------------------------------------
update_boss:
	ld a,(boss_state)
	or a
	jr z,update_boss_state0
	jp BOSS_COMPRESSED_CODE_START

update_boss_state0:
	ld a,(scroll_x_half_pixel)
	dec a
 	ret nz
 	ld hl,starfield_scroll_speed
 	ld (hl),4

update_boss_state0_to_state1:
	ld a,1
	ld (boss_state),a

	ld a,(global_state_selected_level_boss)
	dec a
	jp z,init_polyphemus
	dec a
	jp z,init_scylla
	dec a
	jp z,init_charybdis
	jp init_triton
