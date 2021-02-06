;-----------------------------------------------
; Start a new game
state_game_start:
	ld sp,#F380	; we might come here from within some function for convenience, so, just reset stack

	call StopMusic

	call disable_VDP_output

	    ; intialize variables:
	    xor a
	    ld hl,data_to_zero_on_game_start_start
	    ld de,data_to_zero_on_game_start_start+1
	    ld bc,(data_to_zero_on_game_start_end-data_to_zero_on_game_start_start)-1
	    ld (hl),a
	    ldir 

; 	    ld ix,decompress_sprite_upload_order_plt_from_page1
; 	    call call_from_page1
; 	    ld ix,decompress_enemy_wave_types_plt_from_page1
; 	    call call_from_page1
		call decompress_sprite_upload_order_plt
		ld hl,enemy_wave_types_plt
		ld de,enemy_wave_types
		call unpack_compressed

	    ; difficulty:
	    ld hl,difficulty_d1_values_ROM
	    ld de,difficulty_values_RAM
	    ld bc,difficulty_d1_values_ROM_end - difficulty_d1_values_ROM
	    ld a,(global_state_selected_level+1)
	    srl a
state_game_start_difficulty_loop:
	    jr z,state_game_start_difficulty_loop_end
		add hl,bc
		dec a
		jr state_game_start_difficulty_loop
state_game_start_difficulty_loop_end:

	    ldir
	    ld a,3
	    ld (level_end_countdown),a

; 	    ; debug:
; 	    ld a,0
; 	    ld (difficulty_level_length),a

	    ld bc,64*32
	    ld hl,sprites_ingame_plt
	    call load_sprites_sprtbl2

	    ld a,200
		ld hl,in_game_sprite_attributes	    
		ld de,in_game_sprite_attributes+1
		ld bc,(3+MAX_ENEMIES+MAX_ENEMY_BULLETS+MAX_PLAYER_SECONDARY_BULLETS+2)*4-1
	    ld (hl),a
		ldir

		; Initialize the player:
		call respawn_player
	    ld a,(global_state_weapon_upgrade_level+WEAPON_PILOTS)
	    ld hl,player_lives
	    ld (hl),a

	    ; initial speed:
 	    ld a,(global_state_weapon_upgrade_level+WEAPON_INITIAL_SPEED)
 	    ld (ingame_weapon_current_level),a	; initial speed up
		ld hl,speed_up_levels
		ADD_HL_A
		ld a,(hl)
		ld (player_speed_level),a
	    ld a,WEAPON_MAX_ENERGY
	    ld (player_primary_weapon_energy),a

	    ld hl,scoreboard_sprites_ROM
	    ld de,SPRATR2   ; the first 4 sprites are there to protect the scoreboard
	    ld bc,4*4
	    call fast_LDIRVM

		; Load any level specific data (load graphics into VDP, and decompress PCG patterns):
	    call load_level_type_data

	    ; 2 empty patterns to start a level
	    ld a,2
	    ld (PCG_remaining_empty_patterns),a
	    ld hl,pcgPatterns
	    ld (PCG_last_pattern_used_ptr),hl

	    ; enemy spawn queue:
		ld hl,enemy_spawn_queue
		ld de,enemy_spawn_queue+1
		ld (hl),#ff 	; mark that there is no enemy to spawn
		ld bc,(enemy_spawn_queue_end-enemy_spawn_queue)-1
		ldir	; set all the que to #ff, so, it's clear
		ld hl,enemy_spawn_queue
		ld (enemy_spawn_queue_next_to_push),hl
		ld (enemy_spawn_queue_next_to_pop),hl

		; the values for ENEMY_STRUCT_SPRITE_IDX, ENEMY_BULLET_STRUCT_SPRITE_PTR, and 
		; PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX
		; are predefined here, and do not need to be updated any more during the game:
		xor a
		ld hl,enemies+ENEMY_STRUCT_SPRITE_IDX
		ld de,ENEMY_STRUCT_SIZE
		ld b,MAX_ENEMIES
state_game_start_enemy_init_loop:
		ld (hl),a
		add hl,de
		add a,4
		djnz state_game_start_enemy_init_loop

		ld hl,enemy_bullet_sprite_attributes
		ld ix,enemy_bullets
		ld b,MAX_ENEMY_BULLETS
state_game_start_enemy_bullet_init_loop:
		ld (ix+ENEMY_BULLET_STRUCT_SPRITE_PTR),l
		ld (ix+ENEMY_BULLET_STRUCT_SPRITE_PTR+1),h
		ld de,ENEMY_BULLET_STRUCT_SIZE
		add ix,de
		ld e,4	; no need to modify d, as itis 0 here
		add hl,de
		djnz state_game_start_enemy_bullet_init_loop

		xor a
		ld hl,player_secondary_bullets+PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX
		ld de,PLAYER_SECONDARY_BULLET_STRUCT_SIZE
		ld b,e  ; MAX_PLAYER_SECONDARY_BULLETS happens to be == PLAYER_SECONDARY_BULLET_STRUCT_SIZE
; 		ld b,MAX_PLAYER_SECONDARY_BULLETS
state_game_start_player_secondary_bullet_init_loop:
		ld (hl),a
		add hl,de
		add a,4
		djnz state_game_start_player_secondary_bullet_init_loop

	    ; scoreboard:
	    ld ix,decompress_scoreboard_from_page1
	    call call_from_page1

	    ld hl,buffer
	    ld de,NAMTBL2+22*32
	    ld bc,32*2
	    call fast_LDIRVM
	    call update_scoreboard_lives
	    call update_scoreboard_weapon_selection
	    call update_scoreboard_credits
	    call update_scoreboard_energy

		; generate the start of a level via PCG:
		ld hl,mapBuffer
		ld (PCG_mapBuffer_nextptr),hl
		call PCG_choosePattern
		xor a
		ld (PCG_next_pattern_x),a	; correct the pattern initially, as this will be wrong, since scroll has not started yet
		call PCG_unpackPattern
		call PCG_spawnTileBasedEnemies
		ld de,mapBuffer+PCG_PATTERN_WIDTH*0
		call PCG_copyPatternToBuffer

		call PCG_choosePattern
		ld a,16
		ld (PCG_next_pattern_x),a	; correct the pattern initially, as this will be wrong, since scroll has not started yet
		call PCG_unpackPattern
		call PCG_spawnTileBasedEnemies
		ld de,mapBuffer+PCG_PATTERN_WIDTH*1
		call PCG_copyPatternToBuffer

		call PCG_choosePattern
		ld a,32
		ld (PCG_next_pattern_x),a	; correct the pattern initially, as this will be wrong, since scroll has not started yet
		call PCG_unpackPattern
		call PCG_spawnTileBasedEnemies
		ld de,mapBuffer+PCG_PATTERN_WIDTH*2
		call PCG_copyPatternToBuffer

		; set the first 2 waves to be trilos (up/down)
		ld hl,enemy_spawn_next_waves
		ld (hl),1
		inc hl
		ld (hl),2

	    ; initialize the star field:
	    ld a,#01
	    ld (starfield_tile),a
		ld bc,0
state_game_start_starfield_init_loop:
		push bc
			call starfield_new_star
		pop bc
		inc bc
		ld a,c
		cp 31
		jr nz,state_game_start_starfield_init_loop

		call load_option_weapon_tiles		


	    ; weapon configuration:
		ld ix,global_state_weapon_configuration
		ld de,ingame_weapon_max_level
		ld b,0
		ld iyl,8
state_game_start_weapon_init_loop:		
		ld a,(ix)
		or a
		jr z,state_game_start_weapon_init_loop_none
		ld c,a

		ld hl,global_state_weapon_upgrade_level
		add hl,bc
		ld a,(hl)
		dec a

		ld hl,weapon_max_ingame_upgrades_at_level-3
		add hl,bc
		add hl,bc
		add hl,bc
		ld c,a
		add hl,bc
		ld a,(hl)
state_game_start_weapon_init_loop_none:		
		ld (de),a
		inc de
		inc ix
		dec iyl
		jr nz,state_game_start_weapon_init_loop

	    ; passive upgrades:
	    xor a
	    ld (player_primary_weapon_idx),a
	    ld (player_primary_weapon),a

	    ; initial weapon:
	    ld a,(global_state_weapon_upgrade_level+WEAPON_INIT_WEAPON)
	    or a
	    jr z,state_game_start_equip_weapon_default
	    ; look for the highest equipped weapon:
	    ld c,4
		ld a,(global_state_weapon_configuration+4)
		or a
		jr nz,state_game_start_equip_weapon
		dec c
		ld a,(global_state_weapon_configuration+3)
		or a
		jr nz,state_game_start_equip_weapon
state_game_start_equip_weapon_default:
	    ld c,2
state_game_start_equip_weapon:
		ld hl,ingame_weapon_current_selection
		ld (hl),c
		call select_weapon_silent

		; draw the first frame:
		halt
		call starfield_update_draw
		call update_scroll_and_pcg
    	call draw_map
    	call update_sprites

		ld ix,(level_type_song_ptr)
		call call_from_page1
	    ld a,(level_type_song_speed)
	    call PlayMusic

	call enable_VDP_output
	; jp game_loop


;-----------------------------------------------
; main game loop!
game_loop:
	halt
    ;out (#2c),a
    call update_sprites
	call update_scroll_and_pcg
    ld a,(scroll_x_half_pixel)
    and #01
    jr z,game_loop_even

    ; ---- odd cycles: ----
game_loop_odd:
		call update_enemies	; only update the enemies on the odd frames, when the map is not updated
							; might mark player bullets for deletion, or spawn power pellets
	    call update_enemy_bullets	; only update enemy bullets on the odd frames, when the map is not updated
	    call update_keyboard_buffers
		call update_player
		call restore_player_bullets_bg
	    call explosions_restore_bg
	    call check_power_pellet_pickup
	    ld hl,any_tile_enemy_to_delete
	    ld a,(scroll_x_half_pixel)
	    cp 15
	    jr z,game_loop_power_pellet_redraw
	    ld a,(redraw_power_pellets_signal)
	    add a,(hl)
	    or a
	    jr z,game_loop_no_power_pellet_redraw
game_loop_power_pellet_redraw:
	    ; clear the redraw signals:
	    xor a
	    ld (hl),a
	    ld (redraw_power_pellets_signal),a
	    call power_pellets_restore_bg
	    call check_tile_enemy_deletion
	 	call starfield_update_odd

	    ld a,(scroll_x_half_pixel)
	    cp 15
	    call z,update_tile_enemies	; only once per scroll tile, as these are slow enemies, no need to spend much CPU

	    call power_pellets_draw
	    jr game_loop_odd_continue

game_loop_no_power_pellet_redraw:
	 	call starfield_update_odd
game_loop_odd_continue:	

		ld hl,scroll_restart
		ld a,(hl)
		or a
		ld (hl),0
		call nz,game_loop_adjust_positions_after_scroll_restart
; 	    ld a,(scroll_x_half_pixel)
; 	    dec a
; 	    jr nz,game_loop_skip_player_bullet_adjust
; 		ld a,(scroll_x_tile)
; 		and #3f
; 		call z,game_loop_adjust_positions_after_scroll_restart
; game_loop_skip_player_bullet_adjust:
		call update_explosions
		call update_player_bullets
	    jr game_loop_continue

	; ---- even cycles: ----
game_loop_even:
	 	call starfield_update_even
		call draw_map	; only update the map on the even frames, as nothing changes in the odd ones!
	    call update_keyboard_buffers
	    call update_player
		call update_player_secondary_bullets

game_loop_continue:
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

	;out (#2d),a
    jp game_loop


game_loop_adjust_positions_after_scroll_restart:
    call adjust_player_bullet_positions_after_scroll_restart	; only adjusts X, no bg change
    call adjust_explosion_positions_after_scroll_restart		; only adjusts X, no bg change
    jp adjust_power_pellet_positions_after_scroll_restart		; adjusts X, and redraws (without saving any new BG info)


check_for_weapon_change:
	ld hl,player_bullets
	ld de,PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
check_for_weapon_change_loop:
	ld a,(hl)
	or a
	jr z,check_for_weapon_change_next
	inc hl
	ld a,(hl)
	dec hl
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES
	ret m
check_for_weapon_change_next:
	add hl,de
	djnz check_for_weapon_change_loop
	; no bullets, change weapon tiles!
	call load_weapon_tiles
	xor a
	ld (player_weapon_change_signal),a
	ret


game_pause:
	call PauseMusic
	; print the "pause" message
 	ld bc,TEXT_PAUSE_BANK + 5*8*256
 	ld a,TEXT_PAUSE_IDX
 	ld de,CHRTBL2+FIRST_TILE_FOR_IN_GAME_TEXT*8
 	ld iyl,COLOR_WHITE*16
 	call draw_text_from_bank
 	ld hl,NAMTBL2+7*32+14
 	ld b,5
 	ld a,FIRST_TILE_FOR_IN_GAME_TEXT
 	call draw_text_name_table_ingame

	ld bc,TEXT_Q_QUIT_BANK + 5*8*256
	ld a,TEXT_Q_QUIT_IDX
	ld de,CHRTBL2+(FIRST_TILE_FOR_IN_GAME_TEXT+5)*8
	ld iyl,COLOR_WHITE*16
	call draw_text_from_bank

game_pause_loop:
	halt	
	ld a,(interrupt_cycle)
	bit 4,a
	jr z,game_pause_loop_draw_pause
game_pause_loop_clear_pause:
	xor a
	ld hl,NAMTBL2+6*32+14
	ld bc,5
	call fast_FILVRM
	jr game_pause_loop_draw_pause_done
game_pause_loop_draw_pause:
	ld hl,NAMTBL2+6*32+14
	ld b,5
	ld a,FIRST_TILE_FOR_IN_GAME_TEXT+5
	call draw_text_name_table_ingame
game_pause_loop_draw_pause_done:

    call update_keyboard_buffers

    ld a,(keyboard_line_clicks+KEY_PAUSE_BYTE)
    bit KEY_PAUSE_BIT,a
    jr nz,game_pause_loop_exit
    ld a,(keyboard_line_clicks+KEY_Q_BYTE)
    bit KEY_Q_BIT,a
    jr nz,game_quit
	jr game_pause_loop
game_pause_loop_exit:
    jp ResumeMusic


game_life_lost:
	xor a
	ld (player_lose_life_signal),a

	ld hl,player_lives
	dec (hl)
	ld a,(hl)
	inc a
	jr z,game_quit
	call update_scoreboard_lives
	jp respawn_player

game_quit:
	call StopMusic
	call clearScreenLeftToRight
	call clearAllTheSprites
	jp COMPRESSED_state_mission_screen_from_game_failed
	;jp state_gameover_screen


;-----------------------------------------------
update_scroll_and_pcg:
	; schedule for PCG operations is (map is drawn on even frames, so, no heavy duty operations there):
	; 	- frame 0.0: starfield
	; 	- frame 0.1: choose pattern, sprite enemy spawn
	; 	- frame 0.2: -
	; 	- frame 0.3: decompress
	; 	- frame 0.4: starfield
	; 	- frame 0.5: spawn enemies
	; 	- frame 0.6: spawn enemies
	; 	- frame 0.7: spawn enemies
	; 	- frame 0.8: starfield
	; 	- frame 0.9: spawn enemies
	; 	- frame 0.10: spawn enemies
	; 	- frame 0.11: spawn enemies
	; 	- frame 0.12: starfield
	; 	- frame 0.13: spawn enemies
	; 	- frame 0.14: spawn enemies
	; 	- frame 0.15: spawn enemies, tile enemies
	; 	- frame 1.0: starfield
	; 	- frame 1.1: spawn enemies, sprite enemy spawn
	; 	- frame 1.2: spawn enemies
	; 	- frame 1.3: -
	; 	- frame 1.4: starfield
	; 	- frame 1.5: -
	; 	- frame 1.6: -	
	;   - frame 1.7: wave spawning
	;   - frame 1.8: starfield
	;   - frame 1.9: -
	;   - frame 1.10: -
	;   - frame 1.11: -
	;   - frame 1.12: starfield
	;   - frame 1.13: -
	;   - frame 1.14: tile enemies
	;   - frame 1.15: -
	;  ...
	; 	- frame 8.3: copy 1
	; 	- frame 8.4: starfield
	; 	- frame 8.5: copy 2
	;  ...

	ld a,(scroll_x_half_pixel)
	inc a
	and #0f
	ld (scroll_x_half_pixel),a
	jr nz,update_scroll_pcg_cycle_no_tile_increase
	ld a,(scroll_x_tile)
; 	ld (scroll_x_tile_prev),a	; store it for spawning enemies/power pellets/etc.
	inc a
	and #3f
	ld (scroll_x_tile),a
	call z,adjust_enemy_positions_after_scroll_restart	; also sets "(scroll_restart) = 1"
update_scroll_pcg_cycle_no_tile_increase:

	ld a,(scroll_x_tile)
	and #0f
	push af
		call z,update_scroll_pcg_update_frame0
	pop af
	dec a
	call z,update_scroll_pcg_update_frame1
	ld a,(scroll_x_tile)
	and #0f
	cp 8
	call z,update_scroll_pcg_update_frame8

	ld a,(scroll_x_half_pixel)
	dec a
	jp z,check_for_enemies_to_spawn
	ret


update_scroll_pcg_update_frame0:
	ld a,(scroll_x_half_pixel)
	or a
	ret z	; frame 0.0
	dec a
	jp z,PCG_choosePattern
	dec a
	ret z  	; frame 0.2
	dec a
	jp z,PCG_unpackPattern
	ld a,(scroll_x_half_pixel)
	and #03
	ret z	; starfield frames
	jp PCG_spawnTileBasedEnemies_2rows


update_scroll_pcg_update_frame1:
	ld a,(scroll_x_half_pixel)
	dec a
	jp z,PCG_spawnTileBasedEnemies_2rows
	dec a
	jp z,PCG_spawnTileBasedEnemies_2rows
	; pattern copies (all together for now):
	add a,-2
	ret z	; frame 1.4
	add a,-2
	ret z	; frame 1.6
	dec a
	ret nz
	jp PCG_choose_enemy_wave

update_scroll_pcg_update_frame8:
	ld a,(scroll_x_half_pixel)
	cp 3
	jr z,update_scroll_pcg_update_frame1_copy1
	cp 4
	jr z,update_scroll_pcg_update_frame1_copy2
	ret

update_scroll_pcg_update_frame1_copy2:
	; copy:
	ld a,(scroll_x_tile)
	sub PCG_PATTERN_WIDTH+8
	jr z,update_scroll_pcg_cycle2_1
	cp PCG_PATTERN_WIDTH
	jr z,update_scroll_pcg_cycle2_2
	ret


update_scroll_pcg_update_frame1_copy1:
	; copy:
	ld a,(scroll_x_tile)
	sub 8
	jr z,update_scroll_pcg_cycle_0
	cp PCG_PATTERN_WIDTH
	jr z,update_scroll_pcg_cycle_1
	cp PCG_PATTERN_WIDTH*2
	jr z,update_scroll_pcg_cycle_2
	cp PCG_PATTERN_WIDTH*3
	ret nz

update_scroll_pcg_cycle_3:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*2
	jp PCG_copyPatternToBuffer

update_scroll_pcg_cycle_0:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*3
	jp PCG_copyPatternToBuffer

update_scroll_pcg_cycle_1:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*4
	jp PCG_copyPatternToBuffer

update_scroll_pcg_cycle2_1:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*0
	jp PCG_copyPatternToBuffer

update_scroll_pcg_cycle_2:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*5
	jp PCG_copyPatternToBuffer

update_scroll_pcg_cycle2_2:
	ld de,mapBuffer+PCG_PATTERN_WIDTH*1
	jp PCG_copyPatternToBuffer

