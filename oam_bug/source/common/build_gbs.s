; Build as GBS music file

.memoryMap
     defaultSlot 0
     slot 0 $2000 size $2000
     slot 1 $C000 size $2000
.endMe

.romBankSize $2000
.romBanks 2

.define RST_OFFSET $70

.ifndef GBS_TMA
     .define GBS_TMA 0
.endif

.ifndef GBS_TAC
     .define GBS_TAC 0
.endif

;;;; GBS music file header

.ifndef CUSTOM_HEADER
     .byte "GBS"
     .byte 1,1,1    ; vers, song count, first song
     .word load_addr, reset, gbs_play_, std_stack
     .byte GBS_TMA,GBS_TAC         ; timer
.endif
     .org $10
     .ds $60,0
load_addr:
     .org RST_OFFSET+$70 ; space for RST vectors
     .ds $148-RST_OFFSET-$70,0
     .org $150 ; wla insists on generating GB header

gbs_play_:
     jp   gbs_play  ; GBS spec disallows having gbs_play in RAM

;;;; Shell

.include "shell.s"

.define gbs_idle    nv_ram
.redefine nv_ram    nv_ram+2

init_runtime:
     ; Identify as DMG hardware
     ld   a,$01
     ld   (gb_id),a
     
     ; Save return address
     pop  hl
     ld   a,l
     ld   (gbs_idle),a
     ld   a,h
     ld   (gbs_idle+1),a
     
     ; Delay 1/4 second to give time
     ; for GBS player to interrupt with
     ; play, if it's going to do so
     delay_msec 250
     
.ifndef CUSTOM_PLAY
gbs_play:
.endif
     ; Get return address
     ld   a,(gbs_idle)
     ld   l,a
     ld   a,(gbs_idle+1)
     ld   h,a
     
     ; If zero, then play interrupted init
     ; call, or another play call, and we
     ; can't run the program properly.
     or   l
     jp   z,internal_error
     
     setw gbs_idle,0
     jp   hl


; Reports A in binary as high and low tones, with
; leading low tone for reference. Omits leading
; zeroes.
; Preserved: AF, BC, DE, HL
play_byte:
     push af
     push hl
     
     ; HL = (A << 1) | 1
     scf
     rla
     ld   l,a
     ld   h,0
     rl   h
     
     ; Shift left until next-to-top bit is 1
-    add  hl,hl
     bit  6,h
     jr   z,-
     
     ; Reset sound
     delay_msec 400
     wreg NR52,0    ; sound off
     wreg NR52,$80  ; sound on
     wreg NR51,$FF  ; mono
     wreg NR50,$77  ; volume
     
-    add  hl,hl

     ; Low or high pitch based on bit shifted out
     ; of HL
     ld   a,0
     jr   nc,+
     ld   a,$FF
+    sta  NR23
     
     ; Play short tone
     wreg NR21,$A0
     wreg NR22,$F0
     wreg NR24,$86
     delay_msec 75
     wreg NR22,0
     wreg NR23,$F8
     wreg NR24,$87
     delay_msec 200
     
     ; Loop until HL = $8000
     ld   a,h
     xor  $80
     or   l
     jr   nz,-
     
     pop  hl
     pop  af
     ret

.ends
