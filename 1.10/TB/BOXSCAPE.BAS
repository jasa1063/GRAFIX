 '******************************************************************************
 '* BOXSCAPE - Graphic demo of modern computer art - Burt Bursky               *
 '*                                                                            *
 '* Modified for TURBO BASIC with GRAFIX driver                                *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to pause program                                                  *
 '* Press F2 to restart program                                                *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 $INCLUDE "GRAFIX.BAS"

 Call EnableGraphics

 DEFINT A-Z

Again:
 RANDOMIZE TIMER
 CALL ClearScreen

 DO
   X = INT(RND * 15 + 3)
   Y = INT(RND * 15 + 3)
   FOR A = 1 TO 5
     X1 = 0
     X2 = 319
     Y1 = 0
     Y2 = 199
     B = INT(RND * 15 + 1)
     WHILE B = BoxColor
       B = INT(RND * 15 + 1)
     WEND
     BoxColor = B
     IF A = 5 THEN BoxColor = 0
     DO WHILE  X1 < 319 AND Y1 < 199
       K$ = INKEY$
       K$ = RIGHT$(K$, 1)
       IF K$ = CHR$(27) THEN
         CALL ExitGraphics
         END
       END IF
       IF K$ = CHR$(59) THEN
         CALL WaitKey
         CALL ClearKey
       END IF
       IF K$ = CHR$(60) THEN GOTO Again
       CALL DrawBox(X1, Y1, X2, Y2, BoxColor)
       X1 = X1 + Y
       Y1 = Y1 + X
       X2 = X2 - Y
       Y2 = Y2 - X
     LOOP
     CALL Pause(5)
   NEXT A
 LOOP

