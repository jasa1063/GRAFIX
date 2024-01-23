PAGE 60,132

;DEMO--Demonstration program of GRAFIX 1.0

;By Joseph A. Albrecht - Sep 1988

;*******************************************************************************
CSeg	Segment			;Define code segement

	Assume	CS:CSeg,DS:CSeg,ES:CSeg,SS:CSeg

	Org	100H		;COM files start at 100H

Begin:	Jmp	Main		;Skip past data

Delay	EQU	7

Not_Resident	DB 10,13,'GRAFIX not installed!',7,13,10,'$'
DemoMsg1	DB 'Lines And Flashing Boxes'
DemoMsg2	DB 'Circles And Paint Filling'
DemoMsg3	DB 'Animation'
AnyKey		DB 'Press Any Key To Continue'

;Palette arrays for demo part 1
PAL1		DW 0,1,13,3,4,5,11,7,8,9,10,2,12,6,14,15
PAL2		DW 0,1,6,3,4,5,2,7,8,9,10,13,12,11,14,15
PAL3		DW 0,1,11,3,4,5,13,7,8,9,10,6,12,2,14,15
PAL4		DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

Shape		DB 54 DUP(?)	;Storage area for animation figure

;-------------------------------------------------------------------------------

Main	Proc	Near

	Mov	AX,0EE80H	;See if GRAFIX is resident
	Mov	BX,0		; ..
	Int	10H		;  ..
	Cmp	AX,0DEADH	;   ..
	Je	GraphOK		;GRAFIX is resident, proceed with program
	Mov	AH,9		;GRAFIX is not resident, print error message
	Lea	DX,Not_Resident ; ..
	Int	21H		;  ..
	Int	20H		;   ..
GraphOK:
	Mov	AX,0EE80H	;Enable graphics functions
	Mov	BX,2		; ..
	Int	10H		;  ..

;Part 1 of demo - Line and box demo with changing palettes
	Call	ClearBuf	;Clear keyboard buffer
	Mov	AX,0EE19H	;Print demo 1 header
	Mov	BX,9		; ..
	Mov	CX,1		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,24		;      ..
	Lea	DX,DemoMsg1	;	..
	Int	10H		;	 ..
	Mov	AX,0EE19H	;Print Any Key... line
	Mov	BX,9		; ..
	Mov	CX,25		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,25		;      ..
	Lea	DX,AnyKey	;	..
	Int	10H		;	 ..
	Mov	AX,0EE0BH	;Draw 1st line in BLUE (Default)
	Mov	BX,10		; ..
	Mov	CX,10		;  ..
	Mov	SI,309		;   ..
	Mov	DI,189		;    ..
	Int	10H		;     ..
	Mov	AX,0EE02H	;Set next color to YELLOW
	Mov	BX,1		; ..
	Mov	CX,14		;  ..
	Int	10H		;   ..
	Mov	AX,0EE0BH	;Draw 2nd line
	Mov	BX,309		; ..
	Mov	CX,10		;  ..
	Mov	SI,10		;   ..
	Mov	DI,189		;    ..
	Int	10H		;     ..
	Mov	AX,0EE0EH	;Draw a line box in RED
	Mov	BX,10		; ..
	Mov	CX,10		;  ..
	Mov	SI,309		;   ..
	Mov	DI,189		;    ..
	Mov	DX,4		;     ..
	Int	10H		;      ..
	Mov	AX,0EE11H	;Draw a solid box in BROWN
	Mov	BX,135		; ..
	Mov	CX,19		;  ..
	Mov	SI,184		;   ..
	Mov	DI,68		;    ..
	Mov	DX,6		;     ..
	Int	10H		;      ..
	Mov	AX,0EE11H	;Draw a solid box in GREEN
	Mov	BX,135		; ..
	Mov	CX,131		;  ..
	Mov	SI,184		;   ..
	Mov	DI,180		;    ..
	Mov	DX,2		;     ..
	Int	10H		;      ..
	Mov	AX,0EE11H	;Draw a solid box in LT CYAN
	Mov	BX,19		; ..
	Mov	CX,74		;  ..
	Mov	SI,68		;   ..
	Mov	DI,123		;    ..
	Mov	DX,11		;     ..
	Int	10H		;      ..
	Mov	AX,0EE11H	;Draw a solid box in LT MAGENTA
	Mov	BX,251		; ..
	Mov	CX,74		;  ..
	Mov	SI,300		;   ..
	Mov	DI,123		;    ..
	Mov	DX,13		;     ..
	Int	10H		;      ..
Demo1:
	Mov	AX,0EE13H	;Change palette entries (Set 1)
	Lea	DX,PAL1		; ..
	Int	10H		;  ..
	Mov	AX,0EE83H	;Delay awhile
	Mov	BX,Delay	; ..
	Int	10H		;  ..
	Mov	AX,0EE13H	;Change palette entries (Set 2)
	Lea	DX,PAL2		; ..
	Int	10H		;  ..
	Mov	AX,0EE83H	;Delay awhile
	Mov	BX,Delay	; ..
	Int	10H		;  ..
	Mov	AX,0EE13H	;Change palette entries (Set 3)
	Lea	DX,PAL3		; ..
	Int	10H		;  ..
	Mov	AX,0EE83H	;Delay awhile
	Mov	BX,Delay	; ..
	Int	10H		;  ..
	Mov	AX,0EE13H	;Change palette entries (Set 4)
	Lea	DX,PAL4		; ..
	Int	10H		;  ..
	Mov	AX,0EE83H	;Delay awhile
	Mov	BX,Delay	; ..
	Int	10H		;  ..
	Call	CheckKey	;See if a key has been pressed
	Jnz	Demo2		;If so continue on with demo
	Jmp	Demo1		;Else, continue changing palettes

;Part 2 of demo - Draw circles and fill them with color
Demo2:
	Call	ClearBuf	;Clear keyboard buffer
	Mov	AX,0EE14H	;Reset the color palette
	Int	10H		; ..
	Mov	AX,0EE00H	;Clear the screen
	Int	10H		; ..
	Mov	AX,0EE19H	;Print demo 2 header
	Mov	BX,9		; ..
	Mov	CX,1		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,25		;      ..
	Lea	DX,DemoMsg2	;	..
	Int	10H		;	 ..
	Mov	AX,0EE19H	;Print Any Key... line
	Mov	BX,9		; ..
	Mov	CX,25		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,25		;      ..
	Lea	DX,AnyKey	;	..
	Int	10H		;	 ..
	Mov	AX,0EE02H	;Draw 1st circle in BLUE
	Mov	BX,1		; ..
	Mov	CX,1		;  ..
	Int	10H		;   ..
	Mov	AX,0EE0FH	;    ..
	Mov	SI,50		;     ..
	Mov	DI,100		;      ..
	Mov	BX,50		;	..
	Int	10H		;	 ..
	Mov	AX,0EE10H	;Fill 1st circle with YELLOW
	Mov	SI,50		; ..
	Mov	DI,100		;  ..
	Mov	BX,14		;   ..
	Mov	CX,1		;    ..
	Int	10H		;     ..
	Mov	AX,0EE04H	;Set aspect ratio of 2nd circle to 12/5
	Mov	BX,12		; ..
	Mov	CX,5		;  ..
	Int	10H		;   ..
	Mov	AX,0EE02H	;Draw 2nd circle in RED
	Mov	BX,1		; ..
	Mov	CX,4		;  ..
	Int	10H		;   ..
	Mov	AX,0EE0FH	;    ..
	Mov	SI,159		;     ..
	Mov	DI,100		;      ..
	Mov	BX,50		;	..
	Int	10H		;	 ..
	Mov	AX,0EE10H	;Fill 2nd circle with CYAN
	Mov	SI,159		; ..
	Mov	DI,100		;  ..
	Mov	BX,3		;   ..
	Mov	CX,4		;    ..
	Int	10H		;     ..
	Mov	AX,0EE04H	;Set aspect ratio of 3rd circle to 6/10
	Mov	BX,6		; ..
	Mov	CX,10		;  ..
	Int	10H		;   ..
	Mov	AX,0EE02H	;Draw 2nd circle in GREEN
	Mov	BX,1		; ..
	Mov	CX,2		;  ..
	Int	10H		;   ..
	Mov	AX,0EE0FH	;    ..
	Mov	SI,269		;     ..
	Mov	DI,100		;      ..
	Mov	BX,50		;	..
	Int	10H		;	 ..
	Mov	AX,0EE10H	;Fill 2nd circle with BROWN
	Mov	SI,269		; ..
	Mov	DI,100		;  ..
	Mov	BX,6		;   ..
	Mov	CX,2		;    ..
	Int	10H		;     ..
	Call	WaitKey		;Wait for a key to pressed

;Part 3 of demo - Animation
	Call	ClearBuf	;Clear keyboard buffer
	Mov	AX,0EE00H	;Clear the screen
	Int	10H		; ..
	Mov	AX,0EE0EH	;Draw a line box in BLUE
	Mov	BX,0		;     ..
	Mov	CX,0		;      ..
	Mov	SI,9		;	..
	Mov	DI,9		;	 ..
	Mov	DX,1		;	  ..
	Int	10H		;	   ..
	Mov	AX,0EE10H	;Fill line box with YELLOW
	Mov	SI,5		; ..
	Mov	DI,5		;  ..
	Mov	BX,14		;   ..
	Mov	CX,1		;    ..
	Int	10H		;     ..
	Mov	AX,0EE15H	;Store the image
	Mov	BX,0		; ..
	Mov	CX,0		;  ..
	Mov	SI,9		;   ..
	Mov	DI,9		;    ..
	Lea	DX,Shape	;     ..
	Int	10H		;      ..
	Mov	AX,0EE00H	;Clear the screen
	Int	10H		; ..
	Mov	AX,0EE19H	;Print demo 3 header
	Mov	BX,16		; ..
	Mov	CX,1		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,9		;      ..
	Lea	DX,DemoMsg3	;	..
	Int	10H		;	 ..
	Mov	AX,0EE19H	;Print Any Key... line
	Mov	BX,9		; ..
	Mov	CX,25		;  ..
	Int	10H		;   ..
	Mov	AX,0EE1BH	;    ..
	Mov	BX,0		;     ..
	Mov	CX,25		;      ..
	Lea	DX,AnyKey	;	..
	Int	10H		;	 ..
Animate1:
	Mov	AX,0EE1CH	;Set initial values for animation loop
	Mov	CX,60		; ..
	Lea	DX,Shape	;  ..
	Mov	SI,0		;   ..
	Mov	DI,95		;    ..
Animate2:
	Push	CX		;Save CX
	Mov	CX,25000	;Set delay for Animate function
	Int	10H		;Put the image on the screen
	Pop	CX		;Restore CX
	Push	AX		;Save AX
	Call	CheckKey	;Check if a key was pressed
	Pop	AX		;Restore AX
	Jnz	ExitPgm		;If key pressed then end program
	Add	SI,5		;Point to next position
	Loop	Animate2	;Move it across the screen
	Jmp	Animate1	;Do it again

;End program
ExitPgm:
	Call	ClearBuf	;Clear the keyboard buffer
	Mov	AX,0EE80H	;Return to 80x25 text mode
	Mov	BX,3		; ..
	Int	10H		;  ..
	Int	20H		;Return to caller

Main	Endp			;End of main program
;-------------------------------------------------------------------------------

WaitKey Proc	Near

	Call	ClearBuf	;Clear the keyboard buffer
	Mov	AH,0		;Now wait for a key to be pressed
	Int	16H		; ..
	Ret

WaitKey Endp

ClearBuf Proc	Near

ClearBuf1:
	Call	CheckKey	;Clear keyboard buffer
	Jz	ClearBuf2	; ..
	Mov	AH,0		;  ..
	Int	16H		;   ..
	Jmp	ClearBuf1	;    ..
ClearBuf2:
	Ret

ClearBuf Endp

CheckKey Proc	Near

	Mov	AH,1		;Check keyboard status
	Int	16H		; ..
	Ret			;  ..

CheckKey Endp

CSeg	Ends
;*******************************************************************************

	End	Begin
