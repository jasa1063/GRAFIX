	Page	60,132
	Title	Tandy 1000 Graphics And Sound Extensions
	Name	Grafix

;------------------------------------------------------------------------------;
;									       ;
;				  GRAFIX 1.00				       ;
;									       ;
;		    Tandy 1000 Graphics And Sound Extensions		       ;
;		      320 x 200 x 16 Color Graphics Mode		       ;
;		     Texas Instruments SN76496 Sound Chip		       ;
;									       ;
;    Based on the GRAPH.ASM program in the July, 1988 issue of PCM magazine    ;
;									       ;
;			       Original Author:				       ;
;			     John B. Harrell, III			       ;
;									       ;
;				 Expanded by:				       ;
;			      Joseph A. Albrecht			       ;
;			     125 West Raven Street			       ;
;			    Belle Plaine, MN  56011			       ;
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

Pusha	MACRO
	Push	AX
	Push	CX
	Push	DX
	Push	BX
	Push	BP
	Push	SI
	Push	DI
	ENDM

Popa	MACRO
	Pop	DI
	Pop	SI
	Pop	BP
	Pop	BX
	Pop	DX
	Pop	CX
	Pop	AX
	ENDM

Code	Segment Public 'Code'

	Assume	CS:Code,DS:Code,ES:Code,SS:Code

	Org	100H

Grafix: Jmp	Setup		;Jump to TSR initialization code

	Even

Old10Int	DD	?	;Old Video BIOS interrupt vector address
Old1CInt	DD	?	;Old Clock Tick interrupt vector address
Save_SP		DW	?	;Save current Stack Pointer
Save_SS		DW	?	;Save current Stack Segment
Save_DS		DW	?	;Save Segment address of variables passed
Old_X		DW	?	;Last X ordinate value
Old_Y		DW	?	;Last Y ordinate value
X_Aspect	DW	?	;Horizontal part of aspect ratio
Y_Aspect	DW	?	;Vertical part of aspect ratio
D_Color		DW	?	;Current drawing color
B_Color		DW	?	;Current background color
T_Color		DW	?	;Current text color
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
PBuf_Ptr1	DW Offset Sound_Buf1 ;Sound buffer 1 pointer for putting sounds
PBuf_Ptr2	DW Offset Sound_Buf2 ;Sound buffer 2 pointer for putting sounds
PBuf_Ptr3	DW Offset Sound_Buf3 ;Sound buffer 3 pointer for putting sounds
PBuf_Ptr4	DW Offset Noise_Buf  ;Noise buffer pointer for putting noises
GBuf_Ptr1	DW Offset Sound_Buf1 ;Sound buffer 1 pointer for getting sounds
GBuf_Ptr2	DW Offset Sound_Buf2 ;Sound buffer 2 pointer for getting sounds
GBuf_Ptr3	DW Offset Sound_Buf3 ;Sound buffer 3 pointer for getting sounds
GBuf_Ptr4	DW Offset Noise_Buf  ;Moise buffer pointer for getting noises
Buf_Cnt1	DW	0	;Sound buffer 1 current total
Buf_Cnt2	DW	0	;Sound buffer 2 current total
Buf_Cnt3	DW	0	;Sound buffer 3 current total
Buf_Cnt4	DW	0	;Noise buffer current total

DeltaX		DW	?	;Variables
DeltaY		DW	?	; .. used in
YIncr		DW	?	;  .. line drawing

Temp_X		DW	?	;Variables
Temp_Y		DW	?	; .. used in
Scale		DW	?	;  .. circle drawing
Scale2		DW	?	;   ..
Aspect		DW	?	;    ..
InvAsp		DW	?	;     ..
XOrg		DW	?	;      ..
YOrg		DW	?	;	..
Radius		DW	?	;	 ..

Max		DW	?	;Variables
Save_Clr	DW	?	; .. used in
X1		DW	?	;  .. common routines
Y1		DW	?	;   ..
X2		DW	?	;    ..
Y2		DW	?	;     ..

Cursor		DW	8	;Graphics cursor (Cyan color # 3)
CursorRows	DW	8
		DW   16 DUP (3333H)

Paint_End:			;End of paint stack for overflow check
		DW  640 DUP (?) ;Paint Stack
Paint_Stack:			; ..

Scan_Above	DB  160 DUP (?) ;Used in 'Paint' for copy of above scan line
Scan_Below	DB  160 DUP (?) ;Used in 'Paint' for copy of below scan line
Scan_Middle	DB  160 DUP (?) ;Used in 'Paint' for copy of middle scan line

Sound_Buf1	DW  256 DUP (?) ;Sound buffer 1 - Sound channel 0
Buf_End1:			;End of sound buffer 1
Sound_Buf2	DW  256 DUP (?) ;Sound buffer 2 - Sound channel 1
Buf_End2:			;End of sound buffer 2
Sound_Buf3	DW  256 DUP (?) ;Sound buffer 3 - Sound channel 2
Buf_End3:			;End of sound buffer 3
Noise_Buf	DW  192 DUP (?) ;Noise buffer - Noise channel
Buf_End4:			;End of noise buffer

Buf_Num		EQU  64		;Number of entries in each sound/noise buffer

Call_Table:				;CALL table for GRAFIX functions
	DW	Offset Clear_Screen	;Function 00 -- Clear screen
	DW	Offset Color_Enable	;Function 01 -- Set color enable on/off
	DW	Offset Set_Color	;Function 02 -- Set color
	DW	Offset Get_Color	;Function 03 -- Get color
	DW	Offset Set_Aspect	;Function 04 -- Set aspect ratio
	DW	Offset Get_Aspect	;Function 05 -- Get aspect ratio
	DW	Offset Point		;Function 06 -- Set pixel at X,Y
	DW	Offset Get_Point	;Function 07 -- Get pixel color at X,Y
	DW	Offset Move_To		;Function 08 -- Move to X,Y
	DW	Offset Move_Rel		;Function 09 -- Move relative from X,Y
	DW	Offset Get_XY		;Function 10 -- Get current X,Y
	DW	Offset Line		;Function 11 -- Line
	DW	Offset Line_To		;Function 12 -- Line to X,Y
	DW	Offset Line_Rel		;Function 13 -- Line relative from X,Y
	DW	Offset Draw_Box		;Function 14 -- Draw box
	DW	Offset Circle		;Function 15 -- Draw circle
	DW	Offset Paint		;Function 16 -- Paint graphics shape
	DW	Offset Fill_Box		;Function 17 -- Fill rectangle
	DW	Offset Set_Palette	;Function 18 -- Change palette register
	DW	Offset Palette_Using	;Function 19 -- Change all 16 pal regs
	DW	Offset Reset_Palette	;Function 20 -- Reset all palette regs
	DW	Offset Get		;Function 21 -- Store an image
	DW	Offset Put		;Function 22 -- Transfer an image
	DW	Offset Set_Cursor	;Function 23 -- Set cursor mode
	DW	Offset Get_Cursor	;Function 24 -- Get cursor status
	DW	Offset Set_Cursor_Pos	;Function 25 -- Set cursor position
	DW	Offset Get_Cursor_Pos	;Function 26 -- Get cursor position
	DW	Offset Print_String	;Function 27 -- Print a string
	DW	Offset Animate		;Function 28 -- Animate
	DW	99 DUP (Offset Exit_Grafix) ;Filler
	DW	Offset System		;Function 80H - Global system functions
	DW	Offset Sound		;Function 81H - Generate a sound
	DW	Offset Noise		;Function 82H - Generate a noise
	DW	Offset Delay		;Function 83H - Delay loop
	DW	124 DUP (Offset Exit_Grafix) ;Filler

NewInt10:
	Cmp	AH,0EEH		;Test for a function call
	Je	Check
	Jmp	DWord Ptr CS:[Old10Int] ;Execute the normal video BIOS

Check:
	Cmp	AL,80H		;Check for a graphics call
	Jae	Check1		; ..
	Test	CS:Graph_Flag,1 ;See if graphics active
	Jnz	Check1		; ..
	Iret			;  ..
Check1:
	Cli			;Critical code -- interrupts off
	Mov	CS:Save_SP,SP	;Save current task SP
	Mov	CS:Save_SS,SS	;Save current task SS
	Sti			;Re-enable interrupts
	Mov	CS:Save_DS,DS	;Save segment address for variables passed
	Mov	SP,CS		;Set SS to current code segment
	Mov	SS,SP		; ..
	Mov	SP,0100H	;Use our PSP for stack
	Pusha			;Save registers
	Push	DS		; ..
	Push	ES		;  ..
	Mov	BP,CS		;Establish Data Segment for INT 10H extension
	Mov	DS,BP		; ..
	Lea	BP,Call_Table	;Index into functions table
	Xor	AH,AH		; ..
	Shl	AX,1		;  ..
	Add	BP,AX		;   ..
	Call	[BP]		;Call requested function
Exit_Grafix:
	Pop	ES		;Restore registers
	Pop	DS		; ..
	Popa			;  ..
	Cli			;Critical code -- interrupts off
	Mov	SP,CS:Save_SP	;Restore original stack values
	Mov	SS,CS:Save_SS	;  ..
	Sti			;Re-enable interrupts
	Iret			;Return to interrupted program

;
;Clear the graphics screen to the current background color
;

Clear_Screen:
	Mov	BX,0B800H	;Set screen segment address
	Mov	ES,BX		; ..
	Xor	DI,DI		;Starting offset address
	Xor	AX,AX		;Color 0 is current background color
	Mov	CX,16384	;Length of data area
	Cld			;Clear the direction flag
	Rep	Stosw		;Clear it
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
	Jmp	Color_Enable_Exit
Color_Enable1:
	Cmp	BX,1		;Turn color enable on?
	Jne	Color_Enable_Exit ;No
	Xor	AX,AX		;Point to BIOS data area
	Mov	ES,AX
	Mov	AL,ES:[0465H]	;Get BIOS copy of mode select register
	Mov	DX,3D8H		;Port # of mode select register
	And	AL,3BH		;Turn color enable bit on
	Mov	ES:[0465H],AL	;Write new copy to BIOS area
	Out	DX,AL		;Turn the color enable on
Color_Enable_Exit:
	Ret

;
;Set the current drawing, text, background color
;

Set_Color:
	And	CX,15		;Make sure color is 0-15
	Cmp	BX,1		;Set drawing color?
	Jne	Set_Color2	;No
	Mov	D_Color,CX	;Set the drawing color
	Jmp	Short Set_Color_Exit
Set_Color2:
	Cmp	BX,2		;Set text color?
	Jne	Set_Color3	;No
	Mov	T_Color,CX	;Set the text color
	Jmp	Short Set_Color_Exit
Set_Color3:
	Cmp	BX,3		;Set background color?
	Jne	Set_Color_Exit	;No
	Mov	B_Color,CX	;Set the background color
	Mov	AH,11		;Fake an INT 10H interrupt
	Mov	BH,0		; ..
	Mov	BL,CL		;  ..
	PushF			;   ..
	Call	DWord Ptr CS:[Old10Int]
Set_Color_Exit:
	Ret

;
;Get the current draw, text, background color
;

Get_Color:
	Cmp	BX,1		;Get the drawing color
	Jne	Get_Color2	;No
	Mov	CX,D_Color	;Yes, get the drawing color
	Mov	SS:[00FCH],CX
	Jmp	Short Get_Color_Exit
Get_Color2:
	Cmp	BX,2		;Get the text color
	Jne	Get_Color3	;No
	Mov	CX,T_Color	;Yes, get the text color
	Mov	SS:[00FCH],CX
	Jmp	Short Get_Color_Exit
Get_Color3:
	Cmp	BX,3		;Get the background color
	Jne	Get_Color_Exit	;No
	Mov	CX,B_Color	;Yes, get the background color
	Mov	SS:[00FCH],CX
Get_Color_Exit:
	Ret

;
;Set the aspect ratio for circle drawing
;

Set_Aspect:
	Mov	X_Aspect,BX
	Mov	Y_Aspect,CX
	Ret

;
;Get the current aspect ratio for circle drawing
;

Get_Aspect:
	Mov	BX,X_Aspect
	Mov	SS:[00F8H],BX
	Mov	CX,Y_Aspect
	Mov	SS:[00FCH],CX
	Ret

;
;Calculate video  segment and offset  for the Tandy  1000 320 X  200 X 16  color
;graphics mode. Returns the segment and offset in ES:DI
;

Calc_Address:
	Mov	ES,DI		;Save row
	Shr	SI,1		;Form offset address in DI
	Shr	DI,1		; .. ((Row / 4) * 160) + (Col / 2)
	Shr	DI,1		;  ..
	Mov	CL,5		;   ..
	Shl	DI,CL		;    ..
	Mov	CX,DI		;     ..
	Shl	DI,1		;      ..
	Shl	DI,1		;	..
	Add	DI,CX		;	 ..
	Add	DI,SI		;	  ..
	Mov	SI,ES		;Restore row
	And	SI,3		;Form segment address in ES
	Mov	CL,9		; .. (Row MOD 4) * 512
	Shl	SI,CL		;  ..
	Add	SI,0B800H	;   ..
	Mov	ES,SI		;    ..
	Ret

;
;Internal  pixel writing  routine used	 by 'Point',  'Line', and  'Circle'. For
;clipping  at  screen  boundries,  call  entry	point  '$Point', for no clipping
;checks, call entry point '$Point1'.
;

$Point:
	Cmp	SI,319		;SI=X, DI=Y  Does not set Old_X & Old_Y
	Ja	Clip_It
	Cmp	SI,0
	Jb	Clip_It
	Cmp	DI,199
	Ja	Clip_It
	Cmp	DI,0
	Jnb	$Point1
Clip_It:
	Ret
$Point1:			;SI=X, DI=Y - No clipping!!!
	Pusha
	Mov	BX,SI		;Save column
	Call	Calc_Address	;Get video address
	Mov	AX,D_Color	;Get color for pixel
	Mov	AH,0F0H		;Set mask for odd pixel
	Test	BX,1		;Check for odd/even pixel
	Jnz	$Point2
	Not	AH		;Set mask for even pixel
	Shl	AL,1		;Move to left nybble
	Shl	AL,1
	Shl	AL,1
	Shl	AL,1
$Point2:
	Mov	DL,ES:[DI]	;Plot the point
	And	DL,AH		; ..
	Or	DL,AL		;  ..
	Mov	ES:[DI],DL	;   ..
	Popa
	Ret

;
;Plot a point using the current drawing color
;

Point:
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Jmp	$Point		;Plot the point
Point_Exit:
	Ret

;
;Get the pixel color a point X,Y
;

Get_Point:
	Mov	BX,SI		;Save column
	Call	Calc_Address	;Get video address
	Mov	AL,ES:[DI]	;Get byte from video memory
	Test	BX,1		;Test for odd/even pixel
	Jnz	Get_Point1
	Shr	AL,1		;Move color lower nybble
	Shr	AL,1		; ..
	Shr	AL,1		;  ..
	Shr	AL,1		;   ..
Get_Point1:
	And	AX,000FH	;Mask off unwanted bits
	Mov	SS:[00FEH],AX
	Ret

;
;Move to the specified position from Old_X, Old_Y without plotting any points
;

Move_To:
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Ret

;
;Move a relative distance from Old_X, Old_Y without plotting any points
;

Move_Rel:
	Mov	AX,Old_X	;Calculate relative position
	Add	AX,SI		; ..
	Mov	BX,Old_Y	;  ..
	Add	BX,DI		;   ..
	Mov	Old_X,AX	;Update old X,Y values
	Mov	Old_Y,BX	; ..
	Ret

;
;Get current X,Y position
;

Get_XY:
	Mov	BX,Old_X	;Return the current X position
	Mov	SS:[00F8H],BX	; ..
	Mov	CX,Old_Y	;Return the current Y position
	Mov	SS:[00FCH],CX	; ..
	Ret

;
;Internal  primative  line  drawing  algorithm	 used  by  'Line'  and	'Circle'
;procedures. Uses  Breshenham's fast differential  integer line algorithm.  This
;algorithm finds the closet integer coordinates  to the actual line's path using
;only integer arithmetic and is very fast.
;

$Plot_Line:
	Cmp	SI,AX		;Test for proper ordering of x-ordinates
	Jbe	NoXchg
	Xchg	SI,AX		;Swap co-ordinate values if required
	Xchg	DI,BX
NoXchg:
	Jne	Plot_Line1
	Jmp	Vertical	;X1 = X2 --> simple line drawing problem
Plot_Line1:
	Sub	AX,SI
	Mov	DeltaX,AX	;Form differential value for X
	Sub	BX,DI		;Form differential value for Y
	Jnz	Plot_Line2
	Jmp	Horizontal	;Y1 = Y2 --> simple line drawing problem
Plot_Line2:
	Mov	CX,1
	Jns	NotNeg
	Neg	CX
	Neg	BX
NotNeg:
	Mov	YIncr,CX
	Mov	DeltaY,BX
	Cmp	AX,BX
	Jg	Case2
	Mov	DX,DeltaX
	Shl	DX,1
	Mov	BX,DX
	Mov	AX,DeltaY
	Shl	AX,1
	Sub	BX,AX
	Mov	AX,DX
	Sub	AX,DeltaX
	Mov	CX,DeltaY
Lp1:
	Dec	CX
	Js	Plot_Line_Exit
	Call	$Point
	Add	DI,YIncr
	Cmp	AX,0
	Jl	Incr1
	Inc	SI
	Add	AX,BX
	Jmp	Short Lp1
Incr1:
	Add	AX,DX
	Jmp	Short Lp1
Case2:
	Mov	DX,DeltaY
	Shl	DX,1		;DX <= 2 * DeltaY
	Mov	BX,DX
	Mov	AX,DeltaX
	Shl	AX,1
	Sub	BX,AX		;BX <= 2 * DeltaY - DeltaX
	Mov	AX,DX
	Sub	AX,DeltaX
	Mov	CX,DeltaX
Lpt2:
	Dec	CX
	Js	Plot_Line_Exit
	Call	$Point
	Inc	SI
	Cmp	AX,0
	Jl	Incr2
	Add	DI,YIncr
	Add	AX,BX
	Jmp	Short Lpt2
Incr2:
	Add	AX,DX
	Jmp	Short Lpt2
Vertical:			;SI = XVal, BX, DI = YVal
	Cmp	DI,BX
	Jle	YOrder
	Xchg	BX,DI
YOrder:
	Sub	BX,DI
VPlot:
	Call	$Point
	Inc	DI
	Dec	BX
	Jns	VPlot
	Jmp	Short Plot_Line_Exit
Horizontal:			;AX = DeltaX, SI, DI = Start point
	Call	$Point
	Inc	SI
	Dec	AX
	Jns	Horizontal
Plot_Line_Exit:
	Ret

;
;Draw a line from X1,Y1 - X2,Y2 using the current drawing color
;

Line:
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Mov	AX,BX		;Setup proper values for $Plot_Line
	Mov	BX,CX		; ..
	Jmp	$Plot_Line	;Plot the line

;
;Draw  a line  to the  specified position  from Old_X,	Old_Y using  the current
;drawing color
;

Line_To:
	Mov	AX,SI		;Setup proper values for $Plot_Line
	Mov	BX,DI		; ..
	Mov	SI,Old_X	;  ..
	Mov	DI,Old_Y	;   ..
	Mov	Old_X,AX	;Update old X,Y values
	Mov	Old_Y,BX	; ..
	Jmp	$Plot_Line	;Plot the line

;
;Draw a  line a relative  distance from Old_X,	Old_Y using the  current drawing
;color
;

Line_Rel:
	Mov	AX,Old_X	;Calculate relative position
	Add	AX,SI		; ..
	Mov	BX,Old_Y	;  ..
	Add	BX,DI		;   ..
	Xchg	AX,SI		;Setup proper values for $Plot_Line
	Xchg	BX,DI		; ..
	Mov	AX,Old_X	;  ..
	Mov	BX,Old_Y	;   ..
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Jmp	$Plot_Line	;Plot the line

;
;Draw a line box from X1,Y1 - X2,Y2 in the specified color
;

Draw_Box:
	And	DX,15		;Validate color
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Mov	AX,D_Color	;Save current drawing color
	Mov	Save_Clr,AX	; ..
	Mov	D_Color,DX	;Set drawing color
	Mov	X1,BX
	Mov	Y1,CX
	Mov	X2,SI
	Mov	Y2,DI
	Mov	DI,CX
	Mov	AX,BX
	Mov	BX,CX
	Call	$Plot_Line	;Line (X1,Y1) - (X2,Y2)
	Mov	SI,X2
	Mov	AX,SI
	Mov	BX,Y1
	Mov	DI,Y2
	Call	$Plot_Line	;LineTo (X2,Y2)
	Mov	SI,X1
	Mov	DI,Y2
	Mov	BX,DI
	Mov	AX,X2
	Call	$Plot_Line	;Line (X1,Y1) - (X2,Y2)
	Mov	SI,X1
	Mov	AX,SI
	Mov	DI,Y2
	Mov	BX,Y1
	Call	$Plot_Line	;LineTo (X1,Y1)
	Mov	AX,Save_Clr	;Restore current drawing color
	Mov	D_Color,AX	; ..
Draw_Box_Exit:
	Ret

;
;Draw a circle at origin X,Y with the specified radius using the current drawing
;color.
;
;(Dan Lee 07/01/82, SourceWare)
;

Circle:
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Mov	XOrg,SI
	Mov	YOrg,DI
	Or	BX,BX
	Jnz	Ok_Rad
	Jmp	Single		;Simple case --> Only a point where R = 0
Ok_Rad:
	Mov	Radius,BX
	Mov	AX,1024
	Mov	Scale,AX
	Shr	AX,1
	Mov	Scale2,AX
	Mov	AX,Y_Aspect	;Get aspect
	Mul	Scale		;AX = Y_Aspect * Scale
	Shl	AX,1
	Div	X_Aspect	;AX = (Y_Aspect * Scale) / X_Aspect
	Inc	AX
	Shr	AX,1
	Mov	Aspect,AX	;Store Aspect * Scale
	Mov	AX,X_Aspect	;Get X_Aspect in AX
	Mul	Scale		;AX = X_Aspect * Scale
	Shl	AX,1
	Div	Y_Aspect	;AX = (X_Aspect * Scale) / Y_Aspect
	Inc	AX
	Shr	AX,1
	Mov	InvAsp,AX	;Store Inv Aspect * Scale

;Plot 0 to 45 degrees.
;Increase Y by one unit and
;decrease X by TAN units*Inv Aspect ratio.

	Mov	AX,Radius	;Get radius for initial X
	Mul	Scale		;AX = Radius * Scale
	Xor	DI,DI		;Zero initial Y value
	Push	AX		;Save lo word X * Scale
	Push	DX		;Save hi word X * Scale
	Add	AX,Scale2
	Adc	DX,0
	Div	Scale
	Mov	Temp_X,AX	;Temp_X, Temp_Y are old relative coord's
	Mov	Temp_Y,DI
	Pop	DX
	Pop	AX
Circle_Loop1:
	Push	AX		;Save lo word X * Scale
	Push	DX		;Save hi word X * Scale
	Add	AX,Scale2
	Adc	DX,0
	Div	Scale
	Mov	BX,AX		;BX = 1st quad X
	Add	AX,XOrg		;Add X origin
	Push	BP
	Push	DI		;Relative Y-coord
	Push	BX		;Relative X-coord
	Mov	BP,SP
	Mov	BX,YOrg		;Get Y origin
	Sub	BX,DI		;and sub Y to plot
	Call	Pnt1
	Pop	CX		;1st quad X val
	Pop	DI
	Mov	Temp_X,CX
	Mov	Temp_Y,DI
	Pop	BP
;CX = 1st quad X, DI = 1st quad Y
	Inc	DI		;Get new Y
	Mov	AX,DI		;AX = Y
	Mul	InvAsp		;AX = Y * Inv Aspect * Scale
	Div	CX		;AX = TAN * Inv Aspect * Scale
	Xor	DX,DX		;Zero remainder
	Mov	SI,AX		;SI = TAN * Inv Aspect * Scale
	Div	InvAsp		;AX = TAN
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
	Mul	Scale		;DX:AX = Y * Scale
	Mov	DI,CX		;DI = Last X value
	Dec	DI		;Next X to plot
Circle_Loop2:
	Push	AX		;Save lo word Y * Scale
	Push	DX		;Save hi word Y * Scale
	Add	AX,Scale2	;'one-half'
	Adc	DX,0
	Div	Scale		;AX = Y
	Mov	BX,AX		;BX = 1st quad Y coord
	Add	AX,YOrg		;Add Y origin
	Mov	CX,XOrg		;CX = X origin
	Add	CX,DI		;X to plot
	Push	BP
	Push	BX
	Push	DI
	Mov	BP,SP
	Mov	BX,AX
	Mov	AX,CX
	Call	Near Ptr Pnt2
	Pop	DI
	Pop	BX
	Mov	Temp_X,DI
	Mov	Temp_Y,BX
	Pop	BP
	Or	DI,DI		;90 degrees?
	Js	Exit		;Yes, exit
	Dec	DI		;Get new X
	Mov	AX,DI		;AX = X
	IMul	Aspect		;AX X * Aspect * Scale
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
Exit:
	Add	SP,4		;Release parms
	Jmp	AllDone

;BP points to rel X coord and BP+2 points to rel Y coord
;ABS coords of point are in AX,BX

Pnt1:
	Mov	SI,Temp_X
	Add	SI,XOrg		;SI is old abs X
	Mov	DI,YOrg
	Mov	CX,Temp_Y
	Sub	DI,CX		;DI is old abs Y
	Call	Plot_Line_Seg	;Write 1st quad point
	Sub	AX,[BP]		;Get 2nd quad X + origin
	Sub	AX,[BP]
	Sub	SI,Temp_X
	Sub	SI,Temp_X
	Call	Plot_Line_Seg	;Write 2nd quad point
	Add	BX,[BP+2]	;Get 3rd quad Y + origin
	Add	BX,[BP+2]
	Add	DI,Temp_Y
	Add	DI,Temp_Y
	Call	Plot_Line_Seg	;Write 3rd quad point
	Add	AX,[BP]
	Add	AX,[BP]		;Get 4th quad X + origin
	Add	SI,Temp_X
	Add	SI,Temp_X
	Call	Plot_Line_Seg	;Write 4th quad point
	Ret

Pnt2:
	Mov	SI,Temp_X
	Add	SI,XOrg
	Mov	DI,YOrg
	Add	DI,Temp_Y
	Call	Plot_Line_Seg	;Write 1st quad point
	Sub	AX,[BP]		;Get 2nd quad X + origin
	Sub	AX,[BP]
	Sub	SI,Temp_X
	Sub	SI,Temp_X
	Call	Plot_Line_Seg	;Write 2nd quad point
	Sub	BX,[BP+2]	;Get 3rd quad Y + origin
	Sub	BX,[BP+2]
	Sub	DI,Temp_Y
	Sub	DI,Temp_Y
	Call	Plot_Line_Seg	;Write 3rd quad point
	Add	AX,[BP]
	Add	AX,[BP]		;Get 4th quad X + origin
	Add	SI,Temp_X
	Add	SI,Temp_X
	Call	Plot_Line_Seg	;Write 4th quad point
	Ret

Single:
	Mov	SI,CX
	Mov	DI,DX
	Call	$Point
AllDone:
	Ret

Plot_Line_Seg:
	Push	AX
	Push	BX
	Push	SI
	Push	DI
	Call	$Plot_Line
	Pop	DI
	Pop	SI
	Pop	BX
	Pop	AX
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
	Cmp	BP,Offset Paint_End ;Check for stack overflow
	Ja	PushPaint1
	Ret
PushPaint1:
	Sub	BP,4		;Decrement stack pointer first
	Mov	[BP+2],SI	;Push X
	Mov	[BP],DI		;Push Y
	ENDM

;MACRO to pop X,Y from the paint stack
PopPaint MACRO
	Mov	DI,[BP]		;Pop Y
	Mov	SI,[BP+2]	;Pop X
	Add	BP,4		;Increment stack pointer after
	ENDM

;MACRO to get the color at X,Y (Above & below scan lines)
GetPtAB MACRO
	LOCAL GetPtAB1
	Mov	BX,SI		;Index into scan lines
	Shr	BX,1		; ..
	Add	BX,Offset Scan_Above
	Mov	CL,[BX]		;Above scan line color in CL
	Mov	CH,[BX+160]	;Below scan line color in CH
	Test	SI,1		;Check for odd/even pixel
	Jnz	GetPtAB1
	Shr	CX,1		;Move to lower nybble
	Shr	CX,1		; ..
	Shr	CX,1		;  ..
	Shr	CX,1		;   ..
GetPtAB1:
	And	CX,0F0FH	;Mask off unwanted bits
	ENDM

;MACRO to get the color at X,Y (Middle scan line)
GetPtM	MACRO
	LOCAL GetPtM1
	Mov	BX,SI		;Index into scan line
	Shr	BX,1		; ..
	Add	BX,Offset Scan_Middle
	Mov	CL,[BX]		;Middle scan line color in CL
	Test	SI,1		;Check for odd/even pixel
	Jnz	GetPtM1
	Shr	CL,1		;Move to lower nybble
	Shr	CL,1		; ..
	Shr	CL,1		;  ..
	Shr	CL,1		;   ..
GetPtM1:
	And	CL,0FH		;Mask off unwanted bits
	ENDM

;MACRO to get scan line address in DS:SI
CalcScan MACRO
	Mov	SI,DI		;Form offset address in SI
	Shr	SI,1		; .. ((Row / 4) * 160)
	Shr	SI,1		;  ..
	Mov	CL,5		;   ..
	Shl	SI,CL		;    ..
	Mov	CX,SI		;     ..
	Shl	SI,1		;      ..
	Shl	SI,1		;	..
	Add	SI,CX		;	 ..
	And	DI,3		;Form segment address in DS
	Mov	CL,9		; .. (Row MOD 4) * 512
	Shl	DI,CL		;  ..
	Add	DI,0B800H	;   ..
	Mov	DS,DI		;    ..
	ENDM


;Initialize paint color & paint stack
Paint:
	And	BX,15		;Make sure colors are 0-15
	And	CX,15		;   ..
	Cld			;Make sure string operations go forward
	Mov	DH,CL		;Boundry color in DH
	Mov	DL,BL		;Fill color in DL
	Lea	BP,Paint_Stack	;BP is set to top of stack
	PushPaint		;Push seed onto stack

;Main loop for painting
Paint1:
	Lea	AX,Paint_Stack	;Stack empty?
	Cmp	BP,AX
	Jne	Paint2		;If not continue
	Ret			;If so exit

;Get the next place to paint
Paint2:
	PopPaint		;Pop the next place to paint

;Get above, middle, & below scan lines
	Mov	BX,SI		;Save current X
	Mov	AX,DS		;Put DS into ES
	Mov	ES,AX		; ..
	Mov	AX,DI		;save current Y
	Dec	DI		;Get above scan line
	CalcScan		; ..
	Lea	DI,Scan_Above	;Copy the scan line
	Mov	CX,80		; ..
	Rep	Movsw		;  ..
	Mov	DI,AX		;Restore current Y
	CalcScan		;Get middle scan line
	Lea	DI,Scan_Middle	;Copy the scan line
	Mov	CX,80		; ..
	Rep	Movsw		;  ..
	Mov	DI,AX		;Restore current Y
	Inc	DI		;Get below scan line
	CalcScan		; ..
	Lea	DI,Scan_Below	;Copy the scan line
	Mov	CX,80		; ..
	Rep	Movsw		;  ..
	Mov	DI,AX		;Restore current Y
	Mov	AX,ES		;Restore DS
	Mov	DS,AX		; ..
	Mov	SI,BX		;Restore current X

;Get initial color
	GetPtM			;Get initial color
	Cmp	CL,DL		;Is it filled?
	Je	GOTOPaint1
	Cmp	CL,DH		;Is it boundry?
	Je	GOTOPaint1
	Cmp	DI,0		;Top of screen?
	Jl	GOTOPaint1
	Cmp	DI,199		;Bottom of screen?
	Jg	GOTOPaint1
	Jmp	Short Paint3
GOTOPaint1:
	Jmp	Paint1

;Move right until boundry is reached
Paint3:
	Inc	SI		;X <-- X + 1
	Cmp	SI,319		;At right screen boundry
	Jg	Paint4
	GetPtM			;Look right
	Cmp	CL,DL		;Is it filled?
	Je	Paint4
	Cmp	CL,DH		;Is it boundry?
	Je	Paint4
	Jmp	Short Paint3

;Push above and below
Paint4:
	Dec	SI		;Restore X
	GetPtAB			;Check above & below
	Mov	AH,CL		;Save above state
	Cmp	CL,DL		;Is it filled?
	Je	Paint5
	Cmp	CL,DH		;Is it boundry?
	Je	Paint5
	Dec	DI		;Y <-- Y - 1
	PushPaint		;Push above
	Inc	DI		;Restore Y
Paint5:
	Mov	AL,CH		;Save below state
	Cmp	CH,DL		;Is it filled?
	Je	Paint6
	Cmp	CH,DH		;Is it boundry?
	Je	Paint6
	Inc	DI		;Y <-- Y + 1
	PushPaint		;Push below
	Dec	DI		;Restore Y
Paint6:

;Anchor the end point of the scan line
	Mov	X1,SI		;Store X ordinate end of scan line

;Scan left, check above and below
Paint7:
	GetPtAB			;Check above & below
	Cmp	CL,DL		;Is it filled?
	Je	Paint9
	Cmp	CL,DH		;Is it boundry?
	Je	Paint9
	Cmp	AH,DL		;Last above filled?
	Je	Paint8
	Cmp	AH,DH		;Last above boundry?
	Je	Paint8
	Jmp	Short Paint9
Paint8:
	Dec	DI		;Y <-- Y - 1
	PushPaint		;Push above if new place to paint
	Inc	DI		;Restore Y

Paint9:
	Mov	AH,CL		;Update last above

;Check below
	Cmp	CH,DL		;Is it filled?
	Je	Paint11
	Cmp	CH,DH		;Is it boundry?
	Je	Paint11
	Cmp	AL,DL		;Last below filled?
	Je	Paint10
	Cmp	AL,DH		;Last below boundry?
	Je	Paint10
	Jmp	Short Paint11
Paint10:
	Inc	DI		;Y <-- Y + 1
	PushPaint		;Push below if new place to paint
	Dec	DI		;Restore Y

Paint11:
	Mov	AL,CH		;Update last below

;Move left
	Dec	SI		;X <-- X - 1
	Jl	Paint12		;Stop the scan if too far left
	GetPtM			;Check the point
	Cmp	CL,DL		;Hit filled yet?
	Je	Paint12		;If so next scan line
	Cmp	CL,DH		;Hit boundry yet?
	Je	Paint12		;If so next scan line
	Jmp	Paint7		;Continue painting the scan line

Paint12:
	Inc	SI		;Restore X
	Pusha			;Save registers
	Mov	AX,DI		;Save row
	Mov	BX,SI		;Save starting column
	Call	Calc_Address	;Get starting address
	Test	BX,1		;Check for partial byte
	Mov	BX,DI		;Save starting address
	Jz	Paint13
	And	Byte Ptr ES:[DI],0F0H ;Transfer pixel
	Or	ES:[DI],DL	; ..
	Inc	BX		;Point to next byte
Paint13:
	Mov	SI,X1		;Get ending column
	Mov	DI,AX		;Restore row
	Call	Calc_Address	;Get ending address
	Test	X1,1		;Check for partial byte
	Jnz	Paint14
	Mov	CL,DL		;Fill color in CL
	Shl	CL,1		;Move color to upper nybble
	Shl	CL,1		; ..
	Shl	CL,1		;  ..
	Shl	CL,1		;   ..
	And	Byte Ptr ES:[DI],0FH ;Transfer pixel
	Or	ES:[DI],CL	; ..
	Dec	DI		;Point to previous byte
Paint14:
	Mov	CX,DI		;Get ending address
	Mov	DI,BX		;Get starting address
	Sub	CX,DI		;Get byte count
	Jb	Paint15		;Nothing more to do
	Inc	CX		;ES:DI = Video scanline, CX = Byte count
	Mov	AL,DL		;Fill color in AL
	Shl	AL,1		;Form full byte of color
	Shl	AL,1		; ..
	Shl	AL,1		;  ..
	Shl	AL,1		;   ..
	Or	AL,DL		;    ..
	Rep	Stosb		;Fill the scan line
Paint15:
	Popa			;Restore registers
	Jmp	Paint1		;Next place to paint

;
;Draw a solid filled box from X1,Y1 - X2,Y2 using the specified color
;

Fill_Box:
	And	DX,15		;Make sure color is 0-15
	Cld			;Make sure string operations go forward
	Mov	Old_X,SI	;Update old X,Y values
	Mov	Old_Y,DI	; ..
	Mov	X1,BX		;Setup X1,Y1 - X2,Y2 values
	Mov	X2,SI		; ..
	Mov	Y1,CX		;  ..
	Mov	Y2,DI		;   ..
Fill_Box1:
	Mov	SI,X1		;Get starting column
	Mov	DI,Y1		;Get current row
	Mov	AX,DI		;Save row
	Mov	BX,SI		;Save starting column
	Call	Calc_Address	;Get starting address
	Test	BX,1		;Check for partial byte
	Mov	BX,DI		;Save starting address
	Jz	Fill_Box2
	Mov	CL,DL		;Fill color in CL
	And	Byte Ptr ES:[DI],0F0H ;Transfer pixel
	Or	ES:[DI],CL	; ..
	Inc	BX		;Point to next byte
Fill_Box2:
	Mov	SI,X2		;Get ending column
	Mov	DI,AX		;Restore row
	Call	Calc_Address	;Get ending address
	Test	X2,1		;Check for partial byte
	Jnz	Fill_Box3
	Mov	CL,DL		;Fill color in CL
	Shl	CL,1		;Move color to upper nybble
	Shl	CL,1		; ..
	Shl	CL,1		;  ..
	Shl	CL,1		;   ..
	And	Byte Ptr ES:[DI],0FH ;Transfer pixel
	Or	ES:[DI],CL	; ..
	Dec	DI		;Point to previous byte
Fill_Box3:
	Mov	CX,DI		;Get ending
	Mov	DI,BX		;Get starting address
	Sub	CX,DI		;Get byte count
	Jb	Fill_Box4	;Nothing more to do
	Inc	CX		;ES:DI = Video scanline, CX = Byte count
	Mov	AL,DL		;Fill color in AL
	Shl	AL,1		;Form full byte of color
	Shl	AL,1		; ..
	Shl	AL,1		;  ..
	Shl	AL,1		;   ..
	Or	AL,DL		;    ..
	Rep	Stosb		;Fill the scan line
Fill_Box4:
	Inc	Y1		;Point to next row
	Mov	AX,Y1		;Check if all done
	Cmp	AX,Y2		; ..
	Jle	Fill_Box1	;No
	Ret

;
;Change a palette register color
;

Set_Palette:
	And	BX,15		;Make sure palette register number is 0-15
	And	CX,15		;Make sure color is 0-15
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
	Mov	DS,Save_DS	;Get segment address of array
	Mov	SI,DX		;Offset address in SI
	Mov	CS:B_Color,0	;Reset border color to palette register 0
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
	Mov	B_Color,0	;Reset background color to black
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
	Mov	DS,CS:Save_DS	;Get segment address of array
	Xchg	BX,SI		;Exchange registers for call to
	Xchg	CX,DI		; 'Calc_Address'
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
	Mov	CS:Max,AX	;Save # of bytes to process on a row
	Sub	CX,DI		;Get # of rows in image
	Inc	CX		; ..
	Mov	[BX+2],CX	;Store in 2nd word of array
	Add	BX,4		;Point to starting array image location
Get_Next:
	Push	CX		;Save # of rows to process
	Push	DI		;Save current row
	Push	SI		;Save beginning column
	Call	Calc_Address	;Get starting address of row
	Pop	SI		;Restore beginning column
	Mov	CX,CS:Max	;Get # of bytes to process on a row
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
	Mov	DS,CS:Save_DS	;Get segment address of array
	Xchg	BX,DX		;Store offset address in BX
	Mov	CX,[BX]		;Get # of columns to move
	Mov	CS:Max,CX	;Save # of columns to process on a row
	Mov	CX,[BX+2]	;Get # of rows in image
	Add	BX,3		;Point to starting array image location
	Test	Cursor_Flag,4	;Don't update Old_X, Old_Y if plotting cursor
	Jz	Put1
	Mov	CS:Old_Y,SI	;Update old X,Y values
	Mov	CS:Old_X,DI	;  ..
Put1:
	Cmp	DX,1		;PRESET?
	Jne	Put2		;No
	Lea	BP,Put_Preset	;Yes
	Jmp	Short Put_Next
Put2:
	Cmp	DX,2		;PSET?
	Jne	Put3		;No
	Lea	BP,Put_Pset	;Yes
	Jmp	Short Put_Next
Put3:
	Cmp	DX,3		;AND?
	Jne	Put4		;No
	Lea	BP,Put_And	;Yes
	Jmp	Short Put_Next
Put4:
	Cmp	DX,4		;OR?
	Jne	Put5		;No
	Lea	BP,Put_Or	;Yes
	Jmp	Short Put_Next
Put5:
	Lea	BP,Put_Xor	;XOR is the default

Put_Next:
	Push	CX		;Save # of rows to process
	Push	DI		;Save current row
	Push	SI		;Save beginning column
	Call	Calc_Address	;Get starting address of row
	Pop	SI		;Restore beginning column
	Mov	CX,CS:Max	;Get # of columns to process on a row
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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Xor_Even_Exit ;No, do next row
	And	AH,0FH		;Transfer pixle
	Xor	ES:[DI],AH	; ..
	Loop	Put_Xor_Even	;Do next pixel?
Put_Xor_Even_Exit:		;No, do next row
	Jmp	Put_Next_Row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Xor_Odd_Exit ;No, do next row
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Xor	ES:[DI+1],AH	;Transfer pixel
	Loop	Put_Xor_Odd	;Do next pixel?
Put_Xor_Odd_Exit:		;No, do next row
	Jmp	Put_Next_Row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Or_Even_Exit ;No, do next row
	And	AH,0FH		;Transfer pixel
	Or	ES:[DI],AH	; ..
	Loop	Put_Or_Even	;Do next pixel?
Put_Or_Even_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Or_Odd_Exit ;No, do next row
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Or	ES:[DI+1],AH	;Transfer pixel
	Loop	Put_Or_Odd	;Do next pixel?
Put_Or_Odd_Exit:
	Jmp	Put_Next_Row	;No, Do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_And_Even_Exit ;No, do next row
	Or	AH,0F0H		;Transfer pixel
	And	ES:[DI],AH	; ..
	Loop	Put_And_Even	;Do next pixel
Put_And_Even_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_And_Odd_Exit ;No, do next row
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Or	AH,0FH		;Transfer pixel
	And	ES:[DI+1],AH	; ..
	Loop	Put_And_Odd	;Do next pixel
Put_And_Odd_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Pset_Even_Exit ;No, do next row
	And	AH,0FH		;Transfer pixel
	And	DH,0F0H		; ..
	Or	DH,AH		;  ..
	Or	DH,DL		;   ..
	Mov	ES:[DI],DH	;    ..
	Loop	Put_Pset_Even	;Do next pixel?
Put_Pset_Even_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Pset_Odd_Exit ;No, do next row
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	And	DH,0FH		;Transfer pixel
	Or	DH,AH		; ..
	Mov	ES:[DI+1],DH	;   ..
	Loop	Put_Pset_Odd	;Do next pixel?
Put_Pset_Odd_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Preset_Even_Exit ;No, do next row
	And	AH,0FH		;Transfer pixel
	Xor	AH,0FH		; ..
	And	DH,0F0H		;  ..
	Or	DH,AH		;   ..
	Or	DH,DL		;    ..
	Mov	ES:[DI],DH	;     ..
	Loop	Put_Preset_Even ;Do next pixel?
Put_Preset_Even_Exit:
	Jmp	Put_Next_Row	;No, do next row

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
	Dec	CX		;Do next pixel?
	Jcxz	Put_Preset_Odd_Exit ;No, do next row
	Shl	AH,1		;Shift color to upper nybble
	Shl	AH,1		; ..
	Shl	AH,1		;  ..
	Shl	AH,1		;   ..
	Xor	AH,0F0H		;Transfer pixel
	And	DH,0FH		; ..
	Or	DH,AH		;  ..
	Mov	ES:[DI+1],DH	;    ..
	Loop	Put_Preset_Odd	;Do next pixel?
Put_Preset_Odd_Exit:		;No, do next row

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
;Turn the graphics cursor On or Off
;

Set_Cursor:
	Cmp	BX,0		;Off?
	Jne	Set_Cursor2
	Test	Cursor_Flag,1	;See if cursor is already off
	Jz	Set_Cursor1
	Mov	BX,Column	;Turn graphics cursor off
	Mov	CX,Row		; ..
	Call	Plot_Cursor2	;  ..
	And	Cursor_Flag,0FFFEH ;Set cursor flag off
Set_Cursor1:
	Jmp	Set_Cursor_Exit
Set_Cursor2:
	Cmp	BX,1		;On?
	Jne	Set_Cursor4
	Test	Cursor_Flag,1	;See if cursor is already on
	Jnz	Set_Cursor3
	Or	Cursor_Flag,1	;Set cursor flag on
	Mov	BX,Column	;Turn graphics cursor on
	Mov	CX,Row		; ..
	Call	Plot_Cursor2	;  ..
Set_Cursor3:
	Jmp	Set_Cursor_Exit
Set_Cursor4:
	Cmp	BX,2		;Half cursor off?
	Jne	Set_Cursor6
	Test	Cursor_Flag,2	;See if half cursor is already off
	Jz	Set_Cursor5
	Mov	BX,Column	;Turn half cursor off
	Mov	CX,Row		; ..
	Call	Plot_Cursor2	;  ..
	Mov	CursorRows,8	;Turn regular cursor back on
	Mov	BX,Column	; ..
	Mov	CX,Row		;  ..
	Call	Plot_Cursor2	;   ..
	And	Cursor_Flag,0FFFDH ;Set half cursor flag off
Set_Cursor5:
	Jmp	Set_Cursor_Exit
Set_Cursor6:
	Cmp	BX,3		;Half cursor on?
	Jne	Set_Cursor_Exit
	Test	Cursor_Flag,2	;See if half cursor is already On
	Jnz	Set_Cursor_Exit
	Mov	BX,Column	;Turn regular cursor off
	Mov	CX,Row		; ..
	Call	Plot_Cursor2	;  ..
	Mov	CursorRows,4	;Turn half cursor on
	Mov	BX,Column	; ..
	Mov	CX,Row		;  ..
	Call	Plot_Cursor2	;   ..
	Or	Cursor_Flag,2	;Set half cursor flag on
Set_Cursor_Exit:
	Ret

;
;Return the current graphics cursor status Off or On, Full or Half
;

Get_Cursor:
	Mov	BX,Cursor_Flag	;Get the current status on or off
	And	BX,1		; ..
	Mov	SS:[00F8H],BX	;  ..
	Mov	CX,Cursor_Flag	;Get the current size full or half
	And	CX,2		; ..
	Shr	CX,1		;  ..
	Mov	SS:[00FCH],CX	;   ..
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
	Call	DWord Ptr CS:[Old10Int]
	Pop	CX		;Restore row & column
	Pop	BX		; ..
	Call	Plot_Cursor	;Plot the new cursor position
Set_Cur_Pos_Exit:
	Ret

;
;Get the current row and column of the graphics cursor
;

Get_Cursor_Pos:
	Mov	BX,Column	;Column in BX
	Mov	CX,Row		;Row in CX
	Inc	BX		;Adjust row & column values
	Inc	CX		; .. (Row = 1-25, Column = 1-40)
	Mov	SS:[0F8H],BX
	Mov	SS:[0FCH],CX
	Ret

;
;Print a text string on the graphics screen
;

Print_String:
	Cmp	CX,0		;Check for null string
	Ja	Print_String1	; ..
	Jmp	Print_String_Exit
Print_String1:
	Push	DS		;Save DS
	Push	BX		;Save action indicator
	Mov	AH,14		;BIOS write TTY function
	Mov	BX,T_Color	;Text color in BX
	Mov	DS,CS:Save_DS	;Get segment address of string
	Mov	SI,DX		;String offset address in SI
Print_String2:
	Mov	AL,[SI]		;Character to print in AL
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
	Inc	SI		;Point to next character in string
	Loop	Print_String2	;Print next character
Print_String3:
	Pop	BX		;Restore action indicator
	Cmp	BX,0		;Check to skip final CR & LF sequence
	Je	Print_String4
	Mov	AH,14		;BIOS write TTY function
	Mov	AL,13		;Print a final carriage return & linefeed
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
	Mov	AL,10		;Print a final carriage return & linefeed
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
Print_String4:
	Pop	DS		;Restore DS
	Mov	BX,Row		;Erase old cursor
	Mov	CX,Column	; ..
	Call	Plot_Cursor2	;  ..
	Mov	AH,3		;BIOS get cursor position function
	Mov	BX,0		;Page must be 0 for graphics mode
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
	Xor	BX,BX		;Clear BX & CX for call to 'Plot_Cursor'
	Xor	CX,CX		; ..
	Mov	BL,DL		;Column in BX
	Mov	CL,DH		;Row in CX
	Call	Plot_Cursor	;Move cursor to new position
Print_String_Exit:
	Ret

;
;Animate an object onto the screen using 'Put' with the Xor option
;

Animate:
	Push	CX		;Save used registers
	Push	DX		; ..
	Push	SI		;  ..
	Push	DI		;   ..
	Mov	BX,5		;Use Xor option
	Call	Put		;Put object onto the screen
	Pop	DI		;Restore used registers
	Pop	SI		; ..
	Pop	DX		;  ..
	Pop	CX		;   ..
Animate2:
	Loop	Animate2	;Delay awhile
	Mov	BX,5		;Use Xor option
	Call	Put		;Erase the image from the screen
	Ret

;
;Plot the graphics cursor onto the screen.
;

Plot_Cursor:
	Test	Cursor_Flag,1	;See if cursor is off
	Jz	Plot_Cursor2
	Push	BX		;Save row & column
	Push	CX		; ..
	Mov	CS:Save_DS,CS	;Set data segment to our program for 'Put'
	Mov	SI,Column	;Get old X ordinate value (SI * 8)
	Shl	SI,1		; ..
	Shl	SI,1		;  ..
	Shl	SI,1		;   ..
	Mov	DI,Row		;Get old Y ordinate value (DI * 8)
	Shl	DI,1		; ..
	Shl	DI,1		;  ..
	Shl	DI,1		;   ..
	Lea	DX,Cursor	;Point to graphics cursor array
	Mov	BX,5		;Xor the cursor onto the screen
	Or	Cursor_Flag,4	;Indicate to 'Put' we are plotting cursor
	Call	Put		;Plot it
	Pop	CX		;Restore row & column
	Pop	BX
Plot_Cursor2:			;Entered here for initial plot or erase
	Mov	Column,BX	;Update new row & column values
	Mov	Row,CX		; ..
	Test	Cursor_Flag,1	;See if cursor is off
	Jz	Plot_Cursor_Exit
	Mov	CS:Save_DS,CS	;Set data segment to our program for 'Put'
	Mov	SI,BX		;Get new X ordinate value (SI * 8)
	Shl	SI,1		; ..
	Shl	SI,1		;  ..
	Shl	SI,1		;   ..
	Mov	DI,CX		;Get new Y ordinate value (DI * 8)
	Shl	DI,1		; ..
	Shl	DI,1		;  ..
	Shl	DI,1		;   ..
	Lea	DX,Cursor	;Point to graphics cursor array
	Mov	BX,5		;Xor the cursor onto the screen
	Or	Cursor_Flag,4	;Indicate to 'Put' we are plotting cursor
	Call	Put		;Plot it
Plot_Cursor_Exit:
	And	Cursor_Flag,0FFFBH ;Reset 'Put' indicator
	Ret

;
;Return residency or graphics status - Set graphics and audio system
;

System:
	Cmp	BX,0		;Status check?
	Jne	System1		;No
	Mov	AX,0DEADH	;Indicate this program is resident
	Mov	SS:[00FEH],AX	; ..
	Jmp	System_Exit
System1:
	Cmp	BX,1		;Return graphics status?
	Jne	System2		;No
	Mov	AX,Graph_Flag
	Mov	SS:[00FEH],AX
	Jmp	System_Exit
System2:
	Cmp	BX,2		;Enable graphics functions?
	Jne	System3		;No
	Mov	AX,0009H	;Enter 320 x 200 x 16 color graphics mode
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
	Mov	Graph_Flag,1	;Enable graphics functions
	Mov	Cursor_Flag,0	;Reset graphic variables
	Mov	CursorRows,8	; ..
	Mov	B_Color,0	;  ..
	Mov	D_Color,1	;   ..
	Mov	T_Color,15	;    ..
	Mov	Old_X,0		;     ..
	Mov	Old_Y,0		;      ..
	Mov	Row,0		;	..
	Mov	Column,0	;	 ..
	Mov	X_Aspect,6	;	  ..
	Mov	Y_Aspect,5	;	   ..
	Jmp	System_Exit
System3:
	Cmp	BX,3		;Disable graphics functions?
	Jne	System4		;No
	Mov	Graph_Flag,0	;Disable graphics functions
	Mov	AX,0003H	;Reset video mode to 80 x 25 color
	PushF			;Fake an INT 10H interrupt
	Call	DWord Ptr CS:[Old10Int]
	Jmp	System_Exit
System4:
	Cmp	BX,4		;Turn all current sound processing off?
	Jne	System5		;No
	Call	Sound_Off	;Reset sound system
	Jmp	System_Exit
System5:
	Cmp	BX,5		;Turn sound buffering on?
	Jne	System7
	Test	Buf_Flag,1	;See if buffering is already on
	Jnz	System6		;Yes, don't reset
	Or	Buf_Flag,1	;Turn all sound buffer processing on
	Call	Reset_Sound_Buf ;Reset sound buffer variables
System6:
	Jmp	System_Exit
System7:
	Cmp	BX,6		;Turn sound buffering off?
	Jne	System9		;No
	Test	Buf_Flag,1	;See if buffering is already off
	Jz	System8		;Yes, don't reset
	And	Buf_Flag,0FFFEH ;Turn all sound buffer processing off
System8:
	Jmp	System_Exit
System9:
	Cmp	BX,7		;Turn all noise processing off?
	Jne	System10	;No
	Call	Noise_Off	;Reset noise system
	Jmp	System_Exit
System10:
	Cmp	BX,8		;Turn noise buffering on?
	Jne	System12	;No
	Test	Buf_Flag,2	;See if buffering is already on
	Jnz	System11	;Yes, don't reset
	Or	Buf_Flag,2	;Turn all noise buffer processing on
	Call	Reset_Noise_Buf ;Reset noise buffer variables
System11:
	Jmp	System_Exit
System12:
	Cmp	BX,9		;Turn noise buffering off?
	Jne	System14	;No
	Test	Buf_Flag,2	;See if buffering is already off
	Jz	System13	;Yes, don't reset
	And	Buf_Flag,0FFFDH ;Turn all noise buffer processing off
System13:
	Jmp	System_Exit
System14:
	Cmp	BX,10		;Turn all sound & noise processing off?
	Jne	System_Exit	;No
	Call	Sound_Off	;Reset sound system
	Call	Noise_Off	;Reset noise system
System_Exit:
	Ret

;
;Turns all current sound processing off
;

Sound_Off:
	And	Timer_Flag,16	;Reset timer flag
	And	Buf_Flag,0FFFEH ;Turn all sound buffer processing off
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
	And	Timer_Flag,0FFEFH ;Reset timer flag
	And	Buf_Flag,0FFFDH ;Turn all noise buffer processing off
	Mov	AL,0FFH		;Turn noise channel off
	Out	0C0H,AL		; ..
	Call	Reset_Noise_Buf ;Reset noise buffer
	Ret

;
;Reset all sound buffer variables
;

Reset_Sound_Buf:
	Mov	Buf_Cnt1,0	;Reset all counters
	Mov	Buf_Cnt2,0	; ..
	Mov	Buf_Cnt3,0	;  ..
	Lea	BP,Sound_Buf1	;Reset all pointers
	Mov	GBuf_Ptr1,BP	; ..
	Mov	PBuf_Ptr1,BP	;  ..
	Lea	BP,CS:Sound_Buf2 ;   ..
	Mov	GBuf_Ptr2,BP	;    ..
	Mov	PBuf_Ptr2,BP	;     ..
	Lea	BP,Sound_Buf3	;      ..
	Mov	GBuf_Ptr3,BP	;	..
	Mov	PBuf_Ptr3,BP	;	 ..
	Ret

;
;Reset all noise buffer variables
;

Reset_Noise_Buf:
	Mov	Buf_Cnt4,0	;Reset counter
	Lea	BP,Noise_Buf	;Reset all pointers
	Mov	GBuf_Ptr4,BP	; ..
	Mov	PBuf_Ptr4,BP	;  ..
	Ret

;
;Produce a sound with the specified freqency, duration, volume, and voice
;

Sound:
	Pusha			;Save registers
	Call	Make_Sound	;Produce the desired sound
	Popa			;Restore registers
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
	Test	CS:Timer_Flag,1 ;Check if current sound still active
	Jz	Make_Sound3	;No
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Make_Sound2	;No, wait for current sound to finish
	Call	Put_Sound1	;Yes, add the sound to the buffer
	Ret
Make_Sound2:			;No, wait for current sound to finish
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:Sound0_Cnt ;See if time has expired
	Cmp	AX,CS:Sound0_Ticks
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound2	;Keep looping until it's free
Make_Sound3:
	Mov	CS:Sound0_Ticks,DI ;Set number of ticks for channel 0
	Mov	CS:Sound0_Cnt,0 ;Reset counter
	Or	CS:Timer_Flag,1 ;Turn channel 0 flag bit on
	Jmp	Short Make_Sound10
Make_Sound4:
	Cmp	CL,1		;Check for sound channel 1
	Jne	Make_Sound7
	Test	CS:Timer_Flag,2 ;Check if current sound still active
	Jz	Make_Sound6	;No
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Make_Sound5	;No, wait for current sound to finish
	Call	Put_Sound2	;Yes, add the sound to the buffer
	Ret
Make_Sound5:
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:Sound1_Cnt ;See if time has expired
	Cmp	AX,CS:Sound1_Ticks
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound5	;Keep looping until it's free
Make_Sound6:
	Mov	CS:Sound1_Ticks,DI ;Set number of ticks for channel 1
	Mov	CS:Sound1_Cnt,0 ;Reset counter
	Or	CS:Timer_Flag,2 ;Turn channel 1 flag bit on
	Jmp	Short Make_Sound10
Make_Sound7:
	Test	CS:Timer_Flag,4 ;Check if current sound still active
	Jz	Make_Sound9	;No
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Make_Sound8	;No, wait for current sound to finish
	Call	Put_Sound3	;Yes, add the sound to the buffer
	Ret
Make_Sound8:
	Cli			;Disable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:Sound2_Cnt ;See if time has expired
	Cmp	AX,CS:Sound2_Ticks
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Sound8	;Keep looping until it's free
Make_Sound9:
	Mov	CS:Sound2_Ticks,DI ;Set number of ticks for channel 2
	Mov	CS:Sound2_Cnt,0 ;Reset counter
	Or	CS:Timer_Flag,4 ;Turn channel 2 flag bit on
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
	Pusha			;Save registers
	Call	Make_Noise	;Make the noise
	Popa			;Restore registers
	Ret

Make_Noise:
	Cmp	DX,0		;Check for zero length noise
	Ja	Make_Noise_OK	;Duration is OK, go on with making noise
	Ret			;Duration is zero, don't make the noise
Make_Noise_OK:
	Test	CS:Timer_Flag,8 ;See if current noise still active
	Jz	Make_Noise3	;No
Make_Noise1:
	Test	CS:Buf_Flag,2	;See if buffering active
	Jz	Make_Noise2	;No, wait for current noise to finished
	Call	Put_Noise	;Yes, put noise into sound buffer
	Ret
Make_Noise2:
	Cli			;Diable interrupts
	Push	AX		;Save AX
	Mov	AX,CS:Noise_Cnt ;See if time has expired
	Cmp	AX,CS:Noise_Ticks
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Make_Noise2	;Keep looping until it's free
Make_Noise3:
	Mov	CS:Noise_Ticks,DX ;Set duration
	Mov	CS:Noise_Cnt,0	;Reset clock tick counter
	Or	CS:Timer_Flag,8 ;Enable noise flag bit
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
	Cmp	CS:Buf_Cnt1,Buf_Num ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound1A	;Yes, loop until there's an openning
	Mov	BP,CS:PBuf_Ptr1 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End1
	Jne	Put_Sound1B	;No
	Lea	BP,CS:Sound_Buf1 ;Yes, point to beginning of buffer
Put_Sound1B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:PBuf_Ptr1,BP ;Save current buffer pointer
	Inc	CS:Buf_Cnt1	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 2
Put_Sound2:
	Push	BP		;Save BP
Put_Sound2A:
	Cli			;Clear interrupts
	Cmp	CS:Buf_Cnt2,Buf_Num ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound2A	;Yes, loop until there's an openning
	Mov	BP,CS:PBuf_Ptr2 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End2
	Jne	Put_Sound2B	;No
	Lea	BP,CS:Sound_Buf2 ;Yes, point to beginning of buffer
Put_Sound2B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:PBuf_Ptr2,BP ;Save current buffer pointer
	Inc	CS:Buf_Cnt2	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 3
Put_Sound3:
	Push	BP		;Save BP
Put_Sound3A:
	Cli			;Clear interrupts
	Cmp	CS:Buf_Cnt3,Buf_Num ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Sound3A	;Yes, loop until there's an openning
	Mov	BP,CS:PBuf_Ptr3 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End3
	Jne	Put_Sound3B	;No
	Lea	BP,CS:Sound_Buf3 ;Yes, point to beginning of buffer
Put_Sound3B:
	Mov	CS:[BP],BX	;Store the volume
	Mov	CS:[BP+2],CX	;Store the voice
	Mov	CS:[BP+4],SI	;Store the frequency
	Mov	CS:[BP+6],DI	;Store the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:PBuf_Ptr3,BP ;Save current buffer pointer
	Inc	CS:Buf_Cnt3	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;
;Put the current noise into the noise buffer
;

Put_Noise:
	Push	BP		;Save BP
Put_Noise1:
	Cli			;Clear interrupts
	Cmp	CS:Buf_Cnt4,Buf_Num ;See if buffer is full
	Sti			;Re-enable interrupts
	Je	Put_Noise1	;Yes, loop until there's an openning
	Mov	BP,CS:PBuf_Ptr4 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End4
	Jne	Put_Noise2	;No
	Lea	BP,CS:Noise_Buf ;Yes, point to beginning of buffer
Put_Noise2:
	Mov	CS:[BP],BX	;Store the type
	Mov	CS:[BP+2],CX	;Store the volume
	Mov	CS:[BP+4],DX	;Store the duration
	Add	BP,6		;Increment buffer pointer
	Mov	CS:PBuf_Ptr4,BP ;Save current buffer pointer
	Inc	CS:Buf_Cnt4	;Add to current sound total
	Pop	BP		;Restore BP
	Ret

;Sound buffer number 1
Get_Sound1:
	Cmp	CS:Buf_Cnt1,0	;See if buffer is empty
	Je	Get_Sound1_Exit
	Pusha			;Save registers
	Mov	BP,CS:GBuf_Ptr1 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End1
	Jne	Get_Sound1A	;No
	Lea	BP,CS:Sound_Buf1 ;Yes, point to beginning of buffer
Get_Sound1A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:GBuf_Ptr1,BP ;Save current buffer pointer
	Dec	CS:Buf_Cnt1	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popa			;Restore registers
Get_Sound1_Exit:
	Ret

;Sound buffer number 2
Get_Sound2:
	Cmp	CS:Buf_Cnt2,0	;See if buffer is empty
	Je	Get_Sound2_Exit
	Pusha			;Save registers
	Mov	BP,CS:GBuf_Ptr2 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End2
	Jne	Get_Sound2A	;No
	Lea	BP,CS:Sound_Buf2 ;Yes, point to beginning of buffer
Get_Sound2A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:GBuf_Ptr2,BP ;Save current buffer pointer
	Dec	CS:Buf_Cnt2	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popa			;Restore registers
Get_Sound2_Exit:
	Ret

;Sound buffer number 3
Get_Sound3:
	Cmp	CS:Buf_Cnt3,0	;See if buffer is empty
	Je	Get_Sound3_Exit ;No
	Pusha			;Save registers
	Mov	BP,CS:GBuf_Ptr3 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End3
	Jne	Get_Sound3A	;No
	Lea	BP,CS:Sound_Buf3 ;Yes, point to beginning of buffer
Get_Sound3A:
	Mov	BX,CS:[BP]	;Get the volume
	Mov	CX,CS:[BP+2]	;Get the voice
	Mov	SI,CS:[BP+4]	;Get the frequency
	Mov	DI,CS:[BP+6]	;Get the duration
	Add	BP,8		;Increment buffer pointer
	Mov	CS:GBuf_Ptr3,BP ;Save current buffer pointer
	Dec	CS:Buf_Cnt3	;Subtract from current sound total
	Call	Make_Sound	;Play the sound
	Popa			;Restore registers
Get_Sound3_Exit:
	Ret

;
;Get the current noise from the noise buffer and generate it
;

Get_Noise:
	Cmp	CS:Buf_Cnt4,0	;See if buffer is empty
	Je	Get_Noise_Exit	;No
	Pusha			;Save registers
	Mov	BP,CS:GBuf_Ptr4 ;See if at end of buffer
	Cmp	BP,Offset CS:Buf_End4
	Jne	Get_Noise1	;No
	Lea	BP,CS:Noise_Buf ;Yes, point to beginning of buffer
Get_Noise1:
	Mov	BX,CS:[BP]	;Get the type
	Mov	CX,CS:[BP+2]	;Get the volume
	Mov	DX,CS:[BP+4]	;Get the duration
	Add	BP,6		;Increment buffer pointer
	Mov	CS:GBuf_Ptr4,BP ;Save current buffer pointer
	Dec	CS:Buf_Cnt4	;Subtract from current sound total
	Call	Make_Noise	;Make the noise
	Popa			;Restore registers
Get_Noise_Exit:
	Ret

;
;Delay for the specified number of clock ticks
;

Delay:
	Or	CS:Timer_Flag,16 ;Turn delay flag bit on
	Mov	CS:Delay_Ticks,BX ;Set number of ticks for delay
	Mov	CS:Delay_Cnt,0	;Reset counter
Delay1:
	Cli			;Clear interrupts
	Push	AX		;Save AX
	Mov	AX,CS:Delay_Cnt ;See if time has expired
	Cmp	AX,CS:Delay_Ticks
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jb	Delay1		;Keep looping until time is up
	And	CS:Timer_Flag,0FFEFH ;Set delay flag bit off
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
	Test	CS:Timer_Flag,1 ;Check for sound channel 0
	Jz	Timer2
	Inc	CS:Sound0_Cnt	;Add another clock tick
	Mov	AX,CS:Sound0_Cnt ;See if time has expired
	Cmp	AX,CS:Sound0_Ticks
	Jb	Timer2		;No
	And	CS:Timer_Flag,0FFFEH ;Turn channel 0 flag bit off
	Mov	AX,0083H	;Turn sound channel 0 off
	Out	0C0H,AX		; ..
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Timer2		;No, check next sound channel
	Call	Get_Sound1	;Yes, get next sound to play from the buffer
Timer2:
	Test	CS:Timer_Flag,2 ;Check for sound channel 1
	Jz	Timer3
	Inc	CS:Sound1_Cnt	;Add another clock tick
	Mov	AX,CS:Sound1_Cnt ;See if time has expired
	Cmp	AX,CS:Sound1_Ticks
	Jb	Timer3		;No
	And	CS:Timer_Flag,0FFFDH ;Turn channel 1 flag bit off
	Mov	AX,00A3H	;Turn sound channel 1 off
	Out	0C0H,AX		; ..
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Timer3		;No, check next sound channel
	Call	Get_Sound2	;Yes, get next sound to play from the buffer
Timer3:
	Test	CS:Timer_Flag,4 ;Check for sound channel 2
	Jz	Timer4
	Inc	CS:Sound2_Cnt	;Add another clock tick
	Mov	AX,CS:Sound2_Cnt ;See if time has expired
	Cmp	AX,CS:Sound2_Ticks
	Jb	Timer4		;No
	And	CS:Timer_Flag,0FFFBH ;Turn channel 2 flag bit off
	Mov	AX,00C3H	;Turn sound channel 2 off
	Out	0C0H,AX		; ..
	Test	CS:Buf_Flag,1	;See if sound buffer is active
	Jz	Timer4		;No, check noise channel
	Call	Get_Sound3	;Yes, get next sound to play from the buffer
Timer4:
	Test	CS:Timer_Flag,8 ;Check for noise channel
	Jz	Timer5
	Inc	CS:Noise_Cnt	;Add another clock tick
	Mov	AX,CS:Noise_Cnt ;See if time has expired
	Cmp	AX,CS:Noise_Ticks
	Jb	Timer5		;No
	And	CS:Timer_Flag,0FFF7H ;Turn noise flag bit off
	Mov	AL,0FFH		;Turn noise off
	Out	0C0H,AL		; ..
	Test	CS:Buf_Flag,2	;See if noise buffer is active
	Jz	Timer5		;No, check for delay
	Call	Get_Noise	;Yes, get next noise to make from the buffer
Timer5:
	Test	CS:Timer_Flag,16 ;Check for delay
	Jz	Timer_Exit
	Inc	CS:Delay_Cnt	;Add another clock tick
Timer_Exit:
	Pop	AX		;Restore AX
	Sti			;Re-enable interrupts
	Jmp	DWord Ptr CS:[Old1CInt] ;Execute normal clock tick interrupt

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
	Lea	DX,Installed_Error
	Mov	AH,9
	Int	21H
	Mov	AH,4CH		;Exit with child return code non-zero
	Mov	AL,1
	Int	21H

Not_Already_Installed:
	Mov	AH,9
	Lea	DX,Installed_Message
	Int	21H

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
	Mov	AH,9		;Yes
	Lea	DX,Mem_Not_Protected
	Int	21H
	Jmp	Skip_Protect_Mem

Protect_Mem:
	Push	DS
	Mov	AX,DS		;Get current PSP address
	Dec	AX		;PSP Addr - 1 = Memory Block Header
	Mov	DS,AX
	Mov	AX,DS:[3]
	Sub	AX,16384/16	;Decrease paragraph count by 16K
	Mov	DS:[3],AX
	Mov	AX,40H
	Mov	DS,AX
	Mov	AX,DS:[15H]	;Get memory size in K
	Sub	AX,16		;Decrease memory size 16K
	Mov	DS:[15H],AX
	Pop	DS
	Mov	AH,49H		;Deallocate Environment Block
	Mov	DX,002CH
	Mov	ES,DX
	Int	21H
	Mov	AH,9
	Lea	DX,Mem_Protected
	Int	21H

Skip_Protect_Mem:
	Mov	AH,35H		;Get vector address for INT 10H
	Mov	AL,10H
	Int	21H
	Mov	Word Ptr Old10Int+2,ES ;Save vector address
	Mov	Word Ptr Old10Int,BX
	Mov	AH,35H		;Get vector address for INT 1CH
	Mov	AL,1CH
	Int	21H
	Mov	Word Ptr Old1CInt+2,ES ;Save vector address
	Mov	Word Ptr Old1CInt,BX
	Mov	AH,25H		;Change Video BIOS vector to new address
	Mov	AL,10H
	Lea	DX,NewInt10
	Int	21H
	Mov	AH,25H		;Change clock tick vector to new address
	Mov	AL,1CH
	Lea	DX,Timer
	Int	21H
	Lea	DX,Setup	;Setup paragraph count for terminate
	Mov	CL,4
	Shr	DX,CL
	Inc	DX
	Mov	AH,31H
	Mov	AL,0
	Int	21H

Installed_Message:
	DB	13,10,'GRAFIX 1.00'
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
	DB	13,10,'GRAFIX 1.00 is already installed!',7,13,10,'$'

Code	Ends

	End	Grafix
