;-----------------------------------------------
update_scylla:
	call update_boss_check_if_hit
	jr z,update_scylla_not_hit

	; boss health reached 0!
	ld hl,boss_state
	ld a,(hl)
	cp 5
	jr c,update_scylla_to_phase2
	; boss dead:
	xor a
	inc hl	; boss_state_cycle
	ld (hl),a
	ld a,9	; death state
	ld (boss_state),a
	call update_scylla_clear
	ld hl,boss_x
	inc (hl)
	inc hl
	inc (hl)

	call StopMusic
	ld hl,SFX_big_explosion
	call play_SFX_with_high_priority
	jr update_scylla_not_hit

update_scylla_to_phase2:
	ld (hl),5	; (switch to phase 2) hl still contains boss_state
	xor a
	inc hl	; boss_state_cycle
	ld (hl),a
	ld a,SCYLLA_HEALTH_PHASE2
	ld (boss_health),a
	ld a,128
	ld (boss_hit_gfx),a	; prevent the boss being hit during the transformation

update_scylla_not_hit:
	ld a,(boss_state)
	ld hl,boss_state_cycle
	inc (hl)
	dec a
	jr z,update_scylla_state1
	dec a
	jr z,update_scylla_state2
	dec a
	jr z,update_scylla_state3
	dec a
	jp z,update_scylla_state4
	dec a
	jp z,update_scylla_state5
	dec a
	jr z,update_scylla_state6
	dec a
	jp z,update_scylla_state7
	dec a
	jp z,update_scylla_state8
	dec a
	jp z,update_boss_explosion
	ret


;-----------------------------------------------
; - Scylla enters from the right
; hl: boss_state_cycle
update_scylla_state1:
	ld a,(hl)
	and #0f
	jp nz,update_scylla_draw
	ld hl,boss_x
	dec (hl)
	ld a,(hl)
	cp 22
	jp nz,update_scylla_draw
	ld (boss_state_cycle),a	; a = 0 here
	ld a,2
	ld (boss_state),a
	jp update_scylla_draw


;-----------------------------------------------
; pick a position at random to move to
update_scylla_state2:
update_scylla_state6:
	call random
	and #0f
	add a,8
	ld (boss_target_x),a
	call random
	and #0f
	dec a
	ld (boss_target_y),a
	ld hl,boss_state
	inc (hl)
update_scylla_state2_6_draw:
	ld a,(boss_state)
	cp 5
	jp m,update_scylla_draw
	jp update_scylla_draw_phase2


update_scylla_state3:
	; fire bullets every few frames:
	ld de,#0400
	call random
	and #1f
	call z,update_boss_fire_bullet

	; movement:
	ld a,(boss_state_cycle)
	and #07
	jr nz,update_scylla_state2_6_draw

update_scylla_state3_move:
	ld c,0
	ld a,(boss_x)
	ld hl,boss_target_x
	cp (hl)
	jr z,update_scylla_state3_no_x_move
	ld c,1
	jp p,update_scylla_state3_left
update_scylla_state3_right:
	inc a
	jr update_scylla_state3_no_x_move
update_scylla_state3_left:
	dec a
update_scylla_state3_no_x_move:
	ld (boss_x),a

	ld a,(boss_y)
	ld hl,boss_target_y
	cp (hl)
	jr z,update_scylla_state3_no_y_move
	ld c,1
	jp p,update_scylla_state3_up
update_scylla_state3_down:
	inc a
	jr update_scylla_state3_no_y_move
update_scylla_state3_up:
	dec a
update_scylla_state3_no_y_move:
	ld (boss_y),a

	ld a,c
	or a
	jr nz,update_scylla_state2_6_draw

	; arrived at destination!
	ld hl,boss_state
	inc (hl)
	ld (boss_state_cycle),a
	jr update_scylla_state2_6_draw


;-----------------------------------------------
update_scylla_state4:
	; fire laser
	ld a,(boss_state_cycle)
	dec a
	jr nz,update_scylla_state4_no_laser
	ld a,1
	ld (boss_scylla_arm_frame),a

	; fire laser:
	call find_enemy_bullet_spot
	jr nz,update_scylla_state4_no_laser

	ld a,(boss_x)
	add a,a
	add a,a
	add a,a
	inc a
	ld (iy+ENEMY_BULLET_STRUCT_X), a

	ld a,(boss_y)
	add a,7
	add a,a
	add a,a
	add a,a
	ld (iy+ENEMY_BULLET_STRUCT_Y), a
	ld (iy+ENEMY_BULLET_STRUCT_TYPE), ENEMY_BULLET_LASER_LEFT

	ld hl,SFX_moai_laser	
	call play_SFX_with_high_priority

update_scylla_state4_no_laser:
	ld a,(boss_state_cycle)
	cp 8
	jp nz,update_scylla_draw
	xor a
	ld (boss_scylla_arm_frame),a
	ld a,2
	ld (boss_state),a
	jp update_scylla_draw


;-----------------------------------------------
update_scylla_state5:
	ld a,(boss_state_cycle)
	cp 80
	jp nz,update_scylla_draw_state5
	ld a,6
	ld (boss_state),a
	jp update_scylla_draw_state5


;-----------------------------------------------
update_scylla_state7:
	; fire bullets every few frames:
	ld de,#ff02
	call random
	and #0f
	call z,update_boss_fire_bullet

	; movement:
	ld a,(boss_state_cycle)
	and #07
	jp nz,update_scylla_state2_6_draw
	jp update_scylla_state3_move

;-----------------------------------------------
update_scylla_state8:
	; fire bullets every few frames:
	ld de,#ff02
	call random
	and #0f
	call z,update_boss_fire_bullet

	ld a,(boss_state_cycle)
	cp 8
	jr c,update_scylla_state8_1 ; head forward
	cp 16
	jr c,update_scylla_state8_2 ; mouth open
	cp 24
	jr c,update_scylla_state8_3 ; mouth wide open
	cp 64
	jr c,update_scylla_state8_4 ; laser
	cp 72
	jr c,update_scylla_state8_3 ; mouth wide open
	cp 80
	jr c,update_scylla_state8_2 ; mouth open

	xor a
	ld (boss_scylla_head_frame),a
	ld (boss_scylla_jaw_frame),a
	ld (boss_state_cycle),a
	ld a,6
	ld (boss_state),a	
	jp update_scylla_draw_phase2

update_scylla_state8_1:
	xor a
	ld (boss_scylla_jaw_frame),a
	inc a
	ld (boss_scylla_head_frame),a
	jp update_scylla_draw_phase2

update_scylla_state8_2:
	ld a,1
	ld (boss_scylla_jaw_frame),a
	inc a
	ld (boss_scylla_head_frame),a
	jp update_scylla_draw_phase2

update_scylla_state8_3:
	ld a,2
	ld (boss_scylla_jaw_frame),a
	xor a
	ld (boss_laser_length),a
	jp update_scylla_draw_phase2

update_scylla_state8_4:
	; laser:
	ld a,(boss_x)
	add a,2
	ld (boss_laser_length),a
	jp update_scylla_draw_phase2


;-----------------------------------------------
; erases the boss from the screen
update_scylla_clear:
	; clear sprites:
	ld c,200
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),c
	ld hl,enemy_sprite_attributes
	ld (hl),c
	ld hl,enemy_sprite_attributes+4
	ld (hl),c
update_scylla_clear_skip_sprites:

	ld de,(boss_previous_ptr)
	ld a,d
	or a
	ret z
	ld bc,#0b0b	; clear an area of 9x11
	call clear_tile_enemy
	jp update_boss_clear_laser


;-----------------------------------------------
update_scylla_draw:
	call update_scylla_clear
	call get_boss_ptr
	ld (boss_previous_ptr),hl
	ex de,hl	; de ptr to draw scylla!

update_scylla_draw_phase1:
	ld bc,#0308	; 8x3 is the size of the head top
	ld hl,boss2_frames+9*5*2+2+3
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,3*MAP_BUFFER_WIDTH
	add hl,bc
	ex de,hl

update_scylla_draw_phase1_body:
	ld bc,#0509	; 9x5 is the size of the main body (phase 1)
	ld a,(boss_scylla_arm_frame)
	or a
	jr z,update_scylla_draw_arm1_frame
	ld hl,boss2_frames+9*5
	jr update_scylla_draw_arm_drawn
update_scylla_draw_arm1_frame:
	ld hl,boss2_frames
update_scylla_draw_arm_drawn:
	push de
		call copy_non_empty_enemy_tiles
	pop de

	ld hl,boss_hit_gfx
	ld a,(hl)
	or a
	jr z,update_scylla_draw_no_hit_gfx
	dec (hl)
	push de
		ex de,hl
			ld bc,MAP_BUFFER_WIDTH
			add hl,bc
		ex de,hl
		ld bc,#0102
		ld hl,boss2_frames+9*5*2
		call copy_non_empty_enemy_tiles
	pop de

update_scylla_draw_no_hit_gfx:
	ld bc,2*MAP_BUFFER_WIDTH+8
	ld hl,boss2_frames+9*5*2+2
	call update_boss_draw_thruster	

	; sprites
	ld a,(boss_x)
	cp 29
	jp p,update_scylla_draw_no_arm_sprite

	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	add a,a
	add a,a
	add a,a
	add a,24
	ld c,a

	ld a,(boss_y)
	add a,5	; we need to add this first, otherwise, coordinate is wrong for negative y coordinates
	add a,a
	add a,a
	add a,a
	dec a
	ld b,a
	ld (hl),a
	inc hl
	ld (hl),c
	inc hl
	ld a,(boss_scylla_arm_frame)
	or a
	jr z,update_scylla_draw_arm1_sprite
	ld (hl),(SCYLLA_FIRST_SPRITE+1)*4
	jr update_scylla_draw_arm_sprite_drawn
update_scylla_draw_arm1_sprite:
	ld (hl),SCYLLA_FIRST_SPRITE*4
update_scylla_draw_arm_sprite_drawn:
	inc hl
	ld (hl),COLOR_BLUE
update_scylla_draw_no_arm_sprite:
	ret


update_scylla_draw_state5:
	call update_scylla_clear
	call get_boss_ptr
	ld bc,-3*MAP_BUFFER_WIDTH
	add hl,bc	
	ex de,hl	; de ptr to draw scylla!
	ld (boss_previous_ptr),de

	; draw face sticking out:
	ld a,(boss_state_cycle)
	cp 16
	jr c,update_scylla_draw_state5_1
	cp 32
	jr c,update_scylla_draw_state5_2
	cp 48
	jr c,update_scylla_draw_state5_3
	cp 56
	jr c,update_scylla_draw_state5_4	; spider+explosion big
	cp 64
	jr c,update_scylla_draw_state5_5	; spider+explosion med
	jr update_scylla_draw_phase2

update_scylla_draw_state5_1:
	ex de,hl
		ld bc,3*MAP_BUFFER_WIDTH
		add hl,bc
	ex de,hl
	jp update_scylla_draw_phase1

update_scylla_draw_state5_2:
	ex de,hl
		ld bc,1*MAP_BUFFER_WIDTH+1
		add hl,bc
	ex de,hl
	ld bc,#0508	; 8x5 is the size of the head top
	ld hl,boss2_frames+9*5*2+2+3
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,5*MAP_BUFFER_WIDTH-1
	add hl,bc
	ex de,hl
	jp update_scylla_draw_phase1_body

update_scylla_draw_state5_3:
	inc de
	ld bc,#0608	; 8x7 is the size of the head top
	ld hl,boss2_frames+9*5*2+2+3
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,6*MAP_BUFFER_WIDTH-1
	add hl,bc
	ex de,hl
	jp update_scylla_draw_phase1_body

update_scylla_draw_state5_4:
	ld hl,SFX_big_explosion
	cp 49
	call z,play_SFX_with_high_priority

	inc de
	ld bc,#0608	; 8x7 is the size of the head top
	ld hl,boss2_frames+9*5*2+2+3
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,6*MAP_BUFFER_WIDTH-1
	add hl,bc
	ex de,hl
	call update_scylla_draw_phase1_body
	; explosion:
	ld hl,(boss_previous_ptr)
	ld bc,5*MAP_BUFFER_WIDTH+1
	add hl,bc
	ex de,hl
	ld bc,#0606
	ld hl,tile_explosion_large
	jp copy_non_empty_enemy_tiles

update_scylla_draw_state5_5:
	call update_scylla_draw_phase2
	; explosion:
	ld hl,(boss_previous_ptr)
	ld bc,7*MAP_BUFFER_WIDTH+3
	add hl,bc
	ex de,hl
	ld bc,#0404
	ld hl,tile_explosion+16
	jp copy_non_empty_enemy_tiles

update_scylla_draw_phase2:
	ld hl,boss_hit_gfx
	ld a,(hl)
	or a
	jr z,update_scylla_draw_phase2_not_hit_gfx
	dec (hl)
update_scylla_draw_phase2_not_hit_gfx:

	call update_scylla_clear
	call get_boss_ptr
	ld bc,-3*MAP_BUFFER_WIDTH
	add hl,bc	
	ex de,hl	; de ptr to draw scylla!
	ld (boss_previous_ptr),de

	ld a,(boss_scylla_head_frame)
	or a
	jr z,update_scylla_draw_phase2_head1
	dec a
	jr z,update_scylla_draw_phase2_head2
update_scylla_draw_phase2_head3:
	ld hl,boss2_frames+9*5*2+2+3+8*7*3
	jr update_scylla_draw_phase2_head2_continue
update_scylla_draw_phase2_head2:
	ld hl,boss2_frames+9*5*2+2+3+8*7*2
update_scylla_draw_phase2_head2_continue:
	ld bc,#0708	; 8x7 is the size of the head top
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,7*MAP_BUFFER_WIDTH+1
	add hl,bc
	ex de,hl
	ld hl,boss2_frames+9*5*2+2+3+8*7*4+3+3*3
	ld bc,#0409
	call copy_non_empty_enemy_tiles

	; jaw:
	ld hl,(boss_previous_ptr)
	ld bc,5*MAP_BUFFER_WIDTH
	add hl,bc
	ex de,hl
	ld a,(boss_scylla_jaw_frame)
	or a
	jr z,update_scylla_draw_phase2_sprites
	dec a
	jr z,update_scylla_draw_phase2_jaw1
update_scylla_draw_phase2_jaw2:
	ld bc,#0303
	ld hl,boss2_frames+9*5*2+2+3+8*7*4+3
	call copy_non_empty_enemy_tiles
	jr update_scylla_draw_phase2_sprites
update_scylla_draw_phase2_jaw1:
	ld bc,#0103
	ld hl,boss2_frames+9*5*2+2+3+8*7*4
	call copy_non_empty_enemy_tiles
	jr update_scylla_draw_phase2_sprites
update_scylla_draw_phase2_head1:
	inc de
	ld bc,#0708	; 8x7 is the size of the head top
	ld hl,boss2_frames+9*5*2+2+3+8*7
	push de
		call copy_non_empty_enemy_tiles
	pop hl
	ld bc,7*MAP_BUFFER_WIDTH-1
update_scylla_draw_phase2_after_head:
	add hl,bc
	ex de,hl
	ld hl,boss2_frames+9*5*2+2+3+8*7*4+3+3*3
	ld a,(boss_state_cycle)
	and #08
	jr z,update_scylla_draw_phase2_legs1
	ld bc,4*9
	add hl,bc	
update_scylla_draw_phase2_legs1:
	ld bc,#0409
	call copy_non_empty_enemy_tiles

update_scylla_draw_phase2_sprites:
	; sprites:
	ld a,(boss_x)
	add a,a
	add a,a
	add a,a
	add a,16
	ld c,a

	ld a,(boss_y)
	dec a
	add a,a
	add a,a
	add a,a
	dec a
	ld b,a

	ld a,(boss_scylla_head_frame)
	or a
	jr z,update_scylla_draw_phase2_sprites_head1
	ld e,(SCYLLA_FIRST_SPRITE+3)*4
	ld a,-8
	add a,c
	ld c,a
	jr update_scylla_draw_phase2_sprites_head_set
update_scylla_draw_phase2_sprites_head1:
	ld e,(SCYLLA_FIRST_SPRITE+2)*4
update_scylla_draw_phase2_sprites_head_set:

	; eye:
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),e
	inc hl
	ld (hl),COLOR_YELLOW

	; nose
	ld a,e
	add a,8
	ld e,a
	ld hl,enemy_sprite_attributes
	ld a,b
	add a,8
	ld (hl),a
	inc hl
	ld a,c
	add a,-8
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),COLOR_YELLOW

	; cables
	ld a,e
	add a,8
	ld e,a
	cp (SCYLLA_FIRST_SPRITE+7)*4
	jr nz,update_scylla_draw_phase2_sprites_continue
	ld a,c
	add a,14
	ld c,a
update_scylla_draw_phase2_sprites_continue:
	ld hl,enemy_sprite_attributes+4
	ld a,b
	add a,32
	ld (hl),a
	inc hl
	ld a,c
	add a,8
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),COLOR_DARK_YELLOW

 	; laser:
 	ld hl,(boss_previous_ptr)
 	ld bc,5*MAP_BUFFER_WIDTH+2
 	add hl,bc
 	ld de,boss2_frames+9*5*2+2+3+8*7*4+3+3*3+9*4*3 ; laser tile ptr
 	jp update_boss_draw_laser
