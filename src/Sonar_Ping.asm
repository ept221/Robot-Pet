MVI A, 00	// Setup timer B
OUT 44

MVI A, 41	// Setup timer B
OUT 45

MVI A, CE	// Start timer B and set up port BB and BC to OUTPUT
OUT 40

MVI A, 02	// Enable front sonar
OUT 43

LXI SP, FF	// Set stack pointer

JMP PRE

#ORG 44
PRE:
MVI A, 0C
OUT 00
MVI A, 20
OUT 03

START:
CALL DELAY
LXI B, 800A	// Set Timeout 
CALL TMR

POLL:
IN 41	// Poll for echo
ANI 05
CPI 05
JZ POLL	// If no TMR or echo

CPI 01	// If TMR
JZ CLEAR

IN 44	// If echo
MOV B,A
MVI A, FF
SUB B
JMP WRITE

CLEAR:
MVI A, 00

WRITE:
OUT 42
JMP START
HLT

TMR:
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CC
OUT 00
RET

DELAY:
LXI B,0C37
DELAYLoop:
DCX B
MOV A,B
ORA C
JNZ DELAYLoop
RET
