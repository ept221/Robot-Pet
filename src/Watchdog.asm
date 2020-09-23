MVI A, 0E	// Set port AA and AC to output
OUT 00

MVI A, 3C	// Keep shaft left
OUT 03

MVI A, 00	// Setup timer B
OUT 44
MVI A, 41		
OUT 45

MVI A, CE	// Start timer B and set port BB and BC to OUTPUT
OUT 40

LXI SP, FF

JMP START

#ORG 44
START:
MVI A, 01
OUT 02
P1:
MVI A, 01
OUT 43
CALL SUB_PING
CPI FF
JZ P1
IN 43
ORI 0C
OUT 43
IN 43
ANI 03
OUT 43
JMP P1

SUB_PING:		// Ping subroutine
CALL SUB_DELAY	// Rest delay
LXI B, 800A		// Setup timeout timer
CALL SUB_TMR

POLL:		// Poll for echo or timout
IN 41
ANI 05
CPI 05
JZ POLL

CPI 01	// If timout reached jump to set max distance
JZ CLEAR

IN 44	// If echo, calculate distance
MOV B,A
MVI A, FF
SUB B
JMP WRITE

CLEAR:
MVI A, FF	// Set distance to max if no object detected

WRITE:	// Write distance to LED readout
OUT 42
RET	// Return, note that distance is in A

SUB_TMR:	// Timer subroutine
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CE
OUT 00
RET		// Return

SUB_DELAY:		// Delay subroutine for PING refresh
LXI B,0C37
DELAYLoop:
DCX B
MOV A,B
ORA C
JNZ DELAYLoop
RET		// Return