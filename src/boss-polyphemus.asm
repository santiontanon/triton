;-----------------------------------------------
update_polyphemus:
	call update_boss_check_if_hit
	jr z,update_polyphemus_not_hit

	; boss dead!
	xor a
	ld (boss_state_cycle),a
	ld a,9	; death state
	ld (boss_state),a
	call update_polyphemus_clear
	ld hl,boss_x
	inc (hl)
	inc hl
	inc (hl)

	call StopMusic
	ld hl,SFX_big_explosion
	call play_SFX_with_high_priority

update_polyphemus_not_hit:
	ld a,(boss_state)
	ld hl,boss_state_cycle
	inc (hl)
	dec a
	jr z,update_polyphemus_state1
	dec a
	jr z,update_polyphemus_state2
	dec a
	jr z,update_polyphemus_state3
	dec a
	jp z,update_polyphemus_state4
	dec a
	jp z,update_polyphemus_state5
	dec a
	jp z,update_polyphemus_state6
	dec a
	jp z,update_polyphemus_state7
	dec a
	jp z,update_polyphemus_state8
	dec a
	jp z,update_boss_explosion
	ret


;-----------------------------------------------
; - Polyphemus enters from the right
; hl: boss_state_cycle
update_polyphemus_state1:
	ld a,(hl)
	and #0f
	jp nz,update_polyphemus_draw
	ld hl,boss_x
	dec (hl)
	ld a,(hl)
	cp 22
	jp nz,update_polyphemus_draw
update_polyphemus_go_to_state2:
	ld a,2
update_polyphemus_go_to_state_a:
	ld (boss_state),a
	xor a
	ld (boss_state_cycle),a
	ld (boss_polyphemus_leg_frame),a
	jp update_polyphemus_draw


update_polyphemus_state2:
	ld a,(hl)
	cp 16
	jp nz,update_polyphemus_draw
	call random
	and #07

	; 0,6,7 -> move (state 3) 
	; 1,5 -> eye (state 4)
	; 2 -> machine gun (state 5)
	; 3 -> spawn enemies (state 6)
	; 4 -> charge (state 7)
	; ld a,1 ; DEBUG!
	cp 5
	jr z,update_polyphemus_state2_to_eye
	cp 6
	jr nc,update_polyphemus_state2_to_move
	add a,3
	jr update_polyphemus_go_to_state_a
update_polyphemus_state2_to_eye:
	ld a,4
	jr update_polyphemus_go_to_state_a
update_polyphemus_state2_to_move:
	sub 3
	jr update_polyphemus_go_to_state_a


	; move up/down
update_polyphemus_state3:
	ld a,(hl)
	dec a
	jr nz,update_polyphemus_state3_continue
	; pick target y: 0-32, and if >21, subtract 18
	call random 
	and #1f
	cp 21
	jr c,update_polyphemus_state3_y_pos_set
	sub 18
update_polyphemus_state3_y_pos_set:
	sub 3
	ld (boss_target_y),a
update_polyphemus_state3_continue:
	ld a,(hl)
	and #03
	jp nz,update_polyphemus_draw

	ld a,(boss_target_y)
	ld hl,boss_y
	cp (hl)
	jr z,update_polyphemus_go_to_state2
	jp p,update_polyphemus_state3_down
update_polyphemus_state3_up:
	xor a
	ld (boss_polyphemus_leg_frame),a
	dec (hl)
	jp update_polyphemus_draw
update_polyphemus_state3_down:
	ld a,1
	ld (boss_polyphemus_leg_frame),a
	inc (hl)
	jp update_polyphemus_draw

	; open eye!
update_polyphemus_state4:
	ld a,(hl)
	cp 8
	jr c,update_polyphemus_state4_1
	cp 32
	jr c,update_polyphemus_state4_2
	cp 112
	jr c,update_polyphemus_state4_3
	cp 128
	jr c,update_polyphemus_state4_1
	ld hl,enemy_sprite_attributes	; remove the eye sprite
	ld (hl),200	
	xor a
	ld (boss_polyphemus_eye_frame),a
	jp update_polyphemus_go_to_state2
update_polyphemus_state4_1:
	xor a
	ld (boss_laser_length),a
	ld a,1*6
	jp update_polyphemus_state4_continue
update_polyphemus_state4_2:
	call random
	and #01
	ld (boss_polyphemus_moving_direction),a
	ld a,2*6
	jp update_polyphemus_state4_continue
update_polyphemus_state4_3:
	; laser length:
	sub 32
	cp 22
	jr c,update_polyphemus_state4_3_laser_len_set
	ld a,22
update_polyphemus_state4_3_laser_len_set:
	ld (boss_laser_length),a

	; move and fire laser
	ld a,(hl)
	and #07
	jp nz,update_polyphemus_draw

	ld a,(boss_polyphemus_moving_direction)
	or a
	ld hl,boss_y
	ld a,(hl)
	jr z,update_polyphemus_state4_3_up
update_polyphemus_state4_3_down:
	cp 18
	jr z,update_polyphemus_state4_change_direction
	ld a,1
	ld (boss_polyphemus_leg_frame),a	
	inc (hl)
	jp update_polyphemus_draw	
update_polyphemus_state4_3_up:
	cp -3
	jr z,update_polyphemus_state4_change_direction
	xor a
	ld (boss_polyphemus_leg_frame),a	
	dec (hl)
	jp update_polyphemus_draw
update_polyphemus_state4_change_direction:
	ld hl,boss_polyphemus_moving_direction
	ld a,(hl)
	xor #01
	ld (hl),a
	jp update_polyphemus_draw

	; machine gun:
update_polyphemus_state5:
	ld a,(hl)
	cp 8
	jr c,update_polyphemus_state5_1
	cp 16
	jr c,update_polyphemus_state5_2
	cp 24
	jr c,update_polyphemus_state5_3
	cp 128
	jr c,update_polyphemus_state5_4
	cp 144
	jr c,update_polyphemus_state5_2
	cp 160
	jr c,update_polyphemus_state5_1
	xor a
	ld (boss_polyphemus_eye_frame),a
	jp update_polyphemus_go_to_state2
update_polyphemus_state5_1:
	ld a,5*6
	jr update_polyphemus_state5_continue
update_polyphemus_state5_2:
	ld a,4*6
	jr update_polyphemus_state5_continue
update_polyphemus_state5_3:
	ld a,3*6
	jr update_polyphemus_state5_continue
update_polyphemus_state5_4:
	; fire:
	and #03
	jp nz,update_polyphemus_draw

	; fire at a place near player, but not exactly:
	call random
	and #3f
	sub 32
	ld c,a
	ld a,(player_y)
	push af
		add a,c
		cp 224
		jr c,update_polyphemus_state5_4_no_overflow
		xor a
update_polyphemus_state5_4_no_overflow:
		ld (player_y),a
		ld de,#0300
		call update_boss_fire_bullet
	pop af
	ld (player_y),a
	jr update_polyphemus_draw

update_polyphemus_state4_continue:
update_polyphemus_state5_continue:
	ld (boss_polyphemus_eye_frame),a
	jr update_polyphemus_draw

	; spawn enemies
update_polyphemus_state6:
	ld a,(hl)
	or a
	jr z,update_polyphemus_state6_done
	cp 32
	jr c,update_polyphemus_state6_warn
	jr z,update_polyphemus_state6_spawn
	jr update_polyphemus_draw
update_polyphemus_state6_done:
	ld (boss_polyphemus_arm_frame),a
	jp update_polyphemus_go_to_state2
update_polyphemus_state6_warn:
	ld a,1
	ld (boss_polyphemus_arm_frame),a
	jr update_polyphemus_draw
update_polyphemus_state6_spawn:
	ld hl,enemy_wave_types+15*ENEMY_WAVE_STRUCT_SIZE
	call spawn_enemy_wave
	jr update_polyphemus_draw

	; charge!
update_polyphemus_state7:
	ld a,1
	ld (boss_polyphemus_arm_frame),a
	ld hl,boss_x
	ld a,(hl)
	or a
	ld a,8
	jp z,update_polyphemus_go_to_state_a
	dec (hl)
	jr update_polyphemus_draw

	; back from charge
update_polyphemus_state8:
	xor a
	ld (boss_polyphemus_arm_frame),a
	ld a,(hl)
	and #03
	jr nz,update_polyphemus_draw
	ld hl,boss_x
	ld a,(hl)
	cp 21
	jp z,update_polyphemus_go_to_state2
	inc (hl)
	jr update_polyphemus_draw


;-----------------------------------------------
update_polyphemus_clear:
	; clear sprites:
	ld c,200
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),c
	ld a,(boss_state)
	cp 6
	jr z,update_polyphemus_clear_skip_sprites
	ld hl,enemy_sprite_attributes
	ld (hl),c
	ld hl,enemy_sprite_attributes+4
	ld (hl),c
update_polyphemus_clear_skip_sprites:

	ld de,(boss_previous_ptr)
	ld a,d
	or a
	ret z
	dec de		; in case we had the "forward arm" frame
	dec de
	ld bc,#0b0a
	call clear_tile_enemy
	jp update_boss_clear_laser


;-----------------------------------------------
update_polyphemus_draw:
	call update_polyphemus_clear
	call get_boss_ptr

	ex de,hl	; de ptr to draw polyphemus!
	ld (boss_previous_ptr),de

	ld bc,#0708	; 8x7 is the size of the main body
	ld hl,boss1_frames
	push de
		call copy_non_empty_enemy_tiles
	pop de

	ld bc,4*MAP_BUFFER_WIDTH+7
	ld hl,boss1_frames+8*7
	call update_boss_draw_thruster

	ld hl,boss1_frames+8*7+3
	ld a,(boss_polyphemus_eye_frame)
	ld b,0
	ld c,a
	add hl,bc
	call update_polyphemus_draw_eye
 	ld a,(boss_polyphemus_leg_frame)
 	or a
 	jr nz,update_polyphemus_draw_legs1
 	ld hl,boss1_frames+8*7+3+6*6+6*5*2
 	jr update_polyphemus_draw_legs_chosen
update_polyphemus_draw_legs1:
 	ld hl,boss1_frames+8*7+3+6*6+6*5*2+4*4
update_polyphemus_draw_legs_chosen:
 	call update_polyphemus_draw_legs

 	ld a,(boss_polyphemus_arm_frame)
 	or a
 	jr nz,update_polyphemus_draw_arm1
 	ld hl,boss1_frames+8*7+3+6*6+6*5
 	jr update_polyphemus_draw_arm_chosen
update_polyphemus_draw_arm1:
 	ld hl,boss1_frames+8*7+3+6*6
update_polyphemus_draw_arm_chosen:
 	call update_polyphemus_draw_arm

 	; laser:
 	ld hl,3*MAP_BUFFER_WIDTH
 	add hl,de
 	ld de,boss1_frames+8*7+3+6*6+6*5*2+4*4*2 ; laser tile ptr
 	call update_boss_draw_laser

	; eye/shoulder sprites:
	ld a,(boss_x)
	cp 30
	jp p,update_polyphemus_draw_no_shoulder_sprite

	add a,a
	add a,a
	add a,a
	add a,18
	ld c,a

	ld a,(boss_y)
	add a,4	; we need to add this first, otherwise, coordinate is wrong for negative y coordinates
	add a,a
	add a,a
	add a,a
	add a,5
	ld b,a
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),a
	inc hl
	ld (hl),c
	inc hl
	ld a,(boss_polyphemus_arm_frame)
	or a
	jr z,update_polyphemus_draw_arm1_sprite
	ld (hl),(POLYPHEMUS_FIRST_SPRITE+1)*4
	jr update_polyphemus_draw_arm_sprite_drawn
update_polyphemus_draw_arm1_sprite:
	ld (hl),POLYPHEMUS_FIRST_SPRITE*4
update_polyphemus_draw_arm_sprite_drawn:
	inc hl
	ld (hl),COLOR_DARK_BLUE
update_polyphemus_draw_no_shoulder_sprite:
	ld e,COLOR_YELLOW
	ld hl,boss_hit_gfx
	ld a,(hl)
	or a
	jr z,update_polyphemus_draw_no_eye_sprite_flash
	ld e,COLOR_RED
	dec (hl)
update_polyphemus_draw_no_eye_sprite_flash:

	ld a,(boss_polyphemus_eye_frame)
	cp 6
	jr z,update_polyphemus_draw_small_eye_sprite
	cp 12
	jr z,update_polyphemus_draw_large_eye_sprite
	ret
update_polyphemus_draw_small_eye_sprite:
	ld hl,enemy_sprite_attributes
	ld a,b
	add a,-22
	ld (hl),a
	inc hl
	ld a,c
	add a,-16
	ld (hl),a
	inc hl
	ld (hl),(POLYPHEMUS_FIRST_SPRITE+4)*4
	inc hl
	ld (hl),e
	ret
update_polyphemus_draw_large_eye_sprite:
	ld hl,enemy_sprite_attributes
	ld a,b
	add a,-22
	ld (hl),a
	inc hl
	ld a,c
	add a,-16
	ld (hl),a
	inc hl
	ld (hl),(POLYPHEMUS_FIRST_SPRITE+2)*4
	inc hl
	ld (hl),e
	inc hl

	ld a,b
	add a,-6
	ld (hl),a
	inc hl
	ld a,c
	add a,-16
	ld (hl),a
	inc hl
	ld (hl),(POLYPHEMUS_FIRST_SPRITE+3)*4
	inc hl
	ld (hl),e
	ret


; - hl: eye frame to draw
update_polyphemus_draw_eye:
	push de
		ld bc,2*MAP_BUFFER_WIDTH
		ex de,hl
			add hl,bc
		ex de,hl
		ld bc,#0302
		call copy_non_empty_enemy_tiles
	pop de
	ret

update_polyphemus_draw_legs:
	push de
		ld bc,7*MAP_BUFFER_WIDTH+3
		ex de,hl
			add hl,bc
		ex de,hl
		ld bc,#0404
		call copy_non_empty_enemy_tiles
	pop de
	ret

update_polyphemus_draw_arm:
	push de
		ld bc,4*MAP_BUFFER_WIDTH-2
		ex de,hl
			add hl,bc
		ex de,hl
		ld bc,#0506
		call copy_non_empty_enemy_tiles
	pop de
	ret

