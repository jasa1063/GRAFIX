'*******************************************************************************
'* This file contains the necessary interfacing SUB programs for GRAFIX the    *
'* Tandy 1000 graphics and sound extensions.  You $INCLUDE it into your        *
'* current program.  Each SUB program contains a description of it's use and   *
'* examples of how to call it.                                                 *
'*                                                                             *
'* Here are a set of color constants to make the use of color names easier:    *
'*                                                                             *
'*   %Black, %Blue, %Green, %Cyan, %Red, %Magenta, %Brown, %White, %Gray,      *
'*   %LtBlue, %LtGreen, %LtCyan, %LtRed, %LtMagenta, %Yellow, & %LtWhite       *
'*                                                                             *
'* Finally is a set of constants for the 'ExtPut' function to correspond with  *
'* the action requested:                                                       *
'*                                                                             *
'*   %PutPreset, %PutPset, %PutAnd, %PutOr, & %PutXor                          *
'*                                                                             *
'* NOTE:  This file is for use with Borland's TURBO BASIC only!!!              *
'*******************************************************************************

DIM InRegs%(6), OutRegs%(6)

%AX = 0
%BX = 1
%CX = 2
%DX = 3
%SI = 4
%DI = 5
%DS = 6

%Black = 0
%Blue = 1
%Green = 2
%Cyan = 3
%Red = 4
%Magenta = 5
%Brown = 6
%White = 7
%Gray = 8
%LtBlue = 9
%LtGreen = 10
%LtCyan = 11
%LtRed = 12
%LtMagenta = 13
%Yellow = 14
%LtWhite = 15

%PutPreset = 1
%PutPset = 2
%PutAnd = 3
%PutOr = 4
%PutXor = 5

SUB Int10A INLINE
  $INLINE "INT10A.BIN"
END SUB

SUB Int10B INLINE
  $INLINE "INT10B.BIN"
END SUB

SUB Animate (X%, Y%, Image%(1), Duration%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE1C
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%CX) = Duration%
  InRegs%(%DX) = VARPTR(Image%(0))
  InRegs%(%DS) = VARSEG(Image%(0))
  CALL Int10A(InRegs%(0))
END SUB

SUB AudioOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 10
  CALL Int10A(InRegs%(0))
END SUB

SUB ClearKey
  WHILE INKEY$ <> ""
  WEND
END SUB

SUB ClearScreen
  SHARED InRegs%()
  InRegs%(%AX) = &HEE00
  CALL Int10A(InRegs%(0))
END SUB

SUB ColorOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE01
  InRegs%(%BX) = 0
  CALL Int10A(InRegs%(0))
END SUB

SUB ColorOn
  SHARED InRegs%()
  InRegs%(%AX) = &HEE01
  InRegs%(%BX) = 1
  CALL Int10A(InRegs%(0))
END SUB

SUB CurrentPoint (X%, Y%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE0A
  CALL Int10B(InRegs%(0), OutRegs%(0))
  X% = OutRegs%(%BX)
  Y% = OutRegs%(%CX)
END SUB

SUB CursorOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE17
  InRegs%(%BX) = 0
  CALL Int10A(InRegs%(0))
END SUB

SUB CursorOn
  SHARED InRegs%()
  InRegs%(%AX) = &HEE17
  InRegs%(%BX) = 1
  CALL Int10A(InRegs%(0))
END SUB

SUB CursorStatus (Status%, SizeStatus%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE18
  CALL Int10B(InRegs%(0), OutRegs%(0))
  Status% = OutRegs%(%BX)
  SizeStatus% = OutRegs%(%CX)
END SUB

SUB DrawBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE0E
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  InRegs%(%DX) = BoxColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB DrawBoxC (X1%, Y1%, X2%, Y2%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE22
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  CALL Int10A(InRegs%(0))
END SUB

SUB EnableGraphics
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 0
  CALL Int10B(InRegs%(0), OutRegs%(0))
  IF OutRegs%(%AX) <> &HDEAD THEN
    SCREEN 0, 0, 0
    COLOR 7, 0, 0
    WIDTH 80
    CLS
    PRINT "GRAFIX Driver Not Loaded"
    CALL WaitKey
    END
  END IF
  SCREEN 0, 0, 0
  WIDTH 80
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 2
  CALL Int10A(InRegs%(0))
END SUB

SUB ExitGraphics
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 3
  CALL Int10A(InRegs%(0))
  SCREEN 0, 0, 0
  WIDTH 80
END SUB

SUB ExtCircle (X%, Y%, Radius%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE0F
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%BX) = Radius%
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtCircleC (X%, Y%, Radius%, CircleColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE21
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%BX) = Radius%
  InRegs%(%DX) = CircleColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtGet (X1%, Y1%, X2%, Y2%, Image%(1))
  SHARED InRegs%()
  ArraySize% = UBOUND(Image%(1)) - LBOUND(Image%(1)) + 1
  W% = X2% - X1% + 1
  H% = Y2% - Y1% + 1
  ImageSize% = (H% * W% / 4) + 6
  IF ArraySize% < ImageSize% THEN
    SCREEN 0, 0, 0
    WIDTH 80
    COLOR 7, 0, 0
    CLS
    PRINT "Array size too small"
    PRINT
    PRINT "Press Any Key To Continue"
    CALL WaitKey
    END
  END IF
  InRegs%(%AX) = &HEE15
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  InRegs%(%DX) = VARPTR(Image%(0))
  InRegs%(%DS) = VARSEG(Image%(0))
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtLine (X1%, Y1%, X2%, Y2%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE0B
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtLineC (X1%, Y1%, X2%, Y2%, LineColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE1E
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  InRegs%(%DX) = LineColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtPaint (X%, Y%, FillColor%, BoundryColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE10
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%BX) = FillColor%
  InRegs%(%CX) = BoundryColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtPut (X%, Y%, Image%(1), Action%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE16
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%BX) = Action%
  InRegs%(%DX) = VARPTR(Image%(0))
  InRegs%(%DS) = VARSEG(Image%(0))
  CALL Int10A(InRegs%(0))
END SUB

SUB ExtSound (Frequency%, Duration%, Volume%, Voice%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE81
  InRegs%(%BX) = Volume%
  InRegs%(%CX) = Voice%
  InRegs%(%SI) = Frequency%
  InRegs%(%DI) = Duration%
  CALL Int10A(InRegs%(0))
END SUB

SUB FillBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE11
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  InRegs%(%DX) = BoxColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB FillBoxC (X1%, Y1%, X2%, Y2%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE23
  InRegs%(%BX) = X1%
  InRegs%(%CX) = Y1%
  InRegs%(%SI) = X2%
  InRegs%(%DI) = Y2%
  CALL Int10A(InRegs%(0))
END SUB

SUB GetAspect (X%, Y%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE05
  CALL Int10B(InRegs%(0), OutRegs%(0))
  X% = OutRegs%(%BX)
  Y% = OutRegs%(%CX)
END SUB

SUB GetBackColor (BackColor%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE03
  InRegs%(%BX) = 3
  CALL Int10B(InRegs%(0), OutRegs%(0))
  BackColor% = OutRegs%(%CX)
END SUB

SUB GetCursor (Row%, Column%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE1A
  CALL Int10B(InRegs%(0), OutRegs%(0))
  Row% = OutRegs%(%CX)
  Column% = OutRegs%(%BX)
END SUB

SUB GetInput (Prompt$, GS$)
  SHARED InRegs%()
  CALL CursorStatus(SaveCursor%, SaveSize%)
  CALL CursorOn
  CALL NormalCursor
  CALL PrintStringX(Prompt$)
  CALL GetCursor(R%, StartCol%)
  P% = 1
  Max% = 40 - StartCol% + 1
  Insert% = 0
  Temp$ = SPACE$(Max%)
  WHILE INKEY$ <> ""
  WEND
  DO
    K$ = ""
    WHILE K$ = ""
      K$ = INKEY$
    WEND
    K% = ASC(RIGHT$(K$, 1))
    WhatToDo% = 0
    IF LEN(K$) = 1 THEN
      SELECT CASE K%
        CASE 8  'Back Space
          P% = P% - 1
          IF P% < 1 THEN P% = 1
          Temp$ = LEFT$(Temp$, P% - 1) + RIGHT$(Temp$, LEN(Temp$) - P%) + " "
          WhatToDo% = 2
        CASE 13  'Enter
          EXIT LOOP
        CASE 27  'Escape
          Temp$ = SPACE$(Max%)
          P% = 1
          WhatToDo% = 2
        CASE 32 TO 126  'ASC 32 - 126
          IF Insert% = 0 THEN
            MID$(Temp$, P%, 1) = K$
            WhatToDo% = 1
            P% = P% + 1
            IF P% > Max% THEN
              P% = 1
              WhatToDo% = 2
            END IF
          END IF
          IF Insert% = 1 THEN
            Temp$ = LEFT$(Temp$, P% - 1) + K$ + MID$(Temp$, P%, LEN(Temp$) - P%)
            P% = P% + 1
            IF P% > Max% THEN P% = 1
            WhatToDo% = 2
          END IF
        CASE ELSE
      END SELECT
    END IF
    IF LEN(K$) = 2 THEN
      SELECT CASE K%
        CASE 71  'Home
          P% = 1
        CASE 75  'Cursor Left
          P% = P% - 1
          IF P% < 1 THEN P% = 1
        CASE 77  'Cursor Right
          P% = P% + 1
          IF P% > Max% THEN P% = Max%
        CASE 79  'End
          FOR X% = Max% TO 1 STEP -1
            IF MID$(Temp$, X%, 1) <> " " THEN EXIT FOR
          NEXT X%
          P% = X% + 1
          IF P% = Max% + 1 THEN P% = Max%
        CASE 82  'Insert
          IF Insert% = 0 THEN
            Insert% = 1
            CALL HalfCursor
          ELSE
            Insert% = 0
            CALL NormalCursor
          END IF
        CASE 83  'Delete
          Temp$ = LEFT$(Temp$, P% - 1) + RIGHT$(Temp$, LEN(Temp$) - P%) + " "
          WhatToDo% = 2
        CASE ELSE
      END SELECT
    END IF
    SELECT CASE WhatToDo%
      CASE 0
        CALL SetCursor(R%, (StartCol% + P% - 1))
      CASE 1
        CALL SetCursor(R%, (StartCol% + P% - 2))
        CALL PrintStringX(K$)
        CALL SetCursor(R%, (StartCol% + P% - 1))
      CASE 2
        CALL SetCursor(R%, StartCol%)
        CALL PrintStringX(Temp$)
        CALL SetCursor(R%, (StartCol% + P% - 1))
    END SELECT
  LOOP
  FOR X% = Max% TO 1 STEP -1
    IF MID$(Temp$, X%, 1) <> " " THEN EXIT FOR
  NEXT X%
  GS$ = LEFT$(Temp$, X%)
  R% = R% + 1
  IF R% > 25 THEN R% = 1
  CALL SetCursor(R%, 1)
  IF SaveCursor% = 0 THEN CALL CursorOff
  IF SaveCursor% = 1 THEN CALL CursorOn
  IF SaveSize% = 0 THEN CALL NormalCursor
  IF SaveSize% = 1 THEN CALL HalfCursor
END SUB

SUB GetPlotColor (PlotColor%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE03
  InRegs%(%BX) = 1
  CALL Int10B(InRegs%(0), OutRegs%(0))
  PlotColor% = OutRegs%(%CX)
END SUB

SUB GetTextColor (TextColor%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE03
  InRegs%(%BX) = 2
  CALL Int10B(InRegs%(0), OutRegs%(0))
  TextColor% = OutRegs%(%CX)
END SUB

SUB GraphStatus (Status%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 1
  CALL Int10B(InRegs%(0), OutRegs%(0))
  Status% = OutRegs%(%AX)
END SUB

SUB HalfCursor
  SHARED InRegs%()
  InRegs%(%AX) = &HEE17
  InRegs%(%BX) = 3
  CALL Int10A(InRegs%(0))
END SUB

SUB LineRel (X%, Y%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE0D
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  CALL Int10A(InRegs%(0))
END SUB

SUB LineRelC (X%, Y%, LineColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE20
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%DX) = LineColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB LineTo (X%, Y%)
   SHARED InRegs%()
   InRegs%(%AX) = &HEE0C
   InRegs%(%SI) = X%
   InRegs%(%DI) = Y%
   CALL Int10A(InRegs%(0))
END SUB

SUB LineToC (X%, Y%, LineColor%)
   SHARED InRegs%()
   InRegs%(%AX) = &HEE1F
   InRegs%(%SI) = X%
   InRegs%(%DI) = Y%
   InRegs%(%DX) = LineColor%
   CALL Int10A(InRegs%(0))
END SUB

SUB MoveRel (X%, D%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE09
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  CALL Int10A(InRegs%(0))
END SUB

SUB MoveTo (X%, Y%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE08
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  CALL Int10A(InRegs%(0))
END SUB

SUB Noise (Source%, Volume%, Duration%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE82
  InRegs%(%BX) = Source%
  InRegs%(%CX) = Volume%
  InRegs%(%DX) = Duration%
  CALL Int10A(InRegs%(0))
END SUB

SUB NoiseBufOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 9
  CALL Int10A(InRegs%(0))
END SUB

SUB NoiseBufOn
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 8
  CALL Int10A(InRegs%(0))
END SUB

SUB NoiseOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 7
  CALL Int10A(InRegs%(0))
END SUB

SUB NormalCursor
  SHARED InRegs%()
  InRegs%(%AX) = &HEE17
  InRegs%(%BX) = 2
  CALL Int10A(InRegs%(0))
END SUB

SUB PaletteUsing (Array%(1), Index%)
  SHARED InRegs%()
  IF Index% > (UBOUND(Array%(1)) - 15 + 1) THEN EXIT SUB
  InRegs%(%AX) = &HEE13
  InRegs%(%DX) = VARPTR(Array%(Index%))
  InRegs%(%DS) = VARSEG(Array%(0))
  CALL Int10A(InRegs%(0))
END SUB

SUB Pause (Duration%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE83
  InRegs%(%BX) = Duration%
  CALL Int10A(InRegs%(0))
END SUB

SUB PlotPoint (X%, Y%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE06
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  CALL Int10A(InRegs%(0))
END SUB

SUB PlotPointC (X%, Y%, PixelColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE1D
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  InRegs%(%DX) = PixelColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB PointColor (X%, Y%, XYColor%)
  SHARED InRegs%(), OutRegs%()
  InRegs%(%AX) = &HEE07
  InRegs%(%SI) = X%
  InRegs%(%DI) = Y%
  CALL Int10B(InRegs%(0), OutRegs%(0))
  XYColor% = OutRegs%(%AX)
END SUB

SUB PrintString (GS$)
  SHARED InRegs%()
  LOCAL STRSEG%, OFFSET%
  DEF SEG
  STRSEG% = PEEK(1) * 256 + PEEK(0)
  DEF SEG = VARSEG(GS$)
  OFFSET% = (PEEK(VARPTR(GS$) + 3) * 256) + PEEK(VARPTR(GS$) + 2)
  DEF SEG
  InRegs%(%AX) = &HEE1B
  InRegs%(%BX) = 1
  InRegs%(%CX) = LEN(GS$)
  InRegs%(%DX) = OFFSET%
  InRegs%(%DS) = STRSEG%
  CALL Int10A(InRegs%(0))
END SUB

SUB PrintStringX (GS$)
  SHARED InRegs%()
  LOCAL STRSEG%, OFFSET%
  DEF SEG
  STRSEG% = PEEK(1) * 256 + PEEK(0)
  DEF SEG = VARSEG(GS$)
  OFFSET% = (PEEK(VARPTR(GS$) + 3) * 256) + PEEK(VARPTR(GS$) + 2)
  DEF SEG
  InRegs%(%AX) = &HEE1B
  InRegs%(%BX) = 0
  InRegs%(%CX) = LEN(GS$)
  InRegs%(%DX) = OFFSET%
  InRegs%(%DS) = STRSEG%
  CALL Int10A(InRegs%(0))
END SUB

SUB ResetPalette
  SHARED InRegs%()
  InRegs%(%AX) = &HEE14
  CALL Int10A(InRegs%(0))
END SUB

SUB SetAspect (XAspect%, YAspect%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE04
  InRegs%(%BX) = XAspect%
  InRegs%(%CX) = YAspect%
  CALL Int10A(InRegs%(0))
END SUB

SUB SetBackColor (BackColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE02
  InRegs%(%BX) = 3
  InRegs%(%CX) = BackColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB SetCursor (Row%, Column%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE19
  InRegs%(%BX) = Column%
  InRegs%(%CX) = Row%
  CALL Int10A(InRegs%(0))
END SUB

SUB SetPalette (OldColor%, NewColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE12
  InRegs%(%BX) = OldColor%
  InRegs%(%CX) = NewColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB SetPlotColor (PlotColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE02
  InRegs%(%BX) = 1
  InRegs%(%CX) = PlotColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB SetTextColor (TextColor%)
  SHARED InRegs%()
  InRegs%(%AX) = &HEE02
  InRegs%(%BX) = 2
  InRegs%(%CX) = TextColor%
  CALL Int10A(InRegs%(0))
END SUB

SUB SoundBufOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 6
  CALL Int10A(InRegs%(0))
END SUB

SUB SoundBufOn
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 5
  CALL Int10A(InRegs%(0))
END SUB

SUB SoundOff
  SHARED InRegs%()
  InRegs%(%AX) = &HEE80
  InRegs%(%BX) = 4
  CALL Int10A(InRegs%(0))
END SUB

SUB SpeakerOff
  Reg 1, &H8002
  CALL Interrupt &H1A
END SUB

SUB SpeakerOn
  OUT &HC0, &H9F
  OUT &HC0, &HBF
  OUT &HC0, &HDF
  Reg 1, &H8003
  CALL Interrupt &H1A
END SUB

SUB WaitKey
  CALL ClearKey
  WHILE INKEY$ = ""
  WEND
END SUB
