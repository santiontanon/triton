;-----------------------------------------------
respawn_player:
    ld hl,player_sprite_attributes_ROM
    ld de,player_sprite_attributes
    ld bc,12
    ldir
    ld hl,player_state
    ld (hl),PLAYER_STATE_INVULNERABLE
    inc hl	; player_state_timer
    ld (hl),0

    ld hl,in_game_sprite_attributes
    ld de,SPRATR2+4*4   ; skip the 4 sprites to protect scoreboard
    ld bc,8
    call fast_LDIRVM

    ; reset power bar
	ld hl,ingame_weapon_current_selection
	ld (hl),#ff
	jp update_scoreboard_weapon_selection


;-----------------------------------------------
update_player:
	ld a,(player_primary_weapon_special_triggered)
	or a
	jr nz,update_player_energy_done	; do not increase energy while using the special

	; at weapon level 1, energy recharges at 1/2 speed:
	ld a,(player_primary_weapon_level)
	dec a
	jr nz,update_player_not_level1
	ld a,(interrupt_cycle)
	and #01
	jr z,update_player_energy_done
	
update_player_not_level1:
	ld hl,player_primary_weapon_energy
	ld a,(hl)
	cp WEAPON_MAX_ENERGY
	jr nc,update_player_max_energy
	inc (hl)
	inc a
	and #07
	call z,update_scoreboard_energy
	jp update_player_energy_done
update_player_max_energy:
	ld (hl),WEAPON_MAX_ENERGY
update_player_energy_done:

	ld hl,player_primary_weapon_cooldown_state
	ld a,(hl)
	or a
	jr z,update_player_primary_weapon_ready
	dec (hl)
update_player_primary_weapon_ready:

	ld hl,player_secondary_weapon_cooldown_state
	ld a,(hl)
	or a
	jr z,update_player_secondary_weapon_ready
	dec (hl)
update_player_secondary_weapon_ready:

	ld hl,player_option_weapon_cooldown_state
	ld a,(hl)
	or a
	jr z,update_player_option_weapon_ready
	dec (hl)
update_player_option_weapon_ready:

	ld a,(player_state)
	or a
	jr z,update_player_default_state
	dec a
	jp nz,update_player_explosion_state

update_player_invulnerable_state:
	ld hl,player_state_timer
	inc (hl)
	ld a,(hl)

	bit 2,a
	jr z,update_player_invulnerable_state_visible
update_player_invulnerable_state_invisible:
	xor a
	ld (player_sprite_attributes+3),a
	ld (player_sprite_attributes+4+3),a
	jr update_player_invulnerable_state_color_set
update_player_invulnerable_state_visible:
	ld a,COLOR_GREY
	ld (player_sprite_attributes+3),a
	ld a,COLOR_DARK_BLUE
	ld (player_sprite_attributes+4+3),a
update_player_invulnerable_state_color_set:

	ld a,(hl)
	cp INVULNERABLE_TIME
	jr nz,update_player_default_state
	dec hl	; player_state
	ld (hl),PLAYER_STATE_DEFAULT

update_player_default_state:
	xor a
	ld (player_current_movement),a

	ld hl,player_speed_level
	ld c,(hl)
	ld a,(player_hold_fire_timer)
	cp TIME_PRESSING_FOR_SPECIAL
	jp m,update_player_default_state_no_slow_down
	srl c
update_player_default_state_no_slow_down:
	ld a,(player_speed_state)
	add a,c
update_player_default_state_movement_loop:	
	cp 64
	jp c,update_player_default_state_move_done
	sub 64
	push af
		call update_player_default_state_movement
	pop af
	jp update_player_default_state_movement_loop
update_player_default_state_move_done:
	ld (player_speed_state),a

	ld a,(player_current_movement)
	or a
	jr z,update_player_default_state_no_move
	ld (player_last_movement),a
update_player_default_state_no_move:

	; update option positions:
	ld a,(player_option_weapon_level)
	or a
	call nz,update_player_options

	; precalculate tile_x and tile_y (used later), and then check collisions:
	ld a,(player_y)
	add a,6	; ship center
    rrca
    rrca
    rrca
    and 31
	ld (player_tile_y),a
	ld b,a
	ld a,(player_x)
	add a,12 ; ship center
    rrca
    rrca
    rrca
    and 31
	ld hl,scroll_x_tile
	add a,(hl)
	ld (player_tile_x),a
	ld c,a

	; weapon usage:
	push bc
		xor a
		ld (player_laser_type),a	; switch laser off

		ld a,(keyboard_line_clicks+KEY_BUTTON2_BYTE)
		bit KEY_BUTTON2_BIT,a
		push af
			call nz,select_weapon_sfx
		pop af
		bit KEY_BUTTON2_BIT_ALTERNATIVE,a
		call nz,select_weapon_sfx

		ld a,(player_primary_weapon)
		cp WEAPON_LASER
		jr z,update_player_fire_laser
		cp WEAPON_TWISTER_LASER
		jr z,update_player_fire_laser

		; for bullet weapons, we want maximum responsiveness, so we fire on click:
		; (for laser weapon, we fire upon fire key release, to prevent a bullet to come out right before each
		;  laser burst)
 		ld a,(keyboard_line_clicks+KEY_BUTTON1_BYTE)
;  		bit KEY_BUTTON1_BIT,a
;  		call nz,spawn_player_bullet
 		rra  ; assuming KEY_BUTTON1_BIT == 0
 		call c,spawn_player_bullet

update_player_fire_laser:
		ld hl,player_hold_fire_timer
		ld a,(keyboard_line_state+KEY_BUTTON1_BYTE)
; 		bit KEY_BUTTON1_BIT,a
; 		jp nz,update_player_fire_not_held
 		rra  ; assuming KEY_BUTTON1_BIT == 0
 		jr c,update_player_fire_not_held

		inc (hl)

		; fire is being held! weapon special effect!
		ld a,(hl)
		cp 128
		jr c,update_player_fire_no_timer_overflow
		sub 64
		ld (hl),a	; prevent the counter from overflowing
update_player_fire_no_timer_overflow:
 		cp TIME_PRESSING_FOR_SPECIAL	; at least some frames holding space to consider it a "hold"
 		jr c,update_player_not_firing

		call spawn_player_bullet_fire_held
		jr update_player_not_firing

update_player_fire_not_held:
		ld c,(hl)	; hl = player_hold_fire_timer
		xor a
		ld (hl),a
		ld (player_primary_weapon_special_triggered),a

		ld a,(player_primary_weapon)
		cp WEAPON_LASER
		jr z,update_player_check_laser_fire
		cp WEAPON_TWISTER_LASER
		jr nz,update_player_not_firing

update_player_check_laser_fire:
		; only for laser (fire upon fire key release):
		ld a,c	; (player_hold_fire_timer)
		or a
		jr z,update_player_not_firing
		cp TIME_PRESSING_FOR_SPECIAL
		call c,spawn_player_bullet	; we have held space for less than the amount necessary for autofire, fire a bullet!

update_player_not_firing:
		ld a,(player_shield_level)
		or a
		jr z,update_player_no_shield
update_player_shield:
		ld hl,player_y
		ld de,player_y3
		ldi
		ldi
		ld hl,player_shield_colors
		dec a
		jr nz,update_player_shield_no_last_hit
		ld hl,player_shield_colors_last_hit
update_player_shield_no_last_hit:
		ld a,(interrupt_cycle)
	    rrca
	    rrca
	    rrca
	    and 31
		and #03
		ADD_HL_A
		ld a,(hl)
		ld (player_sprite_attributes+8+3),a
		jr update_player_after_shield
update_player_no_shield:
		ld a,200
		ld (player_y3),a
update_player_after_shield:

		; if player is invulnerable, do not check collision (but we still want to calculate tile x, and y)
		ld a,(player_state)
		cp PLAYER_STATE_INVULNERABLE
	pop bc
	ret z

	call collisionWithMap
	ld c,10	; some large number so it's insta-death
	jp nz,update_player_collision
	ret

update_player_default_state_movement:
	ld a,12
	ld (player_desired_frame),a	; 1 is the neutral position
	ld a,(keyboard_line_state)
	bit KEY_LEFT_BIT,a
	push af
		call z,update_player_left
	pop af
	bit KEY_RIGHT_BIT,a
	push af
		call z,update_player_right
	pop af
	bit KEY_UP_BIT,a
	push af
		call z,update_player_up
	pop af
	bit KEY_DOWN_BIT,a
	call z,update_player_down

	ld a,(player_desired_frame)
	ld (player_sprite_attributes+2),a
	add a,-4
	ld (player_sprite_attributes+4+2),a
	ret


update_player_explosion_state:
	ld hl,player_state_timer
	ld a,(hl)
	cp 16
	jp p,update_player_explosion_state_frame1
	ld a,PLAYER_SPRITE_EXPLOSION
	jr update_player_explosion_state_frame_set
update_player_explosion_state_frame1:
	cp 32
	jp p,update_player_explosion_state_frame2
	ld a,PLAYER_SPRITE_EXPLOSION+8
	jr update_player_explosion_state_frame_set
update_player_explosion_state_frame2:
	cp 48
	jp p,update_player_explosion_state_lose_life
	ld a,PLAYER_SPRITE_EXPLOSION+16

update_player_explosion_state_frame_set:
	ld (player_sprite_attributes+2),a
	add a,4
	ld (player_sprite_attributes+4+2),a
	ld a,COLOR_RED
	ld (player_sprite_attributes+3),a
	ld a,COLOR_DARK_YELLOW
	ld (player_sprite_attributes+4+3),a

	inc (hl)
	ret

update_player_explosion_state_lose_life:
	ld hl,player_lose_life_signal
	ld (hl),1
	ret


update_player_left:
	ld hl,player_current_movement
	ld a,(hl)
	and #fc	; clear horizontal movement
	or #01
	ld (hl),a

	ld hl,player_x
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,player_x2
	dec (hl)
	ret


update_player_right:
	ld hl,player_current_movement
	ld a,(hl)
	and #fc	; clear horizontal movement
	or #02
	ld (hl),a

	ld hl,player_x
	ld a,(hl)
	cp 232
	ret z
	inc (hl)
	ld hl,player_x2
	inc (hl)
	ret


update_player_up:
	ld hl,player_current_movement
	ld a,(hl)
	and #f3	; clear vertical movement
	or #04
	ld (hl),a

	; change animation frame
	ld hl,player_desired_frame
	ld a,(hl)
	add a,8
	ld (hl),a

	ld hl,player_y
	ld a,(hl)
	or a
	ret z
	dec (hl)
	ld hl,player_y2
	dec (hl)
	ret


update_player_down:
	ld hl,player_current_movement
	ld a,(hl)
	and #f3	; clear vertical movement
	or #08
	ld (hl),a

	; change animation frame
	ld hl,player_desired_frame
	ld a,(hl)
	add a,-8
	ld (hl),a

	ld hl,player_y
	ld a,(hl)
	cp 166
	ret z
	inc (hl)
	ld hl,player_y2
	inc (hl)
	ret


;-----------------------------------------------
; input:
; - c: strength of the hit
; output:
; - a: damage dealt to the collider
update_player_collision:
	ld hl,player_state
	ld a,(hl)
	cp PLAYER_STATE_EXPLOSION
	jr z,update_player_collision_already_exploding
	ld hl,player_shield_level
	ld a,(hl)
	ld b,a
	inc b	; this is the damage that we will deal back
	sub c
	jp p,update_player_collision_survived
	ld (hl),0
	ld hl,player_state
	ld (hl),PLAYER_STATE_EXPLOSION
	inc hl	; player_state_timer
	ld (hl),0
	ld hl,SFX_big_explosion
	call play_SFX_with_high_priority
	ld a,b
    ret

update_player_collision_survived:
	; update shied strength:
	ld (hl),a
	; make sure we can select the shield again:
	xor a
	ld (ingame_weapon_current_level+6),a	; NOTE: this assumes shield is ALWAYS in the second to last slot
	push bc
	push ix
		call update_scoreboard_weapon_selection
	pop ix
	pop bc
	ld a,b	; damage reflected
	ret

update_player_collision_already_exploding:
	xor a
	ret


;-----------------------------------------------
select_weapon_sfx:
	call select_weapon_silent
	ret z
	ld hl,SFX_weapon_select
	jp play_SFX_with_high_priority


;-----------------------------------------------
; z: if no selection
; nz: if selection
select_weapon_silent:
	ld a,(ingame_weapon_current_selection)
	cp #ff
	ret z

	ld hl,ingame_weapon_max_level
	ld b,0
	ld c,a
	add hl,bc
	ex de,hl
	ld hl,ingame_weapon_current_level
	add hl,bc
	ld a,(de)
	cp (hl)
	ret z

	; weapon selected!!
	inc (hl)
	push hl
		; actually select the weapon:
		ld a,(ingame_weapon_current_selection)
		ld hl,global_state_weapon_configuration
		ADD_HL_A
		ld a,(hl)	; weapon ID
	pop hl
	ld c,(hl)	; weapon level
	call level_up_weapon

	; update scoreboard:
	ld a,#ff
	ld (ingame_weapon_current_selection),a
	call update_scoreboard_weapon_selection
	or 1
	ret


;-----------------------------------------------
; a: weapon to level up
; c: weapon level
level_up_weapon:
	; I do "cp" instead of "dec a", as it is convenient to preserve "a":
	cp WEAPON_SPEED
	jp z,level_up_speed
	cp WEAPON_TRANSFER
	jp z,level_up_transfer
	cp WEAPON_BULLET
	jp z,level_up_bullet
	cp WEAPON_TWIN_BULLET
	jp z,level_up_twin_bullet
	cp WEAPON_TRIPLE_BULLET
	jp z,level_up_triple_bullet
	cp WEAPON_SHIELD
	jp z,level_up_shield
	cp WEAPON_L_TORPEDOES
	jp z,level_up_l_torpedoes
	cp WEAPON_H_TORPEDOES
	jp z,level_up_h_torpedoes
	cp WEAPON_UP_MISSILES
	jp z,level_up_missiles
	cp WEAPON_DOWN_MISSILES
	jp z,level_up_missiles
	cp WEAPON_BIDIRECTIONAL_MISSILES
	jp z,level_up_missiles
	cp WEAPON_LASER
	jp z,level_up_laser
	cp WEAPON_TWISTER_LASER
	jp z,level_up_twister_laser
	cp WEAPON_FLAME
	jp z,level_up_flame
	cp WEAPON_BULLET_OPTION
	jp z,level_up_bullet_option
	cp WEAPON_MISSILE_OPTION
	jp z,level_up_missile_option
	cp WEAPON_DIRECTIONAL_OPTION
	jp z,level_up_directional_option
	ret


; this is called when the weapon to level up is different from the current one
; we need to clear the level of the previous weapon, and trigger loading the tiles
; for the new weapon
; return:
; - c: level of the weapon after change
level_up_weapon_change:
	push af
	push hl
		ld a,(player_primary_weapon_idx)
		or a
		jr z,level_up_weapon_change_no_previous
		ld hl,ingame_weapon_current_level
		ADD_HL_A
		ld (hl),0	; clear the level of the previous weapon
level_up_weapon_change_no_previous:

		ld a,(ingame_weapon_current_selection)
		ld (player_primary_weapon_idx),a
		ld b,0
		ld c,a		

	    ld a,(global_state_weapon_upgrade_level+WEAPON_LEVEL_UP_START)
	    or a
		jr z,level_up_weapon_change_no_level_up_start

		; start with a higher level of the weapon:
		inc a
		; 1) get max weapon level ingame_weapon_max_level
		ld hl,ingame_weapon_max_level
		add hl,bc
		; 2) determine starting level min(global_state_weapon_upgrade_level+1,ingame_weapon_max_level)
		cp (hl)
		jr c,level_up_weapon_change_level_up_start_ok
		ld a,(hl)
level_up_weapon_change_level_up_start_ok:
		; 3) set the new level to ingame_weapon_current_level
		ld hl,ingame_weapon_current_level
		add hl,bc
		ld (hl),a
		ld c,a

level_up_weapon_change_continue:
		; signal to change the graphics:
		ld a,1
		ld (player_weapon_change_signal),a
	pop hl
	pop af
	ret

level_up_weapon_change_no_level_up_start:
		ld c,1
		jr level_up_weapon_change_continue


level_up_secondary_weapon_change:
	push af
	push hl
		ld a,(player_secondary_weapon_idx)
		or a
		jr z,level_up_secondary_weapon_change_no_previous
		ld hl,ingame_weapon_current_level
		ADD_HL_A
		ld (hl),0	; clear the level of the previous secondary weapon
level_up_secondary_weapon_change_no_previous:

		ld a,(ingame_weapon_current_selection)
		ld (player_secondary_weapon_idx),a
	pop hl
	pop af
	ret


level_up_option_weapon_change:
	push af
	push hl
		ld a,(player_option_weapon_idx)
		or a
		jr z,level_up_option_weapon_change_no_previous
		ld hl,ingame_weapon_current_level
		ADD_HL_A
		ld (hl),0	; clear the level of the previous secondary weapon
level_up_option_weapon_change_no_previous:
	
		ld a,(ingame_weapon_current_selection)
		ld (player_option_weapon_idx),a
	pop hl
	pop af
	ret


level_up_speed:
	ld a,c
	ld hl,speed_up_levels
	ADD_HL_A
	ld a,(hl)
	ld (player_speed_level),a
	ret


level_up_transfer:
	ld a,(global_state_weapon_upgrade_level+WEAPON_TRANSFER)
	dec a
	ld a,c
	jr z,level_up_transfer_level1
	add a,a	; transfer leveled up, credits count double!
level_up_transfer_level1:
	ld (player_credits),a
	jp update_scoreboard_credits


level_up_bullet:
	ld hl,weapon_tiles_bullet_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
 	ld a,c
 	ld (player_primary_weapon_level),a

 	cp 3
 	jr z,level_up_bullet_max_level
	ld a,BULLET_DAMAGE
	jr level_up_bullet_damage_set
level_up_bullet_max_level:
	ld a,BULLET_DAMAGE_MAX
level_up_bullet_damage_set: 	
	ld (player_primary_weapon_damage),a	

 	ld hl,weapon_bullet_cadence-1	; -1 since we want level 1 to index the first position
level_up_twin_bullet_entry_point:
level_up_triple_bullet_entry_point:
 	ld b,0
 	add hl,bc
 	ld a,(hl)
 	ld (player_primary_weapon_cooldown),a
	ret


level_up_twin_bullet:
	ld hl,weapon_tiles_bullet_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
	ld a,c
	ld (player_primary_weapon_level),a

;  	cp 3
;  	jr z,level_up_twin_bullet_max_level
	ld a,BULLET_DAMAGE
; 	jr level_up_twin_bullet_damage_set
; level_up_twin_bullet_max_level:
; 	ld a,BULLET_DAMAGE_MAX
; level_up_twin_bullet_damage_set: 	
	ld (player_primary_weapon_damage),a	

	ld hl,weapon_twin_bullet_cadence-1	; -1 since we want level 1 to index the first position
	jr level_up_twin_bullet_entry_point


level_up_triple_bullet:
	ld hl,weapon_tiles_bullet_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
	ld a,c
	ld (player_primary_weapon_level),a

 	cp 3
 	jr z,level_up_triple_bullet_max_level
	ld a,BULLET_DAMAGE
	jr level_up_triple_bullet_damage_set
level_up_triple_bullet_max_level:
	ld a,BULLET_DAMAGE_MAX
level_up_triple_bullet_damage_set: 	
	ld (player_primary_weapon_damage),a	

	ld hl,weapon_triple_bullet_cadence-1	; -1 since we want level 1 to index the first position
	jr level_up_triple_bullet_entry_point


level_up_shield:
	ld a,(global_state_weapon_upgrade_level+WEAPON_SHIELD)
	add a,a
	inc a	; level 1 -> 3, level 2 -> 5 
	ld (player_shield_level),a
	ret


level_up_l_torpedoes:
	ld hl,player_secondary_weapon
	cp (hl)
	call nz,level_up_secondary_weapon_change
	ld (hl),a
	ld a,c
	ld (player_secondary_weapon_level),a
	ld hl,torpedo_light_cadence-1	; -1 since we want level 1 to index the first position
 	ld b,0
 	add hl,bc
	ld a,(hl)
	ld (player_secondary_weapon_cooldown),a
	ret


level_up_h_torpedoes:
	ld hl,player_secondary_weapon
	cp (hl)
	call nz,level_up_secondary_weapon_change
	ld (hl),a
	ld a,c
	ld (player_secondary_weapon_level),a
	ld hl,torpedo_heavy_cadence-1	; -1 since we want level 1 to index the first position
 	ld b,0
 	add hl,bc
	ld a,(hl)
	ld (player_secondary_weapon_cooldown),a
	ret


level_up_missiles:
	ld hl,player_secondary_weapon
	cp (hl)
	call nz,level_up_secondary_weapon_change
	ld (hl),a
	ld a,c
	ld (player_secondary_weapon_level),a
	ld hl,missiles_cadence-1	; -1 since we want level 1 to index the first position
 	ld b,0
 	add hl,bc
	ld a,(hl)
	ld (player_secondary_weapon_cooldown),a
	ret


level_up_laser:
	ld hl,weapon_tiles_laser_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
 	ld a,c
 	ld (player_primary_weapon_level),a

 	cp 3
 	jr z,level_up_laser_max_level
	ld a,LASER_DAMAGE
	jr level_up_laser_damage_set
level_up_laser_max_level:
	ld a,LASER_DAMAGE_MAX
level_up_laser_damage_set: 	
	ld (player_primary_weapon_damage),a	

	ld hl,weapon_laser_cadence-1	; -1 since we want level 1 to index the first position
 	ld b,0
 	add hl,bc
	ld a,(hl)
	ld (player_primary_weapon_cooldown),a
	ret


level_up_twister_laser:
	ld hl,weapon_tiles_twister_laser_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
 	ld a,c
 	ld (player_primary_weapon_level),a

 	cp 3
 	jr z,level_up_twister_laser_max_level
	ld a,TWISTER_LASER_DAMAGE
	jr level_up_twister_laser_damage_set
level_up_twister_laser_max_level:
	ld a,TWISTER_LASER_DAMAGE_MAX
level_up_twister_laser_damage_set: 	
	ld (player_primary_weapon_damage),a	

	ld hl,weapon_twister_laser_cadence-1	; -1 since we want level 1 to index the first position
 	ld b,0
 	add hl,bc
	ld a,(hl)
	ld (player_primary_weapon_cooldown),a
	ret

level_up_flame:
	ld hl,weapon_tiles_flame_plt
	ld (player_weapon_change_ptr),hl
	ld hl,player_primary_weapon
	cp (hl)
	call nz,level_up_weapon_change
	ld (hl),a
 	ld a,c
 	ld (player_primary_weapon_level),a

 	cp 3
 	jr z,level_up_flame_max_level
	ld a,FLAME_DAMAGE
	jr level_up_flame_damage_set
level_up_flame_max_level:
	ld a,FLAME_DAMAGE_MAX
level_up_flame_damage_set: 	
	ld (player_primary_weapon_damage),a	

	ld hl,weapon_flame_cadence-1	; -1 since we want level 1 to index the first position
	ld b,0
	add hl,bc
	ld a,(hl)
	ld (player_primary_weapon_cooldown),a
	ret


level_up_directional_option:
level_up_bullet_option:
	ld hl,player_option_weapon
	cp (hl)
	call nz,level_up_option_weapon_change
	ld (hl),a
	ld a,c
	ld (player_option_weapon_level),a
	ld hl,bullet_option_cadence-1	; -1 since we want level 1 to index the first position
	ld b,0
	add hl,bc
	ld a,(hl)
	ld (player_option_weapon_cooldown),a
	ret


level_up_missile_option:
	ld hl,player_option_weapon
	cp (hl)
	call nz,level_up_option_weapon_change
	ld (hl),a
	ld a,c
	ld (player_option_weapon_level),a
	ld hl,missile_option_cadence-1	; -1 since we want level 1 to index the first position
	ld b,0
	add hl,bc
	ld a,(hl)
	ld (player_option_weapon_cooldown),a
	ret


;-----------------------------------------------
check_power_pellet_pickup:
	ld a,(player_tile_y)
	ld e,a
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	ld h,0
	ld a,(player_tile_x)
	ld l,a
	add hl,de
	ld a,(player_tile_y)
	cp 8
	ld a,(hl)	; tile under player
	jp m,check_power_pellet_pickup_bank0
	ld hl,power_pellet_types_bank1
	jp check_power_pellet_pickup_bank_set
check_power_pellet_pickup_bank0:
	ld hl,power_pellet_types_bank0
check_power_pellet_pickup_bank_set:
	cpi
	jp z,power_pellet_pickup
	cpi
	jp z,power_pellet_pickup
	cpi
	jp z,power_pellet_pickup
	ret
