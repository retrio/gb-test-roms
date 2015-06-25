; After powering sound off then on, NR12 and NR14 are 0
; and NR44 is unchanged. While powered off, writes to
; NR41 are NOT ignored.

.define REQUIRE_DMG 1
.include "shell.inc"
.include "apu.s"

main:
     call sync_apu
     ld   a,$FF
     call fill_apu_regs
     
     ; Power down for a moment
     wreg NR52,$00
     wreg NR41,-$12
     wreg NR12,$F0
     delay_msec 100
     wreg NR52,$80
     
     set_test 2,"Powering off should clear NR12"
     call sync_apu
     wreg NR14,$80
     lda  NR52
     and  $01
     jp   nz,test_failed
     
     set_test 3,"Powering off should clear NR13"
     call sync_apu
     wreg NR10,$11
     wreg NR12,$08
     wreg NR14,$80
     delay_apu 20
     lda  NR52
     and  $01
     jp   z,test_failed
     
     set_test 4,"Powering off shouldn't affect NR41"
     call sync_apu
     delay_clocks 8192   ; avoids extra length clocking
     wreg NR42,$08
     wreg NR44,$C0
     delay_apu $11
     lda  NR52
     and  $08
     jp   z,test_failed
     delay_apu 1
     lda  NR52
     and  $08
     jp   nz,test_failed
     
     jp   tests_passed
