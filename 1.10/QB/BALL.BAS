 '******************************************************************************
 '* Bouncing Ball Program - Modified version of an IBM PC demo program         *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-Z
 DIM Ball(115), B(280)

 FOR X = 20 TO 280 STEP 4
   B(X) = 159 - CINT(ABS(SIN(X * .07853981#) * X) \ 2)
 NEXT X

 CALL SetBackColor(White)
 CALL ExtCircle(160, 100, 10)
 CALL ExtPaint(160, 100, Blue, Blue)
 CALL ExtGet(150, 90, 170, 110, Ball())
 CALL ClearScreen

 CALL DrawBox(19, 0, 302, 180, Brown)
 CALL DrawBox(20, 1, 301, 179, Brown)
 CALL FillBox(160, 2, 190, 178, LtBlue)
 CALL FillBox(191, 2, 222, 178, LtRed)
 CALL FillBox(223, 2, 253, 178, Yellow)

 PLAY "MFl32T067;P16"
 L = 6
 X2 = 20
 Y2 = 150
 CALL ExtPut(X2, Y2, Ball(), PutXor)

DO
 FOR D = 0 TO 1
   S = 20 + D * 260
   E = 280 - D * 260
   FOR X = S TO E STEP 4 - 8 * D
     Y = B(X)
     N = (170 - Y2) \ 5
     CALL ExtPut(X2, Y2, Ball(), PutXor)
     CALL ExtPut(X, Y, Ball(), PutXor)
     PLAY "L=" + VARPTR$(L) + "T255;N=" + VARPTR$(N)
     X2 = X
     Y2 = Y
     K$ = INKEY$
     IF K$ = CHR$(27) THEN
       CALL ExitGraphics
       END
     END IF
   NEXT X
   L = L + 3
   IF L > 21 THEN L = 6
 NEXT D
LOOP

