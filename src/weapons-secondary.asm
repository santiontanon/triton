;-----------------------------------------------
spawn_player_secondary_bullet:
	ld a,(player_secondary_weapon)
	or a
	ret z	; if no secondary weapon, ignore!

	ld ix,player_secondary_bullets
	ld de,PLAYER_SECONDARY_BULLET_STRUCT_SIZE
	ld b,MAX_PLAYER_SECONDARY_BULLETS
spawn_player_secondary_bullet_loop:	
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE)
	or a
	jp z,spawn_player_secondary_bullet_found_spot
	add ix,de
	djnz spawn_player_secondary_bullet_loop
	; no spot found, ignore...
	ret
spawn_player_secondary_bullet_found_spot:
	ld hl,player_secondary_weapon_cooldown
	ld de,player_secondary_weapon_cooldown_state
	ldi

	ld a,(player_x)
	add a,4
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	ld a,(player_y)
	add a,8
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_STATE),0

	ld a,(player_secondary_weapon)
	cp WEAPON_UP_MISSILES
	jp z,spawn_player_secondary_bullet_found_spot_going_up
	cp WEAPON_BIDIRECTIONAL_MISSILES
	; decide if it's going to be an "up" or a "down" missile:
	jp nz,spawn_player_secondary_bullet_found_spot_direction_set
	ld a,(player_last_movement)
	bit 2,a
	jp nz,spawn_player_secondary_bullet_found_spot_going_up
spawn_player_secondary_bullet_found_spot_going_down:
	ld a,WEAPON_DOWN_MISSILES
	jp spawn_player_secondary_bullet_found_spot_direction_set
spawn_player_secondary_bullet_found_spot_going_up:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	sub 12
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld a,WEAPON_UP_MISSILES

spawn_player_secondary_bullet_found_spot_direction_set:
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE),a
	cp WEAPON_L_TORPEDOES
	jp z,spawn_player_secondary_bullet_found_spot_light
	cp WEAPON_H_TORPEDOES
	jp z,spawn_player_secondary_bullet_found_spot_heavy
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE),MISSILE_DAMAGE
	jr spawn_player_secondary_bullet_found_damage_set
spawn_player_secondary_bullet_found_spot_light:
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE),LIGHT_TORPEDO_DAMAGE
	jr spawn_player_secondary_bullet_found_damage_set
spawn_player_secondary_bullet_found_spot_heavy:
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE),HEAVY_TORPEDO_DAMAGE

spawn_player_secondary_bullet_found_damage_set:
	ld a,(player_secondary_weapon_level)
	cp 3
	ret m
	inc (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE)
	inc (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE) 
	ret

;-----------------------------------------------
; updates the behavior of all the enemies, and also updates their sprites
update_player_secondary_bullets:
	ld ix,player_secondary_bullets
	ld b,MAX_PLAYER_SECONDARY_BULLETS
update_player_secondary_bullets_loop:
	push bc
		ld a,(ix)
		or a
		jp z,update_player_secondary_bullets_loop_next
		cp WEAPON_L_TORPEDOES
		jp z,update_player_secondary_bullets_torpedo
		cp WEAPON_H_TORPEDOES
		jp z,update_player_secondary_bullets_torpedo
		cp WEAPON_UP_MISSILES
		jp z,update_player_secondary_bullets_up_missile
		cp WEAPON_DOWN_MISSILES
		jp z,update_player_secondary_bullets_down_missile
		; ...
update_player_secondary_bullets_loop_next:
		ld bc,PLAYER_SECONDARY_BULLET_STRUCT_SIZE
		add ix,bc
	pop bc
	djnz update_player_secondary_bullets_loop
	ret


update_player_secondary_bullets_clear:
	ld hl,player_secondary_bullets_sprite_attributes
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX)
	ADD_HL_A
	ld (hl),200
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE)
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE),0
	cp WEAPON_H_TORPEDOES
	jp nz,update_player_secondary_bullets_loop_next
update_player_secondary_bullets_clear_spawn_explosion:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	cp 252
	jp nc,update_player_secondary_bullets_loop_next

	; look for an enemy slot for the explosion:
	ld iy,enemies
	ld de,ENEMY_STRUCT_SIZE
	ld b,MAX_ENEMIES
update_player_secondary_bullets_clear_loop:
	ld a,(iy)
	or a
	jp z,update_player_secondary_bullets_clear_loop_found_spot
	add iy,de
	djnz update_player_secondary_bullets_clear_loop
	; found no enemy spot! ignore the explosion
	jp update_player_secondary_bullets_loop_next
update_player_secondary_bullets_clear_loop_found_spot:
	ld (iy+ENEMY_STRUCT_TYPE),ENEMY_EXPLOSION
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	sub 4
	and #07
	ld (iy+ENEMY_STRUCT_X),a
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	sub 4
    rrca
    rrca
    rrca
    and 31
	ld hl,scroll_x_tile
	add a,(hl)
	ld (iy+ENEMY_STRUCT_TILE_X),a
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	sub 4
	ld (iy+ENEMY_STRUCT_Y),a
	ld (iy+ENEMY_STRUCT_STATE),0
	ld (iy+ENEMY_STRUCT_TIMER),3
	jp update_player_secondary_bullets_loop_next


update_player_secondary_bullets_torpedo:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_STATE)
	cp 8
	jp p,update_player_secondary_bullets_torpedo_advancing

	inc (ix+PLAYER_SECONDARY_BULLET_STRUCT_STATE)
	inc (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	cp 22*8-4
	jp nc,update_player_secondary_bullets_clear
	jp update_player_secondary_bullets_torpedo_movement_done

update_player_secondary_bullets_torpedo_advancing:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	add a,4
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	cp 252
	jp nc,update_player_secondary_bullets_clear

update_player_secondary_bullets_torpedo_movement_done:
	call collisionWithMap_player_secondary_bullet
	or a
	jp nz,update_player_secondary_bullets_clear

	call collisionWithSpriteEnemies_secondary_bullet
	jp nz,update_player_secondary_bullets_clear

	; update sprite:
	ld hl,player_secondary_bullets_sprite_attributes
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX)
	ADD_HL_A
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	ld (hl),a
	inc hl
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	ld (hl),a
	inc hl
	ld (hl),WEAPON_SPRITE_TORPEDO
	inc hl
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE)
	cp WEAPON_L_TORPEDOES
	jp z,update_player_secondary_bullets_torpedo_green
	ld (hl),COLOR_RED
	jp update_player_secondary_bullets_loop_next
update_player_secondary_bullets_torpedo_green:
	ld (hl),COLOR_GREEN

	jp update_player_secondary_bullets_loop_next


update_player_secondary_bullets_up_missile:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	add a,2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	cp 252
	jp nc,update_player_secondary_bullets_clear

	call collisionWithMap_player_secondary_bullet
	or a
	jp nz,update_player_secondary_bullets_clear

	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	sub 2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	cp 22*8-4
	jp nc,update_player_secondary_bullets_clear

	call collisionWithSpriteEnemies_secondary_bullet
	jp nz,update_player_secondary_bullets_clear

	call collisionWithMap_player_secondary_bullet
	or a
	jp z,update_player_secondary_bullets_up_missile_no_collision
	cp 2
	jp z,update_player_secondary_bullets_clear
	; follow terrain:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	add a,2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld e,WEAPON_SPRITE_MISSILE
	jp update_player_secondary_bullets_up_missile_entry_point

update_player_secondary_bullets_up_missile_no_collision:
	ld e,WEAPON_SPRITE_UP_MISSILE

update_player_secondary_bullets_up_missile_entry_point:
	; update sprite:
	ld hl,player_secondary_bullets_sprite_attributes
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX)
	ADD_HL_A
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	ld (hl),a
	inc hl
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),COLOR_WHITE

	jp update_player_secondary_bullets_loop_next	


update_player_secondary_bullets_down_missile:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	add a,2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	cp 252
	jp nc,update_player_secondary_bullets_clear

	call collisionWithMap_player_secondary_bullet
	or a
	jp nz,update_player_secondary_bullets_clear

	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	add a,2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	cp 22*8-4
	jp nc,update_player_secondary_bullets_clear

	call collisionWithSpriteEnemies_secondary_bullet
	jp nz,update_player_secondary_bullets_clear

	call collisionWithMap_player_secondary_bullet
	or a
	jp z,update_player_secondary_bullets_down_missile_no_collision
	cp 2
	jp z,update_player_secondary_bullets_clear
	; follow terrain:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	sub 2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld e,WEAPON_SPRITE_MISSILE
	jp update_player_secondary_bullets_up_missile_entry_point

update_player_secondary_bullets_down_missile_no_collision:
	ld e,WEAPON_SPRITE_DOWN_MISSILE
	jp update_player_secondary_bullets_up_missile_entry_point	

