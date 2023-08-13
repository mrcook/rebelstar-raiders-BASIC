; RAIDERS disassembly

; Routine at $C738=51000
; Looks like a helper routine for the developer.
; Copy the SCREEN/ATTR data at $4000 to $A7F8, ready for saving to tape.
C738  ld hl,$4000
C73B  ld de,$A7F8
C73E  ld bc,$1B00
C741  ldir
C743  ret

; Routine at $C744=51012
; Move the loaded SCREEN/ATTR data from $A7F8 to the SCREEN memory at $4000.
C744  ld hl,$A7F8
C747  ld de,$4000
C74A  ld bc,$1B00
C74D  ldir
C74F  ret
