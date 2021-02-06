;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
spawn_power_pellet:
	ld a,(scroll_restart)
	or a					
	ret nz  ; do not spawn power pellets on scroll restart cycles to avoid an edge case
	ld hl,power_pellets
	ld de,POWER_PELLET_STRUCT_SIZE
	ld a,MAX_POWER_PELLETS
spawn_power_pellet_loop:
	push af
		ld a,(hl)
		or a
		jr nz,spawn_power_pellet_next
	pop af
	; spot found:
	push hl	; save this pointer, in case the spawn is not allowed
		ld (hl),1
		inc hl
		ld (hl),c
		inc hl
		ld (hl),b
		inc hl
		ld (hl),0	; POWER_PELLET_STRUCT_BG_FLAG
		inc hl
		; calculate the pointer of where the pellet has to be drawn:
		push hl
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
			ex de,hl
		pop hl
		ld (hl),e
		inc hl
		ld (hl),d

; 		ld a,b
; 		cp 8
; 		jr nc,spawn_power_pellet_bank2
spawn_power_pellet_bank1:
		ld b,FIRST_WALL_COLLIDABLE_TILE
; 		jr spawn_power_pellet_bank_selected
; spawn_power_pellet_bank2:
; 		ld b,FIRST_WALL_COLLIDABLE_TILE_BANK_2
spawn_power_pellet_bank_selected:
	pop hl

	; check that there is no obstacle underneath (power pellets cannot spawn over walls):
	ld a,(de)
	cp b
	jr nc,spawn_power_pellet_not_allowed
	inc de
	ld a,(de)
	cp b
	jr nc,spawn_power_pellet_not_allowed
	inc de
	ld a,(de)
	cp b
	jr nc,spawn_power_pellet_not_allowed
	inc de
	ld a,(de)
	cp b
	jr nc,spawn_power_pellet_not_allowed

	ld hl,redraw_power_pellets_signal
	ld (hl),1
	ret
spawn_power_pellet_next:
		add hl,de
	pop af
	dec a
	jr nz,spawn_power_pellet_loop
	ret

spawn_power_pellet_not_allowed:
	ld (hl),0
	ret


;-----------------------------------------------
; preserves IX, IY
power_pellets_restore_bg:
	ld hl,power_pellets+((MAX_POWER_PELLETS-1)*POWER_PELLET_STRUCT_SIZE)
	ld de,-POWER_PELLET_STRUCT_SIZE
	ld b,MAX_POWER_PELLETS
power_pellets_restore_bg_loop:
	ld a,(hl)
	or a
	jr z,power_pellets_restore_bg_next
	; restore bg:
	push hl
	push de
	push bc
		rla
		jr nc,power_pellets_restore_bg_loop_no_deletion
		; it was marked for deletion, delete it
		ld (hl),0
power_pellets_restore_bg_loop_no_deletion:
		inc hl	; skip type
		ld a,(scroll_x_tile)
		add a,-2
		cp (hl)	; x
		jp p,power_pellets_restore_bg_loop_skip
		inc hl
		inc hl
		ld a,(hl)	; check if any BG has been saved yet
		or a
		jr z,power_pellets_restore_bg_loop_continue
		inc hl
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
		ldi
		ldi
		ldi
power_pellets_restore_bg_loop_continue:		
	pop bc
	pop de
	pop hl
power_pellets_restore_bg_next:
	add hl,de
	djnz power_pellets_restore_bg_loop
	ret

power_pellets_restore_bg_loop_skip:	
	dec hl
	ld (hl),0	; remove the power pellet
	jr power_pellets_restore_bg_loop_continue


;-----------------------------------------------
; preserves IX, IY
power_pellets_draw:
	ld hl,power_pellets
	ld de,POWER_PELLET_STRUCT_SIZE
	ld b,MAX_POWER_PELLETS
power_pellets_draw_loop:
	ld a,(hl)
	or a
	jr z,power_pellets_draw_next
	push hl
	push de
	push bc
		; save bg:
		inc hl		; skip type
		ld a,(scroll_x_tile)
		dec a
		cp (hl)	; x
		jp p,power_pellets_draw_loop_skip
		inc hl
		ld a,(hl)	; y
		inc hl
		ld (hl),1	; POWER_PELLET_STRUCT_BG_FLAG
		inc hl
		ld e,(hl)	; ptrl
		inc hl
		ld d,(hl)	; ptrh
		inc hl
		ex de,hl	; hl has the pointer to the map where to draw, de points to the BG buffer
		push hl
			ldi
			ldi
			ldi
		pop de

		; draw:
		cp 8		; a has the value of "y"
		jp p,power_pellets_draw_bank1
		ld hl,power_pellet_types_bank0
		jr power_pellets_draw_bank_set
power_pellets_draw_bank1:
		ld hl,power_pellet_types_bank1
power_pellets_draw_bank_set:
		ldi
		ldi
		ldi
power_pellets_draw_loop_continue:
	pop bc
	pop de
	pop hl
power_pellets_draw_next:
	add hl,de
	djnz power_pellets_draw_loop
	ret

power_pellets_draw_loop_skip:	
	dec hl
	ld (hl),0	; remove the power pellet
	jr power_pellets_draw_loop_continue


;-----------------------------------------------
; Since the scroll works on a circular buffer, when the scroll circles back, 
; we need to adjust the coordinates of the power pellets, to bring them back to where the viewport is
adjust_power_pellet_positions_after_scroll_restart:
	ld ix,power_pellets
	ld b,MAX_POWER_PELLETS
	ld de,POWER_PELLET_STRUCT_SIZE
adjust_power_pellet_positions_loop:
	ld a,(ix)
	or a
	jr z,adjust_power_pellet_positions_loop_next
	ld a,(ix+POWER_PELLET_STRUCT_X)
	sub 64
	jp p,adjust_power_pellet_positions_adjust
	; power pellet got out of the scroll
	ld (ix),0
adjust_power_pellet_positions_loop_next:
	add ix,de
	djnz adjust_power_pellet_positions_loop
	ret

adjust_power_pellet_positions_adjust:
 	ld (ix+POWER_PELLET_STRUCT_X),a
 	push bc
 	push de
 		ld l,(ix+POWER_PELLET_STRUCT_PTRL)
 		ld h,(ix+POWER_PELLET_STRUCT_PTRH)
 		ld bc,-64
 		add hl,bc
 		ld (ix+POWER_PELLET_STRUCT_PTRL),l
 		ld (ix+POWER_PELLET_STRUCT_PTRH),h
 		ex de,hl

 		; draw the power pellet in the new position (no need to store the bg, as it should be the same as before):
 		ld a,(ix+POWER_PELLET_STRUCT_Y)
 		cp 8
 		jp p,adjust_power_pellet_positions_bank1
 		ld hl,power_pellet_types_bank0
 		jr adjust_power_pellet_positions_bank_set
adjust_power_pellet_positions_bank1:
 		ld hl,power_pellet_types_bank1
adjust_power_pellet_positions_bank_set:
 		ldi
 		ldi
 		ldi
 	pop de
 	pop bc
	jr adjust_power_pellet_positions_loop_next



;-----------------------------------------------
power_pellet_pickup:
	ld ix,power_pellets
	ld b,MAX_POWER_PELLETS
	ld a,(player_tile_y)
	ld c,a
	ld de,POWER_PELLET_STRUCT_SIZE
power_pellet_pickup_loop:
	ld a,(ix)
	or a
	jr z,power_pellet_pickup_loop_next
	ld a,c
	cp (ix+POWER_PELLET_STRUCT_Y)
	jr nz,power_pellet_pickup_loop_next
	ld a,(player_tile_x)
	cp (ix+POWER_PELLET_STRUCT_X)
	jp m,power_pellet_pickup_loop_next
	sub 3
	cp (ix+POWER_PELLET_STRUCT_X)
	jp p,power_pellet_pickup_loop_next

	; found! mark pellet for deletion
	set 7,(ix)

	ld hl,redraw_power_pellets_signal
	ld (hl),1

	ld hl,SFX_power_capsule
	call play_SFX_with_high_priority

	ld hl,ingame_weapon_current_selection
	ld a,(hl)
	cp 7
	jp z,select_weapon_sfx
	inc a
	and #07
	ld (hl),a
	jp update_scoreboard_weapon_selection
power_pellet_pickup_loop_next:
	add ix,de
	djnz power_pellet_pickup_loop

	ld hl,redraw_power_pellets_signal
	ld (hl),1
	ret
