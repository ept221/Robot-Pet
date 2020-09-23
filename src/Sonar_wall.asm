MVI A, 00	// Setup timer B
OUT 44

MVI A, 41	// Setup timer B
OUT 45

MVI A, CE	// Start timer B and set up port BC and BB to OUTPUT
OUT 40

MVI A, 02	// Enable front sonar
OUT 43

MVI A, 0C	// Set port AC to OUTPUT
OUT 00

MVI A, 21	// Forward
OUT 03

LXI SP, FF

JMP START

#ORG 24
TRAP:
MVI A, 01	// Turn on white led
OUT 42
HLT

#ORG 44
START:
IN 41
ANI 01
JNZ START

MVI A, 01	// Turn on red led
OUT 42

MVI A, 20	// Stop
OUT 03

HLT
