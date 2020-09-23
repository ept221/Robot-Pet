##########################################################################################
[Requirements]

* SUB_TMR
* SUB_DELAY (50 ms)

##########################################################################################
[Initialize]

MVI A, 00	// Setup timer B
OUT 44

MVI A, 41	// Setup timer B
OUT 45

MVI A, CE	// Start timer B and set up port BB and BC to OUTPUT
OUT 40

MVI A, 02	// Enable front sonar
OUT 43
##########################################################################################
[Main]

SUB_PING:		// Ping subroutine
CALL SUB_DELAY	// Rest delay (50 ms)
LXI B, 800A		// Setup timeout timer
CALL SUB_TMR

PING_P1:		// Poll for echo or timout
IN 41
ANI 05
CPI 05
JZ PING_P1

CPI 01			// If timout reached jump to set max distance
JZ CLEAR

IN 44			// If echo, calculate distance
MOV B,A
MVI A, FF
SUB B
JMP WRITE

CLEAR:
MVI A, FF		// Set distance to max if no object detected

WRITE:			// Write distance to LED readout
OUT 42
RET 			// Return, note that distance is in A
##########################################################################################