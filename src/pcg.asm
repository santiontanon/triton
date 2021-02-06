;-----------------------------------------------
; A useful macro for random number generation fod PCG
JP_IF_RANDOM_GEQ: MACRO ?threshold_ptr,?label
	call random
	push hl
		ld hl,?threshold_ptr
		sub (hl)
	pop hl
	jp nc,?label
	ENDM


JP_IF_RANDOM_GEQ_NO_PUSH_HL: MACRO ?threshold_ptr,?label
	call random
	ld hl,?threshold_ptr
	sub (hl)
	jp nc,?label
	ENDM


RET_IF_RANDOM_GEQ: MACRO ?threshold_ptr
	call random
	push hl
		ld hl,?threshold_ptr
		sub (hl)
	pop hl
	ret nc
	ENDM	


;-----------------------------------------------
; chooses the next pattern to be added to the map
; - it reads the current constraint from "PCG_pattern_constraint"
; - chooses a pattern and stores its pointer in "PCG_last_pattern_used_ptr"
; - updates "PCG_pattern_constraint" 
	IF MAP_BUFFER_WIDTH != 128
		ERROR "MAP_BUFFER_WIDTH != 128, which is assumed by PCG_choosePattern!"
	ENDIF
	IF PCG_PATTERN_WIDTH != 16
		ERROR "PCG_PATTERN_WIDTH != 16, which is assumed by PCG_choosePattern!"
	ENDIF
PCG_choosePattern:
	; calculate the position where this PCG pattern will be in the buffer:
	ld a,(scroll_x_tile)
	add a,PCG_PATTERN_WIDTH*3
PCG_choosePattern_continue:
	ld (PCG_next_pattern_x),a

	ld hl,PCG_remaining_empty_patterns
	ld a,(hl)
	or a
	jr z,PCG_choosePattern_using_constraint
	; we still want some more empty patterns:
	dec (hl)

PCG_choosePattern_empty:
	ld hl,pcgPatterns

PCG_choosePattern_match:
	ld (PCG_last_pattern_used_ptr),hl	
	inc hl
	ld de,PCG_pattern_constraint
	ldi
	ld hl,pcg_map_pattern_buffer
	ld (PCG_respawn_enemies_ptr),hl
	xor a
	ld (PCG_respawn_enemies_row),a
	ret

PCG_choosePattern_empty_at_level_end:
	ld hl,level_end_countdown
	ld a,(hl)
	or a
	jp z,state_level_complete_check
	dec (hl)
	jr PCG_choosePattern_empty

PCG_choosePattern_using_constraint:
	ld hl,difficulty_level_length
	ld a,(hl)
	or a
	jr nz,PCG_choosePattern_using_constraint_level_still_going
	ld a,(PCG_pattern_constraint)
	dec a	; empty constraint
	; level is over!
	jr z,PCG_choosePattern_empty_at_level_end

	inc (hl)	; increment, since we will decrement below (so, we keep it at 0)
PCG_choosePattern_using_constraint_level_still_going:
	dec (hl)	; decrease the length left in the current level
	ld a,(PCG_pattern_constraint)
	ld e,a

	ld bc,4
	ld hl,(PCG_last_pattern_used_ptr)
	add hl,bc	; skip the last one used to avoid repetition bias
PCG_choosePattern_loop:
	ld a,(hl)
	or a
	jr z,PCG_choosePattern_restart
	cp e
	jr z,PCG_choosePattern_potential_match
	add hl,bc
	jr PCG_choosePattern_loop
PCG_choosePattern_restart:
	ld hl,pcgPatterns
	jr PCG_choosePattern_loop

PCG_choosePattern_potential_match:
	ld a,(difficulty_level_length)
	or a
	jr nz,PCG_choosePattern_potential_match_no_level_end
	inc hl
	ld a,(hl)	; get the next constraint
	dec hl
	dec a	; if it's an empty constraint, choose it and end the level!
	jr z,PCG_choosePattern_match
	add hl,bc
	jr PCG_choosePattern_loop

PCG_choosePattern_potential_match_no_level_end:
	call random
	and #80
	jr z,PCG_choosePattern_match
	add hl,bc
	jr PCG_choosePattern_loop



;-----------------------------------------------
; unpacks the patten that was chosen by PCG_choosePattern to "pcg_map_pattern_buffer"
PCG_unpackPattern:	
	ld hl,(PCG_last_pattern_used_ptr)
	inc hl
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	ld de,pcg_map_pattern_buffer
	; jp unpack_compressed
	jp pletter_unpack	; even if everything else is compressed with aplib, these are
						; compressed with pletter, as it saves space doing it this way 
						; (even considering the extra space of having two separate compressors
						;  in the code!)


;-----------------------------------------------
; if spot if found, X, Y, state and timer are also initialized
; input:
; - hl: ptr to where the tile enemy marker was
; returns:
; - ix: a pointer where to store the tile-based enemy if found
; - z: if we could find a spot
; - nz: if we could not find a spot
; modifies af, de, ix
find_tile_enemy_spot:
	push bc
		ld ix,tile_enemies
		ld de,TILE_ENEMY_STRUCT_SIZE
		ld b,MAX_TILE_ENEMIES
find_tile_enemy_spot_loop:
		ld a,(ix)
		or a
		jr z, find_tile_enemy_spot_found
		add ix,de
		djnz find_tile_enemy_spot_loop
		or 1	; spot not found
	pop bc
	ret
find_tile_enemy_spot_found:
	pop bc
	ld a,(PCG_respawn_enemies_row)
	add a,a
	add a,2
	sub c	; y = (PCG_respawn_enemies_row)*2 + (2 - c)
	ld (ix+TILE_ENEMY_STRUCT_Y),a
	ld a,(PCG_next_pattern_x)
	add a,PCG_PATTERN_WIDTH
	sub b
	; x = (PCG_next_pattern_x) + (16 - b)
	ld (ix+TILE_ENEMY_STRUCT_X),a
	ld (ix+TILE_ENEMY_STRUCT_STATE),0
	ld (ix+TILE_ENEMY_STRUCT_TIMER),0
	ld a,(hl)
	ld (ix+TILE_ENEMY_STRUCT_CLEAR_TILE),a	; which tile to use when deleting this enemy

	; pointer to the mapBuffer where this enemy will be drawn:
	push hl
	push bc
		ld a,(ix+TILE_ENEMY_STRUCT_Y)
		ld hl,mapBuffer
		ld bc,MAP_BUFFER_WIDTH
		or a
		jr z,find_tile_enemy_spot_ptr_loop_done
find_tile_enemy_spot_ptr_loop:
		add hl,bc
		dec a
		jr nz,find_tile_enemy_spot_ptr_loop
find_tile_enemy_spot_ptr_loop_done:
		ld b,0
		ld c,(ix+TILE_ENEMY_STRUCT_X)
		add hl,bc
		dec hl	; pointer to draw is 1 byte earlier
		ld (ix+TILE_ENEMY_STRUCT_PTRL),l
		ld (ix+TILE_ENEMY_STRUCT_PTRH),h	
	pop bc
	pop hl
	xor a
	ret


;-----------------------------------------------
; Goes through the pattern in "pcg_map_pattern_buffer" looking for potential enemy locations and spawns tile-based enemies
PCG_spawnTileBasedEnemies:
	ld b,11
PCG_spawnTileBasedEnemies_loop:
	push bc
		call PCG_spawnTileBasedEnemies_2rows
	pop bc
	djnz PCG_spawnTileBasedEnemies_loop
	ret


PCG_spawnTileBasedEnemies_2rows:
	ld a,(global_state_selected_level_type)
	or a
	jr z,PCG_spawnTileBasedEnemies_moai_2rows
	dec a
	jr z,PCG_spawnTileBasedEnemies_tech_2rows
	dec a
	jr z,PCG_spawnTileBasedEnemies_water_2rows
	jr PCG_spawnTileBasedEnemies_temple_2rows


PCG_spawnTileBasedEnemies_enemy_spawned:
	ld a,(global_state_selected_level_type)
	or a
	jr z,PCG_spawnTileBasedEnemies_moai_enemy_spawned
	dec a
	jr z,PCG_spawnTileBasedEnemies_tech_enemy_spawned
	dec a
	jr z,PCG_spawnTileBasedEnemies_water_enemy_spawned
	jr PCG_spawnTileBasedEnemies_temple_enemy_spawned


PCG_spawnTileBasedEnemies_moai_2rows:
	ld c,2
	ld hl,(PCG_respawn_enemies_ptr)
PCG_spawnTileBasedEnemies_moai_loop_y:
	ld b,PCG_PATTERN_WIDTH
PCG_spawnTileBasedEnemies_moai_loop_x:
	ld a,(hl)
	inc a ; cp #ff
	jr z,PCG_spawnTileBasedEnemies_turret
	inc a ; cp #fe
	jp z,PCG_spawnTileBasedEnemies_moai
	inc a ; cp #fd
	jp z,PCG_spawnTileBasedEnemies_growingwall
PCG_spawnTileBasedEnemies_moai_enemy_spawned:
	inc hl
	djnz PCG_spawnTileBasedEnemies_moai_loop_x
	dec c
	jr nz,PCG_spawnTileBasedEnemies_moai_loop_y
PCG_spawnTileBasedEnemies_2rows_moai_done:
PCG_spawnTileBasedEnemies_2rows_tech_done:
PCG_spawnTileBasedEnemies_2rows_water_done:	
PCG_spawnTileBasedEnemies_2rows_temple_done:	
	ld (PCG_respawn_enemies_ptr),hl
	ld hl,PCG_respawn_enemies_row
	inc (hl)
	ret


PCG_spawnTileBasedEnemies_tech_2rows:
	ld c,2
	ld hl,(PCG_respawn_enemies_ptr)
PCG_spawnTileBasedEnemies_tech_loop_y:
	ld b,PCG_PATTERN_WIDTH
PCG_spawnTileBasedEnemies_tech_loop_x:
	ld a,(hl)
 	inc a ; cp #ff
 	jr z,PCG_spawnTileBasedEnemies_turret
 	inc a ; cp #fe
 	jp z,PCG_spawnTileBasedEnemies_generator
; 	inc a ; cp #fd
; 	jp z,PCG_spawnTileBasedEnemies_growingwall
PCG_spawnTileBasedEnemies_tech_enemy_spawned:
	inc hl
	djnz PCG_spawnTileBasedEnemies_tech_loop_x
	dec c
	jr nz,PCG_spawnTileBasedEnemies_tech_loop_y
	jr PCG_spawnTileBasedEnemies_2rows_tech_done


PCG_spawnTileBasedEnemies_water_2rows:
	ld c,2
	ld hl,(PCG_respawn_enemies_ptr)
PCG_spawnTileBasedEnemies_water_loop_y:
	ld b,PCG_PATTERN_WIDTH
PCG_spawnTileBasedEnemies_water_loop_x:
	ld a,(hl)
 	inc a ; cp #ff
 	jr z,PCG_spawnTileBasedEnemies_turret
	inc a ; cp #fe
 	jp z,PCG_spawnTileBasedEnemies_water_dome
 	inc a ; cp #fd
 	jp z,PCG_spawnTileBasedEnemies_falling_rocks
PCG_spawnTileBasedEnemies_water_enemy_spawned:
	inc hl
	djnz PCG_spawnTileBasedEnemies_water_loop_x
	dec c
	jr nz,PCG_spawnTileBasedEnemies_water_loop_y
	jr PCG_spawnTileBasedEnemies_2rows_water_done


PCG_spawnTileBasedEnemies_temple_2rows:
	ld c,2
	ld hl,(PCG_respawn_enemies_ptr)
PCG_spawnTileBasedEnemies_temple_loop_y:
	ld b,PCG_PATTERN_WIDTH
PCG_spawnTileBasedEnemies_temple_loop_x:
	ld a,(hl)
 	inc a ; cp #ff
 	jr z,PCG_spawnTileBasedEnemies_turret
	inc a ; cp #fe
 	jp z,PCG_spawnTileBasedEnemies_temple_snake
 	inc a ; cp #fd
 	jp z,PCG_spawnTileBasedEnemies_temple_column
PCG_spawnTileBasedEnemies_temple_enemy_spawned:
	inc hl
	djnz PCG_spawnTileBasedEnemies_temple_loop_x
	dec c
	jr nz,PCG_spawnTileBasedEnemies_temple_loop_y
	jr PCG_spawnTileBasedEnemies_2rows_temple_done

;-----------------------------------------------
clearEnemyMarker:
	dec hl
	ld a,(hl)
	inc hl
	ld (hl),a
	ret


;-----------------------------------------------
PCG_spawnTileBasedEnemies_turret:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 

	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld a,(difficulty_enemy_health_med)
	ld (ix+TILE_ENEMY_STRUCT_HP),a
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),3
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),2
	ld a,(PCG_respawn_enemies_row)
	cp 4
	jp m,PCG_spawnTileBasedEnemies_turret_top
PCG_spawnTileBasedEnemies_turret_bottom:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_G_TURRET_BOTTOM
	push hl
	push bc
		; adjust Y coordinate:
		ld a,(ix+TILE_ENEMY_STRUCT_Y)
		dec a
		ld (ix+TILE_ENEMY_STRUCT_Y),a
		push hl
			ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
			ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
			ld bc,-MAP_BUFFER_WIDTH
			add hl,bc
			ld (ix+TILE_ENEMY_STRUCT_PTRL),l
			ld (ix+TILE_ENEMY_STRUCT_PTRH),h
		pop hl

; 		ld bc,-(PCG_PATTERN_WIDTH+1)
		ld c,(-(PCG_PATTERN_WIDTH+1)) & #00ff  ; assuming b will not change

		add hl,bc	; start position
		ex de,hl
		ld hl,(level_type_tile_enemies_bank1)
		ld bc,TURRET_START_OFFSET
		add hl,bc
		JP_IF_RANDOM_GEQ difficulty_power_spawn_p, PCG_spawnTileBasedEnemies_turret_bottom_no_drop 
		ld hl,(level_type_tile_enemies_bank1)
		ld bc,TURRET_WITH_DROP_START_OFFSET
		add hl,bc
		ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_R_TURRET_BOTTOM
PCG_spawnTileBasedEnemies_turret_bottom_no_drop:
		ld a,2	; enemy height
		ld bc,3	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned
PCG_spawnTileBasedEnemies_turret_top:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_G_TURRET_TOP
	push hl
	push bc
		dec hl	; we need to modify the tile to the left of the enemy too
		ex de,hl
		ld hl,(level_type_tile_enemies_bank0)
		ld bc,TURRET_START_OFFSET
		add hl,bc
		JP_IF_RANDOM_GEQ difficulty_power_spawn_p, PCG_spawnTileBasedEnemies_turret_top_no_drop 
		ld hl,(level_type_tile_enemies_bank0)
		ld bc,TURRET_WITH_DROP_START_OFFSET
		add hl,bc
		ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_R_TURRET_TOP
PCG_spawnTileBasedEnemies_turret_top_no_drop:
		ld a,2	; enemy height
		ld bc,3	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
PCG_spawnTileBasedEnemies_moai:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld a,(difficulty_enemy_health_tough)
	ld (ix+TILE_ENEMY_STRUCT_HP),a
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),5
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),4
	ld a,(PCG_respawn_enemies_row)
	cp 4
	jp m,PCG_spawnTileBasedEnemies_moai_top
PCG_spawnTileBasedEnemies_moai_bottom:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_MOAI_BOTTOM
	push hl
	push bc
		; adjust Y coordinate:
		ld a,(ix+TILE_ENEMY_STRUCT_Y)
		sub 3
		ld (ix+TILE_ENEMY_STRUCT_Y),a
		push hl
			ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
			ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
			ld bc,-MAP_BUFFER_WIDTH*3
			add hl,bc
			ld (ix+TILE_ENEMY_STRUCT_PTRL),l
			ld (ix+TILE_ENEMY_STRUCT_PTRH),h
		pop hl

 		ld bc,-(3*PCG_PATTERN_WIDTH+1)

		add hl,bc	; start position
		ex de,hl
		ld hl,tile_enemies_moai1+MOAI_START_OFFSET
		ld a,4	; enemy height
		ld bc,5	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned
PCG_spawnTileBasedEnemies_moai_top:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_MOAI_TOP
	push hl
	push bc
		dec hl	; we need to modify the tile to the left of the enemy too
		ex de,hl
		ld hl,tile_enemies_moai0+MOAI_START_OFFSET
		ld a,4	; enemy height
		ld bc,5	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
PCG_spawnTileBasedEnemies_growingwall:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld (ix+TILE_ENEMY_STRUCT_HP),1
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),4
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),1
	ld a,(PCG_respawn_enemies_row)
	cp 4
	jp m,PCG_spawnTileBasedEnemies_growingwall_top
PCG_spawnTileBasedEnemies_growingwall_bottom:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_GROWINGWALL_BOTTOM
	; timer should be:  50-(y-7)*2 -> 64-y*2
	ld a,(ix+TILE_ENEMY_STRUCT_Y)
	add a,a
	sub 64
	neg
	ld (ix+TILE_ENEMY_STRUCT_TIMER),a
	jp PCG_spawnTileBasedEnemies_enemy_spawned	

PCG_spawnTileBasedEnemies_growingwall_top:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_GROWINGWALL_TOP
	ld (ix+TILE_ENEMY_STRUCT_TIMER),36
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
PCG_spawnTileBasedEnemies_generator:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld a,(difficulty_enemy_health_tough)
	ld (ix+TILE_ENEMY_STRUCT_HP),a
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),4
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),2
	ld (ix+TILE_ENEMY_STRUCT_TIMER),4	; do not release any ship for a few frames
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	ld a,(PCG_respawn_enemies_row)
	cp 4
	jp m,PCG_spawnTileBasedEnemies_generator_top
PCG_spawnTileBasedEnemies_generator_bottom:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_GENERATOR_BOTTOM
	push hl
	push bc
		; adjust Y coordinate:
		dec (ix+TILE_ENEMY_STRUCT_Y)
		push hl
			ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
			ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
			ld bc,-MAP_BUFFER_WIDTH
			add hl,bc
			ld (ix+TILE_ENEMY_STRUCT_PTRL),l
			ld (ix+TILE_ENEMY_STRUCT_PTRH),h
		pop hl

		ld bc,-(PCG_PATTERN_WIDTH+1)
		add hl,bc	; start position
		ex de,hl
		ld hl,(level_type_tile_enemies_bank1)
		ld bc,GENERATOR_START_OFFSET
		add hl,bc
		ld a,2	; enemy height
		ld c,4	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned
PCG_spawnTileBasedEnemies_generator_top:
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_GENERATOR_TOP
	push hl
	push bc
		dec hl	; we need to modify the tile to the left of the enemy too
		ex de,hl
		ld hl,(level_type_tile_enemies_bank0)
		ld bc,GENERATOR_START_OFFSET
		add hl,bc
		ld a,2	; enemy height
		ld c,4	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
PCG_spawnTileBasedEnemies_water_dome:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld a,(difficulty_enemy_health_tough)
	ld (ix+TILE_ENEMY_STRUCT_HP),a
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),4
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),3
	ld (ix+TILE_ENEMY_STRUCT_TIMER),4	; do not come out for a few frames
	ld (ix+TILE_ENEMY_STRUCT_STATE),1
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_WATERDOME
	push hl
	push bc
		; adjust Y coordinate:
		dec (ix+TILE_ENEMY_STRUCT_Y)
		dec (ix+TILE_ENEMY_STRUCT_Y)
		ld l,(ix+TILE_ENEMY_STRUCT_PTRL)
		ld h,(ix+TILE_ENEMY_STRUCT_PTRH)
		ld bc,-MAP_BUFFER_WIDTH*2
		add hl,bc
		ld (ix+TILE_ENEMY_STRUCT_PTRL),l
		ld (ix+TILE_ENEMY_STRUCT_PTRH),h
	pop bc
	pop hl
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
PCG_spawnTileBasedEnemies_falling_rocks:
	call clearEnemyMarker
	; JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld (ix+TILE_ENEMY_STRUCT_HP),1
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),2
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),1
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_FALLINGROCKS
	ld (ix+TILE_ENEMY_STRUCT_TIMER),8
	jp PCG_spawnTileBasedEnemies_enemy_spawned	


;-----------------------------------------------
PCG_spawnTileBasedEnemies_temple_snake:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_temple_snake_no_spawn 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jr nz,PCG_spawnTileBasedEnemies_temple_snake_no_spawn

	ld a,(difficulty_enemy_health_tough)
	ld (ix+TILE_ENEMY_STRUCT_HP),a
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),3
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),2
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_TEMPLESNAKE
	ld (ix+TILE_ENEMY_STRUCT_TIMER),8

	; draw snake:
	push hl
	push bc
		; adjust X coordinate:
		dec (ix+TILE_ENEMY_STRUCT_X)
		dec (ix+TILE_ENEMY_STRUCT_X)
		dec (ix+TILE_ENEMY_STRUCT_PTRL)
		dec hl
		dec hl	; start position
		ld bc,SNAKE_START_OFFSET
PCG_spawnTileBasedEnemies_temple_snake_spawn_continue:	
		ex de,hl
		ld hl,(level_type_tile_enemies_bank0)
		add hl,bc
		ld a,2	; enemy height
		ld bc,6	; enemy width+1
		call PCG_copy_enemy_tiles
	pop bc
	pop hl

	jp PCG_spawnTileBasedEnemies_enemy_spawned
PCG_spawnTileBasedEnemies_temple_snake_no_spawn:
	; remove snake:
	push hl
	push bc
		dec hl
		dec hl	; start position
		ld bc,SNAKE_START_OFFSET+6*2*2
		jr PCG_spawnTileBasedEnemies_temple_snake_spawn_continue


;-----------------------------------------------
PCG_spawnTileBasedEnemies_temple_column:
	call clearEnemyMarker
	JP_IF_RANDOM_GEQ difficulty_spawn_p, PCG_spawnTileBasedEnemies_enemy_spawned 
	call find_tile_enemy_spot	; finds a spot in the tile_enemies list to place the enemy (returned in IX)
	jp nz,PCG_spawnTileBasedEnemies_enemy_spawned

	ld (ix+TILE_ENEMY_STRUCT_HP),1
	ld (ix+TILE_ENEMY_STRUCT_WIDTH),4
	ld (ix+TILE_ENEMY_STRUCT_HEIGHT),2
	ld (ix+TILE_ENEMY_STRUCT_TYPE),TILE_ENEMY_TEMPLECOLUMN
	ld (ix+TILE_ENEMY_STRUCT_TIMER),33
	jp PCG_spawnTileBasedEnemies_enemy_spawned


;-----------------------------------------------
; copies the tiles onto a PCG pattern
; input:
; - hl: the source tiles
; - de: ptr to the address in the pattern to start copying
; - a: enemy height
; - bc: enemy width
PCG_copy_enemy_tiles:
	push bc	
		push de
			ldir
		pop de
		ex de,hl
		ld bc,PCG_PATTERN_WIDTH
		add hl,bc
		ex de,hl
	pop bc
	dec a
	jr nz,PCG_copy_enemy_tiles
	ret


;-----------------------------------------------
; copies the pattern currently in "pcg_map_pattern_buffer" to the circular map buffer
; input:
; - de: direction to copy
PCG_copyPatternToBuffer:
	ld a,MAP_HEIGHT
	ld hl,pcg_map_pattern_buffer
PCG_copyPatternToBuffer_loop_y:	
	REPT PCG_PATTERN_WIDTH
		ldi
	ENDM
	ex de,hl
		ld bc,MAP_BUFFER_WIDTH - PCG_PATTERN_WIDTH
		add hl,bc
	ex de,hl
	dec a
	jr nz,PCG_copyPatternToBuffer_loop_y
	ret

;-----------------------------------------------
; Chooses one eemy wave from the set of possible enemy waves in the current PCG pattern
; and spawns it.
	IF PCG_WAVE_TYPES_PER_PATTERN != 4
		ERROR "PCG_WAVE_TYPES_PER_PATTERN != 4, this is assumed by PCG_choose_enemy_wave"
	ENDIF

PCG_choose_enemy_wave:
	ld a,(difficulty_level_length)
	or a
	jr z,PCG_choose_enemy_wave_level_wave_chosen	; stop spawning enemies

	ld a,(last_wave_type_spawned)
	ld e,a	; we store this for later
	call random
	ld b,0
PCG_choose_enemy_wave_norepeat_loop:
	; pick one different from the last one spawned:
	ld hl,pcg_map_pattern_buffer+PCG_PATTERN_WIDTH*MAP_HEIGHT
	and #03	; assumes that PCG_WAVE_TYPES_PER_PATTERN = 4
	ld c,a
	add hl,bc
	ld a,(hl)	; a has the wave type
	cp e
	jr nz,PCG_choose_enemy_wave_level_wave_chosen
	ld a,c
	inc a
	jr PCG_choose_enemy_wave_norepeat_loop

PCG_choose_enemy_wave_level_wave_chosen:
	; store the wave at the end of the queue, and get the front:
	ld (last_wave_type_spawned),a
	ld (enemy_spawn_next_waves+2),a
	ld a,(enemy_spawn_next_waves)

	; move the queue forward:
	ld hl,enemy_spawn_next_waves+1
	ld de,enemy_spawn_next_waves
	ldi
	ldi

	or a
	ret z	; no wave to spawn
	ld hl,enemy_wave_types
	ld bc,ENEMY_WAVE_STRUCT_SIZE
PCG_choose_enemy_wave_loop:
	dec a
	jp z,spawn_enemy_wave
	add hl,bc
	jr PCG_choose_enemy_wave_loop
