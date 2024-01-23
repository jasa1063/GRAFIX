 '******************************************************************************
 '* BOXSCAPE - Graphic demo of modern computer art - Burt Bursky               *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 Call EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON

 DEFINT A-Z
 CALL PrintString("Number of Seconds to Run (Default=120)")
 GetInput "", SEC$
 CALL ClearScreen
 SEC = VAL(SEC$)
 IF SEC = 0 THEN SEC = 120
 ON TIMER(SEC) GOSUB EndProgram
 TIMER ON

MainLoop:
 FOR X = 3 TO 7
   FOR Y = 2 TO 6
     FOR Z = 4 TO 8
       A = 0
       B = 290
       C = 0
       D = 191
Again:
       CALL DrawBox(A, C, B, D, Z)
       A = A + Y
       B = B - Y
       C = C + X
       D = D - X
       IF A < 255 AND C < 191 THEN GOTO Again
     NEXT Z
   NEXT Y
 NEXT X
 GOTO MainLoop

EndProgram:
 ExitGraphics
 END

