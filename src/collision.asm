;-----------------------------------------------
; input:
; - c: x tile coordinate
; - b: y tile coordinate
; return:
; - z: no collision
; - nz: collision
collisionWithMap:
	ld e,b
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	ld h,0
	ld l,c
	add hl,de
collisionWithMap_internal:	; assumes "a" has y coordinate, and "hl" pointer of the tile
	ld a,(hl)
	cp FIRST_WALL_COLLIDABLE_ONLY_SHIP_TILE
	jp nc,collisionWithMap_collision
	xor a
	ret

collision_enemy_to_player_bullet_no_collision:
collision_enemy_to_player_bullet_next4:
collision_with_player_no_collision:
collisionWithMap_collision:
	or 1
	ret


;-----------------------------------------------
; - collision with the player of pixel coordinates c,b (top-left)
; - assumes the collider is about the size of a small bullet
; z: collision
; nz: no collision
collision_with_player:	
	ld a,(player_x)
	sub c
	cp -12
	jp m,collision_with_player_no_collision
	cp 1
	jp p,collision_with_player_no_collision
	ld a,(player_y)
	sub b
	cp -7
	jp m,collision_with_player_no_collision
	or a
	jp p,collision_with_player_no_collision
	xor a
	ret


;-----------------------------------------------
; - collision with the player of pixel coordinates c,b (top-left)
; - assumes the collider is a large almost 16x16 object
; z: collision
; nz: no collision
collision_with_player_large:	
	ld a,(player_x)
	sub c
	cp -13
	jp m,collision_with_player_no_collision
	cp 9
	jp p,collision_with_player_no_collision
	ld a,(player_y)
	sub b
	cp -6
	jp m,collision_with_player_no_collision
	cp 11
	jp p,collision_with_player_no_collision
	xor a
	ret


;-----------------------------------------------
; - checks collision between a 16x16 enemy and player bullets
; input:
; - ix: enemy ptr
; output:
; - a: damage dealt
; - z: collision
; - nz: no collision
collision_enemy_to_player_bullet:
	ld a,(ix+ENEMY_STRUCT_Y)
	add a,4
    rrca
    rrca
    rrca
    and 31	; divide by 8
	cp 22	; chek ifwe will be outside of the map
	jr nc,collision_enemy_to_player_bullet_no_collision
	ld e,a
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	ld h,0
	ld l,(ix+ENEMY_STRUCT_TILE_X)
	add hl,de 	; hl now has the collision ptr

	ld a,(hl)
	cp FIRST_WEAPON_TILE
	jp c,collision_enemy_to_player_bullet_next1
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES*2
	jp nc,collision_enemy_to_player_bullet_next1
	; collision!
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES
	jp c,collision_enemy_to_player_bullet_primary
	jp collision_enemy_to_player_bullet_option

collision_enemy_to_player_bullet_next1:	
	inc hl
	ld a,(hl)
	cp FIRST_WEAPON_TILE
	jp c,collision_enemy_to_player_bullet_next2
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES*2
	jp nc,collision_enemy_to_player_bullet_next2
	; collision!
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES
	jp c,collision_enemy_to_player_bullet_primary
	jp collision_enemy_to_player_bullet_option

collision_enemy_to_player_bullet_next2:	
	ld de,MAP_BUFFER_WIDTH-1
	add hl,de

	; check if we are outside of the map:
	ld a,h
	cp (mapBuffer+22*MAP_BUFFER_WIDTH)/256
	jp nc,collision_enemy_to_player_bullet_next4

	ld a,(hl)
	cp FIRST_WEAPON_TILE
	jp c,collision_enemy_to_player_bullet_next3
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES*2
	jp nc,collision_enemy_to_player_bullet_next3
	; collision!
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES
	jp c,collision_enemy_to_player_bullet_primary
	jp collision_enemy_to_player_bullet_option

collision_enemy_to_player_bullet_next3:	
	inc hl
	ld a,(hl)
	cp FIRST_WEAPON_TILE
	jp c,collision_enemy_to_player_bullet_next4
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES*2
	jp nc,collision_enemy_to_player_bullet_next4
	; collision!
	cp FIRST_WEAPON_TILE+N_WEAPON_TILES
	jp c,collision_enemy_to_player_bullet_primary
	jp collision_enemy_to_player_bullet_option

collision_enemy_to_player_bullet_primary:
	call delete_player_bullet_by_hl
	xor a	; z
	ld a,(player_primary_weapon_damage)
	ret

collision_enemy_to_player_bullet_option:
	call delete_player_bullet_by_hl_option
	xor a	; z
	ld a,OPTION_BULLET_DAMAGE
	ret


;-----------------------------------------------
; collision between a player bullet and background, checking if a tile-enemy was hit
; input:
; - ix: player bullet in question
; - a: y tile coordinate
; - hl: ptr to check collision at
; output:
; - z: no collision
; - nz: collision
; preserves: bc, de, hl
collisionWithMap_player_bullet:
	ld a,(hl)
	cp FIRST_TILEENEMY_COLLIDABLE_TILE
	jp nc,collisionWithMap_player_bullet_collision_with_enemy
	cp FIRST_DESTROYABLEWALL_COLLIDABLE_TILE
	jp nc,collisionWithMap_player_bullet_collision_with_destroyablewall_choose_bank
	cp FIRST_WALL_COLLIDABLE_TILE
	jp nc,collisionWithMap_collision
	xor a
	ret

collisionWithMap_player_bullet_collision_with_destroyablewall_choose_bank:
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_Y)
	cp 8
	jr nc,collisionWithMap_player_bullet_collision_with_destroyablewall2
collisionWithMap_player_bullet_collision_with_destroyablewall1:
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld iyl,a	
collisionWithMap_player_bullet_collision_with_destroyablewall1_entry_point:	
	push bc
	push de
		ld a,(destroyable_tiles_bank0)
		ld c,a	; 0 -> 1
		ld a,(destroyable_tiles_bank0+2)
		ld b,a	; 1 -> 0
		ld a,(power_pellet_types_bank0+2)
		ld e,a
		inc e	; e has the first tile type ID of the first scenario tile
		jr collisionWithMap_player_bullet_collision_with_destroyablewall
collisionWithMap_player_bullet_collision_with_destroyablewall2:
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE_X)
	ld iyl,a	
collisionWithMap_player_bullet_collision_with_destroyablewall2_entry_point:	
	push bc
	push de
		ld a,(destroyable_tiles_bank1)
		ld c,a	; 0 -> 1
		ld a,(destroyable_tiles_bank1+2)
		ld b,a	; 1 -> 0
		ld a,(power_pellet_types_bank1+2)
		ld e,a
		inc e	; e has the first tile type ID of the first scenario tile
collisionWithMap_player_bullet_collision_with_destroyablewall:
		; destroy the wall (we basically have to shift things to the right):
		push hl
			dec hl
			ld a,(hl)
			inc hl
			cp e
			jr c,collisionWithMap_player_bullet_collision_with_destroyablewall_case0
			cp c
			jr z,collisionWithMap_player_bullet_collision_with_destroyablewall_case0
collisionWithMap_player_bullet_collision_with_destroyablewall_case1:
			ld a,(hl)
			cp b
			jr z,collisionWithMap_player_bullet_collision_with_destroyablewall_case10
collisionWithMap_player_bullet_collision_with_destroyablewall_case11:
			ld (hl),c	; 0 -> 1
			dec hl
			ld (hl),b	; 1 -> 0
			jr collisionWithMap_player_bullet_collision_with_destroyablewall_done
collisionWithMap_player_bullet_collision_with_destroyablewall_case10:
			ld (hl),0
			dec hl
			ld (hl),b	; 1 -> 0
			jr collisionWithMap_player_bullet_collision_with_destroyablewall_done
collisionWithMap_player_bullet_collision_with_destroyablewall_case0:
			ld a,(hl)
			cp b
			jr z,collisionWithMap_player_bullet_collision_with_destroyablewall_case00
collisionWithMap_player_bullet_collision_with_destroyablewall_case01:
			ld (hl),c	; 0 -> 1
			dec hl
			ld (hl),0
			jr collisionWithMap_player_bullet_collision_with_destroyablewall_done
collisionWithMap_player_bullet_collision_with_destroyablewall_case00:
			ld (hl),0
			dec hl
			ld (hl),0
collisionWithMap_player_bullet_collision_with_destroyablewall_done:

			; check if we also need to destroy it in the second copy:
			ld a,iyl	; tile x coordinate of the collision
			cp 64
			jr c,collisionWithMap_player_bullet_collision_with_destroyablewall_no_need_to_copy
			ld d,h
			ld e,l
			ld bc,-64
			add hl,bc
			ex de,hl
			ldi
			ldi
collisionWithMap_player_bullet_collision_with_destroyablewall_no_need_to_copy:
			ld hl,SFX_destroyable_wall
			call play_SFX_with_high_priority
		pop hl
	pop de
	pop bc
	jr collisionWithMap_player_bullet_collision_if_not_laser


collisionWithMap_player_bullet_collision_with_enemy:
	; find the tile enemy that was collided with
	ld a,(in_boss)
	or a
	jr z,collisionWithMap_player_bullet_collision_with_enemy_not_boss
	ld a,(ix+PLAYER_BULLET_STRUCT_DAMAGE)
	ld (boss_hit),a
	jr collisionWithMap_player_bullet_collision_with_enemy_collision
collisionWithMap_player_bullet_collision_with_enemy_not_boss:
	push bc
		ld iy,tile_enemies
		ld b,MAX_TILE_ENEMIES
collisionWithMap_player_bullet_loop:
 		ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
 		or a
 		jr z,collisionWithMap_player_bullet_loop_next
 		ld a,(iy+TILE_ENEMY_STRUCT_X)
 		add a,-2
 		cp (ix+PLAYER_BULLET_STRUCT_TILE_X)
 		jp p,collisionWithMap_player_bullet_loop_next
 		inc a
 		add a,(iy+TILE_ENEMY_STRUCT_WIDTH)
 		cp (ix+PLAYER_BULLET_STRUCT_TILE_X)
 		jp m,collisionWithMap_player_bullet_loop_next

		ld a,(iy+TILE_ENEMY_STRUCT_Y)
		dec a
		cp (ix+PLAYER_BULLET_STRUCT_TILE_Y)
		jp p,collisionWithMap_player_bullet_loop_next
		add a,(iy+TILE_ENEMY_STRUCT_HEIGHT)
		cp (ix+PLAYER_BULLET_STRUCT_TILE_Y)
		jp m,collisionWithMap_player_bullet_loop_next

		ld c,(ix+PLAYER_BULLET_STRUCT_DAMAGE)
		call tile_enemy_hit
	pop bc
	jr nz,collisionWithMap_player_bullet_collision_with_enemy_collision
	; if it's destroyed and it's a laser/flame, the bullet goes through:
collisionWithMap_player_bullet_collision_if_not_laser:
	ld a,(ix+PLAYER_BULLET_STRUCT_TYPE)
	cp PLAYER_BULLET_TYPE_LASER
	jr z,collisionWithMap_player_bullet_collision_with_enemy_no_collision
	cp PLAYER_BULLET_TYPE_FLAME
	jr z,collisionWithMap_player_bullet_collision_with_enemy_no_collision

collisionWithMap_player_bullet_collision_with_enemy_collision:
	; collision
 	or 1
 	ret

collisionWithMap_player_bullet_collision_with_enemy_no_collision:
	xor a
	ret

collisionWithMap_player_bullet_loop_next:
		push de
			ld de,TILE_ENEMY_STRUCT_SIZE
			add iy,de
		pop de
	djnz collisionWithMap_player_bullet_loop
	pop bc
	; collision
 	or 1
 	ret


;-----------------------------------------------
; Collision between a player secondary bullet and the map or tile enemies:
; input:
; - ix: bullet
; return:
; - a = 0: no collision
; - a = 1: collision with bg
; - a = 2: collision with enemy
collisionWithMap_player_secondary_bullet:
	; calculate tile coordinates:
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
	add a,4
    rrca
    rrca
    rrca
    and 31
	ld hl,scroll_x_tile
	add a,(hl)
	ld c,a
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
	add a,5
    rrca
    rrca
    rrca
    and 31
	cp 22
	jr nc,collisionWithMap_player_secondary_bullet_no_collision
	ld b,a

	; calculate map pointer:
	ld e,a
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	; de now has the y ptr
	ld h,0
	ld l,c
	add hl,de

	; check for collision:
	ld a,(hl)
	cp FIRST_TILEENEMY_COLLIDABLE_TILE
	jr nc,collisionWithMap_player_secondary_bullet_collision_with_enemy
	cp FIRST_DESTROYABLEWALL_COLLIDABLE_TILE
	jr nc,collisionWithMap_player_secondary_bullet_collision_with_destroyablewall
	cp FIRST_WALL_COLLIDABLE_TILE
	jr nc,collisionWithMap_player_secondary_bullet_collision
collisionWithMap_player_secondary_bullet_no_collision:
	xor a
	ret

collisionWithMap_player_secondary_bullet_collision_with_enemy:
	; find the tile enemy that was collided with
	ld a,(in_boss)
	or a
	jr z,collisionWithMap_player_secondary_bullet_collision_with_enemy_not_boss
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE)
	ld (boss_hit),a
	jr collisionWithMap_player_secondary_bullet_collision_with_enemy_collision
collisionWithMap_player_secondary_bullet_collision_with_enemy_not_boss:

	ld e,c
	ld d,b

	; find the tile enemy that was collided with
	ld iy,tile_enemies
	ld b,MAX_TILE_ENEMIES
collisionWithMap_player_secondary_bullet_loop:
	ld a,(iy+TILE_ENEMY_STRUCT_TYPE)
	or a
	jp z,collisionWithMap_player_secondary_bullet_loop_next
	ld a,(iy+TILE_ENEMY_STRUCT_X)
	add a,-2
	cp e
	jp p,collisionWithMap_player_secondary_bullet_loop_next
	inc a
	add a,(iy+TILE_ENEMY_STRUCT_WIDTH)
	cp e
	jp m,collisionWithMap_player_secondary_bullet_loop_next

	ld a,(iy+TILE_ENEMY_STRUCT_Y)
	dec a
	cp d
	jp p,collisionWithMap_player_secondary_bullet_loop_next
	add a,(iy+TILE_ENEMY_STRUCT_HEIGHT)
	cp d
	jp m,collisionWithMap_player_secondary_bullet_loop_next

	ld c,(ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE)
	call tile_enemy_hit
collisionWithMap_player_secondary_bullet_collision_with_enemy_collision:
	; collision
 	ld a,2
 	ret

collisionWithMap_player_secondary_bullet_collision_with_destroyablewall:
	ld a,b	; recover y coordinate
 	cp 8	; are we in bank 1 or not
 	jr nc,collisionWithMap_player_secondary_bullet_collision_with_destroyablewall2

collisionWithMap_player_secondary_bullet_collision_with_destroyablewall1:
	ld a,c	; tile x
	ld iyl,a	
	call collisionWithMap_player_bullet_collision_with_destroyablewall1_entry_point
	; collision
 	ld a,1
	ret


collisionWithMap_player_secondary_bullet_collision_with_destroyablewall2:
	ld a,c	; tile x
	ld iyl,a	
	call collisionWithMap_player_bullet_collision_with_destroyablewall2_entry_point

collisionWithMap_player_secondary_bullet_collision:
	; collision
 	ld a,1
	ret


collisionWithMap_player_secondary_bullet_loop_next:
	push bc
		ld bc,TILE_ENEMY_STRUCT_SIZE
		add iy,bc
	pop bc
	djnz collisionWithMap_player_secondary_bullet_loop
	; collision
 	ld a,2
 	ret


;-----------------------------------------------
; input:
; - ix: secondary bullet to check
collisionWithSpriteEnemies_secondary_bullet:
	ld iy,enemies
	ld b,MAX_ENEMIES
collisionWithSpriteEnemies_secondary_bullet_loop:
	push bc
		ld a,(iy)
		and #7f	; we remove the power pellet bit
		jp z,collisionWithSpriteEnemies_secondary_bullet_loop_next
		dec a
		jp z,collisionWithSpriteEnemies_secondary_bullet_loop_next		; ENEMY_EXPLOSION

		; check collision:
		ld a,(iy+ENEMY_STRUCT_TILE_X)
		ld hl,scroll_x_tile
		sub (hl)
		add a,a
		add a,a
		add a,a
		add a,(iy+ENEMY_STRUCT_X)
		ld c,a
		ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_X)
		sub c
		cp -13
		jp m,collisionWithSpriteEnemies_secondary_bullet_loop_next
		cp 9
		jp p,collisionWithSpriteEnemies_secondary_bullet_loop_next
		ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_Y)
		sub (iy+ENEMY_STRUCT_Y)
		cp -6
		jp m,collisionWithSpriteEnemies_secondary_bullet_loop_next
		cp 13
		jp p,collisionWithSpriteEnemies_secondary_bullet_loop_next

		; collision!
		ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE)
		push iy
		push ix
			push iy
			pop ix
			call update_enemy_hit_internal
		pop ix
		pop iy
	pop bc
	or 1
	ret

collisionWithSpriteEnemies_secondary_bullet_loop_next:
		ld bc,ENEMY_STRUCT_SIZE
		add iy,bc
	pop bc
	djnz collisionWithSpriteEnemies_secondary_bullet_loop

	xor a
	ret
