; Demonstrates exact timing for first scanline

; With LCD off, turning it on synchronizes to beginning
; of first visible scanline

.include "oam_bug.inc"

main:
     set_test 2,"INC DE just before first corruption"
     call begin
     ld   de,$FE00
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 70224-3
     inc  de
     call should_not_corrupt

     set_test 3,"INC DE at first corruption"
     call begin
     ld   de,$FE00
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 70224-2
     inc  de
     call should_corrupt
     
     set_test 4,"INC DE at last corruption"
     call begin
     ld   de,$FE00
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 70224-2+18
     inc  de
     call should_corrupt
     
     set_test 5,"INC DE just after last corruption"
     call begin
     ld   de,$FE00
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 70224-2+19
     inc  de
     call should_not_corrupt
     
     jp   tests_passed

begin:
     call disable_lcd
     call fill_oam
     ret

should_not_corrupt:
     call disable_lcd
     call cp_oam
     jp   nz,test_failed
     ret

should_corrupt:
     call disable_lcd
     call cp_oam
     jp   z,test_failed
     ret
