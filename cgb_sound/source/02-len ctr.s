; Tests basic length counter operation

.include "shell.inc"
.include "test_chan.s"

main:
     test_all_chans
     jp   tests_passed

begin:
     call sync_apu
     delay 2048     ; avoid extra clocking due to quirks
     wchn 4,$40     ; avoid extra clocking due to quirks
     wchn 1,-4      ; length = 4
     wchn 4,$C0     ; trigger, enabling channel
     ret

should_be_on:
     lda  chan_mask
     ld   b,a
     lda  NR52
     and  b
     jp   z,test_failed
     ret

should_be_almost_off:
     call should_be_on
     delay_apu 1
should_be_off:
     lda  chan_mask
     ld   b,a
     lda  NR52
     and  b
     jp   nz,test_failed
     ret

test_chan:
     set_test 2,"Length becoming 0 should clear status"
     call begin
     delay_apu 3
     call should_be_almost_off
     
     set_test 3,"Length can be reloaded at any time"
     call begin
     wchn 1,-10     ; length = 10
     delay_apu 9
     call should_be_almost_off
     
     set_test 4,"Attempting to load length with 0 should load with maximum"
     call begin
     wchn 1,0       ; length = maximum
     lda  chan_maxlen
     dec  a
     call delay_apu_cycles
     call should_be_almost_off
     
     set_test 5,"Trigger shouldn't affect length"
     call begin
     delay_apu 1
     wchn 4,$C0     ; length unaffected
     delay_apu 2
     call should_be_almost_off
     
     set_test 6,"Trigger should treat 0 length as maximum"
     call begin
     delay_apu 4    ; clocks length to 0
     wchn 4,$C0     ; trigger converts 0 to maximum
     lda  chan_maxlen
     dec  a
     call delay_apu_cycles
     call should_be_almost_off
     
     set_test 7,"Trigger with disabled length should convert ","0 length to maximum"
     call begin
     delay_apu 4    ; clocks length to 0
     wchn 4,$00     ; disable length
     wchn 4,$80     ; trigger converts 0 to maximum
     wchn 4,$40     ; enable length
     lda  chan_maxlen
     dec  a
     call delay_apu_cycles
     call should_be_almost_off
     
     set_test 8,"Disabling length shouldn't re-enable channel"
     call begin
     delay_apu 4    ; clocks length to 0
     call should_be_off
     wchn 4,0       ; disable length
     call should_be_off
     
     set_test 9,"Disabling length should stop length clocking"
     call begin
     wchn 4,0       ; disable length
     delay_apu 4    ; length isn't affected
     wchn 4,$40     ; enable length
     delay_apu 3    ; clocks length to 1
     call should_be_almost_off
     
     set_test 10,"Reloading shouldn't re-enable channel"
     call begin
     delay_apu 4    ; clocks length to 0
     call should_be_off
     wchn 1,-2      ; length = 2
     call should_be_off
     
     set_test 11,"Disabled channel should still clock length"
     call begin
     delay_apu 4    ; clocks length to 0, disabling channel
     wchn 1,-8      ; length = 8
     delay_apu 4    ; clocks length to 4
     wchn 4,$C0     ; trigger, enabling channel
     delay_apu 3    ; clocks length to 1
     call should_be_almost_off
          
     set_test 12,"Disabled channel should still convert 0 load to max length"
     call begin
     delay_apu 4    ; clocks length to 0, disabling channel
     wchn 1,0       ; length = maximum
     delay_apu 32   ; clock length 32 times
     wchn 4,$C0
     lda  chan_maxlen
     sub  33
     call delay_apu_cycles
     call should_be_almost_off
     
     set_test 13,"Disabling DAC should disable channel immediately"
     call begin
     delay_apu 2    ; clocks length to 2
     call should_be_on
     wchn 0,$00     ; if wave channel, this disables DAC
     wchn 2,$07     ; if square/noise channel, this disables DAC
     call should_be_off
     
     set_test 14,"Disabled DAC should prevent enable at trigger"
     call begin
     wchn 0,$00     ; if wave channel, this disables DAC
     wchn 2,$07     ; if square/noise channel, this disables DAC
     wchn 4,$80     ; triggers channel but doesn't enable it
     call should_be_off
     
     set_test 15,"Enabling DAC shouldn't re-enable channel"
     wchn 0,$80     ; if wave channel, this enables DAC
     wchn 2,$10     ; if square/noise channel, this enables DAC
     call begin
     delay_apu 2
     call should_be_on
     wchn 0,$00     ; if wave channel, this disables DAC
     wchn 2,$00     ; if square/noise channel, this disables DAC
     call should_be_off
     wchn 0,$80     ; if wave channel, this enables DAC
     wchn 2,$10     ; if square/noise channel, this enables DAC
     call should_be_off
     
     set_test 16,"Volume reaching 0 shouldn't disable channel"
     wchn 2,$11     ; envelope that reaches zero in less than
                    ; 20 length clocks (if wave channel, this just sets
                    ; volume to 0)
     call begin
     wchn 1,-20
     delay_apu 19
     call should_be_almost_off
     
     ret
