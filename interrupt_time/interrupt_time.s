; Tests interrupt handling time for slow and fast
; CPU. First value is CPU speed (0=slow, 1=fast),
; second is number of cycles taken by interrupt.
; Should take 13 cycles at either speed.
.define REQUIRE_CGB 1

.include "shell.inc"
.include "cpu_speed.s"
.include "timer.s"
.include "apu.s"

; $58: JP $DEC3
; $DEC3: RET
.define sint $DEC3

main:
     call init_timer
     
     ld   d,0
     call test_interrupt
     ld   d,8
     call test_interrupt
     call cpu_fast
     ld   d,0
     call test_interrupt
     ld   d,8
     call test_interrupt
     
     check_crc $C86CC74D
     jp   tests_passed
     
test_interrupt:
     call get_cpu_speed
     call print_a
     call print_d
     
     ld   a,$C9     ; RET
     ld   (sint),a
     
     wreg IE,$08
     wreg IF,$00
     call start_timer
     ei
     ld   a,d
     ld   (IF),a    ; $00 = 0 clocks, $08 = 13 clocks
     di
     call stop_timer
     sub  3+4       ; instruction overhead
     call print_a
     call print_newline
     
     ret

; RST handler that matches the one in my devcart
.bank 0 slot 0
.org $58
     jp   $DEC3
