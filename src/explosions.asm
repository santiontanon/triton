;-----------------------------------------------
; input:
; - iy: tile enemy that is exploding
spawn_sprite_explosion:
	; look for an enemy slot:
	ld ix,enemies
	ld de,ENEMY_STRUCT_SIZE
	ld b,MAX_ENEMIES
	ld a,(scroll_x_tile)
	ld c,a
spawn_sprite_explosion_loop:
	ld a,(ix)
	or a
	jp z,spawn_sprite_explosion_found_spot
	add ix,de
	djnz spawn_sprite_explosion_loop
	; no spot available:
	ret
spawn_sprite_explosion_found_spot:
	; create an enemy in ix:
	ld (ix+ENEMY_STRUCT_TYPE),ENEMY_EXPLOSION
	ld a,(iy+TILE_ENEMY_STRUCT_X)
	ld (ix+ENEMY_STRUCT_TILE_X),a
	ld a,(iy+TILE_ENEMY_STRUCT_Y)
	add a,a
	add a,a
	add a,a
	ld (ix+ENEMY_STRUCT_Y),a
	ld (ix+ENEMY_STRUCT_X),0
	ld (ix+ENEMY_STRUCT_STATE),0
	ld (ix+ENEMY_STRUCT_TIMER),3
	ret


;-----------------------------------------------
; input:
; - iy: tile enemy that is exploding
spawn_tile_explosion:
	ld ix,tile_explosions
	ld de,TILE_EXPLOSION_STRUCT_SIZE
	ld b,MAX_TILE_EXPLOSIONS
spawn_tile_explosion_loop:
	ld a,(ix+TILE_EXPLOSION_TIME)
	or a
	jp nz,spawn_tile_explosion_loop_next
	; found!
	ld hl,SFX_explosion
	call play_SFX_with_high_priority

	ld (ix+TILE_EXPLOSION_TIME),12
	ld a,(iy+TILE_ENEMY_STRUCT_X)
	ld (ix+TILE_EXPLOSION_X),a
	ld a,(iy+TILE_ENEMY_STRUCT_Y)
	ld (ix+TILE_EXPLOSION_Y),a
	ld l,(iy+TILE_ENEMY_STRUCT_PTRL)
	ld h,(iy+TILE_ENEMY_STRUCT_PTRH)
	inc hl
	ld (ix+TILE_EXPLOSION_PTRL),l
	ld (ix+TILE_EXPLOSION_PTRH),h
	; save background:
	ld e,ixl
	ld d,ixh
	inc de
	ld a,4
	ld bc,4
	jp save_bg_tiles

spawn_tile_explosion_loop_next:
	add ix,de
	djnz spawn_tile_explosion_loop	
	ret


;-----------------------------------------------
; updates and also draws tile explosions
update_explosions:
	ld ix,tile_explosions
	ld de,TILE_EXPLOSION_STRUCT_SIZE
	ld b,MAX_TILE_EXPLOSIONS
update_explosions_loop:
	ld a,(ix+TILE_EXPLOSION_TIME)
	or a
	jp z,update_explosions_loop_next
 	dec (ix+TILE_EXPLOSION_TIME)
	jp z,update_explosions_loop_next		
 	ld hl,tile_explosion
 	cp 8
 	jp p,update_explosions_draw
 	ld hl,tile_explosion+16
 	cp 4
 	jp p,update_explosions_draw
 	ld hl,tile_explosion+32
update_explosions_draw:
 	push de
 	push bc
 		ld e,(ix+TILE_EXPLOSION_PTRL)
 		ld d,(ix+TILE_EXPLOSION_PTRH)
 		ld a,4	; height
 		ld bc,4 ; width
 		call copy_enemy_tiles
	pop bc
 	pop de
update_explosions_loop_next:
	add ix,de
	djnz update_explosions_loop
	ret


;-----------------------------------------------
; restores the background of explosions
explosions_restore_bg:
	ld ix,tile_explosions
	ld de,TILE_EXPLOSION_STRUCT_SIZE
	ld b,MAX_TILE_EXPLOSIONS
explosions_restore_bg_loop:
	ld a,(ix+TILE_EXPLOSION_TIME)
	or a
	jp z,explosions_restore_bg_loop_next
 	push de
 	push bc
 		ld l,(ix+TILE_EXPLOSION_PTRL)
 		ld h,(ix+TILE_EXPLOSION_PTRH)
 		ld e,ixl
 		ld d,ixh
 		inc de	; TILE_EXPLOSION_BG_BUFFER
 		ex de,hl
 		ld a,4	; height
 		ld bc,4 ; width
 		call copy_enemy_tiles
	pop bc
 	pop de	
explosions_restore_bg_loop_next:
	add ix,de
	djnz explosions_restore_bg_loop
	ret


;-----------------------------------------------
adjust_explosion_positions_after_scroll_restart:
	ld ix,tile_explosions
	ld de,TILE_EXPLOSION_STRUCT_SIZE
	ld b,MAX_TILE_EXPLOSIONS
adjust_explosion_positions_after_scroll_restart_loop:
	ld a,(ix)
	or a
	jp z,adjust_explosion_positions_after_scroll_restart_loop_next
	ld a,(ix+TILE_EXPLOSION_X)
	sub 64
	ld (ix+TILE_EXPLOSION_X),a
	push bc
		ld l,(ix+TILE_EXPLOSION_PTRL)
		ld h,(ix+TILE_EXPLOSION_PTRH)
		ld bc,-64
		add hl,bc
		ld (ix+TILE_EXPLOSION_PTRL),l
		ld (ix+TILE_EXPLOSION_PTRH),h
	pop bc
adjust_explosion_positions_after_scroll_restart_loop_next:
	add ix,de
	djnz adjust_explosion_positions_after_scroll_restart_loop
	ret


;-----------------------------------------------
; saves tiles from the map buffer
; input:
; - de: buffer to save the data
; - hl: ptr to the address in the pattern to start copying
; - a: block height
; - bc: block width
save_bg_tiles:
	push bc	
		push hl
			ldir
		pop hl
		ld bc,MAP_BUFFER_WIDTH
		add hl,bc
	pop bc
	dec a
	jr nz,save_bg_tiles
	ret
