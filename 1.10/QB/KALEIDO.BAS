 '******************************************************************************
 '* KALEIDOSCOPE - Taken from the August, 1988 issue of PCM magazine           *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to pause program                                                  *
 '* Press F2 to clear the screen                                               *
 '* Press ESC to exit program                                                  *
 '* ****************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 CONST MX = 160
 CONST MY = 100
 CONST M = 100
 CONST MaxDelta = 7
 CONST MaxColor = 15

 DEFINT A-Z
 DEF FNRND (Max) = INT(RND * Max) + 1

 DO
   RANDOMIZE TIMER
   CALL ClearScreen
   X1 = FNRND(M) + 1
   X2 = FNRND(M) + 1
   Y1 = FNRND(X1)
   Y2 = FNRND(X2)
   DO
     LC = FNRND(MaxColor)      'Ensure good color seperation
     LC = FNRND(MaxColor)
     XV1 = FNRND(11) - 5
     XV2 = FNRND(11) - 5
     YV1 = FNRND(11) - 5
     YV2 = FNRND(11) - 5
     DO WHILE (FNRND(10) > 1)
       XA = (X1 * 9) \ MaxDelta
       XB = (X2 * 9) \ MaxDelta
       YA = (Y1 * 9) \ MaxDelta
       YB = (Y2 * 9) \ MaxDelta
       CALL MoveTo((MX + XA), (MY - Y1))
       CALL LineToC((MX + XB), (MY - Y2), LC)
       CALL MoveTo((MX - YA), (MY + X1))
       CALL LineToC((MX - YB), (MY + X2), LC)
       CALL MoveTo((MX - XA), (MY - Y1))
       CALL LineToC((MX - XB), (MY - Y2), LC)
       CALL MoveTo((MX - YA), (MY - X1))
       CALL LineToC((MX - YB), (MY - X2), LC)
       CALL MoveTo((MX - XA), (MY + Y1))
       CALL LineToC((MX - XB), (MY + Y2), LC)
       CALL MoveTo((MX + YA), (MY - X1))
       CALL LineToC((MX + YB), (MY - X2), LC)
       CALL MoveTo((MX + XA), (MY + Y1))
       CALL LineToC((MX + XB), (MY + Y2), LC)
       CALL MoveTo((MX + YA), (MY + X1))
       CALL LineToC((MX + YB), (MY + X2), LC)
       X1 = ABS((X1 + XV1) MOD M)
       Y1 = ABS((Y1 + YV1) MOD M)
       X2 = ABS((X2 + XV2) MOD M)
       Y2 = ABS((Y2 + YV2) MOD M)
     LOOP
     K$ = INKEY$
     K$ = RIGHT$(K$, 1)
     IF K$ = CHR$(27) THEN
       CALL ExitGraphics
       END
     END IF
     IF K$ = CHR$(59) THEN CALL WaitKey
     IF K$ = CHR$(60) THEN EXIT DO
   LOOP
 LOOP

