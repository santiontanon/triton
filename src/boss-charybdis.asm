;-----------------------------------------------
update_charybdis:
	call update_boss_check_if_hit
	jr z,update_charybdis_not_hit

	; boss health reached 0!
	; boss dead:
	xor a
	ld (boss_state_cycle),a
	ld a,7	; death state
	ld (boss_state),a
	call update_charybdis_clear
	ld hl,boss_x
	inc (hl)
	inc hl
	inc (hl)

	call StopMusic
	ld hl,SFX_big_explosion
	call play_SFX_with_high_priority

update_charybdis_not_hit:
	ld a,(boss_state)
	ld hl,boss_state_cycle
	inc (hl)
 	dec a
 	jr z,update_charybdis_state1
 	dec a
 	jp z,update_charybdis_state2
 	dec a
 	jp z,update_charybdis_state3
 	dec a
 	jp z,update_charybdis_state4
 	dec a
 	jp z,update_charybdis_state5
 	dec a
 	jp z,update_charybdis_state6
 	dec a
 	jp z,update_boss_explosion
	ret


;-----------------------------------------------
; going left:
update_charybdis_state1:
	call update_charybdis_fire_bullets

	ld hl,boss_state_cycle
	ld a,(hl)
	or a
	jp nz,update_charybdis_draw
	ld de,boss_charybdis_moving_speed
	ld a,(de)
	ld (hl),a

	; check if charybdis is still turning:
	ld hl,boss_charybdis_shape+1
	ld a,(hl)
	cp 4
	jr c,update_charybdis_state1_no_turn

	; check if head is to be detached
	ld a,(player_tile_x)
	ld hl,scroll_x_tile
	sub (hl)
	ld b,a
	ld a,(boss_x)
	cp b
	jp m,update_charybdis_state1_do_not_detach_head
	cp 26
	jp p,update_charybdis_state1_do_not_detach_head
	ld a,(boss_charybdis_time_without_opening)
	cp 32	; if it's been a while without opening the head, just do it!
	jr nc,update_charybdis_state1_detach_head
	call random
	and #0f
	jr z,update_charybdis_state1_detach_head
update_charybdis_state1_do_not_detach_head:

	; chance of turning:
	call random
	and #03
	jr z,update_charybdis_state1_turn
update_charybdis_state1_no_turn:
	call charybdis_update_body_shape_advance
	ld hl,boss_x
	dec (hl)
	ld a,(hl)
	cp -(CHARYBDIS_LENGTH+1)
	jp p,update_charybdis_draw
	ld a,32
	ld (boss_x),a
	call random
	and #0f
	inc a
	ld (boss_y),a
	jp update_charybdis_draw


update_charybdis_state1_detach_head:
	xor a
	ld (boss_charybdis_time_without_opening),a
	ld hl,boss_state
	ld (hl),4
	inc hl	; boss_state_cycle
	ld (hl),0
	ld hl,boss_x
	ld de,boss_charybdis_head_x
	ldi
	ldi
	jp update_charybdis_draw


update_charybdis_state1_turn:
	ld a,(boss_x)
	cp 28
	jp p,update_charybdis_state1_no_turn
	cp 2
	jp m,update_charybdis_state1_no_turn
	ld a,(player_tile_y)
	ld hl,boss_y
	sub (hl)
	cp 4
	jp p,update_charybdis_state1_turn_down
	cp -3
	jp m,update_charybdis_state1_turn_up
	jr update_charybdis_state1_no_turn

update_charybdis_state1_turn_up:
	ld hl,boss_y
	ld a,(hl)
	cp 4
	jp m,update_charybdis_state1_no_turn
	dec (hl)
	ld hl,boss_state
	ld (hl),2
	inc hl
	ld (hl),0

	call charybdis_shift_body_shape_right

	ld hl,boss_charybdis_shape
	ld (hl),1
	inc hl
	ld (hl),0
	jr update_charybdis_state2

update_charybdis_state1_turn_down:
	ld a,(boss_y)
	cp 15
	jp p,update_charybdis_state1_no_turn
	ld hl,boss_state
	ld (hl),3
	inc hl	; boss_charybdis_shape+1
	ld (hl),0

	call charybdis_shift_body_shape_right
	ld hl,boss_charybdis_shape
	ld (hl),2
	inc hl	; boss_charybdis_shape+1
	ld (hl),0
	jr update_charybdis_state3


;-----------------------------------------------
; going up
update_charybdis_state2:
	call update_charybdis_fire_bullets

	ld hl,boss_state_cycle
	ld a,(hl)
	or a
	jp nz,update_charybdis_draw
	ld de,boss_charybdis_moving_speed
	ld a,(de)
	ld (hl),a

	; check if we want to turn:
	ld hl,boss_charybdis_shape+1
	ld a,(hl)
	cp 4
	jr c,update_charybdis_state2_no_turn
	call random
	and #03
	jr z,update_charybdis_state2_turn
update_charybdis_state2_no_turn:
	call charybdis_update_body_shape_advance
	ld hl,boss_y
	dec (hl)
	ld a,(hl)
	or a
	jp nz,update_charybdis_draw

update_charybdis_state3_turn:
	ld hl,boss_y
	inc (hl)
update_charybdis_state2_turn:
	ld hl,boss_x
	dec (hl)
	ld hl,boss_state
	ld (hl),1
	inc hl
	xor a
	ld (hl),a

	call charybdis_shift_body_shape_right
	xor a
	ld hl,boss_charybdis_shape
	ld (hl),a
	inc hl	; boss_charybdis_shape+1
	ld (hl),a
	jp update_charybdis_state1


;-----------------------------------------------
; going down
update_charybdis_state3:
	call update_charybdis_fire_bullets

	ld hl,boss_state_cycle
	ld a,(hl)
	or a
	jp nz,update_charybdis_draw
	ld de,boss_charybdis_moving_speed
	ld a,(de)
	ld (hl),a

	; check if we want to turn:
	ld hl,boss_charybdis_shape+1
	ld a,(hl)
	cp 4
	jr c,update_charybdis_state3_no_turn
	call random
	and #03
	jr z,update_charybdis_state3_turn
update_charybdis_state3_no_turn:
	call charybdis_update_body_shape_advance
	ld hl,boss_y
	inc (hl)
	ld a,(hl)
	cp 18
	jp nz,update_charybdis_draw
	jr update_charybdis_state3_turn


;-----------------------------------------------
; detaching head
update_charybdis_state4:
	ld a,(boss_state_cycle)
	cp 16
	jr z,update_charybdis_state4_left
	cp 32
	jr z,update_charybdis_state4_left
	cp 48
	jr z,update_charybdis_state4_to_state5
	jp update_charybdis_draw

update_charybdis_state4_to_state5:
	ld hl,boss_state
	ld (hl),5
	inc hl
	ld (hl),0
	call random
	and #01
	ld (boss_charybdis_head_direction),a
	; fire laser:
	ld a,(boss_charybdis_head_x)
	add a,2
	ld (boss_laser_length),a
	jp update_charybdis_draw

update_charybdis_state4_left:
	ld hl,boss_charybdis_head_x
	dec (hl)
	jp update_charybdis_draw


;-----------------------------------------------
; firing laser:
update_charybdis_state5:
	ld a,(boss_state_cycle)
	and #03
	jp nz,update_charybdis_draw

	ld a,(boss_charybdis_head_direction)
	or a
	jr z,update_charybdis_state5_up
update_charybdis_state5_down:
	ld hl,boss_charybdis_head_y
	ld a,(hl)
	cp 18
	jr z,update_charybdis_state5_switch
	inc (hl)
	inc a
	ld hl,boss_y
	cp (hl)
	jr z,update_charybdis_state5_done
	jp update_charybdis_draw

update_charybdis_state5_up:
	ld hl,boss_charybdis_head_y
	ld a,(hl)
	or a
	jr z,update_charybdis_state5_switch
	dec (hl)
	dec a
	ld hl,boss_y
	cp (hl)
	jr z,update_charybdis_state5_done
	jp update_charybdis_draw

update_charybdis_state5_switch:
	ld hl,boss_charybdis_head_direction
	ld a,(hl)
	xor #01
	ld (hl),a
	jp update_charybdis_draw

update_charybdis_state5_done:
	ld hl,boss_state
	ld (hl),6
	inc hl
	ld (hl),0
	xor a
	ld (boss_laser_length),a
	jp update_charybdis_draw


;-----------------------------------------------
; reattaching head:
update_charybdis_state6:
	ld a,(boss_state_cycle)
	cp 16
	jr z,update_charybdis_state6_right
	cp 32
	jr z,update_charybdis_state6_right
	cp 48
	jr z,update_charybdis_state6_to_state1
	jp update_charybdis_draw

update_charybdis_state6_to_state1:
	ld hl,boss_state
	ld (hl),1
	inc hl
	ld (hl),-6
	jp update_charybdis_draw

update_charybdis_state6_right:
	ld hl,boss_charybdis_head_x
	inc (hl)
	jp update_charybdis_draw


;-----------------------------------------------
update_charybdis_fire_bullets:
	ld a,(boss_x)
	or a
	ret m
	cp 31
	ret p
	ld de,#0101
	call random
	and #0f
	jp z,update_boss_fire_bullet
	ret


;-----------------------------------------------
charybdis_shift_body_shape_right:
	ld hl,boss_charybdis_shape+5*2-1
	ld de,boss_charybdis_shape+6*2-1
	ld bc,5*2
	lddr
	ret

;-----------------------------------------------
charybdis_update_body_shape_advance:
	ld hl,boss_charybdis_time_without_opening
	inc (hl)
	ld hl,boss_charybdis_shape+1
	inc (hl)
	; search the last segment:
	dec hl
charybdis_update_body_shape_advance_loop:	
	inc hl
	inc hl
	ld a,(hl)
	inc a
	jr nz,charybdis_update_body_shape_advance_loop
	; found the end:
	dec hl
	dec (hl)
	ld a,(hl)
	or a
	ret nz
	dec hl
	ld (hl),#ff
	ret


;-----------------------------------------------
; erases the boss from the screen
update_charybdis_clear:
	; clear sprites:
	ld c,200
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),c
	ld l,enemy_sprite_attributes&#00ff  ; assuming that h does not change!
; 	ld hl,enemy_sprite_attributes
	ld (hl),c

update_charybdis_clear_skip_sprites:
	; clear detached head:
	ld de,(boss_charybdis_head_previous_ptr)
	ld a,d
	or a
	jr z,update_charybdis_clear_skip_detached_head
	ld bc,#0404
	call clear_tile_enemy

update_charybdis_clear_skip_detached_head:
	ld de,(boss_previous_ptr)
	ld a,d
	or a
	ret z

	; clear the different blocks:
	ld ix,boss_charybdis_shape
update_charybdis_clear_loop:
	ld a,(ix)
	or a
	jr z,update_charybdis_clear_left
	dec a
	jr z,update_charybdis_clear_up
	dec a
	jr z,update_charybdis_clear_down
	ld de,(boss_charybdis_tail_previous_ptr)
	ld bc,#0303
	call clear_tile_enemy
	jp update_boss_clear_laser
update_charybdis_clear_left:
	ld a,(ix+1)
	add a,4
	ld b,3
	ld c,a
	push de
		call clear_tile_enemy
	pop hl
	ld b,0
	ld c,(ix+1)
	add hl,bc
	ex de,hl
	inc ix
	inc ix
	jr update_charybdis_clear_loop
update_charybdis_clear_up:
	ld a,(ix+1)
	add a,4
	ld b,a
	ld c,3
	push de
		call clear_tile_enemy
	pop hl
	ld de,MAP_BUFFER_WIDTH
	ld b,(ix+1)
update_charybdis_clear_up_loop:
	add hl,de
	djnz update_charybdis_clear_up_loop
	ex de,hl
	inc de
	inc ix
	inc ix
	jr update_charybdis_clear_loop
update_charybdis_clear_down:
	ld b,(ix+1)
	inc b
	ld a,b
	ex de,hl
		ld de,-MAP_BUFFER_WIDTH
update_charybdis_clear_down_loop:
		add hl,de
		djnz update_charybdis_clear_down_loop
	ex de,hl
	add a,4
	ld b,a
	ld c,3
	push de
		call clear_tile_enemy
	pop de
	inc de
	inc ix
	inc ix
	jr update_charybdis_clear_loop


;-----------------------------------------------
update_charybdis_draw:
	call update_charybdis_clear
	call get_boss_ptr
	ld (boss_previous_ptr),hl
	ex de,hl	; de ptr to draw the boss

	ld ix,boss_charybdis_shape
	ld c,(ix+1)	; length
	ld a,c
	cp 4
	jr c,update_charybdis_draw_no_length_reset
	xor a
update_charybdis_draw_no_length_reset:
	ld b,a	; length drawn so far
	ld a,(ix)
	inc ix
	inc ix
	or a
	jp z,update_charybdis_draw_left_first
	dec a
	jp z,update_charybdis_draw_up_first
	; dec a
	; jr z,update_charybdis_draw_down_first

	; c: has length
	; de: has draw ptr
	; ix: points to the next shape direction
update_charybdis_draw_down_first:
	ex de,hl
		ld de,-MAP_BUFFER_WIDTH
		add hl,de
	ex de,hl
update_charybdis_draw_down:
	ld a,c
	cp 5
	jr c,update_charybdis_draw_down_turn
	push bc
	push de
		bit 0,b
		jr nz,update_charybdis_draw_down_frame1
update_charybdis_draw_down_frame0:
		ld hl,boss3_frames + 4*3*3+4*4 + 3*1*5
		jr update_charybdis_draw_down_frame_set
update_charybdis_draw_down_frame1:
		ld hl,boss3_frames + 4*3*3+4*4 + 3*1*4	
update_charybdis_draw_down_frame_set:	
		ld bc,#0103
		call copy_non_empty_enemy_tiles
	pop de
	pop bc
	inc b
	dec c
	jr update_charybdis_draw_down_first
update_charybdis_draw_down_turn:
	ld a,(ix)
	or a	; left
	jr z,update_charybdis_draw_down_turn_from_left
	; draw tail down:
	ld a,(ix-1)	; check if the tail has to be offset
	dec a
	jr z,update_charybdis_draw_down_tail_draw_direct
	dec a
	jr z,update_charybdis_draw_down_tail_draw_offs1
	ld hl,-2*MAP_BUFFER_WIDTH
	jr update_charybdis_draw_down_tail_draw
update_charybdis_draw_down_tail_draw_offs1:
	ld hl,-MAP_BUFFER_WIDTH
update_charybdis_draw_down_tail_draw:
	add hl,de
	ex de,hl
update_charybdis_draw_down_tail_draw_direct:	
	ld (boss_charybdis_tail_previous_ptr),de
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*2
	ld a,3
	ld bc,3
	call copy_enemy_tiles
; 	ld bc,#0303
; 	call copy_non_empty_enemy_tiles
	jp update_charybdis_draw_face

update_charybdis_draw_down_turn_from_left:	
	push bc
		ex de,hl
			dec c
			jr z,update_charybdis_draw_down_turn_from_left_loop_done
			ld de,-MAP_BUFFER_WIDTH
update_charybdis_draw_down_turn_from_left_loop:			
			add hl,de
			dec c
			jr nz,update_charybdis_draw_down_turn_from_left_loop
update_charybdis_draw_down_turn_from_left_loop_done:
		ex de,hl
	pop bc
	; check b for frame
	bit 0,b
	jr nz,update_charybdis_draw_down_turn_from_left_frame1
update_charybdis_draw_down_turn_from_left_frame0:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*0
	jr update_charybdis_draw_down_turn_from_left_frame_set
update_charybdis_draw_down_turn_from_left_frame1:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*1
update_charybdis_draw_down_turn_from_left_frame_set:
	push bc
		ld bc,#0404
		push de
			call copy_non_empty_enemy_tiles
		pop de
	pop bc
	inc de
	inc de
	inc de
	inc de
	ld c,(ix+1)
	inc ix
	inc ix
	jp update_charybdis_draw_left

	; c: has length
	; de: has draw ptr
	; ix: points to the next shape direction
update_charybdis_draw_up_first:
	ld hl,MAP_BUFFER_WIDTH*4
	add hl,de
	ex de,hl
update_charybdis_draw_up:
	ld a,c
	cp 5
	jr c,update_charybdis_draw_up_turn
	push bc
	push de
		bit 0,b
		jr nz,update_charybdis_draw_up_frame1
update_charybdis_draw_up_frame0:
		ld hl,boss3_frames + 4*3*3+4*4 + 3*1*2
		jr update_charybdis_draw_up_frame_set
update_charybdis_draw_up_frame1:
		ld hl,boss3_frames + 4*3*3+4*4 + 3*1*3	
update_charybdis_draw_up_frame_set:	
		ld bc,#0103
		call copy_non_empty_enemy_tiles
	pop de
	pop bc
	inc b
	dec c
	ld hl,MAP_BUFFER_WIDTH
	add hl,de
	ex de,hl
	jr update_charybdis_draw_up
update_charybdis_draw_up_turn:
	ld a,(ix)
	or a	; left
	jr z,update_charybdis_draw_up_turn_from_left
	; draw tail up:
	ld a,(ix-1)	; check if the tail has to be offset
	dec a
	jr z,update_charybdis_draw_up_tail_draw_offs2
	dec a
	jr z,update_charybdis_draw_up_tail_draw_offs1
	jr update_charybdis_draw_up_tail_draw_direct
update_charybdis_draw_up_tail_draw_offs2:
	ld hl,-2*MAP_BUFFER_WIDTH
	jr update_charybdis_draw_up_tail_draw
update_charybdis_draw_up_tail_draw_offs1:
	ld hl,-MAP_BUFFER_WIDTH
update_charybdis_draw_up_tail_draw:
	add hl,de
	ex de,hl
update_charybdis_draw_up_tail_draw_direct:
	ld (boss_charybdis_tail_previous_ptr),de
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3
	ld a,3
	ld bc,3
	call copy_enemy_tiles
; 	ld bc,#0303
; 	call copy_non_empty_enemy_tiles
	jp update_charybdis_draw_face

update_charybdis_draw_up_turn_from_left:	
	push bc
		ex de,hl
			ld a,4
			sub c
			jr z,update_charybdis_draw_up_turn_from_left_loop_done
			ld c,a
			ld de,-MAP_BUFFER_WIDTH
update_charybdis_draw_up_turn_from_left_loop:			
			add hl,de
			dec c
			jr nz,update_charybdis_draw_up_turn_from_left_loop
update_charybdis_draw_up_turn_from_left_loop_done:
		ex de,hl
	pop bc
	; check b for frame
	bit 0,b
	jr nz,update_charybdis_draw_up_turn_from_left_frame1
update_charybdis_draw_up_turn_from_left_frame0:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*4
	jr update_charybdis_draw_up_turn_from_left_frame_set
update_charybdis_draw_up_turn_from_left_frame1:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*5
update_charybdis_draw_up_turn_from_left_frame_set:
	push bc
		ld bc,#0404
		push de
			call copy_non_empty_enemy_tiles
		pop de
	pop bc
	ld hl,MAP_BUFFER_WIDTH+4
	add hl,de
	ex de,hl
	ld c,(ix+1)
	inc ix
	inc ix
	jr update_charybdis_draw_left

	; c: has length
	; de: has draw ptr
	; ix: points to the next shape direction
update_charybdis_draw_left_first:
	; skip head:
	inc de
	inc de
	inc de
	inc de
update_charybdis_draw_left:
	ld a,c
	cp 5
	jr c,update_charybdis_draw_left_turn
	push bc
	push de
		bit 0,b
		jr nz,update_charybdis_draw_left_frame1
update_charybdis_draw_left_frame0:
		ld hl,boss3_frames+4*3*3+4*4
		jr update_charybdis_draw_left_frame_set
update_charybdis_draw_left_frame1:
		ld hl,boss3_frames+4*3*3+4*4+3*1	
update_charybdis_draw_left_frame_set:	
		ld bc,#0301
		call copy_non_empty_enemy_tiles
	pop de
	pop bc
	inc b
	dec c
	inc de
	jr update_charybdis_draw_left

update_charybdis_draw_left_turn:
	ld a,(ix)
	dec a	; up
	jr z,update_charybdis_draw_left_turn_from_up
	dec a	; down
	jr z,update_charybdis_draw_left_turn_from_down
	; draw tail left:
	ld a,(ix-1)	; check if the tail has to be offset
	dec a
	jr z,update_charybdis_draw_left_tail_draw_offs3
	dec a
	jr z,update_charybdis_draw_left_tail_draw_offs2
	dec a
	jr z,update_charybdis_draw_left_tail_draw_offs1
	jr update_charybdis_draw_left_tail_draw
update_charybdis_draw_left_tail_draw_offs3:
	dec de
update_charybdis_draw_left_tail_draw_offs2:
	dec de
update_charybdis_draw_left_tail_draw_offs1:
	dec de
update_charybdis_draw_left_tail_draw:
	ld (boss_charybdis_tail_previous_ptr),de
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6
	ld a,3
	ld bc,3
	call copy_enemy_tiles
	;call copy_non_empty_enemy_tiles
	jr update_charybdis_draw_face

update_charybdis_draw_left_turn_from_down:
	push bc
		ex de,hl
			ld de,-(MAP_BUFFER_WIDTH+4)
			add hl,de
			ld b,0
			add hl,bc
		ex de,hl
	pop bc
	; check b for frame
	bit 0,b
	jr nz,update_charybdis_draw_left_turn_from_down_frame1
update_charybdis_draw_left_turn_from_down_frame0:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*6
	jr update_charybdis_draw_left_turn_from_down_frame_set
update_charybdis_draw_left_turn_from_down_frame1:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*7
update_charybdis_draw_left_turn_from_down_frame_set:
	push bc
		ld bc,#0404
		push de
			call copy_non_empty_enemy_tiles
		pop de
	pop bc
	ex de,hl
		ld de,1-MAP_BUFFER_WIDTH
		add hl,de
	ex de,hl
	ld c,(ix+1)
	inc ix
	inc ix
	jp update_charybdis_draw_down

update_charybdis_draw_left_turn_from_up:
	push bc
		ex de,hl
			ld de,-4
			add hl,de
			ld b,0
			add hl,bc
		ex de,hl
	pop bc
	; check b for frame
	bit 0,b
	jr nz,update_charybdis_draw_left_turn_from_up_frame1
update_charybdis_draw_left_turn_from_up_frame0:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*2
	jr update_charybdis_draw_left_turn_from_up_frame_set
update_charybdis_draw_left_turn_from_up_frame1:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*3
update_charybdis_draw_left_turn_from_up_frame_set:
	push bc
		ld bc,#0404
		push de
			call copy_non_empty_enemy_tiles
		pop de
	pop bc
	ex de,hl
		ld de,4*MAP_BUFFER_WIDTH+1
		add hl,de
	ex de,hl
	ld c,(ix+1)
	inc ix
	inc ix
	jp update_charybdis_draw_up


;-----------------------------------------------
update_charybdis_draw_face:	
	call get_boss_ptr
	ld (boss_previous_ptr),hl
	ex de,hl	; de ptr to draw the boss

	ld a,(boss_state)
	cp 4	; head detached
	jr nc,update_charybdis_draw_organic_face_left

	ld a,(boss_charybdis_moving_direction)
	or a
	jr z,update_charybdis_draw_face_left
	dec a
	jr z,update_charybdis_draw_face_up
update_charybdis_draw_face_down:
	; eye sprite:
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	call update_charybdis_draw_head_pixel_coordinates
	add a,7
	ld (hl),a
	inc hl
	ld (hl),c
	inc hl
	ld (hl),(CHARYBDIS_FIRST_SPRITE)*4
	inc hl
	ld (hl),COLOR_RED
	ld bc,#0403	; 3x4 is the size of the head (left)
	ld hl,boss3_frames+4*3*2
	jr update_charybdis_draw_face_ptr_set

update_charybdis_draw_face_up:
	; eye sprite:
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	call update_charybdis_draw_head_pixel_coordinates
	ld (hl),b
	inc hl
	ld (hl),c
	inc hl
	ld (hl),(CHARYBDIS_FIRST_SPRITE)*4
	inc hl
	ld (hl),COLOR_RED
	ld bc,#0403	; 3x4 is the size of the head (left)
	ld hl,boss3_frames+4*3
	jr update_charybdis_draw_face_ptr_set

update_charybdis_draw_face_left:
	; tooth sprite:
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld a,(boss_x)
	or a
	jp m,update_charybdis_draw_face_left_no_sprite
	cp 32
	jp p,update_charybdis_draw_face_left_no_sprite
	call update_charybdis_draw_head_pixel_coordinates
	ld a,b
	add a,16
	ld (hl),a
	inc hl
	ld (hl),c
	inc hl
	ld (hl),(CHARYBDIS_FIRST_SPRITE+1)*4
	inc hl
	ld (hl),COLOR_YELLOW
update_charybdis_draw_face_left_no_sprite:
	ld bc,#0304	; 4x3 is the size of the head (left)
	ld hl,boss3_frames

update_charybdis_draw_face_ptr_set:
	jp copy_non_empty_enemy_tiles

update_charybdis_draw_organic_face_left:
	; eye sprite:
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	call update_charybdis_draw_head_pixel_coordinates
	ld (hl),b
	inc hl
	ld a,c
	add a,16
	ld (hl),a
	inc hl
	ld (hl),(CHARYBDIS_FIRST_SPRITE+2)*4
	inc hl
	ld (hl),COLOR_RED
	inc de
	inc de
	ld hl,boss_hit_gfx
	ld a,(hl)
	or a
	jr z,update_charybdis_draw_organic_face_left_not_hit
update_charybdis_draw_organic_face_left_hit:
	dec (hl)	

	; if the boss is hit, maybe its movement speed changes:
	ld hl,boss_charybdis_moving_speed
	ld (hl),-6
	ld a,(boss_health)
	cp CHARYBDIS_HEALTH/2
	jr nc,update_charybdis_speed_set
	inc (hl)
	cp CHARYBDIS_HEALTH/3
	jr nc,update_charybdis_speed_set
	inc (hl)
	cp CHARYBDIS_HEALTH/4
	jr nc,update_charybdis_speed_set
	inc (hl)
	cp 8
	jr nc,update_charybdis_speed_set
	inc (hl)
update_charybdis_speed_set:


	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*8 + 2*3
	jr update_charybdis_draw_organic_face_left_draw
update_charybdis_draw_organic_face_left_not_hit:
	ld hl,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*8
update_charybdis_draw_organic_face_left_draw:
	ld bc,#0302
	call copy_non_empty_enemy_tiles

	; draw detached head:
	ld hl,boss_charybdis_head_x
	call get_boss_ptr_hl_set
	ex de,hl
	ld (boss_charybdis_head_previous_ptr),de
	ld hl,boss3_frames + 3*4*3
	ld bc,#0404
	call copy_non_empty_enemy_tiles

	; laser:
 	ld hl,(boss_charybdis_head_previous_ptr)
 	ld bc,2*MAP_BUFFER_WIDTH+1
 	add hl,bc
 	ld de,boss3_frames + 3*4*3+4*4 + 3*1*6 + 3*3*3 + 4*4*8 + 2*3*2
 	jp update_boss_draw_laser


update_charybdis_draw_head_pixel_coordinates:
	ld a,(boss_x)
	add a,a
	add a,a
	add a,a
	ld c,a
	ld a,(boss_y)
	add a,a
	add a,a
	add a,a
	ld b,a
	ret
