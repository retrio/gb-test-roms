; Writes to wave RAM while playing

.define REQUIRE_DMG 1
;.define REQUIRE_CGB 1
.include "shell.inc"
.include "apu.s"

main:
     loop_n_times test,69
     
     ; CGB behaves erratically, so DMG-only for now
     check_crc_dmg_cgb $3B4538A9,$2B27544E
     jp   tests_passed
     
test:
     add  $99
     ld   b,a
     
     ; Reload wave and have its first
     ; sample read occur 2 clocks earlier
     ; each loop iteration
     ld   hl,wave
     call load_wave
     wreg NR30,$80  ; enable
     wreg NR32,$00  ; silent
     ld   a,b
     sta  NR33      ; period
     wreg NR34,$87  ; start
     
     ; Write to wave
     wreg NR33,-2   ; period = 4
     delay_clocks 168
     wreg WAVE,$F7
     
     ; Print wave RAM
     wreg NR30,0
     delay 1000
     ld   hl,WAVE
-    ld   a,(hl+)
     call print_a
     bit  6,l
     jr   z,-
     call print_newline
     
     ret

wave:
     .byte $00,$11,$22,$33,$44,$55,$66,$77
     .byte $88,$99,$AA,$BB,$CC,$DD,$EE,$FF
