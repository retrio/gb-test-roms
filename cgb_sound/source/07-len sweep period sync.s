; Tests length and sweep periods, and synchronization between the two
.include "shell.inc"
.include "apu.s"

test_timing:
     ; Time how long until next length clock
-    inc  de
     ld   a,(NR52)
     and  $01
     jr   nz,-
     
     ;call     print_de
     
     ; Error if not in 0...4 range
     ld   a,d
     cp   0
     jp   nz,test_failed
     ld   a,e
     cp   5
     jp   nc,test_failed
     ret

main:
     
     set_test 2,"Length period is wrong"
     call sync_apu
     wreg NR14,$40  ; avoids extra length clock
     wreg NR11,$3F  ; length = $01
     wreg NR12,$08  ; silent without disabling channel
     wreg NR14,$C0  ; start length
     ld   de,-$170
     call test_timing
     
     set_test 3,"Sweep period is wrong"
     call sync_sweep
     wreg NR10,$10  ; sweep period = 1
     wreg NR12,$08  ; silent without disabling channel
     wreg NR13,$FF  ; max freq
     wreg NR14,$87  ; start
     ld   de,-$2E4
     call test_timing
     
     set_test 4,"Sweep clock is synchronized with length"
     call sync_sweep
     wreg NR14,$40  ; avoids extra length clock
     wreg NR11,$3F  ; length = $01
     wreg NR12,$08  ; silent without disabling channel
     wreg NR14,$C0  ; start length
     ld   de,-$170
     call test_timing
     
     set_test 5,"Powering up APU MODs next frame time with 8192"
     call sync_apu
     ld   de,-$16F
     call test_power
     
     call sync_apu
     ld   de,-$B5
     call test_power_off
     
     call sync_apu
     delay_clocks 8192
     ld   de,-$B5
     call test_power
     
     call sync_apu
     delay_clocks 8192
     ld   de,-$B5
     call test_power_off
     
     call sync_apu
     ld   de,-$B5
     wreg NR52,$00  ; power off
     delay_clocks 8192
     call test_power
     
     set_test 6,"Powering up APU resets 128 Hz sweep divider"
     call sync_sweep
     ld   de,-$229
     call test_power2
     
     call sync_sweep
     delay_apu 1
     ld   de,-$229
     call test_power2
     
     jp   tests_passed

test_power_off:
     wreg NR52,$00  ; power off
test_power:
     wreg NR52,$80  ; power on
     wreg NR14,$40
     wreg NR11,-1   ; length = 1
     wreg NR12,8
     wreg NR14,$C0
     jp   test_timing

test_power2:
     wreg NR52,$00  ; power off
     wreg NR52,$80  ; power on
     wreg NR10,$11
     wreg NR12,8
     wreg NR13,$00
     wreg NR14,$84
     jp   test_timing
