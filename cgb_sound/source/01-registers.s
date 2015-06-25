; - APU registers always have some bits set when read back.
; - Wave memory can be read back freely.
; - When powered off, registers are cleared, except high bit of NR52.
; - While off, register writes are ignored, but not reads.
; - Wave RAM is always readable and writable, and unaffected by power.

.include "shell.inc"
.include "apu.s"

main:
     set_test 2,"NR10-NR51 and wave RAM write/read"
     ld   d,0
-    call test_rw
     inc  d
     jr   nz,-
     
     set_test 3,"NR52 write/read"
     wreg NR52,$00
     lda  NR52
     cp   $70
     jp   nz,test_failed
     wreg NR52,$FF
     lda  NR52
     cp   $F0
     jp   nz,test_failed
     
     set_test 4,"Powering APU shouldn't affect wave"
     ld   a,$37
     call fill_wave
     wreg NR52,$00
     
     ; Verify that wave RAM is unchanged
     ld   hl,WAVE
-    ld   a,(hl+)
     cp   $37
     jp   nz,test_failed
     ld   a,l
     cp   $40
     jr   nz,-
     wreg NR52,$80 ; on
     
     set_test 5,"Powering APU off should write 0 to all regs"
     ld   a,$FF
     call fill_apu_regs
     wreg NR52,$00
     wreg NR52,$80
     call regs_should_be_clear
     
     set_test 6,"When off, should ignore writes to registers"
     wreg NR52,$00
     ld   a,$FF
     call fill_apu_regs
     wreg NR52,$80
     call regs_should_be_clear
     wreg NR52,$80

     set_test 7,"When off, should allow normal register reads"
     wreg NR52,$00
     call regs_should_be_clear
     wreg NR52,$80

     jp   tests_passed

regs_should_be_clear:
     ld   bc,masks
     ld   hl,NR10
-    ld   a,(bc)
     cp   (hl)
     jp   nz,test_failed
     inc  bc
     inc  l
     ld   a,l
     cp   <NR52
     jr   nz,-
     ret

test_rw:
     ld   bc,masks
     ld   hl,NR10
-    ; Skip NR52
     ld   a,l
     cp   <NR52
     jr   z,+
     
     ; A = value that should be read back
     ld   a,(bc)
     or   d
     
     ; Write then read back and compare
     ld   (hl),d
     cp   (hl)
     jp   nz,test_failed
     
+    ; Mute channels
     wreg NR51,0
     
     ; Disable wave, in case it just got enabled
     ; while testing register
     wreg NR30,0
     
     inc  bc
     inc  l
     ld   a,l
     cp   <WAVE+$10
     jr   nz,-
     ret
     
; Registers are ORed with this when reading
masks:
     .byte $80,$3F,$00,$FF,$BF ; NR10-NR15
     .byte $FF,$3F,$00,$FF,$BF ; NR20-NR25
     .byte $7F,$FF,$9F,$FF,$BF ; NR30-NR35
     .byte $FF,$FF,$00,$00,$BF ; NR40-NR45
     .byte $00,$00,$70         ; NR50-NR52
     .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
     .byte $00,$00,$00,$00,$00,$00,$00,$00 ; Wave RAM
     .byte $00,$00,$00,$00,$00,$00,$00,$00
