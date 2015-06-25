; Verifies corruption at timing edges:
; * Beginning of first scanline, and 18 cycles later
; * Beginning of second scanline
; * End of last scanline

.include "oam_bug.inc"

main:
     set_test 2,"Should corrupt at beginning of first scanline"
     call begin
     call end
     
     set_test 3,"Should corrupt at +18 of first scanline"
     call begin
     delay 18
     call end
     
     set_test 4,"Should corrupt at beginning of second scanline"
     call begin
     delay 114
     call end
     
     set_test 5,"Should corrupt at +18 of last scanline"
     call begin
     delay 114*143+18
     call end
     
     jp   tests_passed

begin:
     call disable_lcd
     call fill_oam
     wreg LCDC,$81
     delay 70224 - 15
     ret

end:
     ld   de,$FE00
     inc  de
     call disable_lcd
     call cp_oam
     jp   z,test_failed
     ret
