; ------------------------------------------------
starfield_new_star_following_scroll:
	ld a,(scroll_x_tile)
	add a,32
	ld c,a
	ld b,0


; ------------------------------------------------
; input:
; - bc: star X
starfield_new_star:
	call random
	and #3e	; (modulo 32)*2 (there is a chance that stars are outside of the viewport, and thus, not drawn)
	add a,2	; we don't want stars at the top, as some times they flicker at 60Hz
	cp 22*2
	jp nc,starfield_new_star_outofbounds

	ld e,a
	ld d,0
	ld hl,map_y_ptr_table
	add hl,de
	ld e,(hl)
	inc hl
	ld h,(hl)	
	ld l,e	; hl now has the y ptr
	add hl,bc	; add x coordinate
	ex de,hl	; de has the pointer to the new star
	jp starfield_new_star_ptr_calculated

starfield_new_star_outofbounds:
	ld de,0

starfield_new_star_ptr_calculated:
	ld hl,starfield_cycle
	ld a,(hl)
	inc a
	cp 33
	jr nz,starfield_new_star_ptr_calculated_no_loop_back
	xor a
starfield_new_star_ptr_calculated_no_loop_back:
	ld (hl),a
	ld hl,starfield_ptrs
	add a,a
	ld b,0
	ld c,a
	add hl,bc
	ld (hl),d
	inc hl
	ld (hl),e
	ret



; ------------------------------------------------
starfield_update_16x_even:
	ld a,#ff
	ld hl,CHRTBL2+STAR_TILE*8+4
	call writeByteToVDP
	ld hl,CHRTBL2+STAR_TILE*8+4 + 256*8
	call writeByteToVDP
	ld hl,CHRTBL2+STAR_TILE*8+4 + 2*256*8
	jp writeByteToVDP

starfield_update_16x_odd:
	ld iyl,4
	ld a,(scroll_x_half_pixel)
; 	bit 0,a
; 	jp nz,starfield_update_draw
; 	or a
	cp 15
	jr nz,starfield_update_adjust_ptrs
	ld iyl,1
	jr starfield_update_adjust_ptrs


; ------------------------------------------------
	IF STAR_TILE != 1
		ERROR "STAR_TILE != 1, this is assumed by starfield_update"
	ENDIF
starfield_update_even:	
	ld a,(starfield_scroll_speed)
	cp 4
	jr z,starfield_update_16x_even

 	ld a,(scroll_x_half_pixel)
 	and #03
 	ret nz

	; update the star tile (in all 3 banks)
	ld hl,starfield_tile
	ld a,(hl)
	rlca
	ld (hl),a

	ld hl,CHRTBL2+STAR_TILE*8+4
	call writeByteToVDP
	ld hl,CHRTBL2+STAR_TILE*8+4 + 256*8
	call writeByteToVDP
	ld hl,CHRTBL2+STAR_TILE*8+4 + 2*256*8
	jp writeByteToVDP


starfield_update_odd:
	ld a,(starfield_scroll_speed)
	cp 4
	jr z,starfield_update_16x_odd

 	ld a,(scroll_x_half_pixel)
 	and #03
 	cp 3
 	ret nz

	; sample a new star if necessary, and increment all the pointers (so stars move at half the speed as the fg):

 	ld a,(starfield_scroll_speed)
 	ld iyl,a
; 	; 0: inc de when #10
; 	; 1: -
; 	; 2, 3: dec de when #01 only if scroll_x_half_pixel != 0
; 	or a
; 	jr z,starfield_update_1x_speed
; 	dec a
; 	jr z,starfield_update_2x_speed
; 	dec a
; 	jr z,starfield_update_4x_speed
; 	dec a
; 	jr z,starfield_update_8x_speed

starfield_update_1x_speed:
	ld a,(starfield_tile)
	cp #08
	jr nz,starfield_update_adjust_check_for_scroll_restart
; 	jr starfield_update_adjust_ptrs

; starfield_update_2x_speed:
; 	ld a,c
; 	cp #08
; 	jp nz,starfield_update_draw
; 	jr starfield_update_adjust_ptrs

; starfield_update_8x_speed:
; starfield_update_4x_speed:
; 	ld a,c
; 	cp #01
; 	ret nz
; 	ld a,(scroll_x_half_pixel)
; 	or a
; 	jr nz,starfield_update_adjust_ptrs
; 	ld iyl,1
; 	;jr starfield_update_adjust_ptrs

starfield_update_adjust_ptrs:
	call starfield_update_draw_internal
	call starfield_new_star_following_scroll

starfield_update_adjust_check_for_scroll_restart:
	ld a,(scroll_x_tile)
	cp 63
	ret nz

	ld a,(scroll_x_half_pixel)
	cp 15
	ret nz


;  	ld a,(starfield_scroll_speed)
;  	cp 4
;  	jr z,starfield_update_adjust_ptrs_loop_skip_star_16x
; 	cp 3
; 	jr z,starfield_update_adjust_ptrs_loop_skip_star_8x
; 	cp 2
; 	jp z,starfield_update_adjust_ptrs_loop_skip_star_4x
; 	jr update_star_ptrs_after_scroll_restart

; starfield_update_adjust_ptrs_loop_skip_star_4x:
; 	ld a,(scroll_x_half_pixel)
; 	cp 8
; 	ret m
; 	jr update_star_ptrs_after_scroll_restart

; starfield_update_adjust_ptrs_loop_skip_star_8x:
; 	ld a,(scroll_x_half_pixel)
; 	cp 12
; 	ret m
; 	jr update_star_ptrs_after_scroll_restart

; starfield_update_adjust_ptrs_loop_skip_star_16x:
; 	ld a,(scroll_x_half_pixel)
; 	cp 14
; 	ret m
	; jr update_star_ptrs_after_scroll_restart


; ------------------------------------------------
update_star_ptrs_after_scroll_restart:
	ld hl,starfield_ptrs
	ld iyl,33
	ld bc,-64
update_star_ptrs_after_scroll_restart_loop:
	ld d,(hl)
	inc hl
	ld a,d
	or a
	jr z,update_star_ptrs_after_scroll_restart_loop_skip
	ld e,(hl)
	dec hl
	ex de,hl
		add hl,bc
		ld a,(hl)
		or a
		jr nz,update_star_ptrs_after_scroll_restart_no_draw
		ld (hl),STAR_TILE
update_star_ptrs_after_scroll_restart_no_draw:
	ex de,hl
	ld (hl),d
	inc hl
	ld (hl),e
update_star_ptrs_after_scroll_restart_loop_skip:	
	inc hl
	dec iyl
	jr nz,update_star_ptrs_after_scroll_restart_loop
	ret


; ------------------------------------------------
starfield_update_draw:
	ld iyl,1	; mark so that pointers are not modified
starfield_update_draw_internal:
	ld hl,starfield_ptrs
	ld b,33
starfield_update_adjust_ptrs_loop:
	ld a,(hl)
	inc hl
	or a
	jp z,starfield_update_adjust_ptrs_loop_skip_star
	ld d,a
	ld e,(hl)
	dec hl	; "de" has the star pointer

	ld a,(de)
	dec a	; assuming STAR_TILE == 1
 	jp nz,starfield_update_adjust_ptrs_loop_star_deleted
 	ld (de),a	; a is 0 here
starfield_update_adjust_ptrs_loop_star_deleted:

	ld a,iyl
	or a
	jr z,starfield_update_adjust_ptrs_loop_inc
	dec a
	jr z,starfield_update_adjust_ptrs_loop_de_updated
starfield_update_adjust_ptrs_loop_dec:
	;dec de
	dec e
	jr starfield_update_adjust_ptrs_loop_de_updated
starfield_update_adjust_ptrs_loop_inc:
	;inc de
	inc e
starfield_update_adjust_ptrs_loop_de_updated:	

	ld (hl),d
	inc hl
	ld (hl),e

	ld a,(de)
	or a
 	jp nz,starfield_update_adjust_ptrs_loop_skip_star
 	inc a
 	ld (de),a	; assuming STAR_TILE == 1

starfield_update_adjust_ptrs_loop_skip_star:
	inc hl
	djnz starfield_update_adjust_ptrs_loop
	ret
