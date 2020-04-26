	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#$01
	.endm

;
;	Title:		RAM Test
;	Name:		RAMTST
;	Purpose:	Test a RAM (read/write memory) area as follows:
;
;			1) Write all 0 and test
;			2) Write all 11111111 binary
;			3) Write all 10101010 binary and test
;			4) Write all 01010101 binary and test
;			5) Shift a single 1 through each bit,
;			   while clearing all other bits
;
;			If the program finds an error,
;			it exits immediately with the Carry flag set 
;			and indicates the test value
;			and where the error occurred.
;
;	Entry:		TOP OF STACK 
;			High byte of return address
;			Low  byte of return address 
;			High byte of area size in bytes 
;			Low  byte of area size in bytes 
;			High byte of base address of area 
;			Low  byte of base address of area
;
;	Exit:		If there are no errors
;			then	Carry flag equals 0
;				test area contains 0 in all bytes
;			else
;				Carry flag equals 1
;				Register X = Address of error
;				Register A = Test value
;
;	Registers Used:	All.
;
;	Time:		Approximately 268 cycles per byte
;			plus 231 cycles overhead
;
;	Size:		Program 97 bytes
;
RAMTST:
;
; EXIT INDICATING NO ERRORS IF AREA SIZE IS ZERO
;
	PULS	U		; SAVE RETURN ADDRESS
	CLC			;INDICATE NO ERRORS
	LDX	,S		; GET AREA SIZE
	BEQ	EXITRT		; BRANCH (EXIT) IF AREA SIZE IS ZERO
				; CARRY = 0 IN THIS CASE
;
; FILL MEMORY WITH 0 AND TEST
;
	CLRA			; GET ZERO VALUE
	BSR	FILCMP		; FILL AND TEST MEMORY
	BCS	EXITRT		; BRANCH (EXIT) IF ERROR FOUND
;
; FILL MEMORY WITH FF HEX (ALL 1'S) AND TEST
;
	LDA	#$FF		; GET ALL 1'S VALUE
	BSR	FILCMP		; FILL AND TEST MEMORY
	BCS	EXITRT		; BRANCH (EXIT) IF ERROR FOUND
;
; FILL MEMORY WITH ALTERNATING 1'S AND 0'S AND TEST
;
	LDA	#10101010b	; GET ALTERNATING 0'S AND 1'S PATTERN
	BSR	FILCMP		; FILL AND TEST MEMORY
	BCS	EXITRT		; BRANCH (EXIT) IF ERROR FOUND
;
; FILL MEMORY WITH ALTERNATING 0'S AND 1'S AND TEST
;
	LDA	#01010101b	; GET ALTERNATING 0'S AND 1'S PATTERN
	BSR	FILCMP		; FILL AND TEST MEMORY
	BCS	EXITRT		; BRANCH (EXIT) IF ERROR FOUND

; WALKING BIT TEST.
; PLACE A 1 IN BIT 7 AND SEE IF IT CAN BE READ BACK.
; THEN MOVE THE 1 T0 BITS 6, 5, 4, 3, 2, 1, AND 0
; AND SEE IF IT CAN BE READ BACK
;
	LDX	2,S		; GET BASE ADDRESS OF AREA TO TEST
	LDY	,S		; GET AREA SIZE IN BYTES
	CLRB			; GET ZERO TO USE IN CLEARING AREA
WLKLP:
	LDA	#10000000b	; MAKE BIT 7 = 1, ALL OTHER BITS 0
WLKLP1:
	STA	,X		; STORE TEST PATTERN IN MEMORY
	CMPA	,X		; TRY TO READ IT BACK
	BNE	EXITCS		; BRANCH (EXIT) IF ERROR FOUND
	LSRA			; SHIFT PATTERN TO MOVE 1 BIT RIGHT
	BNE	WLKLP1		; CONTINUE UNTIL PATTERN BECOMES ZERO
				; THAT IS, UNTIL 1 BIT MOVES ALL THE
				; WAY ACROSS THE BYTE
	STB	,X+		; CLEAR BYTE JUST CHECKED
	LEAY	-1,Y		; DECREMENT COUNTER
	BNE	WLKLP		; CONTINUE UNTIL AREA CHECKED
	CLC			; NO ERRORS CLEAR CARRY
	BRA	EXITRT
;
; FOUND AN ERROR - SET CARRY TO INDICATE IT
;
EXITCS:
	SEC			; ERROR FOUND - SET CARRY
;
; REMOVE PARAMETERS FROM STACK AND EXIT
;
EXITRT:
	LEAS	4,S		; REMOVE PARAMETERS FROM STACK
	JMP	,U		; EXIT TO RETURN ADDRESS
;
; **********************************
; ROUTINE:		FILCMP
; PURPOSE:		FILL MEMORY WITH A VALUE AND TEST
;			THAT IT CAN BE READ BACK
; ENTRY:		A = TEST VALUE
;			STACK CONTAINS (IN ORDER STARTING AT TOP):
;				RETURN ADDRESS
;				AREA SIZE IN BYTES
;				BASE ADDRESS OF AREA
;
; EXIT:			IF NO ERRORS THEN
;				CARRY FLAG EQUALS 0
;			ELSE
;				CARRY FLAG EQUALS 1
;				X = ADDRESS OF ERROR
;				A = TEST VALUE
;				PARAMETERS LEFT ON STACK

; REGISTERS USED:	CC,X,Y
;
; ************************************
FILCMP:
	LDY	2,S		; GET SIZE OF AREA IN BYTES
	LDX	4,S		; GET BASE ADDRESS OF AREA
;
; FILL MEMORY WITH TEST VALUE
;
FILLP:
	STA	,X+		; FILL A BYTE WITH TEST VALUE
	LEAY	-1,Y		; CONTINUE UNTIL AREA FILLED
	BNE	FILLP
;
; COMPARE MEMORY AND TEST VALUE
;
	LDY	2,S		; GET SIZE OF AREA IN BYTES
	LDX	4,S		; GET BASE ADDRESS OF AREA
CMPLP:
	CMPA	,X+		; COMPARE MEMORY AND TEST VALUE
	BNE	EREXIT		; BRANCH (ERROR EXIT) IF NOT EQUAL
	LEAY	-1,Y		; CONTINUE UNTIL AREA CHECKED
	BNE	CMPLP
;
; NO ERRORS FOUND, CLEAR CARRY AND EXIT
;
	CLC			; INDICATE NO ERRORS
	RTS

;
; ERROR FOUND, SET CARRY, MOVE POINTER BACK, AND EXIT
;
EREXIT:
	SEC			; INDICATE AN ERROR
	LEAX	-1,X		; POINT TO BYTE CONTAINING ERROR 
	RTS
;
; SAMPLE EXECUTION
;
SC6G:
;
; TEST RAM FROM 2000 HEX THROUGH 300F HEX
; SIZE OF AREA = 1010 HEX BYTES
;
	LDY	#$2000		; GET BASE ADDRESS OF TEST AREA
	LDX	#$1010		; GET SIZE OF AREA IN BYTES
	PSHS	X,Y		; SAVE PARAMETERS IN STACK
	JSR	RAMTST		; TEST MEMORY
				; CARRY FLAG SHOULD BE 0

	END