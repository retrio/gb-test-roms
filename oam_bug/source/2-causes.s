; Things that cause corruption

.include "oam_bug.inc"

main:
     save_sp
     
     set_test 2,"LD DE,$FE00 : INC DE"
     call begin
     ld   de,$FE00
     inc  de
     call end
     
     set_test 3,"LD DE,$FE00 : DEC DE"
     call begin
     ld   de,$FE00
     dec  de
     call end
     
     set_test 4,"LD DE,$FEFF : INC DE"
     call begin
     ld   de,$FEFF
     inc  de
     call end
     
     set_test 5,"LD BC,$FE00 : INC BC"
     call begin
     ld   bc,$FE00
     inc  bc
     call end
     
     set_test 6,"LD HL,$FE00 : INC HL"
     call begin
     ld   hl,$FE00
     inc  hl
     call end
     
     set_test 7,"LD SP,$FE00 : INC SP"
     call begin
     ld   sp,$FE00
     inc  sp
     restore_sp
     call end
     
     set_test 8,"LD SP,$FDFF : POP BC"
     call begin
     ld   sp,$FDFF
     pop  bc
     restore_sp
     call end
     
     set_test 9,"LD SP,$FE00 : PUSH BC"
     call begin
     ld   sp,$FE00
     push bc
     restore_sp
     call end
     
     set_test 10,"LD HL,$FE00 : LD A,(HL+)"
     call begin
     ld   hl,$FE00
     ld   a,(hl+)
     restore_sp
     call end
     
     set_test 11,"LD HL,$FE00 : LD A,(HL-)"
     call begin
     ld   hl,$FE00
     ld   a,(hl-)
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
     jp   z,test_failed
     ret
