; Things that don't cause corruption

.include "oam_bug.inc"

main:
     save_sp
     
     set_test 2,"When LCD is off"
     call disable_lcd
     call fill_oam
     ld   bc,2 * 70224/11 ; a couple of frames
     ld   de,$FE00
-    inc  de
     dec  bc
     dec  de
     ld   a,b
     or   c
     jr   nz,-
     call end
     
     set_test 3,"LD DE,$FF00 : DEC DE"
     call begin
     ld   de,$FF00
     dec  de
     call end
     
     set_test 4,"LD DE,$FDFF : INC DE"
     call begin
     ld   de,$FDFF
     inc  de
     call end
     
     set_test 5,"LD DE,$7E00 : INC DE"
     call begin
     ld   de,$7E00
     inc  de
     call end
     
     set_test 6,"LD DE,$FE00 : INC E"
     call begin
     ld   de,$FE00
     inc  e
     call end
     
     set_test 7,"LD SP,$FDFE : POP BC"
     call begin
     ld   sp,$FDFE
     pop  bc
     restore_sp
     call end
     
     set_test 8,"LD SP,$FE00 : LD HL,SP+1"
     call begin
     ld   sp,$FE00
     ld   hl,sp+1
     restore_sp
     call end
     
     set_test 9,"LD HL,$FE00 : LD BC,$0001 : ADD HL,BC"
     call begin
     ld   hl,$FE00
     ld   bc,$0001
     add  hl,bc
     call end
     
     set_test 10,"LD SP,$FE00 : ADD SP,1"
     call begin
     ld   sp,$FE00
     add  sp,1
     restore_sp
     call end
     
     jp   tests_passed

begin:
     call disable_lcd
     call fill_oam
     wreg LCDC,$81
     delay 70224 - 6
     ret

end:
     call disable_lcd
     call cp_oam
     jp   nz,test_failed
     ret
