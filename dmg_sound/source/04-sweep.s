; Calc = calculation of new frequency and check for > $7FF
; Update = modification of frequency with new calculated value
.include "shell.inc"
.include "apu.s"

begin:
     call sync_sweep
     wreg NR14,$40
     wreg NR11,-$21
     wreg NR12,$08
     ret

should_be_almost_off:
     lda  NR52
     and  $01
     jp   z,test_failed
     delay_apu 1
should_be_off:
     lda  NR52
     and  $01
     jp   nz,test_failed
     ret
     
main:
     set_test 2,"If shift>0, calculates on trigger"
     call begin
     wreg NR10,$01
     wreg NR13,$FF
     wreg NR14,$C7
     call should_be_off
     call begin
     wreg NR10,$11
     wreg NR13,$FF
     wreg NR14,$C7
     call should_be_off
     
     set_test 3,"If shift=0, doesn't calculate on trigger"
     call begin
     wreg NR10,$10
     wreg NR13,$FF
     wreg NR14,$C7
     delay_apu 1
     call should_be_almost_off
     
     set_test 4,"If period=0, doesn't calculate"
     call begin
     wreg NR10,$00
     wreg NR13,$FF
     wreg NR14,$C7
     delay_apu $20
     call should_be_almost_off
     
     set_test 5,"After updating frequency, calculates a second time"
     call begin
     wreg NR10,$11
     wreg NR13,$00
     wreg NR14,$C5
     delay_apu 1
     call should_be_almost_off
     
     set_test 6,"If calculation>$7FF, disables channel"
     call begin
     wreg NR10,$02
     wreg NR13,$67
     wreg NR14,$C6
     call should_be_off
     
     set_test 7,"If calculation<=$7FF, doesn't disable channel"
     call begin
     wreg NR10,$01
     wreg NR13,$55
     wreg NR14,$C5
     delay_apu $20
     call should_be_almost_off
     
     set_test 8,"If shift=0 and period>0, trigger enables"
     call begin
     wreg NR10,$10
     wreg NR13,$FF
     wreg NR14,$C3
     delay_apu 2
     wreg NR10,$11
     delay_apu 1
     call should_be_almost_off
     
     set_test 9,"If shift>0 and period=0, trigger enables"
     call begin
     wreg NR10,$01
     wreg NR13,$FF
     wreg NR14,$C3
     delay_apu 15
     wreg NR10,$11
     call should_be_almost_off
     
     set_test 10,"If shift=0 and period=0, trigger disables"
     call begin
     wreg NR10,$08
     wreg NR13,$FF
     wreg NR14,$C3
     wreg NR10,$11
     delay_apu $20
     call should_be_almost_off
     
     set_test 11,"If shift=0, doesn't update"
     call begin
     wreg NR10,$10
     wreg NR13,$FF
     wreg NR14,$C3
     delay_apu $20
     call should_be_almost_off
     
     set_test 12,"If period=0, doesn't update"
     call begin
     wreg NR10,$01
     wreg NR13,$00
     wreg NR14,$C5
     delay_apu $20
     call should_be_almost_off
     
     jp   tests_passed
