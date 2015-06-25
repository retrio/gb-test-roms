; Tests timing of accesses made by
; memory read-modify-write instructions

.include "shell.inc"
.include "tima_64.s"

instructions:
     ; last values are read/write times
     .byte $35,$00,$00,2,3 ; DEC  (HL)
     .byte $34,$00,$00,2,3 ; INC  (HL)
     .byte $CB,$06,$00,3,4 ; RLC  (HL)
     .byte $CB,$0E,$00,3,4 ; RRC  (HL)
     .byte $CB,$16,$00,3,4 ; RL   (HL)
     .byte $CB,$1E,$00,3,4 ; RR   (HL)
     .byte $CB,$26,$00,3,4 ; SLA  (HL)
     .byte $CB,$2E,$00,3,4 ; SRA  (HL)
     .byte $CB,$36,$00,3,4 ; SWAP (HL)
     .byte $CB,$3E,$00,3,4 ; SRL  (HL)
     .byte $CB,$86,$00,3,4 ; RES  0,(HL)
     .byte $CB,$8E,$00,3,4 ; RES  1,(HL)
     .byte $CB,$96,$00,3,4 ; RES  2,(HL)
     .byte $CB,$9E,$00,3,4 ; RES  3,(HL)
     .byte $CB,$A6,$00,3,4 ; RES  4,(HL)
     .byte $CB,$AE,$00,3,4 ; RES  5,(HL)
     .byte $CB,$B6,$00,3,4 ; RES  6,(HL)
     .byte $CB,$BE,$00,3,4 ; RES  7,(HL)
     .byte $CB,$C6,$00,3,4 ; SET  0,(HL)
     .byte $CB,$CE,$00,3,4 ; SET  1,(HL)
     .byte $CB,$D6,$00,3,4 ; SET  2,(HL)
     .byte $CB,$DE,$00,3,4 ; SET  3,(HL)
     .byte $CB,$E6,$00,3,4 ; SET  4,(HL)
     .byte $CB,$EE,$00,3,4 ; SET  5,(HL)
     .byte $CB,$F6,$00,3,4 ; SET  6,(HL)
     .byte $CB,$FE,$00,3,4 ; SET  7,(HL)
instructions_end:

main:
     call init_tima_64
     set_test 0
     
     ; Test instructions
     ld   hl,instructions
-    call @test_instr
     inc  hl
     ld   a,l
     cp   <instructions_end
     jr   nz,-
     
     jp   tests_done

@test_instr:
     call @time_instr
     ld   a,d
     cp   (hl)
     inc  hl
     jr   nz,@print_failed
     ld   a,e
     cp   (hl)
     ret  z
@print_failed:
     push hl
     ld   c,(hl)
     dec  hl
     ld   b,(hl)
     dec  hl
     dec  hl
     dec  hl
     ldi  a,(hl)
     cp   $CB
     jr   nz,+
     call print_a
     ld   a,(hl)
+    call print_hex
     print_str ":"
     ld   a,d
     call print_dec
     print_str "/"
     ld   a,e
     call print_dec
     print_str "-"
     ld   a,b
     call print_dec
     print_str "/"
     ld   a,c
     call print_dec
     call print_newline
     pop  hl
     set_test 1
     ret

; Times instruction
; HL -> 3-byte instruction
; HL <- HL + 3
@time_instr:
     ; Copy instr
     ld   a,(hl+)
     ld   (instr+0),a
     ld   a,(hl+)
     ld   (instr+1),a
     ld   a,(hl+)
     ld   (instr+2),a
     push hl
     
     ; Find result when access doesn't occur
     ld   b,0
     call @time_access
     
     ; Find first access
     call @find_next_access
     ld   d,b
     
     ; Find second access
     call @find_next_access
     ld   e,b
     
     pop  hl
     ret

; A -> current timer result
; B -> starting clock
; B <- clock next access occurs on
; A <- new timer result
@find_next_access:
     ld   c,a
-    call @time_access
     cp   c
     ret  nz
     inc  b
     ld   a,b
     cp   10
     jr   c,-
     
     ; Couldn't find time, so return 0/0
     ld   a,c
     ld   b,0
     ld   d,b
     ret
     
; Tests for access
; B -> which cycle to test
; A <- timer value after test
@time_access:
     call sync_tima_64
     ld   hl,tima_64
     ld   (hl),$7F
     ld   a,17
     sub  b
     call delay_a_20_cycles
     xor  a    ; clear flags
instr:
     nop
     nop
     nop
     delay 32
     ld   a,(tima_64)
     ret
