MVI A, 02
OUT 40
MVI A, 0C
OUT 00
MVI A, 3C
OUT 03
LXI SP, FF
JMP START

#ORG 44
START:
MVI D, 00
MOV A,D
OUT 42

CALL DELAY
NEXT:
INR D
MOV A,D
OUT 42
CALL DELAY
CPI FF
JNZ NEXT
JMP START

DELAY:
LXI B,186F
DELAYLoop:
DCX B
MOV A,B
ORA C
JNZ DELAYLoop
RET
