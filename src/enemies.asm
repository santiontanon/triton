;-----------------------------------------------
; updates the behavior of all the enemies, and also updates their sprites
update_enemies:
	ld ix,enemies
	ld b,MAX_ENEMIES
update_enemies_loop:
	ld a,(ix)
	and #7f	; we remove the power pellet bit
	jp z,update_enemies_loop_next_no_pop
	push bc
		dec a
		jp z,update_enemy_explosion		; ENEMY_EXPLOSION
		dec a
		jp z,update_enemy_trilo		; ENEMY_TRILO
		dec a
		jp z,update_enemy_fish		; ENEMY_FISH
		dec a
		jp z,update_enemy_ufo		; ENEMY_UFO
		dec a
		jp z,update_enemy_walker		; ENEMY_WALKER
		dec a
		jp z,update_enemy_falling_rock		; ENEMY_FALLING_ROCK
		;dec a
		;jp z,update_enemy_face		; ENEMY_FACE
		jp update_enemy_face		; ENEMY_FACE
		; ...
update_enemies_loop_next:
	pop bc
update_enemies_loop_next_no_pop:		
	ld de,ENEMY_STRUCT_SIZE
	add ix,de
	djnz update_enemies_loop
	ret


;-----------------------------------------------
update_enemy_hit_player:
	ld c,(ix+ENEMY_STRUCT_HP)
	push ix
		call update_player_collision
	pop ix

; a: damage dealt
update_enemy_hit:	
	call update_enemy_hit_internal
	ret nz
	pop af	; simulate a ret
	jp update_enemies_loop_next

; a: damage dealt
; returns:
; - z: enemy dead
; - nz: enemy still alive
update_enemy_hit_internal:
	push af
		ld hl,SFX_enemy_hit
		call play_SFX_with_high_priority
	pop af
	ld b,a
	ld a,(ix+ENEMY_STRUCT_HP)
	sub b
	ld (ix+ENEMY_STRUCT_HP),a
	cp 1
	jp m,update_enemy_hit_internal_enemy_dead
	or 1
	ret

update_enemy_hit_internal_enemy_dead:
	; enemy is dead:
	bit 7,(ix+ENEMY_STRUCT_TYPE)
	jp z,update_enemy_hit_no_power_pellet

	ld c,(ix+ENEMY_STRUCT_TILE_X)
	ld a,(ix+ENEMY_STRUCT_Y)
	add a,4
	ld b,a	; center the pellet in the y axis
	srl b
	srl b
	srl b
	call spawn_power_pellet

update_enemy_hit_no_power_pellet:
	ld (ix+ENEMY_STRUCT_TYPE),ENEMY_EXPLOSION
	ld (ix+ENEMY_STRUCT_STATE),0
	ld (ix+ENEMY_STRUCT_TIMER),3
	xor 0
	ret


;-----------------------------------------------
update_enemy_explosion:
	dec (ix+ENEMY_STRUCT_TIMER)
	jp nz,update_enemy_explosion_sprite
	ld (ix+ENEMY_STRUCT_TIMER),3
	inc (ix+ENEMY_STRUCT_STATE)
	ld a,(ix+ENEMY_STRUCT_STATE)
	cp 5
	jp z,update_enemy_disappears_compute_sprite_ptr
update_enemy_explosion_sprite:
	ld a,(ix+ENEMY_STRUCT_STATE)
	add a,a
	add a,a
	add a,ENEMY_SPRITE_EXPLOSION
	ld e,a
	ld d,COLOR_WHITE
	jp update_enemy_draw_sprite	


;-----------------------------------------------
check_enemy_to_player_collision:
	ld a,(player_state)
	cp PLAYER_STATE_DEFAULT
	ret nz
	ld hl,scroll_x_tile
	ld a,(ix+ENEMY_STRUCT_TILE_X)
	sub (hl)
	ret m
	cp 31
	ret p
	add a,a
	add a,a
	add a,a
	add a,(ix+ENEMY_STRUCT_X)
	ld c,a
	ld b,(ix+ENEMY_STRUCT_Y)
	call collision_with_player_large
	jp z,update_enemy_hit_player
	ret


;-----------------------------------------------
update_enemy_trilo:
	; collision with player:
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

	; update movement:
	ld hl,difficulty_enemy_speed
	ld d,(hl)
update_enemy_trilo_loop:
	ld a,(ix+ENEMY_STRUCT_STATE)
	or a
	jp nz,update_enemy_trilo_state1
update_enemy_trilo_state0:
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	bit 1,a
	call z,enemy_move_right
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 16
	jp nz,update_enemy_trilo_movement_done
	ld (ix+ENEMY_STRUCT_STATE),4
	ld (ix+ENEMY_STRUCT_TIMER),0
	jp update_enemy_trilo_movement_done
update_enemy_trilo_state1:
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 8
	call m,enemy_move_left
	call enemy_move_left
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 32
	jp nz,update_enemy_trilo_movement_done
	ld (ix+ENEMY_STRUCT_STATE),0
	ld (ix+ENEMY_STRUCT_TIMER),0
update_enemy_trilo_movement_done:
	ld a,(scroll_x_half_pixel)
	bit 1,a
	jr z,update_enemy_trilo_loop_done
	dec d
	jp nz,update_enemy_trilo_loop
update_enemy_trilo_loop_done:

	; this one is special, as it folow "difficulty_sprite_fire_rate_none" instead of "difficulty_sprite_fire_rate_slow"
	JP_IF_RANDOM_GEQ difficulty_sprite_fire_rate_none,update_enemy_trilo_sprites
	call update_enemy_fire_bullet_check_fire_bullet

update_enemy_trilo_sprites:
	ld a,(ix+ENEMY_STRUCT_STATE)
	add a,ENEMY_SPRITE_TRILO
	ld e,a
	ld d,ENEMY_COLOR_TRILO
	jp update_enemy_draw_sprite


update_enemy_fire_bullet_check:
	RET_IF_RANDOM_GEQ difficulty_sprite_fire_rate_slow
update_enemy_fire_bullet_check_fire_bullet:
	; fire a bullet:
	ld a,(ix+ENEMY_STRUCT_TILE_X)
	ld hl,scroll_x_tile
	sub (hl)
	ret m
	cp 30
	ret p
	add a,a
	add a,a
	add a,a
	add a,(ix+ENEMY_STRUCT_X)
	ld c,a
	ld a,(ix+ENEMY_STRUCT_Y)
	add a,6
	ld b,a
	jp enemy_fire_bullet


;-----------------------------------------------
update_enemy_fish:
	; collision with player:
	ld a,(ix+ENEMY_STRUCT_Y)
	cp 22*8
	jp nc,update_enemy_fish_no_collision_check
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

update_enemy_fish_no_collision_check:
	ld hl,difficulty_enemy_speed
	ld d,(hl)
update_enemy_fish_loop:

	ld a,(ix+ENEMY_STRUCT_MOVEMENT_TYPE)
	or a ; MOVEMENT_FISH_WAVE
	jp z,update_enemy_fish_wave
	dec a ; MOVEMENT_FISH_FOLLOW
	jp z,update_enemy_fish_follow
	dec a ; MOVEMENT_FISH_TOP_FIRE
	jp z,update_enemy_fish_top_fire

	; MOVEMENT_FISH_BOTTOM_FIRE:
update_enemy_fish_bottom_fire:
	call enemy_move_left
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 96
	jp nc,update_enemy_fish_bottom_fire_state3
	cp 48
	jp nc,update_enemy_fish_bottom_fire_state2
update_enemy_fish_bottom_fire_state1:
	call enemy_move_up
	ld e,ENEMY_SPRITE_FISH+4
	jp update_enemy_fish_movement_done
update_enemy_fish_bottom_fire_state2:
	ld e,ENEMY_SPRITE_FISH
	sub 72
	jp nz,update_enemy_fish_movement_done
	ld a,d
	dec a	; if cycle == 72 and d == 1 (last movement cycle), fire!
	jp nz,update_enemy_fish_movement_done
	call update_enemy_fire_bullet_check_fire_bullet
	jp update_enemy_fish_sprites
update_enemy_fish_bottom_fire_state3:
	call enemy_move_down
	ld e,ENEMY_SPRITE_FISH+8
	jp update_enemy_fish_movement_done

	; MOVEMENT_FISH_TOP_FIRE:
update_enemy_fish_top_fire:
	call enemy_move_left
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 96
	jp nc,update_enemy_fish_top_fire_state3
	cp 48
	jp nc,update_enemy_fish_top_fire_state2
update_enemy_fish_top_fire_state1:
	call enemy_move_down
	ld e,ENEMY_SPRITE_FISH+8
	jp update_enemy_fish_movement_done
update_enemy_fish_top_fire_state2:
	ld e,ENEMY_SPRITE_FISH
	sub 72
	jp nz,update_enemy_fish_movement_done
	ld a,d
	dec a	; if cycle == 72 and d == 1 (last movement cycle), fire!
	jp nz,update_enemy_fish_movement_done
	call update_enemy_fire_bullet_check_fire_bullet
	jp update_enemy_fish_sprites
update_enemy_fish_top_fire_state3:
	call enemy_move_up
	ld e,ENEMY_SPRITE_FISH+4
	jp update_enemy_fish_movement_done


update_enemy_fish_follow:
	call enemy_move_left
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	and #07
	jp nz,update_enemy_fish_follow_do_not_reconsider

	; reconsider the decision:
	ld (ix+ENEMY_STRUCT_STATE),0
	ld a,(player_y)
	sub (ix+ENEMY_STRUCT_Y)
	cp 6
	jp m,update_enemy_fish_no_down
	ld (ix+ENEMY_STRUCT_STATE),1
	jp update_enemy_fish_follow_do_not_reconsider
update_enemy_fish_no_down:	
	cp -4
	jp p,update_enemy_fish_no_up
	ld (ix+ENEMY_STRUCT_STATE),2
update_enemy_fish_no_up:
update_enemy_fish_follow_do_not_reconsider:

	; execute the decision:
	ld e,ENEMY_SPRITE_FISH
	ld a,(ix+ENEMY_STRUCT_STATE)
	or a
	jr z,update_enemy_fish_movement_done
	dec a
	jp nz,update_enemy_fish_move_up
update_enemy_fish_move_down:
	call enemy_move_down
	ld e,ENEMY_SPRITE_FISH+8
	jr update_enemy_fish_movement_done
update_enemy_fish_move_up:
	call enemy_move_up
	ld e,ENEMY_SPRITE_FISH+4

update_enemy_fish_movement_done:
	ld a,(scroll_x_half_pixel)
	bit 1,a
	jr z,update_enemy_fish_loop_done
	dec d
	jp nz,update_enemy_fish_loop
update_enemy_fish_loop_done:
	call update_enemy_fire_bullet_check

update_enemy_fish_sprites:
	ld d,ENEMY_COLOR_FISH
	jp update_enemy_draw_sprite	


update_enemy_fish_wave:
	call enemy_move_left
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	srl a
	srl a
	and #0f
	ld hl,waving_pattern_y_increments
	ADD_HL_A
	ld a,(hl)
	ld e,ENEMY_SPRITE_FISH
	cp 2
	jp p,update_enemy_fish_wave_down
	cp -1
	jp m,update_enemy_fish_wave_up
update_enemy_fish_wave_sprite_set:
	add a,(ix+ENEMY_STRUCT_Y)
	ld (ix+ENEMY_STRUCT_Y),a
	jr update_enemy_fish_movement_done

update_enemy_fish_wave_down:
	ld e,ENEMY_SPRITE_FISH+8
	jp update_enemy_fish_wave_sprite_set

update_enemy_fish_wave_up:
	ld e,ENEMY_SPRITE_FISH+4
	jp update_enemy_fish_wave_sprite_set



;-----------------------------------------------
update_enemy_ufo:
	; collision with player:
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

	; update movement:
	ld hl,difficulty_enemy_speed
	ld d,(hl)
update_enemy_ufo_loop:
	inc (ix+ENEMY_STRUCT_TIMER)

	ld a,(ix+ENEMY_STRUCT_MOVEMENT_TYPE)
	or a ; MOVEMENT_UFO_H
	jr z,update_enemy_ufo_h
	dec a ; MOVEMENT_UFO_REVERSE_H
	jr z,update_enemy_ufo_reverse_h
	dec a ; MOVEMENT_UFO_GENERATE_TOP
	jr z,update_enemy_ufo_generate_top
	; MOVEMENT_UFO_GENERATE_BOT

update_enemy_ufo_generate_bot:
	call enemy_move_up
update_enemy_ufo_generate_bot_continue:
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 24
	jp m,update_enemy_ufo_movement_done
	ld (ix+ENEMY_STRUCT_MOVEMENT_TYPE),MOVEMENT_UFO_H
	jr update_enemy_ufo_movement_done

update_enemy_ufo_reverse_h:
	call enemy_move_right
	ld a,d
	dec a
	call z,enemy_move_right	; this last move is only to compensate for scroll speed
	jr update_enemy_ufo_movement_done

update_enemy_ufo_h:
	call enemy_move_left
	jr update_enemy_ufo_movement_done

update_enemy_ufo_generate_top:
	call enemy_move_down
	jr update_enemy_ufo_generate_bot_continue

update_enemy_ufo_movement_done:
	ld a,(scroll_x_half_pixel)
	bit 1,a
	jr z,update_enemy_ufo_loop_done
	dec d
	jp nz,update_enemy_ufo_loop
update_enemy_ufo_loop_done:

	call update_enemy_fire_bullet_check

update_enemy_ufo_sprites:
	ld a,(ix+ENEMY_STRUCT_TIMER)
	add a,(ix+ENEMY_STRUCT_TILE_X)
	and #0c
	cp #0c
	jr nz,update_enemy_ufo_sprites_continue
	ld a,#04
update_enemy_ufo_sprites_continue:
	add a,ENEMY_SPRITE_UFO
	ld e,a
	ld d,ENEMY_COLOR_UFO
	jp update_enemy_draw_sprite


;-----------------------------------------------
update_enemy_walker:
	; collision with player:
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

	ld a,(ix+ENEMY_STRUCT_STATE)
	or a
	jp nz,update_enemy_walker_fire_state

	; update movement:
	ld hl,difficulty_enemy_speed
	ld d,(hl)
update_enemy_walker_loop:
	inc (ix+ENEMY_STRUCT_TIMER)

	ld a,(ix+ENEMY_STRUCT_MOVEMENT_TYPE)
	or a ; MOVEMENT_WALKER_LEFT
	jp z,update_enemy_walker_left

update_enemy_walker_right:
	; check collisions!
	push de
		ld c,(ix+ENEMY_STRUCT_TILE_X)
		inc c
		inc c
		ld a,(ix+ENEMY_STRUCT_Y)
		add a,16
	    rrca
	    rrca
	    rrca
	    and 31
		ld b,a
		call collisionWithMap
	pop de
	jr z,update_enemy_walker_switch_to_left

	ld e,ENEMY_SPRITE_WALKER_RIGHT	
	call enemy_move_right
	ld a,d
	dec a
	call z,enemy_move_right	; this last move is only to compensate for scroll speed
	jp update_enemy_walker_movement_done

update_enemy_walker_left:
	; check collisions!
	push de
		ld c,(ix+ENEMY_STRUCT_TILE_X)
		dec c
		ld a,(ix+ENEMY_STRUCT_Y)
		add a,16
	    rrca
	    rrca
	    rrca
	    and 31
		ld b,a
		call collisionWithMap
	pop de
	jr z,update_enemy_walker_switch_to_right	

	ld e,ENEMY_SPRITE_WALKER_LEFT
	call enemy_move_left

update_enemy_walker_movement_done:
	ld a,(scroll_x_half_pixel)
	bit 1,a
	jr z,update_enemy_walker_loop_done	
	dec d
	jp nz,update_enemy_walker_loop
update_enemy_walker_loop_done:

	ld a,(ix+ENEMY_STRUCT_TIMER)
	and #03
	jr nz,update_enemy_walker_sprites

	; chance to stop and fire:
	JP_IF_RANDOM_GEQ difficulty_fire_rate_fast, update_enemy_walker_sprites 
	ld (ix+ENEMY_STRUCT_TIMER),0
	inc (ix+ENEMY_STRUCT_STATE)

update_enemy_walker_sprites:
	ld a,(ix+ENEMY_STRUCT_TIMER)
	and #0c
	cp #0c
	jp nz,update_enemy_walker_sprites_continue
	ld a,#04
update_enemy_walker_sprites_continue:
	add a,e
	ld e,a
update_enemy_walker_sprites_continue2:
	ld d,ENEMY_COLOR_WALKER
	jp update_enemy_draw_sprite

update_enemy_walker_switch_to_left:
	ld (ix+ENEMY_STRUCT_MOVEMENT_TYPE),0
	jr update_enemy_walker_movement_done

update_enemy_walker_switch_to_right:
	ld (ix+ENEMY_STRUCT_MOVEMENT_TYPE),1
	jr update_enemy_walker_movement_done

update_enemy_walker_fire_state:
	ld e,ENEMY_SPRITE_WALKER_STOP
	inc (ix+ENEMY_STRUCT_TIMER)
	ld a,(ix+ENEMY_STRUCT_TIMER)
	cp 16
	jr nz,update_enemy_walker_sprites_continue2

	; fire!
	call update_enemy_fire_bullet_check_fire_bullet

	ld (ix+ENEMY_STRUCT_TIMER),0
	dec (ix+ENEMY_STRUCT_STATE)
	jr update_enemy_walker_sprites_continue2


;-----------------------------------------------
update_enemy_falling_rock:
	ld a,(ix+ENEMY_STRUCT_Y)
	cp 22*8
	jp z,update_enemy_disappears_compute_sprite_ptr
	jr nc,update_enemy_falling_rock_no_collisions
	; collision with player:
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

update_enemy_falling_rock_no_collisions:
	ld hl,difficulty_enemy_speed
	ld d,(hl)	
update_enemy_falling_rock_nmove_loop:	
	call enemy_move_down
	call enemy_move_down	
	dec d
	jr nz,update_enemy_falling_rock_nmove_loop

	ld a,(ix+ENEMY_STRUCT_Y)
	srl a
	and #0c
	add a,ENEMY_SPRITE_FALLING_ROCK
	ld e,a
	ld d,ENEMY_COLOR_FALLING_ROCK
	jp update_enemy_draw_sprite


;-----------------------------------------------
update_enemy_face:
	; collision with player:
	call check_enemy_to_player_collision

	; collision with player bullet:
	call collision_enemy_to_player_bullet	; a will have "damage" as a side effect
	call z,update_enemy_hit

	inc (ix+ENEMY_STRUCT_TIMER)

	; update movement (not affected by speed, otherwise, it's crazy!):
	ld a,(player_tile_x)
	cp (ix+ENEMY_STRUCT_TILE_X)
	push af
		call p,enemy_move_right
	pop af
	push af
		call p,enemy_move_right
	pop af
	call m,enemy_move_left

	ld a,(player_y)
	cp (ix+ENEMY_STRUCT_Y)
	push af
		call p,enemy_move_down
	pop af
	call m,enemy_move_up

	JP_IF_RANDOM_GEQ difficulty_sprite_fire_rate_slow,update_enemy_face_sprites
	call update_enemy_fire_bullet_check_fire_bullet

update_enemy_face_sprites:
	ld a,(ix+ENEMY_STRUCT_TIMER)
	srl a
	and #04
	ld b,a
	ld a,(player_tile_x)
	cp (ix+ENEMY_STRUCT_TILE_X)
	jp m,update_enemy_face_sprites_right
	ld a,ENEMY_SPRITE_FACE+8
	jr update_enemy_face_sprites_set
update_enemy_face_sprites_right:
	ld a,ENEMY_SPRITE_FACE
update_enemy_face_sprites_set:
	add a,b
	ld e,a
	ld d,ENEMY_COLOR_FACE
	jp update_enemy_draw_sprite


;-----------------------------------------------
; input:
; - ix: enemy struct pointer
; - e: sprite index
; - d: sprite color
update_enemy_draw_sprite:
	ld a,(ix+ENEMY_STRUCT_TYPE)
	and #80
	jp z,update_enemy_draw_sprite_no_power_pellet
	ld d,COLOR_RED	; enemies dropping power pellet are drawn in red color
update_enemy_draw_sprite_no_power_pellet:
	; update sprite:
	ld hl,enemy_sprite_attributes
	ld a,(ix+ENEMY_STRUCT_SPRITE_IDX)
	ADD_HL_A
	ld a,(ix+ENEMY_STRUCT_Y)
	ld (hl),a
	ld a,(scroll_x_tile)
	ld c,a
	ld a,(scroll_x_half_pixel)
	srl a
	ld b,a
	ld a,(ix+ENEMY_STRUCT_TILE_X)
	sub c
	cp 36
	jp p,update_enemy_disappears
	cp 33
	jp p,update_enemy_clear_sprite
	cp -2
	jp m,update_enemy_disappears
	cp 4
	jp m,update_enemy_draw_sprites_early_clock
	add a,a
	add a,a
	add a,a
	add a,(ix+ENEMY_STRUCT_X)
	sub b
	cp 16
	jp c,update_enemy_clear_sprite
	inc hl
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	jp update_enemies_loop_next

update_enemy_draw_sprites_early_clock:
	add a,4	
	add a,a
	add a,a
	add a,a
	add a,(ix+ENEMY_STRUCT_X)
	sub b
	jp m,update_enemy_clear_sprite
	inc hl
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld a,d
	or #80
	ld (hl),a
	jp update_enemies_loop_next


;-----------------------------------------------
; input:
; - ix: pointer to the enemy struct
; - hl: pointer to the sprite attributes of the enemy
update_enemy_disappears_compute_sprite_ptr:
	ld hl,enemy_sprite_attributes
	ld a,(ix+ENEMY_STRUCT_SPRITE_IDX)
	ADD_HL_A	
update_enemy_disappears:
	ld (ix+ENEMY_STRUCT_TYPE),0
update_enemy_clear_sprite:
	ld (hl),200
	jp update_enemies_loop_next


;-----------------------------------------------
enemy_move_right:
	ld a,(ix+ENEMY_STRUCT_X)
	inc a
	cp 8
	jp nz,enemy_move_right_no_tile_change
	inc (ix+ENEMY_STRUCT_TILE_X)
	xor a
enemy_move_right_no_tile_change:
	ld (ix+ENEMY_STRUCT_X),a
	ret


;-----------------------------------------------
enemy_move_left:
	ld a,(ix+ENEMY_STRUCT_X)
	dec a
	jp p,enemy_move_left_no_tile_change
	dec (ix+ENEMY_STRUCT_TILE_X)
	ld a,7
enemy_move_left_no_tile_change:
	ld (ix+ENEMY_STRUCT_X),a
	ret


;-----------------------------------------------
enemy_move_up:
	dec (ix+ENEMY_STRUCT_Y)
	ret


;-----------------------------------------------
enemy_move_down:
	inc (ix+ENEMY_STRUCT_Y)
	ret


;-----------------------------------------------
; input:
; - hl: pointer to the wave type to spawn
spawn_enemy_wave:
	push hl
	pop ix
	ld c,0	; time to spawn
	ld b,(ix+2)	; spawn interval
	ld de,3
	add ix,de
spawn_enemy_wave_loop:
	ld a,(ix)
	cp #ff
	ret z

	; add an enemy spawn record:
	ld de,(enemy_spawn_queue_next_to_push)
	push hl
		ld a,c
		ld (de),a	; time to spawn
		inc de
		ld c,b	; we store time to spawn + spawn interval again
		push bc
			ldi
			ldi
		pop bc
	pop hl
	ld a,(ix)
	ld (de),a	; x
	inc de
	ld a,(ix+1)
	ld (de),a	; y
	inc de

	ld a,d
	cp enemy_spawn_queue_end/256
	jr nz,spawn_enemy_wave_next_ptr
	ld a,e
	cp enemy_spawn_queue_end%256
	jr nz,spawn_enemy_wave_next_ptr
	ld de,enemy_spawn_queue
spawn_enemy_wave_next_ptr:	
	ld (enemy_spawn_queue_next_to_push),de

	inc ix
	inc ix
	jp spawn_enemy_wave_loop


;-----------------------------------------------
check_for_enemies_to_spawn:
	ld hl,(enemy_spawn_queue_next_to_pop)
	ld a,(hl)
	cp #ff
	ret z
	or a
	jp z,check_for_enemies_to_spawn_spawn
	; decrease the timer:
	ld a,(difficulty_enemy_speed)
	ld b,a
check_for_enemies_to_spawn_timer_loop:
	dec (hl)
	ret z
	djnz check_for_enemies_to_spawn_timer_loop
	ret
check_for_enemies_to_spawn_spawn:
	ld (hl),#ff	

	call spawn_enemy_from_spawn_record

	ld a,h
	cp enemy_spawn_queue_end/256
	jp nz,check_for_enemies_to_spawn_next_ptr
	ld a,l
	cp enemy_spawn_queue_end%256
	jp nz,check_for_enemies_to_spawn_next_ptr
	ld hl,enemy_spawn_queue
check_for_enemies_to_spawn_next_ptr:	
	ld (enemy_spawn_queue_next_to_pop),hl
	jp check_for_enemies_to_spawn	; check the next enemy (maybe there are two enemies to spawn in a row)


;-----------------------------------------------
; input:
; - hl: pointer to spawn record
; output:
; - hl: next spawn record
; - ix: enemy spawned ptr
; - z: spawned
; - nz: not spawned
spawn_enemy_from_spawn_record:
	; look for an enemy slot:
	ld ix,enemies
	ld de,ENEMY_STRUCT_SIZE
	ld b,MAX_ENEMIES
spawn_enemy_from_spawn_record_find_spot_loop:
	ld a,(ix)
	or a
	jp z,spawn_enemy_from_spawn_record_found_spot
	add ix,de
	djnz spawn_enemy_from_spawn_record_find_spot_loop
	; found no enemy spot! ignore the enemy spawn
	ld de,ENEMY_SPAWN_STRUCT_SIZE
	add hl,de
	or 1	; nz
	ret

spawn_enemy_from_spawn_record_found_spot:
	; create an enemy in ix:
	push ix
	pop de
	inc hl		; skip the time
	ldi			; type
	ldi			; movement type
	ld a,(scroll_x_tile)
	ld c,a
	ld a,(hl)
	add a,c		; we add the scroll tile
	ld (de),a	; tile x
	inc hl
	inc de
	ldi			; y
	xor a
	ld (de),a	; pixel x
	inc de
	inc de		; sprite idx is predefined and doesn't need to change
	ld (de),a	; state
	inc de
	ld (de),a	; timer
	inc de
	ld a,(difficulty_enemy_health_base)
	ld (de),a	; hit points
	ld a,(ix+ENEMY_STRUCT_TYPE)
	cp ENEMY_TRILO	; double HP
	jr z,spawn_enemy_from_spawn_record_2hp
	cp ENEMY_WALKER	; double HP
	jr z,spawn_enemy_from_spawn_record_2hp
	cp ENEMY_FACE	; max HP
	jr z,spawn_enemy_from_spawn_record_maxhp
spawn_enemy_from_spawn_record_hp_set:
	ld a,(ix+ENEMY_STRUCT_TYPE)
	cp ENEMY_WALKER
	jr z,spawn_enemy_from_spawn_check_walker_position
	cp ENEMY_TRILO
	jr z,spawn_enemy_from_spawn_record_high_power_pellet_p
spawn_enemy_from_spawn_record_walker_ok:
	JP_IF_RANDOM_GEQ difficulty_power_spawn_low_p, spawn_enemy_from_spawn_record_drops_power_pellet 
	xor a	; z
	ret

spawn_enemy_from_spawn_record_2hp:
	ld a,(difficulty_enemy_health_med)
	ld (de),a	; hit points
	jr spawn_enemy_from_spawn_record_hp_set

spawn_enemy_from_spawn_record_maxhp:
	ld a,(difficulty_enemy_health_tough)
	ld (de),a	; hit points
	jr spawn_enemy_from_spawn_record_hp_set

spawn_enemy_from_spawn_record_high_power_pellet_p:
	JP_IF_RANDOM_GEQ difficulty_power_spawn_p, spawn_enemy_from_spawn_record_drops_power_pellet 
	xor a	; z
	ret

spawn_enemy_from_spawn_record_drops_power_pellet:
	set 7,(ix+ENEMY_STRUCT_TYPE)
	xor a	; z
	ret

spawn_enemy_from_spawn_check_walker_position:
	push hl
		ld c,(ix+ENEMY_STRUCT_TILE_X)
		inc c
		ld a,(ix+ENEMY_STRUCT_Y)
		add a,8
	    rrca
	    rrca
	    rrca
	    and 31
		ld b,a
		call collisionWithMap
		jr nz,spawn_enemy_from_spawn_check_walker_position_not_ok
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
		call collisionWithMap_internal
		jr z,spawn_enemy_from_spawn_check_walker_position_not_ok
	pop hl
	jr spawn_enemy_from_spawn_record_walker_ok

spawn_enemy_from_spawn_check_walker_position_not_ok:
	pop hl
	ld (ix+ENEMY_STRUCT_TYPE),0
	or 1	; nz
	ret

;-----------------------------------------------
; Since the scroll works on a circular buffer, when the scroll circles back, 
; we need to adjust the coordinates of the enemies, to bring them back to where the viewport is
adjust_enemy_positions_after_scroll_restart:
	ld ix,enemies
	ld b,MAX_ENEMIES
	ld de,ENEMY_STRUCT_SIZE
adjust_enemy_positions_loop:
	ld a,(ix)
	or a
	jp z,adjust_enemy_positions_loop_next
	ld a,(ix+ENEMY_STRUCT_TILE_X)
	sub 64
	ld (ix+ENEMY_STRUCT_TILE_X),a
adjust_enemy_positions_loop_next:
	add ix,de
	djnz adjust_enemy_positions_loop

	ld ix,tile_enemies
	ld b,MAX_TILE_ENEMIES
	ld de,TILE_ENEMY_STRUCT_SIZE
adjust_enemy_positions_loop2:
	ld a,(ix)
	or a
	jp z,adjust_enemy_positions_loop2_next
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	sub 64
	jp m,adjust_enemy_positions_loop2_next
	ld (ix+TILE_ENEMY_STRUCT_X),a
	push bc
		ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
		ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
		ld bc,-64
		add hl,bc
		ld (ix+TILE_ENEMY_STRUCT_PTRL),l
		ld (ix+TILE_ENEMY_STRUCT_PTRH),h
	pop bc
adjust_enemy_positions_loop2_next:
	add ix,de
	djnz adjust_enemy_positions_loop2

	ret

