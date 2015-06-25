; Waits for LCD blanking period
; Preserved: BC, DE, HL
wait_vbl:
     ; Return if off
     lda  LCDC
     rla
     ret  nc
     
     ; Wait for start of vblank
-    lda  LY
     cp   144
     jr   nz,-
     
     ret
