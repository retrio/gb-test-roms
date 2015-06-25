; Included at beginning of all programs
; that use standard shell

; Get include files from common/
.incdir "common"

; Sub-test in a multi-test ROM
.ifdef BUILD_MULTI
     .include "build_multi.s"
.else

; GBS music file
.ifdef BUILD_GBS
     .include "build_gbs.s"
.endif

; Devcart
.ifdef BUILD_DEVCART
     .include "build_devcart.s"
.endif

; GB ROM (default)
.ifndef RUNTIME_INCLUDED
     .include "build_rom.s"
.endif

.endif ; .ifdef BUILD_MULTI
