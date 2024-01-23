 '******************************************************************************
 '* WALKING LINES - Taken from the August, 1988 issue of PCM magazine          *
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
 RANDOMIZE TIMER

 DEFINT A-Z
 DEF FNRND (Max) = (RND * Max) + 1

 NLines = 150
 Delta1 = 31
 Delta2 = 16
 ChgCnt = 75

 DIM LineX1(NLines), LineY1(NLines), LineX2(NLines), LineY2(NLines)
 MaxX = 320
 MaxX1 = 319
 MaxY = 200
 MaxY1 = 199
 MaxColor = 16
 Tint = FNRND(MaxColor) - 1
 BackTint = 0

 CALL ClearScreen
 IX = 0
 Cnt = 0

 X1 = FNRND(MaxX) - 1
 Y1 = FNRND(MaxY) - 1
 X2 = FNRND(MaxX) - 1
 Y2 = FNRND(MaxY) - 1

 DX1 = FNRND(Delta1) - Delta2
 DY1 = FNRND(Delta1) - Delta2
 DX2 = FNRND(Delta1) - Delta2
 DY2 = FNRND(Delta1) - Delta2

 DO
   FOR ChangeCnt = 1 TO FNRND(ChgCnt)
     CALL SetPlotColor(Tint)
     CALL ExtLine(X1, Y1, X2, Y2)
     IX = (IX + 1) MOD NLines
     IF Cnt = NLines THEN
       CALL SetPlotColor(BackTint)
       CALL ExtLine(LineX1(IX), LineY1(IX), LineX2(IX), LineY2(IX))
     END IF

     LineX1(IX) = X1
     LineY1(IX) = Y1
     LineX2(IX) = X2
     LineY2(IX) = Y2

     IF Cnt < NLines THEN Cnt = Cnt + 1

     X1 = X1 + DX1
     IF (X1 < 0) OR (X1 > MaxX1) THEN
       DX1 = -DX1
       X1 = X1 + DX1
     END IF

     Y1 = Y1 + DY1
     IF (Y1 < 0) OR (Y1 > MaxY1) THEN
       DY1 = -DY1
       Y1 = Y1 + DY1
     END IF

     X2 = X2 + DX2
     IF (X2 < 0) OR (X2 > MaxX1) THEN
       DX2 = -DX2
       X2 = X2 + DX2
     END IF

     Y2 = Y2 + DY2
     IF (Y2 < 0) OR (Y2 > MaxY1) THEN
       DY2 = -DY2
       Y2 = Y2 + DY2
     END IF
   NEXT ChangeCnt

   DX1 = FNRND(Delta1) - Delta2
   DY1 = FNRND(Delta1) - Delta2
   DX2 = FNRND(Delta1) - Delta2
   DY2 = FNRND(Delta1) - Delta2

   Tint = FNRND(MaxColor) - 1
 LOOP

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END


