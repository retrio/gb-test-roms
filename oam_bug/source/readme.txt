Game Boy Tests Source Code
--------------------------

Building with wla-dx
--------------------
To assemble a test ROM with wla-dx, use the following commands:

	wla -o source_filename_here.s test.o
	wlalink linkfile test.gb

To assemble as a GBS music file:
	
	wla -o source_filename_here.s test.o -DBUILD_GBS
	wlalink linkfile test.gbs

Note that some tests might only work when built as a ROM or GBS file,
but not both.

Some tests might include a ROM/GBS that has all the tests combined.
Building such a multi-test is complex and the necessary files aren't
included.


Framework
---------
Each test is in a single source file, and makes use of several library
source files from common/. This framework provides common services and
reduces code to only that which performs the actual test. Virtually all
tests include "shell.inc" at the beginning, which sets things up and
includes all the appropriate library files.

The reset handler does minimal GB hardware initialization, clears RAM,
sets up the text console, then runs main. Main can exit by returning or
jumping to "exit" with an error code in A. Exit reports the code then
goes into an infinite loop. If the code is 0, it doesn't do anything,
otherwise it reports the code. Code 1 is reported as "Failed", and the
rest as "Error <code>".

The default is to build a ROM. Defining BUILD_GBS will build as an GBS.
The other build types aren't supported due to their complexity. I load
the code into RAM at $C000 since my devcart requires it, and I don't
want the normal ROM to differ in any way from what I've tested. This
also allows easy self-modifying code.

Several routines are available to print values and text to the console.
Most update a running CRC-32 checksum which can be checked with
check_crc, allowing ALL the output to be checked very easily. If the
checksum doesn't match, it is printed, so you can run the code on a GB
and paste the correct checksum into your code.


Macros
------
Some macros are used to make common operations more convenient. The left
is equivalent to the right:

	Macro               Equivalent
	-------------------------------------
	lda addr            ldh a,(addr-$FF00)
	
	sta addr            ldh (addr-$FF00),a
	
	wreg addr,data      ld  a,data
						ldh (addr-$FF00),a
	
	setb                ld  a,data
						ld  (addr),a
	
	setw                setb addr+0,<data
						setb addr+1,>data
	
	for_loop routine,begin,end,step
						calls routine with A set to successive values
	
	loop_n_times routine,count
						calls routine with A from 0 to count-1
	
	print_str "str"     prints string
	

-- 
Shay Green <gblargg@gmail.com>
