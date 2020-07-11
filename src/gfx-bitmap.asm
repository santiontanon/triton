
;-----------------------------------------------
; sets the name table of the banks to: 0, 1, 2, 3, ..., 255
; and clears all patterns and attributes to 0
set_bitmap_mode:
    xor a
set_bitmap_mode_a_color:
    ld bc,8*256*3
    ld hl,CLRTBL2
    call fast_FILVRM
    xor a
    ld bc,8*256*3
    ld hl,CHRTBL2
    call fast_FILVRM
    ; jp set_bitmap_name_table_all_banks


;-----------------------------------------------
; sets the name table of the banks to: 0, 1, 2, 3, ..., 255
set_bitmap_name_table_all_banks:
    ld hl,NAMTBL2
    call set_bitmap_name_table
    ld hl,NAMTBL2+256
    call set_bitmap_name_table
set_bitmap_name_table_bank3:
    ld hl,NAMTBL2+512

set_bitmap_name_table:
    call SETWRT
    ld a,(VDP.DW)
    ld c,a
    xor a
    ld b,a
set_bitmap_name_table_bank3_loop:
    out (c),a
    inc a
    djnz set_bitmap_name_table_bank3_loop
    ret


;-----------------------------------------------
; 0,8,16, ...
; 1,9,17, ...
; ...
; 7,15,23, ...
set_vertical_bitmap_name_table_bank1:
   ld hl,NAMTBL2+256
set_vertical_bitmap_name_table:
    call SETWRT
    ld a,(VDP.DW)
    ld c,a
    xor a
    ld b,a
set_vertical_bitmap_name_table_bank3_loop:
    out (c),a
    add a,8
    jr nc,set_vertical_bitmap_name_table_bank3_loop_continue
    inc a
set_vertical_bitmap_name_table_bank3_loop_continue:
    djnz set_vertical_bitmap_name_table_bank3_loop
    ret



;-----------------------------------------------
; - a: tile index
; - de: ptr to the tile to draw: 8 bytes for pattern + 8 bytes for attributes
draw_tile_bitmap_mode_by_index:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc,buffer
    add hl,bc
    ; jp draw_tile_bitmap_mode


;-----------------------------------------------
; assuming the screen is in screen 2 bitmap mode, it draws a tile+attributes
; - hl: ptr to the pattern table to draw to
; - de: ptr to the tile to draw: 8 bytes for pattern + 8 bytes for attributes
draw_tile_bitmap_mode:
    push hl
        push de
            ld bc,8
            call fast_LDIRVM
        pop hl
        ld bc,CLRTBL2-CHRTBL2
        add hl,bc
        ex de,hl
    pop hl
    ld bc,8
    add hl,bc
    jp fast_LDIRVM


;-----------------------------------------------
; input:
; - hl: ptr to clear (CLRTBL2, as we only clear the attributes)
; - b: height in tiles
; - c: width in tiles
clear_rectangle_bitmap_mode:
    push bc
        push hl
            ld b,0
            sla c
            sla c
            sla c
            rl b    ; we only need to do rl b in the 3rd shift, as the other two can never carry a bit
            xor a
            call fast_FILVRM
        pop hl
        ld bc,32*8
        add hl,bc
    pop bc
    djnz clear_rectangle_bitmap_mode
    ret
