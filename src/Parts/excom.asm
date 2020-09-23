
##########################################################################################
[Requirements]

* SUB_TMR
* SUB_DELAY (300 ms)

##########################################################################################
[Initialize]

MVI A, 1E		// Setup interrupt
SIM
EI
##########################################################################################
[Interrupts]

#ORG 2C		
DI
LXI H, *BASE*	// Set HL to point to reference frequency address
JMP EXCOM
##########################################################################################
[Main]

EXCOM:
MVI A, 4C		// Stop timer
OUT 00

MVI A, 01		// Turn on red led
OUT 42

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
CPI *BASE+numOfDataPitchs+1*
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
LXI H, *BASE*				// Set HL pointer to first frequency (reference frequency)
EXCOM_P3:
INX H 						// Increment HL pointer
LDA *BASE* 					// Load reference frequency into A
CMP M 						// Compare it to data pointed to by HL
MOV A,B 					// Move B to A
RAL							// Rotate the carry flag into B
MOV, B,A 					// Move A to B
MOV, A,L 					// Move L to A 
CPI *BASE+numOfDataPitchs*	// Check to see if finished last frequency
JNZ EXCOM_P3 				// If not, jump to POLL3

DISPLAY:
MOV A,B		// Load decoded control word
RLC			// Shift it right
RLC			// Shift it right
OUT 42		// Display it on LED bus
EI			// Enable Interrupts
RET			// Return
##########################################################################################












