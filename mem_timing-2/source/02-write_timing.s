; Tests timing of accesses made by
; memory write instructions

.include "shell.inc"
.include "tima_64.s"

instructions:
     ; last value is time of write
     .byte $36,$FF,$00,3 ; LD   (HL),n
     .byte $70,$00,$00,2 ; LD   (HL),B
     .byte $71,$00,$00,2 ; LD   (HL),C
     .byte $72,$00,$00,2 ; LD   (HL),D
     .byte $73,$00,$00,2 ; LD   (HL),E
     .byte $74,$00,$00,2 ; LD   (HL),H
     .byte $75,$00,$00,2 ; LD   (HL),L
     .byte $77,$00,$00,2 ; LD   (HL),A
     .byte $02,$00,$00,2 ; LD   (BC),A
     .byte $12,$00,$00,2 ; LD   (DE),A
     .byte $22,$00,$00,2 ; LD   (HL+),A
     .byte $32,$00,$00,2 ; LD   (HL-),A
     .byte $E2,$00,$00,2 ; LDH  (C),A
     .byte $E0,<tima_64,$00,3 ; LDH  (n),A
     .byte $EA,<tima_64,>tima_64,4 ; LD   (nn),A
instructions_end:

main:
     call init_tima_64
     set_test 0
     
     ; Test instructions
     ld   hl,instructions
-    call @test_instr
     cp   (hl)
     call nz,@print_failed
     inc  hl
     ld   a,l
     cp   <instructions_end
     jr   nz,-
     
     jp   tests_done

@print_failed:
     push hl
     ld   b,a
     ld   c,(hl)
     dec  hl
     dec  hl
     dec  hl
     ld   a,(hl)
     call print_hex
     print_str ":"
     ld   a,b
     call print_dec
     print_str "-"
     ld   a,c
     call print_dec
     print_str " "
     pop  hl
     set_test 1
     ret

; Tests instruction
; HL -> 3-byte instruction
; HL <- HL + 3
@test_instr:
     ; Copy instr
     ld   a,(hl+)
     ld   (instr+0),a
     ld   a,(hl+)
     ld   (instr+1),a
     ld   a,(hl+)
     ld   (instr+2),a
     push hl
     
     ; Test for writes on each cycle
     ld   b,0
-    push bc
     call @time_write
     pop  bc
     cp   <tima_64
     jr   z,@no_write
     cp   >tima_64
     jr   z,@no_write
     jr   @found
@no_write:
     inc  b
     ld   a,b
     cp   10
     jr   nz,-
     ld   b,0
     
@found:
     ld   a,b
     pop  hl
     ret

; Tests for write
; B -> which cycle to test
; A <- timer value after test
@time_write:
     call sync_tima_64
     ld   a,13
     sub  b
     call delay_a_20_cycles
     ld   hl,tima_64
     ld   bc,tima_64
     ld   de,tima_64
     ld   a,<tima_64
instr:
     nop
     nop
     nop
     delay 32
     ld   a,(tima_64)
     ret
