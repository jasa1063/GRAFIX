;------------------------------------------------------------------------------;
; INT10A - Interface for GRAFIX 1.0 using Microsoft QuickBASIC 4.0	       ;
;									       ;
; By Joseph A. Albrecht - Sep 1988					       ;
;									       ;
; This is a quick and simple interface for GRAFIX 1.0 using Microsoft	       ;
; QuickBASIC 4.0.  I didn't want to use any of the BIOS interfacing routines   ;
; that came with QuickBASIC 4.0 because there was just to much overhead to     ;
; continually call GRAFIX.  This is about as short and sweet as it gets.  The  ;
; interface provides the ability to load the following CPU registers:  AX, BX, ;
; CX, DX, SI, DI, DS.  No registers are returned in this routine.  These are   ;
; all that are necessary to call GRAFIX.  You can make any changes you want if ;
; you decide to modify the GRAFIX program and need to add more registers at    ;
; that time.  The register values are passed using a 7 element integer array.  ;
; The order of the register values in the array are as follows:		       ;				;
;									       ;
;			       AX = 0					       ;
;			       BX = 1					       ;
;			       CX = 2					       ;
;			       DX = 3					       ;
;			       SI = 4					       ;
;			       DI = 5					       ;
;			       DS = 6					       ;
;									       ;
; See the file GRAFIX.BAS on how the calling interface works from QuickBASIC.  ;
;------------------------------------------------------------------------------;

DOSSEG

.MODEL MEDIUM

.CODE

PUBLIC INT10A

INT10A	PROC

	Push	BP		;Save compiler frame reference
	Mov	BP,SP		;Set up program frame reference
	Push	DS		;Save DS
	Lds	BX,[BP+6]	;Get address of 1st register buffer
	Mov	ES,[BX+2]	;Save BX register buffer value
	Mov	AX,[BX]		;Move values into registers for INT 10H
	Mov	CX,[BX+4]	; ..
	Mov	DX,[BX+6]	;  ..
	Mov	SI,[BX+8]	;   ..
	Mov	DI,[BX+10]	;    ..
	Mov	DS,[BX+12]	;     ..
	Mov	BX,ES		;      ..
	Int	10H		;Execute INT 10H
	Pop	DS		;Restore DS
	Pop	BP		;Restore compiler frame reference
	Ret	8		;Clean up stack and return

INT10A	ENDP

	END
