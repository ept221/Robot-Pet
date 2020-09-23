MVI A, 0C       // Keep shaft right
OUT 00
MVI A, 3C
OUT 03

MVI A, 02       // Set led port to output
OUT 40  

LXI H, 00C0     // Set pointer to frequency storage
LXI SP, 00FF    // Set stack pointer

MVI A, 1E       // Setup interrupt
SIM
EI

JMP START   


#ORG 2C         // Interrupt
DI
LXI H, 00C0
JMP BEGIN

#ORG 44
START:
JMP START       // Wait for Interrupt to trigger

BEGIN:      
MVI A, 4C       // Stop timer
OUT 00

MVI A, 01       // Turn on red led
OUT 42

CALL DELAY      // Wait for settle period
IN 01           // Read frequency
MOV M,A         // Store at address pointed to by HL
INX H           // Increment HL pointer

POLL:
IN 41           // Poll for end of whistle
ANI 02
JNZ POLL

MVI A, 02       // Turn on white led
OUT 42

MOV A,L         // Decode if last whistle
CPI C5
JZ DECODE

LXI B, 81F4     // Call sync timer
CALL TMR

POLL2:          // Poll for sync and whistle
IN 41
ANI 06
CPI 04
JZ POLL2        // Repoll if no sync or whistle
CPI 06
JZ BEGIN        // If whistle

MVI A, 04       // If sync times out
OUT 42
RET

DECODE:
MVI B, 00       // Clear the word register
LXI H, 00C0     // Set HL pointer to first frequency
POLL3:
INX H           // Increment HL pointer
LDA 00C0        // Load reference frequency into A
CMP M           // Compare it to data pointed to by HL
MOV A,B         // Move B to A
RAL             // Rotate the carry flag into B
MOV B,A         // Move A to B
MOV A,L         // Move L to A
CPI C4          // Check to see if finished last frequency
JNZ POLL3       // If not, jump to P3

MOV A,B         // Load decoded control word
RLC             // Shift it right
RLC             // Shift it right
OUT 42          // Display it on LED bus
EI              // Enable Interrupts
RET             // Return

TMR:
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CC
OUT 00
RET

DELAY:
LXI B, 4950
DELAY_LOOP:
DCX B
MOV A,B
ORA C
JNZ DELAY_LOOP
RET
