; Common routines and runtime

.define RUNTIME_INCLUDED 1

; A few bytes of RAM that aren't cleared
.define nv_ram_base      $D800
.define nv_ram           nv_ram_base

; Address of next normal variable
.define bss_base    nv_ram_base+$80
.define bss         bss_base

; Address of next direct-page ($FFxx) variable
.define dp_base     $FF80
.define dp          dp_base

; Top of stack
.define std_stack $DFFF+1

; Final exit result byte is written here
.define final_result     $A000

; Text output is written here as zero-terminated string
.define text_out_base    $A004

; DMG/CGB hardware identifier
.define gb_id_cgb        $10 ; mask for testing CGB bit
.define gb_id_devcart    $04 ; mask for testing "on devcart" bit
.define gb_id       nv_ram
.redefine nv_ram    nv_ram+1

; Copies C*$100 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
copy_to_wram_then_run:
     ld   b,a
     
     ld   de,$C000
-    ld   a,(hl+)
     ld   (de),a
     inc  e
     jr   nz,-
     inc  d
     dec  c
     jr   nz,-
     
     ld   a,b
     jp   $C000


.ifndef RST_OFFSET
     .define RST_OFFSET 0
.endif

.ifndef CUSTOM_RESET
     reset:
          di
          
          ; Run code from $C000, as is done on devcart. This
          ; ensures minimal difference in how it behaves.
          ld   hl,$4000
          ld   c,$14
          jp   copy_to_wram_then_run
     
     .bank 1 slot 1
     .org 0
          jp   std_reset
.endif

; returnOrg puts this code AFTER user code.
.section "runtime" returnOrg

     ; Catch user code running off end
     jp   internal_error

; Common routines
.include "gb.inc"
.include "macros.inc"
.include "delay.s"
.include "crc.s"
.include "printing.s"
.include "numbers.s"
.include "testing.s"

; Sets up hardware and runs main
std_reset:

     ; Init hardware
     di
     ld   sp,std_stack
     
     ; Save DMG/CGB id
     ld   (gb_id),a
     
     ; Clear memory except very top of stack
     ld   bc,std_stack-bss_base - 2
     ld   hl,bss_base
     call clear_mem
     ld   bc,$FFFF-dp_base
     ld   hl,dp_base
     call clear_mem
     
     ; Init hardware
     wreg TAC,$00
     wreg IF,$00
     wreg IE,$00
     
     wreg NR52,0    ; sound off
     wreg NR52,$80  ; sound on
     wreg NR51,$FF  ; mono
     wreg NR50,$77  ; volume
     
     call init_runtime
     call init_text_out
     call console_init
     call init_testing
     
     .ifdef TEST_NAME
          print_str TEST_NAME,newline,newline
     .endif
     
     call reset_crc ; in case init_runtime prints anything
     
     delay_msec 250
     
     ; Run user code
     call main
     
     ; Default is to successful exit
     ld   a,0
     jp   exit


; Exits code and reports value of A
exit:
     ld   sp,std_stack
     push af
     call +
     call console_show
     pop  af
     call play_byte
     jp   post_exit

+    push af   
     call print_newline
     pop  af
     
     ; Report exit status
     cp   1
     
     ; 0: ""
     ret  c
     
     ; 1: "Failed"
     jr   nz,+
     print_str "Failed",newline
     ret
     
     ; n: "Failed #n"
+    print_str "Failed #"
     call print_dec
     call print_newline
     ret


; Clears BC bytes starting at HL
clear_mem:
     ; If C>0, increment B
     dec  bc
     inc  c
     inc  b
     
     ld   a,0
-    ld   (hl+),a
     dec  c
     jr   nz,-
     dec  b
     jr   nz,-
     ret


; Reports internal error and exits with code 255
internal_error:
     print_str "Internal error"
     ld   a,255
     jp   exit


; build_devcart and build_multi customize this
.ifndef CUSTOM_PRINT
     .define text_out_addr    bss+0
     .redefine bss            bss+2
     
     ; Initializes text output to cartridge RAM
     init_text_out:
          ; Enable cartridge RAM and set text output pointer
          setb RAMEN,$0A
          setw text_out_addr,text_out_base
          setb text_out_base-3,$DE
          setb text_out_base-2,$B0
          setb text_out_base-1,$61
          setb text_out_base,0
          setb final_result,$80
          ret
     
     
     ; Appends character to text output string
     ; Preserved: AF, BC, DE, HL
     write_text_out:
          push hl
          push af
          ld   a,(text_out_addr)
          ld   l,a
          ld   a,(text_out_addr+1)
          ld   h,a
          inc  hl
          ld   (hl),0
          ld   a,l
          ld   (text_out_addr),a
          ld   a,h
          ld   (text_out_addr+1),a
          dec  hl
          pop  af
          ld   (hl),a
          pop  hl
          ret
     
     print_char_nocrc:
          call write_text_out
          jp   console_print
.endif


; only build_rom uses console
.ifdef NEED_CONSOLE
     .include "console.s"
.else
     console_init:
     console_print:
     console_flush:
     console_normal:
     console_inverse:
     console_show:
     console_set_mode:
          ret
.endif


; build_devcart and build_multi need to customize this
.ifndef CUSTOM_EXIT
     post_exit:
          ld   (final_result),a
     forever:
          wreg NR52,0    ; sound off
-         jr   -
.endif


.macro def_rst ARGS addr
     .bank 0 slot 0
     .org addr+RST_OFFSET
.endm
