; Tests number of cycles taken by instructions
; except STOP, HALT, and illegals.

.include "shell.inc"
.include "timer.s"

.define saved_sp    bss+0
.define instr       bss+2 ; 3-byte instr + JP instr_end
.define instr_addr  bss+8 ; JP instr_end
.redefine bss       bss+11

main:
     call init_timer
     call test_timer
     set_test 0
     call test_main_ops
     call test_cb_ops
     jp   tests_done


; Ensures timer works
test_timer:
     call start_timer
     call stop_timer
     or   a
     ret  z
     set_test 2,"Timer doesn't  work properly"
     jp   test_failed


; Tests main opcodes
test_main_ops:
     ld   l,0
-    ld   h,>op_times
     ld   a,(hl)
     cp   0
     call nz,@test_op
     inc  l
     jr   nz,-
     ret

@test_op:
     ; Can't test the 8 RST instructions on devcart
     ld   a,l
     cpl
     and  $C7
     jr   nz,+
     ld   a,(gb_id)
     and  gb_id_devcart
     ret  nz
+
     ; Test with flags set so that branches are
     ; not taken
     ld   a,l  ; e = (l & 0x08 ? 0 : 0xFF)
     and  $08
     add  $F8
     ld   e,a
     call @copy_and_exec
     ld   d,0
     cp   (hl)
     jr   z,+
     ld   d,a
     call print_failed_opcode
+

     ; Time with branches not taken
     ld   a,e
     cpl
     ld   e,a
     call @copy_and_exec
     ld   h,>op_times_taken
     cp   (hl)
     ret  z
     
     ; If opcode already failed and timed the
     ; same again, avoid re-reporting.
     cp   d
     ret  z
     
     call print_failed_opcode
     ret

@copy_and_exec:
     push de
     push hl
     
     ld   h,>op_lens
     ld   c,(hl)
     ld   a,l
     ld   hl,instr
     ld   (hl+),a
     dec  c
     jr   z,@one_byte
     ld   a,0
     dec  c
     jr   z,@two_bytes
     ld   a,<instr_addr
     ld   (hl+),a
     ld   a,>instr_addr
@two_bytes:
     ld   (hl+),a
@one_byte:     
     ld   a,e
     call time_instruction
     
     pop  hl
     pop  de
     ret


; Tests CB opcodes
test_cb_ops:
     ld   hl,cb_op_times
-    ld   a,(hl)
     cp   0
     call nz,@test_op_cb
     inc  l
     jr   nz,-
     ret

@test_op_cb:
     ; Test with flags clear
     ld   e,$00
     call @copy_and_exec_cb
     cp   (hl)
     jr   nz,+
     
     ; Test with flags set
     ld   e,$FF
     call @copy_and_exec_cb
     cp   (hl)
     jr   nz,+
     
     ret
+    print_str "CB "
     call print_failed_opcode
     ret

@copy_and_exec_cb:
     push hl
     
     ; Copy instr to exec space
     ld   a,l
     ld   hl,instr+1
     ld   (hl+),a
     ld   a,$CB
     ld   (instr),a
     call time_instruction
     
     pop  hl
     ret


; Reports failed opcode
; L    -> opcode
; A    -> cycles it took
; (HL) -> cycles it should have taken
; Preserved: HL
print_failed_opcode:
     ; Print opcode
     push af
     ld   a,l
     call print_hex
     ld   a,':'
     call print_char
     pop  af
     
     ; Print actual and correct times
     call print_dec
     ld   a,'-'
     call print_char
     ld   a,(hl)
     call print_dec
     ld   a,' '
     call print_char
     
     ; Remember that failure occurred
     set_test 1
     
     ret


; Times instruction.
; HL -> address of byte just after instruction
; A  -> flags when executing instruction
; A  <- number of cycles instruction took
time_instruction:
     ld   c,a
     
     ; Write JP instr_end to HL and instr_addr
     ld   a,$C3     ; JP
     ld   (hl+),a
     ld   (instr_addr),a
     
     ld   a,<instr_end
     ld   (instr_addr+1),a
     ld   (hl+),a
     
     ld   a,>instr_end
     ld   (instr_addr+2),a
     ld   (hl),a
     
     ; Save sp
     ld   (saved_sp),sp
     
     ; Set regs and stack contents
     push bc
     ld   bc,instr_addr
     ld   de,instr_addr
     ld   hl,instr_addr
     call start_timer
     pop  af
     push hl
     
     ; Environment instruction executes in:
     ; 1 byte: OP
     ; 2 byte: OP 00
     ; 3 byte: OP instr_addr
     ; BC,DE,HL = instr_addr
     ; Stack has instr_addr pushed on it.
     ; Stack pointer can be trashed by instr.
     ; instr_addr contains JP instr_end, that
     ; can be trashed. Instructions which trash
     ; this don't execute it.
     
     jp   instr
instr_end:     ; instruction jumps here when done
     di
     
     ; Restore sp
     ld   sp,saved_sp
     pop  hl
     ld   sp,hl
     
     call stop_timer
     sub  24
     ret

.section "page_aligned" align 256

; Instruction lengths of opcodes.
; 0 for instructions not timed.
op_lens:
     .byte 1,3,1,1,1,1,2,1,3,1,1,1,1,1,2,1 ; 0
     .byte 0,3,1,1,1,1,2,1,2,1,1,1,1,1,2,1 ; 1
     .byte 2,3,1,1,1,1,2,1,2,1,1,1,1,1,2,1 ; 2
     .byte 2,3,1,1,1,1,2,1,2,1,1,1,1,1,2,1 ; 3
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 4
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 5
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 6
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 7
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 8
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; 9
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; A
     .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; B
     .byte 1,1,3,3,3,1,2,1,1,1,3,0,3,3,2,1 ; C
     .byte 1,1,3,0,3,1,2,1,1,1,3,0,3,0,2,1 ; D
     .byte 2,1,1,0,0,1,2,1,2,1,3,0,0,0,2,1 ; E
     .byte 2,1,1,1,0,1,2,1,2,1,3,1,0,0,2,1 ; F

; Timings for main opcodes
op_times:
     .byte 1,3,2,2,1,1,2,1,5,2,2,2,1,1,2,1
     .byte 0,3,2,2,1,1,2,1,3,2,2,2,1,1,2,1
     .byte 2,3,2,2,1,1,2,1,2,2,2,2,1,1,2,1
     .byte 2,3,2,2,3,3,3,1,2,2,2,2,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 2,2,2,2,2,2,0,2,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 2,3,3,4,3,4,2,4,2,4,3,0,3,6,2,4
     .byte 2,3,3,0,3,4,2,4,2,4,3,0,3,0,2,4
     .byte 3,3,2,0,0,4,2,4,4,1,4,0,0,0,2,4
     .byte 3,3,2,1,0,4,2,4,3,2,4,1,0,0,2,4

; Timings when conditionals are taken
op_times_taken:
     .byte 1,3,2,2,1,1,2,1,5,2,2,2,1,1,2,1
     .byte 0,3,2,2,1,1,2,1,3,2,2,2,1,1,2,1
     .byte 3,3,2,2,1,1,2,1,3,2,2,2,1,1,2,1
     .byte 3,3,2,2,3,3,3,1,3,2,2,2,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 2,2,2,2,2,2,0,2,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1
     .byte 5,3,4,4,6,4,2,4,5,4,4,0,6,6,2,4
     .byte 5,3,4,0,6,4,2,4,5,4,4,0,6,0,2,4
     .byte 3,3,2,0,0,4,2,4,4,1,4,0,0,0,2,4
     .byte 3,3,2,1,0,4,2,4,3,2,4,1,0,0,2,4
     
; Timings for CB-prefixed opcodes
cb_op_times:
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2
     .byte 2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2
     .byte 2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2
     .byte 2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
     .byte 2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2
.ends

; RST handlers
.bank 0 slot 0
.org $00
     jp   instr_end
.org $08
     jp   instr_end
.org $10
     jp   instr_end
.org $18
     jp   instr_end
.org $20
     jp   instr_end
.org $28
     jp   instr_end
.org $30
     jp   instr_end
.org $38
     jp   instr_end
