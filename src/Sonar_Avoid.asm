MVI A, 00       // Setup timer B
OUT 44

MVI A, 41       // Setup timer B
OUT 45

MVI A, CE       // Start timer B and set up port BB and BC to OUTPUT
OUT 40

MVI A, 02       // Enable front sonar
OUT 43

LXI SP, 40FF    // Set stack pointer

JMP PRE

#ORG 44
PRE:
MVI A, 0C       // Set Servo Port to OUTPUT
OUT 00

MVI A, 20       // Center Shaft
OUT 03

CENTER:         // Wait until shaft is centered
IN 41
ANI 08
JZ CENTER

START:
MVI A, 21       // Move shaft forward and drive
OUT 03

MVI A, 02       // Enable front sonar
OUT 43

PING_POLL:
CALL SUB_PING   // Poll for obstical
CPI 4F
JNC PING_POLL

MVI A, 20       // Stop
OUT 03

MVI A, 01       // Enable left sonar
OUT 43
CALL SUB_PING   // Read left distance
MOV L,A         // Store left distance in L

MVI A, 03       // Enable right sonar
OUT 43
CALL SUB_PING   // Read right distance

CMP L           // Compare right distance to left distance
JC LEFT         // Turn left if there is more room to the left
JZ FLIP         // Turn left or right if distances are equal

MVI A, 3C       // Turn shaft right
OUT 03
JMP TURN

LEFT:           // Turn shaft left
MVI A, 00
OUT 03
JMP TURN

FLIP:
LDA 00F4
XRI 3C
STA 00F4
OUT 03

TURN:           // Wait for shaft to finish turning
IN 41
ANI 08
JZ TURN

IN 03           // Turn on drive motor to turn
INR A
OUT 03

LXI B, 80C8     // Wait for turn to finish (2s)
CALL SUB_TMR
PP:
IN 41
ANI 04
JNZ PP
CALL SUB_DELAY
JMP START       // Loop back to START

SUB_PING:       // Ping subroutine
CALL SUB_DELAY  // Rest delay
LXI B, 800A     // Setup timeout timer
CALL SUB_TMR

POLL:           // Poll for echo or timout
IN 41
ANI 05
CPI 05
JZ POLL

CPI 01          // If timout reached jump to set max distance
JZ CLEAR

IN 44           // If echo, calculate distance
MOV B,A
MVI A, FF
SUB B
JMP WRITE

CLEAR:
MVI A, FF       // Set distance to max if no object detected

WRITE:          // Write distance to LED readout
OUT 42
RET             // Return, note that distance is in A

SUB_TMR:        // Timer subroutine
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CC
OUT 00
RET             // Return

SUB_DELAY:      // Delay subroutine for PING refresh (50ms)
LXI B,0C37
DELAYLoop:
DCX B
MOV A,B
ORA C
JNZ DELAYLoop
RET             // Return

# ORG F4            
# DB 3CH,
