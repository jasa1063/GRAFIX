 '******************************************************************************
 '* WORMY - Author Unknown                                                     *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 CALL SetCursor(1, 18)
 CALL PrintString("WORMY")
 FOR X = .1 TO 1.1 STEP .002
   K$ = INKEY$
   IF K$ = CHR$(27) THEN
     CALL ExitGraphics
     END
   END IF
   C = C + .1
   CALL ExtCircleC((X * 200), (SIN(X * 24) * (X * 50) + 100), (X * 40), (C))
   C = -C * (C < 15)
 NEXT X
 CALL WaitKey
 CALL ExitGraphics

