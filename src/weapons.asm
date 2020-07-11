;-----------------------------------------------
load_weapon_tiles:
	ld hl,(player_weapon_change_ptr)
	ld de,buffer5
	call unpack_compressed

	ld de,CHRTBL2+FIRST_WEAPON_TILE*8
load_weapon_tiles_entry_point:	
	ld a,3
load_weapon_tiles_loop:
	ld bc,N_WEAPON_TILES*8
	push af
		ld hl,buffer5
		push de
			push bc
				push de
					call fast_LDIRVM
				pop hl
				ld bc,CLRTBL2-CHRTBL2
				add hl,bc
				ex de,hl
			pop bc
			ld hl,buffer5+N_WEAPON_TILES*8
			call fast_LDIRVM
		pop hl
		ld bc,256*8
		add hl,bc
		ex de,hl
	pop af
	dec a
	jp nz,load_weapon_tiles_loop
	ret


;-----------------------------------------------
spawn_player_bullet_fire_held:
	; fire secondary weapon:
	ld hl,player_secondary_weapon_cooldown_state
	ld a,(hl)
	or a
	call z,spawn_player_secondary_bullet

	; fire option weapon:
	ld hl,player_option_weapon_cooldown_state
	ld a,(hl)
	or a
	call z,spawn_player_option_bullet

	; trigger the special weapon:
	ld a,(player_primary_weapon_special_triggered)
	or a
	jp z,spawn_player_bullet_fire_held_not_yet_triggered

spawn_player_bullet_fire_held_triggered:
	ld a,(player_primary_weapon)
	cp WEAPON_LASER
	jp z,spawn_player_bullet_fire_held_laser
	cp WEAPON_TWISTER_LASER
	jp z,spawn_player_bullet_fire_held_laser
	cp WEAPON_FLAME
	jp z,spawn_player_bullet_fire_held_flame

	; auto fire for bullet based weapons:
	ld a,(player_hold_fire_timer)
	and #03
	ret nz

	ld a,(player_primary_weapon_energy)
	ld hl,player_primary_weapon_cooldown
	sub (hl)
	jp nc,spawn_player_bullet_fire_held_triggered_positive_energy
	xor a
	ld (player_primary_weapon_special_triggered),a
spawn_player_bullet_fire_held_triggered_positive_energy:
	ld (player_primary_weapon_energy),a
	call update_scoreboard_energy
	jp spawn_player_bullet_ready_to_fire

spawn_player_bullet_fire_held_not_yet_triggered:
	ld a,(player_primary_weapon_energy)
	cp WEAPON_MAX_ENERGY
	jp nz,spawn_player_bullet_secondary_already_fired

	; trigger special!
	ld a,1
	ld (player_primary_weapon_special_triggered),a

	ld a,(player_primary_weapon)
	cp WEAPON_LASER
	jp z,spawn_player_bullet_fire_held_laser
	cp WEAPON_TWISTER_LASER
	jp z,spawn_player_bullet_fire_held_laser
	cp WEAPON_FLAME
	jp z,spawn_player_bullet_fire_held_flame


;-----------------------------------------------
spawn_player_bullet:
	; fire secondary weapon:
	ld hl,player_secondary_weapon_cooldown_state
	ld a,(hl)
	or a
	call z,spawn_player_secondary_bullet

	; fire option weapon:
	ld hl,player_option_weapon_cooldown_state
	ld a,(hl)
	or a
	call z,spawn_player_option_bullet

spawn_player_bullet_secondary_already_fired:
	; fire primary weapon:
	ld a,(player_weapon_change_signal)
	or a
	ret nz

	; not ready to fire yet
 	ld a,(player_primary_weapon_cooldown_state)
 	or a
 	ret nz

spawn_player_bullet_ready_to_fire:
	; consider weapon:
	ld a,(player_primary_weapon)
	cp WEAPON_BULLET
	jp z,spawn_player_bullet_internal_bullet
	cp WEAPON_TWIN_BULLET
	jp z,spawn_player_bullet_internal_twin_bullet
	cp WEAPON_TRIPLE_BULLET
	jp z,spawn_player_bullet_internal_triple_bullet
	cp WEAPON_LASER
	jp z,spawn_player_bullet_internal_laser
	cp WEAPON_TWISTER_LASER
	jp z,spawn_player_bullet_internal_laser
	cp WEAPON_FLAME
	jp z,spawn_player_bullet_internal_flame
	ret

spawn_player_bullet_internal_bullet:
	ld iy,player_sprite_attributes
	ld c,PLAYER_BULLET_TYPE_BULLET
	call spawn_player_bullet_internal
	ret nz
	; start cooldown:
	ld hl,player_primary_weapon_cooldown
	ld de,player_primary_weapon_cooldown_state
	ldi
	ret

spawn_player_bullet_internal_twin_bullet:
	ld iy,player_sprite_attributes
	ld c,PLAYER_BULLET_TYPE_BULLET
	call spawn_player_bullet_internal
	ret nz	; give up
	; start cooldown:
	ld hl,player_primary_weapon_cooldown
	ld de,player_primary_weapon_cooldown_state
	ldi
	ld c,PLAYER_BULLET_TYPE_BULLET_BACKWARDS
	jp spawn_player_bullet_internal


spawn_player_bullet_internal_triple_bullet:
	; start cooldown:
	ld hl,player_primary_weapon_cooldown
	ld de,player_primary_weapon_cooldown_state
	ldi	

	ld iy,player_sprite_attributes
	ld a,(player_primary_weapon_level)
	dec a
	jr z,spawn_player_bullet_internal_triple_bullet_skip_center
	ld c,PLAYER_BULLET_TYPE_BULLET
 	call spawn_player_bullet_internal
 	ret nz	; give up
 spawn_player_bullet_internal_triple_bullet_skip_center:
	ld c,PLAYER_BULLET_TYPE_BULLET_FW_UP
	call spawn_player_bullet_internal
 	ret nz	; give up
	ld c,PLAYER_BULLET_TYPE_BULLET_FW_DOWN
	jp spawn_player_bullet_internal


spawn_player_bullet_internal_laser:
	ld iy,player_sprite_attributes
	ld c,PLAYER_BULLET_TYPE_LASER
	call spawn_player_bullet_internal
	ret nz	; give up
	; start cooldown:
	ld hl,player_primary_weapon_cooldown
	ld de,player_primary_weapon_cooldown_state
	ldi
	ret

spawn_player_bullet_internal_flame:
	ld iy,player_sprite_attributes
	ld c,PLAYER_BULLET_TYPE_FLAME
	call spawn_player_bullet_internal
	ret nz	; give up
	ld (ix+PLAYER_BULLET_STRUCT_TIMER),MAX_FLAME_LENGTH+2
	; start cooldown:
	ld hl,player_primary_weapon_cooldown
	ld de,player_primary_weapon_cooldown_state
	ldi
	ret

	
;-----------------------------------------------
; input:
; - iy: sprite that is shooting the bullet (player / option)
; - c: bullet type
; returns:
; - ix: ptr to the bullet if spawned
; - z: bullet was spawned
; - nz: no bullet spot found
spawn_player_bullet_internal:
	ld ix,player_bullets
	ld de,PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
spawn_player_bullet_loop:	
	ld a,(ix+PLAYER_BULLET_STRUCT_TYPE)
	or a
	jp z,spawn_player_bullet_found_spot
	add ix,de
	djnz spawn_player_bullet_loop
	; no spot found, ignore...
	or 1
	ret
spawn_player_bullet_found_spot:
	ld hl,SFX_weapon_bullet
	ld a,c
	cp PLAYER_BULLET_TYPE_LASER
	jp z,spawn_player_bullet_laser_sfx
	cp PLAYER_BULLET_TYPE_FLAME
	jp nz,spawn_player_bullet_found_spot_bullet_sfx
	ld hl,SFX_weapon_flame_bullet
	jr spawn_player_bullet_found_spot_bullet_sfx
spawn_player_bullet_laser_sfx:
	ld hl,SFX_weapon_laser_bullet
spawn_player_bullet_found_spot_bullet_sfx:
    ld a,SFX_PRIORITY_LOW
	call play_SFX_with_priority

	; c: bullet type
	ld a,c
	ld (ix+PLAYER_BULLET_STRUCT_TYPE),a
	ld a,(player_primary_weapon_damage)
	ld (ix+PLAYER_BULLET_STRUCT_DAMAGE),a
	ld a,(iy)	; sprite y
	add a,8
	srl a
	ld e,a
	and #03
	add a,FIRST_WEAPON_TILE
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a

	srl e
	srl e
	ld (ix+PLAYER_BULLET_STRUCT_TILE_Y),e

	ld a,(iy+1)	; sprite x
	add a,10 	; center
    rrca
    rrca
    rrca
    and 31
	ld hl,scroll_x_tile
	add a,(hl)
	ld (ix+PLAYER_BULLET_STRUCT_TILE_X),a
	ld (ix+PLAYER_BULLET_STRUCT_BG_FLAG),0

	; calculate the pointer of where the bullet has to be drawn:
	; e still has a "y" coordinate in tiles
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	ld h,0
	ld l,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	add hl,de
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
	xor a
	ret


;-----------------------------------------------
spawn_player_bullet_fire_held_laser:
	; fire primary weapon:
	ld a,(player_weapon_change_signal)
	or a
	ret nz

	; laser uses 3 units of energy per cycle at max level (4), so it is: 7-level
	ld a,7
	ld hl,player_primary_weapon_level
	sub (hl)
	ld c,a

	; energy consumption:
	ld hl,player_primary_weapon_energy
	ld a,(hl)
	sub c
	jp nc,spawn_player_bullet_fire_held_laser_no_overflow
	xor a
	ld (player_primary_weapon_special_triggered),a
spawn_player_bullet_fire_held_laser_no_overflow:
	ld (hl),a

	ld a,1
	ld (player_laser_type),a	; switch laser on
	jp update_scoreboard_energy


;-----------------------------------------------
spawn_player_bullet_fire_held_flame:
	; fire primary weapon:
	ld a,(player_weapon_change_signal)
	or a
	ret nz

	; flame uses 3 units of energy per cycle at max level (4), so it is: 7-level
	ld a,7
	ld hl,player_primary_weapon_level
	sub (hl)
	ld c,a

	; energy consumption:
	ld hl,player_primary_weapon_energy
	ld a,(hl)
	sub c
	jp nc,spawn_player_bullet_fire_held_fire_no_overflow
	xor a
	ld (player_primary_weapon_special_triggered),a
spawn_player_bullet_fire_held_fire_no_overflow:
	ld (hl),a

	ld hl,SFX_weapon_flame
	call play_SFX_with_high_priority

	ld a,2
	ld (player_laser_type),a	; switch laser on
	jp update_scoreboard_energy


;-----------------------------------------------
; optimization note: jp/jr usage is chosen depending on whether it is likely to jump (jp) or not to jump (jr)
; 					 to optimize for CPU speed, ignoring space.
restore_player_bullets_bg:
	; restore the previous background (in reverse order):
	ld ix,player_bullets+((MAX_PLAYER_BULLETS-1)*PLAYER_BULLET_STRUCT_SIZE)
	ld de,-PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
restore_player_bullets_bg_loop:
	ld a,(ix+PLAYER_BULLET_STRUCT_TYPE)
	or a
	jp z,restore_player_bullets_bg_loop_next
	ld a,(ix+PLAYER_BULLET_STRUCT_BG_FLAG)
	or a
	jr z,restore_player_bullets_bg_loop_next

	; restore background:
	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
	ld a,(hl)
	; if the tile there is not the bullet itself, if means something has overwritten the BG, so, we should
	; not mess it up:
	cp (ix+PLAYER_BULLET_STRUCT_TILE)
	jr nz,restore_player_bullets_bg_loop_skip_restore_bg
	ld a,(ix+PLAYER_BULLET_STRUCT_BG)
	ld (hl),a
restore_player_bullets_bg_loop_skip_restore_bg:
	bit 7,(ix+PLAYER_BULLET_STRUCT_TYPE)	; check if it is marked for deletion
	jp z,restore_player_bullets_bg_loop_next
	ld (ix+PLAYER_BULLET_STRUCT_TYPE),0	; delete the bullet if it was marked for deletion

restore_player_bullets_bg_loop_next:
	add ix,de
	djnz restore_player_bullets_bg_loop

	ld a,(player_laser_bg_buffer_length)
	or a
	ret z
	jp restore_player_bullets_bg_laser	


;-----------------------------------------------
; updates and also draws player bullets
update_player_bullets:
	ld a,(player_laser_type)
	or a
	call nz,update_player_laser

	ld ix,player_bullets
	ld de,PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
update_player_bullets_loop:
	ld a,(ix+PLAYER_BULLET_STRUCT_TYPE)
	or a
	jp z,update_player_bullets_loop_next

	and #7f	; ignore the "to delete" flag
	dec a	; PLAYER_BULLET_TYPE_BULLET
	jp z,update_player_bullets_bullet
	dec a	; PLAYER_BULLET_TYPE_BULLET_BACKWARDS
	jp z,update_player_bullets_bullet_backward
	dec a	; PLAYER_BULLET_TYPE_BULLET_FW_UP
	jp z,update_player_bullets_bullet_fw_up
	dec a	; PLAYER_BULLET_TYPE_BULLET_FW_DOWN
	jp z,update_player_bullets_bullet_fw_down
	dec a	; PLAYER_BULLET_TYPE_LASER
	jp z,update_player_bullets_bullet
	dec a	; PLAYER_BULLET_TYPE_FLAME
	jp z,update_player_bullets_bullet_flame
	dec a   ; PLAYER_BULLET_TYPE_DIRECTIONAL_BULLET
	jp z,update_player_bullets_directional_bullet

update_player_bullets_bullet:
	inc (ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld hl,scroll_x_tile
	sub (hl)
	;jp m,update_player_bullets_disappear
	cp 32
	jp p,update_player_bullets_disappear
	; update the bullet position:
	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
	inc l	; data is 128-aligned
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
update_player_bullets_bullet_continue:
	; check if bullet collided with BG, or hit an enemy:
; 	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_Y)
	call collisionWithMap_player_bullet
	jp nz,update_player_bullets_disappear
	; store bg, and draw it:
	ld a,(hl)
	ld (ix+PLAYER_BULLET_STRUCT_BG),a
	ld (ix+PLAYER_BULLET_STRUCT_BG_FLAG),1
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE)
	ld (hl),a
update_player_bullets_loop_next:
	add ix,de
	djnz update_player_bullets_loop
	ret


update_player_bullets_disappear:
	ld (ix+PLAYER_BULLET_STRUCT_TYPE),0
	jp update_player_bullets_loop_next


update_player_bullets_directional_bullet:
	ld a,(ix+PLAYER_BULLET_STRUCT_DIRECTION)

	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)

	bit 0,a	; left
	jr z,update_player_bullets_directional_bullet_no_left
	dec (ix+PLAYER_BULLET_STRUCT_TILE_X)
	dec l	; data is 128-aligned
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
update_player_bullets_directional_bullet_no_left:

	bit 1,a	; right
	jr z,update_player_bullets_directional_bullet_no_right
	inc (ix+PLAYER_BULLET_STRUCT_TILE_X)
	inc l	; data is 128-aligned
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
update_player_bullets_directional_bullet_no_right:

	bit 2,a	; up
	jr z,update_player_bullets_directional_bullet_no_up
	dec (ix+PLAYER_BULLET_STRUCT_TILE_Y)
	push bc
		ld bc,-MAP_BUFFER_WIDTH
		add hl,bc
	pop bc
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
update_player_bullets_directional_bullet_no_up:

	bit 3,a	; down
	jr z,update_player_bullets_directional_bullet_no_down
	inc (ix+PLAYER_BULLET_STRUCT_TILE_Y)
	push bc
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
	pop bc
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
update_player_bullets_directional_bullet_no_down:

	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	push hl
		ld hl,scroll_x_tile
		sub (hl)
	pop hl
	or a
	jp m,update_player_bullets_disappear
	cp 32
	jp p,update_player_bullets_disappear
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_Y)
	or a
	jp m,update_player_bullets_disappear
	cp 22
	jp p,update_player_bullets_disappear
	jp update_player_bullets_bullet_continue


update_player_bullets_bullet_flame:
	dec (ix+PLAYER_BULLET_STRUCT_TIMER)
	ld a,(ix+PLAYER_BULLET_STRUCT_TIMER)
	or a
	jr z,update_player_bullets_disappear
	jp update_player_bullets_bullet


update_player_bullets_bullet_fw_down:
	inc (ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld hl,scroll_x_tile
	sub (hl)
	jp m,update_player_bullets_disappear
	cp 32
	jp p,update_player_bullets_disappear

	; update the bullet position:
	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
	inc hl	
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	;ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h

	ld a,(ix+PLAYER_BULLET_STRUCT_TILE)
	inc a
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a
	cp FIRST_WEAPON_TILE+4
	jp m,update_player_bullets_bullet_continue
	sub 4
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a

	inc (ix+PLAYER_BULLET_STRUCT_TILE_Y)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_Y)
	cp 22
	jp p,update_player_bullets_disappear
	push bc
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
	pop bc
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
	jp update_player_bullets_bullet_continue


update_player_bullets_bullet_fw_up:
	inc (ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld hl,scroll_x_tile
	sub (hl)
	jp m,update_player_bullets_disappear
	cp 32
	jp p,update_player_bullets_disappear

	; update the bullet position:
	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
	inc hl	
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	;ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h

	ld a,(ix+PLAYER_BULLET_STRUCT_TILE)
	dec a
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a
	cp FIRST_WEAPON_TILE-1
	jp p,update_player_bullets_bullet_continue
	add a,4
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a

	dec (ix+PLAYER_BULLET_STRUCT_TILE_Y)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_Y)
	or a
	jp m,update_player_bullets_disappear
	push bc
		ld bc,-MAP_BUFFER_WIDTH
		add hl,bc
	pop bc	
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
	jp update_player_bullets_bullet_continue

update_player_bullets_bullet_backward:
	dec (ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld hl,scroll_x_tile
	sub (hl)
	jp m,update_player_bullets_disappear
	;cp 32
	;jp p,update_player_bullets_disappear

	; update the bullet position:
	ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
	ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
	dec l	; data is 128-aligned	
	ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
	;ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
	jp update_player_bullets_bullet_continue


;-----------------------------------------------
update_player_laser:
	ex af,af'
	 	ld hl,SFX_weapon_laser
	 	call play_SFX_with_high_priority
	ex af,af'

	ld iyl,MAX_FLAME_LENGTH	; length of the flame
	dec a
	jr nz,update_player_laser_flame
	ld iyl,32	; length of the laser
update_player_laser_flame:

	; calculate the pointer where the laser will start:
	ld a,(player_tile_y)
	;ld iyl,a	; we save the y tile
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
	inc a
	ld l,a
	add hl,de

	ld (player_laser_bg_buffer_ptr),hl

	; calculate maximum laser length:
	push hl
		ld hl,scroll_x_tile
		sub (hl)	; a = laser_x - (scroll_x_tile)
		sub 32
		neg			; a = 32 - (laser_x - (scroll_x_tile))
	pop hl
	cp iyl	; laser max length is 32, and flame MAX_FLAME_LENGTH
	jr c,update_player_laser_length_ok
	ld a,iyl
update_player_laser_length_ok:
	ld b,a	; laser length

	; draw laser:
	ld a,(player_y)
	add a,6
	srl a
	and #03
	add a,FIRST_WEAPON_TILE
	ld c,a	; laser tile
	ld (player_last_last_tile),a
	ld de,player_laser_bg_buffer

	ld iyh,0	; count how many tiles do we draw
update_player_laser_loop:
	ld a,(hl)
	cp FIRST_TILEENEMY_COLLIDABLE_TILE
	jp nc,update_player_laser_loop_hit_tile_enemy
	cp FIRST_DESTROYABLEWALL_COLLIDABLE_TILE
	jp nc,update_player_laser_loop_hit_tile_enemy_destroyablewall_choose_bank
	cp FIRST_WALL_COLLIDABLE_TILE
	jp nc,update_player_laser_loop_end
update_player_laser_loop_continue:

;	cp STAR_TILE
;	jp nz,update_player_laser_loop_no_star
;	xor a	; do not save the stars, as those get messed up otherwise!
;update_player_laser_loop_no_star:
	ld (de),a	; save BG
	ld (hl),c	; draw laser
	inc hl
	inc de
	inc iyh
	djnz update_player_laser_loop
update_player_laser_loop_end:

	ld a,iyh
	ld (player_laser_bg_buffer_length),a
	ret


update_player_laser_loop_hit_tile_enemy_destroyablewall_choose_bank:
	ld a,(player_tile_y)
	cp 8
	jr nc,update_player_laser_loop_hit_tile_enemy_destroyablewall2

update_player_laser_loop_hit_tile_enemy_destroyablewall1:
	ld a,(player_tile_x)
	add a,iyh
	ld iyl,a
	call collisionWithMap_player_bullet_collision_with_destroyablewall1_entry_point
	jp update_player_laser_loop_end

update_player_laser_loop_hit_tile_enemy_destroyablewall2:
	ld a,(player_tile_x)
	add a,iyh
	ld iyl,a
	call collisionWithMap_player_bullet_collision_with_destroyablewall2_entry_point
	jp update_player_laser_loop_end


update_player_laser_loop_hit_tile_enemy:
	ld a,iyh
	ld (player_laser_bg_buffer_length),a

	ld a,(in_boss)
	or a
	jr z,update_player_laser_loop_hit_tile_enemy_not_boss
	ld a,(player_primary_weapon_damage)
	ld (boss_hit),a
	ret
update_player_laser_loop_hit_tile_enemy_not_boss:

	ld a,(player_hold_fire_timer)
	and #02	; since this function is only called every 2 frames, we need to clear the lsb, since otherwise, it
			; might always be 0, if this function syncs wrongly with the player update cycle
	ret z	; only do damage once every 4 update cycles

	ld hl,player_tile_y
	ld c,(hl)
	ld hl,player_tile_x
	ld a,(hl)
	inc a
	add a,iyh
	ld l,a
	ld h,c

	; find the tile enemy that was collided with
	ld iy,tile_enemies
	ld de,TILE_ENEMY_STRUCT_SIZE
	ld b,MAX_TILE_ENEMIES
update_player_laser_loop_hit_tile_enemy_loop:
	ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
	or a
	jp z,update_player_laser_loop_hit_tile_enemy_loop_next
	ld a,(iy+TILE_ENEMY_STRUCT_X)
	dec a
	dec a
	cp l	; laser x
	jp p,update_player_laser_loop_hit_tile_enemy_loop_next
	inc a
	add a,(iy+TILE_ENEMY_STRUCT_WIDTH)
	cp l	; laser x
	jp m,update_player_laser_loop_hit_tile_enemy_loop_next

	ld a,(iy+TILE_ENEMY_STRUCT_Y)
	dec a
	cp h	; laser y
	jp p,update_player_laser_loop_hit_tile_enemy_loop_next
	add a,(iy+TILE_ENEMY_STRUCT_HEIGHT)
	cp h	; laser y
	jp m,update_player_laser_loop_hit_tile_enemy_loop_next

	ld a,(player_primary_weapon_damage)
	ld c,a	; damage
	jp tile_enemy_hit

update_player_laser_loop_hit_tile_enemy_loop_next:
	add iy,de
	djnz update_player_laser_loop_hit_tile_enemy_loop
	ret


;-----------------------------------------------
; a: (player_laser_bg_buffer_length)
restore_player_bullets_bg_laser:
	ld hl,player_laser_bg_buffer
	ld de,(player_laser_bg_buffer_ptr)
	ld b,a
	ld a,(player_last_last_tile)
	ld c,a
restore_player_bullets_bg_laser_loop:
	ld a,(de)
	cp c
	jp nz,restore_player_bullets_bg_laser_loop_skip
	ld a,(hl)
	ld (de),a
restore_player_bullets_bg_laser_loop_skip:
	inc de
	inc hl
	djnz restore_player_bullets_bg_laser_loop


	xor a
	ld (player_laser_bg_buffer_length),a
	ret


;-----------------------------------------------
adjust_player_bullet_positions_after_scroll_restart:
	ld ix,player_bullets
	ld de,PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
adjust_player_bullet_positions_loop:
	ld a,(ix)
	or a
	jp z,adjust_player_bullet_positions_loop_next
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	sub 64
	jp m,adjust_player_bullet_positions_loop_next	; this is in the off-chance of firing a bullet exactly
													; in the frame where scroll restarts before this function is called
	ld (ix+PLAYER_BULLET_STRUCT_TILE_X),a
	push bc
		ld l,(ix+PLAYER_BULLET_STRUCT_BG_PTR)
		ld h,(ix+PLAYER_BULLET_STRUCT_BG_PTR+1)
		ld bc,-64
		add hl,bc
		ld (ix+PLAYER_BULLET_STRUCT_BG_PTR),l
		ld (ix+PLAYER_BULLET_STRUCT_BG_PTR+1),h
	pop bc
adjust_player_bullet_positions_loop_next:
	add ix,de
	djnz adjust_player_bullet_positions_loop
	ret


;-----------------------------------------------
; finds a bullet that is drawing in position "hl", and deletes it (unless this is a penetrating weapon)
; - preserves "ix", as this is called from the enemies update loop
delete_player_bullet_by_hl:
	ld a,(player_primary_weapon)
	cp WEAPON_LASER
	ret z
	cp WEAPON_TWISTER_LASER
	ret z
	cp WEAPON_FLAME
	ret z

delete_player_bullet_by_hl_option:
	ld iy,player_bullets
	ld de,PLAYER_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_BULLETS
delete_player_bullet_by_hl_loop:
	ld a,(iy+PLAYER_BULLET_STRUCT_TYPE)
	or a
	jp z,delete_player_bullet_by_hl_loop_next
	bit 7,a	; check if it's already marked for deletion
	jp nz,delete_player_bullet_by_hl_loop_next
	ld a,(iy+PLAYER_BULLET_STRUCT_BG_PTR)
	cp l
	jp nz, delete_player_bullet_by_hl_loop_next
	ld a,(iy+PLAYER_BULLET_STRUCT_BG_PTR+1)
	cp h
	jp nz, delete_player_bullet_by_hl_loop_next
	; mark bullet for deletion!
	set 7,(iy+PLAYER_BULLET_STRUCT_TYPE)
	;ld a,(iy+PLAYER_BULLET_STRUCT_BG)
	;ld (hl),a
	;ld (iy+PLAYER_BULLET_STRUCT_TYPE),0
	ret
delete_player_bullet_by_hl_loop_next:
	add iy,de
	djnz delete_player_bullet_by_hl_loop
	ret
