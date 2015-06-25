; Verifies LCD timing when turning on. Necessary for
; timing tests to work right.

; With LCD off, turning it on synchronizes to beginning
; of first visible scanline

.include "oam_bug.inc"

main:
     set_test 2,"Turning LCD on starts too late in scanline"
     call disable_lcd
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 109
     ldh  a,(LY-$FF00)   ; just before LY increments
     cp   0
     jp   nz,test_failed
     
     set_test 3,"Turning LCD on starts too early in scanline"
     call disable_lcd
     ld   a,$81
     ldh  (LCDC-$FF00),a ; LCD on
     delay 110
     ldh  a,(LY-$FF00)   ; just after LY increments
     cp   1
     jp   nz,test_failed
     
     jp   tests_passed
