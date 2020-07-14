;-----------------------------------------------
; updates the behavior of all the enemies, and also updates their sprites
update_enemy_bullets:
	ld ix,enemy_bullets
	ld b,MAX_ENEMY_BULLETS
update_enemy_bullets_loop:
	ld a,(ix)
	or a
	jp z,update_enemy_bullets_loop_next_no_pop
	push bc
		dec a
		jp z,update_enemy_bullet_pellet				; ENEMY_BULLET_PELLET
		dec a
		jp z,update_enemy_bullet_laser_up_left		; ENEMY_BULLET_LASER_UP_LEFT
		dec a
		jp z,update_enemy_bullet_laser_down_left	; ENEMY_BULLET_LASER_DOWN_LEFT
		dec a
		jp z,update_enemy_bullet_laser_left			; ENEMY_BULLET_LASER_LEFT
		; ...
update_enemy_bullets_loop_next:
	pop bc
update_enemy_bullets_loop_next_no_pop:
	ld de,ENEMY_BULLET_STRUCT_SIZE
	add ix,de
	djnz update_enemy_bullets_loop
	ret


;-----------------------------------------------
update_enemy_bullet_pellet:
	; collision with a wall:
	ld a,(in_boss)	; no collisions while we are in a boss!
	or a
	jr nz,update_enemy_bullet_pellet_no_wall_collision
	ld c,(ix+ENEMY_BULLET_STRUCT_X)
	ld b,(ix+ENEMY_BULLET_STRUCT_Y)
	srl c
	srl c
	srl c
	ld a,(scroll_x_tile)
	add a,c
	ld c,a
	srl b
	srl b
	srl b
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
	ld a,(hl)
	cp FIRST_TILEENEMY_COLLIDABLE_TILE
	jr nc,update_enemy_bullet_pellet_no_wall_collision
	cp FIRST_WALL_COLLIDABLE_TILE
	jp nc,update_enemy_bullet_clear_bullet
update_enemy_bullet_pellet_no_wall_collision:

	; collision with player:
	ld a,(player_state)
	or a	; cp PLAYER_STATE_DEFAULT
	jp nz,update_enemy_bullet_pellet_no_player_collision
	ld c,(ix+ENEMY_BULLET_STRUCT_X)
	ld b,(ix+ENEMY_BULLET_STRUCT_Y)
	call collision_with_player
	jp z,update_enemy_bullet_hit_player
update_enemy_bullet_pellet_no_player_collision:

    ; Calculate the offsets in c,b:
 	ld de,0	; e,d will accumulate the movement we need to apply to the bullet in x,y    
    ld a,(ix+ENEMY_BULLET_STRUCT_VY)
    or a
    jp p,update_enemy_bullet_pellet_no_yspeed_flip
    neg
update_enemy_bullet_pellet_no_yspeed_flip:
    ld b,a
    ld a,(ix+ENEMY_BULLET_STRUCT_VX)
    or a
    jp p,update_enemy_bullet_pellet_no_xspeed_flip
    neg
update_enemy_bullet_pellet_no_xspeed_flip:
    ld c,a
    cp b
    jp c,update_enemy_bullet_pellet_y_is_bigger

	; Move the bullet more or less depending on its speed:
 	ld hl,difficulty_bullet_speed
 	ld a,(hl)
 	ld iyl,a
update_enemy_bullet_pellet_loop:
    ; Bresenham for when the XDIFF > YDIFF
    ld a,(ix+ENEMY_BULLET_STATE)
update_enemy_bullet_pellet_x_is_bigger:
    sub b       ; we subtract y difference from the error term 
    jp p,update_enemy_bullet_pellet_x_is_bigger_no_error_overflow
    inc d
    add a,c
update_enemy_bullet_pellet_x_is_bigger_no_error_overflow:
    inc e
	dec iyl
	jp nz,update_enemy_bullet_pellet_loop   
    ld (ix+ENEMY_BULLET_STATE),a
	jp update_enemy_bullet_pellet_choose_quadrant 

update_enemy_bullet_pellet_y_is_bigger:
	; Move the bullet more or less depending on its speed:
 	ld hl,difficulty_bullet_speed
 	ld a,(hl)
 	ld iyl,a
    ld a,(ix+ENEMY_BULLET_STATE)
update_enemy_bullet_pellet_loop2:
    ; Bresenham for when the XDIFF < YDIFF
    sub c       ; we subtract y difference from the error term 
    jp p,update_enemy_bullet_pellet_y_is_bigger_no_error_overflow
    inc e
    add a,b
update_enemy_bullet_pellet_y_is_bigger_no_error_overflow:
    inc d
	dec iyl
	jp nz,update_enemy_bullet_pellet_loop2
    ld (ix+ENEMY_BULLET_STATE),a

update_enemy_bullet_pellet_choose_quadrant:
    ld a,(ix+ENEMY_BULLET_STRUCT_VY)
    or a
    jp p,update_enemy_bullet_pellet_no_yspeed_flip2
    xor a
    sub d
    ld d,a
update_enemy_bullet_pellet_no_yspeed_flip2:
    ld a,(ix+ENEMY_BULLET_STRUCT_VX)
    or a
    jp p,update_enemy_bullet_pellet_no_xspeed_flip2
    xor a
    sub e
    ld e,a
update_enemy_bullet_pellet_no_xspeed_flip2:

	; move the bullet:
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	add a,e
	cp 251	; 255-4 (where 4 is the maximum bullet speed)
	jp nc,update_enemy_bullet_clear_bullet
	ld (ix+ENEMY_BULLET_STRUCT_X),a

	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	add a,d
	ld (ix+ENEMY_BULLET_STRUCT_Y),a
	cp 192
	jp nc,update_enemy_bullet_clear_bullet

	jp update_enemy_bullet_draw_sprite_only_coordinate_change


;-----------------------------------------------
update_enemy_bullet_laser_up_left:
	; collision with player:
	ld c,(ix+ENEMY_BULLET_STRUCT_X)
	inc c
	inc c
	ld b,(ix+ENEMY_BULLET_STRUCT_Y)
	inc b
	inc b
	call collision_with_player
	jp z,update_enemy_bullet_hit_player

	ld a,8
	add a,c
	ld c,a
	ld a,8
	add a,b
	ld b,a
	call collision_with_player
	jp z,update_enemy_bullet_hit_player

	ld a,(ix+ENEMY_BULLET_STATE)
	dec a
	ld hl,SFX_moai_laser	
	call z,play_SFX_with_high_priority
	ld a,(ix+ENEMY_BULLET_STATE)
	or a
	jp nz,update_enemy_bullet_laser_up_left_wait

	; move the bullet:
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	dec a
	jp z,update_enemy_bullet_clear_bullet
	sub 7
	ld (ix+ENEMY_BULLET_STRUCT_X),a
	dec a
	jp z,update_enemy_bullet_clear_bullet
	
	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	sub 8
	jp z,update_enemy_bullet_clear_bullet
	ld (ix+ENEMY_BULLET_STRUCT_Y),a

	ld de, ENEMY_BULLET_SPRITE_LASER_UP_LEFT + 256 * COLOR_LIGHT_RED
	jp update_enemy_bullet_draw_sprite

update_enemy_bullet_laser_up_left_wait:
	dec (ix+ENEMY_BULLET_STRUCT_X)
	jp z,update_enemy_bullet_clear_bullet
	ld a,(ix+ENEMY_BULLET_STATE)
	dec a
	ld (ix+ENEMY_BULLET_STATE),a
 	ld de, ENEMY_BULLET_SPRITE_LASER_UP_LEFT + 4 + 256 * COLOR_LIGHT_RED
	jp update_enemy_bullet_draw_sprite


;-----------------------------------------------
update_enemy_bullet_laser_down_left:
	; collision with player:
	ld c,(ix+ENEMY_BULLET_STRUCT_X)
	inc c
	inc c
	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	add a,10
	ld b,a
	call collision_with_player
	jp z,update_enemy_bullet_hit_player

	ld a,8
	add a,c
	ld c,a
	ld a,-8
	add a,b
	ld b,a
	call collision_with_player
	jp z,update_enemy_bullet_hit_player

	ld a,(ix+ENEMY_BULLET_STATE)
	dec a
	ld hl,SFX_moai_laser	
	call z,play_SFX_with_high_priority
	ld a,(ix+ENEMY_BULLET_STATE)
	or a
	jp nz,update_enemy_bullet_laser_down_left_wait

	; move the bullet:
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	cp 1
	jp z,update_enemy_bullet_clear_bullet
	sub 8
	ld (ix+ENEMY_BULLET_STRUCT_X),a
	dec a
	jp z,update_enemy_bullet_clear_bullet
	
	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	add a,8
	jp z,update_enemy_bullet_clear_bullet
	cp 192
	jp nc,update_enemy_bullet_clear_bullet
	ld (ix+ENEMY_BULLET_STRUCT_Y),a

 	ld de, ENEMY_BULLET_SPRITE_LASER_DOWN_LEFT + 256 * COLOR_LIGHT_RED
	jp update_enemy_bullet_draw_sprite

update_enemy_bullet_laser_down_left_wait:
	dec (ix+ENEMY_BULLET_STRUCT_X)
	jp z,update_enemy_bullet_clear_bullet
	ld a,(ix+ENEMY_BULLET_STATE)
	dec a
	ld (ix+ENEMY_BULLET_STATE),a
 	ld de, ENEMY_BULLET_SPRITE_LASER_DOWN_LEFT + 4 + 256 * COLOR_LIGHT_RED
	jp update_enemy_bullet_draw_sprite


;-----------------------------------------------
update_enemy_bullet_laser_left:
	; collision with player:
	ld c,(ix+ENEMY_BULLET_STRUCT_X)
	inc c
	inc c
	ld b,(ix+ENEMY_BULLET_STRUCT_Y)
	inc b
	inc b
	call collision_with_player
	jp z,update_enemy_bullet_hit_player

	; move the bullet:
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	cp 1
	jp z,update_enemy_bullet_clear_bullet
	sub 8
	ld (ix+ENEMY_BULLET_STRUCT_X),a
	dec a
	jp z,update_enemy_bullet_clear_bullet
	
 	ld de, ENEMY_BULLET_SPRITE_LASER_LEFT + 256 * COLOR_LIGHT_RED
	jp update_enemy_bullet_draw_sprite


;-----------------------------------------------
update_enemy_bullet_hit_player:
	; bullet hits player!:
	ld c,1	; strength of the hit
	push ix
		call update_player_collision
	pop ix
update_enemy_bullet_clear_bullet:
	ld (ix),0
	ld l,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR)
	ld h,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR+1)
	ld (hl),200
	jp update_enemy_bullets_loop_next


;-----------------------------------------------
; input:
; - ix: enemy struct pointer
; - e: sprite index
; - d: sprite color
update_enemy_bullet_draw_sprite:
	; update sprite:
	ld l,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR)
	ld h,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR+1)
	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	ld (hl),a
	inc hl
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	ld (hl),a
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	jp update_enemy_bullets_loop_next


update_enemy_bullet_draw_sprite_only_coordinate_change:
	; update sprite:
	ld l,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR)
	ld h,(ix+ENEMY_BULLET_STRUCT_SPRITE_PTR+1)
	ld a,(ix+ENEMY_BULLET_STRUCT_Y)
	ld (hl),a
	inc hl
	ld a,(ix+ENEMY_BULLET_STRUCT_X)
	ld (hl),a
	jp update_enemy_bullets_loop_next


;-----------------------------------------------
; searches for an empty spot in the enemy bullets list
; returns:
; - iy: ptr to the spot if found
; - z: if found
; - nz: if not found
find_enemy_bullet_spot:
	; look for a bullet slot:
	ld iy,enemy_bullets
	ld de,ENEMY_BULLET_STRUCT_SIZE
	ld b,MAX_ENEMY_BULLETS
find_enemy_bullet_spot_loop:
	ld a,(iy)
	or a
	ret z
	add iy,de
	djnz find_enemy_bullet_spot_loop
	; found no bullet spot!
	or 1
	ret


;-----------------------------------------------
; input:
; - c,b: x, y where to spawn the bullet (pixel coordinates)
; preserves ix,de
enemy_fire_bullet:
	push de
		push bc
			call find_enemy_bullet_spot
		pop bc
		jp nz,enemy_fire_bullet_no_spot

		ld (iy+ENEMY_BULLET_STRUCT_X), c
		ld a,(player_x)
		srl a
		srl c
		sub c
		ld (iy+ENEMY_BULLET_STRUCT_VX), a

		ld (iy+ENEMY_BULLET_STRUCT_Y), b
		ld a,(player_y)
		srl a
		srl b
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
enemy_fire_bullet_no_spot:		
	pop de
	ret
