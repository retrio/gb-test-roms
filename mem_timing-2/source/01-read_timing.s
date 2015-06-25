; Tests timing of accesses made by
; memory read instructions

.define ROM_NAME "foo"

.include "shell.inc"
.include "tima_64.s"

instructions:
     ; last value is time of read
     .byte $B6,$00,$00,2 ; OR   (HL)
     .byte $BE,$00,$00,2 ; CP   (HL)
     .byte $86,$00,$00,2 ; ADD  (HL)
     .byte $8E,$00,$00,2 ; ADC  (HL)
     .byte $96,$00,$00,2 ; SUB  (HL)
     .byte $9E,$00,$00,2 ; SBC  (HL)
     .byte $A6,$00,$00,2 ; AND  (HL)
     .byte $AE,$00,$00,2 ; XOR  (HL)
     .byte $46,$00,$00,2 ; LD   B,(HL)
     .byte $4E,$00,$00,2 ; LD   C,(HL)
     .byte $56,$00,$00,2 ; LD   D,(HL)
     .byte $5E,$00,$00,2 ; LD   E,(HL)
     .byte $66,$00,$00,2 ; LD   H,(HL)
     .byte $6E,$00,$00,2 ; LD   L,(HL)
     .byte $7E,$00,$00,2 ; LD   A,(HL)
     .byte $F2,$00,$00,2 ; LDH  A,(C)
     .byte $0A,$00,$00,2 ; LD   A,(BC)
     .byte $1A,$00,$00,2 ; LD   A,(DE)
     .byte $2A,$00,$00,2 ; LD   A,(HL+)
     .byte $3A,$00,$00,2 ; LD   A,(HL-)
     .byte $F0,<tima_64,$00,3 ; LDH  A,($00)
     .byte $FA,<tima_64,>tima_64,4 ; LD   A,($0000)
     
     .byte $CB,$46,$00,3 ; BIT  0,(HL)
     .byte $CB,$4E,$00,3 ; BIT  1,(HL)
     .byte $CB,$56,$00,3 ; BIT  2,(HL)
     .byte $CB,$5E,$00,3 ; BIT  3,(HL)
     .byte $CB,$66,$00,3 ; BIT  4,(HL)
     .byte $CB,$6E,$00,3 ; BIT  5,(HL)
     .byte $CB,$76,$00,3 ; BIT  6,(HL)
     .byte $CB,$7E,$00,3 ; BIT  7,(HL)
instructions_end:

main:
     call init_tima_64
     set_test 0
     
     ; Test instructions
     ld   hl,instructions
-    call @time_instr
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
     ld   a,(hl+)
     cp   $CB
     jr   nz,+
     call print_a
     ld   a,(hl)
+    call print_hex
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
     ld   c,a
     
     ; Test for accesses on each cycle
     ld   b,0
-    push bc
     call @time_access
     pop  bc
     cp   c
     jr   nz,@found
     inc  b
     ld   a,b
     cp   10
     jr   nz,-
     ld   b,0
     
@found:
     ld   a,b
     pop  hl
     ret

; Tests for read
; B -> which cycle to test
; A <- timer value after test
@time_access:
     call sync_tima_64
     ld   a,9
     sub  b
     call delay_a_20_cycles
     xor  a    ; clear flags
     ld   hl,tima_64
     ld   (hl),$7F
     ld   bc,tima_64
     ld   de,tima_64
     ld   a,$7F
instr:
     nop
     nop
     nop
     
     ; Add all registers together to yield
     ; unique value that differs based on
     ; read occurring before or after tima_64
     ; increments.
     push af
     add  hl,bc
     add  hl,de
     pop  de
     add  hl,de
     ld   a,h
     add  l
     ret
