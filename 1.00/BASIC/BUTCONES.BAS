 '******************************************************************************
 '* BUTTERFY CONE - Burt Bursky                                                *
 '*                                                                            *
 '* Modified For QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON

 DIM OBJECT%(205)
 DEF SEG = VARSEG(OBJECT%(0))
 OFFSET = VARPTR(OBJECT%(0))
 BLOAD "BUTTER.BIN", OFFSET
 DEF SEG

 PI = 3.14159
 P2 = PI * 2
 P3 = PI / 2
 X = 159
 Y = 99
 R1 = 120
 R2 = 30
 Y1 = 40
 Y2 = 145

 DO
   FOR I = PI TO 3 * PI STEP PI / 32
     PX = X - R1 * COS(I)
     PY = Y1 - R2 * SIN(I)
     CX = R1 * COS(I) + X
     CY = R2 * SIN(I) + Y2
     CO = I MOD 15
     CALL SetPlotColor((CO))
     CALL ExtLine((PX), (PY), (CX), (CY))
     CALL ExtPut((OLDX), (OLDY), OBJECT%(), PutXor%)
     CALL ExtPut((PX), (PY), OBJECT%(), PutXor%)
     OLDX = PX
     OLDY = PY
     CALL ExtPut((OLDX2), (OLDY2), OBJECT%(), PutXor%)
     CALL ExtPut((CX), (CY), OBJECT%(), PutXor%)
     OLDX2 = CX
     OLDY2 = CY
   NEXT I
 LOOP

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END

