;-----------------------------------------------
; input:
; - a: health
; - ix: tiles ptr from page 1
init_boss_base:
	ld (boss_health),a

	ld hl,boss_x
	ld (hl),34
	inc hl
	ld (hl),6
	ld hl,0
	ld (boss_previous_ptr),hl

	ld a,2
	ld (difficulty_enemy_speed),a
	inc a
	ld (difficulty_bullet_speed),a
	ld a,255
	ld (difficulty_power_spawn_p),a
	ld (difficulty_power_spawn_low_p),a
	ld a,8
	ld (difficulty_sprite_fire_rate_slow),a

	call call_from_page1	
	ld bc,(buffer3)	; size of the banks
	ld hl,buffer3+2
	ld de,CHRTBL2+43*8
	call init_boss_base_tiles_bank
	ld de,CHRTBL2+(256+43)*8
	call init_boss_base_tiles_bank
	ld de,CHRTBL2+(512+43)*8
	; jp init_boss_base_tiles_bank

init_boss_base_tiles_bank:
	push hl
		push bc
		push hl
			push de
				call fast_LDIRVM
			pop hl
			ld bc,CLRTBL2-CHRTBL2
			add hl,bc
			ex de,hl
		pop hl
		pop bc
		add hl,bc
		push bc
			call fast_LDIRVM
		pop bc
	pop hl
	ret


;-----------------------------------------------
init_polyphemus:
	ld a,POLYPHEMUS_HEALTH
	ld ix,decompress_boss1_tiles_plt_from_page1
	call init_boss_base

	; frames + sprites:
	ld hl,boss1_data_plt
	ld de,boss1_frames
	call unpack_compressed
	ld hl,boss1_frames+188
	ld de,SPRTBL2+POLYPHEMUS_FIRST_SPRITE*32
	ld bc,5*32
	call fast_LDIRVM

	ld hl,compressed_boss1_code_plt
	ld de,BOSS_COMPRESSED_CODE_START
	jp unpack_compressed


;-----------------------------------------------
init_scylla:
	ld a,SCYLLA_HEALTH_PHASE1
	ld ix,decompress_boss2_tiles_plt_from_page1
	call init_boss_base

	; frames + sprites:
	ld hl,boss2_data_plt
	ld de,boss2_frames
	call unpack_compressed
	ld hl,boss2_frames+440
	ld de,SPRTBL2+SCYLLA_FIRST_SPRITE*32
	ld bc,8*32
	call fast_LDIRVM

	ld hl,compressed_boss2_code_plt
	ld de,BOSS_COMPRESSED_CODE_START
	jp unpack_compressed


;-----------------------------------------------
init_charybdis:
	ld a,CHARYBDIS_HEALTH
	ld ix,decompress_boss3_tiles_plt_from_page1
	call init_boss_base

	ld a,-6
	ld (boss_charybdis_moving_speed),a
	ld (boss_state_cycle),a
	ld a,CHARYBDIS_LENGTH
	ld (boss_charybdis_shape+1),a
	ld a,#ff
	ld (boss_charybdis_shape+2),a

	; faster bullets
	ld a,4
	ld (difficulty_bullet_speed),a

	; frames + sprites:
	ld hl,boss3_data_plt
	ld de,boss3_frames
	call unpack_compressed
	ld hl,boss3_frames+238
	ld de,SPRTBL2+CHARYBDIS_FIRST_SPRITE*32
	ld bc,3*32
	call fast_LDIRVM

	ld hl,compressed_boss3_code_plt
	ld de,BOSS_COMPRESSED_CODE_START
	jp unpack_compressed


;-----------------------------------------------
init_triton:
	ld a,TRITON_HEALTH
	ld ix,decompress_boss4_tiles_plt_from_page1
	call init_boss_base

	; faster bullets
	ld a,4
	ld (difficulty_bullet_speed),a

	; frames + sprites:
	ld hl,boss4_data_plt
	ld de,boss4_frames
	call unpack_compressed
	ld hl,boss4_frames+828
	ld de,SPRTBL2+TRITON_FIRST_SPRITE*32
	ld bc,3*32
	call fast_LDIRVM

	ld hl,compressed_boss4_code_plt
	ld de,BOSS_COMPRESSED_CODE_START
	jp unpack_compressed


;-----------------------------------------------
; output:
; - z: if boss health > 0
; - nz: if health reached 0
update_boss_check_if_hit:
	ld hl,boss_hit
	ld a,(hl)
	or a
	ret z
	ld c,a	; store the damage to deal to the boss
	ld (hl),0
	inc hl	; boss_hit_gfx
	ld a,(hl)
	or a
	jr nz,update_boss_check_if_hit_alive
	ld (hl),4	; you can only hit bosses once everh 4 frames (otherwise, they are too easy with laser/flamethrower!)

	ld hl,SFX_enemy_hit
	call play_SFX_with_high_priority

	ld hl,boss_health
	ld a,(hl)
	sub c
	ld (hl),a
	jr nc,update_boss_check_if_hit_alive
	or 1
	ret

update_boss_check_if_hit_alive:
	xor a
	ret


;-----------------------------------------------
; input:
; - e: x offset in tiles
; - d: y offset in tiles
update_boss_fire_bullet:
	; - c,b: x, y where to spawn the bullet (pixel coordinates)
	ld a,(boss_x)
	add a,e
	add a,a
	add a,a
	add a,a
	ld c,a
	ld a,(boss_y)
	add a,d
	add a,a
	add a,a
	add a,a
	ld b,a
	jp enemy_fire_bullet


;-----------------------------------------------
update_boss_explosion:
	; clear the explosion:
	ld de,(boss_previous_ptr)
	ld bc,#0606
	push bc
		call clear_tile_enemy
	pop bc

	call get_boss_ptr
	ld (boss_previous_ptr),hl

	ld bc,#0404
	ld a,(boss_state_cycle)
	cp 12
	jr c,update_boss_explosion_frame1
	cp 24
	jr c,update_boss_explosion_frame2
	cp 36
	jr c,update_boss_explosion_frame3
	cp 48
	jr c,update_boss_explosion_frame4
	cp 128
	ret c

	; collect a map from the boss!
	ld hl,global_state_bosses_defeated
	inc (hl)
	jp state_level_complete

update_boss_explosion_frame1:
	ld de,tile_explosion
	jr update_boss_explosion_draw_frame_1_1

update_boss_explosion_frame2:
	ld bc,#0606
	ld de,tile_explosion_large
	jr update_boss_explosion_draw_frame

update_boss_explosion_frame3:
	ld de,tile_explosion+16
	jr update_boss_explosion_draw_frame_1_1

update_boss_explosion_frame4:
	ld de,tile_explosion+32

update_boss_explosion_draw_frame_1_1:
	push bc
		ld bc,MAP_BUFFER_WIDTH+1
		add hl,bc
	pop bc
update_boss_explosion_draw_frame:
	ex de,hl
	jp copy_non_empty_enemy_tiles


;-----------------------------------------------
; returns the boss ptr in hl
get_boss_ptr:
	ld hl,boss_x
get_boss_ptr_hl_set:
	ld a,(scroll_x_tile)
	add a,(hl)	; a = x coordinate
	ld c,a
	ld d,0

	inc hl
	ld a,(hl)	; y coordinate
	or a
	jp p,get_boss_ptr_positive_y
	ld hl,map_y_ptr_table_negative
	neg
	ld e,a
	add hl,de
	add hl,de
	jr get_boss_ptr_coordinate_continue
get_boss_ptr_positive_y:
	ld e,(hl)	; de = y coordinate
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
get_boss_ptr_coordinate_continue:
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	; we extend "c" (x coordinate) into "hl" maintaining the sign:
	ld a,c
    ld l,a  ; Store low byte
    add a,a  ; Push sign into carry
    sbc a,a     ; Turn it into 0 or -1
    ld h,a  ; Store high byte
	add hl,de

	ld a,(scroll_x_half_pixel)
	cp 15
	jr nz,get_boss_ptr_no_x_adjust
	inc hl	; correct the boss x in the last cycle before scroll advances
	ld a,(scroll_x_tile)
	cp 63
	jr nz,get_boss_ptr_no_x_adjust
	ld bc,-64
	add hl,bc
get_boss_ptr_no_x_adjust:	
	ret	


;-----------------------------------------------
update_boss_clear_laser:
	ld a,(boss_laser_last_length)
	or a
	ret z
	ld hl,(boss_laser_last_ptr)
	ld c,a
	xor a
update_boss_clear_laser_loop:
	ld (hl),a
	inc hl
	dec c
	jr nz,update_boss_clear_laser_loop
	ret



;-----------------------------------------------
; input:
; - bc: offset
; - de: ptr of the main body
; - hl: ptr of the thruster tiles
update_boss_draw_thruster:
	push de
		push hl
			; draw thruster:
			ex de,hl
				add hl,bc
			ex de,hl
			ld a,(boss_state_cycle)
			srl a
			and #03
			cp 3
			jr nz,update_scylla_draw_thruster_continue
			ld a,1
update_scylla_draw_thruster_continue:
		pop hl
		ADD_HL_A	
		ld bc,#0101
		call copy_non_empty_enemy_tiles
	pop de
	ret


;-----------------------------------------------
; input:
; - hl: ptr of the right end of the laser
; - de: ptr to laser tile
update_boss_draw_laser:
 	; laser:
 	ld a,(boss_laser_length)
 	ld (boss_laser_last_length),a
 	or a
 	ret z
 	ld b,0
 	ld c,a
 	xor a
	sbc hl,bc	; hl = ptr where to start drawing the laser!
 	ld (boss_laser_last_ptr),hl
 	ld a,(de) ; laser tile
 update_boss_draw_laser_loop:
 	ld (hl),a
 	inc hl
 	dec c
 	jr nz,update_boss_draw_laser_loop
 	ret
