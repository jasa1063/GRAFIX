 '******************************************************************************
 '* WORMY - Author Unknown                                                     *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON

 CALL SetCursor(1, 18)
 CALL PrintString("WORMY")
 FOR X = .1 TO 1.1 STEP .002
   C = C + .1
   CALL SetPlotColor((C))
   CALL ExtCircle((X * 200), (SIN(X * 24) * (X * 50) + 100), (X * 40))
   C = -C * (C < 15)
 NEXT X
 CALL WaitKey

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END

