;-----------------------------------------------
; DEBUGGING
DETERMINISTIC:	equ 0


;-----------------------------------------------
; BIOS calls:
SYNCHR: equ #0008
RDSLT:  equ #000c
CHRGTR: equ #0010
WRSLT:  equ #0014
OUTDO:  equ #0018
CALSLT: equ #001c
DCOMPR: equ #0020
ENASLT: equ #0024
GETYPR: equ #0028
CALLF:  equ #0030
KEYINT: equ #0038
INITIO: equ #003b
INIFNK: equ #003e
DISSCR: equ #0041
ENASCR: equ #0044
WRTVDP: equ #0047
RDVRM:  equ #004a
WRTVRM: equ #004d
SETRD:  equ #0050
SETWRT: equ #0053
FILVRM: equ #0056
LDIRMV: equ #0059
LDIRVM: equ #005c
CHGMOD: equ #005f
CHGCLR: equ #0062
NMI:    equ #0066
CLRSPR: equ #0069
INITXT: equ #006c
INIT32: equ #006f
INIGRP: equ #0072
INIMLT: equ #0075
SETTXT: equ #0078
SETT32: equ #007b
SETGRP: equ #007e
SETMLT: equ #0081
CALPAT: equ #0084
CALATR: equ #0087
GSPSIZ: equ #008a
GRPPRT: equ #008d
GICINI: equ #0090
WRTPSG: equ #0093
RDPSG:  equ #0096
STRTMS: equ #0099
CHSNS:  equ #009c
CHGET:  equ #009f
CHPUT:  equ #00a2
LPTOUT: equ #00a5
LPTSTT: equ #00a8
CNVCHR: equ #00ab
PINLIN: equ #00ae
INLIN:  equ #00b1
QINLIN: equ #00b4
BREAKX: equ #00b7
ISCNTC: equ #00ba
CKCNTC: equ #00bd
BEEP:   equ #00c0
CLS:    equ #00c3
POSIT:  equ #00c6
FNKSB:  equ #00c9                
ERAFNK: equ #00cc
DSPFNK: equ #00cf
TOTEXT: equ #00d2
GTSTCK: equ #00d5
GTTRIG: equ #00d8
GTPAD:  equ #00db
GTPDL:  equ #00de
TAPION: equ #00e1
TAPIN:  equ #00e4
TAPIOF: equ #00e7
TAPOON: equ #00ea
TAPOUT: equ #00ed
TAPOOF: equ #00f0
STMOTR: equ #00f3
LFTQ:   equ #00f6
PUTQ:   equ #00f9
RIGHTC: equ #00fc
LEFTC:  equ #00ff
UPC:    equ #0102
TUPC:   equ #0105
DOWNC:  equ #0108
TDOWNC: equ #010b
SCALXY: equ #010e
MAPXY:  equ #0111
FETCHC: equ #0114
STOREC: equ #0117
SETATR: equ #011a
READC:  equ #011d
SETC:   equ #0120
NSETCX: equ #0123
GTASPC: equ #0126
PNTINI: equ #0129
SCANR:  equ #012c
SCANL:  equ #012f
CHGCAP: equ #0132
CHGSND: equ #0135
RSLREG: equ #0138
WSLREG: equ #013b
RDVDP:  equ #013e
SNSMAT: equ #0141
PHYDIO: equ #0144
FORMAT: equ #0147
ISFLIO: equ #014a
OUTDLP: equ #014d
GETVCP: equ #0150
GETVC2: equ #0153
KILBUF: equ #0156
CALBAS: equ #0159
SUBROM: equ #015c
EXTROM: equ #015f
CHKSLZ: equ #0162
CHKNEW: equ #0165
EOL:    equ #0168
BIGFIL: equ #016b
NSETRD: equ #016e
NSTWRT: equ #0171
NRDVRM: equ #0174
NWRVRM: equ #0177
RDRES:  equ #017a
WRRES:  equ #017d
CHGCPU: equ #0180
GETCPU: equ #0183
PCMPLY: equ #0186
PCMREC: equ #0189


;-----------------------------------------------
; System variables
VDP.DR:	equ #0006
VDP.DW:	equ #0007
VDP_REGISTER_0: equ #f3df
VDP_REGISTER_1: equ #f3e0
CLIKSW: equ #f3db       ; keyboard sound
FORCLR: equ #f3e9
BAKCLR: equ #f3ea
BDRCLR: equ #f3eb
SCNCNT: equ #f3f6
PUTPNT: equ #f3f8
GETPNT: equ #f3fa
MODE:   equ #fafc	
KEYS:   equ #fbe5    
KEYBUF: equ #fbf0
EXPTBL: equ #fcc1
TIMI:   equ #fd9f       ; timer interrupt hook
HKEY:   equ #fd9a       ; hkey interrupt hook


;-----------------------------------------------
; Assembler opcodes:	
JP_OPCODE: 			equ  #c3
RET_OPCODE:        	equ  #c9

;-----------------------------------------------
; VRAM map in Screen 1 (only 1 table of patterns, color table has 1 byte per each 8 patterns)
CHRTBL1:  equ     #0000   ; pattern table address
NAMTBL1:  equ     #1800   ; name table address 
CLRTBL1:  equ     #2000   ; color table address             
SPRTBL1:  equ     #0800   ; sprite pattern address  
SPRATR1:  equ     #1b00   ; sprite attribute address
; VRAM map in Screen 2 (3 tables of patterns, color table has 8 bytes per pattern)
CHRTBL2:  equ     #0000   ; pattern table address
NAMTBL2:  equ     #1800   ; name table address 
CLRTBL2:  equ     #2000   ; color table address             
SPRTBL2:  equ     #3800   ; sprite pattern address  
SPRATR2:  equ     #1b00   ; sprite attribute address

; VRAM map in Screen 4 (patterns like Screen 2, but sprites specify one color per line)
CHRTBL4:  equ     #0000   ; pattern table address
NAMTBL4:  equ     #1800   ; name table address 
CLRTBL4:  equ     #2000   ; color table address             
SPRTBL4:  equ     #3800   ; sprite pattern address  
SPRATR4:  equ     #1e00   ; sprite attribute address
SPRCLR4:  equ     #1c00   ; sprite attribute address

;-----------------------------------------------
; MSX1 colors:
COLOR_TRANSPARENT:	equ 0
COLOR_BLACK:		equ 1
COLOR_GREEN:		equ 2
COLOR_LIGHT_GREEN:	equ 3
COLOR_DARK_BLUE:	equ 4
COLOR_BLUE:			equ 5
COLOR_DARK_RED:		equ 6
COLOR_LIGHT_BLUE:	equ 7
COLOR_RED:			equ 8
COLOR_LIGHT_RED:	equ 9
COLOR_DARK_YELLOW:	equ 10
COLOR_YELLOW:		equ 11
COLOR_DARK_GREEN:	equ 12
COLOR_PURPLE:		equ 13
COLOR_GREY:			equ 14
COLOR_WHITE:		equ 15


;-----------------------------------------------
; A couple of useful macros for adding 16 and 8 bit numbers

; 5 bytes
; time 24 - 28 cycles
ADD_HL_A: MACRO 
    add a,l
    ld l,a
    jr nc, $+3
    inc h
    ENDM


ADD_DE_A: MACRO 
    add a,e
    ld e,a
    jr nc, $+3
    inc d
    ENDM    


; 4 bytes
; time 25 cycles
ADD_HL_A_VIA_BC: MACRO
    ld b,0
    ld c,a
    add hl,bc
    ENDM


; ------------------------------------------------
	include "sound-constants.asm"


; ------------------------------------------------
KEY_LEFT_BYTE:				equ 0
KEY_LEFT_BIT:				equ 4

KEY_RIGHT_BYTE:				equ 0
KEY_RIGHT_BIT:				equ 7

KEY_UP_BYTE:				equ 0
KEY_UP_BIT:					equ 5

KEY_DOWN_BYTE:				equ 0
KEY_DOWN_BIT:				equ 6

KEY_BUTTON1_BYTE:			equ 0
KEY_BUTTON1_BIT:			equ 0

KEY_BUTTON2_BYTE:			equ 1*2
KEY_BUTTON2_BIT:			equ 2

KEY_PAUSE_BYTE:				equ 2*2
KEY_PAUSE_BIT:				equ 5

KEY_Q_BYTE:					equ 1*2
KEY_Q_BIT:					equ 6


; ------------------------------------------------
; All the code for the title screen, brain games screeen, menus, etc. is not needed in-game,
; and thus we can compress it away, and we have enough RAM to decompress it when needed.
; This is the address wehre it will be decompressed:
NON_GAME_COMPRESSED_CODE_START:			equ #D900
BOSS_COMPRESSED_CODE_START:             equ #C600


; ------------------------------------------------
FIRST_WALL_COLLIDABLE_ONLY_SHIP_TILE:	equ	72
FIRST_WALL_COLLIDABLE_TILE:				equ	73
FIRST_DESTROYABLEWALL_COLLIDABLE_TILE: 	equ 205
FIRST_TILEENEMY_COLLIDABLE_TILE: 		equ 207


; ------------------------------------------------
INITIAL_CREDITS:			equ 2
; INITIAL_CREDITS:			equ 64
INITIAL_NUMBER_OF_LIVES:	equ 2	; 0 is the last life, so, 2 means you have 3 lives
MAX_NUMBER_OF_LIVES:		equ 8
INVULNERABLE_TIME:			equ 80
MINIMAP_WIDTH:				equ 26
MINIMAP_HEIGHT:				equ 9

MAP_HEIGHT:					equ 22
PCG_PATTERN_WIDTH:			equ 16
;MAP_BUFFER_WIDTH:			equ 6*PCG_PATTERN_WIDTH
MAP_BUFFER_WIDTH:			equ 128	; this is wider than necessary, but helps with optimization
PCG_WAVE_TYPES_PER_PATTERN:	equ 4

STAR_TILE:					equ 1
FIRST_WEAPON_TILE:			equ 2

N_WEAPON_TILES:				equ 4

MAX_ENEMIES:				equ 10
MAX_ENEMY_BULLETS:			equ 10

MAX_TILE_ENEMIES:			equ 12

FIRST_TILE_FOR_IN_GAME_TEXT:	equ 240

SCOREBOARD_LIFE_TILE:		equ 25

TIME_PRESSING_FOR_SPECIAL:	equ 6

PLAYER_STATE_DEFAULT:		equ 0
PLAYER_STATE_INVULNERABLE:	equ 1
PLAYER_STATE_EXPLOSION:		equ 2

PLAYER_SPRITE_SHIP:         equ 0*4
PLAYER_SPRITE_EXPLOSION:	equ 6*4
PLAYER_SPRITE_SHIELD:		equ 17*4
OPTION_SPRITE:				equ 12*4

MAX_PLAYER_BULLETS:			equ 16
MAX_FLAME_LENGTH:			equ 14

BULLET_DAMAGE:              equ 1
BULLET_DAMAGE_MAX:          equ 2
OPTION_BULLET_DAMAGE:       equ 1
OPTION_BULLET_DAMAGE_MAX:   equ 2
LASER_DAMAGE:               equ 1
LASER_DAMAGE_MAX:           equ 2
TWISTER_LASER_DAMAGE:       equ 2
TWISTER_LASER_DAMAGE_MAX:   equ 3
FLAME_DAMAGE:               equ 4
FLAME_DAMAGE_MAX:           equ 6
MISSILE_DAMAGE:             equ 2   ; +2
LIGHT_TORPEDO_DAMAGE:       equ 3   ; +2
HEAVY_TORPEDO_DAMAGE:       equ 6   ; +2

PLAYER_BULLET_STRUCT_SIZE:	    equ 10
PLAYER_BULLET_STRUCT_TYPE:		equ 0	; 0 if there is no bullet here, and type if there is.
										; msb determines if it is marked for deletion! 
										; (they are only actually deleted, once they restore their bg)
PLAYER_BULLET_STRUCT_TILE:		equ 1
PLAYER_BULLET_STRUCT_DAMAGE:	equ 2
PLAYER_BULLET_STRUCT_TILE_X:	equ 3
PLAYER_BULLET_STRUCT_TILE_Y:	equ 4
PLAYER_BULLET_STRUCT_BG_FLAG:	equ 5	; if 0, no background has been saved yet
PLAYER_BULLET_STRUCT_BG_PTR:	equ 6
PLAYER_BULLET_STRUCT_BG:		equ 8
PLAYER_BULLET_STRUCT_DIRECTION:	equ 9	; PLAYER_BULLET_STRUCT_DIRECTION and PLAYER_BULLET_STRUCT_TIMER share byte, 
										; as no weapon uses both at the same time
PLAYER_BULLET_STRUCT_TIMER:		equ 9	; some bullets only last a certain duration

PLAYER_BULLET_TYPE_NONE:	equ 0
PLAYER_BULLET_TYPE_BULLET:	equ 1
PLAYER_BULLET_TYPE_BULLET_BACKWARDS:	equ 2
PLAYER_BULLET_TYPE_BULLET_FW_UP:	equ 3
PLAYER_BULLET_TYPE_BULLET_FW_DOWN:	equ 4
PLAYER_BULLET_TYPE_LASER:	equ 5
PLAYER_BULLET_TYPE_FLAME:	equ 6
PLAYER_BULLET_TYPE_DIRECTIONAL_BULLET:	equ 7

MAX_PLAYER_SECONDARY_BULLETS:			equ 6
PLAYER_SECONDARY_BULLET_STRUCT_SIZE:	equ 6

PLAYER_SECONDARY_BULLET_STRUCT_TYPE:	equ 0
PLAYER_SECONDARY_BULLET_STRUCT_DAMAGE:	equ 1
PLAYER_SECONDARY_BULLET_STRUCT_X:		equ 2
PLAYER_SECONDARY_BULLET_STRUCT_Y:		equ 3
PLAYER_SECONDARY_BULLET_STRUCT_STATE:	equ 4
PLAYER_SECONDARY_BULLET_STRUCT_SPRITE_IDX:	equ 5


WEAPON_SPRITE_MISSILE:		equ 18*4
WEAPON_SPRITE_DOWN_MISSILE:	equ 19*4
WEAPON_SPRITE_UP_MISSILE:	equ 20*4
WEAPON_SPRITE_TORPEDO:		equ 21*4

; - Sprite-based enemies: ------------------------
MAX_ENEMIES_PER_WAVE:		equ 6
ENEMY_STRUCT_SIZE:			equ 9
ENEMY_WAVE_STRUCT_SIZE:		equ 3+(MAX_ENEMIES_PER_WAVE*2)+1

ENEMY_SPAWN_QUEUE_SIZE:		equ 8
ENEMY_SPAWN_STRUCT_SIZE:	equ 5

ENEMY_SPAWN_STRUCT_TIMER:	equ 0
ENEMY_SPAWN_STRUCT_TYPE:	equ 1
ENEMY_SPAWN_STRUCT_MOVEMENT_TYPE:	equ 2
ENEMY_SPAWN_STRUCT_TILE_X:	equ 3
ENEMY_SPAWN_STRUCT_Y:		equ 4

ENEMY_STRUCT_TYPE:			equ 0	; msb represents if it will drop a power pellet or not
ENEMY_STRUCT_MOVEMENT_TYPE:	equ 1
ENEMY_STRUCT_TILE_X:		equ 2
ENEMY_STRUCT_Y:				equ 3
ENEMY_STRUCT_X:				equ 4
ENEMY_STRUCT_SPRITE_IDX:	equ 5
ENEMY_STRUCT_STATE:			equ 6
ENEMY_STRUCT_TIMER:			equ 7
ENEMY_STRUCT_HP:			equ 8

ENEMY_SPRITE_EXPLOSION:		equ 12*4
ENEMY_SPRITE_TRILO:			equ 27*4
ENEMY_SPRITE_FISH:			equ 29*4
ENEMY_SPRITE_UFO:			equ 32*4
ENEMY_SPRITE_WALKER_LEFT:	equ 36*4
ENEMY_SPRITE_WALKER_RIGHT:	equ 39*4
ENEMY_SPRITE_WALKER_STOP:	equ 42*4
ENEMY_SPRITE_FALLING_ROCK:  equ 43*4
ENEMY_SPRITE_FACE:          equ 47*4

ENEMY_COLOR_TRILO:			equ COLOR_PURPLE
ENEMY_COLOR_FISH:			equ COLOR_DARK_BLUE
ENEMY_COLOR_UFO:			equ COLOR_LIGHT_BLUE
ENEMY_COLOR_WALKER:			equ COLOR_DARK_YELLOW
ENEMY_COLOR_FALLING_ROCK:   equ COLOR_GREY
ENEMY_COLOR_FACE:           equ COLOR_LIGHT_GREEN

ENEMY_EXPLOSION:			equ 1
ENEMY_TRILO:				equ 2
ENEMY_FISH:					equ 3
ENEMY_UFO:					equ 4
ENEMY_WALKER:				equ 5
ENEMY_FALLING_ROCK:         equ 6
ENEMY_FACE:                 equ 7

MOVEMENT_TRILO_H:			equ 0
MOVEMENT_FISH_WAVE:			equ 0
MOVEMENT_FISH_FOLLOW:		equ 1
MOVEMENT_FISH_TOP_FIRE:		equ 2
MOVEMENT_FISH_BOTTOM_FIRE:	equ 3
MOVEMENT_UFO_H:				equ 0
MOVEMENT_UFO_REVERSE_H:		equ 1
MOVEMENT_UFO_GENERATE_TOP:	equ 2
MOVEMENT_UFO_GENERATE_BOT:	equ 3
MOVEMENT_WALKER_LEFT:		equ 0
MOVEMENT_WALKER_RIGHT:		equ 1


; - Tile-based enemies: --------------------------
TILE_ENEMY_STRUCT_SIZE:		equ 11

TILE_ENEMY_STRUCT_TYPE:		equ 0	; msb determines if it is marked for deletion! 
TILE_ENEMY_STRUCT_X:		equ 1
TILE_ENEMY_STRUCT_Y:		equ 2
TILE_ENEMY_STRUCT_WIDTH:	equ 3
TILE_ENEMY_STRUCT_HEIGHT:	equ 4
TILE_ENEMY_STRUCT_STATE:	equ 5
TILE_ENEMY_STRUCT_TIMER:	equ 6
TILE_ENEMY_STRUCT_HP:		equ 7
TILE_ENEMY_STRUCT_PTRL:		equ 8
TILE_ENEMY_STRUCT_PTRH:		equ 9
TILE_ENEMY_STRUCT_CLEAR_TILE:     equ 10    ; the tile to use when deleting this enemy

TILE_ENEMY_G_TURRET_TOP:	equ 1
TILE_ENEMY_R_TURRET_TOP:	equ 2
TILE_ENEMY_G_TURRET_BOTTOM:	equ 3
TILE_ENEMY_R_TURRET_BOTTOM:	equ 4
TILE_ENEMY_MOAI_TOP:		equ 5
TILE_ENEMY_MOAI_BOTTOM:		equ 6
TILE_ENEMY_GROWINGWALL_TOP:		equ 7
TILE_ENEMY_GROWINGWALL_BOTTOM:	equ 8

TILE_ENEMY_GENERATOR_TOP:		equ 9
TILE_ENEMY_GENERATOR_BOTTOM:	equ 10

TILE_ENEMY_WATERDOME:       equ 11
TILE_ENEMY_FALLINGROCKS:    equ 12

TILE_ENEMY_TEMPLESNAKE:     equ 13
TILE_ENEMY_TEMPLECOLUMN:    equ 14


; - Enemy bullets: -------------------------------
ENEMY_BULLET_STRUCT_SIZE:	equ 8

ENEMY_BULLET_STRUCT_TYPE:	equ 0
ENEMY_BULLET_STRUCT_X:		equ 1
ENEMY_BULLET_STRUCT_Y:		equ 2
ENEMY_BULLET_STRUCT_VX:		equ 3
ENEMY_BULLET_STRUCT_VY:		equ 4
ENEMY_BULLET_STATE:			equ 5
ENEMY_BULLET_STRUCT_SPRITE_PTR:		equ 6	; 2 bytes

ENEMY_BULLET_SPRITE_PELLET:				equ 22*4
ENEMY_BULLET_SPRITE_LASER_UP_LEFT:		equ 23*4
ENEMY_BULLET_SPRITE_LASER_DOWN_LEFT:	equ 25*4
ENEMY_BULLET_SPRITE_LASER_LEFT:			equ 35*4

ENEMY_BULLET_PELLET:			equ 1
ENEMY_BULLET_LASER_UP_LEFT:		equ 2
ENEMY_BULLET_LASER_DOWN_LEFT:	equ 3
ENEMY_BULLET_LASER_LEFT:		equ 4


; ------------------------------------------------
MAX_TILE_EXPLOSIONS:		equ 4
TILE_EXPLOSION_STRUCT_SIZE:	equ 21

TILE_EXPLOSION_TIME:		equ 0
TILE_EXPLOSION_BG_BUFFER:	equ 1	; this is of size 4*4
TILE_EXPLOSION_X:			equ 17
TILE_EXPLOSION_Y:			equ 18
TILE_EXPLOSION_PTRL:		equ 19
TILE_EXPLOSION_PTRH:		equ 20


; ------------------------------------------------
MAX_POWER_PELLETS:			equ 8
POWER_PELLET_STRUCT_SIZE:	equ 9

POWER_PELLET_STRUCT_TYPE:	equ 0		; msb determines if it is marked for deletion! 
										; (they are only actually deleted, once they restore their bg)
POWER_PELLET_STRUCT_X:		equ 1
POWER_PELLET_STRUCT_Y:		equ 2
POWER_PELLET_STRUCT_BG_FLAG:	equ 3
POWER_PELLET_STRUCT_PTRL:	equ 4
POWER_PELLET_STRUCT_PTRH:	equ 5
POWER_PELLET_STRUCT_BG:		equ 6	; size 3


; ------------------------------------------------
TURRET_START_OFFSET:        equ 0
TURRET_WITH_DROP_START_OFFSET:  equ 6*3
MOAI_START_OFFSET:			equ 6*6
GENERATOR_START_OFFSET:		equ 6*6
WATERDOME_START_OFFSET:     equ 6*6
SNAKE_START_OFFSET:         equ 6*6
COLUMN_START_OFFSET:        equ 6*6

; ------------------------------------------------
WEAPON_MAX_ENERGY:			equ 12*16

WEAPON_NONE:				equ 0
WEAPON_SPEED:				equ 1
WEAPON_INITIAL_SPEED:		equ 2
WEAPON_TRANSFER:			equ 3
WEAPON_BULLET:				equ 4
WEAPON_TWIN_BULLET:			equ 5
WEAPON_TRIPLE_BULLET:		equ 6
WEAPON_SHIELD:				equ 7
WEAPON_L_TORPEDOES:			equ 8
WEAPON_H_TORPEDOES:			equ 9
WEAPON_UP_MISSILES:			equ 10
WEAPON_DOWN_MISSILES:			equ 11
WEAPON_BIDIRECTIONAL_MISSILES:	equ 12
WEAPON_LASER:				equ 13
WEAPON_TWISTER_LASER:		equ 14
WEAPON_FLAME:				equ 15
WEAPON_BULLET_OPTION:		equ 16
WEAPON_MISSILE_OPTION:		equ 17
WEAPON_DIRECTIONAL_OPTION:	equ 18
WEAPON_LEVEL_UP_START:		equ 19
WEAPON_INIT_WEAPON:			equ 20
WEAPON_PILOTS:				equ 21

N_WEAPONS:					equ 22


; ------------------------------------------------
POLYPHEMUS_FIRST_SPRITE:	equ 64-5
POLYPHEMUS_HEALTH:			equ 32

SCYLLA_FIRST_SPRITE:		equ 64-8
SCYLLA_HEALTH_PHASE1:		equ 72
SCYLLA_HEALTH_PHASE2:		equ 96

CHARYBDIS_FIRST_SPRITE:     equ 64-5
CHARYBDIS_HEALTH:           equ 112
CHARYBDIS_LENGTH:           equ 14

TRITON_FIRST_SPRITE:        equ 64-3
TRITON_HEALTH:              equ 200
