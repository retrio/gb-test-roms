; Verifies corruption pattern for each instruction

.include "oam_bug.inc"

main:
     save_sp
     
     set_test 2,"INC/DEC rp pattern is wrong"
     call begin
     ld   de,$FE00
     inc  de
     call end

     ld   de,$FE00
     dec  de
     call end
     check_crc $EF0C266A

     set_test 3,"POP rp pattern is wrong"
     call begin
     ld   sp,$FEF0
     pop  bc
     restore_sp
     call end
     check_crc $8C62EE7D

     set_test 4,"PUSH rp pattern is wrong"
     call begin
     ld   sp,$FEF0
     push bc
     restore_sp
     call end
     check_crc $B3693CEE

     set_test 5,"LD A,(HL+/-) pattern is wrong"
     call begin
     ld   hl,$FEF0
     ld   a,(hl+)
     call end

     ld   hl,$FEF0
     ld   a,(hl-)
     call end
     check_crc $06BE41A4

     jp   tests_passed

begin:
     call disable_lcd
     call fill_oam
     wreg LCDC,$81
     delay 70224 - 4
     ret

end:
     call disable_lcd
     call cp_oam
     jr   z,+
     call print_oam
     call print_newline
+
     call begin
     ret
