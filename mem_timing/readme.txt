Game Boy CPU Memory Access Timing Test
--------------------------------------
This ROM tests the timing of memory reads and writes made by
instructions, except stack and program counter accesses. These tests
require correct instruction timing and proper timer operation (TAC,
TIMA, TMA).

The read and write tests list failing instructions as

	[CB] opcode:tested-correct

The read-modify-write test lists failing instructions as 

	[CB] opcode:tested read/tested write-correct read/correct write

The values after the opcode refer to which instruction cycle the access
occurs on, with 1 being the first. If a time couldn't be determined due
to some other problem, it prints 0.

For instructions which either read or write, but not both, the CPU makes
the access on the last cycle. For instructions which read, modify, then
write back, the CPU reads on the next-to-last cycle, and writes on the
last cycle.


Internal operation
------------------
The tests have the timer increment TIMA every 64 cycles, synchronize
with this, delay a variable amount, then have the instruction under test
access the timer. By varying the delay in one-cycle increments, the
memory access made by the instruction can be made to fall before and
after a TIMA increment. By then examining the registers and value in
TIMA, it can be determined which occurred.


Multi-ROM
---------
In the main directory is a single ROM which runs all the tests. It
prints a test's number, runs the test, then "ok" if it passes, otherwise
a failure code. Once all tests have completed it either reports that all
tests passed, or prints the number of failed tests. Finally, it makes
several beeps. If a test fails, it can be run on its own by finding the
corresponding ROM in individual/.

Ths compact format on screen is to avoid having the results scroll off
the top, so the test can be started and allowed to run without having to
constantly monitor the display. 

Currently there is no well-defined way for an emulator test rig to
programatically find the result of the test; contact me if you're trying
to do completely automated testing of your emulator. One simple approach
is to take a screenshot after all tests have run, or even just a
checksum of one, and compare this with a previous run.


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
