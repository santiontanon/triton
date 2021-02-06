;-----------------------------------------------
; updates the # of lives in the scoreboard
update_scoreboard_lives:
	; clear a small buffer to copy to the VDP:
	ld hl,scoreboard_rendering_buffer
	push hl
		ld bc,7
		call clear_memory
	pop hl
	ld a,(player_lives)
	or a
	jr z,update_scoreboard_lives_last
	ld (hl),SCOREBOARD_LIFE_TILE
	dec a
	jr z,update_scoreboard_lives_last
	ld e,l
	ld d,h
	inc de
	ld b,0
	ld c,a
	push hl
		ldir
	pop hl
update_scoreboard_lives_last:
	ld de,NAMTBL2+23*32
	ld bc,8
	jp fast_LDIRVM


;-----------------------------------------------
; updates the weapon selection bar in the scoreboard
update_scoreboard_weapon_selection:
	ld iyl,#ff	; weapon that will be selected if pressing M
	ld de,scoreboard_rendering_buffer
	ld ix,ingame_weapon_current_level
	ld hl,ingame_weapon_max_level
	ld a,(ingame_weapon_current_selection)
	ld c,a
	ld b,0
update_scoreboard_weapon_selection_loop:
	ld a,(hl)
	cp (ix)
	jr z,update_scoreboard_weapon_selection_max
	ld a,c
	cp b
	jr z,update_scoreboard_weapon_selection_selected
	ld a,36
	ld (de),a
	inc de
	ld a,37
	ld (de),a
	inc de
	jr update_scoreboard_weapon_selection_loop_next

update_scoreboard_weapon_selection_selected:
	ld a,21
	ld (de),a
	inc de
	ld a,22
	ld (de),a
	inc de
	ld iyl,b
	jr update_scoreboard_weapon_selection_loop_next

update_scoreboard_weapon_selection_max:
	ld a,c
	cp b
	jr z,update_scoreboard_weapon_selection_max_selected
	ld a,23
	ld (de),a
	inc de
	ld a,24
	ld (de),a
	inc de
	jr update_scoreboard_weapon_selection_loop_next

update_scoreboard_weapon_selection_max_selected:
	ld a,40
	ld (de),a
	inc de
	ld a,41
	ld (de),a
	inc de
	jr update_scoreboard_weapon_selection_loop_next

update_scoreboard_weapon_selection_loop_next:
	inc hl
	inc ix
	inc b
	ld a,b
	cp 8
	jr nz,update_scoreboard_weapon_selection_loop

	ld hl,scoreboard_rendering_buffer
	ld de,NAMTBL2+22*32
	ld bc,16
	call fast_LDIRVM

	; update name:
	ld a,iyl
	cp #ff
	jr z,update_scoreboard_weapon_selection_clear_name
	ld hl,global_state_weapon_configuration
	ADD_HL_A
	ld a,(hl)
	ld hl,weapon_gfx_and_names
	ld b,0
	add a,a
	ld c,a
	add a,a
	add a,c		; a*6
	add a,4		; skip the gfx
	ld c,a		
	add hl,bc	; hl now points to the weapon name
 	ld c,(hl)
 	inc hl
 	ld a,(hl)
 	ld de,CHRTBL2+(256*2+27)*8-1	; -1 so that we draw everything 1 pixel higher (to center it vertically)
 	ld iyl,COLOR_DARK_GREEN
 	ld b,6*8
 	jp draw_text_from_bank

update_scoreboard_weapon_selection_clear_name:
	ld a,COLOR_DARK_GREEN+COLOR_DARK_GREEN*16
	ld bc,6*8
	ld hl,CLRTBL2+(256*2+27)*8
	jp fast_FILVRM


;-----------------------------------------------
update_scoreboard_credits:
	ld hl,scoreboard_rendering_buffer
	ld bc,15
	call clear_memory
	ld hl,scoreboard_rendering_buffer+15

	ld a,(player_credits)
	ld c,a
	srl a
	srl a
	; number of "large credits":
update_scoreboard_credits_large_loop:
	jr z,update_scoreboard_credits_done_with_large
	ld (hl),39
	dec hl
	dec a
	jr update_scoreboard_credits_large_loop
update_scoreboard_credits_done_with_large:
	ld a,c
	and #03
	; number of "small credits":
update_scoreboard_credits_small_loop:
	jr z,update_scoreboard_credits_done_with_small
	ld (hl),38
	dec hl
	dec a
	jr update_scoreboard_credits_small_loop
update_scoreboard_credits_done_with_small:
	ld hl,scoreboard_rendering_buffer
	ld de,NAMTBL2+23*32+16
	ld bc,16
	jp fast_LDIRVM


;-----------------------------------------------
; player_primary_weapon_special_triggered
; if (player_primary_weapon_special_triggered) == 1 or max energy:
; 	- draw the current level in increments of two bars with tile 42 (green color)
; else:
;   - draw current level using blue color (tiles 34, 35) in increments of 1 bar


update_scoreboard_energy:
	ld a,(player_primary_weapon_energy)
	cp WEAPON_MAX_ENERGY
	jr z,update_scoreboard_energy_green
	ld a,(player_primary_weapon_special_triggered)
	or a
	jr nz,update_scoreboard_energy_green

update_scoreboard_energy_blue:
	ld hl,scoreboard_rendering_buffer
	ld a,(player_primary_weapon_energy)
; 	ld c,34
    rrca
    rrca
    rrca
    and 31
; 	ld b,12
	ld bc,34 + 12*256
update_scoreboard_energy_loop_blue:
	cp 1
	jr nz,update_scoreboard_energy_blue_not_1bar
	ld (hl),35
	inc hl
	dec a
	djnz update_scoreboard_energy_loop_blue
	jr update_scoreboard_energy_draw
update_scoreboard_energy_blue_not_1bar:
	or a
	jr nz,update_scoreboard_energy_blue_continue
	ld c,0
update_scoreboard_energy_blue_continue:
	ld (hl),c
	inc hl
	add a,-2
	djnz update_scoreboard_energy_loop_blue
	jr update_scoreboard_energy_draw

update_scoreboard_energy_green:
	; if (player_primary_weapon_special_triggered) == 1 or max energy:
	ld hl,scoreboard_rendering_buffer
	ld a,(player_primary_weapon_energy)
; 	ld c,42
    rrca
    rrca
    rrca
    and 31
	srl a
; 	ld b,12
	ld bc,42 + 12*256
update_scoreboard_energy_loop:
	or a	
	jr nz,update_scoreboard_energy_continue
	ld c,0
update_scoreboard_energy_continue:
	ld (hl),c
	inc hl
	dec a
	djnz update_scoreboard_energy_loop

update_scoreboard_energy_draw:
	ld hl,scoreboard_rendering_buffer
	ld de,NAMTBL2+22*32+20
	ld bc,12
	jp fast_LDIRVM



