;	Title:			TwoDimensional Byte Array Indexing 
;
;	Name:			D2BYTE
;
;	Purpose:
;
;		Given the base address of a byte array,
;		two subscripts 'I' and 'J', and the size
;		of the first subscript in bytes, calculate
;		the address of A[I,J]. The array is assumed
;		to be stored in row major order (A[0,0],
;		A[0,1],...,A[K,L]), and both dimensions
;		are assumed to begin at zero as in the
;		following Pascal declaration:
;
;			A:ARRAY[0. .2,0. .7] OF BYTE;
;
; 	Entry:
;
;	TOP OF STACK 
;
;	High byte of return address 
;	Low byte of return address 
;	High byte of second subscript (column element) 
;	Low byte of second subscript (column element) 
;	High byte of first subscript size, in bytes 
;	Low byte of first subscript size, in bytes 
;	High byte of first subscript (row element) 
;	Low byte of first subscript (row element) 
;	High byte of array base address
;	Low byte of array base address
;
;	NOTE:
;	The first subscript size is the length of a row in bytes.
;
;	Exit:		Register X = Element address
;
;	Registers used:	CC,D,X,Y
;
;	Time:		Approximately 785 cycles
;
;	Size:		Program 36 bytes


D2BYTE:
	;
	; ELEMENT ADDRESS = ROW SIZE*ROW SUBSCRIPT + COLUMN
	; SUBSCRIPT + BASE ADDRESS
	;
	LDD	#0			; START ELEMENT ADDRESS AT 0 
	LDY	#16			; SHIFT COUNTER = 16
	;
	; MULTIPLY ROW SUBSCRIPT * ROW SIZE
	; USING SHIFT AND ADD ALGORITHM
	;
MUL16:
	LSR	4,S			; SHIFT HIGH BYTE OF ROW SIZE
	ROR	5,S			; SHIFT LOW BYTE OF ROW SIZE
	BCC	LEFTSH			; JUMP IF NEXT BIT OF ROW SIZE IS 0
	ADDD	6,S			; OTHERWISE, ADD SHIFTED ROW SUBSCRIPT
					; TO ELEMENT ADDRESS
LEFTSH:
	LSL	7,S			; SHIFT LOW BYTE OF ROW SUBSCRIPT
	ROL	6,S			; SHIFT HIGH BYTE PLUS CARRY

	LEAY	-1,Y			; DECREMENT SHIFT COUNTER 
	BNE	MUL16			; LOOP 16 TIMES
	;
	; ADD COLUMN SUBSCRIPT TO ROW SUBSCRIPT * ROW SIZE
	;
	ADDD	2,S			; ADD COLUMN SUBSCRIPT 
	ADDD	8,S			; ADD BASE ADDRESS OF ARRAY 
	TFR	D,X			; EXIT WITH ELEMENT ADDRESS IN X
	;
	; REMOVE PARAMETERS FROM STACK AND EXIT
	; 
	PULS	D			; GET RETURN ADDRESS
	LEAS	6,S			; REMOVE PARAMETERS FROM STACK
	STD	,S			; PUT RETURN ADDRESS BACK IN STACK
	RTS
;
;	SAMPLE EXECUTION
;
SC2C:
	LDU	#ARY			; BASE ADDRESS OF ARRAY
	LDY	SUBS1			; FIRST SUBSCRIPT
	LDX	SSUBS1			; SI2E OF FIRST SUBSCRIPT
	LDD	SUBS2			; SECQND SUBSCRIPT
	PSHS	U,X,Y,D			; PUSH PARAMETERS
	JSR	D2BYTE			; CALCULATE ADDRESS 
					; FOR THE INITIAL TEST DATA 
					; X = ADDRESS OF ARY(2,4)
					; = ARY + (2*8) + 4
					; = ARY + 20 (CONTENTS ARE 21) 
					; NOTE BOTH SUBSCRIPTS START AT 0
	FDB	2			; SUBSCRIPT 1
;
; DATA
;
SUBS1:	FDB	2			; SUBSCRIPT 1
SSUBS1:	FDB	8			; SIZE OF SUBSCRIPT 1 (NUMBER OF BYTES
					; PER ROW)
SUBS2:	FDB	4			; SUBSCRIPT 2
;
; THE ARRAY (3 ROWS OF 8 COLUMNS) 
;
ARY:
	FCB	 1, 2, 3, 4, 5, 6, 7, 8 
	FCB	 9,10,11,12,13,14,15,16
	FCB	17,18,19,20,21,22,23,24
	END
