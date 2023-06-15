	include "password-constants.asm"

; This file contains code that should be in "state-password.asm", but it does not fit there.
; It does not fit, because "state-password.asm" is compressed together with all the other code
; related to the title screen/menus, and it needs to fit in a RAM buffer when decompressed, 
; hence it is limited in size.


;-----------------------------------------------
init_game_from_password:
	xor a
	ld (global_state_levels_completed),a
	ld (global_state_bosses_defeated),a

	ld hl,weapon_configuration_default_ROM
	ld de,global_state_weapon_configuration
	ld bc,8
	ldir

; 	ld hl,global_state_weapon_upgrade_level+1
; 	ld bc,N_WEAPONS-2
; 	call clear_memory

; 	jp password_load

;-----------------------------------------------
password_load:
	; load password:
	ld hl,password_buffer
	ld de,global_state_credits
	ldi

	ld bc,(password_buffer+1)
	ld (global_rand_seed),bc

	ld hl,deterministic	; prevent the random seed changing randomly during the generation process
	ld (hl),1
	ld bc,(password_buffer+1)	; set the random seed from the map
	ld (randData),bc
	push hl
		call NON_GAME_COMPRESSED_CODE_START+4*3	 ; generate_minimap
	pop hl
	dec (hl)

	; mark visited planets:
	ld hl,password_buffer+3
	ld d,(hl)
	ld e,8
	xor a
	ld (ui_cursor_area),a
	ld (ui_cursor_position),a

password_load_loop:
	xor a
	call password_get_next_bit
	exx
		or a
		jr z,password_load_loop_no_change
		; check if it was a boss, and increase boss count:
		call NON_GAME_COMPRESSED_CODE_START+7*3	 ;state_mission_boss_under_cursor
		or a
		jr z,password_load_loop_no_boss
password_load_loop_is_boss:
		ld hl,global_state_bosses_defeated
		inc (hl)
password_load_loop_no_boss:
		; increase maps completed:
		ld hl,global_state_levels_completed
		inc (hl)
		; mark map as beaten:
		call NON_GAME_COMPRESSED_CODE_START+3*6  ; get_minimap_pointer
		call password_load_mark_planet_as_complete
password_load_loop_no_change:
		ld hl,ui_cursor_position
		inc (hl)
		ld a,(hl)
		cp 11
		jr nz,password_load_loop_no_rowend
		xor a
		ld (hl),a
		dec hl  ; ui_cursor_area
		inc (hl)
		ld a,(hl)
		cp 5
		jr z,password_load_loop_end
password_load_loop_no_rowend:
	exx
	jr password_load_loop
password_load_loop_end:
	exx
	; last planet after nebula:
	xor a
	call password_get_next_bit
	or a
	jr z,password_load_upgrades
	; mark map as beaten:
	exx
		ld hl,ui_cursor_area
		ld (hl),0
		inc hl
		ld (hl),11	; ui_cursor_position
		call NON_GAME_COMPRESSED_CODE_START+3*6  ; get_minimap_pointer
		call password_load_mark_planet_as_complete
	exx

password_load_upgrades:
	; load upgrades:
 	ld ix,global_state_weapon_upgrade_level+1
 	ld b,N_WEAPONS-1
password_load_upgrade_loop:
	ld a,b
	cp 19  ; transfer
	jr z, password_load_upgrade_loop_transfer
	cp 2  ; init weapon
	jr z, password_load_upgrade_loop_1bit
	dec a  ; pilots
	jr z, password_load_upgrade_loop_pilots

password_load_upgrade_loop_2bits:
	xor a
	call password_get_next_bit
	call password_get_next_bit
	call password_load_flip_upgrade_bits
	jr password_load_upgrade_loop_continue

password_load_upgrade_loop_1bit:
	xor a
	call password_get_next_bit

password_load_upgrade_loop_continue:
	ld (ix),a
	inc ix
	or a
	call nz,password_load_equip_weapon
	djnz password_load_upgrade_loop
	ret

password_load_upgrade_loop_transfer:
	xor a
	call password_get_next_bit
 	inc a
 	jr password_load_upgrade_loop_continue

password_load_upgrade_loop_pilots:
	xor a
	call password_get_next_bit
	call password_get_next_bit
	call password_load_flip_upgrade_bits
	add a,2
	jr password_load_upgrade_loop_continue

	; 00 -> 00, 11 -> 11, 01 -> 10, 10 -> 01
password_load_flip_upgrade_bits:
	cp 1
	jr z,password_load_flip_upgrade_bits_1
	cp 2
	ret nz
	dec a
	ret
password_load_flip_upgrade_bits_1:
	inc a
	ret

password_load_mark_planet_as_complete:
	ld a,(hl)
	; check that it's actually a planet (85, 86, 87, 88):
	cp 85
	ret c
	cp 89
	ret nc
	add a,4
	ld (hl),a		
	jp NON_GAME_COMPRESSED_CODE_START+3*5	; enable_nearby_minimap_paths


; b: (N_WEAPONS-1) - (weapon idx)
; modifies: iyl, af
password_load_equip_weapon:
	push hl
	push bc
		ld a,b
		cpl
		add a,N_WEAPONS+1  ; a = N_WEAPONS - b
		ld iyl,a
		ld hl,weapon_slot_number-1
		ld b,0
		ld c,a
		add hl,bc
		ld a,(hl)
		cp #ff
		jr z,password_load_equip_weapon_not_equipable
		ld hl,global_state_weapon_configuration
		ld c,a  ; b is already 0
		add hl,bc
		ld a,iyl
		ld (hl),a
password_load_equip_weapon_not_equipable
	pop bc
	pop hl
	ret


;-----------------------------------------------
password_get_checksum:
	xor a
	ld hl,password_buffer
	ld b,PASSWORD_BYTES_SIZE-1
password_check_sum_loop:
	ld c,(hl)
	add a,c	; make sure all bits affect the checksum, and not just the 5 lsb:
	rl c
	rl c
	rl c
	add a,c
	inc hl
	djnz password_check_sum_loop
	and #1f		; keep only the 5 lsb
	ret


;-----------------------------------------------
; - d: stores the current byte we are exracting bits from
; - e: counts how many more bits do we have left in the current byte
; - extracts a bit from d, puts it in a, and if we are out of bits, it gets the next byte from the password (hl)
password_get_next_bit:
	rl d	; msb to carry
	rl a	; carry to lsb
	dec e
	ret nz
	ld e,8
	inc hl
	ld d,(hl)
	ret


;-----------------------------------------------
password_bits_from_text:
	exx
		ld hl,password_buffer
	exx
	ld c,PASSWORD_BYTES_SIZE-1
	ld hl,password_text_buffer
	ld e,5
	ld d,(hl)
	rl d
	rl d
	rl d

password_bits_from_text_loop:
	ld b,8
	xor a
password_bits_from_text_bit_loop:
; password_get_next_bit_from_text:
	rl d	; lsb to carry
	rl a	; carry to lsb
	dec e
	jr nz,password_bits_from_text_bit_loop_continue
	ld e,5
	inc hl
	ld d,(hl)
	rl d
	rl d
	rl d	
password_bits_from_text_bit_loop_continue:
	djnz password_bits_from_text_bit_loop

	exx
		ld (hl),a
		inc hl
	exx
	dec c
	jr nz,password_bits_from_text_loop

	; finally the check sum can be written directly:
	ld a,(hl)
	exx
		ld (hl),a
	exx
	ret


;-----------------------------------------------
; generates the content of a password corresponding to the beginning of the game
password_generate_initial:
	; set initial credits:
	ld a,INITIAL_CREDITS
	ld (global_state_credits),a

	; rand seed:
	ld bc,(randData)
	; make sure random seed is not 0:
	; (which makes the random number generator get in a loop when in deterministic mode)
	ld a,b
	or c
	jr nz,password_generate_initial_not0
	inc bc
password_generate_initial_not0:
	ld (global_rand_seed),bc

	; set initial upgrades:
	ld hl,global_state_weapon_upgrade_level
	push hl
		ld bc,N_WEAPONS-1
		call clear_memory
	pop hl
	ld (hl),#ff	; mark the "NONE" weapon as special	
	inc hl
	ld a,1
	ld (hl),a	; we start with "WEAPON_SPEED" level 1
	inc hl
	inc hl
	ld (hl),a	; we start with "WEAPON_TRANSFER" level 1
	inc hl
	ld (hl),a	; we start with "WEAPON_BULLET" level 1
	ld hl,global_state_weapon_upgrade_level+WEAPON_PILOTS
	ld (hl),INITIAL_NUMBER_OF_LIVES
	
	; clear minimap:
	ld hl,global_state_minimap
	ld a,31
	ld bc,MINIMAP_WIDTH*(MINIMAP_HEIGHT+1)-1
	call clear_memory_a
; 	jp password_from_current_state


;-----------------------------------------------
password_from_current_state:
	ld hl,password_buffer

	; credits:
	ld a,(global_state_credits)
	ld (hl),a
	inc hl

	; random seed:
	ld bc,(global_rand_seed)
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl

	xor a
	ld (password_current_byte),a
	ld a,8
	ld (password_write_bit_counter),a

	; planet visit status:
	ld de,global_state_minimap
	ld c,5
password_from_current_state_planet_loop_y:
	ld b,11
password_from_current_state_planet_loop_x:
	; write the next bit:
	ld a,(de)
	push de
		call password_from_current_state_write_planet_bit
	pop de

	inc de
	inc de
	djnz password_from_current_state_planet_loop_x

	; next line:
	push hl
		ld hl,MINIMAP_WIDTH+4
		add hl,de
		ex de,hl
	pop hl
	dec c
	jr nz,password_from_current_state_planet_loop_y

	; last planet before triton:
	ld a,(global_state_minimap+22)
	call password_from_current_state_write_planet_bit

	; upgrade status:
	ld ix,global_state_weapon_upgrade_level+1
	ld b,N_WEAPONS-1
password_from_current_state_upgrade_loop:
	ld a,b
	ld c,(ix)
	cp 19  ; transfer
	jr z, password_from_current_state_upgrade_loop_transfer
	cp 2  ; init weapon
	jr z, password_from_current_state_upgrade_loop_1bit
	dec a  ; pilots
	jr z, password_from_current_state_upgrade_loop_pilots

password_from_current_state_upgrade_loop_2bits:
	rr c
	call password_from_current_state_write_upgrade_bit
password_from_current_state_upgrade_loop_1bit:
	rr c
	call password_from_current_state_write_upgrade_bit

	inc ix
	djnz password_from_current_state_upgrade_loop

	; checksum:
	call password_get_checksum
	ld (hl),a
	ret


password_from_current_state_upgrade_loop_transfer:
	dec c
	jr password_from_current_state_upgrade_loop_1bit

password_from_current_state_upgrade_loop_pilots:
	dec c
	dec c
	jr password_from_current_state_upgrade_loop_2bits


password_from_current_state_write_planet_bit:
	cp 89
	jr c,password_from_current_state_write_bit0
	cp 93
	jr nc,password_from_current_state_write_bit0

password_from_current_state_write_bit1:
	scf		; set carry flag
password_from_current_state_write_bit0_entry_point:
	ld de,password_current_byte
	ld a,(de)
	rl a	; carry flag goes to the lsb
	ld (de),a
	inc de	; password_write_bit_counter
	ld a,(de)
	dec a
	ld (de),a
	ret nz
	ld a,8
	ld (de),a
	ld a,(password_current_byte)
	ld (hl),a
	inc hl
	ret


password_from_current_state_write_upgrade_bit:
	jr c,password_from_current_state_write_bit1
; 	jr nc,password_from_current_state_write_bit0


password_from_current_state_write_bit0:
	xor a	; clear carry flag
	jr password_from_current_state_write_bit0_entry_point
