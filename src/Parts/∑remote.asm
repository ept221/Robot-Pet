////////////////////////////////////////////////
//Init
MVI A, 0E	// Set up port BB and BC to OUTPUT
OUT 40

MVI A, 1E		// Setup interrupt
SIM

LXI SP, 40FF

JMP 44


////////////////////////////////////////////////
//Excom Interrupt 
#ORG 2C		
DI
LXI H, F7	// Set HL to point to reference frequency address
JMP EXCOM


////////////////////////////////////////////////
//Main
#ORG 44

MVI A, 0C	// Set Servo Port to OUTPUT
OUT 00

MVI A, 20	// Center Shaft
OUT 03

CALL SUB_SERVO

EI 			// Enable Excom

WAIT:
JMP Wait 	// Wait for Excom command


////////////////////////////////////////////////
//Excom
EXCOM:
MVI A, 4C		// Stop timer
OUT 00

MVI A, 01		// Turn on red led
OUT 42

LXI B, 4950
CALL SUB_DELAY	// Wait for settle period (300 ms delay util function)
IN 01			// Read frequency
MOV M,A			// Store at address pointed to by HL
INX H			// Increment HL pointer

EXCOM_P1:
IN 41			// Poll for end of whistle
ANI 02
JNZ EXCOM_P1

MVI A, 02		// Turn on white led
OUT 42

MOV A,L			// Decode if last whistle
CPI F9
JZ DECODE

LXI B, 81F4		// Call sync timer (5-seconds)
CALL SUB_TMR		

EXCOM_P2:		// Poll for sync and whistle
IN 41
ANI 06
CPI 04
JZ EXCOM_P2		// Repoll if no sync or whistle
CPI 06
JZ EXCOM		// If whistle

MVI A, FF		// If sync times out
OUT 42
EI
RET

DECODE:
MVI B, 00					// Clear the word register
LXI H, F7					// Set HL pointer to first frequency (reference frequency)
EXCOM_P3:
INX H 						// Increment HL pointer
LDA F7 						// Load reference frequency into A
CMP M 						// Compare it to data pointed to by HL
MOV A,B 					// Move B to A
RAL							// Rotate the carry flag into B
MOV B,A 					// Move A to B
MOV A,L 					// Move L to A 
CPI F8						// Check to see if finished last frequency
JNZ EXCOM_P3 				// If not, jump to POLL3

DISPLAY:
MOV A,B		// Load decoded control word
RLC			// Shift it right
RLC			// Shift it right
OUT 42		// Display it on LED bus

MOV A,B 	// Put the unshifted control word back in A

FORWARDS:
CPI 01
JNZ BACKWARDS
MVI A, 21
OUT 03
JMP END

BACKWARDS:
MVI A, 23
OUT 03

END:
LXI B, 81F4
CALL SUB_TMR_DELAY
MVI A, 20
OUT 03
LXI B, 8032
CALL SUB_TMR_DELAY 
EI			// Enable Interrupts
RET			// Return


////////////////////////////////////////////////
//Combo
SUB_SERVO:
IN 41
ANI 08
JNZ SUB_SERVO
RET

SUB_TMR_DELAY:
CALL SUB_TMR
IN 41
ANI 04
JNZ SUB_TMR_DELAY
LXI B, 0C37
CALL SUB_DELAY
RET


////////////////////////////////////////////////
//Util
SUB_TMR:
MOV A,B
OUT 05
MOV A,C
OUT 04
MVI A, CC
OUT 00
RET

SUB_DELAY:
DCX B
MOV A,B
ORA C
JNZ SUB_DELAY
RET