;-----------------------------------------------
load_option_weapon_tiles:
	ld hl,weapon_tiles_directional_plt
	ld de,buffer5
	call unpack_compressed

	ld de,CHRTBL2+(FIRST_WEAPON_TILE+N_WEAPON_TILES)*8
	jp load_weapon_tiles_entry_point


;-----------------------------------------------
update_player_options:
	ld a,(interrupt_cycle)
	and #04
	jr z,update_player_options_odd_cycle
	ld de, COLOR_WHITE + 256 * OPTION_SPRITE
	jr update_player_options_color_set
update_player_options_odd_cycle:
	ld de, COLOR_LIGHT_BLUE + 256 * OPTION_SPRITE + 4

update_player_options_color_set:
	ld hl,option_sprite_attributes
	ld a,(player_y)
	sub 28
	jr nc,update_player_option1_no_y_carry
	xor a
update_player_option1_no_y_carry:
	ld (hl),a
	inc hl
	ld a,(player_x)
	sub 8
	jr nc,update_player_option1_no_x_carry
	xor a
update_player_option1_no_x_carry:
	ld (hl),a
	inc hl
	ld (hl),d
	inc hl
	ld (hl),e
	inc hl

	ld a,(player_option_weapon_level)
	dec a
	ret z

	ld a,(player_y)
	add a,24
	cp 21*8-4
	jr c,update_player_option2_no_y_carry
	ld a,21*8-4
update_player_option2_no_y_carry:
	ld (hl),a
	inc hl
	ld a,(player_x)
	sub 8
	jr nc,update_player_option2_no_x_carry
	xor a
update_player_option2_no_x_carry:
	ld (hl),a
	inc hl
	ld (hl),d
	inc hl
	ld (hl),e
	inc hl
	ret


;-----------------------------------------------
spawn_player_option_bullet:
	ld a,(player_option_weapon_level)
	or a
	ret z	; if no options, ignore!

	ld a,(player_option_weapon)
	cp WEAPON_BULLET_OPTION
	jr z,spawn_player_bullet_option_bullet
	cp WEAPON_MISSILE_OPTION
	jr z,spawn_player_missile_option_bullet
	cp WEAPON_DIRECTIONAL_OPTION
	jp z,spawn_player_directional_option_bullet
	ret

spawn_player_bullet_option_bullet:
	ld iy,option_sprite_attributes
	ld c,PLAYER_BULLET_TYPE_BULLET
	call spawn_player_bullet_internal
	ret nz	; no spot for bullets, just give up

	; change the tile to use the option tiles:
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE)
	add a,N_WEAPON_TILES
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a

	; start cooldown:
	ld hl,player_option_weapon_cooldown
	ld de,player_option_weapon_cooldown_state
	ldi

	ld a,(player_option_weapon_level)
	dec a
	ret z	; only one option, we are done!

	ld iy,option_sprite_attributes+4
	ld c,PLAYER_BULLET_TYPE_BULLET
	call spawn_player_bullet_internal
	ret nz	; no spot for bullets, just give up

	; change the tile to use the option tiles:
	ld a,(ix+PLAYER_BULLET_STRUCT_TILE)
	add a,N_WEAPON_TILES
	ld (ix+PLAYER_BULLET_STRUCT_TILE),a
	ret


spawn_player_missile_option_bullet:
	call spawn_player_missile_option_bullet_find_spot
	ret nz	; no spot for missiles, just give up

	; start cooldown:
	ld hl,player_option_weapon_cooldown
	ld de,player_option_weapon_cooldown_state
	ldi

	; set coordinates:
	ld a,(option_sprite_attributes+1)
	add a,4
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	ld a,(option_sprite_attributes)
	add a,2
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_STATE),0
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE),WEAPON_UP_MISSILES
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE),MISSILE_DAMAGE

	ld a,(player_option_weapon_level)
	dec a
	ret z	; only one option, we are done!

	call spawn_player_missile_option_bullet_find_spot
	ret nz	; no spot for missiles, just give up

	; set coordinates:
	ld a,(option_sprite_attributes+4+1)
	add a,4
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_X),a
	ld a,(option_sprite_attributes+4)
	add a,4
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_Y),a
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_STATE),0
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE),WEAPON_DOWN_MISSILES
	ld (ix+PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE),MISSILE_DAMAGE
	ret


spawn_player_missile_option_bullet_find_spot:
	ld ix,player_secondary_bullets
	ld de,PLAYER_SECONDARY_BULLET_STRUCT_SIZE
	ld b,e  ; MAX_PLAYER_SECONDARY_BULLETS happens to be equal to PLAYER_SECONDARY_BULLET_STRUCT_SIZE
; 	ld b,MAX_PLAYER_SECONDARY_BULLETS

spawn_player_missile_option_bullet_find_spot_loop:	
	ld a,(ix+PLAYER_SECONDARY_BULLET_STRUCT_TYPE)
	or a
	jr z,spawn_player_missile_option_bullet_find_spot_found
	add ix,de
	djnz spawn_player_missile_option_bullet_find_spot_loop
	; no spot found, ignore...
	or 1
	ret
spawn_player_missile_option_bullet_find_spot_found:
	xor a
	ret


spawn_player_directional_option_bullet:
 	ld iy,option_sprite_attributes
 	ld c,PLAYER_BULLET_TYPE_DIRECTIONAL_BULLET
 	call spawn_player_bullet_internal
 	ret nz	; no spot for bullets, just give up

 	; change the tile to use the option tiles:
 	ld (ix+PLAYER_BULLET_STRUCT_TILE),FIRST_WEAPON_TILE+N_WEAPON_TILES
 	ld a,(player_last_movement)
 	ld (ix+PLAYER_BULLET_STRUCT_DIRECTION),a

	; start cooldown:
	ld hl,player_option_weapon_cooldown
	ld de,player_option_weapon_cooldown_state
	ldi

	ld a,(player_option_weapon_level)
	dec a
	ret z	; only one option, we are done!

	ld iy,option_sprite_attributes+4
	ld c,PLAYER_BULLET_TYPE_DIRECTIONAL_BULLET
	call spawn_player_bullet_internal
	ret nz	; no spot for bullets, just give up

	; change the tile to use the option tiles:
 	ld (ix+PLAYER_BULLET_STRUCT_TILE),FIRST_WEAPON_TILE+N_WEAPON_TILES
 	ld a,(player_last_movement)
 	ld (ix+PLAYER_BULLET_STRUCT_DIRECTION),a 	
	ret


