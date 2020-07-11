;-----------------------------------------------
; a: byte
; hl: target address in the VDP
writeByteToVDP:
    push af
        call SETWRT
        ld a,(VDP.DW)
        ld c,a
    pop af
    out (c),a
    ret
    

;-----------------------------------------------
; a: byte
; bc: amount to write
; hl: target address in the VDP
fast_FILVRM:
    push af
    push bc
        call SETWRT
        ld a,(VDP.DW)
        ld c,a
    pop de
    ld a,e
    or a
    jp z,fast_FILVRM_no_inc
    inc d
fast_FILVRM_no_inc:
    pop af
fast_FILVRM_loop2:
fast_FILVRM_loop:
    out (c),a
    dec e
    jp nz,fast_FILVRM_loop
    ;ld e,256
    dec d
    jp nz,fast_FILVRM_loop2
    ret


;-----------------------------------------------
; hl: source data
; de: target address in the VDP
; bc: amount to copy
fast_LDIRVM:
    ex de,hl    ; this is wasteful, but it's to maintain the order of parameters of the original LDIRVM...
                ; For things that require real speed, this function should not be used anyway, but use specialized loops
    push de
    push bc
        call SETWRT
    pop bc
    pop hl
    ; jp copy_to_VDP

;-----------------------------------------------
; This is like LDIRVM, but faster, and assumes, we have already called "SETWRT" with the right address
; input: 
; - hl: address to copy from
; - bc: amount fo copy
copy_to_VDP:
    ld e,b
    ld a,c
    or a
    jr z,copy_to_VDP_lsb_0
    inc e
copy_to_VDP_lsb_0:
    ld b,c
    ; get the VDP write register:
    ld a,(VDP.DW)
    ld c,a
    ld a,e
copy_to_VDP_loop2:
copy_to_VDP_loop:
    outi
    jp nz,copy_to_VDP_loop
    dec a
    jp nz,copy_to_VDP_loop2
    ret


;-----------------------------------------------
; de: target address in memory
; hl: source address in the VDP
; bc: amount to copy
fast_LDIRMV:
    push de
    push bc
        call SETRD
    pop bc
    pop hl
    ; jp copy_to_VDP

;-----------------------------------------------
; This is like LDIRVM, but faster, and assumes, we have already called "SETWRT" with the right address
; input: 
; - hl: address to copy from
; - bc: amount fo copy
copy_from_VDP:
    ld e,b
    ld a,c
    or a
    jr z,copy_from_VDP_lsb_0
    inc e
copy_from_VDP_lsb_0:
    ld b,c
    ; get the VDP write register:
    ld a,(VDP.DW)
    ld c,a
    ld a,e
copy_from_VDP_loop2:
copy_from_VDP_loop:
    ini
    jp nz,copy_from_VDP_loop
    dec a
    jp nz,copy_from_VDP_loop2
    ret    


;-----------------------------------------------
; This is like copy_to_VDP, but copying less than 256 bytes, amount in "b"
; input: 
; - hl: address to copy from
; - b: amount fo copy
; copy_to_VDP_less_than_256:
;     ; get the VDP write register:
;     ld a,(VDP.DW)
;     ld c,a
; copy_to_VDP_less_than_256_loop:
;     outi
;     jp nz,copy_to_VDP_less_than_256_loop
;     ret

; an even faster version, that only works if we are in vblank:
;copy_to_VDP_less_than_256_duringvblank:
;    ; get the VDP write register:
;    ld a,(VDP.DW)
;    ld c,a
;copy_to_VDP_less_than_256_duringvblank_loop:
;    outi
;    outi
;    outi
;    outi
;    outi
;    outi
;    outi
;    outi
;    jp nz,copy_to_VDP_less_than_256_duringvblank_loop
;    ret


;-----------------------------------------------
disable_VDP_output:
    ld a,(VDP_REGISTER_1)
    and #bf ; reset the BL bit
    di
    out (#99),a
    ld  a,1+128 ; write to register 1
    ei
    out (#99),a
    ret


;-----------------------------------------------
enable_VDP_output:
    ld a,(VDP_REGISTER_1)
    or #40  ; set the BL bit
    di
    out (#99),a
    ld  a,1+128 ; write to register 1
    ei
    out (#99),a
    ret


;-----------------------------------------------
; clear sprites:
clearAllTheSprites:
    ld hl,SPRATR2
    ld a,224
    ld bc,32*4
    jp FILVRM


;-----------------------------------------------
; Fills the whole screen with the pattern 0
clearScreen:
    xor a
    ld bc,768
    ld hl,NAMTBL2
    jp fast_FILVRM


;-----------------------------------------------
; Clears the screen left to right
; input:
; - iyl: how many rows to clear
clearScreenLeftToRight:
    ld iyl,24
clearScreenLeftToRight_iyl_rows:
    call clearAllTheSprites
clearScreenLeftToRight_iyl_rows_no_sprites:
    ld a,16
    ld bc,0
clearScreenLeftToRightExternalLoop:
    push af
    push bc
        ld a,iyl
        ld hl,NAMTBL2
        add hl,bc
clearScreenLeftToRightLoop:
        push hl
        push af
            xor a
            ld bc,2
            call fast_FILVRM
        pop af
        pop hl
        ld bc,32
        add hl,bc
        dec a
        jr nz,clearScreenLeftToRightLoop
    pop bc
    pop af
    inc bc
    inc bc
    dec a
    halt
    jr nz,clearScreenLeftToRightExternalLoop
    ret  


;-----------------------------------------------
; uploads the enemy attributes to the VDP
update_sprites:
    ld a,(scroll_x_half_pixel)
    and #03
    jp z,update_sprites_pattern1
    dec a
    jp z,update_sprites_pattern2
    dec a
    jp z,update_sprites_pattern3
update_sprites_pattern4:
    ld de,sprite_upload_order4
    jp update_sprites_pattern_set
update_sprites_pattern3:
    ld de,sprite_upload_order3
    jp update_sprites_pattern_set
update_sprites_pattern2:
    ld de,sprite_upload_order2
    jp update_sprites_pattern_set
update_sprites_pattern1:
    ld de,sprite_upload_order1

update_sprites_pattern_set:
    ld hl,SPRATR2+4*4
    call SETWRT
    ld a,(VDP.DW)
    ld c,a    
    ld a,28
update_sprites_pattern_set_loop:
    ex de,hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
    ex de,hl
    outi
    outi
    outi
    outi
    dec a
    jp nz,update_sprites_pattern_set_loop
    ret


;-----------------------------------------------
decompress_sprite_upload_order_plt:
    ld hl,sprite_upload_order_plt
    ld de,buffer
    push de
        call unpack_compressed    
    pop hl
    ld de,sprite_upload_order1
    ld b,4*7*4
decompress_sprite_upload_order_plt_loop:
    push bc
    push hl
        ld b,0
        ld c,(hl)
        ld hl,in_game_sprite_attributes-4*4
        add hl,bc
        ex de,hl
            ld (hl),e
            inc hl
            ld (hl),d
            inc hl
        ex de,hl
    pop hl
    pop bc
    inc hl
    djnz decompress_sprite_upload_order_plt_loop
    ret


;-----------------------------------------------
; hl: ptr to compressed sprites
; bc: amount of data to copy to the VDP
load_sprites_sprtbl2:
    ld de,SPRTBL2
load_sprites:
    push de
    push bc
        ; unpack sprites:
        ld de,buffer4
        call unpack_compressed
    pop bc
    pop de

    ; load them to the VDP:
    ld hl,buffer4
    jp fast_LDIRVM
