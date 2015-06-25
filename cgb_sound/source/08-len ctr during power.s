; On CGB, length counters are reset when powered up.
; On DMG, they are unaffected, and not clocked.

;.define REQUIRE_DMG 1
;.define REQUIRE_CGB 1
.include "shell.inc"
.include "apu.s"

enable_len_ctrs:
     wreg NR22,8
     wreg NR24,$C0
     wreg NR12,8
     wreg NR14,$C0
     wreg NR30,$80
     wreg NR34,$C0
     wreg NR42,8
     wreg NR44,$C0
     ret

main:
     call sync_apu
     
     ld   a,0
     call fill_apu_regs
     
     ; Load length counters
     wreg NR41,-$33
     wreg NR31,-$44
     wreg NR11,-$11
     wreg NR21,-$22
     
     delay_clocks 8192
     call enable_len_ctrs
     
     ; Power down. Comment out to see what would
     ; happen if length counters did run.
     wreg NR52,$00
     
     ; Try to enable length counters
     call enable_len_ctrs
     
     ; Give plenty of time for them to be clocked
     delay_msec 250
     
     ; Power back on and wait a bit longer
     wreg NR52,$80
     ;call enable_len_ctrs ; can't do this here
     delay_clocks 2048
     
     ; Get values from length counters
     wreg NR22,8
     wreg NR24,$C0
     ld   a,$02
     call get_len_a
     push af
     
     wreg NR12,8
     wreg NR14,$C0
     ld   a,$01
     call get_len_a
     push af
     
     wreg NR30,$80
     wreg NR34,$C0
     ld   a,$04
     call get_len_a
     push af
     
     wreg NR42,8
     wreg NR44,$C0
     ld   a,$08
     call get_len_a
     
     ; Print them
     call print_a
     pop  af
     call print_a
     pop  af
     call print_a
     pop  af
     call print_a
     
     check_crc_dmg_cgb $32F0CFBB,$3CF589B4
     jp tests_passed
