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

DECLARE SUB Animate (X%, Y%, Image%(), Delay%)
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
DECLARE SUB EnableGraphics ()
DECLARE SUB ExitGraphics ()
DECLARE SUB ExtCircle (X%, Y%, Radius%)
DECLARE SUB ExtGet (X1%, Y1%, X2%, Y2%, Image%())
DECLARE SUB ExtLine (X1%, Y1%, X2%, Y2%)
DECLARE SUB ExtPaint (X%, Y%, FillColor%, BoundryColor%)
DECLARE SUB ExtPut (X%, Y%, Image%(), Action%)
DECLARE SUB ExtSound (Frequency%, Duration%, Volume%, Voice%)
DECLARE SUB GraphStatus (Status%)
DECLARE SUB FillBox (X1%, Y1%, X2%, Y2%, BoxColor%)
DECLARE SUB GetAspect (X%, Y%)
DECLARE SUB GetBackColor (BackColor%)
DECLARE SUB GetCursor (Row%, Column%)
DECLARE SUB GetInput (Prompt$, GraphicInput$)
DECLARE SUB GetPlotColor (PlotColor%)
DECLARE SUB GetTextColor (TextColor%)
DECLARE SUB HalfCursor ()
DECLARE SUB LineRel (DX%, DY%)
DECLARE SUB LineTo (X%, Y%)
DECLARE SUB MoveRel (DX%, DY%)
DECLARE SUB MoveTo (X%, Y%)
DECLARE SUB Noise (Source%, Volume%, Duration%)
DECLARE SUB NoiseBufOff ()
DECLARE SUB NoiseBufOn ()
DECLARE SUB NoiseOff ()
DECLARE SUB NormalCursor ()
DECLARE SUB PaletteUsing (Array%(), Index%)
DECLARE SUB Pause (Duration%)
DECLARE SUB PlotPoint (X%, Y%)
DECLARE SUB PointColor (X%, Y%, XYColor%)
DECLARE SUB PrintString (GraphicString$)
DECLARE SUB PrintStringX (GraphicString$)
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

'
'*******************************************************************************
'* 'Animate' - Performs animation as explained in the 'ExtPut' function.  The  *
'*             image is automatically transferred to the screen, and then      *
'*             erased again.  You specify a delay amount 1 - 32767 which  help *
'*             reduce flickering.  The delay is the interval between the       *
'*             transfer and erase phase of the image.                          *
'*                                                                             *
'*             Example:                                                        *
'*                CALL Animate(X%, Y%, Image%(), 1000)                         *
'*******************************************************************************
'
SUB Animate(X%, Y%, Image%(), Delay%)
  InRegs%(AX%) = &HEE1C
  InRegs%(CX%) = Delay%
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(DS%) = VARSEG(Image%(0))
  InRegs%(DX%) = VARPTR(Image%(0))
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB


'
'*******************************************************************************
'* 'AudioOff' - Turns off all current sounds and noise off and disables sound  *
'*              and noise buffering.                                           *
'*                                                                             *
'*              Example:                                                       *
'*                 CALL AudioOff                                               *
'*******************************************************************************
'
SUB AudioOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 10
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ClearKey' - Clears the keyboard buffer.                                    *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL ClearKey                                            *
'*******************************************************************************
'
SUB ClearKey
  WHILE INKEY$ <> ""
  WEND
END SUB

'
'*******************************************************************************
'* 'ClearScreen' - Clears the graphics screen using the current background     *
'*                 color.                                                      *
'*                                                                             *
'*                 Example:                                                    *
'*                   CALL ClearScreen                                          *
'*******************************************************************************
'
SUB ClearScreen
  InRegs%(AX%) = &HEE00
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ColorOff' - Turns the color enable off for use with a monochrome composit  *
'*              monitor.                                                       *
'*                                                                             *
'*              Example:                                                       *
'*                CALL ColorOff                                                *
'*******************************************************************************
'
SUB ColorOff
  InRegs%(AX%) = &HEE01
  InRegs%(BX%) = 0
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ColorOn' - Turns the color enable on.  This is useful if you had turned it *
'*             off with the ColorOff statement.                                *
'*                                                                             *
'*             Example:                                                        *
'*               CALL ColorOn                                                  *
'*******************************************************************************
'
SUB ColorOn
  InRegs%(AX%) = &HEE01
  InRegs%(BX%) = 1
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'CurrentPoint' - Returns the current X,Y coordinates.                       *
'*                                                                             *
'*                  Examples:                                                  *
'*                    CALL CurrentPoint(X%, Y%)                                *
'*******************************************************************************
'
SUB CurrentPoint (X%, Y%)
  InRegs%(AX%) = &HEE0A
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  X% = OutRegs%(BX%)
  Y% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'CursorOff' - Sets the graphics cursor off making it invisible.             *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL CursorOff                                           *
'*******************************************************************************
'
SUB CursorOff
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 0
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'CursorOn' - Sets the graphics cursor on making it visible.                 *
'*                                                                             *
'*                 Example:                                                    *
'*                   CALL CursorOn                                             *
'*******************************************************************************
'
SUB CursorOn
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 1
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'CursorStatus' - Returns the current cursor status and size.                *
'*                  Status%:                                                   *
'*                           0 = Off                                           *
'*                           1 = On                                            *
'*                  SizeStatus%:                                               *
'*                           0 = Normal Size                                   *
'*                           1 = Half Size                                     *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL CursorStatus(Status%, SizeStatus%)                  *
'*******************************************************************************
'
SUB CursorStatus (Status%, SizeStatus%)
  InRegs%(AX%) = &HEE18
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  Status% = OutRegs%(BX%)
  SizeStatus% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'DrawBox' - Draws a line box from X1,Y1 to X2,Y2 using the specified color  *
'*             ignoring current drawing color.                                 *
'*                                                                             *
'*             Examples:                                                       *
'*               CALL DrawBox(0, 0, 50, 75, 1)                                 *
'*******************************************************************************
'
SUB DrawBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  InRegs%(AX%) = &HEE0E
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = BoxColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'EnableGraphics' - Enters the 320 X 200 X 16 color graphics screen mode.    *
'*                    Verifies the GRAFIX driver is loaded before attempting   *
'*                    to enter the graphics mode.                              *
'*                                                                             *
'*                    Example:                                                 *
'*                      CALL EnableGraphics                                    *
'*******************************************************************************
'
SUB EnableGraphics
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 0
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  IF OutRegs%(AX%) <> &HDEAD THEN
    SCREEN 0, 0, 0
    COLOR 7, 0, 0
    WIDTH 80
    CLS
    PRINT "GRAFIX Driver Not Loaded"
    END
  END IF
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 2
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExitGraphics' - Leaves the 320 X 200 X 16 color graphics screen mode and   *
'*                  enter the 80 X 25 color text screen mode.                  *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL ExitGraphics                                        *
'*******************************************************************************
'
SUB ExitGraphics
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 3
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtCircle' - Draws a circle at X,Y with the specified radius.  It uses the *
'*               current values of XAspect & YAspect which default to 6/5,     *
'*               unless set using 'SetAspect'.                                 *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL ExtCircle(160, 100, 75)                                *
'*******************************************************************************
'
SUB ExtCircle (X%, Y%, Radius%)
  InRegs%(AX%) = &HEE0F
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = Radius%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtGet' - Stores a graphics image from X1,Y1 to X2,Y2 into the specified   *
'*            array.  The array size can be calculated using the following     *
'*            formula:                                                         *
'*              2 + INT (H * W) / 4)) + ((H * W) MOD 4)                        *
'*                H - Number of pixels high                                    *
'*                W - Number of pixels wide                                    *
'*            The array MUST be an integer array for the 'ExtGet' function to  *
'*            work.                                                            *
'*                                                                             *
'*            Example:                                                         *
'*              ExtGet 0, 0, 50, 75, Array%()                                  *
'*******************************************************************************
'
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
    END
  END IF
  InRegs%(AX%) = &HEE15
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = VARPTR(Image%(0))
  InRegs%(DS%) = VARSEG(Image%(0))
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtLine' - Draws a line from X1,Y1 to X2,Y2 using the current drawing      *
'*             color.                                                          *
'*                                                                             *
'*             Example:                                                        *
'*               CALL ExtLine(10, 15, 100, 150)                                *
'*******************************************************************************
'
SUB ExtLine (X1%, Y1%, X2%, Y2%)
  InRegs%(AX%) = &HEE0B
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtPaint' - Fills an enclosed shape starting at X,Y with 'FillColor%'      *
'*              which is bounded by 'BoundryColor%'.                           *
'*                                                                             *
'*              Example:                                                       *
'*                CALL ExtPaint(100, 10, 5, 14)                                *
'*******************************************************************************
'
SUB ExtPaint (X%, Y%, FillColor%, BoundryColor%)
  InRegs%(AX%) = &HEE10
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = FillColor%
  InRegs%(CX%) = BoundryColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtPut' - Transfers a graphics image stored with 'ExtGet' starting at X,Y  *
'*            using the specified action.  Action is 1 of 5 options described  *
'*            as follows:                                                      *
'*              1 = Preset - Produces a numeric opposite of the color stored   *
'*                           in the array:                                     *
'*                                     Array Color   Screen Color              *
'*                                     -----------   ------------              *
'*                                         00             15                   *
'*                                         01             14                   *
'*                                         02             13                   *
'*                                         03             12                   *
'*                                         04             11                   *
'*                                         05             10                   *
'*                                         06             09                   *
'*                                         07             08                   *
'*                                         08             07                   *
'*                                         09             06                   *
'*                                         10             05                   *
'*                                         11             04                   *
'*                                         12             03                   *
'*                                         13             02                   *
'*                                         14             01                   *
'*                                         15             00                   *
'*                                                                             *
'*              2 = Pset - Transfers the image exactly as it was stored.       *
'*                                                                             *
'*              3 = And - Transfers the image over the existing image.         *
'*                                                                             *
'*              4 = Or - Superimposes the image onto the existing image.       *
'*                                                                             *
'*              5 = Xor - Inverts the points on the screen where a point       *
'*                        exists in the array image.  When PUT against a       *
'*                        background twice, the background is restored.  This  *
'*                        allows animation to take place.  To perform          *
'*                        animation do the following:                          *
'*                          1) PUT the object on the screen.                   *
'*                          2) Calculate the next X,Y position.                *
'*                          3) PUT the object at the previous X,Y position.    *
'*                          4) Repeat Step 1.                                  *
'*                                                                             *
'*            Example:                                                         *
'*              CALL ExtPut(10, 20, Array%(), 5)                               *
'*******************************************************************************
'
SUB ExtPut (X%, Y%, Image%(), Action%)
  InRegs%(AX%) = &HEE16
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  InRegs%(BX%) = Action%
  InRegs%(DX%) = VARPTR(Image%(0))
  InRegs%(DS%) = VARSEG(Image%(0))
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ExtSound' - Generates a sound with the specified frequency, duration,      *
'*              volume, and voice.                                             *
'*                                                                             *
'*              Frequency% is a number 110 - 32767:                            *
'*                This is the tone to produce in Hertz.  Certain frequencies   *
'*                correspond to musical notes for example the following chart  *
'*                starts at middle C:                                          *
'*                                                                             *
'*                  C -  523.25                                                *
'*                  D -  587.33                                                *
'*                  E -  659.26                                                *
'*                  F -  698.46                                                *
'*                  G -  783.99                                                *
'*                  A -  880.00                                                *
'*                  B -  987.77                                                *
'*                  C - 1045.50                                                *
'*                                                                             *
'*                To produce notes in the octave above middle C look up the    *
'*                note's frequency in the above chart and multiply it by 2.    *
'*                                                                             *
'*                To produce notes in the octave below middle C follow the     *
'*                same procedure only divide by 2 instead.                     *
'*                                                                             *
'*              Duration% is a number 0 - 32767:                               *
'*                This is the number of clock ticks the sound will last.       *
'*                Clock ticks occur 18.2 times a second, so a number of 18     *
'*                will make the sound last approximately 1 second.             *
'*                                                                             *
'*                There are 1092 clock ticks per minute.  To find the number   *
'*                of clock ticks for one beat, divide the beats per minute     *
'*                into 1092.  The following chart gives the number of clock    *
'*                ticks for some common tempos:                                *
'*                                                                             *
'*                                Beats Per       Ticks                        *
'*                  Tempo          Minute       Per Minute                     *
'*                  -----         --------      ----------                     *
'*                  Largo          40- 60       27.3 -18.2                     *
'*                  Larghetto      60- 66       18.2 -16.55                    *
'*                  Adagio         66- 70       16.55-14.37                    *
'*                  Andante        76-108       14.37-10.11                    *
'*                  Moderato      108-120       10.11- 9.1                     *
'*                  Allegro       120-168        9.1 - 6.5                     *
'*                  Presto        168-208        6.5 - 5.25                    *
'*                                                                             *
'*              Volume% is a number 0 - 15:                                    *
'*                0 is the quietest.                                           *
'*                15 is the loudest.                                           *
'*                                                                             *
'*              Voice% is a number 0 - 2:                                      *
'*                This is the sound channel to use when producing the sound.   *
'*                You can set each voice to a diffenent tone to make a 3-note  *
'*                chord.                                                       *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL ExtSound(880, 8, 7, 0)                                 *
'*******************************************************************************
'
SUB ExtSound (Frequency%, Duration%, Volume%, Voice%)
  InRegs%(AX%) = &HEE81
  InRegs%(BX%) = Volume%
  InRegs%(CX%) = Voice%
  InRegs%(SI%) = Frequency%
  InRegs%(DI%) = Duration%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'FillBox' - Draws a solid box from X1,Y1 to X2,Y2 using the specified       *
'*             color ignoring the current drawing color.                       *
'*                                                                             *
'*             Example:                                                        *
'*               CALL FillBox(0, 0, 100, 75, 1)                                *
'*******************************************************************************
'
SUB FillBox (X1%, Y1%, X2%, Y2%, BoxColor%)
  InRegs%(AX%) = &HEE11
  InRegs%(BX%) = X1%
  InRegs%(CX%) = Y1%
  InRegs%(SI%) = X2%
  InRegs%(DI%) = Y2%
  InRegs%(DX%) = BoxColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'GetAspect' - Returns the current XAspect & YAspect values.                 *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL GetAspect(X%, Y%)                                      *
'*******************************************************************************
'
SUB GetAspect (X%, Y%)
  InRegs%(AX%) = &HEE05
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  X% = OutRegs%(BX%)
  Y% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'GetBackColor' - Returns the current background color setting.              *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL GetBackColor(BackColor%)                            *
'*******************************************************************************
'
SUB GetBackColor (BackColor%)
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 3
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  BackColor% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'GetCursor' - Returns the current row and column.                           *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL GetCursor(Row%, Column%)                               *
'*******************************************************************************
'
SUB GetCursor (Row%, Column%)
  InRegs%(AX%) = &HEE1A
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  Row% = OutRegs%(CX%)
  Column% = OutRegs%(BX%)
END SUB

'
'*******************************************************************************
'* 'GetInput' - Allows input of string variables while in the 320 x 200 x 16   *
'*              color graphics mode.  It provides most of the editting         *
'*              capabilities of BASIC's INPUT function.  The keys that are     *
'*              listed show what editting functions are currently handled.  To *
'*              input a number use the VAL function after inputting the string *
'*              variable:                                                      *
'*                ExtInput "Enter Number ", Num$                               *
'*                Num# = VAL(Num$)                                             *
'*                                                                             *
'*              The following keys are trapped:                                *
'*                 Back Space                                                  *
'*                 Enter                                                       *
'*                 Esc                                                         *
'*                 ASCII Characters 32 - 126                                   *
'*                 Home                                                        *
'*                 Cursor Left                                                 *
'*                 Cursor Right                                                *
'*                 End                                                         *
'*                 Insert                                                      *
'*                 Delete                                                      *
'*                                                                             *
'*              Example:                                                       *
'*                CALL GetInput("Enter Your Name ", A$)                        *
'*******************************************************************************
'
SUB GetInput (Prompt$, GraphicInput$)
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
  GraphicInput$ = LEFT$(Temp$, X%)
  R% = R% + 1
  IF R% > 25 THEN R% = 1
  CALL SetCursor(R%, 1)
  IF SaveCursor% = 0 THEN CALL CursorOff
  IF SaveCursor% = 1 THEN CALL CursorOn
  IF SaveSize% = 0 THEN CALL NormalCursor
  IF SaveSize% = 1 THEN CALL HalfCursor
END SUB

'
'*******************************************************************************
'* 'GetPlotColor' - Returns the current drawing color.                         *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL GetPlotColor(PlotColor%)                            *
'*******************************************************************************
'
SUB GetPlotColor (PlotColor%)
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 1
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  PlotColor% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'GetTextColor' - Returns the current text color.                            *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL GetTextColor(TextColor%)                            *
'*******************************************************************************
'
SUB GetTextColor (TextColor%)
  InRegs%(AX%) = &HEE03
  InRegs%(BX%) = 2
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  TextColor% = OutRegs%(CX%)
END SUB

'
'*******************************************************************************
'* 'GraphStatus' - Returns the whether the graphics functions are enabled or   *
'*                 disabled.                                                   *
'*                                                                             *
'*                   0 = Disabled                                              *
'*                   1 = Enabled                                               *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL GraphStatus(Status%)                                   *
'*******************************************************************************
'
SUB GraphStatus (Status%)
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 1
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  Status% = OutRegs%(AX%)
END SUB

'
'*******************************************************************************
'* 'HalfCursor' - Sets the cursor to half size.                                *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL HalfCursor                                          *
'*******************************************************************************
'
SUB HalfCursor
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 3
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'LineRel' - Draws a line a relative distance from the current X,Y position. *
'*                                                                             *
'*             Examples:                                                       *
'*               CALL LineRel(10, 10)                                          *
'*               CALL LineRel(-10, -5)                                         *
'*******************************************************************************
'
SUB LineRel (DX%, DY%)
  InRegs%(AX%) = &HEE0D
  InRegs%(SI%) = DX%
  InRegs%(DI%) = DY%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'LineTo' - Draw a line to specified X,Y position from the current X,Y       *
'*            position.                                                        *
'*                                                                             *
'*            Example:                                                         *
'*              CALL LineTo(50, 75)                                            *
'*******************************************************************************
'
SUB LineTo (X%, Y%)
   InRegs%(AX%) = &HEE0C
   InRegs%(SI%) = X%
   InRegs%(DI%) = Y%
   CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'MoveRel' - Moves a relative distance from the current X,Y position without *
'*             plotting any points.                                            *
'*                                                                             *
'*             Examples:                                                       *
'*               CALL MoveRel(15, 20)                                          *
'*               CALL MoveRel(-10, -15)                                        *
'*******************************************************************************
'
SUB MoveRel (DX%, DY%)
  InRegs%(AX%) = &HEE09
  InRegs%(SI%) = DX%
  InRegs%(DI%) = DY%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'MoveTo' - Moves to the specified X,Y position from the current X,Y         *
'*            position without plotting any points.                            *
'*                                                                             *
'*            Example:                                                         *
'*              CALL MoveTo(0, 10)                                             *
'*******************************************************************************
'
SUB MoveTo (X%, Y%)
  InRegs%(AX%) = &HEE08
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'Noise' - Generates a periodic or white noise sound, with the indicated     *
'*           volume, for the specified length of time.                         *
'*                                                                             *
'*           Source is a number 0-7:                                           *
'*             0-3 are periodic noises.                                        *
'*             4-7 are white noises.                                           *
'*                                                                             *
'*           Volume is a number 0-15:                                          *
'*             0 is the quietest.                                              *
'*             15 is the loudest.                                              *
'*                                                                             *
'*           Duration is a number 0 to 32767:                                  *
'*             It indicates how many clock ticks the noise should last.  Clock *
'*             ticks occur 18.2 times a second, so a value of 18 would make    *
'*             the noise last about 1 second.                                  *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL Noise(4, 8, 12)                                     *
'*******************************************************************************
'
SUB Noise (Source%, Volume%, Duration%)
  InRegs%(AX%) = &HEE82
  InRegs%(BX%) = Source%
  InRegs%(CX%) = Volume%
  InRegs%(DX%) = Duration%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'NoiseBufOff' - Disables background processing of noises in the noise       *
'*                 buffer.                                                     *
'*                                                                             *
'*                 Example:                                                    *
'*                   CALL NoiseBufOff                                          *
'*******************************************************************************
'
SUB NoiseBufOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 9
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'NoiseBufOn' - Enables the 32 entry noise buffer for processing of noises   *
'*                in background.  Background processing is off by default.     *
'*                                                                             *
'*                Example:                                                     *
'*                  CALL NoiseBufOn                                            *
'*******************************************************************************
'
SUB NoiseBufOn
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 8
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'NoiseOff' - Turns off all current noises off and disables noise            *
'*              buffering.                                                     *
'*                                                                             *
'*              Example:                                                       *
'*                 CALL NoiseOff                                               *
'*******************************************************************************
'
SUB NoiseOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 7
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'NormalCursor' - Sets the cursor to normal size.                            *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL NormalCursor                                        *
'*******************************************************************************
'
SUB NormalCursor
  InRegs%(AX%) = &HEE17
  InRegs%(BX%) = 2
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'PaletteUsing' - Changes the color palette using 15 elements of an integer  *
'*                  array starting with the indicated index value.  Each array *
'*                  element holds the new color value for the corresponding    *
'*                  palette entry.                                             *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL PaletteUsing(Array%(), Index%)                      *
'*******************************************************************************
'
SUB PaletteUsing (Array%(), Index%)
  IF Index% > (UBOUND(Array%, 1) - 15 + 1) THEN EXIT SUB
  InRegs%(AX%) = &HEE13
  InRegs%(DX%) = VARPTR(Array%(Index%))
  InRegs%(DS%) = VARSEG(Array%(0))
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'Pause' - Delays a program for the specified number of clock ticks.  Clock  *
'*           ticks occur 18.2 times a second, so a number of 37 would delay    *
'*           a program approximately 2 seconds.  This function has the         *
'*           advantage being more precise than a high level language delay     *
'*           loop because it uses an assembly language interface.  Use it when *
'*           you need to delay for a precise number of clock ticks.            *
'*                                                                             *
'*           Example:                                                          *
'*             CALL Pause(20)                                                  *
'*******************************************************************************
'
SUB Pause (Duration%)
  InRegs%(AX%) = &HEE83
  InRegs%(BX%) = Duration%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'PlotPoint' - Plots a point at the specified X,Y position using the current *
'*               drawing color.                                                *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL PlotPoint(160, 100)                                    *
'*******************************************************************************
'
SUB PlotPoint (X%, Y%)
  InRegs%(AX%) = &HEE06
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'PointColor' - Returns the color for the point at the specified X,Y         *
'*                position.                                                    *
'*                                                                             *
'*                Example:                                                     *
'*                  CALL PointColor(100, 100, XYColor%)                        *
'*******************************************************************************
'
SUB PointColor (X%, Y%, XYColor%)
  InRegs%(AX%) = &HEE07
  InRegs%(SI%) = X%
  InRegs%(DI%) = Y%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
  XYColor% = OutRegs%(AX%)
END SUB

'
'*******************************************************************************
'* 'PrintString' - Prints a string and advances to the next line.  To print    *
'*                 several strings at the same time don't use a semicolon, use *
'*                 the '+' operator instead.  To print a number use the STR$   *
'*                 function.                                                   *
'*                                                                             *
'*                 Examples:                                                   *
'*                   CALL PrintString(GraphicString$)                          *
'*                   CALL PrintString("Press Any Key To Exit")                 *
'*                   CALL PrintString(A$ + "Hi There" + B$)                    *
'*                   CALL PrintString("Total =" + STR$(Total%))                *
'*******************************************************************************
'
SUB PrintString (GraphicString$)
  InRegs%(AX%) = &HEE1B
  InRegs%(BX%) = 1
  InRegs%(CX%) = LEN(GraphicString$)
  InRegs%(DX%) = SADD(GraphicString$)
  InRegs%(DS%) = VARSEG(GraphicString$)
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'PrintStringX' - Prints a string, but does not advance to the next line.    *
'*                  To print several strings at the same time don't use a      *
'*                  semicolon, use the '+' operator instead.  To print a       *
'*                  number use the STR$ function.                              *
'*                                                                             *
'*                 Examples:                                                   *
'*                   CALL PrintStringX(GraphicString$)                         *
'*                   CALL PrintStringX("Press Any Key To Exit")                *
'*                   CALL PrintStringX(A$ + "Hi There" + B$)                   *
'*                   CALL PrintStringX("Total =" + STR$(Total%))               *
'*******************************************************************************
'
SUB PrintStringX (GraphicString$)
  InRegs%(AX%) = &HEE1B
  InRegs%(BX%) = 0
  InRegs%(CX%) = LEN(GraphicString$)
  InRegs%(DX%) = SADD(GraphicString$)
  InRegs%(DS%) = VARSEG(GraphicString$)
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'ResetPalette' - Resets the color palette to the default state.             *
'*                  NOTE:  This functions reset the background & border colors *
'*                         to Black again.                                     *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL ResetPalette                                        *
'*******************************************************************************
'
SUB ResetPalette
  InRegs%(AX%) = &HEE14
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetAspect' - Sets the X & Y portions of the aspect ratio for drawing       *
'*               circles.                                                      *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL SetAspect(12, 5)                                       *
'*******************************************************************************
'
SUB SetAspect (XAspect%, YAspect%)
  InRegs%(AX%) = &HEE04
  InRegs%(BX%) = XAspect%
  InRegs%(CX%) = YAspect%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetBackColor' - Sets the current background color and border color.        *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL SetBackColor(7)                                     *
'*******************************************************************************
'
SUB SetBackColor (BackColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 3
  InRegs%(CX%) = BackColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetCursor' - Sets the current cursor position for printing text on the     *
'*               graphics screen.                                              *
'*                                                                             *
'*               NOTE:  Row must be 1-25 & Column must be 1-40.                *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL SetCursor(10, 1)                                       *
'*******************************************************************************
'
SUB SetCursor (Row%, Column%)
  InRegs%(AX%) = &HEE19
  InRegs%(BX%) = Column%
  InRegs%(CX%) = Row%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetPalette' - Allows you to redefine any one of the 16 colors.  This is    *
'*                done by specifying the color number to change followed by    *
'*                the color to replace it.                                     *
'*                                                                             *
'*                Example:                                                     *
'*                  CALL SetPalette(1, 10)                                     *
'*******************************************************************************
'
SUB SetPalette (OldColor%, NewColor%)
  InRegs%(AX%) = &HEE12
  InRegs%(BX%) = OldColor%
  InRegs%(CX%) = NewColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetPlotColor' - Sets the current drawing color.                            *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL SetPlotColor(5)                                     *
'*******************************************************************************
'
SUB SetPlotColor (PlotColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 1
  InRegs%(CX%) = PlotColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SetTextColor' - Sets the current text color used by 'PrintString'.         *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL SetTextColor(14)                                    *
'*******************************************************************************
'
SUB SetTextColor (TextColor%)
  InRegs%(AX%) = &HEE02
  InRegs%(BX%) = 2
  InRegs%(CX%) = TextColor%
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SoundBufOff' - Disables background processing of sounds in the sound       *
'*                 buffer.                                                     *
'*                                                                             *
'*                 Example:                                                    *
'*                   CALL SoundBufOff                                          *
'*******************************************************************************
'
SUB SoundBufOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 6
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SoundBufOn' - Enables the 32 entry sound buffer for processing of sounds   *
'*                in background.  Background processing is off by default.     *
'*                                                                             *
'*                Example:                                                     *
'*                  CALL SoundBufOn                                            *
'*******************************************************************************
'
SUB SoundBufOn
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 5
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SoundOff' - Turns off all current sounds off and disables sound            *
'*              buffering.                                                     *
'*                                                                             *
'*              Example:                                                       *
'*                 CALL SoundOff                                               *
'*******************************************************************************
'
SUB SoundOff
  InRegs%(AX%) = &HEE80
  InRegs%(BX%) = 4
  CALL Int10(SEG InRegs%(0), SEG OutRegs%(0))
END SUB

'
'*******************************************************************************
'* 'SpeakerOff' - Disables the sound to the exterior speaker.                  *
'*                                                                             *
'*                Example:                                                     *
'*                  CALL SpeakerOff                                            *
'*******************************************************************************
'
SUB SpeakerOff
  InRegs%(0) = &H8002
  CALL Int86XOld(&H1A, InRegs%(), OutRegs%())
END SUB

'
'*******************************************************************************
'* 'SpeakerOn' - Enables the sound to the exterior speaker.                    *
'*                                                                             *
'*               Example:                                                      *
'*                 CALL SpeakerOn                                              *
'*******************************************************************************
'
SUB SpeakerOn
  OUT &HC0, &H9F
  OUT &HC0, &HBF
  OUT &HC0, &HDF
  InRegs%(0) = &H8003
  CALL Int86XOld(&H1A, InRegs%(), OutRegs%())
END SUB

'
'*******************************************************************************
'* 'WaitKey' - Pauses the program and waits for a key to be pressed on the     *
'*             keyboard.                                                       *
'*                                                                             *
'*                  Example:                                                   *
'*                    CALL WaitKey                                             *
'*******************************************************************************
'
SUB WaitKey
  CALL ClearKey
  WHILE INKEY$ = ""
  WEND
END SUB

