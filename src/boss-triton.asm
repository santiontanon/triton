;-----------------------------------------------
update_triton:
	call update_boss_check_if_hit
	jr z,update_triton_not_hit

	; boss health reached 0!
	; boss dead:
	xor a
	ld (boss_state_cycle),a
	ld a,8	; death state
	ld (boss_state),a
	call update_triton_clear
	ld hl,boss_x
	inc (hl)
	inc hl
	inc (hl)

	call StopMusic
	ld hl,SFX_big_explosion
	call play_SFX_with_high_priority

update_triton_not_hit:
	ld a,(boss_state)
	ld hl,boss_state_cycle
	inc (hl)
  	dec a
  	jr z,update_triton_state1	; enter
  	dec a
  	jr z,update_triton_state2	; choose direction
  	dec a
  	jp z,update_triton_state3	; move
  	dec a
  	jp z,update_triton_state4	; cover
  	dec a
  	jp z,update_triton_state5	; fire!
 	dec a
  	jp z,update_triton_state6	; trident advancing
 	dec a
  	jp z,update_triton_state7	; trident retreating
 	dec a
 	jp z,update_boss_explosion
	ret


;-----------------------------------------------
; - Triton enters from the right
; hl: boss_state_cycle
update_triton_state1:
	ld a,(hl)
	and #07
	jp nz,update_triton_draw
	ld hl,boss_x
	dec (hl)
	ld a,(hl)
	cp 18
	jp nz,update_triton_draw
	ld (boss_state_cycle),a	; a = 0 here
	ld a,2
	ld (boss_state),a
	jp update_triton_draw


;-----------------------------------------------
; pick a position at random to move to
update_triton_state2:
	ld hl,boss_triton_body_frame
	ld (hl),1

	ld a,(boss_state_cycle)
	and #07
	jp nz,update_triton_draw

	call random
	and #0f
	add a,6
	ld (boss_target_x),a
	call random
	and #0f
	sub 4
	ld (boss_target_y),a
	call random
	and #03
	add a,a	; 0,2,4,6: 0,2 go as is, 4 goes to cover, and 6 goes to throw trident
	cp 4
	jr z,update_triton_state2_cover
	cp 6
	jr z,update_triton_state2_throw
	ld (hl),a	; hl should still have boss_triton_body_frame
	ld hl,boss_state
	inc (hl)
	jp update_triton_draw

update_triton_state2_cover:
	ld (hl),3
	ld hl,boss_state
	ld (hl),4
	inc hl
	ld (hl),0	; boss_state_cycle
	jp update_triton_draw

update_triton_state2_throw:
	ld (hl),5
	ld hl,boss_state
	ld (hl),5
	inc hl
	ld (hl),0	; boss_state_cycle
	ld a,(boss_x)
	ld (boss_triton_trident_x),a
	ld a,(boss_y)
	add a,4
	ld (boss_triton_trident_y),a	
	jp update_triton_draw


;-----------------------------------------------
update_triton_state3:
; 	; fire bullets every few frames:
 	ld de,#0304
 	call random
 	and #0f
 	call z,update_boss_fire_bullet

	; movement:
	ld a,(boss_state_cycle)
	and #07
	jp nz,update_triton_draw

update_triton_state3_move:
	ld c,0
	ld a,(boss_x)
	ld hl,boss_target_x
	cp (hl)
	jr z,update_triton_state3_no_x_move
	ld c,1
	jp p,update_triton_state3_left
update_triton_state3_right:
	inc a
	jr update_triton_state3_no_x_move
update_triton_state3_left:
	dec a
update_triton_state3_no_x_move:
	ld (boss_x),a

	ld a,(boss_y)
	ld hl,boss_target_y
	cp (hl)
	jr z,update_triton_state3_no_y_move
	ld c,1
	jp p,update_triton_state3_up
update_triton_state3_down:
	inc a
	jr update_triton_state3_no_y_move
update_triton_state3_up:
	dec a
update_triton_state3_no_y_move:
	ld (boss_y),a

	ld a,c
	or a
	jp nz,update_triton_draw

	; arrived at destination!
	ld hl,boss_state
	ld (hl),2
	inc hl ; boss_state_cycle
	ld (hl),a	; a = 0
	jp update_triton_draw


;-----------------------------------------------
; cover face with trident
; hl: boss_state_cycle
update_triton_state4:
	ld a,(hl)
	cp 128
	jr nc,update_triton_state4_done

	; fire at a place near player, but not exactly:
	call random
	and #3f
	sub 32
	ld c,a
	ld a,(player_y)
	push af
		add a,c
		cp 224
		jr c,update_triton_state4_no_overflow
		xor a
update_triton_state4_no_overflow:
		ld (player_y),a
		ld de,#0304
		call update_boss_fire_bullet
	pop af
	ld (player_y),a
	jp update_triton_draw

update_triton_state4_done:
	ld hl,boss_state
	ld (hl),2	; back to moving
	inc hl ; boss_state_cycle
	ld (hl),a	; a = 0	
	jp update_triton_draw


;-----------------------------------------------
; fire trident!
; hl: boss_state_cycle
update_triton_state5:
 	ld de,#0304
 	call random
 	and #0f
 	call z,update_boss_fire_bullet

	ld a,(hl)
	cp 32
	jr c,update_triton_draw

	; switch to throw:
	ld hl,boss_triton_body_frame
	ld (hl),4
	ld hl,boss_state
	ld (hl),6
	jr update_triton_draw


;-----------------------------------------------
update_triton_state6:
 	ld de,#0304
 	call random
 	and #0f
 	call z,update_boss_fire_bullet

	ld hl,boss_triton_trident_x
	ld a,(hl)
	cp -16
	jp m,update_triton_state6_to_return
	dec (hl)
	jr update_triton_draw
update_triton_state6_to_return:
	ld hl,boss_state
	ld (hl),7
	jr update_triton_draw

;-----------------------------------------------
update_triton_state7:
 	ld de,#0304
 	call random
 	and #0f
 	call z,update_boss_fire_bullet

	ld hl,boss_x
	ld a,(hl)
	ld hl,boss_triton_trident_x
	cp (hl)
	jr z,update_triton_state7_done
	inc (hl)
	jr update_triton_draw

update_triton_state7_done:
	ld hl,boss_state
	ld (hl),2	; back to moving
	inc hl ; boss_state_cycle
	ld (hl),a	; a = 0	
	jr update_triton_draw


;-----------------------------------------------
; erases the boss from the screen
update_triton_clear:
	; clear sprites:
	ld c,200
	ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
	ld (hl),c
	ld l,enemy_sprite_attributes&#00ff  ; assuming that h does not change!
; 	ld hl,enemy_sprite_attributes
	ld (hl),c
	ld hl,enemy_sprite_attributes+4
	ld (hl),c

update_triton_clear_skip_sprites:
	; clear detached head:
	ld de,(boss_triton_trident_previous_ptr)
	ld a,d
	or a
	jr z,update_triton_clear_skip_detached_trident
	ld bc,#030d
	call clear_tile_enemy
update_triton_clear_skip_detached_trident:

	ld de,(boss_previous_ptr)
	ld a,d
	or a
	ret z
	ld bc,#100f
	jp clear_tile_enemy


;-----------------------------------------------
update_triton_draw:
	call update_triton_clear

	ld hl,0
	ld (boss_triton_trident_previous_ptr),hl
	ld a,(boss_triton_body_frame)
	cp 4
	jr c,update_triton_draw_no_horizontal_trident

	ld hl,boss_triton_trident_x
	call get_boss_ptr_hl_set
	ld (boss_triton_trident_previous_ptr),hl
	ex de,hl
	ld bc,#030d
	ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8+15*7*2 + 13*7 + 14*7 + 9*7 + 2*6
	call copy_non_empty_enemy_tiles

update_triton_draw_no_horizontal_trident:
	call get_boss_ptr
	ld (boss_previous_ptr),hl
	ex de,hl	; de ptr to draw the boss

	; head:
	push de
		inc de
		inc de
		inc de
		ld hl,boss_hit_gfx
		ld a,(hl)
		or a
		jr nz,update_triton_draw_head_hit
		ld a,(boss_triton_body_frame)
		cp 3
		jr z,update_triton_draw_head_covering	; we draw the head later in this case
		ld hl,boss4_frames
		jr update_triton_draw_head_set
update_triton_draw_head_hit:
		dec (hl)
		ld hl,boss4_frames + 7*8*2
update_triton_draw_head_set:
		ld bc,#0807
		call copy_non_empty_enemy_tiles
update_triton_draw_head_covering:

		; sprites
		ld a,(boss_x)
		sub 26
		jp p,update_triton_draw_no_sprites
		ld e,a
		ld hl,enemy_sprite_attributes+(MAX_ENEMIES-3)*4
		add a,26
		add a,a
		add a,a
		add a,a
		add a,48
		ld c,a

		ld a,(boss_triton_body_frame)
		cp 3
		ld a,(boss_y)
		jr nz,update_triton_draw_head_no_offset
		inc a
update_triton_draw_head_no_offset:

		add a,a
		add a,a
		add a,a
		dec a
		; sprite 1:
		ld b,a
		ld (hl),b
		inc hl
		ld (hl),c
		inc hl
		ld (hl),(TRITON_FIRST_SPRITE)*4
		inc hl
		ld (hl),COLOR_BLUE
		; sprite 2:
		inc e
		jr z,update_triton_draw_no_sprites
		ld hl,enemy_sprite_attributes
		add a,16
		ld b,a
		ld (hl),b
		inc hl
		ld a,c
		add a,8
		ld c,a
		ld (hl),c
		inc hl
		ld (hl),(TRITON_FIRST_SPRITE+1)*4
		inc hl
		ld (hl),COLOR_BLUE
		inc hl
		; sprite 3:
		inc e
		jr z,update_triton_draw_no_sprites
		ld a,b
		add a,16
		ld (hl),a
		inc hl
		ld a,c
		add a,8
		ld (hl),a
		inc hl
		ld (hl),(TRITON_FIRST_SPRITE+2)*4
		inc hl
		ld (hl),COLOR_BLUE	
update_triton_draw_no_sprites:
	pop hl
	
	push hl
		; hump:
		ld bc,MAP_BUFFER_WIDTH+10
		add hl,bc
		ex de,hl
		ld bc,#0705
		ld hl,boss4_frames + 7*8*3
		call copy_non_empty_enemy_tiles
	pop hl

	push hl
		; body:
		ld bc,MAP_BUFFER_WIDTH*8+1
		add hl,bc
		ex de,hl
		ld a,(boss_triton_body_frame)
		or a
		jr z,update_triton_draw_body1
		dec a
		jr z,update_triton_draw_body2
		dec a
		jr z,update_triton_draw_body3
		dec a
		jr z,update_triton_draw_body4
		dec a
		jr z,update_triton_draw_body5
update_triton_draw_body6:
		ld bc,#0709
		inc de
		inc de
		inc de
		inc de
		inc de
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8 + 15*7*2 + 13*7 + 14*7
		jr update_triton_draw_body_set
update_triton_draw_body5:
		ld bc,#070e
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8 + 15*7*2 + 13*7
		jr update_triton_draw_body_set
update_triton_draw_body4:
		ld bc,#070d
		inc de
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8 + 15*7*2
		jr update_triton_draw_body_set
update_triton_draw_body3:
		ld bc,#070f
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8 + 15*7
		dec de
		jr update_triton_draw_body_set
update_triton_draw_body2:
		ld bc,#070f
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8
		dec de
		jr update_triton_draw_body_set
update_triton_draw_body1:
		ld bc,#080e
		ld hl,boss4_frames + 7*8*3 + 5*7
update_triton_draw_body_set:
		call copy_non_empty_enemy_tiles
	pop hl

	; potentially draw the trident:
	ld a,(boss_triton_body_frame)
	cp 3
	jr z,update_triton_draw_vertical_trident
	ret

update_triton_draw_vertical_trident:
	push hl
		ld bc,MAP_BUFFER_WIDTH*2+1
		add hl,bc
		ex de,hl
		; draw covering trident:
		ld bc,#0602
		ld hl,boss4_frames + 7*8*3 + 5*7 + 14*8+15*7*2 + 13*7 + 14*7 + 9*7
		call copy_non_empty_enemy_tiles
	pop hl
	; draw covering head:
	ld bc,MAP_BUFFER_WIDTH+3
	add hl,bc
	ex de,hl
	ld bc,#0807
	ld hl,boss4_frames + 7*8
	jp copy_non_empty_enemy_tiles

