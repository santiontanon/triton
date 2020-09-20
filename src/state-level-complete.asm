;-----------------------------------------------
; return:
; - z: clear
; - nz: there is still a power pellet or enemy
any_enemy_or_power_pellet:
	ld hl,enemies
	ld de,ENEMY_STRUCT_SIZE
	ld b,MAX_ENEMIES
any_enemy_or_power_pellet_enemies_loop:
	ld a,(hl)
	or a
	jp nz,any_enemy_or_power_pellet_one_found
	add hl,de
	djnz any_enemy_or_power_pellet_enemies_loop

	ld hl,power_pellets
	ld de,POWER_PELLET_STRUCT_SIZE
	ld b,MAX_POWER_PELLETS
any_enemy_or_power_pellet_pellet_loop:
	ld a,(hl)
	or a
	jp nz,any_enemy_or_power_pellet_one_found
	add hl,de
	djnz any_enemy_or_power_pellet_pellet_loop

	xor a
	ret
any_enemy_or_power_pellet_one_found:
	or 1
	ret


;-----------------------------------------------
state_level_complete_check:
	; if there is still any enemy or power pellet, keep going!
	call any_enemy_or_power_pellet
	jp nz,PCG_choosePattern_empty
	ld a,(global_state_selected_level_boss)
	or a
	jp nz,state_boss
	; jr state_level_complete


;-----------------------------------------------
state_level_complete:

	call StopMusic

	; clear screen left to right, except scoreboard and ship:
	ld hl,player_sprite_attributes+2
	ld (hl),12
	inc hl
	ld (hl),COLOR_GREY
	ld hl,player_sprite_attributes+4+2
	ld (hl),8
	inc hl
	ld (hl),COLOR_DARK_BLUE

	ld hl,player_sprite_attributes
	ld de,SPRATR2+4*4
	ld bc,2*4
	call fast_LDIRVM

	ld hl,SPRATR2+6*4
	ld bc,26*4
	xor a
	call fast_FILVRM

	ld iyl,22
	call clearScreenLeftToRight_iyl_rows_no_sprites

	; print level complete message and credits:
 	ld c,TEXT_SYSTEM_CLEAR_BANK
 	ld a,TEXT_SYSTEM_CLEAR_IDX
 	ld de,CHRTBL2+FIRST_TILE_FOR_IN_GAME_TEXT*8
 	ld iyl,COLOR_WHITE*16
 	ld b,8*8
 	call draw_text_from_bank
 	ld hl,NAMTBL2+6*32+12
 	ld b,8
 	ld a,FIRST_TILE_FOR_IN_GAME_TEXT
 	call draw_text_name_table_ingame


	ld b,144
state_level_complete_move_ship_loop:
	halt

	push bc
		ld hl,player_sprite_attributes
		ld de,player_sprite_attributes+4
		ld a,(hl)
		sub 96
		jr z,state_level_complete_move_ship_loop_y_ok
		jr c,state_level_complete_move_ship_loop_y_inc
		dec (hl)
		ex de,hl
		dec (hl)
		ex de,hl
		jr state_level_complete_move_ship_loop_y_ok
state_level_complete_move_ship_loop_y_inc:
		inc (hl)
		ex de,hl
		inc (hl)
		ex de,hl
state_level_complete_move_ship_loop_y_ok:

		inc hl
		inc de
		ld a,(hl)
		sub 120
		jr z,state_level_complete_move_ship_loop_x_ok
		jr c,state_level_complete_move_ship_loop_x_inc
		dec (hl)
		ex de,hl
		dec (hl)
		ex de,hl
		jr state_level_complete_move_ship_loop_x_ok
state_level_complete_move_ship_loop_x_inc:
		inc (hl)
		ex de,hl
		inc (hl)
		ex de,hl
state_level_complete_move_ship_loop_x_ok:

		ld hl,player_sprite_attributes
		ld de,SPRATR2+4*4
		ld bc,2*4
		call fast_LDIRVM
	pop bc

	djnz state_level_complete_move_ship_loop

	; bring credits one by one:
state_level_complete_move_credit_loop:
	halt

	; credits:
	ld c,TEXT_MONEY_BANK
	ld a,TEXT_MONEY_IDX
	ld de,CHRTBL2+(FIRST_TILE_FOR_IN_GAME_TEXT+8)*8
	ld iyl,COLOR_WHITE*16
 	ld b,5*8
 	call draw_text_from_bank
	ld a,(global_state_credits)
	ld de,CHRTBL2+(FIRST_TILE_FOR_IN_GAME_TEXT+13)*8
	ld iyl,#a0	; yellow
	call draw_text_number_of_credits 	
 	ld hl,NAMTBL2+7*32+12
 	ld b,8
 	ld a,FIRST_TILE_FOR_IN_GAME_TEXT+8
 	call draw_text_name_table_ingame 	

 	call update_scoreboard_credits

	ld b,6
	call wait_b_halts

 	; transfer 1 credit:
	ld hl,player_credits
	ld a,(hl)
	or a
	jr z,state_level_complete_move_credit_loop_done
	dec (hl)
	ld hl,global_state_credits
	ld a,(hl)	; prevent overflow of credits!
	inc a
	jr z,state_level_complete_move_credit_loop_done
	ld (hl),a
	ld hl,SFX_ui_move
	call play_SFX_with_high_priority

	jr state_level_complete_move_credit_loop
state_level_complete_move_credit_loop_done:

	ld b,100
	call wait_b_halts

;  	; debug:
;  	ld a,4
;  	ld (global_state_levels_completed),a
;  	ld a,1
;  	ld (global_state_bosses_defeated),a	
;  	ld (global_state_selected_level_boss),a	

	call clearScreenLeftToRight

	jp COMPRESSED_state_mission_screen_from_game_complete


;-----------------------------------------------
; - a: number of credits
; - de: ptr to where to draw
; - iyl: color (attribute byte)
digit_indexes: db 19,22,24,27,30,32,34,36,38,41

draw_text_number_of_credits:
	push de
		push af
			call clear_text_rendering_buffer
		pop af

		ld hl,text_buffer
		ld (hl),4	; longest string is "$255"
		inc hl
		ld (hl),3	; 3 is "$"

		ld h,0
	    ld l,a
	    ld d,10
	    call Div8
	    push hl
	    	ld hl,digit_indexes
	    	ld b,0
	    	ld c,a
	    	add hl,bc
	    	ld a,(hl)
	    pop hl
	    ld (text_buffer+4),a

	    call Div8
	    push hl
	    	ld hl,digit_indexes
	    	ld b,0
	    	ld c,a
	    	add hl,bc
	    	ld a,(hl)
	    pop hl
	    ld (text_buffer+3),a

	    call Div8
    	ld hl,digit_indexes
    	ld b,0
    	ld c,a
    	add hl,bc
    	ld a,(hl)
	    ld (text_buffer+2),a
	pop de
	; - hl: sentence to draw (first byte is the length)
	; - de: target VRAM address
	; - iyl: color (attribute byte)
	; - bc: expected length in bytes
	ld hl,text_buffer
	ld bc,3*8
	jp draw_sentence
