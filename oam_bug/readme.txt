OAM Corruption Test
-------------------
* Verifies OAM corruption bug on DMG.

* Occurs when 16-bit increment/decrement is made of value in range $FE00
to $FEFF, during around the first 20 cycles of a visible scanline while
LCD is on, where 114 cycles = 1 scanline.

* Causes several bytes of OAM to be copied from one place to another.

* Occurs with instructions that do increment:
	INC rp (including SP)
	DEC rp
	POP rp      counts as two increments
	PUSH rp     counts as two increments
	LD A,(HL+)
	LD A,(HL-)

* Doesn't occur with instructions that do 16-bit add:
	LD HL,SP+n
	ADD HL,rp
	ADD SP,n

* Doesn't occur anytime during the 10 vblank scanlines.

* Doesn't occur when LCD is off, no matter when it happens.

* Corruption depends on when it occurs.


Multi-ROM
---------
In the main directory is a single ROM/GBS which runs all the tests. It
prints a test's number, runs the test, then "ok" if it passes, otherwise
a failure code. Once all tests have completed it either reports that all
tests passed, or reports the number of the first failed test as the
result code (1 = first). Finally, it makes several beeps. If a test
fails, it can be run on its own by finding the corresponding ROM/GBS in
the singles directories.

Ths compact format on screen is to avoid having the results scroll off
the top, so the test can be started and allowed to run without having to
constantly monitor the display. 


Failure information
-------------------
For more information about a failure code or information printed, see
the test's source code in source/. To find failure code N, search for
"set_test N", which will usually be before the subtest which failed.


Flashes, clicks, other glitches
-------------------------------
Some tests might need to turn the screen off and on, or cause slight
audio clicks. This does not indicate failure, and should be ignored.
Only the test result reported at the end is important, unless stated
otherwise.


LCD support
-----------
Tests generally print information on screen. The tests will work fine if
run on an emulator with NO LCD support, or as an GBS which has no
inherent screen; in particular, the VBL wait routine has a timeout in
case LY doesn't reflect the current LCD line. The text printing will
also work if the LCD doesn't support scrolling.


Output to memory
----------------
Text output and the final result are also written to memory at $A000,
allowing testing a very minimal emulator that supports little more than
CPU and RAM. To reliably indicate that the data is from a test and not
random data, $A001-$A003 are written with a signature: $DE,$B0,$61. If
this is present, then the text string and final result status are valid.

$A000 holds the overall status. If the test is still running, it holds
$80, otherwise it holds the final result code.

All text output is appended to a zero-terminated string at $A004. An
emulator could regularly check this string for any additional
characters, and output them, allowing real-time text output, rather than
just printing the final output at the end.


GBS versions
------------
Many GBS-based tests require that the GBS player either not interrupt
the init routine with the play routine, or if they do, not interrupt the
play routine again if it hasn't returned yet. This is because many tests
need to run for a while without returning.

In addition to the other text output methods described above, GBS builds
report essential information bytes audibly, including the final result.
A byte is reported as a series of tones. The code is in binary, with a
low tone for 0 and a high tone for 1. The first tone is always a zero. A
final code of 0 means passed, 1 means failure, and 2 or higher indicates
a specific reason as listed in the source code by the corresponding
set_code line. Examples:

Tones         Binary  Decimal  Meaning
- - - - - - - - - - - - - - - - - - - - 
low             0       0      passed
low high        01      1      failed
low high low   010      2      error 2

-- 
Shay Green <gblargg@gmail.com>
