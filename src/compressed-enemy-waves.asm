    include "constants.asm"

    org #0000

wave_types:
    ; 16 bytes: enemy type, movement pattern, spawn interval, (x1,y1), ... (x6, y6), #ff
    ; all times are in multiples of 16 game frames
    ; wave type 1: 4 trilobites in a sequence from the top
    db ENEMY_TRILO, MOVEMENT_TRILO_H, 3
    db 34,48, 34,48, 34,48, 34,48, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 2: 4 trilobites in a sequence from the bottom
    db ENEMY_TRILO, MOVEMENT_TRILO_H, 3
    db 34,104, 34,104, 34,104, 34,104, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 3: 4 trilobites at once vertically
    db ENEMY_TRILO, MOVEMENT_TRILO_H, 0
    db 34,32, 34,64, 34,96, 34,128, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 4: 6 waving fish
    db ENEMY_FISH, MOVEMENT_FISH_WAVE, 1
    db 34,64, 34,64, 34,64, 34,64, 34,64, 34,64
    db #ff
    ; wave type 5: 4 following fish
    db ENEMY_FISH, MOVEMENT_FISH_FOLLOW, 2
    db 34,64, 34,64, 34,64, 34,64, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 6: 4 following fish (2 up, 2 down)
    db ENEMY_FISH, MOVEMENT_FISH_FOLLOW, 2
    db 34,40, 34,120, 34,40, 34,120, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 7: 4 fish coming briefly from the top and firing
    db ENEMY_FISH, MOVEMENT_FISH_TOP_FIRE, 1
    db 34,-32, 34,-32, 34,-32, 34,-32, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 8: 4 ufo moving horizontally (top)
    db ENEMY_UFO, MOVEMENT_UFO_H, 2
    db 34,40, 34,40, 34,40, 34,40, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 9: 4 ufo moving horizontally (bottom)
    db ENEMY_UFO, MOVEMENT_UFO_H, 2
    db 34,112, 34,112, 34,112, 34,112, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 10: 4 ufo moving horizontally reverse (top)
    db ENEMY_UFO, MOVEMENT_UFO_REVERSE_H, 4
    db 0,32, 0,32, 0,32, 0,32, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 11: 4 ufo moving horizontally reverse (bottom)
    db ENEMY_UFO, MOVEMENT_UFO_REVERSE_H, 4
    db 0,128, 0,128, 0,128, 0,128, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 12: 4 trilobites in a sequence from the top (1 tile higher, for water)
    db ENEMY_TRILO, MOVEMENT_TRILO_H, 3
    db 34,40, 34,40, 34,40, 34,40, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 13: 4 fish coming briefly from the bottom and firing
    db ENEMY_FISH, MOVEMENT_FISH_BOTTOM_FIRE, 1
    db 34,192, 34,192, 34,192, 34,192, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 14: 2 walkers coming from the right
    db ENEMY_WALKER, MOVEMENT_WALKER_LEFT, 4
    db 34,144, 34,144, #ff,#ff, #ff,#ff, #ff,#ff, #ff,#ff
    db #ff
    ; wave type 15: 2 walkers coming from the left
    db ENEMY_WALKER, MOVEMENT_WALKER_RIGHT, 4
    db 0,144, 0,144, #ff,#ff, #ff,#ff, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 16: 6 ufo moving horizontally reverse (3 bottom, 3 top) (used in Polyphemus)
    db ENEMY_UFO, MOVEMENT_UFO_REVERSE_H, 2
    db 0,128, 0,32, 0,128, 0,32, 0,128, 0,32
    db #ff

    ; wave type 17: 1 face coming from the front
    db ENEMY_FACE, 0, 1
    db 34,80, #ff,#ff, #ff,#ff, #ff,#ff, #ff,#ff, #ff,#ff
    db #ff

    ; wave type 18: 4 trilobites in a sequence from the middle (for temple)
    db ENEMY_TRILO, MOVEMENT_TRILO_H, 3
    db 34,80, 34,80, 34,80, 34,80, #ff,#ff, #ff,#ff
    db #ff
