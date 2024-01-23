'*******************************************************************************
'* This file contains the necessary interfacing SUB programs for GRAFIX the    *
'* Tandy 1000 graphics and sound extensions.  You can either MERGE it into     *
'* your current program or compile it to a Quick Library.  The Quick Library   *
'* option is the best route to go.  Each SUB program contains a description of *
'* it's use and examples of how to call it.  This file also contains all the   *
'* necessary DECLARE SUB statements if you decide to use the MERGE option.  If *
'* you decide to compile it to a Quick Library then use the file GRAFIX.DEF    *
'* which only contains the DECLARE SUB statements and defined constants that   *
'* are described as follows:                                                   *
'*                                                                             *
'* Here are a set of color constants to make the use of color names easier:    *
'*                                                                             *
'*   Black%, Blue%, Green%, Cyan%, Red%, Magenta%, Brown%, White%, Gray%,      *
'*   LtBlue%, LtGreen%, LtCyan%, LtRed%, LtMagenta%, Yellow%, & LtWhite%       *
'*                                                                             *
'* Finally is a set of constants for the 'ExtPut' function to correspond with  *
'* the action requested:                                                       *
'*                                                                             *
'*   PutPreset%, PutPset%, PutAnd%, PutOr%, & PutXor%                          *
'*                                                                             *
'* NOTE:  This file is for use with Microsoft QuickBASIC 4.0 or later only!!!  *
'*******************************************************************************

DECLARE SUB Animate (X%, Y%, Image%(), Duration%)
DECLARE SUB AudioOff ()
DECLARE SUB ClearKey ()
DECLARE SUB ClearScreen ()
DECLARE SUB ColorOff ()
DECLARE SUB ColorOn ()
DECLARE SUB CurrentPoint (X%, Y%)
DECLARE SUB CursorOn ()
DECLARE SUB CursorOff ()
DECLARE SUB CursorStatus (Status%, HalfStatus%)
DECLARE SUB DrawBox (X1%, Y1%, X2%, Y2%, BoxColor%)
DECLARE SUB DrawBoxC (X1%, Y1%, X2%, Y2%)
DECLARE SUB EnableGraphics ()
DECLARE SUB ExitGraphics ()
DECLARE SUB ExtCircle (X%, Y%, Radius%)
DECLARE SUB ExtCircleC (X%, Y%, Radius%, CircleColor%)
DECLARE SUB ExtGet (X1%, Y1%, X2%, Y2%, Image%())
DECLARE SUB ExtLine (X1%, Y1%, X2%, Y2%)
DECLARE SUB ExtLineC (X1%, Y1%, X2%, Y2%, LineColor%)
DECLARE SUB ExtPaint (X%, Y%, FillColor%, BoundryColor%)
DECLARE SUB ExtPut (X%, Y%, Image%(), Action%)
DECLARE SUB ExtSound (Frequency%, Duration%, Volume%, Voice%)
DECLARE SUB GraphStatus (Status%)
DECLARE SUB FillBox (X1%, Y1%, X2%, Y2%, BoxColor%)
DECLARE SUB FillBoxC (X1%, Y1%, X2%, Y2%)
DECLARE SUB GetAspect (X%, Y%)
DECLARE SUB GetBackColor (BackColor%)
DECLARE SUB GetCursor (Row%, Column%)
DECLARE SUB GetInput (Prompt$, GraphicInput$)
DECLARE SUB GetPlotColor (PlotColor%)
DECLARE SUB GetTextColor (TextColor%)
DECLARE SUB HalfCursor ()
DECLARE SUB LineRel (X%, Y%)
DECLARE SUB LineRelC (X%, Y%, LineColor%)
DECLARE SUB LineTo (X%, Y%)
DECLARE SUB LineToC (X%, Y%, LineColor%)
DECLARE SUB MoveRel (X%, Y%)
DECLARE SUB MoveTo (X%, Y%)
DECLARE SUB Noise (Source%, Volume%, Duration%)
DECLARE SUB NoiseBufOff ()
DECLARE SUB NoiseBufOn ()
DECLARE SUB NoiseOff ()
DECLARE SUB NormalCursor ()
DECLARE SUB PaletteUsing (Array%(), Index%)
DECLARE SUB Pause (Duration%)
DECLARE SUB PlotPoint (X%, Y%)
DECLARE SUB PlotPointC (X%, Y%, PixelColor%)
DECLARE SUB PointColor (X%, Y%, PixelColor%)
DECLARE SUB PrintString (GS$)
DECLARE SUB PrintStringX (GS$)
DECLARE SUB ResetPalette ()
DECLARE SUB SetAspect (XAspect%, YAspect%)
DECLARE SUB SetBackColor (BackColor%)
DECLARE SUB SetCursor (Row%, Column%)
DECLARE SUB SetCursorOff ()
DECLARE SUB SetCursorOn ()
DECLARE SUB SetPalette (OldColor%, NewColor%)
DECLARE SUB SetPlotColor (PlotColor%)
DECLARE SUB SetTextColor (TextColor%)
DECLARE SUB SoundBufOff ()
DECLARE SUB SoundBufOn ()
DECLARE SUB SoundOff ()
DECLARE SUB SpeakerOff ()
DECLARE SUB SpeakerOn ()
DECLARE SUB WaitKey ()

DIM SHARED InRegs%(9), OutRegs%(9)

CONST AX% = 0
CONST BX% = 1
CONST CX% = 2
CONST DX% = 3
CONST SI% = 4
CONST DI% = 5
CONST DS% = 6
CONST ES% = 7

CONST Black% = 0
CONST Blue% = 1
CONST Green% = 2
CONST Cyan% = 3
CONST Red% = 4
CONST Magenta% = 5
CONST Brown% = 6
CONST White% = 7
CONST Gray% = 8
CONST LtBlue% = 9
CONST LtGreen% = 10
CONST LtCyan% = 11
CONST LtRed% = 12
CONST LtMagenta% = 13
CONST Yellow% = 14
CONST LtWhite% = 15

CONST PutPreset% = 1
CONST PutPset% = 2
CONST PutAnd% = 3
CONST PutOr% = 4
CONST PutXor% = 5

SUB Animate (X%, Y%, Image%(), Duration%)
  InRegs%(AX%) = &HEE1C
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(CX%) = Duration%
  InRegs%(DX%) = VARPTR(Image%(0))
  InRegs%(DS%) = VARSEG(Image%(0))
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB AudioOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 10
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ClearKey
  WHILE INKEY$ <> ""
  WEND
END SUB

SUB ClearScreen
  InRegs%(AX%) = &HEE00
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ColorOff
  InRegs%(AX%) = &HEE01
  InRegs%(BX%) = 0
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ColorOn
  InRegs%(AX%) = &HEE01
  InRegs%(BX%) = 1
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB CurrentPoint (X%, Y%)
  InRegs%(AX%) = &HEE0A
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  X% = OutRegs%(BX%)
  Y% = OutRegs%(CX%)
END SUB

SUB CursorOff
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 0
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB CursorOn
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 1
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB CursorStatus (Status%, SizeStatus%)
  InRegs%(AX%) = &HEE18
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  Status% = OutRegs%(BX%)
  SizeStatus% = OutRegs%(CX%)
END SUB

SUB DrawBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  InRegs%(AX%) = &HEE0E
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = BoxColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB DrawBoxC (X1%, Y1%, X2%, Y2%)
  InRegs%(AX%) = &HEE22
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB EnableGraphics
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 0
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  IF OutRegs%(AX%) <> &HDEAD THEN
    SCREEN 0, 0, 0
    WIDTH 80
    COLOR 7, 0, 0
    CLS
    PRINT "GRAFIX Driver Not Loaded"
    PRINT
    PRINT "Press Any Key To Continue"
    CALL WaitKey
    END
  END IF
  SCREEN 0, 0, 0
  WIDTH 80
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 2
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExitGraphics
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 3
  CALL Int10A(SEG InRegs%(0))
  SCREEN 0, 0, 0
  WIDTH 80
END SUB

SUB ExtCircle (X%, Y%, Radius%)
  InRegs%(AX%) = &HEE0F
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = Radius%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtCircleC (X%, Y%, Radius%, CircleColor%)
  InRegs%(AX%) = &HEE21
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = Radius%
  InRegs%(DX%) = CircleColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtGet (X1%, Y1%, X2%, Y2%, Image%())
  ArraySize% = UBOUND(Image%, 1) - LBOUND(Image%, 1) + 1
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
  InRegs%(AX%) = &HEE15
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = VARPTR(Image%(0))
  InRegs%(DS%) = VARSEG(Image%(0))
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtLine (X1%, Y1%, X2%, Y2%)
  InRegs%(AX%) = &HEE0B
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtLineC (X1%, Y1%, X2%, Y2%, LineColor%)
  InRegs%(AX%) = &HEE1E
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = LineColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtPaint (X%, Y%, FillColor%, BoundryColor%)
  InRegs%(AX%) = &HEE10
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = FillColor%
  InRegs%(CX%) = BoundryColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtPut (X%, Y%, Image%(), Action%)
  InRegs%(AX%) = &HEE16
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = Action%
  InRegs%(DX%) = VARPTR(Image%(0))
  InRegs%(DS%) = VARSEG(Image%(0))
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ExtSound (Frequency%, Duration%, Volume%, Voice%)
  InRegs%(AX%) = &HEE81
  InRegs%(BX%) = Volume%
  InRegs%(CX%) = Voice%
  InRegs%(SI%) = Frequency%
  InRegs%(DI%) = Duration%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB FillBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  InRegs%(AX%) = &HEE11
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = BoxColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB FillBoxC (X1%, Y1%, X2%, Y2%)
  InRegs%(AX%) = &HEE23
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB GetAspect (X%, Y%)
  InRegs%(AX%) = &HEE05
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  X% = OutRegs%(BX%)
  Y% = OutRegs%(CX%)
END SUB

SUB GetBackColor (BackColor%)
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 3
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  BackColor% = OutRegs%(CX%)
END SUB

SUB GetCursor (Row%, Column%)
  InRegs%(AX%) = &HEE1A
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  Row% = OutRegs%(CX%)
  Column% = OutRegs%(BX%)
END SUB

SUB GetInput (Prompt$, GS$)
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
          EXIT DO
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
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 1
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  PlotColor% = OutRegs%(CX%)
END SUB

SUB GetTextColor (TextColor%)
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 2
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  TextColor% = OutRegs%(CX%)
END SUB

SUB GraphStatus (Status%)
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 1
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  Status% = OutRegs%(AX%)
END SUB

SUB HalfCursor
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 3
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB LineRel (X%, Y%)
  InRegs%(AX%) = &HEE0D
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB LineRelC (X%, Y%, LineColor%)
  InRegs%(AX%) = &HEE20
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(DX%) = LineColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB LineTo (X%, Y%)
   InRegs%(AX%) = &HEE0C
   InRegs%(SI%) = X%
   InRegs%(DI%) = Y%
   CALL Int10A(SEG InRegs%(0))
END SUB

SUB LineToC (X%, Y%, LineColor%)
   InRegs%(AX%) = &HEE1F
   InRegs%(SI%) = X%
   InRegs%(DI%) = Y%
   InRegs%(DX%) = LineColor%
   CALL Int10A(SEG InRegs%(0))
END SUB

SUB MoveRel (X%, Y%)
  InRegs%(AX%) = &HEE09
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB MoveTo (X%, Y%)
  InRegs%(AX%) = &HEE08
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB Noise (Source%, Volume%, Duration%)
  InRegs%(AX%) = &HEE82
  InRegs%(BX%) = Source%
  InRegs%(CX%) = Volume%
  InRegs%(DX%) = Duration%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB NoiseBufOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 9
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB NoiseBufOn
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 8
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB NoiseOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 7
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB NormalCursor
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 2
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB PaletteUsing (Array%(), Index%)
  IF Index% > (UBOUND(Array%, 1) - 15 + 1) THEN EXIT SUB
  InRegs%(AX%) = &HEE13
  InRegs%(DX%) = VARPTR(Array%(Index%))
  InRegs%(DS%) = VARSEG(Array%(0))
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB Pause (Duration%)
  InRegs%(AX%) = &HEE83
  InRegs%(BX%) = Duration%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB PlotPoint (X%, Y%)
  InRegs%(AX%) = &HEE06
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB PlotPointC (X%, Y%, PixelColor%)
  InRegs%(AX%) = &HEE1D
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(DX%) = PixelColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB PointColor (X%, Y%, PixelColor%)
  InRegs%(AX%) = &HEE07
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10B(SEG InRegs%(0), SEG OutRegs%(0))
  PixelColor% = OutRegs%(AX%)
END SUB

SUB PrintString (GS$)
  InRegs%(AX%) = &HEE1B
  InRegs%(BX%) = 1
  InRegs%(CX%) = LEN(GS$)
  InRegs%(DX%) = SADD(GS$)
  InRegs%(DS%) = VARSEG(GS$)
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB PrintStringX (GS$)
  InRegs%(AX%) = &HEE1B
  InRegs%(BX%) = 0
  InRegs%(CX%) = LEN(GS$)
  InRegs%(DX%) = SADD(GS$)
  InRegs%(DS%) = VARSEG(GS$)
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB ResetPalette
  InRegs%(AX%) = &HEE14
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetAspect (XAspect%, YAspect%)
  InRegs%(AX%) = &HEE04
  InRegs%(BX%) = XAspect%
  InRegs%(CX%) = YAspect%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetBackColor (BackColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 3
  InRegs%(CX%) = BackColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetCursor (Row%, Column%)
  InRegs%(AX%) = &HEE19
  InRegs%(BX%) = Column%
  InRegs%(CX%) = Row%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetPalette (OldColor%, NewColor%)
  InRegs%(AX%) = &HEE12
  InRegs%(BX%) = OldColor%
  InRegs%(CX%) = NewColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetPlotColor (PlotColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 1
  InRegs%(CX%) = PlotColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SetTextColor (TextColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 2
  InRegs%(CX%) = TextColor%
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SoundBufOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 6
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SoundBufOn
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 5
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SoundOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 4
  CALL Int10A(SEG InRegs%(0))
END SUB

SUB SpeakerOff
  InRegs%(0) = &H8002
  CALL Int86XOld(&H1A, InRegs%(), OutRegs%())
END SUB

SUB SpeakerOn
  OUT &HC0, &H9F
  OUT &HC0, &HBF
  OUT &HC0, &HDF
  InRegs%(0) = &H8003
  CALL Int86XOld(&H1A, InRegs%(), OutRegs%())
END SUB

SUB WaitKey
  CALL ClearKey
  WHILE INKEY$ = ""
  WEND
END SUB

