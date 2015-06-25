Game Boy CPU Instruction Timing Test
------------------------------------
This ROM tests the timings of all CPU instructions except HALT, STOP,
and the 11 illegal opcodes. For conditional instructions, it tests taken
and not taken timings. This test requires proper timer operation (TAC,
TIMA, TMA).

Failed instructions are listed as

	[CB] opcode:measured time-correct time

Times are in terms of instruction cycles, where NOP takes one cycle.


Verified cycle timing tables
----------------------------
The test internally uses a table of proper cycle times, which can be
used in an emulator to ensure proper timing. The only changes below are
removal of the .byte prefixes, and addition of commas at the ends, so
that they can be used without changes in most programming languages. For
added correctness assurance, the original tables can be found at the end
of the source code.

Normal instructions:

	1,3,2,2,1,1,2,1,5,2,2,2,1,1,2,1,
	0,3,2,2,1,1,2,1,3,2,2,2,1,1,2,1,
	2,3,2,2,1,1,2,1,2,2,2,2,1,1,2,1,
	2,3,2,2,3,3,3,1,2,2,2,2,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	2,2,2,2,2,2,0,2,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,
	2,3,3,4,3,4,2,4,2,4,3,0,3,6,2,4,
	2,3,3,0,3,4,2,4,2,4,3,0,3,0,2,4,
	3,3,2,0,0,4,2,4,4,1,4,0,0,0,2,4,
	3,3,2,1,0,4,2,4,3,2,4,1,0,0,2,4

CB-prefixed instructions:

	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,
	2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,
	2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,
	2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2,
	2,2,2,2,2,2,4,2,2,2,2,2,2,2,4,2


Internal operation
------------------
Before each instruction is executed, the test sets up registers and
memory in such a way that the instruction will cleanly execute and then
end up at a common destination, without trashing anything important. The
timing itself is done by first synchronizing to the timer via a loop,
executing the instruction, then using a similar loop to determine how
many clocks elapsed.


Failure codes
-------------
Failed tests may print a failure code, and also short description of the
problem. For more information about a failure code, look in the
corresponding source file in source/; the point in the code where
"set_test n" occurs is where that failure code will be generated.
Failure code 1 is a general failure of the test; any further information
will be printed.

Note that once a sub-test fails, no further tests for that file are run.


Console output
--------------
Information is printed on screen in a way that needs only minimum LCD
support, and won't hang if LCD output isn't supported at all.
Specifically, while polling LY to wait for vblank, it will time out if
it takes too long, so LY always reading back as the same value won't
hang the test. It's also OK if scrolling isn't supported; in this case,
text will appear starting at the top of the screen.

Everything printed on screen is also sent to the game link port by
writing the character to SB, then writing $81 to SC. This is useful for
tests which print lots of information that scrolls off screen.


Source code
-----------
Source code is included for all tests, in source/. It can be used to
build the individual test ROMs. Code for the multi test isn't included
due to the complexity of putting everything together.

Code is written for the wla-dx assembler. To assemble a particular test,
execute

	wla -o "source_filename.s" test.o
	wlalink linkfile test.gb

Test code uses a common shell framework contained in common/.


Internal framework operation
----------------------------
Tests use a common framework for setting things up, reporting results,
and ending. All files first include "shell.inc", which sets up the ROM
header and shell code, and includes other commonly-used modules.

One oddity is that test code is first copied to internal RAM at $D000,
then executed there. This allows self-modification, and ensures the code
is executed the same way it is on my devcart, which doesn't have a
rewritable ROM as most do.

Some macros are used to simplify common tasks:

	Macro               Behavior
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	wreg addr,data      Writes data to addr using LDH
	lda  addr           Loads byte from addr into A using LDH
	sta  addr           Stores A at addr using LDH
	delay n             Delays n cycles, where NOP = 1 cycle
	delay_msec n        Delays n milliseconds
	set_test n,"Cause"  Sets failure code and optional string

Routines and macros are documented where they are defined.

-- 
Shay Green <gblargg@gmail.com>
