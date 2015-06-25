; Verifies no corruption when done at "safe" times

.include "oam_bug.inc"

main:
     call disable_lcd
     call fill_oam
     
     call test
     
     call disable_lcd
     call cp_oam
     
     call print_oam
     check_crc $7BB4F198
     jp   tests_passed

test:
     ld   de,$FE00
     wreg LCDC,$81
     
     ; Have first INC DE at scanline 0 beginning
     delay 70224 - 7
     
     ; Run for several frames
     ld   h,10
@loop:
     
     ; Try to trigger just before and just after
     ; window where corruption occurs, for every
     ; scanline
     ld   b,144
-    inc  de
     delay 18
     dec  de
     delay 114-22-4
     dec  b
     jr   nz,-
     
     ; Try to trigger constantly during vblank
     ld   b,10
     jr   +
--   delay 13
+    ld   c,12
-    inc  de
     dec  c
     dec  de
     jr   nz,-
     dec  b
     jr   nz,--
     
     delay 4
     
     dec  h
     jr   nz,@loop
     
     ret
