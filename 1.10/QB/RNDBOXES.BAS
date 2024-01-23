 '******************************************************************************
 '* RANDOM BOXES - Taken from the August, 1988 issue of PCM magazine           *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to clear screen                                                   *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-Z
 DEF FNRND (Max) = INT(RND * Max) + 1

 CONST MXSize = 90
 CONST MYSize = 70
 CONST MaxX = 319 - MXSize
 CONST MaxY = 199 - MYSize
 CONST MaxColor = 15

 RANDOMIZE TIMER
 DO
   K$ = INKEY$
   K$ = RIGHT$(K$, 1)
   IF K$ = CHR$(27) THEN
     CALL ExitGraphics
     END
   END IF
   IF K$ = CHR$(59) THEN CALL ClearScreen
   X = FNRND(MaxX)
   Y = FNRND(MaxY)
   XSize = FNRND(MXSize)
   YSize = FNRND(MYSize)
   BoxColor = FNRND(MaxColor)
   CALL FillBox(X, Y, X + XSize, Y + YSize, BoxColor)
 LOOP

