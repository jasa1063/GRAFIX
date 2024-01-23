	PAGE	60,132
	TITLE	Tandy 1000 Graphics And Sound Extensions
	NAME	GRAFIX

;------------------------------------------------------------------------------;
;									       ;
;				  GRAFIX 1.1				       ;
;									       ;
;		    Tandy 1000 Graphics And Sound Extensions		       ;
;		      320 x 200 x 16 Color Graphics Mode		       ;
;		     Texas Instruments SN76496 Sound Chip		       ;
;									       ;
;									       ;
;			      Joseph A. Albrecht			       ;
;			 9250 Old Cedar Ave   Apt. 215			       ;
;			    Bloomington, MN  55425			       ;
;									       ;
;									       ;
;   To create GRAFIX.COM do the following steps:			       ;
;									       ;
;     MASM GRAFIX;							       ;
;     LINK GRAFIX;							       ;
;     EXE2BIN GRAFIX GRAFIX.COM						       ;
;     ERASE GRAFIX.EXE							       ;
;     ERASE GRAFIX.OBJ							       ;
;									       ;
;									       ;
;   NOTE:  See the file GRAFIX.DOC for a complete description of each function ;
;	   used in this program.					       ;
;									       ;
;------------------------------------------------------------------------------;

Pushr	MACRO
	Push	AX
	Push	CX
	Push	DX
	Push	BX
	Push	BP
	Push	SI
	Push	DI
	ENDM

Popr	MACRO
	Pop	DI
	Pop	SI
	Pop	BP
	Pop	BX
	Pop	DX
	Pop	CX
	Pop	AX
	ENDM

Code	SEGMENT PARA PUBLIC 'Code'

	ASSUME	CS:Code,DS:Code,ES:Code,SS:Code

	ORG	100H

Start:
	Jmp	Setup		;Jump to TSR initialization code

	EVEN

Old10Int	DD	?	;Old Video BIOS interrupt vector address
Old1CInt	DD	?	;Old Clock Tick interrupt vector address
Save_SP		DW	?	;Save current Stack Pointer
Save_SS		DW	?	;Save current Stack Segment
Save_DS		DW	?	;Save Segment address of variables passed
Old_X		DW	?	;Last X ordinate value
Old_Y		DW	?	;Last Y ordinate value
X_Aspect	DW	?	;Horizontal part of aspect ratio
Y_Aspect	DW	?	;Vertical part of aspect ratio
D_Color		DB	?	;Current drawing color
B_Color		DB	?	;Current background color
T_Color		DB	?	;Current text color

	EVEN

Row		DW	?	;Current text row
Column		DW	?	;Current text column
Graph_Flag	DW	?	;Current graphics mode: On or Off
Cursor_Flag	DW	?	;Current cursor status:
				;  Bit 0 - Cursor mode: On or Off
				;  Bit 1 - Cursor size: Half or Full
Buf_Flag	DW	0	;Current sound buffer mode: On or Off
Timer_Flag	DW	0	;Timer interrupt flag mode: On or Off
				;  Bit 0 - Sound channel 0
				;  Bit 1 - Sound channel 1
				;  Bit 2 - Sound channel 2
				;  Bit 3 - Noise channel
				;  Bit 4 - Delay loop
Sound0_Ticks	DW	?	;# of clock ticks before turning off channel 0
Sound0_Cnt	DW	?	; .. Accumulator
Sound1_Ticks	DW	?	;# of clock ticks before turning off channel 1
Sound1_Cnt	DW	?	; .. Accumulator
Sound2_Ticks	DW	?	;# of clock ticks before turning off channel 2
Sound2_Cnt	DW	?	; .. Accumulator
Noise_Ticks	DW	?	;# of clock ticks before turning off noise
Noise_Cnt	DW	?	; .. Accumulator
Delay_Ticks	DW	?	;# of clock ticks before exiting delay loop
Delay_Cnt	DW	?	; .. Accumulator
PBuf_Ptr1	DW OFFSET Sound_Buf1 ;Sound buffer 1 pointer for putting sounds
PBuf_Ptr2	DW OFFSET Sound_Buf2 ;Sound buffer 2 pointer for putting sounds
PBuf_Ptr3	DW OFFSET Sound_Buf3 ;Sound buffer 3 pointer for putting sounds
PBuf_Ptr4	DW OFFSET Noise_Buf  ;Noise buffer pointer for putting noises
GBuf_Ptr1	DW OFFSET Sound_Buf1 ;Sound buffer 1 pointer for getting sounds
GBuf_Ptr2	DW OFFSET Sound_Buf2 ;Sound buffer 2 pointer for getting sounds
GBuf_Ptr3	DW OFFSET Sound_Buf3 ;Sound buffer 3 pointer for getting sounds
GBuf_Ptr4	DW OFFSET Noise_Buf  ;Moise buffer pointer for getting noises
Buf_Cnt1	DW	0	;Sound buffer 1 current total
Buf_Cnt2	DW	0	;Sound buffer 2 current total
Buf_Cnt3	DW	0	;Sound buffer 3 current total
Buf_Cnt4	DW	0	;Noise buffer current total

Temp_X		DW	?	;Variables used in circle drawing
Temp_Y		DW	?	; ..
Scale		DW	?	;  ..
Scale2		DW	?	;   ..
Aspect		DW	?	;    ..
InvAsp		DW	?	;     ..
XOrg		DW	?	;      ..
YOrg		DW	?	;	..
Radius		DW	?	;	 ..

Max		DW	?	;Variables used in common routines
X1		DW	?	;  ..
Y1		DW	?	;   ..
X2		DW	?	;    ..
Y2		DW	?	;     ..
Save_Clr	DB	?	;      ..


	EVEN

Cursor		DW	8	;Graphics cursor (Cyan color # 3)
CursorRows	DW	8
		DW   16 DUP (3333H)

;Scan line offset address table
ScanLine	DW 0000H,2000H,4000H,6000H,00A0H,20A0H,40A0H,60A0H,0140H,2140H
		DW 4140H,6140H,01E0H,21E0H,41E0H,61E0H,0280H,2280H,4280H,6280H
		DW 0320H,2320H,4320H,6320H,03C0H,23C0H,43C0H,63C0H,0460H,2460H
		DW 4460H,6460H,0500H,2500H,4500H,6500H,05A0H,25A0H,45A0H,65A0H
		DW 0640H,2640H,4640H,6640H,06E0H,26E0H,46E0H,66E0H,0780H,2780H
		DW 4780H,6780H,0820H,2820H,4820H,6820H,08C0H,28C0H,48C0H,68C0H
		DW 0960H,2960H,4960H,6960H,0A00H,2A00H,4A00H,6A00H,0AA0H,2AA0H
		DW 4AA0H,6AA0H,0B40H,2B40H,4B40H,6B40H,0BE0H,2BE0H,4BE0H,6BE0H
		DW 0C80H,2C80H,4C80H,6C80H,0D20H,2D20H,4D20H,6D20H,0DC0H,2DC0H
		DW 4DC0H,6DC0H,0E60H,2E60H,4E60H,6E60H,0F00H,2F00H,4F00H,6F00H
		DW 0FA0H,2FA0H,4FA0H,6FA0H,1040H,3040H,5040H,7040H,10E0H,30E0H
		DW 50E0H,70E0H,1180H,3180H,5180H,7180H,1220H,3220H,5220H,7220H
		DW 12C0H,32C0H,52C0H,72C0H,1360H,3360H,5360H,7360H,1400H,3400H
		DW 5400H,7400H,14A0H,34A0H,54A0H,74A0H,1540H,3540H,5540H,7540H
		DW 15E0H,35E0H,55E0H,75E0H,1680H,3680H,5680H,7680H,1720H,3720H
		DW 5720H,7720H,17C0H,37C0H,57C0H,77C0H,1860H,3860H,5860H,7860H
		DW 1900H,3900H,5900H,7900H,19A0H,39A0H,59A0H,79A0H,1A40H,3A40H
		DW 5A40H,7A40H,1AE0H,3AE0H,5AE0H,7AE0H,1B80H,3B80H,5B80H,7B80H
		DW 1C20H,3C20H,5C20H,7C20H,1CC0H,3CC0H,5CC0H,7CC0H,1D60H,3D60H
		DW 5D60H,7D60H,1E00H,3E00H,5E00H,7E00H,1EA0H,3EA0H,5EA0H,7EA0H

Paint_End:			 ;End of paint stack for overflow check
		DW  1024 DUP (?) ;Paint Stack
Paint_Stack:			 ; ..
PSP		DW  ?		;Save area for SP
Above		DB  160 DUP (?) ;Used in 'Paint' for copy of above scan line
Below		DB  160 DUP (?) ;Used in 'Paint' for copy of below scan line
Middle		DB  160 DUP (?) ;Used in 'Paint' for copy of middle scan line

Sound_Buf1	DW  256 DUP (?) ;Sound buffer 1 - Sound channel 0
Buf_End1:			;End of sound buffer 1
Sound_Buf2	DW  256 DUP (?) ;Sound buffer 2 - Sound channel 1
Buf_End2:			;End of sound buffer 2
Sound_Buf3	DW  256 DUP (?) ;Sound buffer 3 - Sound channel 2
Buf_End3:			;End of sound buffer 3
Noise_Buf	DW  192 DUP (?) ;Noise buffer - Noise channel
Buf_End4:			;End of noise buffer

;CALL table for GRAFIX functions
Functions	LABEL WORD
	DW	OFFSET Clear_Screen	;00 - Clear screen
	DW	OFFSET Color_Enable	;01 - Set color enable on/off
	DW	OFFSET Set_Color	;02 - Set color
	DW	OFFSET Get_Color	;03 - Get color
	DW	OFFSET Set_Aspect	;04 - Set aspect ratio
	DW	OFFSET Get_Aspect	;05 - Get aspect ratio
	DW	OFFSET Point		;06 - Set pixel at X,Y
	DW	OFFSET Get_Point	;07 - Get pixel color at X,Y
	DW	OFFSET Move_To		;08 - Move to X,Y
	DW	OFFSET Move_Rel		;09 - Move relative from X,Y
	DW	OFFSET Get_XY		;10 - Get current X,Y
	DW	OFFSET Line		;11 - Line
	DW	OFFSET Line_To		;12 - Line to X,Y
	DW	OFFSET Line_Rel		;13 - Line relative from X,Y
	DW	OFFSET Draw_Box		;14 - Draw box
	DW	OFFSET Circle		;15 - Draw circle
	DW	OFFSET Paint		;16 - Paint graphics shape
	DW	OFFSET Fill_Box		;17 - Fill rectangle
	DW	OFFSET Set_Palette	;18 - Change palette register
	DW	OFFSET Palette_Using	;19 - Change all 16 palette registers
	DW	OFFSET Reset_Palette	;20 - Reset all palette registers
	DW	OFFSET Get		;21 - Store a graphic image
	DW	OFFSET Put		;22 - Transfer an graphic image
	DW	OFFSET Set_Cursor	;23 - Set cursor mode
	DW	OFFSET Get_Cursor	;24 - Get cursor status
	DW	OFFSET Set_Cursor_Pos	;25 - Set cursor position
	DW	OFFSET Get_Cursor_Pos	;26 - Get cursor position
	DW	OFFSET Print_String	;27 - Print a string
	DW	OFFSET Animate		;28 - Animate an image
	DW	OFFSET PointC		;29 - Set pixel at X,Y
	DW	OFFSET LineC		;30 - Line
	DW	OFFSET Line_ToC		;31 - Line to X,Y
	DW	OFFSET Line_RelC	;32 - Line relative from X,Y
	DW	OFFSET CircleC		;33 - Draw circle
	DW	OFFSET Draw_BoxC	;34 - Draw box
	DW	OFFSET Fill_BoxC	;35 - Fill box
	DW	92 DUP (OFFSET None)	;Filler
	DW	OFFSET System		;80H - Global system functions
	DW	OFFSET Sound		;81H - Generate a sound
	DW	OFFSET Noise		;82H - Generate a noise
	DW	OFFSET Delay		;83H - Delay loop
	DW	124 DUP (OFFSET None)	;Filler

NewInt10:
	Cmp	AH,0EEH		;Test for a function call
	Je	Check
	Jmp	DWORD PTR CS:[Old10Int] ;Execute the normal video BIOS

Check:
	Cmp	AL,80H		;Check for a graphics call
	Jae	Check1		; ..
	Test	CS:[Graph_Flag],1 ;See if graphics active
	Jnz	Check1		  ; ..
	Iret			  ;  ..
Check1:
	Cli			;Critical code -- interrupts off
	Mov	CS:[Save_SP],SP ;Save current task SP
	Mov	CS:[Save_SS],SS ;Save current task SS
	Sti			;Re-enable interrupts
	Mov	CS:[Save_DS],DS ;Save segment address for variables passed
	Mov	SP,CS		;Set SS to current code segment
	Mov	SS,SP		; ..
	Mov	SP,0100H	;Use our PSP for stack
	Pushr			;Save registers
	Push	DS		; ..
	Push	ES		;  ..
	Mov	BP,CS		;Establish Data Segment for INT 10H extension
	Mov	DS,BP		; ..
	Mov	BP,0B800H	;Point ES at video segment
	Mov	ES,BP		; ..
	Xor	AH,AH		;Index into functions table
	Shl	AX,1		; ..
	Mov	BP,AX		;  ..
	Call	Functions[BP]	;Call requested function
Exit_Grafix:
	Pop	ES		;Restore registers
	Pop	DS		; ..
	Popr			;  ..
	Cli			;Critical code -- interrupts off
	Mov	SP,CS:[Save_SP] ;Restore original stack values
	Mov	SS,CS:[Save_SS] ; ..
	Sti			;Re-enable interrupts
	Iret			;Return to interrupted program

;
;Dummy function for blank CALL table entries
;

None:
	Ret

;
;Clear the graphics screen to the current background color
;

Clear_Screen:
	Mov	BX,0		;Use 'Fill_Box' to fill entire screen with
	Mov	CX,0		; current background color
	Mov	SI,319		;  ..
	Mov	DI,199		;   ..
	Mov	DX,0		;    ..
	Call	Fill_Box	;     ..
	Mov	BX,1		;Reset cursor to 1,1
	Mov	CX,1		; ..
	Call	Set_Cursor_Pos	;  ..
	Ret

;
;Turn the color enable off/on
;

Color_Enable:
	Cmp	BX,0		;Turn enable color off?
	Jne	Color_Enable1	;No
	Xor	AX,AX		;Point to BIOS data area
	Mov	ES,AX
	Mov	AL,ES:[0465H]	;Get BIOS copy of mode select register
	Mov	DX,3D8H		;Port # of mode select register
	Or	AL,4		;Turn color enable bit off
	Mov	ES:[0465H],AL	;Write new copy to BIOS area
	Out	DX,AL		;Turn the color enable off
	Ret
Color_Enable1:
	Cmp	BX,1		;Turn color enable on?
	Jne	Color_Enable2	;No
	Xor	AX,AX		;Point to BIOS data area
	Mov	ES,AX
	Mov	AL,ES:[0465H]	;Get BIOS copy of mode select register
	Mov	DX,3D8H		;Port # of mode select register
	And	AL,3BH		;Turn color enable bit on
	Mov	ES:[0465H],AL	;Write new copy to BIOS area
	Out	DX,AL		;Turn the color enable on
Color_Enable2:
	Ret

;
;Set the current drawing, text, background color
;

Set_Color:
	Cmp	BX,1		;Set drawing color?
	Jne	Set_Color2	;No
	Mov	[D_Color],CL	;Set the drawing color
	Ret
Set_Color2:
	Cmp	BX,2		;Set text color?
	Jne	Set_Color3	;No
	Mov	[T_Color],CL	;Set the text color
	Ret
Set_Color3:
	Cmp	BX,3		;Set background color?
	Jne	Set_Color4	;No
	Mov	[B_Color],CL	;Set the background color
	Mov	AH,11		;Fake an INT 10H interrupt
	Mov	BH,0		; ..
	Mov	BL,CL		;  ..
	PushF			;   ..
	Call	DWORD PTR CS:[Old10Int]
Set_Color4:
	Ret

;
;Get the current draw, text, background color
;

Get_Color:
	Cmp	BX,1		;Get the drawing color
	Jne	Get_Color2	;No
	Mov	CL,[D_Color]	;Yes, get the drawing color
	Xor	CH,CH		;Clear upper half of CX
	Mov	SS:[0FCH],CX	;Store in CX position on stack
	Ret
Get_Color2:
	Cmp	BX,2		;Get the text color
	Jne	Get_Color3	;No
	Mov	CL,[T_Color]	;Yes, get the text color
	Xor	CH,CH		;Clear upper half of CX
	Mov	SS:[0FCH],CX	;Store in CX position on stack
	Ret
Get_Color3:
	Cmp	BX,3		;Get the background color
	Jne	Get_Color4	;No
	Mov	CL,[B_Color]	;Yes, get the background color
	Xor	CH,CH		;Clear upper half of CX
	Mov	SS:[0FCH],CX	;Store in CX position on stack
Get_Color4:
	Ret

;
;Set the aspect ratio for circle drawing
;

Set_Aspect:
	Mov	[X_Aspect],BX	;Store X & Y aspect ratio components
	Mov	[Y_Aspect],CX	; ..
	Ret

;
;Get the current aspect ratio for circle drawing
;

Get_Aspect:
	Mov	BX,[X_Aspect]	;Get X aspect ratio component
	Mov	SS:[0F8H],BX	;Store in BX position on stack
	Mov	CX,[Y_Aspect]	;Get Y aspect ratio component
	Mov	SS:[0FCH],CX	;Store in CX position on stack
	Ret

;
;Internal  pixel writing  routine used	 by 'Point',  'Line', and  'Circle'.
;

$Point:
	Cmp	SI,319		;Validate X
	Ja	$Point1		; ..
	Cmp	SI,0		;  ..
	Jb	$Point1		;   ..
	Cmp	DI,199		;Validate Y
	Ja	$Point1		; ..
	Cmp	DI,0		;  ..
	Jnb	$Point2		;   ..
$Point1:
	Ret			;X or Y out of range so exit

;Get video offset address
$Point2:
	Mov	BX,DI		;Put offset address in DI from table
	Shl	BX,1		; ..
	Mov	BX,ScanLine[BX] ;  ..
	Mov	DX,SI		;Add column offset (Col / 2)
	Shr	DX,1		; ..
	Add	BX,DX		;  ..

;Plot the point
	Mov	DL,[D_Color]	;Get color for pixel
	Mov	DH,0F0H		;Set mask for odd pixel
	Test	SI,1		;Check for odd/even pixel
	Jnz	$Point3		; ..
	Not	DH		;Set mask for even pixel
	Shl	DL,1		;Move to left nybble
	Shl	DL,1		; ..
	Shl	DL,1		;  ..
	Shl	DL,1		;   ..
$Point3:
	And	ES:[BX],DH	;Plot the point
	Or	ES:[BX],DL	; ..
	Ret

;
;Plot a point using the specified color
;

PointC:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Call	$Point		;Plot the point
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Plot a point using the current drawing color
;

Point:
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Jmp	$Point		;Plot the point

;
;Get the pixel color a point X,Y
;

Get_Point:
	Shl	DI,1		;Put offset address in DI from table
	Mov	DI,ScanLine[DI] ; ..
	Mov	AX,SI		;Add column offset (Col / 2)
	Shr	AX,1		; ..
	Add	DI,AX		;  ..
	Mov	AL,ES:[DI]	;Get byte from video memory
	Test	SI,1		;Test for odd/even pixel
	Jnz	Get_Point1
	Shr	AL,1		;Move color lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
Get_Point1:
	And	AX,0FH		;Mask off unwanted bits
	Mov	SS:[0FEH],AX	;Store in AX position on stack
	Ret

;
;Move to the specified position from Old_X, Old_Y without plotting any points
;

Move_To:
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Ret

;
;Move a relative distance from Old_X, Old_Y without plotting any points
;

Move_Rel:
	Mov	AX,[Old_X]	;Calculate relative position
	Add	AX,SI		; ..
	Mov	BX,[Old_Y]	;  ..
	Add	BX,DI		;   ..
	Mov	[Old_X],AX	;Update old X,Y values
	Mov	[Old_Y],BX	; ..
	Ret

;
;Get current X,Y position
;

Get_XY:
	Mov	BX,[Old_X]	;Return the current X position
	Mov	SS:[0F8H],BX	;Store in BX position on stack
	Mov	CX,[Old_Y]	;Return the current Y position
	Mov	SS:[0FCH],CX	;Store in CX position on stack
	Ret

;
;Internal  primative  line  drawing  algorithm	 used  by  'Line'  and	'Circle'
;procedures. Uses  Breshenham's fast differential  integer line algorithm.  This
;algorithm finds the closet integer coordinates  to the actual line's path using
;only integer arithmetic and is very fast.
;
;NOTE:	This  function uses  self modifying  code techniques  to achieve optimum
;	speed. While this is frowned upon by most ethical programmers, I decided
;	to use it  none-the-less. If you don't like it,  feel free to change the
;	source code to suit your own tastes.
;

$Line:
;Setup X and Y updates
	Mov	DL,1		;Start with positive 1 for X update
	Mov	DH,1		;Start with positive 1 for Y update

;Find (Y2 - Y1)
	Sub	DI,BX		;Subtract Y1
	Jge	StoreY		;Skip if (Y2 - Y1) is nonnegative
	Neg	DH		;Move in negative Y direction
	Neg	DI		;Absolute value of (Y2 - Y1)

;Store Y update for diagonal move
StoreY:
	Mov	BYTE PTR [Diagonal+5],DH ;Modifies:  Add     DI,0

;Find (X2 - X1)
	Sub	SI,AX		;Subtract X1
	Jge	StoreX		;Skip if (X2 - X1) is nonnegative
	Neg	DL		;Move in negative X direction
	Neg	SI		;Absolute value of (X2 - X1)

;Store X update for diagonal move
StoreX:
	Mov	BYTE PTR [Diagonal+2],DL ;Modifies:  Add     SI,0

;Sort (Y2 - Y1) and (X2 - X1)
	Cmp	SI,DI		;Compare Dels with Delp
	Jge	SetDiag		;Skip if straight moves in X direction
	Xor	DL,DL		;If straight=vertical: kill X update
	Xchg	SI,DI		;  and exchange differences
	Jmp	StoreDelsXY
SetDiag:
	Xor	DH,DH		;If straight=horizontal: kill Y update

;Store X and Y updates for straight move
StoreDelsXY:
	Mov	BYTE PTR [Straight+2],DL ;Modifies:  Add     SI,0
	Mov	BYTE PTR [Straight+5],DH ;Modifies:  Add     DI,0

;Get initial line values
	Mov	DX,AX		;Save X1
	Mov	AX,DI		;Straight move
	Shl	AX,1		; .. (Delp * 2)
	Mov	WORD PTR [Straight+7],AX ;Modifies:  Add     AX,0
	Sub	AX,SI		;Initial value for error term
				;  .. (Delp * 2) - Dels
	Sub	AX,SI		;Diagonal move
				; .. (2 * Delp) - (2 * Dels)
	Mov	WORD PTR [Diagonal+7],AX ;Modifies:  Add     AX,0
	Mov	CX,SI		;Get pixel count
	Inc	CX		; ..
	Mov	SI,DX		;Restore X1
	Mov	DI,BX		;Get Y1

;Main pixel setting loop
$Line_Loop:
	Call	$Point		;Plot the point
	Cmp	AX,0		;Determine straight or diagonal move
	Jge	Diagonal	; ..

;Case for staight move
Straight:
	Add	SI,0		;Update X, Y
	Add	DI,0		; ..
	Add	AX,0		;Update error term
	Loop	$Line_Loop	;Do next pixel
	Ret

;Case for diagonal move
Diagonal:
	Add	SI,0		;Update X, Y
	Add	DI,0		; ..
	Add	AX,0		;Update error term
	Loop	$Line_Loop	;Do next pixel
	Ret

;
;Draw a line from X1,Y1 - X2,Y2 using the specified color
;

LineC:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Mov	AX,BX		;Setup proper values for $Line
	Mov	BX,CX		; ..
	Call	$Line		;Plot the line
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw a line from X1,Y1 - X2,Y2 using the current drawing color
;

Line:
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Mov	AX,BX		;Setup proper values for $Line
	Mov	BX,CX		; ..
	Jmp	$Line		;Plot the line

;
;Draw a  line to the  specified position from  Old_X, Old_Y using  the specified
;color
;

Line_ToC:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Mov	AX,SI		;Setup proper values for $Line
	Mov	BX,DI		; ..
	Mov	SI,[Old_X]	;  ..
	Mov	DI,[Old_Y]	;   ..
	Mov	[Old_X],AX	;Update old X,Y values
	Mov	[Old_Y],BX	; ..
	Call	$Line		;Plot the line
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw  a line  to the  specified position  from Old_X,	Old_Y using  the current
;drawing color
;

Line_To:
	Mov	AX,SI		;Setup proper values for $Line
	Mov	BX,DI		; ..
	Mov	SI,[Old_X]	;  ..
	Mov	DI,[Old_Y]	;   ..
	Mov	[Old_X],AX	;Update old X,Y values
	Mov	[Old_Y],BX	; ..
	Jmp	$Line		;Plot the line

;
;Draw a  line a relative  distance from Old_X,	Old_Y using the  specified color
;

Line_RelC:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Mov	AX,[Old_X]	;Calculate relative position
	Add	AX,SI		; ..
	Mov	BX,[Old_Y]	;  ..
	Add	BX,DI		;   ..
	Xchg	AX,SI		;Setup proper values for $Line
	Xchg	BX,DI		; ..
	Mov	AX,[Old_X]	;  ..
	Mov	BX,[Old_Y]	;   ..
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Call	$Line		;Plot the line
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw a  line a relative  distance from Old_X,	Old_Y using the  current drawing
;color
;

Line_Rel:
	Mov	AX,[Old_X]	;Calculate relative position
	Add	AX,SI		; ..
	Mov	BX,[Old_Y]	;  ..
	Add	BX,DI		;   ..
	Xchg	AX,SI		;Setup proper values for $Line
	Xchg	BX,DI		; ..
	Mov	AX,[Old_X]	;  ..
	Mov	BX,[Old_Y]	;   ..
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Jmp	$Line		;Plot the line

;
;Draw a line box from X1,Y1 - X2,Y2 using the specified color
;

Draw_Box:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Call	Draw_BoxC	;Draw the box
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw a line box from X1,Y1 - X2,Y2 using the current drawing color
;

Draw_BoxC:
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Mov	[X1],BX		;Store X1, Y1, X2, Y2
	Mov	[Y1],CX		; ..
	Mov	[X2],SI		;  ..
	Mov	[Y2],DI		;   ..
	Mov	AX,[X1]		;Draw top horizontal line of box
	Mov	BX,[Y1]		; ..
	Mov	SI,[X2]		;  ..
	Mov	DI,[Y1]		;   ..
	Call	$Line		;    ..
	Mov	AX,[X1]		;Draw bottom horizontal line of box
	Mov	BX,[Y2]		; ..
	Mov	SI,[X2]		;  ..
	Mov	DI,[Y2]		;   ..
	Call	$Line		;    ..
	Mov	AX,[X1]		;Draw left vertical line of box
	Mov	BX,[Y1]		; ..
	Mov	SI,[X1]		;  ..
	Mov	DI,[Y2]		;   ..
	Call	$Line		;    ..
	Mov	AX,[X2]		;Draw right vertical line of box
	Mov	BX,[Y1]		; ..
	Mov	SI,[X2]		;  ..
	Mov	DI,[Y2]		;   ..
	Call	$Line		;    ..
	Ret

;
;Draw a circle at origin X,Y with the specified radius using the specified color
;

CircleC:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Call	Circle		;Draw the circle
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw a circle at origin X,Y with the specified radius using the current drawing
;color.
;
;(Dan Lee 07/01/82, SourceWare)
;

Circle:
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Mov	[XOrg],SI	;Store origin
	Mov	[YOrg],DI	; ..
	Or	BX,BX		;Check radius
	Jnz	Ok_Rad		; ..
	Call	$Point		;Simple case --> Only a point where R = 0
	Ret
Ok_Rad:
	Mov	[Radius],BX	;Store Radius
	Mov	AX,1024		;Store Scale
	Mov	[Scale],AX	; ..
	Shr	AX,1		;Store Scale2
	Mov	[Scale2],AX	; ..
	Mov	AX,[Y_Aspect]	;Get aspect
	Mul	[Scale]		;AX = Y_Aspect * Scale
	Shl	AX,1		; ..
	Div	[X_Aspect]	;AX = (Y_Aspect * Scale) / X_Aspect
	Inc	AX		; ..
	Shr	AX,1		;  ..
	Mov	[Aspect],AX	;Store Aspect * Scale
	Mov	AX,[X_Aspect]	;Get X_Aspect in AX
	Mul	[Scale]		;AX = X_Aspect * Scale
	Shl	AX,1		; ..
	Div	[Y_Aspect]	;AX = (X_Aspect * Scale) / Y_Aspect
	Inc	AX		; ..
	Shr	AX,1		;  ..
	Mov	[InvAsp],AX	;Store Inv Aspect * Scale

;Plot 0 to 45 degrees.
;Increase Y by one unit and
;decrease X by TAN units*Inv Aspect ratio.

	Mov	AX,[Radius]	;Get radius for initial X
	Mul	[Scale]		;AX = Radius * Scale
	Xor	DI,DI		;Zero initial Y value
	Push	AX		;Save lo word X * Scale
	Push	DX		;Save hi word X * Scale
	Add	AX,[Scale2]
	Adc	DX,0
	Div	[Scale]
	Mov	[Temp_X],AX	;Temp_X, Temp_Y are old relative coord's
	Mov	[Temp_Y],DI	;    ..
	Pop	DX
	Pop	AX
Circle_Loop1:
	Push	AX		;Save lo word X * Scale
	Push	DX		;Save hi word X * Scale
	Add	AX,[Scale2]
	Adc	DX,0
	Div	[Scale]
	Mov	BX,AX		;BX = 1st quad X
	Add	AX,[XOrg]	;Add X origin
	Push	BP
	Push	DI		;Relative Y-coord
	Push	BX		;Relative X-coord
	Mov	BP,SP
	Mov	BX,[YOrg]	;Get Y origin
	Sub	BX,DI		;and sub Y to plot

;BP points to rel X coord and BP+2 points to rel Y coord
;ABS coords of point are in AX,BX
	Mov	SI,[Temp_X]	;SI is old abs X
	Add	SI,[XOrg]	; ..
	Mov	DI,[YOrg]	;DI is old abs Y
	Mov	CX,[Temp_Y]	; ..
	Sub	DI,CX		;  ..
	Pushr			;Write 1st quad point
	Call	$Line		; ..
	Popr			;  ..
	Sub	AX,[BP]		;Get 2nd quad X + origin
	Sub	AX,[BP]		; ..
	Sub	SI,[Temp_X]	;  ..
	Sub	SI,[Temp_X]	;   ..
	Pushr			;Write 2nd quad point
	Call	$Line		; ..
	Popr			;  ..
	Add	BX,[BP+2]	;Get 3rd quad Y + origin
	Add	BX,[BP+2]	; ..
	Add	DI,[Temp_Y]	;  ..
	Add	DI,[Temp_Y]	;   ..
	Pushr			;Write 3rd quad point
	Call	$Line		; ..
	Popr			;  ..
	Add	AX,[BP]		;Get 4th quad X + origin
	Add	AX,[BP]		; ..
	Add	SI,[Temp_X]	;  ..
	Add	SI,[Temp_X]	;   ..
	Pushr			;Write 4th quad point
	Call	$Line		; ..
	Popr			;  ..

	Pop	CX		;1st quad X val
	Pop	DI
	Mov	[Temp_X],CX
	Mov	[Temp_Y],DI
	Pop	BP
;CX = 1st quad X, DI = 1st quad Y
	Inc	DI		;Get new Y
	Mov	AX,DI		;AX = Y
	Mul	[InvAsp]	;AX = Y * Inv Aspect * Scale
	Div	CX		;AX = TAN * Inv Aspect * Scale
	Xor	DX,DX		;Zero remainder
	Mov	SI,AX		;SI = TAN * Inv Aspect * Scale
	Div	[InvAsp]	;AX = TAN
	Cmp	AX,1		;TAN = 1?
	Pop	DX		;DX = Hi word X * Scale
	Pop	AX		;AX = Lo word X * Scale
	Jae	Part2		;Yes, go to next sector
	Neg	SI		;to decrement X
	Add	AX,SI		;New X value
	Adc	DX,-1		;Hi word carry
	Jmp	Circle_Loop1	;Plot new point

;Plot 45 to 90 degrees.
;Decrease X by one unit and
;increase Y by COT units * aspect ratio.

Part2:
	Mov	AX,DI		;Get next Y to plot
	Mul	[Scale]		;DX:AX = Y * Scale
	Mov	DI,CX		;DI = Last X value
	Dec	DI		;Next X to plot
Circle_Loop2:
	Push	AX		;Save lo word Y * Scale
	Push	DX		;Save hi word Y * Scale
	Add	AX,[Scale2]	;'one-half'
	Adc	DX,0
	Div	[Scale]		;AX = Y
	Mov	BX,AX		;BX = 1st quad Y coord
	Add	AX,[YOrg]	;Add Y origin
	Mov	CX,[XOrg]	;CX = X origin
	Add	CX,DI		;X to plot
	Push	BP
	Push	BX
	Push	DI
	Mov	BP,SP
	Mov	BX,AX
	Mov	AX,CX

;BP points to rel X coord and BP+2 points to rel Y coord
;ABS coords of point are in AX,BX
	Mov	SI,[Temp_X]	;SI is old abs X
	Add	SI,[XOrg]	; ..
	Mov	DI,[YOrg]	;DI is old abs Y
	Add	DI,[Temp_Y]	; ..
	Pushr			;Write 1st quad point
	Call	$Line		; ..
	Popr			;  ..
	Sub	AX,[BP]		;Get 2nd quad X + origin
	Sub	AX,[BP]		; ..
	Sub	SI,[Temp_X]	;  ..
	Sub	SI,[Temp_X]	;   ..
	Pushr			;Write 2nd quad point
	Call	$Line		; ..
	Popr			;  ..
	Sub	BX,[BP+2]	;Get 3rd quad Y + origin
	Sub	BX,[BP+2]	; ..
	Sub	DI,[Temp_Y]	;  ..
	Sub	DI,[Temp_Y]	;   ..
	Pushr			;Write 3rd quad point
	Call	$Line		; ..
	Popr			;  ..
	Add	AX,[BP]		;Get 4th quad X + origin
	Add	AX,[BP]		; ..
	Add	SI,[Temp_X]	;  ..
	Add	SI,[Temp_X]	;   ..
	Pushr			;Write 4th quad point
	Call	$Line		; ..
	Popr			;  ..

	Pop	DI
	Pop	BX
	Mov	[Temp_X],DI
	Mov	[Temp_Y],BX
	Pop	BP
	Or	DI,DI		;90 degrees?
	Js	Circle_Exit	;Yes, exit
	Dec	DI		;Get new X
	Mov	AX,DI		;AX = X
	IMul	[Aspect]	;AX X * Aspect * Scale
	IDiv	BX		;AX = COT * Aspect * Scale
	Mov	SI,AX		;SI = Change in Y
	Pop	DX		;DX = Hi word Y * Scale
	Pop	AX		;AX = Lo word Y * Scale
	Xor	BX,BX
	Or	SI,SI		;For sign check
	Jns	Skip_It		;Positive
	Mov	BX,-1		;Negative carry
Skip_It:
	Add	AX,SI		;AX = New X value
	Adc	DX,BX
	Jmp	Circle_Loop2	;Plot next point
Circle_Exit:
	Add	SP,4		;Release parms
	Ret

;
;Paint the  enclosed figure starting  at X,Y with  the specified color	which is
;surrounded by the specified boundry color.
;
;
;This is a modified version of a paint routine from:
;  'Bluebook of Assembly Language Routines for the IBM PC & XT'
;  by Christopher L. Morgan
;  The Waite Group, 1984
;

;MACRO to push X,Y onto the paint stack
PushPaint MACRO
	LOCAL	PushPaint1
	Cmp	SP,OFFSET Paint_End ;Check for stack overflow
	Ja	PushPaint1	;No stack overflow
	Cli			;Critical code -- interrupts off
	Mov	SP,[PSP]	;Restore SP
	Sti			;Re-enable interrupts
	Ret
PushPaint1:
	Push	SI		;Push X
	Push	DI		;Push Y
	ENDM

;MACRO to get the color at X,Y (Above & below scan lines)
GetAB	MACRO
	LOCAL	GetAB1
	Mov	BP,SI		;Index into scan lines
	Shr	BP,1		; ..
	Mov	BL,Above[BP]	;Above scan line color in BL
	Mov	BH,Below[BP]	;Below scan line color in BH
	Jc	GetAB1		;Check for odd pixel
	Shr	BX,CL		;Move to lower nybble
GetAB1:
	And	BX,0F0FH	;Mask off unwanted bits
	ENDM

;MACRO to get the color at X,Y (Middle scan line)
GetM	MACRO
	LOCAL	GetM1
	Mov	BP,SI		;Index into scan line
	Shr	BP,1		; ..
	Mov	BL,Middle[BP]	;Middle scan line color in BL
	Jc	GetM1		;Check for odd pixel
	Shr	BL,CL		;Move to lower nybble
GetM1:
	And	BL,CH		;Mask off unwanted bits
	ENDM

;Initialize paint color & paint stack
Paint:
	Cld			;Make sure string operations go forward
	Mov	DH,CL		;Boundry color in DH
	Mov	DL,BL		;Fill color in DL
	Cli			;Critical code -- interrupts off
	Mov	[PSP],SP	;Save SP
	Mov	SP,OFFSET Paint_Stack ;Set SP to top of stack
	Sti			;Re-enable interrupts
	PushPaint		;Push seed onto stack

;Main loop for painting
Paint1:
	Cmp	SP,OFFSET Paint_Stack ;Stack empty?
	Jne	Paint2		;If not continue
	Cli			;Critical code -- interrupts off
	Mov	SP,[PSP]	;Restore SP
	Sti			;Re-enable interrupts
	Ret

;Get the next place to paint
Paint2:
	Pop	DI		;Pop the next place to paint
	Pop	SI		; ..

;Copy above, middle, & below scan lines
	Mov	BX,SI		;Save current X
	Mov	AX,DS		;Put DS into ES
	Mov	ES,AX		; ..
	Mov	AX,0B800H	;Point DS at video segment
	Mov	DS,AX		; ..
	Mov	AX,DI		;Save current Y
	Mov	SI,AX		   ;Copy above scan line
	Dec	SI		   ; ..
	Shl	SI,1		   ;  ..
	Mov	SI,CS:ScanLine[SI] ;   ..
	Mov	DI,OFFSET Above    ;	..
	Mov	CX,80		   ;	 ..
	Rep	Movsw		   ;	  ..
	Mov	SI,AX		   ;Copy middle scan line
	Shl	SI,1		   ; ..
	Mov	SI,CS:ScanLine[SI] ;  ..
	Mov	DI,OFFSET Middle   ;   ..
	Mov	CX,80		   ;	..
	Rep	Movsw		   ;	 ..
	Mov	SI,AX		   ;Copy below scan line
	Inc	SI		   ; ..
	Shl	SI,1		   ;  ..
	Mov	SI,CS:ScanLine[SI] ;   ..
	Mov	DI,OFFSET Below    ;	..
	Mov	CX,80		   ;	 ..
	Rep	Movsw		   ;	  ..
	Mov	DI,AX		;Restore current Y
	Mov	AX,ES		;Restore DS
	Mov	DS,AX		; ..
	Mov	SI,BX		;Restore current X

;Get initial color
	Mov	CL,4		;Set up shift count
	Mov	CH,0FH		;Set up bit mask
	GetM			;Get initial color
	Cmp	BL,DL		;Is it filled?
	Je	GOTOPaint1
	Cmp	BL,DH		;Is it boundry?
	Je	GOTOPaint1
	Cmp	DI,0		;Top of screen?
	Jl	GOTOPaint1
	Cmp	DI,199		;Bottom of screen?
	Jg	GOTOPaint1
	Jmp	SHORT Paint3
GOTOPaint1:
	Jmp	Paint1

;Move right until boundry is reached
Paint3:
	Inc	SI		;X <-- X + 1
	Cmp	SI,319		;At right screen boundry
	Jg	Paint4
	GetM			;Look right
	Cmp	BL,DL		;Is it filled?
	Je	Paint4
	Cmp	BL,DH		;Is it boundry?
	Je	Paint4
	Jmp	SHORT Paint3

;Push above and below
Paint4:
	Dec	SI		;Restore X
	GetAB			;Check above & below
	Mov	AH,BL		;Save above state
	Cmp	BL,DL		;Is it filled?
	Je	Paint5
	Cmp	BL,DH		;Is it boundry?
	Je	Paint5
	Dec	DI		;Y <-- Y - 1
	PushPaint		;Push above
	Inc	DI		;Restore Y
Paint5:
	Mov	AL,BH		;Save below state
	Cmp	BH,DL		;Is it filled?
	Je	Paint6
	Cmp	BH,DH		;Is it boundry?
	Je	Paint6
	Inc	DI		;Y <-- Y + 1
	PushPaint		;Push below
	Dec	DI		;Restore Y
Paint6:

;Anchor the end point of the scan line
	Mov	ES,SI		;Store X ordinate end of scan line

;Scan left, check above and below
Paint7:
	GetAB			;Check above & below
	Cmp	BL,DL		;Is it filled?
	Je	Paint9
	Cmp	BL,DH		;Is it boundry?
	Je	Paint9
	Cmp	AH,DL		;Last above filled?
	Je	Paint8
	Cmp	AH,DH		;Last above boundry?
	Je	Paint8
	Jmp	SHORT Paint9
Paint8:
	Dec	DI		;Y <-- Y - 1
	PushPaint		;Push above if new place to paint
	Inc	DI		;Restore Y

Paint9:
	Mov	AH,BL		;Update last above

;Check below
	Cmp	BH,DL		;Is it filled?
	Je	Paint11
	Cmp	BH,DH		;Is it boundry?
	Je	Paint11
	Cmp	AL,DL		;Last below filled?
	Je	Paint10
	Cmp	AL,DH		;Last below boundry?
	Je	Paint10
	Jmp	SHORT Paint11
Paint10:
	Inc	DI		;Y <-- Y + 1
	PushPaint		;Push below if new place to paint
	Dec	DI		;Restore Y

Paint11:
	Mov	AL,BH		;Update last below

;Move left
	Dec	SI		;X <-- X - 1
	Jl	Paint12		;Stop the scan if too far left
	GetM			;Check the point
	Cmp	BL,DL		;Hit filled yet?
	Je	Paint12		;If so next scan line
	Cmp	BL,DH		;Hit boundry yet?
	Je	Paint12		;If fill scan line
	Jmp	Paint7		;Continue checking the scan line

Paint12:
	Inc	SI		;Restore X
	Mov	CX,ES		;Save ending column
	Mov	BX,0B800H	;Point ES at video segment
	Mov	ES,BX		; ..

;Get starting and ending addresses
	Shl	DI,1		;Get starting address in DI
	Mov	DI,ScanLine[DI] ; ..
	Mov	BX,DI		;  ..
	Mov	AX,SI		;   ..
	Shr	AX,1		;    ..
	Add	DI,AX		;     ..
	Mov	AX,CX		;Get ending address in BX
	Shr	AX,1		; ..
	Add	BX,AX		;  ..
	Mov	AL,DL		;Fill color in AL & DL
	Shl	AL,1		; ..
	Shl	AL,1		;  ..
	Shl	AL,1		;   ..
	Shl	AL,1		;    ..

;Fill partial bytes if necessary
	Test	SI,1		;Check for partial byte
	Jz	Paint13		;No
	And	BYTE PTR ES:[DI],0F0H ;Plot the point
	Or	BYTE PTR ES:[DI],DL   ; ..
	Inc	DI		;Point to next byte
Paint13:
	Test	CX,1		;Check for partial byte
	Jnz	Paint14		;No
	And	BYTE PTR ES:[BX],0FH ;Plot the point
	Or	BYTE PTR ES:[BX],AL  ; ..
	Dec	BX		;Point to previous byte

;Fill the scan line with paint color
Paint14:
	Sub	BX,DI		;Get byte count
	Jb	Paint15		;Skip if no more to do
	Mov	CX,BX		;Byte count in CX
	Inc	CX		;Adjust byte count
	Or	AL,DL		;Form full byte of color
	Rep	Stosb		;Fill the scan line
Paint15:
	Jmp	Paint1		;Do next scan line

;
;Draw a solid filled box from X1,Y1 - X2,Y2 using the specified color
;

Fill_Box:
	Mov	AL,[D_Color]	;Save current drawing color
	Mov	[Save_Clr],AL	; ..
	Mov	[D_Color],DL	;Set drawing color
	Call	Fill_BoxC	; ..
	Mov	AL,[Save_Clr]	;Restore current drawing color
	Mov	[D_Color],AL	; ..
	Ret

;
;Draw a solid filled box from X1,Y1 - X2,Y2 using the current drawing color
;

Fill_BoxC:
	Cld			;Make sure string operations go forward
	Mov	[Old_X],SI	;Update old X,Y values
	Mov	[Old_Y],DI	; ..
	Xchg	BX,CX		;X1 in CX
	Mov	DX,SI		;X2 in DX
	Mov	SI,BX		;Y1 in SI
	Mov	BX,DI		;Y2 in BX

;Get starting and end addresses
Fill_Box1:
	Mov	DI,SI		;Get starting address in DI
	Shl	DI,1		; ..
	Mov	DI,ScanLine[DI] ;  ..
	Mov	BP,DI		;   ..
	Mov	AX,CX		;    ..
	Shr	AX,1		;     ..
	Add	DI,AX		;      ..
	Mov	AX,DX		;Get ending address in BP
	Shr	AX,1		; ..
	Add	BP,AX		;  ..
	Mov	AL,[D_Color]	;Fill color in AL & AH
	Mov	AH,AL		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Shl	AH,1		;    ..
	Shl	AH,1		;     ..

;Fill partial bytes if necessary
	Test	CX,1		;Check for partial byte
	Jz	Fill_Box2	;No
	And	BYTE PTR ES:[DI],0F0H ;Plot the point
	Or	BYTE PTR ES:[DI],AL   ; ..
	Inc	DI		;Point to next byte
Fill_Box2:
	Test	DX,1		;Check for partial byte
	Jnz	Fill_Box3	;No
	And	BYTE PTR ES:[BP],0FH ;Plot the point
	Or	BYTE PTR ES:[BP],AH  ; ..
	Dec	BP		;Point to previous byte

;Fill the scan line with color
Fill_Box3:
	Sub	BP,DI		;Get byte count
	Jb	Fill_Box4	;Nothing more to do
	Xchg	BP,CX		;Save X1 and put byte count in CX
	Inc	CX		;Adjust byte count
	Or	AL,AH		;Form full byte of color
	Rep	Stosb		;Fill the scan line
	Xchg	BP,CX		;Restore X1
Fill_Box4:
	Inc	SI		;Point to next row
	Cmp	SI,BX		;All done?
	Ja	Fill_Box5	;Yes
	Jmp	Fill_Box1	;No
Fill_Box5:
	Ret

;
;Change a palette register color
;

Set_Palette:
	Mov	DI,16		;Make sure port offset is for palette registers
Set_Palette1:			;Entered here to set border register
	Mov	DX,3DAH		;Address & status register
	Cli			;Clear interrupts
Set_Palette2:
	In	AL,DX		;Get status register
	And	AL,8		;Look for bit 3
	Jz	Set_Palette2	;Wait for vertical retrace
	Mov	AX,BX		;Get palette number
	Add	AX,DI		;Add offset for palette or border
	Out	DX,AL		;Set palette
	Mov	AX,CX		;Get color to store
	Mov	DX,3DEH		;Palette data register
	Out	DX,AL		;Set palette color
	Mov	DX,3DAH		;Address & status register
	Xor	AX,AX		;AL = 0 to reset address register
	Out	DX,AL		;Reset it
	Sti
	Ret

;
;Change all 16 palette registers using 16 elements of an integer array
;

Palette_Using:
	Push	DS		;Save DS
	Mov	DS,[Save_DS]	;Get segment address of array
	Mov	SI,DX		;OFFSET address in SI
	Mov	CS:[B_Color],0	;Reset border color to palette register 0
	Xor	BX,BX		;Border register is 0
	Mov	CX,0		;Color to store in CX
	Mov	DI,2		;Border register offset is 2
	Call	Set_Palette1	;Set the border color
	Mov	CX,16		;Set count for colors 0-15
	Xor	BX,BX		;Palette register number in BX
Palette_Using1:
	Push	CX		;Save counter
	Mov	CX,[SI]		;Color to store in CX
	Call	Set_Palette	;Set the palette register color
	Inc	BX		;Bump up to next palette register number
	Inc	SI		;Point to next color in the array
	Inc	SI		; ..
	Pop	CX		;Restore counter
	Loop	Palette_Using1	;Do next color
	Pop	DS		;Restore DS
	Ret

;
;Reset the all 16 palette registers to their default state
;

Reset_Palette:
	Mov	[B_Color],0	;Reset background color to black
	Xor	BX,BX		;Border register is 0
	Mov	CX,0		;Color to store in CX
	Mov	DI,2		;Border register offset is 2
	Call	Set_Palette1	;Set the border color
	Mov	CX,16		;Color to store in CX (Do 0-15)
	Xor	BX,BX		;Palette register number in BX
Reset_Palette1:
	Push	CX		;Save counter
	Mov	BX,CX		;Palette registers are same as color
	Call	Set_Palette	;Set the palette register
	Inc	BX		;Do next palette register
	Pop	CX		;Restore counter
	Loop	Reset_Palette1	;Do next color
	Ret

;
;Store a graphics image from X1,Y1 - X2,Y2 into an integer array
;

Get:
	Push	DS		;Save DS
	Mov	DS,CS:[Save_DS] ;Get segment address of array
	Xchg	BX,SI		;SI = X1
	Xchg	CX,DI		;DI = Y1
	Xchg	BX,DX		;Store offset address in BX
	Mov	AX,DX		;Put starting column in AX
	Sub	AX,SI		;Get # of columns to store
	Inc	AX		; ..
	Mov	[BX],AX		;Store in 1st word of array
	Test	AX,1		;Get # of bytes to process on a row
	Jz	Get1		; ..
	Inc	AX		;  ..
Get1:				;   ..
	Shr	AX,1		;    ..
	Mov	CS:[Max],AX	;Save # of bytes to process on a row
	Sub	CX,DI		;Get # of rows in image
	Inc	CX		; ..
	Mov	[BX+2],CX	;Store in 2nd word of array
	Add	BX,4		;Point to starting array image location
Get_Next:
	Push	CX		;Save # of rows to process
	Push	DI		;Save current row
	Push	SI		;Save beginning column
	Shl	DI,1		   ;Put offset address in DI from table
	Mov	DI,CS:ScanLine[DI] ; ..
	Shr	SI,1		   ;Add column offset (Col / 2)
	Add	DI,SI		   ; ..
	Pop	SI		;Restore beginning column
	Mov	CX,CS:[Max]	;Get # of bytes to process on a row
Get_Next1:
	Mov	AL,ES:[DI]	;Store pixel in AL
	Test	SI,1		;Check for odd starting column
	Jz	Get_Next2
	Shl	AL,1		;Yes, shift pixel to upper nybble
	Shl	AL,1		; ..
	Shl	AL,1		;  ..
	Shl	AL,1		;   ..
	Mov	AH,ES:[DI+1]	;Get next pixel & shift to lower nybble
	Shr	AH,1		; ..
	Shr	AH,1		;  ..
	Shr	AH,1		;   ..
	Shr	AH,1		;    ..
	Or	AL,AH		;Now both pixels in AL
Get_Next2:
	Mov	[BX],AL		;Transfer pixel to array
	Inc	BX		;Point to next array position
	Inc	DI		;Point to next pixel position
	Loop	Get_Next1	;Process next pixel
	Pop	DI		;Restore current row
	Inc	DI		;Point to next row
	Pop	CX		;Restore row counter
	Loop	Get_Next	;Process next row
	Pop	DS		;Restore DS
	Ret

;
;Transfer an image stored with 'Get' starting at X,Y using 1 of 5 actions:
;  Preset, Pset, And, Or, Xor
;

Put:
	Push	DS		;Save DS
	Mov	DS,CS:[Save_DS] ;Get segment address of array
	Xchg	BX,DX		;Store offset address in BX
	Mov	CX,[BX]		;Get # of columns to move
	Mov	CS:[Max],CX	;Save # of columns to process on a row
	Mov	CX,[BX+2]	;Get # of rows in image
	Add	BX,3		;Point to starting array image location
	Test	CS:[Cursor_Flag],4 ;Don't update Old_X, Old_Y if plotting cursor
	Jz	Put1
	Mov	CS:[Old_Y],SI	;Update old X,Y values
	Mov	CS:[Old_X],DI	;  ..
Put1:
	Cmp	DX,1		;PRESET?
	Jne	Put2		;No
	Mov	BP,OFFSET Put_Preset ;Yes
	Jmp	Put_Next
Put2:
	Cmp	DX,2		;PSET?
	Jne	Put3		;No
	Mov	BP,OFFSET Put_Pset ;Yes
	Jmp	Put_Next
Put3:
	Cmp	DX,3		;AND?
	Jne	Put4		;No
	Mov	BP,OFFSET Put_And ;Yes
	Jmp	Put_Next
Put4:
	Cmp	DX,4		;OR?
	Jne	Put5		;No
	Mov	BP,OFFSET Put_Or ;Yes
	Jmp	Put_Next
Put5:
	Mov	BP,OFFSET Put_Xor ;XOR is the default

Put_Next:
	Push	CX		;Save # of rows to process
	Push	DI		;Save current row
	Push	SI		;Save beginning column
	Shl	DI,1		   ;Put offset address in DI from table
	Mov	DI,CS:ScanLine[DI] ; ..
	Shr	SI,1		   ;Add column offset (Col / 2)
	Add	DI,SI		   ; ..
	Pop	SI		;Restore beginning column
	Mov	CX,CS:[Max]	;Get # of columns to process on a row
	Dec	DI		;Fix DI for initial increment
	Jmp	BP		;Go to action requested

Put_Xor:
	Test	SI,1		;Check for odd start column
	Jnz	Put_Xor_Odd	;Yes, do odd column processing

Put_Xor_Even:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	And	AL,0F0H		;Transfer pixle
	Xor	ES:[DI],AL	; ..
	Loop	Put_Xor_Even1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Xor_Even1:
	And	AH,0FH		;Transfer pixle
	Xor	ES:[DI],AH	; ..
	Loop	Put_Xor_Even	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Xor_Odd:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Shr	AL,1		;Shift color to lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
	Xor	ES:[DI],AL	;Transfer pixel
	Loop	Put_Xor_Odd1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Xor_Odd1:
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Xor	ES:[DI+1],AH	;Transfer pixel
	Loop	Put_Xor_Odd	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Or:
	Test	SI,1		;Check for odd start column
	Jnz	Put_Or_Odd	;Yes, do odd column processing

Put_Or_Even:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	And	AL,0F0H		;Transfer pixel
	Or	ES:[DI],AL	; ..
	Loop	Put_Or_Even1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Or_Even1:
	And	AH,0FH		;Transfer pixel
	Or	ES:[DI],AH	; ..
	Loop	Put_Or_Even	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Or_Odd:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Shr	AL,1		;Shift color to lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
	Or	ES:[DI],AL	;Transfer pixel
	Loop	Put_Or_Odd1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Or_Odd1:
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Or	ES:[DI+1],AH	;Transfer pixel
	Loop	Put_Or_Odd	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_And:
	Test	SI,1		;Check for odd start column
	Jnz	Put_And_Odd	;Yes, do odd column processing

Put_And_Even:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Or	AL,0FH		;Transfer pixel
	And	ES:[DI],AL	; ..
	Loop	Put_And_Even1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_And_Even1:
	Or	AH,0F0H		;Transfer pixel
	And	ES:[DI],AH	; ..
	Loop	Put_And_Even	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_And_Odd:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Shr	AL,1		;Shift color to lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
	Or	AL,0F0H		;Transfer pixel
	And	ES:[DI],AL	; ..
	Loop	Put_And_Odd1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_And_Odd1:
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Or	AH,0FH		;Transfer pixel
	And	ES:[DI+1],AH	; ..
	Loop	Put_And_Odd	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Pset:
	Test	SI,1		;Check for odd start column
	Jnz	Put_Pset_Odd	;Yes, do odd column processing

Put_Pset_Even:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Mov	DL,ES:[DI]	;Store video pixel in DH & DL
	Mov	DH,DL		; ..
	And	AL,0F0H		;Transfer pixel
	And	DL,0FH		; ..
	Or	DL,AL		;  ..
	Mov	ES:[DI],DL	;   ..
	Loop	Put_Pset_Even1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Pset_Even1:
	And	AH,0FH		;Transfer pixel
	And	DH,0F0H		; ..
	Or	DH,AH		;  ..
	Or	DH,DL		;   ..
	Mov	ES:[DI],DH	;    ..
	Loop	Put_Pset_Even	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Pset_Odd:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Mov	DX,ES:[DI]	;Store video pixel in DH & DL
	Shr	AL,1		;Shift color to lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
	And	DL,0F0H		;Tranfer pixel
	Or	DL,AL		; ..
	Mov	ES:[DI],DL	;  ..
	Loop	Put_Pset_Odd1	;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Pset_Odd1:
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	And	DH,0FH		;Transfer pixel
	Or	DH,AH		; ..
	Mov	ES:[DI+1],DH	;  ..
	Loop	Put_Pset_Odd	;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Preset:
	Test	SI,1		;Check for odd start column
	Jnz	Put_Preset_Odd	;Yes, do odd column processing

Put_Preset_Even:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Mov	DL,ES:[DI]	;Store video pixel in DH & DL
	Mov	DH,DL		; ..
	And	AL,0F0H		;Transfer pixel
	Xor	AL,0F0H		; ..
	And	DL,0FH		;  ..
	Or	DL,AL		;   ..
	Mov	ES:[DI],DL	;    ..
	Loop	Put_Preset_Even1 ;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Preset_Even1:
	And	AH,0FH		;Transfer pixel
	Xor	AH,0FH		; ..
	And	DH,0F0H		;  ..
	Or	DH,AH		;   ..
	Or	DH,DL		;    ..
	Mov	ES:[DI],DH	;     ..
	Loop	Put_Preset_Even ;Do next pixel
	Jmp	Put_Next_Row	;Do next row

Put_Preset_Odd:
	Inc	BX		;Point to next array byte
	Inc	DI		;Point to next video byte
	Mov	AL,[BX]		;Store array pixel in AH & AL
	Mov	AH,AL		; ..
	Mov	DX,ES:[DI]	;Store video pixel in DH & DL
	Shr	AL,1		;Shift color to lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
	Xor	AL,0FH		;Transfer pixel
	And	DL,0F0H		; ..
	Or	DL,AL		;  ..
	Mov	ES:[DI],DL	;   ..
	Loop	Put_Preset_Odd1 ;Do next pixel
	Jmp	Put_Next_Row	;Do next row
Put_Preset_Odd1:
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Xor	AH,0F0H		;Transfer pixel
	And	DH,0FH		; ..
	Or	DH,AH		;  ..
	Mov	ES:[DI+1],DH	;   ..
	Loop	Put_Preset_Odd	;Do next pixel

Put_Next_Row:
	Pop	DI		;Restore current row
	Inc	DI		;Point to next row
	Pop	CX		;Restore row counter
	Dec	CX		;All Done?
	Jcxz	Put_Exit	;Yes
	Jmp	Put_Next	;No, process next row
Put_Exit:
	Pop	DS		;Restore DS
	Ret

;
;Animate a figure with the 'Put' function using the XOR option
;

Animate:
	Push	SI		;Save used registers
	Push	DI		; ..
	Push	CX		;  ..
	Push	DX		;   ..
	Mov	BX,5		;Use XOR option
	Call	Put		;Transfer the image
	Pop	DX		;Restore registers
	Pop	CX		; ..
	Pop	DI		;  ..
	Pop	SI		;   ..
Animate1:
	Loop	Animate1	;Delay awhile
	Mov	BX,5		;Use XOR option
	Call	Put		;Erase the image
	Ret

;
;Turn the graphics cursor On or Off
;

Set_Cursor:
	Cmp	BX,0		;Off?
	Jne	Set_Cursor2
	Test	[Cursor_Flag],1 ;See if cursor is already off
	Jz	Set_Cursor1
	Mov	BX,[Column]	;Turn graphics cursor off
	Mov	CX,[Row]	; ..
	Call	Plot_Cursor2	;  ..
	And	[Cursor_Flag],0FFFEH ;Set cursor flag off
Set_Cursor1:
	Ret
Set_Cursor2:
	Cmp	BX,1		;On?
	Jne	Set_Cursor4
	Test	[Cursor_Flag],1 ;See if cursor is already on
	Jnz	Set_Cursor3
	Or	[Cursor_Flag],1 ;Set cursor flag on
	Mov	BX,[Column]	;Turn graphics cursor on
	Mov	CX,[Row]	; ..
	Call	Plot_Cursor2	;  ..
Set_Cursor3:
	Ret
Set_Cursor4:
	Cmp	BX,2		;Half cursor off?
	Jne	Set_Cursor6
	Test	[Cursor_Flag],2 ;See if half cursor is already off
	Jz	Set_Cursor5
	Mov	BX,[Column]	;Turn half cursor off
	Mov	CX,[Row]	; ..
	Call	Plot_Cursor2	;  ..
	Mov	[CursorRows],8	;Turn regular cursor back on
	Mov	BX,[Column]	; ..
	Mov	CX,[Row]	;  ..
	Call	Plot_Cursor2	;   ..
	And	[Cursor_Flag],0FFFDH ;Set half cursor flag off
Set_Cursor5:
	Ret
Set_Cursor6:
	Cmp	BX,3		;Half cursor on?
	Jne	Set_Cursor7
	Test	[Cursor_Flag],2 ;See if half cursor is already On
	Jnz	Set_Cursor7
	Mov	BX,[Column]	;Turn regular cursor off
	Mov	CX,[Row]	; ..
	Call	Plot_Cursor2	;  ..
	Mov	[CursorRows],4	;Turn half cursor on
	Mov	BX,[Column]	; ..
	Mov	CX,[Row]	;  ..
	Call	Plot_Cursor2	;   ..
	Or	[Cursor_Flag],2 ;Set half cursor flag on
Set_Cursor7:
	Ret

;
;Return the current graphics cursor status Off or On, Full or Half
;

Get_Cursor:
	Mov	BX,[Cursor_Flag] ;Get the current status on or off
	And	BX,1		 ; ..
	Mov	SS:[0F8H],BX	 ;Store in BX position on stack
	Mov	CX,[Cursor_Flag] ;Get the current size full or half
	And	CX,2		 ; ..
	Shr	CX,1		 ;  ..
	Mov	SS:[0FCH],CX	 ;Store in CX position on stack
	Ret

;
;Set the graphics cursor position in text row and column format
;

Set_Cursor_Pos:
	Dec	BX		;Adjust row & column values for BIOS call
	Dec	CX		; .. (Row = 0-24, Column = 0-39)
	Mov	AH,2		;Set cursor function
	Mov	DH,CL		;Row in DH
	Mov	DL,BL		;Column in DL
	Push	BX		;Save row & column
	Push	CX		; ..
	Mov	BX,0		;Must be page 0 for graphics mode
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Pop	CX		;Restore row & column
	Pop	BX		; ..
	Call	Plot_Cursor	;Plot the new cursor position
	Ret

;
;Get the current row and column of the graphics cursor
;

Get_Cursor_Pos:
	Mov	BX,[Column]	;Column in BX
	Mov	CX,[Row]	;Row in CX
	Inc	BX		;Adjust row & column values
	Inc	CX		; .. (Row = 1-25, Column = 1-40)
	Mov	SS:[0F8H],BX	;Store in BX position on stack
	Mov	SS:[0FCH],CX	;Store in CX position on stack
	Ret

;
;Print a text string on the graphics screen
;

Print_String:
	Cmp	CX,0		;Check for null string
	Ja	Print_String1	; ..
	Ret
Print_String1:
	Push	DS		;Save DS
	Push	BX		;Save action indicator
	Mov	AH,14		;BIOS write TTY function
	Mov	BL,[T_Color]	;Text color in BX
	Mov	DS,CS:[Save_DS] ;Get segment address of string
	Mov	SI,DX		;String offset address in SI
Print_String2:
	Mov	AL,[SI]		;Character to print in AL
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Inc	SI		;Point to next character in string
	Loop	Print_String2	;Print next character
Print_String3:
	Pop	BX		;Restore action indicator
	Cmp	BX,0		;Check to skip final CR & LF sequence
	Je	Print_String4
	Mov	AH,14		;BIOS write TTY function
	Mov	AL,13		;Print a final carriage return & linefeed
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Mov	AL,10		;Print a final carriage return & linefeed
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
Print_String4:
	Pop	DS		;Restore DS
	Mov	BX,[Row]	;Erase old cursor
	Mov	CX,[Column]	; ..
	Call	Plot_Cursor2	;  ..
	Mov	AH,3		;BIOS get cursor position function
	Mov	BX,0		;Page must be 0 for graphics mode
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Xor	BX,BX		;Clear BX & CX for call to 'Plot_Cursor'
	Xor	CX,CX		; ..
	Mov	BL,DL		;Column in BX
	Mov	CL,DH		;Row in CX
	Call	Plot_Cursor	;Move cursor to new position
	Ret

;
;Plot the graphics cursor onto the screen.
;

Plot_Cursor:
	Test	[Cursor_Flag],1 ;See if cursor is off
	Jz	Plot_Cursor2
	Push	BX		;Save row & column
	Push	CX		; ..
	Mov	[Save_DS],CS	;Set data segment to our program for 'Put'
	Mov	SI,[Column]	;Get old X ordinate value (SI * 8)
	Shl	SI,1		; ..
	Shl	SI,1		;  ..
	Shl	SI,1		;   ..
	Mov	DI,[Row]	;Get old Y ordinate value (DI * 8)
	Shl	DI,1		; ..
	Shl	DI,1		;  ..
	Shl	DI,1		;   ..
	Mov	DX,OFFSET Cursor ;Point to graphics cursor array
	Mov	BX,5		;Xor the cursor onto the screen
	Or	[Cursor_Flag],4 ;Indicate to 'Put' we are plotting cursor
	Call	Put		;Plot it
	Pop	CX		;Restore row & column
	Pop	BX
Plot_Cursor2:			;Entered here for initial plot or erase
	Mov	[Column],BX	;Update new row & column values
	Mov	[Row],CX	; ..
	Test	[Cursor_Flag],1 ;See if cursor is off
	Jz	Plot_Cursor3
	Mov	[Save_DS],CS	;Set data segment to our program for 'Put'
	Mov	SI,BX		;Get new X ordinate value (SI * 8)
	Shl	SI,1		; ..
	Shl	SI,1		;  ..
	Shl	SI,1		;   ..
	Mov	DI,CX		;Get new Y ordinate value (DI * 8)
	Shl	DI,1		; ..
	Shl	DI,1		;  ..
	Shl	DI,1		;   ..
	Mov	DX,OFFSET Cursor ;Point to graphics cursor array
	Mov	BX,5		;Xor the cursor onto the screen
	Or	[Cursor_Flag],4 ;Indicate to 'Put' we are plotting cursor
	Call	Put		;Plot it
Plot_Cursor3:
	And	[Cursor_Flag],0FFFBH ;Reset 'Put' indicator
	Ret

;
;Return residency or graphics status - Set graphics and audio system
;

System:
	Cmp	BX,0		;Status check?
	Jne	System1		;No
	Mov	AX,0DEADH	;Indicate this program is resident
	Mov	SS:[0FEH],AX	;Store in AX position on stack
	Ret
System1:
	Cmp	BX,1		;Return graphics status?
	Jne	System2		;No
	Mov	AX,[Graph_Flag] ;Return the current graphics status
	Mov	SS:[0FEH],AX	;Store in AX position on stack
	Ret
System2:
	Cmp	BX,2		;Enable graphics functions?
	Jne	System3		;No
	Mov	AX,0009H	;Enter 320 x 200 x 16 color graphics mode
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Mov	[Graph_Flag],1	;Enable graphics functions
	Mov	[Cursor_Flag],0 ;Reset graphic variables
	Mov	[CursorRows],8	; ..
	Mov	[B_Color],0	;  ..
	Mov	[D_Color],1	;   ..
	Mov	[T_Color],15	;    ..
	Mov	[Old_X],0	;     ..
	Mov	[Old_Y],0	;      ..
	Mov	[Row],0		;	..
	Mov	[Column],0	;	 ..
	Mov	[X_Aspect],6	;	  ..
	Mov	[Y_Aspect],5	;	   ..
	Ret
System3:
	Cmp	BX,3		;Disable graphics functions?
	Jne	System4		;No
	Mov	[Graph_Flag],0	;Disable graphics functions
	Mov	AX,0003H	;Reset video mode to 80 x 25 color
	PushF			;Fake an INT 10H interrupt
	Call	DWORD PTR CS:[Old10Int]
	Ret
System4:
	Cmp	BX,4		;Turn all current sound processing off?
	Jne	System5		;No
	Call	Sound_Off	;Reset sound system
	Ret
System5:
	Cmp	BX,5		;Turn sound buffering on?
	Jne	System7
	Test	[Buf_Flag],1	;See if buffering is already on
	Jnz	System6		;Yes, don't reset
	Or	[Buf_Flag],1	;Turn all sound buffer processing on
	Call	Reset_Sound_Buf ;Reset sound buffer variables
System6:
	Ret
System7:
	Cmp	BX,6		;Turn sound buffering off?
	Jne	System9		;No
	Test	[Buf_Flag],1	;See if buffering is already off
	Jz	System8		;Yes, don't reset
	And	[Buf_Flag],0FFFEH ;Turn all sound buffer processing off
System8:
	Ret
System9:
	Cmp	BX,7		;Turn all noise processing off?
	Jne	System10	;No
	Call	Noise_Off	;Reset noise system
	Ret
System10:
	Cmp	BX,8		;Turn noise buffering on?
	Jne	System12	;No
	Test	[Buf_Flag],2	;See if buffering is already on
	Jnz	System11	;Yes, don't reset
	Or	[Buf_Flag],2	;Turn all noise buffer processing on
	Call	Reset_Noise_Buf ;Reset noise buffer variables
System11:
	Ret
System12:
	Cmp	BX,9		;Turn noise buffering off?
	Jne	System14	;No
	Test	[Buf_Flag],2	;See if buffering is already off
	Jz	System13	;Yes, don't reset
	And	[Buf_Flag],0FFFDH ;Turn all noise buffer processing off
System13:
	Ret
System14:
	Cmp	BX,10		;Turn all sound & noise processing off?
	Jne	System15	;No
	Call	Sound_Off	;Reset sound system
	Call	Noise_Off	;Reset noise system
System15:
	Ret

;
;Turns all current sound processing off
;

Sound_Off:
	And	[Timer_Flag],16   ;Reset timer flag
	And	[Buf_Flag],0FFFEH ;Turn all sound buffer processing off
	Mov	AX,0083H	;Turn off all sound channels
	Out	0C0H,AX		; ..
	Mov	AL,00A3H	;  ..
	Out	0C0H,AX		;   ..
	Mov	AL,00C3H	;    ..
	Out	0C0H,AX		;     ..
	Call	Reset_Sound_Buf ;Reset sound buffers
	Ret

;
;Turns all current noise processing off
;

Noise_Off:
	And	[Timer_Flag],0FFEFH ;Reset timer flag
	And	[Buf_Flag],0FFFDH ;Turn all noise buffer processing off
	Mov	AL,0FFH		;Turn noise channel off
	Out	0C0H,AL		; ..
	Call	Reset_Noise_Buf ;Reset noise buffer
	Ret

;
;Reset all sound buffer variables
;

Reset_Sound_Buf:
	Mov	[Buf_Cnt1],0	;Reset all counters
	Mov	[Buf_Cnt2],0	; ..
	Mov	[Buf_Cnt3],0	;  ..
	Mov	[GBuf_Ptr1],OFFSET Sound_Buf1 ;Reset all pointers
	Mov	[PBuf_Ptr1],OFFSET Sound_Buf1 ; ..
	Mov	[GBuf_Ptr2],OFFSET Sound_Buf2 ;  ..
	Mov	[PBuf_Ptr2],OFFSET Sound_Buf2 ;   ..
	Mov	[GBuf_Ptr3],OFFSET Sound_Buf3 ;    ..
	Mov	[PBuf_Ptr3],OFFSET Sound_Buf3 ;     ..
	Ret

;
;Reset all noise buffer variables
;

Reset_Noise_Buf:
	Mov	[Buf_Cnt4],0	;Reset counter
	Mov	[GBuf_Ptr4],OFFSET Noise_Buf ;Reset all pointers
	Mov	[PBuf_Ptr4],OFFSET Noise_Buf ; ..
	Ret

;
;Produce a sound with the specified frequency, duration, volume, and voice
;

Sound:
	Pushr			;Save registers
	Call	Make_Sound	;Produce the desired sound
	Popr			;Restore registers
	Ret

Make_Sound:
	Cmp	DI,0		;Check for zero length sound
	Ja	Make_Sound_OK	;Duration is OK, go on with making sound
	Ret			;Duration is zero, don't make the sound
Make_Sound_OK:
	And	BX,15		;Make sure volume is 0-15
	And	CX,3		;Make sure voice is 0-2
	Cmp	SI,110		;Make sure frequency is at least 110Hz
	Jae	Make_Sound1	; ..
	Mov	SI,110		;  ..
Make_Sound1:
	Cmp	CL,0		;Check for sound channel 0
	Jne	Make_Sound4
	Test	CS:[Timer_Flag],1 ;Check if current sound still active
	Jz	Make_Sound3	;No
	Test	CS:[Buf_Flag],1 ;See if sound buffer is active
	Jz	Make_Sound2	;No, wait for current sound to finish
	Call	Put_Sound1	;Yes, add the sound to the buffer
	Ret
Make_Sound2:			;No, wait for current sound to finish
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:[Sound0_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound0_Ticks] ; ..
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound2	;Keep looping until it's free
Make_Sound3:
	Mov	CS:[Sound0_Ticks],DI ;Set number of ticks for channel 0
	Mov	CS:[Sound0_Cnt],0 ;Reset counter
	Or	CS:[Timer_Flag],1 ;Turn channel 0 flag bit on
	Jmp	Make_Sound10
Make_Sound4:
	Cmp	CL,1		;Check for sound channel 1
	Jne	Make_Sound7
	Test	CS:[Timer_Flag],2 ;Check if current sound still active
	Jz	Make_Sound6	;No
	Test	CS:[Buf_Flag],1 ;See if sound buffer is active
	Jz	Make_Sound5	;No, wait for current sound to finish
	Call	Put_Sound2	;Yes, add the sound to the buffer
	Ret
Make_Sound5:
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:[Sound1_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound1_Ticks] ; ..
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound5	;Keep looping until it's free
Make_Sound6:
	Mov	CS:[Sound1_Ticks],DI ;Set number of ticks for channel 1
	Mov	CS:[Sound1_Cnt],0 ;Reset counter
	Or	CS:[Timer_Flag],2 ;Turn channel 1 flag bit on
	Jmp	Make_Sound10
Make_Sound7:
	Test	CS:[Timer_Flag],4 ;Check if current sound still active
	Jz	Make_Sound9	;No
	Test	CS:[Buf_Flag],1   ;See if sound buffer is active
	Jz	Make_Sound8	;No, wait for current sound to finish
	Call	Put_Sound3	;Yes, add the sound to the buffer
	Ret
Make_Sound8:
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:[Sound2_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound2_Ticks] ; ..
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound8	;Keep looping until it's free
Make_Sound9:
	Mov	CS:[Sound2_Ticks],DI ;Set number of ticks for channel 2
	Mov	CS:[Sound2_Cnt],0 ;Reset counter
	Or	CS:[Timer_Flag],4 ;Turn channel 2 flag bit on
Make_Sound10:			;Set the current sound channel volume
	Mov	AH,CL		; Volume channel formula:
	Mov	CL,5		;  ..	90H OR
	Shl	AH,CL		;   ..	(Voice * 32) OR
	Mov	AL,90H		;    .. (Volume XOR 15)
	Or	AL,AH		;     ..
	Xor	BL,0FH		;      ..
	Or	AL,BL		;	..
	Out	0C0H,AL		;	 ..
	Mov	BX,AX		;Send the volume
	Mov	DX,1		;Calculate the tone (111860 / Frequency)
	Mov	AX,0B4F4H	; ..
	Div	SI		;  ..
	Shl	DX,1		;Round up if necessary
	Cmp	DX,SI		; ..
	Jb	Make_Sound11	;  ..
	Inc	AX		;   ..
Make_Sound11:
	Mov	SI,AX		;Tone in SI
	Mov	AX,BX		;Restore voice
	Mov	AL,80H		;Get 1st byte of tone (takes two)
	Or	AL,AH		; Byte 1 formula:
	Mov	BX,SI		;  ..	80H OR
	And	BX,0FH		;   ..	(Voice * 32) OR
	Or	AL,BL		;    .. (Tone AND 15)
	Out	0C0H,AL		;     ..
	Mov	BX,AX		;Save 1st byte
	Mov	AX,SI		;Get 2nd byte of tone
	And	AX,3F0H		; Byte 2 formula:
	Mov	CL,4		;  .. (Tone AND 3F0) / 16
	Shr	AX,CL		;   ..
	Mov	AH,AL		;2nd byte in AH
	Mov	AL,BL		;1st byte in AL
	Out	0C0H,AX		;Send the tone
	Ret

;
;Generate a periodic or white noise with the specified volume and duration
;

Noise:
	Pushr			;Save registers
	Call	Make_Noise	;Make the noise
	Popr			;Restore registers
	Ret

Make_Noise:
	Cmp	DX,0		;Check for zero length noise
	Ja	Make_Noise_OK	;Duration is OK, go on with making noise
	Ret			;Duration is zero, don't make the noise
Make_Noise_OK:
	Test	CS:[Timer_Flag],8 ;See if current noise still active
	Jz	Make_Noise3	;No
Make_Noise1:
	Test	CS:[Buf_Flag],2 ;See if buffering active
	Jz	Make_Noise2	;No, wait for current noise to finished
	Call	Put_Noise	;Yes, put noise into sound buffer
	Ret
Make_Noise2:
	Cli			;Diable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:[Noise_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Noise_Ticks] ; ..
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Noise2	;Keep looping until it's free
Make_Noise3:
	Mov	CS:[Noise_Ticks],DX ;Set duration
	Mov	CS:[Noise_Cnt],0  ;Reset clock tick counter
	Or	CS:[Timer_Flag],8 ;Enable noise flag bit
	Mov	AL,0F0H		;Set noise volume
	And	CL,0FH		; Noise channel formula:
	Xor	CL,0FH		;  .. F0H OR ((Volume AND 15) XOR 15)
	Add	AL,CL		;   ..
	Mov	AH,AL		;Save volume
	Mov	AL,0E0H		;Set noise type
	Mov	CX,BX		; Noise channel formula:
	Shr	BL,1		;  ..	E0H OR
	Shr	BL,1		;   ..	((Type / 4) * 4) OR
	And	BL,3		;    .. (Type AND 3)
	Shl	BL,1		;     ..
	Shl	BL,1		;      ..
	Or	AL,BL		;	..
	And	CL,3		;	 ..
	Or	AL,CL		;	  ..
	Out	0C0H,AX		;Send the type & volume
	Ret

;
;Put the current sound into the sound buffer
;

;Sound buffer number 1
Put_Sound1:
	Push	BP		;Save BP
Put_Sound1A:
	Cli			;Clear interrupts
	Cmp	CS:[Buf_Cnt1],64 ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound1A	;Yes, loop until there's an openning
	Mov	BP,CS:[PBuf_Ptr1]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End1 ; ..
	Jne	Put_Sound1B	;No
	Mov	BP,OFFSET Sound_Buf1 ;Yes, point to beginning of buffer
Put_Sound1B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[PBuf_Ptr1],BP ;Save current buffer pointer
	Inc	CS:[Buf_Cnt1]	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 2
Put_Sound2:
	Push	BP		;Save BP
Put_Sound2A:
	Cli			;Clear interrupts
	Cmp	CS:[Buf_Cnt2],64 ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound2A	;Yes, loop until there's an openning
	Mov	BP,CS:[PBuf_Ptr2]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End2 ; ..
	Jne	Put_Sound2B	;No
	Mov	BP,OFFSET Sound_Buf2 ;Yes, point to beginning of buffer
Put_Sound2B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[PBuf_Ptr2],BP ;Save current buffer pointer
	Inc	CS:[Buf_Cnt2]	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 3
Put_Sound3:
	Push	BP		;Save BP
Put_Sound3A:
	Cli			;Clear interrupts
	Cmp	CS:[Buf_Cnt3],64 ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound3A	;Yes, loop until there's an openning
	Mov	BP,CS:[PBuf_Ptr3] ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End3
	Jne	Put_Sound3B	;No
	Mov	BP,OFFSET Sound_Buf3 ;Yes, point to beginning of buffer
Put_Sound3B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[PBuf_Ptr3],BP ;Save current buffer pointer
	Inc	CS:[Buf_Cnt3]	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;
;Put the current noise into the noise buffer
;

Put_Noise:
	Push	BP		;Save BP
Put_Noise1:
	Cli			;Clear interrupts
	Cmp	CS:[Buf_Cnt4],64 ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Noise1	;Yes, loop until there's an openning
	Mov	BP,CS:[PBuf_Ptr4]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End4 ; ..
	Jne	Put_Noise2	;No
	Mov	BP,OFFSET Noise_Buf ;Yes, point to beginning of buffer
Put_Noise2:
	Mov	CS:[BP],BX	;Store the type
	Mov	CS:[BP+2],CX	;Store the volume
	Mov	CS:[BP+4],DX	;Store the duration
	Add	BP,6		;Increment buffer pointer
	Mov	CS:[PBuf_Ptr4],BP ;Save current buffer pointer
	Inc	CS:[Buf_Cnt4]	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 1
Get_Sound1:
	Cmp	CS:[Buf_Cnt1],0  ;See if buffer is empty
	Je	Get_Sound1B
	Pushr			;Save registers
	Mov	BP,CS:[GBuf_Ptr1]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End1 ; ..
	Jne	Get_Sound1A	;No
	Mov	BP,OFFSET Sound_Buf1 ;Yes, point to beginning of buffer
Get_Sound1A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[GBuf_Ptr1],BP ;Save current buffer pointer
	Dec	CS:[Buf_Cnt1]	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popr			;Restore registers
Get_Sound1B:
	Ret

;Sound buffer number 2
Get_Sound2:
	Cmp	CS:[Buf_Cnt2],0 ;See if buffer is empty
	Je	Get_Sound2B
	Pushr			;Save registers
	Mov	BP,CS:[GBuf_Ptr2]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End2 ; ..
	Jne	Get_Sound2A	;No
	Mov	BP,OFFSET Sound_Buf2 ;Yes, point to beginning of buffer
Get_Sound2A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[GBuf_Ptr2],BP ;Save current buffer pointer
	Dec	CS:[Buf_Cnt2]	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popr			;Restore registers
Get_Sound2B:
	Ret

;Sound buffer number 3
Get_Sound3:
	Cmp	CS:[Buf_Cnt3],0 ;See if buffer is empty
	Je	Get_Sound3B	;No
	Pushr			;Save registers
	Mov	BP,CS:[GBuf_Ptr3]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End3 ; ..
	Jne	Get_Sound3A	;No
	MOV	BP,OFFSET Sound_Buf3 ;Yes, point to beginning of buffer
Get_Sound3A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:[GBuf_Ptr3],BP ;Save current buffer pointer
	Dec	CS:[Buf_Cnt3]	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popr			;Restore registers
Get_Sound3B:
	Ret

;
;Get the current noise from the noise buffer and generate it
;

Get_Noise:
	Cmp	CS:[Buf_Cnt4],0 ;See if buffer is empty
	Je	Get_Noise2	;No
	Pushr			;Save registers
	Mov	BP,CS:[GBuf_Ptr4]  ;See if at end of buffer
	Cmp	BP,OFFSET Buf_End4 ; ..
	Jne	Get_Noise1	;No
	Mov	BP,OFFSET Noise_Buf ;Yes, point to beginning of buffer
Get_Noise1:
	Mov	BX,CS:[BP]	;Get the type
	Mov	CX,CS:[BP+2]	;Get the volume
	Mov	DX,CS:[BP+4]	;Get the duration
	Add	BP,6		;Increment buffer pointer
	Mov	CS:[GBuf_Ptr4],BP ;Save current buffer pointer
	Dec	CS:[Buf_Cnt4]	;Subtract from current sound total
	Call	Make_Noise	;Make the noise
	Popr			;Restore registers
Get_Noise2:
	Ret

;
;Delay for the specified number of clock ticks
;

Delay:
	Or	CS:[Timer_Flag],16 ;Turn delay flag bit on
	Mov	CS:[Delay_Ticks],BX ;Set number of ticks for delay
	Mov	CS:[Delay_Cnt],0  ;Reset counter
Delay1:
	Cli			;Clear interrupts
	Push	AX		;Save AX
	Mov	AX,CS:[Delay_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Delay_Ticks] ; ..
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Delay1		;Keep looping until time is up
	And	CS:[Timer_Flag],0FFEFH ;Set delay flag bit off
	Ret

;
;This  internal routine  takes over  the clock	tick interrupt	and updates  the
;number of  clock ticks that  have elapsed  since  the start of  the last sound,
;noise, or  delay function. When  the specified number	of ticks has  passed the
;sound	or noise  is turned  off and  the sound  buffer is  checked to see if if
;another  sound is  waiting to	be played.  In the  case of  the delay function,
;control is returned to the interrupted program.
;

Timer:
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Test	CS:[Timer_Flag],1 ;Check for sound channel 0
	Jz	Timer2
	Inc	CS:[Sound0_Cnt]  ;Add another clock tick
	Mov	AX,CS:[Sound0_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound0_Ticks] ; ..
	Jb	Timer2		;No
	And	CS:[Timer_Flag],0FFFEH ;Turn channel 0 flag bit off
	Mov	AX,0083H	;Turn sound channel 0 off
	Out	0C0H,AX		; ..
	Test	CS:[Buf_Flag],1 ;See if sound buffer is active
	Jz	Timer2		;No, check next sound channel
	Call	Get_Sound1	;Yes, get next sound to play from the buffer
Timer2:
	Test	CS:[Timer_Flag],2 ;Check for sound channel 1
	Jz	Timer3
	Inc	CS:[Sound1_Cnt]  ;Add another clock tick
	Mov	AX,CS:[Sound1_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound1_Ticks] ; ..
	Jb	Timer3		;No
	And	CS:[Timer_Flag],0FFFDH ;Turn channel 1 flag bit off
	Mov	AX,00A3H	;Turn sound channel 1 off
	Out	0C0H,AX		; ..
	Test	CS:[Buf_Flag],1 ;See if sound buffer is active
	Jz	Timer3		;No, check next sound channel
	Call	Get_Sound2	;Yes, get next sound to play from the buffer
Timer3:
	Test	CS:[Timer_Flag],4 ;Check for sound channel 2
	Jz	Timer4
	Inc	CS:[Sound2_Cnt]  ;Add another clock tick
	Mov	AX,CS:[Sound2_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Sound2_Ticks] ; ..
	Jb	Timer4		;No
	And	CS:[Timer_Flag],0FFFBH ;Turn channel 2 flag bit off
	Mov	AX,00C3H	;Turn sound channel 2 off
	Out	0C0H,AX		; ..
	Test	CS:[Buf_Flag],1 ;See if sound buffer is active
	Jz	Timer4		;No, check noise channel
	Call	Get_Sound3	;Yes, get next sound to play from the buffer
Timer4:
	Test	CS:[Timer_Flag],8 ;Check for noise channel
	Jz	Timer5
	Inc	CS:Noise_Cnt	;Add another clock tick
	Mov	AX,CS:[Noise_Cnt]   ;See if time has expired
	Cmp	AX,CS:[Noise_Ticks] ; ..
	Jb	Timer5		;No
	And	CS:[Timer_Flag],0FFF7H ;Turn noise flag bit off
	Mov	AL,0FFH		;Turn noise off
	Out	0C0H,AL		; ..
	Test	CS:[Buf_Flag],2 ;See if noise buffer is active
	Jz	Timer5		;No, check for delay
	Call	Get_Noise	;Yes, get next noise to make from the buffer
Timer5:
	Test	CS:[Timer_Flag],16 ;Check for delay
	Jz	Timer6
	Inc	CS:[Delay_Cnt]	;Add another clock tick
Timer6:
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jmp	DWORD PTR CS:[Old1CInt] ;Execute normal clock tick interrupt

;------------------------------------------------------------------------------;
;									       ;
;   Initial part of the program -- It uses sub-function 80H to check and       ;
;   see if GRAFIX is already resident.	If not installed, the standard	       ;
;   INT 10H vector is saved and the new extension code above is linked	       ;
;   into the BIOS vector.						       ;
;									       ;
;   The installation code adjusts the Tandy 1000's memory size downward        ;
;   by an additional 16K to allow use of the full 32K graphics memory.	       ;
;   This is performed by adjusting the actual low memory word specifying       ;
;   the number of kilobytes and by adjusting the number of paragraphs	       ;
;   remaining in this executing task's memory allocation block header.         ;
;									       ;
;   The protection of the top 32K of system memory is skipped if '/N' is       ;
;   present on the command line.					       ;
;									       ;
;------------------------------------------------------------------------------;

Setup:
	Mov	AH,0EEH		;See if this program is already resident
	Mov	AL,80H		; ..
	Mov	BX,0		;  ..
	Int	10H		;   ..
	Cmp	AX,0DEADH	;Test for return value
	Jnz	Not_Already_Installed
	Mov	DX,OFFSET Installed_Error ;Print GRAFIX already installed msg
	Mov	AH,9			  ; ..
	Int	21H			  ;  ..
	Mov	AH,4CH		;Exit with return code non-zero
	Mov	AL,1		; ..
	Int	21H		;  ..

Not_Already_Installed:
	Mov	AH,9			    ;Print GRAFIX installed message
	Mov	DX,OFFSET Installed_Message ; ..
	Int	21H			    ;  ..

;
;Check if we should skip memory protect option (/N on command line)
;

	Mov	BX,0080H	;Get command line length
	Mov	AH,[BX]		; ..
	Cmp	AH,00H		;Is it there anything there to check?
	Jnz	Check_Param	;Yes
	Jmp	Protect_Mem	;No, go ahead with memory protect option
Check_Param:
	Xor	CX,CX		;Byte count in CX
	Mov	CL,AH		; ..
	Push	CX		;Save byte count
	Mov	AX,81H		;Remove any trailing spaces
	Mov	DI,AX		; ..
	Mov	AL,' '		;  ..
	Repe	Scasb		;   ..
	Or	CX,CX		;Anything there yet?
	Jnz	Parm_OK1	;Yes
	Jmp	Protect_Mem	;No, go ahead with memory protect option
Parm_OK1:
	Pop	CX		;Restore current position
	Mov	AX,81H		;Check for '/'
	Mov	DI,AX		; ..
	Mov	AL,'/'		;  ..
	Repne	Scasb		;   ..
	Or	CX,CX		;Is it there?
	Jnz	Parm_OK2	;Yes
	Jmp	Protect_Mem	;No, go ahead with memory protect option
Parm_OK2:
	Mov	AH,[DI]		;Get the parameter
	Cmp	AH,'a'		;Convert to upper case
	Jl	Parm_OK3	; ..
	Sub	AH,20H		;  ..
Parm_OK3:
	Cmp	AH,'N'		;Skip memory protect option?
	Jne	Protect_Mem	;No
	Mov	AH,9			    ;Print memory not protected message
	Mov	DX,OFFSET Mem_Not_Protected ; ..
	Int	21H			    ;  ..
	Jmp	Skip_Protect_Mem

Protect_Mem:
	Push	DS		;Save DS
	Mov	AX,DS		;Get current PSP address
	Dec	AX		;PSP Addr - 1 = Memory Block Header
	Mov	DS,AX		; ..
	Mov	AX,DS:[3]	;  ..
	Sub	AX,16384/16	;Decrease paragraph count by 16K
	Mov	DS:[3],AX	; ..
	Mov	AX,40H		;Get memory size in K
	Mov	DS,AX		; ..
	Mov	AX,DS:[13H]	;  ..
	Sub	AX,16		;Decrease memory size 16K
	Mov	DS:[13H],AX	; ..
	Pop	DS		;Restore DS
	Mov	AH,49H		;Deallocate Environment Block
	Mov	DX,002CH	; ..
	Mov	ES,DX		;  ..
	Int	21H		;   ..
	Mov	AH,9			;Print memory protected message
	Mov	DX,OFFSET Mem_Protected ; ..
	Int	21H			;  ..

Skip_Protect_Mem:
	Mov	AH,35H		;Get vector address for INT 10H
	Mov	AL,10H		; ..
	Int	21H		;  ..
	Mov	WORD PTR [Old10Int+2],ES ;Save vector address
	Mov	WORD PTR [Old10Int],BX	 ; ..
	Mov	AH,35H		;Get vector address for INT 1CH
	Mov	AL,1CH		; ..
	Int	21H		;  ..
	Mov	WORD PTR [Old1CInt+2],ES ;Save vector address
	Mov	WORD PTR [Old1CInt],BX	 ; ..
	Mov	AH,25H		   ;Change Video BIOS vector to new address
	Mov	AL,10H		   ; ..
	Mov	DX,OFFSET NewInt10 ;  ..
	Int	21H		   ;   ..
	Mov	AH,25H		;Change clock tick vector to new address
	Mov	AL,1CH		; ..
	Mov	DX,OFFSET Timer ;  ..
	Int	21H		;   ..
	Mov	DX,OFFSET Setup ;Setup paragraph count for terminate
	Mov	CL,4		; ..
	Shr	DX,CL		;  ..
	Inc	DX		;   ..
	Mov	AH,31H		;Terminate and Stay Resident
	Mov	AL,0		; ..
	Int	21H		;  ..

Installed_Message:
	DB	13,10,'GRAFIX 1.1'
	DB	13,10
	DB	13,10,'Tandy 1000 Graphics and Sound Extensions for the'
	DB	13,10,'320 X 200 X 16 color graphics mode and the Texas'
	DB	13,10,'Instruments SN76496 sound chip is now installed$'

Mem_Protected:
	DB	13,10,'WITH protection of video memory.'
	DB	13,10,'$'
Mem_Not_Protected:
	DB	13,10,'WITHOUT protection of of video memory.'
	DB	13,10,'$'

Installed_Error:
	DB	13,10,'GRAFIX 1.1 is already installed!',7,13,10,'$'

Code	ENDS

	END	Start
