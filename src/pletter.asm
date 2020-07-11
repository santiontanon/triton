;-----------------------------------------------
; pletter v0.5c msx unpacker
; call unpack with hl pointing to some pletter5 data, and de pointing to the destination.
; changes all registers
; code from: https://github.com/uniabis/z80depacker/blob/master/unpletter_180.asm

GETBIT:  MACRO 
  add a,a
  call z,getbit
  ENDM

; unpack_compressed:
pletter_unpack:

  ld a,(hl)
  inc hl

  push hl

  ld bc,-1
  xor 0e0h
  scf
  adc a,a
  rl c
  add a,a
  rl c
  add a,a
  rl c

  ld hl,offsok
  inc c
  jr z,pletter_unpack.mode1
  sla c

  ld hl,mode2+6
  add hl,bc
  add hl,bc
  add hl,bc

pletter_unpack.mode1:
  ex (sp),hl
  pop ix

  jr literal

filbuf:
  ld a,(hl)
  inc hl
  rla
  jr c,getlen

literal:
  ldi
loop:
  add a,a
  jr z,filbuf
  jr nc,literal

getlen:
  GETBIT

  ld bc,1
  jr nc,getlen.lenok
getlen.lus:
  GETBIT
  rl c
  rl b
  ret c
  GETBIT
  jr c,getlen.lus
getlen.lenok:

  push de

  ld e,(hl)
  inc hl
  ld d,0
  bit 7,e
  jr z,offsok
  jp ix

mode6:
  GETBIT
  rl d
mode5:
  GETBIT
  rl d
mode4:
  GETBIT
  rl d
mode3:
  GETBIT
  rl d
mode2:
  GETBIT
  rl d
  GETBIT
  jr nc,offsok
  inc d
  res 7,e
offsok:

  ex (sp),hl
  push hl
  scf
  sbc hl,de
  pop de

  ldir
  ldi
  pop hl
  jr loop

getbit:
  ld a,(hl)
  inc hl
  rla
  ret
