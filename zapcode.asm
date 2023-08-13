; ZAPCODE disassembly
;
; Some helper routines for updating the screen/attrs and a SFX generator.

; Address 65041
FE11  nop

; Load screen pixels (address 65042)
FE12  ld hl,$4000
FE15  ld bc,$1800
FE18  ld d,-1
FE1A  ld a,d
FE1B  sub (hl)
FE1C  ld (hl),a
FE1D  inc hl
FE1E  dec bc
FE1F  ld a,b
FE20  or c
FE21  jr nz,$FE1A
FE23  ret

; Load screen attributes (address 65060)
FE24  ld hl,$5AFF
FE27  ld a,($5B00)
FE2A  ld c,24
FE2C  ld b,31
FE2E  dec hl
FE2F  ld e,(hl)
FE30  inc hl
FE31  ld (hl),e
FE32  dec hl
FE33  djnz $FE2E
FE35  ld (hl),a
FE36  dec hl
FE37  dec c
FE38  jr nz,$FE2C
FE3A  ret

; Load screen pixels (address 65083)
FE3B  ld hl,$4000
FE3E  ld c,-64
FE40  ld b,32
FE42  or a
FE43  rr (hl)
FE45  inc hl
FE46  djnz $FE43
FE48  dec c
FE49  jr nz,$FE40
FE4B  ret

; Load screen attributes (address 65100)
FE4C  ld hl,$5B00
FE4F  ld de,-495
FE52  ld bc,$1B00
FE55  lddr
FE57  ret

; Load screen attributes (address 65112)
FE58  ld hl,-495
FE5B  ld de,$5B00
FE5E  ld bc,$1B00
FE61  lddr
FE63  ret

FE64  nop
FE65  nop
FE66  nop
FE67  nop
FE68  nop
FE69  nop
FE6A  nop
FE6B  nop
FE6C  nop
FE6D  nop
FE6E  nop

; Possibly the SFX routine (address 65135)
FE6F  ld de,($FF51)
FE73  ld hl,($FF53)
FE76  push de
FE77  push hl
FE78  push de
FE79  push hl
FE7A  ld a,($FF57)
FE7D  exx
FE7E  ld b,a
FE7F  exx
FE80  call $FEDD
FE83  push af
FE84  ld b,a
FE85  inc b
FE86  ld a,(hl)
FE87  rlca
FE88  djnz $FE87
FE8A  and $01
FE8C  jr nz,$FEAB
FE8E  pop af
FE8F  call $FF0D
FE92  pop hl
FE93  pop de
FE94  ld bc,($FF55)
FE98  push bc
FE99  ex de,hl
FE9A  call $FEFC
FE9D  pop bc
FE9E  ld c,b
FE9F  push hl
FEA0  ex de,hl
FEA1  call $FEFC
FEA4  push hl
FEA5  exx
FEA6  djnz $FE7F
FEA8  exx
FEA9  jr $FEAC
FEAB  pop af
FEAC  pop hl
FEAD  pop de
FEAE  exx
FEAF  ld a,($FF57)
FEB2  sub b
FEB3  ld b,a
FEB4  exx
FEB5  pop hl
FEB6  pop de
FEB7  push hl
FEB8  call $FEDD
FEBB  call $FF0D
FEBE  pop hl
FEBF  ld bc,($FF55)
FEC3  push bc
FEC4  ex de,hl
FEC5  call $FEFC
FEC8  pop bc
FEC9  ld c,b
FECA  push hl
FECB  ex de,hl
FECC  call $FEFC
FECF  push hl
FED0  exx
FED1  djnz $FEB4
FED3  exx
FED4  pop hl
FED5  ld ($FF53),hl
FED8  pop hl
FED9  ld ($FF51),hl
FEDC  ret

FEDD  ld a,-81
FEDF  sub h
FEE0  ld b,a
FEE1  ld c,d
FEE2  and a
FEE3  rra
FEE4  scf
FEE5  rra
FEE6  and a
FEE7  rra
FEE8  xor b
FEE9  and $F8
FEEB  xor b
FEEC  ld h,a
FEED  ld a,c
FEEE  rlca
FEEF  rlca
FEF0  rlca
FEF1  xor b
FEF2  and $C7
FEF4  xor b
FEF5  rlca
FEF6  rlca
FEF7  ld l,a
FEF8  ld a,c
FEF9  and $07
FEFB  ret

FEFC  bit 7,c
FEFE  jr z,$FF06
FF00  ld b,-1
FF02  dec hl
FF03  dec hl
FF04  jr $FF0A
FF06  ld b,0
FF08  inc hl
FF09  inc hl
FF0A  add hl,bc
FF0B  add hl,bc
FF0C  ret

FF0D  ld b,a
FF0E  inc b
FF0F  xor a
FF10  scf
FF11  rra
FF12  djnz $FF11
FF14  xor (hl)
FF15  ld (hl),a
FF16  di
FF17  exx
FF18  push hl
FF19  xor a
FF1A  ld hl,$08FF
FF1D  rl l
FF1F  rla
FF20  sub b
FF21  jr nc,$FF24
FF23  add a,b
FF24  dec h
FF25  jr nz,$FF1D
FF27  ld a,l
FF28  rla
FF29  cpl
FF2A  ld l,a
FF2B  ld a,($5C48)
FF2E  and $38
FF30  rra
FF31  rra
FF32  rra
FF33  ld h,1
FF35  ld e,l
FF36  xor $18
FF38  out ($FE),a
FF3A  ld d,6
FF3C  ld c,b
FF3D  dec c
FF3E  jr nz,$FF3D
FF40  dec d
FF41  jr nz,$FF3C
FF43  dec e
FF44  jr nz,$FF36
FF46  dec h
FF47  jr nz,$FF35
FF49  and $E7
FF4B  out ($FE),a
FF4D  pop hl
FF4E  exx
FF4F  ei
FF50  ret

; SFX data (address 65361)
FF51 db $00,$4B,$F8,$4C,$7F,$03,$50,$FF,$81,$81
