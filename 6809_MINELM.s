
	.macro	CLC
		ANDCC	#$FE
	.endm

	.macro	SEC
		ORCC	#$01
	.endm
;	Title:		Find Minimum byte-length Element 
;	Name:		MINELM 
;
;	Purpose:	Given the base address and size of an array,
;			find the smallest element
;
;	Entry:		Register X = Base address of array
;			Register A = Size of array in bytes
;
;	Exit:		If size of array not zero then Carry flag = 0 
;			Register A = Smallest element
;			Register X = Address of that element
;			If there are duplicate values of the smallest element, 
;			register X contains the address nearest to the base address,
;			else Carry flag = 1
;
;	Registers Used:	A,B,CC,X,Y
;
;	Time:		Approximately 14 to 26 cycles per byte
;			plus 27 cycles overhead
;
;	Size:		Program 25 bytes
;
MINELM:
	;
	; EXIT WITH CARRY SET IF ARRAY CONTAINS NO ELEMENTS
	;
	SEC				; SET CARRY IN CASE ARRAY HAS NO ELEMENTS 
	TSTA				; CHECK NUMBER OF ELEMENTS
	BEQ	EXITMN			; BRANCH (EXIT) WITH CARRY SET IF NO
					; ELEMENTS INDICATES INVALID RESULT
	;
	; EXAMINE ELEMENTS ONE AT A TIME, COMPARING EACH VALUE WITH
	; THE CURRENT MINIMUM AND ALWAYS KEEPING THE SMALLER VALUE
	; AND ITS ADDRESS. IN THE FIRST ITERATION, TAKE THE FIRST
	; ELEMENT AS THE CURRENT MINIMUM.
	;
	TFR	A,B		; SAVE NUMBER OF ELEMENTS IN B
	LEAY	1,X		; SET POINTER AS IF PROGRAM HAD JUST
				; EXAMINED THE FIRST ELEMENT
MINLP:
	LEAX	-1,Y		; SAVE ADDRESS OF ELEMENT JUST EXAMINED
				; AS ADDRESS OF MINIMUM
	LDA	,X		; SAVE ELEMENT JUST EXAMINED AS MINIMUM
	;
	; COMPARE CURRENT ELEMENT TO SMALLEST
	; KEEP LOOKING UNLESS CURRENT ELEMENT IS SMALLER
	;
MINLP1:
	DECB			; COUNT ELEMENTS
	BEQ	EXITLP		; BRANCH (EXIT) IF ALL ELEMENTS EXAMINED
	CMPA	,Y+		; COMPARE CURRENT ELEMENT TO MINIMUM
	BLS	MINLP1		; CONTINUE UNLESS CURRENT ELEMENT SMALLER
	BMI	MINLP		; ELSE CHANGE MINIMUM
	;
	; CLEAR CARRY TO INDICATE VALID RESULT MINIMUM FOUND
	;
EXITLP:
	CLC			; CLEAR CARRY TO INDICATE VALID RESULT
EXITMN:
	RTS
;
;	SAMPLE EXECUTION:
;
SC6D:
	LDX	#ARY		; GET BASE ADDRESS OF ARRAY
	LDA	#SZARY		; GET SIZE OF ARRAY IN BYTES
	JSR	MINELM		; FIND MINIMUM VALUE IN ARRAY
				; RESULT FOR TEST DATA IS
				; A = 1 HEX (MINIMUM), 
				; X = ADDRESS OF 1 IN ARY.
	BRA	SC6D		; LOOP FOR ANOTHER TEST

SZARY	EQU	$10		; SIZE OF ARRAY IN BYTES

ARY:	FCB	8
	FCB	7
	FCB	6
	FCB	5
	FCB	4
	FCB	3
	FCB	2
	FCB	1
	FCB	$FF
	FCB	$FE
	FCB	$FD
	FCB	$FC
	FCB	$FA
	FCB	$F9
	FCB	$F8

	END


