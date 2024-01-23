 '******************************************************************************
 '* BUTTERFY CONES - Burt Bursky                                               *
 '*                                                                            *
 '* Modified For QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-O, Q-Z
 DIM Image(205)
 DEF SEG = VARSEG(Image(0))
 BLOAD "BUTTER.BIN", VARPTR(Image(0))
 DEF SEG

 PI = 3.14159
 X = 159
 Y = 99
 R1 = 120
 R2 = 30
 Y1 = 40
 Y2 = 145

 DO
   FOR P = PI TO 3 * PI STEP PI / 32
     SX = X - R1 * COS(P)
     SY = Y1 - R2 * SIN(P)
     CX = R1 * COS(P) + X
     CY = R2 * SIN(P) + Y2
     CO = P MOD 15
     CALL ExtLineC(SX, SY, CX, CY, CO)
     CALL ExtPut(OLDX, OLDY, Image(), PutXor)
     CALL ExtPut(SX, SY, Image(), PutXor)
     OLDX = SX
     OLDY = SY
     CALL ExtPut(OLDX2, OLDY2, Image(), PutXor)
     CALL ExtPut(CX, CY, Image(), PutXor)
     OLDX2 = CX
     OLDY2 = CY
     K$ = INKEY$
     IF K$ = CHR$(27) THEN
       CALL ExitGraphics
       END
     END IF
   NEXT P
 LOOP

