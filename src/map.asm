;-----------------------------------------------
draw_map:
    ld a,(starfield_scroll_speed)
    cp 4
    jp z,draw_map_no_scroll

    ld hl,NAMTBL2
    call SETWRT
    ld a,(VDP.DW)
    ld c,a
    
    ld de,tileTypeBuffers
    ld a,(scroll_x_half_pixel)
    srl a   
    srl a   ; scroll is 2 by 2 pixels
    add a,d
    ld d,a
    ld b,e  ; we set this for later (e == 0 as tileTypeBuffers is 256 aligned)

    ld hl,mapBuffer
    ld a,(scroll_x_tile)
    ADD_HL_A
    
;     ld iyh,MAP_HEIGHT
;     ld iyl,MAP_BUFFER_WIDTH-31    ; since we skip the last inc hl
    ld iy,((MAP_BUFFER_WIDTH - 31) & #ff) + (MAP_HEIGHT << 8)

draw_map_column_loop:
    ; this loop is unrolled to make it faster:
    REPT 31
        ld e,(hl)
        ld a,(de)
        out (c),a
        inc l   ; no need to increment "hl" on the first 31 iterations, as map is 32-aligned
    ENDM
    ld e,(hl)
    ld a,(de)
    out (c),a

    ld a,iyl
    ADD_HL_A
    ld a,iyh
    cp (MAP_HEIGHT-8)+1
    jp z,draw_map_switch_to_bank2
    dec iyh
    jp nz,draw_map_column_loop
    ret

draw_map_switch_to_bank2:
    ld de,tileTypeBuffers+4*256
    ld a,(scroll_x_half_pixel)
    srl a
    srl a   ; scroll is 2 by 2 pixels
    add a,d
    ld d,a
    dec iyh
    jp draw_map_column_loop


;-----------------------------------------------
draw_map_no_scroll:
    ld hl,NAMTBL2
    call SETWRT
    
    ld hl,mapBuffer
    ld a,(scroll_x_tile)
    ADD_HL_A
    
    ld iyh,MAP_HEIGHT
    ld de,MAP_BUFFER_WIDTH-32
    ld a,(VDP.DW)
    ld c,a
draw_map_no_scroll_column_loop:
    ld b,32
draw_map_no_scroll_column_loop2:
    outi
    jp nz,draw_map_no_scroll_column_loop2
    add hl,de
    dec iyh
    jp nz,draw_map_no_scroll_column_loop
    ret
