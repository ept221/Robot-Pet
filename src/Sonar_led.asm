MVI A, 00	// Setup timer B
OUT 44

MVI A, 41	// Setup timer B
OUT 45

MVI A, CE	// Start timer B and set up port BC and BB to OUTPUT
OUT 40

MVI A, 02	// Enable front sonar
OUT 43

JMP START

#ORG 44
START:
IN 41
ANI 01
JNZ START

MVI A, 01	// Turn on led
OUT 42

HLT