; Cycle-accurate timer

; TIMA is incremented every 4 cycles. Loops
; check for increment within 3-cycle window,
; so when it occurs outside this, loop is
; exactly synchronized. Loop iterations are
; one more or less than 12 cycles, so they
; will never run more than 4 times.

; Initializes timer
; Preserved: AF, BC, DE, HL
init_timer:
     push af
     di
     lda  IE        ; disable timer interrupt
     and  ~$04
     sta  IE
     wreg TMA,0     ; max period
     wreg TAC,$05   ; 262144 Hz
     
     ; Be sure timer doesn't expire
     ; immediately or take too long
     wreg IF,0
     wreg TIMA,-20
     delay 70
     lda  IF
     and  $04
     jp   nz,test_failed
     lda  IF
     and  $04
     jp   z,test_failed

     pop  af
     ret


; Starts timer
; Preserved: AF, BC, DE, HL
start_timer:
     push af
     
-    xor  a         ; 1
     sta  TIMA      ; 3
     lda  TIMA      ; 3
     or   a         ; 1
     jr   nz,-      ; 3
     
     pop  af
     ret


; Stops timer and determines cycles since
; it was started. A = cycles (0 to 255).
; Preserved: BC, DE, HL
stop_timer:
     push de
     call stop_timer_word
     ld   a,e
     sub  10
     pop  de
     ret


; Same as stop_timer, but with greater range.
; DE = cycles (0 to 1019).
; Preserved: BC, HL
stop_timer_word:
     
     ld   d,0
     
     ; Get main count (TIMA*4)
     lda  TIMA
     sub  5
     add  a
     rl   d
     add  a
     rl   d
     ld   e,a
     
     ; One iteration per remaining cycle
-    xor  a         ; 1
     sta  TIMA      ; 3
     lda  TIMA      ; 3
     dec  de        ; 2
     or   a         ; 1
     jr   nz,-      ; 3
     
     ret
