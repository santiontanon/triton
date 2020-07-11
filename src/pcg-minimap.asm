;-----------------------------------------------
generate_minimap:
	; clear minimap:
	ld hl,global_state_minimap
	ld de,global_state_minimap+1
	ld a,31
	ld (hl),a
	ld bc,MINIMAP_WIDTH*(MINIMAP_HEIGHT+1)-1
	ldir

	; generate the 3 random points (NW, middle, SE):
	call random
	and #06
	ld (pcg_minimap_nw_point),a
	ld l,a
	call random
	and #02
	ld (pcg_minimap_nw_point+1),a
	ld h,a
	call generate_minimap_put_planet

	call random
	and #06
	add a,8
	ld (pcg_minimap_middle_point),a
	ld l,a
	ld a,4
	ld (pcg_minimap_middle_point+1),a
	ld h,a
	call generate_minimap_put_planet

	call random
	and #06
	add a,16
	ld (pcg_minimap_se_point),a
	ld l,a
	call random
	and #02
	add a,6
	ld (pcg_minimap_se_point+1),a
	ld h,a
	call generate_minimap_put_planet

	; path from ITHAKI-NW
	ld hl,pcg_minimap_nw_point
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl,(MINIMAP_HEIGHT-1)*256 + 0
	push de
		call generate_minimap_path

	; path from NW-NEBULA
	pop hl
	ld de,(2)*256 + MINIMAP_WIDTH-6
	call generate_minimap_path

	; path from ITHAKI-middle
	ld hl,pcg_minimap_middle_point
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl,(MINIMAP_HEIGHT-1)*256 + 0
	push de
		call generate_minimap_path

	; path from middle-NEBULA
	pop hl
	ld de,(2)*256 + MINIMAP_WIDTH-6
	call generate_minimap_path

	; path from ITHAKI-SE
	ld hl,pcg_minimap_se_point
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl,(MINIMAP_HEIGHT-1)*256 + 0
	push de
		call generate_minimap_path

	; path from SE-NEBULA
	pop hl
	ld de,(2)*256 + MINIMAP_WIDTH-6
	call generate_minimap_path

	; path from NW-middle
	ld hl,pcg_minimap_nw_point
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
		ld hl,pcg_minimap_middle_point
		ld e,(hl)
		inc hl
		ld d,(hl)
	pop hl
	push de
		call generate_minimap_path

	; path from middle-SE
		ld hl,pcg_minimap_se_point
		ld e,(hl)
		inc hl
		ld d,(hl)
	pop hl
	call generate_minimap_path

	; add the fixed content:
	ld hl,global_state_minimap+(MINIMAP_HEIGHT-1)*MINIMAP_WIDTH
	ld (hl),81	; ITHAKI
	ld hl,global_state_minimap+(MINIMAP_HEIGHT-2)*MINIMAP_WIDTH+1
	ld (hl),100	; CONNECTION_SW_NE (green)
	ld hl,global_state_minimap+MINIMAP_WIDTH-2
	ld (hl),81	; TRITON
	dec hl
	ld (hl),93	; CONNECTION_H
	dec hl
	ld (hl),88	; TEMPLE PLANET
	ld hl,global_state_minimap+(MINIMAP_WIDTH-5)+MINIMAP_WIDTH
	ld (hl),95	; CONNECTION_SW_NE
	ld hl,global_state_minimap+(MINIMAP_WIDTH-5)+2*MINIMAP_WIDTH
	ld (hl),84	; SYSTEM_NEBULA_RIGHT
	dec hl
	ld (hl),83	; SYSTEM_NEBULA
	dec hl
	ld (hl),82	; SYSTEM_NEBULA_LEFT

	; Positions of the bosses:
	ld hl,global_state_minimap+12
	call generate_minimap_boss_position
	ld (global_state_boss2_position),a
	ld hl,global_state_minimap+18
	call generate_minimap_boss_position
	ld (global_state_boss3_position),a
	ret


generate_minimap_boss_position:
	ld e,0
	ld bc,MINIMAP_HEIGHT*256 + 0
generate_minimap_boss_position_loop:
	ld a,(hl)
	; check if it's a planet
	cp 85
	jr c,generate_minimap_boss_position_skip
	cp 89
	jr nc,generate_minimap_boss_position_skip
	ld a,e
	or a
	jr z,generate_minimap_boss_position_found
	call random
	and #01
	jr z,generate_minimap_boss_position_skip
generate_minimap_boss_position_found:
	ld e,c
generate_minimap_boss_position_skip:
	push bc
		ld bc,MINIMAP_WIDTH
		add hl,bc
	pop bc
	inc c
	djnz generate_minimap_boss_position_loop
	ld a,e
	ret


;-----------------------------------------------
; input:
; - l: x
; - h: y
generate_minimap_put_planet:
	call random
	and #03
	add a,85
	;jp generate_minimap_write_to_minimap


;-----------------------------------------------
; input:
; - l: x
; - h: y
generate_minimap_write_to_minimap:
	; calculate pointer:
	push hl
	push de
	push bc
		ex de,hl
		ld hl,global_state_minimap
		push af
			ld a,d
			ld bc,MINIMAP_WIDTH
			or a
			jr z,generate_minimap_put_planet_y_loop_done
generate_minimap_put_planet_y_loop:
			add hl,bc
			dec d
			jr nz,generate_minimap_put_planet_y_loop
generate_minimap_put_planet_y_loop_done:
			add hl,de	; d here is 0
			ld a,(hl)
			cp 94
			jr z,generate_minimap_write_to_minimap_sw_connector
			cp 95
			jr z,generate_minimap_write_to_minimap_ne_connector
			cp 97
			jr z,generate_minimap_write_to_minimap_cross_connector
		pop af
generate_minimap_write_to_minimap_continue:
		ld (hl),a
	pop bc
	pop de
	pop hl
	ret

; write the X shaped connector:
generate_minimap_write_to_minimap_sw_connector:
	pop af
	cp 95
	jr nz,generate_minimap_write_to_minimap_continue
	ld a,97
	jr generate_minimap_write_to_minimap_continue

generate_minimap_write_to_minimap_ne_connector:
	pop af
	cp 94
	jr nz,generate_minimap_write_to_minimap_continue
	ld a,97
	jr generate_minimap_write_to_minimap_continue

generate_minimap_write_to_minimap_cross_connector:
	pop af
	ld a,97
	jr generate_minimap_write_to_minimap_continue


;-----------------------------------------------
; input:
; - hl: starting point (l is x, h is y)
; - de: destination point (e is x, d is y)
generate_minimap_path:
	; check if we made it to the destination:
	ld a,l
	sub e
	jr nz,generate_minimap_path_not_at_destination
	ld a,h
	sub d
	ret z	; we are done!

generate_minimap_path_not_at_destination:
	; randomly generate the horizontal step:
	ld a,e
	sub l
	call generate_minimap_path_random_step
	ld c,a	; dx

	; randomly generate the vertical step:
	ld a,d
	sub h
	call generate_minimap_path_random_step
	ld b,a	; dy

	; make sure we don't violate any constraints:
	ld a,l
	add a,c
	add a,c
	cp MINIMAP_WIDTH
	jr nc,generate_minimap_path_not_at_destination	; continue
	ld a,h
	add a,b
	add a,b
	cp MINIMAP_HEIGHT
	jr nc,generate_minimap_path_not_at_destination	; continue

	push hl
		call generate_minimap_path_advance
		call generate_minimap_path_advance
		; protect the area around ITHAKI:
		; if (x+dx == 0 && y+dy == 6) continue;
		ld a,l
		or a
		jr nz,generate_minimap_path_no_protected_1
		ld a,h
		cp 6
		jr z,generate_minimap_path_loopback_pop
generate_minimap_path_no_protected_1:
		; if (x+dx == 2 && y+dy == 8) continue;
		ld a,l
		cp 2
		jr nz,generate_minimap_path_no_protected_2
		ld a,h
		cp 8
		jr z,generate_minimap_path_loopback_pop
generate_minimap_path_no_protected_2:

		; protect the nebula:
		; if (x+dx == 18 && y+dy == 2) continue;
		ld a,l
		cp 18
		jr nz,generate_minimap_path_no_protected_3
		ld a,h
		cp 2
		jr z,generate_minimap_path_loopback_pop
generate_minimap_path_no_protected_3:
 		; if (x+dx > 20 && y+dy<3) continue;
 		ld a,l
 		cp 21
		jr c,generate_minimap_path_no_protected_4
		ld a,h
		cp 3
		jr c,generate_minimap_path_loopback_pop
generate_minimap_path_no_protected_4:
	pop hl


	; place connector:
	call generate_minimap_path_advance
	ld a,c
	or a
	jr z,generate_minimap_path_vertical_connector
	ld a,b
	or a
	jr z,generate_minimap_path_horizontal_connector
	ld a,c
	add a,b
	jr z,generate_minimap_path_ne_connector
generate_minimap_path_sw_connector:
	ld a,94
	jr generate_minimap_path_connector_set
generate_minimap_path_ne_connector:
	ld a,95
	jr generate_minimap_path_connector_set
generate_minimap_path_vertical_connector:
	ld a,96
	jr generate_minimap_path_connector_set
generate_minimap_path_horizontal_connector:
	ld a,93
generate_minimap_path_connector_set:
	call generate_minimap_write_to_minimap

	; place a planet (if destination is empty):
	call generate_minimap_path_advance
	call generate_minimap_put_planet
	jr generate_minimap_path

	; loop back (popping):
generate_minimap_path_loopback_pop:
	pop hl
	jr generate_minimap_path_not_at_destination


generate_minimap_path_advance:
	ld a,h
	add a,b
	ld h,a
	ld a,l
	add a,c
	ld l,a
	ret


generate_minimap_path_random_step:
	jr z,generate_minimap_path_0_diff
	jr c,generate_minimap_path_negative_diff
generate_minimap_path_positive_diff:
	; random < 6: -1
	; random < 12: 0
	; else:		   1
	call random
	cp 6
	jr c,generate_minimap_path_random_step_minus1
	cp 12
	jr c,generate_minimap_path_random_step_0
generate_minimap_path_random_step_1:
	ld a,1
	ret

generate_minimap_path_0_diff:
	; random < 80: -1
	; random < 176: 0
	; else:		   1
	call random
	cp 64
	jr c,generate_minimap_path_random_step_minus1
	cp 192
	jr c,generate_minimap_path_random_step_0
	jr generate_minimap_path_random_step_1

generate_minimap_path_negative_diff:
	; random < 6:  1
	; random < 12: 0
	; else:		  -1
	call random
	cp 6
	jr c,generate_minimap_path_random_step_1
	cp 12
	jr c,generate_minimap_path_random_step_0
generate_minimap_path_random_step_minus1:
	ld a,-1
	ret

generate_minimap_path_random_step_0:
	xor a
	ret


