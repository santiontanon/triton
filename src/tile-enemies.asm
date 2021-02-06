;-----------------------------------------------
; updates the behavior of all the enemies, and also updates their sprites
update_tile_enemies:
	ld ix,tile_enemies
	ld b,MAX_TILE_ENEMIES
update_tile_enemies_loop:
	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
	or a
	jp z,update_tile_enemies_loop_next_no_pop
	; see if they are out of scroll:
	ld a,(scroll_x_tile)
 	sub (ix+TILE_ENEMY_STRUCT_X)
 	jp z,update_tile_enemies_erase

	push bc
	 	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
		dec a
		jr z,update_tile_enemy_turret_top		; TILE_ENEMY_MOAI_G_TURRET_TOP
		dec a
		jr z,update_tile_enemy_turret_top		; TILE_ENEMY_MOAI_R_TURRET_TOP
		dec a
		jp z,update_tile_enemy_turret_bottom	; TILE_ENEMY_MOAI_G_TURRET_BOTTOM
		dec a
		jp z,update_tile_enemy_turret_bottom	; TILE_ENEMY_MOAI_R_TURRET_BOTTOM
		dec a
		jp z,update_tile_enemy_moai_top			; TILE_ENEMY_MOAI_TOP
		dec a
		jp z,update_tile_enemy_moai_bottom		; TILE_ENEMY_MOAI_BOTTOM
		dec a
		jp z,update_tile_enemy_growingwall_top			; TILE_ENEMY_GROWINGWALL_TOP
		dec a
		jp z,update_tile_enemy_growingwall_bottom		; TILE_ENEMY_GROWINGWALL_BOTTOM
		dec a
		jp z,update_tile_enemy_generator_top			; TILE_ENEMY_GENERATOR_TOP
		dec a
		jp z,update_tile_enemy_generator_bottom		; TILE_ENEMY_GENERATOR_BOTTOM
		dec a
		jp z,update_tile_enemy_waterdome		; TILE_ENEMY_WATERDOME
		dec a
		jp z,update_tile_enemy_fallingrocks		; TILE_ENEMY_FALLINGROCKS
		dec a
		jp z,update_tile_enemy_templesnake		; TILE_ENEMY_TEMPLESNAKE
		dec a
		jp z,update_tile_enemy_templecolumn		; TILE_ENEMY_TEMPLECOLUMN

update_tile_enemies_loop_next:
	pop bc
update_tile_enemies_loop_next_no_pop:
	ld de,TILE_ENEMY_STRUCT_SIZE
	add ix,de
	djnz update_tile_enemies_loop
	ret

update_tile_enemies_erase:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),0
	jp update_tile_enemies_loop_next_no_pop


;-----------------------------------------------
update_tile_enemy_turret_top:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_turret_wait_state

	ld hl,(level_type_tile_enemies_bank0)
	call update_tile_enemy_turret_player_angle
	add hl,bc
	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
	cp TILE_ENEMY_R_TURRET_TOP
update_tile_enemy_turret_bottom_continue:	
	jp nz,update_tile_enemy_turret_top_sprite_set
	ld bc,18
	add hl,bc
update_tile_enemy_turret_top_sprite_set:
	ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
	ld a,2	; enemy height
	ld bc,3	; enemy width+1
	call copy_enemy_tiles

	; fire a bullet:
	JP_IF_RANDOM_GEQ difficulty_fire_rate_fast, update_tile_enemies_loop_next 
	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next

update_tile_enemy_turret_top_fire_bullet:
	call update_tile_enemy_fire_bullet_to_player

	; do not shoot for a few frames
	ld a,(difficulty_fire_delay)
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a
	or a
	jp z,update_tile_enemies_loop_next
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	jp update_tile_enemies_loop_next


update_tile_enemy_turret_bottom:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_turret_wait_state

	ld hl,(level_type_tile_enemies_bank1)
	call update_tile_enemy_turret_player_angle
	add hl,bc
	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
	cp TILE_ENEMY_R_TURRET_BOTTOM
	jp update_tile_enemy_turret_bottom_continue


; must preserve hl
update_tile_enemy_turret_player_angle:
	ld a,(player_tile_x)
	sub (ix+TILE_ENEMY_STRUCT_X)
    jp p,update_tile_enemy_turret_player_angle_upward
    neg
 	ld c,a

	ld a,(player_tile_y)
	sub (ix+TILE_ENEMY_STRUCT_Y)
    jp p,update_tile_enemy_turret_player_angle_y_pos
    neg
update_tile_enemy_turret_player_angle_y_pos:
	ld b,a

	ld a,b
	add a,a
	cp c
	; if c > 4*b ->  aim forward: z, bc = 0
	jr c,update_tile_enemy_turret_player_angle_forward

	ld a,c
	add a,a
	cp b
	; if b > 4*c ->  aim vertically: z, bc = 12
	jr c,update_tile_enemy_turret_player_angle_upward
	
	; else aim diagonally: z, bc = 6
	ld bc,6
	ret
update_tile_enemy_turret_player_angle_forward:
	ld bc,0
	ret

update_tile_enemy_turret_player_angle_upward:
	ld bc,12
	ret

update_tile_enemy_fallingrocks_wait_state:
update_tile_enemy_waterdome_wait_state:
update_tile_enemy_generator_wait_state:
update_tile_enemy_moai_wait_state:
update_tile_enemy_turret_wait_state:
update_tile_enemy_templesnake_wait_state:	
	dec (ix+TILE_ENEMY_STRUCT_TIMER)
	jp nz,update_tile_enemies_loop_next
	ld (ix+TILE_ENEMY_STRUCT_STATE),0
	jp update_tile_enemies_loop_next


;-----------------------------------------------
update_tile_enemy_moai_top:
update_tile_enemy_moai_bottom:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_moai_wait_state

	; fire a bullet:
	JP_IF_RANDOM_GEQ difficulty_fire_rate_fast, update_tile_enemies_loop_next 
	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next

	ld a,(ix+TILE_ENEMY_STRUCT_X)
	ld hl,scroll_x_tile
	sub (hl)
	jp m,update_tile_enemies_loop_next
	cp 32
	jp p,update_tile_enemies_loop_next
	add a,a
	add a,a
	add a,a
	inc a
	ld (iy+ENEMY_BULLET_STRUCT_X), a

	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
	cp TILE_ENEMY_MOAI_TOP
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	jr z,update_tile_enemy_moai_spawn_laser_top
	ld (iy+ENEMY_BULLET_STRUCT_TYPE), ENEMY_BULLET_LASER_UP_LEFT
	jr update_tile_enemy_moai_spawn_laser_continue
update_tile_enemy_moai_spawn_laser_top:
	ld (iy+ENEMY_BULLET_STRUCT_TYPE), ENEMY_BULLET_LASER_DOWN_LEFT
	add a,2
update_tile_enemy_moai_spawn_laser_continue:
	add a,a
	add a,a
	add a,a
	ld (iy+ENEMY_BULLET_STRUCT_Y), a
	ld (iy+ENEMY_BULLET_STATE), 16

	; do not shoot for a few frames
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	ld a,(difficulty_fire_delay)
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a
	or a
	jp z,update_tile_enemies_loop_next
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	jp update_tile_enemies_loop_next


;-----------------------------------------------
update_tile_enemy_growingwall_top:
	; check if the wall is already all the way down
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	cp 8
	jp z,update_tile_enemies_loop_next

	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	or a
	jr z,update_tile_enemy_growingwall_top_grow
	dec (ix+TILE_ENEMY_STRUCT_TIMER)
	jp update_tile_enemies_loop_next
update_tile_enemy_growingwall_top_grow:
	; grow the wall:
	ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
	push hl
		call update_tile_enemy_growingwall_top_grow_render
	pop hl

	; check if we need to update the second copy for when the scroll wraps around:
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	cp 64
	jp c,update_tile_enemy_growingwall_top_grow_no_copy
	push hl
		ld bc,-64
		add hl,bc
		call update_tile_enemy_growingwall_top_grow_render
	pop hl
update_tile_enemy_growingwall_top_grow_no_copy:

	ld bc,MAP_BUFFER_WIDTH
	inc (ix+TILE_ENEMY_STRUCT_Y)
update_tile_enemy_growingwall_top_grow_no_copy_entry_point:
	add hl,bc
	ld (ix+TILE_ENEMY_STRUCT_PTRL),l
	ld (ix+TILE_ENEMY_STRUCT_PTRH),h
	ld (ix+TILE_ENEMY_STRUCT_TIMER),1
	jp update_tile_enemies_loop_next


update_tile_enemy_growingwall_bottom:
	; check if the wall is already all the way up
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	cp 7
	jp z,update_tile_enemies_loop_next

	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	or a
	jr z,update_tile_enemy_growingwall_bottom_grow
	dec (ix+TILE_ENEMY_STRUCT_TIMER)
	jp update_tile_enemies_loop_next
update_tile_enemy_growingwall_bottom_grow:
	; grow the wall:
	ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
	push hl
		call update_tile_enemy_growingwall_bottom_grow_render
	pop hl

	; check if we need to update the second copy for when the scroll wraps around:
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	cp 64
	jp c,update_tile_enemy_growingwall_bottom_grow_no_copy
	push hl
		ld bc,-64
		add hl,bc
		call update_tile_enemy_growingwall_bottom_grow_render
	pop hl
update_tile_enemy_growingwall_bottom_grow_no_copy:

	ld bc,-MAP_BUFFER_WIDTH
	dec (ix+TILE_ENEMY_STRUCT_Y)
	jr update_tile_enemy_growingwall_top_grow_no_copy_entry_point

update_tile_enemy_growingwall_bottom_grow_render:
	ld bc,MAP_BUFFER_WIDTH
	jr update_tile_enemy_growingwall_top_grow_render_entry_point

update_tile_enemy_growingwall_top_grow_render:
	ld bc,-MAP_BUFFER_WIDTH
update_tile_enemy_growingwall_top_grow_render_entry_point:
	ld e,l
	ld d,h
	add hl,bc
	push bc
	push hl
	push hl
		; faster than ld bc,5; ldir
		ldi
		ldi
		ldi
		ldi
		ldi		
	pop de
	pop hl
	pop bc
	add hl,bc
	; faster than ld bc,5; ldir
	ldi
	ldi
	ldi
	ldi
	ldi
	ret


;-----------------------------------------------
update_tile_enemy_generator_gfx_ptr:
	ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
	cp TILE_ENEMY_GENERATOR_TOP
	jr z,update_tile_enemy_generator_gfx_ptr_top
	ld hl,(level_type_tile_enemies_bank1)
	ret
update_tile_enemy_generator_gfx_ptr_top:
	ld hl,(level_type_tile_enemies_bank0)
	ret


update_tile_enemy_generator_top:
update_tile_enemy_generator_bottom:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_generator_wait_state

	; change gfx:
	call update_tile_enemy_generator_gfx_ptr
	ld bc,GENERATOR_START_OFFSET+8
	add hl,bc
	ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
	ld a,2	; enemy height
	ld c,4	; enemy width+1	 (b should be 0 here)
	call copy_enemy_tiles

	inc (ix+TILE_ENEMY_STRUCT_TIMER)
	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	cp 4
	jr z,update_tile_enemy_generator_top_close
	cp 3
	jp nz,update_tile_enemies_loop_next

	; release a ship:
	ld hl,auxilliary_spawn_buffer
	push hl
	 	ld (hl),0	; time to spawn
	 	inc hl
	 	ld (hl),ENEMY_UFO
	 	inc hl

		ld a,(ix+TILE_ENEMY_STRUCT_TYPE)
		cp TILE_ENEMY_GENERATOR_TOP
		jr z,update_tile_enemy_generator_generate_top
	 	ld (hl),MOVEMENT_UFO_GENERATE_BOT
	 	jr update_tile_enemy_generator_generate_set
update_tile_enemy_generator_generate_top:
	 	ld (hl),MOVEMENT_UFO_GENERATE_TOP
update_tile_enemy_generator_generate_set:
	 	inc hl
	 	ld a,(scroll_x_tile)
	 	ld c,a
	 	ld a,(ix+TILE_ENEMY_STRUCT_X)
	 	sub c
	 	ld (hl),a
	 	inc hl
	 	ld a,(ix+TILE_ENEMY_STRUCT_Y)
		add a,a
		add a,a
		add a,a
		ld (hl),a
	pop hl
	push ix
		call spawn_enemy_from_spawn_record
		jr nz,update_tile_enemy_generator_top_no_enemy
		ld (ix+ENEMY_STRUCT_X),3
update_tile_enemy_generator_top_no_enemy:
	pop ix

	jp update_tile_enemies_loop_next

update_tile_enemy_generator_top_close:
 	; do not release ships for a few frames
 	ld (ix+TILE_ENEMY_STRUCT_STATE),1
 	ld a,(difficulty_fire_delay)
 	ld c,a
	call random
	and #3
	add a,c
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a

	; change image:
	call update_tile_enemy_generator_gfx_ptr
	ld bc,GENERATOR_START_OFFSET
	add hl,bc
	ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
	ld a,2	; enemy height
	ld c,4	; enemy width+1  (b should be 0 here)
	call copy_enemy_tiles
	jp update_tile_enemies_loop_next


;-----------------------------------------------
update_tile_enemy_waterdome:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_waterdome_wait_state

	; prepare to draw:
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	cp 8
	jr c,update_tile_enemy_waterdome_bank0
	ld hl,(level_type_tile_enemies_bank1)
	jr update_tile_enemy_waterdome_bank_set
update_tile_enemy_waterdome_bank0:
	ld hl,(level_type_tile_enemies_bank0)
update_tile_enemy_waterdome_bank_set:
	ld bc,WATERDOME_START_OFFSET
	add hl,bc
	ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
	ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
; 	ld b,0 	; b == 0 already here
	ld c,(ix+TILE_ENEMY_STRUCT_WIDTH)

	; come out:
	inc (ix+TILE_ENEMY_STRUCT_TIMER)
	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	dec a
	jr z,update_tile_enemy_waterdome_frame1
	dec a
	jr z,update_tile_enemy_waterdome_frame2
	dec a
	jr z,update_tile_enemy_waterdome_frame3
	sub 4
	jr z,update_tile_enemy_waterdome_frame2
	dec a
	jr z,update_tile_enemy_waterdome_frame1
	dec a
	jr z,update_tile_enemy_waterdome_frame0
	jp update_tile_enemies_loop_next

update_tile_enemy_waterdome_frame0:
 	ld a,(difficulty_fire_delay)
 	push bc
	 	ld c,a
	 	call random
	 	and #0f
	 	add a,c
	pop bc
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	; clear
	call update_tile_enemy_waterdome_clear
	jp update_tile_enemies_loop_next

update_tile_enemy_waterdome_frame1:
	; clear
	call update_tile_enemy_waterdome_clear
	push bc
		ex de,hl
		ld bc,MAP_BUFFER_WIDTH*2
		add hl,bc
		ex de,hl
	pop bc
	ld a,1
	call copy_enemy_tiles_scroll_restart_safe
	jp update_tile_enemies_loop_next

update_tile_enemy_waterdome_frame2:
	; clear
	call update_tile_enemy_waterdome_clear
	; draw
	push bc
		ex de,hl
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
		ex de,hl
	pop bc
	ld a,2
	call copy_enemy_tiles_scroll_restart_safe
	jp update_tile_enemies_loop_next

update_tile_enemy_waterdome_frame3:
	; clear
	call update_tile_enemy_waterdome_clear
	; draw
	ld a,3
	call copy_enemy_tiles_scroll_restart_safe

	; fire bullets:
	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next
	call update_tile_enemy_fire_bullet_to_player
	ld (iy+ENEMY_BULLET_STRUCT_VX), -2
	ld (iy+ENEMY_BULLET_STRUCT_VY), 0

	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next
	call update_tile_enemy_fire_bullet_to_player
	ld (iy+ENEMY_BULLET_STRUCT_VX), 2
	ld (iy+ENEMY_BULLET_STRUCT_VY), 0

	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next
	call update_tile_enemy_fire_bullet_to_player
	ld (iy+ENEMY_BULLET_STRUCT_VX), -2
	ld (iy+ENEMY_BULLET_STRUCT_VY), -3

	call find_enemy_bullet_spot
	jp nz,update_tile_enemies_loop_next
	call update_tile_enemy_fire_bullet_to_player
	ld (iy+ENEMY_BULLET_STRUCT_VX), 2
	ld (iy+ENEMY_BULLET_STRUCT_VY), -3
	jp update_tile_enemies_loop_next

update_tile_enemy_waterdome_clear:
	push hl
	push de
	push bc
		ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
		ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
		ld c,(ix+TILE_ENEMY_STRUCT_WIDTH)
		ld b,(ix+TILE_ENEMY_STRUCT_HEIGHT)
		ld a,(ix+TILE_ENEMY_STRUCT_CLEAR_TILE)
		call clear_tile_enemy_to_a
	pop bc
	pop de
	pop hl
	; if tile x >= 64, we also need to clear the position x-64, ready for when there is a scroll restart:	
	ld a,e
	and #7f
	cp 64
	ret c
	push hl
	push de
	push bc
		ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
		ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
		ld bc,-64
		add hl,bc
		ex de,hl
		ld c,(ix+TILE_ENEMY_STRUCT_WIDTH)
		ld b,(ix+TILE_ENEMY_STRUCT_HEIGHT)
		ld a,(ix+TILE_ENEMY_STRUCT_CLEAR_TILE)
		call clear_tile_enemy_to_a
	pop bc
	pop de
	pop hl
	ret


;-----------------------------------------------
update_tile_enemy_fallingrocks:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_fallingrocks_wait_state

	; release a rock:
	ld hl,auxilliary_spawn_buffer
	push hl
	 	ld (hl),0	; time to spawn
	 	inc hl
	 	ld (hl),ENEMY_FALLING_ROCK
	 	inc hl	; skip movement type, as falling rocks only have one
	 	inc hl
	 	ld a,(scroll_x_tile)
	 	ld c,a
	 	; randomly perturb the x position +1/-1
	 	call random
	 	and #03
	 	dec a
	 	jr nz,update_tile_enemy_fallingrocks_rock_x_pos1
	 	inc c
update_tile_enemy_fallingrocks_rock_x_pos1:
	 	dec a
	 	jr nz,update_tile_enemy_fallingrocks_rock_x_pos2
	 	dec c
update_tile_enemy_fallingrocks_rock_x_pos2:
	 	ld a,(ix+TILE_ENEMY_STRUCT_X)
	 	sub c
	 	ld (hl),a
	 	inc hl
		ld (hl),-8	; TILE_ENEMY_STRUCT_Y
	pop hl
 	push ix
 		call spawn_enemy_from_spawn_record
 	pop ix

 	; do not drop rocks for a few frames
 	ld (ix+TILE_ENEMY_STRUCT_STATE),1
 	ld a,(difficulty_fire_delay)
 	srl a
 	ld c,a
	call random
	and #3
	add a,c
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a

	jp update_tile_enemies_loop_next


;-----------------------------------------------
update_tile_enemy_templesnake:
	ld a,(ix+TILE_ENEMY_STRUCT_STATE)
	or a
	jp nz,update_tile_enemy_templesnake_wait_state

	inc (ix+TILE_ENEMY_STRUCT_TIMER)
	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	dec a
	jr z,update_tile_enemy_templesnake_open_mouth
	cp 2
	jr z,update_tile_enemy_templesnake_fire
	cp 3
	jr nc,update_tile_enemy_templesnake_close_mouth
update_tile_enemy_templesnake_done:
	jp update_tile_enemies_loop_next

update_tile_enemy_templesnake_open_mouth:
	ld bc,SNAKE_START_OFFSET+6*2
update_tile_enemy_templesnake_open_continue:
	ld d,(ix+TILE_ENEMY_STRUCT_PTRH)
	ld e,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld hl,(level_type_tile_enemies_bank0)
	add hl,bc
	ld a,2	; enemy height
	ld bc,6	; enemy width+1
	call copy_enemy_tiles
	jr update_tile_enemy_templesnake_done

update_tile_enemy_templesnake_close_mouth:
 	ld a,(difficulty_fire_delay)
 	push bc
	 	ld c,a
	 	call random
	 	and #0f
	 	add a,c
	pop bc
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	ld bc,SNAKE_START_OFFSET
	jr update_tile_enemy_templesnake_open_continue

update_tile_enemy_templesnake_fire:
	call find_enemy_bullet_spot
	jr nz,update_tile_enemy_templesnake_done
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	ld hl,scroll_x_tile
	sub (hl)
	jp m,update_tile_enemies_loop_next
	cp 32
	jp p,update_tile_enemies_loop_next
	add a,a
	add a,a
	add a,a
	inc a
	ld (iy+ENEMY_BULLET_STRUCT_X), a
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	ld (iy+ENEMY_BULLET_STRUCT_TYPE), ENEMY_BULLET_LASER_DOWN_LEFT
	add a,a
	add a,a
	add a,a
	ld (iy+ENEMY_BULLET_STRUCT_Y), a
	ld (iy+ENEMY_BULLET_STATE), 0
	ld hl,SFX_moai_laser	
	call play_SFX_with_high_priority
	jr update_tile_enemy_templesnake_done


;-----------------------------------------------
update_tile_enemy_templecolumn:
	; check if the wall is already all the way up
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	cp 7
	jp z,update_tile_enemies_loop_next

	ld a,(ix+TILE_ENEMY_STRUCT_TIMER)
	or a
	jr z,update_tile_enemy_templecolumn_grow
	dec (ix+TILE_ENEMY_STRUCT_TIMER)
	jp update_tile_enemies_loop_next
update_tile_enemy_templecolumn_grow:

	; grow the column:
	ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
	ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
	push hl
		call update_tile_enemy_templecolumn_render
	pop hl

	; check if we need to update the second copy for when the scroll wraps around:
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	cp 64
	jr c,update_tile_enemy_templecolumn_grow_continue
	push hl
		ld bc,-64
		add hl,bc
		call update_tile_enemy_templecolumn_render
	pop hl

update_tile_enemy_templecolumn_grow_continue:
	dec (ix+TILE_ENEMY_STRUCT_Y)
	ld bc,-MAP_BUFFER_WIDTH
	add hl,bc
	ld (ix+TILE_ENEMY_STRUCT_PTRL),l
	ld (ix+TILE_ENEMY_STRUCT_PTRH),h
	;ld (ix+TILE_ENEMY_STRUCT_TIMER),1
	jp update_tile_enemies_loop_next

update_tile_enemy_templecolumn_render:
	ex de,hl
	ld bc,COLUMN_START_OFFSET
	ld hl,(level_type_tile_enemies_bank1)
	add hl,bc
	ld a,2	; enemy height
; 	ld bc,4	; enemy width+1
	ld c,4	; no need to modify b, as it's 0 already
	jr copy_enemy_tiles


;-----------------------------------------------
; copies the tiles onto the map buffer
; input:
; - hl: the source tiles
; - de: ptr to the address in the pattern to start copying
; - a: enemy height
; - bc: enemy width
copy_enemy_tiles_ex:
	ex af,af'
copy_enemy_tiles:
	push bc	
		push de
			ldir
		pop de
		ex de,hl
			ld bc,MAP_BUFFER_WIDTH
			add hl,bc
		ex de,hl
	pop bc
	dec a
	jr nz,copy_enemy_tiles
	ret

copy_enemy_tiles_scroll_restart_safe:
	ex af,af'
		ld a,e
		and #7f
		cp 64
		jr c,copy_enemy_tiles_ex	; no need to worry
	ex af,af'
	; if we reach here, we need to copy the enemy twice, since in the desired position,
	; and once in x-64:
	push hl
	push af
	push bc
		push de
			call copy_enemy_tiles
		pop hl
		ld bc,-64
		add hl,bc
		ex de,hl
	pop bc
	pop af
	pop hl
	jr copy_enemy_tiles


;-----------------------------------------------
; - same but does not copy tiles == 0,
; - also it checks if we are not drawing outside of the map area
; input:
; - hl: the source tiles
; - de: ptr to the address in the pattern to start copying
; - b: enemy height
; - c: enemy width
copy_non_empty_enemy_tiles:
	push bc	
		ld a,d
		cp mapBuffer/256
		jp m,copy_non_empty_enemy_tiles_loop_skip_row
		cp (mapBuffer/256)+(MAP_HEIGHT/2)	; since each map row is 128 bytes
		jp p,copy_non_empty_enemy_tiles_loop_skip_row

		push de
			ld b,c
copy_non_empty_enemy_tiles_loop:
			ld a,(hl)
			or a
			jr z,copy_non_empty_enemy_tiles_loop_skip
			ld (de),a
copy_non_empty_enemy_tiles_loop_skip:
			inc de
			inc hl
			djnz copy_non_empty_enemy_tiles_loop
		pop de
copy_non_empty_enemy_tiles_loop_skip_row_continue:
		ex de,hl
			ld bc,MAP_BUFFER_WIDTH
			add hl,bc
		ex de,hl
	pop bc
	djnz copy_non_empty_enemy_tiles
	ret
copy_non_empty_enemy_tiles_loop_skip_row:
	ld b,0
	add hl,bc
	jr copy_non_empty_enemy_tiles_loop_skip_row_continue


;-----------------------------------------------
; - de: ptr to the address to clear
; - b: enemy height
; - c: enemy width
; - a: tile to use for clearing
clear_tile_enemy:
	xor a
clear_tile_enemy_to_a:
	ex de,hl
copy_enemy_tiles_loop_y:	
	push bc	
	push af
		ld b,c
		ld c,a
		; check if we are trying to clear outside the map:
		ld a,h
		cp mapBuffer/256
		jp m,clear_tile_enemy_loop_y_skip
		cp (mapBuffer/256)+(MAP_HEIGHT/2)	; since each map row is 128 bytes
		jp p,clear_tile_enemy_loop_y_skip

		push hl
clear_tile_enemy_loop_x:
			ld a,(hl)
			cp 10	; do not clear stars nor weapons
			jr c,clear_tile_enemy_loop_x_skip
			ld (hl),c
clear_tile_enemy_loop_x_skip:
			inc hl
			djnz clear_tile_enemy_loop_x
		pop hl
clear_tile_enemy_loop_y_skip:		
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
	pop af
	pop bc
	djnz copy_enemy_tiles_loop_y
	ret


;-----------------------------------------------
; input: 
; - iy: tile enemy being hit
; - c: damage to be dealt
; output:
; - z: killed
; - nz: not killed
; should preserve: de, hl, ix
tile_enemy_hit:
	push hl
		ld hl,SFX_enemy_hit
		call play_SFX_with_high_priority
	pop hl	

	; collision with tile_enemy!!
	ld a,(iy+TILE_ENEMY_STRUCT_HP)
	sub c
	ld (iy+TILE_ENEMY_STRUCT_HP),a
	cp 1
	jp p,tile_enemy_hit_still_alive

	; mark that there is a tile enemy to delete:
	ld a,1
	ld (any_tile_enemy_to_delete),a
	set 7,(iy+TILE_ENEMY_STRUCT_TYPE)
	xor a
	ret

tile_enemy_hit_still_alive:
	or 1
	ret


;-----------------------------------------------
check_tile_enemy_deletion:
	ld iy,tile_enemies
	ld b,MAX_TILE_ENEMIES
	ld de,TILE_ENEMY_STRUCT_SIZE
check_tile_enemy_deletion_loop:
	bit 7,(iy+TILE_ENEMY_STRUCT_TYPE)
	jp z,check_tile_enemy_deletion_loop_next_no_pop
	push bc
	push de
		call check_tile_enemy_deletion_loop_delete
	pop de
	pop bc
check_tile_enemy_deletion_loop_next_no_pop:
	add iy,de
	djnz check_tile_enemy_deletion_loop
	ret

check_tile_enemy_deletion_loop_delete:
	ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
	and #7f
	cp TILE_ENEMY_TEMPLESNAKE
	jr nz,check_tile_enemy_deletion_loop_delete_no_snake
	; clear a temple snake:
	ld d,(iy+TILE_ENEMY_STRUCT_PTRH)
	ld e,(iy+TILE_ENEMY_STRUCT_PTRL)
	ld bc,SNAKE_START_OFFSET+6*2*2
	ld hl,(level_type_tile_enemies_bank0)
	add hl,bc
	ld a,2	; enemy height
; 	ld bc,6	; enemy width+1
	ld c,6	; enemy width+1	(no need to modify b here, as it's 0 already)
	push de
	push hl
		call copy_enemy_tiles
	pop de	; notice we swap the registers (to avoid an "ex de,hl" later)
	pop hl

	ld a,(iy+TILE_ENEMY_STRUCT_X)
	cp PCG_PATTERN_WIDTH*PCG_PATTERN_WIDTH*4
	jp m,check_tile_enemy_deletion_no_duplicates
	; when the tile enemy is on the right-most part of the map buffer, it is also replicated
	; on the left-most (for scroll looping). So, we need to clear both!

	ld bc,-PCG_PATTERN_WIDTH*4
	add hl,bc
	ex de,hl
	ld a,2	; enemy height
	ld bc,6	; enemy width+1
	call copy_enemy_tiles
	jr check_tile_enemy_deletion_no_duplicates

check_tile_enemy_deletion_loop_delete_no_snake:
	; clear the enemy and deactivate it:
	ld d,(iy+TILE_ENEMY_STRUCT_PTRH)
	ld e,(iy+TILE_ENEMY_STRUCT_PTRL)
	ld c,(iy+TILE_ENEMY_STRUCT_WIDTH)
	ld b,(iy+TILE_ENEMY_STRUCT_HEIGHT)
	ld a,(iy+TILE_ENEMY_STRUCT_CLEAR_TILE)
	call clear_tile_enemy_to_a

	ld a,(iy+TILE_ENEMY_STRUCT_X)
	cp PCG_PATTERN_WIDTH*PCG_PATTERN_WIDTH*4
	jp m,check_tile_enemy_deletion_no_duplicates
	; when the tile enemy is on the right-most part of the map buffer, it is also replicated
	; on the left-most (for scroll looping). So, we need to clear both!
	ld h,(iy+TILE_ENEMY_STRUCT_PTRH)
	ld l,(iy+TILE_ENEMY_STRUCT_PTRL)
	ld bc,-PCG_PATTERN_WIDTH*4
	add hl,bc
	ex de,hl
	ld c,(iy+TILE_ENEMY_STRUCT_WIDTH)
	ld b,(iy+TILE_ENEMY_STRUCT_HEIGHT)
	ld a,(iy+TILE_ENEMY_STRUCT_CLEAR_TILE)
	call clear_tile_enemy_to_a

check_tile_enemy_deletion_no_duplicates:		

	; spawn power pellet:
	ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
	and #7f
	cp TILE_ENEMY_R_TURRET_TOP
	jr z,check_tile_enemy_deletion_power_pellet_top_turret
	cp TILE_ENEMY_R_TURRET_BOTTOM
	jr z,check_tile_enemy_deletion_power_pellet
check_tile_enemy_deletion_after_power_pellet:
	; trigger an explosion:
	ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
	and #7f
	ld (iy+TILE_ENEMY_STRUCT_TYPE),0
	cp TILE_ENEMY_R_TURRET_BOTTOM+1
	jp m,check_tile_enemy_deletion_sprite_explosion
check_tile_enemy_deletion_tile_explosion:
	jp spawn_tile_explosion
check_tile_enemy_deletion_sprite_explosion:
	jp spawn_sprite_explosion

check_tile_enemy_deletion_power_pellet_top_turret:
	push bc
		ld b,(iy+TILE_ENEMY_STRUCT_Y)
		inc b
		jr check_tile_enemy_deletion_power_pellet_entry_point

check_tile_enemy_deletion_power_pellet:
	push bc
		ld b,(iy+TILE_ENEMY_STRUCT_Y)
check_tile_enemy_deletion_power_pellet_entry_point:
		ld c,(iy+TILE_ENEMY_STRUCT_X)
		dec c
		call spawn_power_pellet
	pop bc
	jp check_tile_enemy_deletion_after_power_pellet


;-----------------------------------------------
update_tile_enemy_fire_bullet_to_player:
	ld a,(ix+TILE_ENEMY_STRUCT_X)
	ld hl,scroll_x_tile
	sub (hl)
	;jp m,update_tile_enemies_loop_next	; comparison not needed
	cp 32
	ret p

	add a,a
	add a,a
	ld c,a
	add a,a
	ld (iy+ENEMY_BULLET_STRUCT_X), a
	ld a,(player_x)
	srl a
	sub c
	ld (iy+ENEMY_BULLET_STRUCT_VX), a

	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	inc a
	add a,a
	add a,a
	ld b,a
	add a,a
	ld (iy+ENEMY_BULLET_STRUCT_Y), a
	ld a,(player_y)
	srl a
	sub b
	ld (iy+ENEMY_BULLET_STRUCT_VY), a
	ld (iy+ENEMY_BULLET_STRUCT_TYPE), ENEMY_BULLET_PELLET

	; by default set it to a regular bullet:
	ld l,(iy+ENEMY_BULLET_STRUCT_SPRITE_PTR)
	ld h,(iy+ENEMY_BULLET_STRUCT_SPRITE_PTR+1)
	inc hl
	inc hl
	ld (hl),ENEMY_BULLET_SPRITE_PELLET
	inc hl
	ld (hl),COLOR_DARK_YELLOW
	ret		
