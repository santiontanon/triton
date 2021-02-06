;-----------------------------------------------
load_level_type_data:
    ; 1) decompress additional tiles to VDP:
    ld ix,decompress_ingame_additional_tiles_plt_from_page1
    call call_from_page1
    ld hl,buffer
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld de,CHRTBL2
    push bc
        call fast_LDIRVM
    pop bc
    ld de,CLRTBL2
    push bc
        call fast_LDIRVM
    pop bc
    ld hl,buffer+2
    ld de,CHRTBL2+256*8
    push bc
        call fast_LDIRVM
    pop bc
    ld de,CLRTBL2+256*8
    push bc
        call fast_LDIRVM
    pop bc
    ld hl,buffer+2
    ld de,CHRTBL2+256*8*2
    push bc
        call fast_LDIRVM
    pop bc
    ld de,CLRTBL2+256*8*2
    call fast_LDIRVM

    ld a,(global_state_selected_level_type)
    or a
    jr z,load_level_type_data_moai
    dec a
    jp z,load_level_type_data_tech
    dec a
    jp z,load_level_type_data_water

load_level_type_data_temple:
    ld hl,decompress_temple_song_from_page1
    ld (level_type_song_ptr),hl
    ld a,(isComputer50HzOr60Hz)
    add a,6 ; 6 if 50Hz, 7 if 60Hz
    ld (level_type_song_speed),a

;     ld hl,destroyable_tiles_temple
;     ld de,destroyable_tiles_bank0
;     ld bc,6
;     ldir
    
    ; 2) decompress base tiles:
    ld ix,decompress_ingame_ingame_base_tiles_plt_from_page1
    call call_from_page1
    ; 3) decompress used tile-types:
    ld ix,decompress_ingame_ingame_tile_types_temple_plt_from_page1
    call call_from_page1
    call generate_offset_tiles
    ld ix,decompress_temple_tile_types_from_page1
    call call_from_page1
    call set_up_tile_type_tables

    ld ix,decompress_pcgPatterns_temple_plt_from_page1
    call call_from_page1

    ld hl,tile_enemies_temple0
    ld (level_type_tile_enemies_bank0),hl
    ld hl,tile_enemies_temple1
    ld (level_type_tile_enemies_bank1),hl
    ret

load_level_type_data_moai:
    ld hl,decompress_moai_song_from_page1
    ld (level_type_song_ptr),hl
    ld a,(isComputer50HzOr60Hz)
    add a,a
    add a,9 ; 9 if 50Hz, 11 if 60Hz
    ld (level_type_song_speed),a

    ld hl,destroyable_tiles_moai
    ld de,destroyable_tiles_bank0
    ld bc,6
    ldir
    
    ; 2) decompress base tiles:
    ld ix,decompress_ingame_ingame_base_tiles_plt_from_page1
    call call_from_page1
    ; 3) decompress used tile-types:
    ld ix,decompress_ingame_ingame_tile_types_moai_plt_from_page1
    call call_from_page1
    call generate_offset_tiles
    ld ix,decompress_moai_tile_types_from_page1
    call call_from_page1
    call set_up_tile_type_tables

    ld ix,decompress_pcgPatterns_moai_plt_from_page1
    call call_from_page1

    ld hl,tile_enemies_moai0
    ld (level_type_tile_enemies_bank0),hl
    ld hl,tile_enemies_moai1
    ld (level_type_tile_enemies_bank1),hl
    ret

load_level_type_data_tech:
    ld hl,decompress_tech_song_from_page1
    ld (level_type_song_ptr),hl
    ld a,(isComputer50HzOr60Hz)
    add a,a
    add a,9 ; 9 if 50Hz, 11 if 60Hz
    ld (level_type_song_speed),a

    ; 2) decompress base tiles:
    ld ix,decompress_ingame_ingame_base_tiles_plt_from_page1
    call call_from_page1
    ; 3) decompress used tile-types:
    ld ix,decompress_ingame_ingame_tile_types_tech_plt_from_page1
    call call_from_page1
    call generate_offset_tiles
    ld ix,decompress_tech_tile_types_from_page1
    call call_from_page1
    call set_up_tile_type_tables

    ld ix,decompress_pcgPatterns_tech_plt_from_page1
    call call_from_page1

    ld hl,tile_enemies_tech0
    ld (level_type_tile_enemies_bank0),hl
    ld hl,tile_enemies_tech1
    ld (level_type_tile_enemies_bank1),hl
    ret

load_level_type_data_water:
    ld hl,decompress_water_song_from_page1
    ld (level_type_song_ptr),hl
    ld a,(isComputer50HzOr60Hz)
    add a,8 ; 8 if 50Hz, 9 if 60Hz
    ld (level_type_song_speed),a

    ; 2) decompress base tiles:
    ld ix,decompress_ingame_ingame_base_tiles_plt_from_page1
    call call_from_page1
    ; 3) decompress used tile-types:
    ld ix,decompress_ingame_ingame_tile_types_water_plt_from_page1
    call call_from_page1
    call generate_offset_tiles
    ld ix,decompress_water_tile_types_from_page1
    call call_from_page1
    call set_up_tile_type_tables

    ld ix,decompress_pcgPatterns_water_plt_from_page1
    call call_from_page1

    ld hl,tile_enemies_water0
    ld (level_type_tile_enemies_bank0),hl
    ld hl,tile_enemies_water1
    ld (level_type_tile_enemies_bank1),hl
    ret

set_up_tile_type_tables:
    ld hl,buffer
    ld a,2
    ld de,tileTypeBuffers
set_up_tile_type_tables_loop2:
    push af
        ld b,0
        ld c,(hl)   ; length
        inc hl
        ld a,4
set_up_tile_type_tables_loop1:
;         push af
        push bc
            push de
                ldir
            pop de
            ex de,hl
                ld bc,256
                add hl,bc
            ex de,hl
        pop bc
;         pop af
        dec a
        jr nz,set_up_tile_type_tables_loop1
    pop af
    dec a
    jr nz,set_up_tile_type_tables_loop2
    ret	
