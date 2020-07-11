;-----------------------------------------------
; inputs:
; - base_tiles are uncompressed in "buffer"
; - tile type offsets uncompressed in "tileTypeBuffers"
generate_offset_tiles:
	; 1) calculate base tile pattern and attribute pointers and put them in IX and IY
	ld ix,buffer
	ld l,(ix)
	inc ix
	ld h,(ix)
	inc ix
	ld bc,buffer+2
	add hl,bc
	push hl
	pop iy

	; 2) bank 0:
	ld hl,tileTypeBuffers
	exx
		ld de,CHRTBL2+21*8
	exx
	call generate_offset_tiles_bank

	; 3) banks 1 and 2:
	push hl
		exx
			ld de,CHRTBL2+256*8+43*8
		exx
		call generate_offset_tiles_bank
	pop hl

	exx
		ld de,CHRTBL2+256*8*2+43*8
	exx
	;jp generate_offset_tiles_bank


;-----------------------------------------------
; recreates the offset tiles for one bank.
; input:
; 
; - hl: ptr to the tile type definitions (first byte is the # of them)
; - shadow hl: pointer in VDP to copy
; - ix: base patterns
; - iy: base attributes
generate_offset_tiles_bank:
	ld b,(hl)	; number of tiles
	inc hl
generate_offset_tiles_bank_loop:
	push bc
		; process one tile type:
		; 1) copy the first base tile and attributes to a memory buffer:
		ld a,(hl)
		inc hl
		ld de,text_buffer
		cp #ff
		jr z,generate_offset_tiles_bank_complete_overwrite
		cp 240
		jr nc,generate_offset_tiles_bank_merge_tiles

		call generate_offset_tiles_get_base_tile
		jr generate_offset_tiles_bank_no_flag_overwrite
generate_offset_tiles_bank_merge_tiles:
		; a has the offset
		push af
			ld a,(hl)
			inc hl
			call generate_offset_tiles_get_base_tile

			; 2) copy the second base tile and attributes to a memory buffer:
			ld a,(hl)
			inc hl
			ld de,text_buffer+16
			call generate_offset_tiles_get_base_tile
		pop af

		; 3) offset them the right amount and calculate pattern and attributes:
		push af
		push ix
		push iy
			and #03	; clear the overwrite flags
			ld ix,text_buffer
			ld iy,text_buffer+16

			ld b,8
generate_offset_tiles_bank_shift_outer_loop:
			ld c,(ix)	; first tile
			ld d,0
			ld e,(iy)	; second tile

			push af
				or a
				jr z,generate_offset_tiles_bank_shift_loop_end
generate_offset_tiles_bank_shift_loop:
				sla c
				sla c
				sla e
				rl d
				sla e
				rl d
				dec a
				jr nz,generate_offset_tiles_bank_shift_loop
generate_offset_tiles_bank_shift_loop_end:

				; merge pattern and attributes:
				ld a,c
				or a
				jr nz,generate_offset_tiles_bank_shift_loop_color_from_first
				ld c,(iy+8)
				ld (ix+8),c
generate_offset_tiles_bank_shift_loop_color_from_first:
				or d
				ld (ix),a
			pop af
			inc ix
			inc iy
			djnz generate_offset_tiles_bank_shift_outer_loop
		pop iy
		pop ix
		pop af

		bit 3,a
		jr z,generate_offset_tiles_bank_no_flag_overwrite
		ld de,text_buffer+8
		ld bc,8
		ldir
generate_offset_tiles_bank_no_flag_overwrite:

		; 4) copy it to VDP:
		call generate_offset_tiles_copy_to_vdp

	pop bc
	djnz generate_offset_tiles_bank_loop
	ret


generate_offset_tiles_bank_complete_overwrite:
	ld de,text_buffer
	ld bc,16
	ldir
	jr generate_offset_tiles_bank_no_flag_overwrite


generate_offset_tiles_get_base_tile:
	push hl
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		push hl
			push ix
			pop bc
			add hl,bc
			ld bc,8
			ldir
		pop hl
		push iy
		pop bc
		add hl,bc
		ld bc,8
		ldir
	pop hl
	ret

generate_offset_tiles_copy_to_vdp:
	exx
		push de
			push de
				ld hl,text_buffer
				ld bc,8
				call fast_LDIRVM
			pop hl
			ld bc,CLRTBL2-CHRTBL2
			add hl,bc
			ex de,hl
			ld hl,text_buffer+8
			ld bc,8
			push bc
				call fast_LDIRVM
			pop bc
		pop hl
		add hl,bc
		ex de,hl
	exx
	ret
