MVI A, 0C	// Set servo port to output
OUT 00

MVI A, 3C	// Keep shaft right
OUT 03

MVI A, 02
OUT 40

LXI SP, FF
JMP START

#ORG 44
START:
LXI B, 8064
CALL SUB_TMR

POLL:
IN 41
ANI 04
JNZ POLL

IN 42
XRI 01
OUT 42

CALL DELAY
JMP START


SUB_TMR:
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CC
OUT 00
RET

DELAY:
LXI B,04E2
DELAYLoop:
DCX B
MOV A,B
ORA C
JNZ DELAYLoop
RET