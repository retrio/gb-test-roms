; Calc = calculation of new frequency and check for > $7FF
; Update = modification of frequency with new calculated value
.include "shell.inc"
.include "apu.s"

begin:
     call sync_sweep
     wreg NR14,$40
     wreg NR11,-$20
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
     set_test 2,"Timer treats period 0 as 8"
     call begin
     wreg NR10,$11
     wreg NR13,$00
     wreg NR14,$C2
     delay_apu 1
     wreg NR10,$01  ; sweep enabled
     delay_apu 3
     wreg NR10,$11  ; non-zero period so calc will occur when timer reloads
     delay_apu $11
     call should_be_almost_off
     
     set_test 3,"Makes private copy of frequency on trigger"
     call begin
     wreg NR10,$12
     wreg NR13,$04
     wreg NR14,$80
     wreg NR13,$00
     delay_apu $39
     call should_be_almost_off
     
     set_test 4,"Exiting negate mode after calculation disables channel"
     call begin
     wreg NR10,$09  ; since shift > 0, calculates sweep value at init
     wreg NR13,$00
     wreg NR14,$C0
     delay_apu 2
     wreg NR10,$10  ; neg->pos, so disables channel
     call should_be_off
     
     set_test 5,"Ending negate after it maybe changed freq disables chan"
     call begin
     wreg NR10,$10  ; enable sweep
     wreg NR13,$00
     wreg NR14,$C0
     delay_apu 2
     wreg NR10,$18  ; negate mode
     delay_apu 2
     wreg NR10,$10  ; neg->pos, so disables channel
     call should_be_off
     
     set_test 6,"Ending negate mode any other way doesn't disable channel"
     call begin
     wreg NR10,$1F  ; use negate mode once
     wreg NR14,$C0
     delay_apu 2
     wreg NR10,$18  ; since period > 0, doesn't calculate at init
     wreg NR13,$00
     wreg NR14,$C0
     delay_apu 1    ; no sweep clock here
     wreg NR10,$10  ; pos mode before neg mode ever used
     delay_apu 1    ; sweep clock occurs here
     wreg NR10,$0F  ; now let neg mode be seen once, but period = 0 so no calculation is made
     delay_apu 2    ; sweep clock occurs here
     wreg NR10,$10  ; doesn't affect channel
     delay_apu 2    ; sweep clock occurs here
     wreg NR10,$1F  ; let neg mode get used
     delay_apu 18
     wreg NR10,$79  ; period and shift can be changed without channel disabling
     delay_apu 5
     call should_be_almost_off
     
     set_test 7,"Subtract mode uses two's complement"
     call begin
     delay 2048      ; avoids extra length clocking on CGB-02
     wreg NR10,$1C
     wreg NR13,$B0
     wreg NR14,$85
     delay_apu 2
     wreg NR10,$01
     wreg NR14,$C5
     delay_apu $1F
     call should_be_almost_off
     
     set_test 8,"Subtract mode uses two's complement (upper bound)"
     call begin
     wreg NR10,$1C
     wreg NR13,$B1
     wreg NR14,$85
     delay_apu 2
     wreg NR10,$01
     wreg NR14,$C5
     call should_be_off
     
     set_test 9,"Update channel frequency only when period is reloaded"
     call begin
     wreg NR10,$74
     wreg NR13,$06
     wreg NR14,$85
     delay_apu 14 ; just reloaded
     wreg NR13,$06
     delay_apu 13 ; if 14, fails
     wreg NR10,$11
     wreg NR14,$85  ; just before next reload, so freq is still $506
     call should_be_almost_off
     
     jp   tests_passed
