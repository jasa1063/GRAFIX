 '******************************************************************************
 '* KALEIDOSCOPE - Taken from the August, 1988 issue of PCM magazine           *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '* Press F2 to pause program                                                  *
 '* ****************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON
 ON KEY(2) GOSUB Pause
 KEY(2) ON

 DEFINT A-Z
 DEF FNRND (Max) = INT(RND * Max) + 1

Again:
 CX = 160
 CY = 100
 M = 100
 MaxDelta = 7
 MaxColor = 15

 DO
   RANDOMIZE TIMER
   X1 = FNRND(M) + 1
   X2 = FNRND(M) + 1
   Y1 = FNRND(X1)
   Y2 = FNRND(X2)
   XV1 = FNRND(11) - 5
   XV2 = FNRND(11) - 5
   YV1 = FNRND(11) - 5
   YV2 = FNRND(11) - 5
   XA1 = X1
   XB1 = X2
   YA1 = Y1
   YB1 = Y2
   Cnt = 0
   Total = FNRND(25) + 35
   FOR Cnt = 1 TO Total
     CALL SetPlotColor(FNRND(MaxColor))
     XA = (X1 * 9) \ MaxDelta
     XB = (X2 * 9) \ MaxDelta
     YA = (Y1 * 9) \ MaxDelta
     YB = (Y2 * 9) \ MaxDelta
     CALL MoveTo((CX + XA), (CY - Y1))
     CALL LineTo((CX + XB), (CY - Y2))
     CALL MoveTo((CX - YA), (CY + X1))
     CALL LineTo((CX - YB), (CY + X2))
     CALL MoveTo((CX - XA), (CY - Y1))
     CALL LineTo((CX - XB), (CY - Y2))
     CALL MoveTo((CX - YA), (CY - X1))
     CALL LineTo((CX - YB), (CY - X2))
     CALL MoveTo((CX - XA), (CY + Y1))
     CALL LineTo((CX - XB), (CY + Y2))
     CALL MoveTo((CX + YA), (CY - X1))
     CALL LineTo((CX + YB), (CY - X2))
     CALL MoveTo((CX + XA), (CY + Y1))
     CALL LineTo((CX + XB), (CY + Y2))
     CALL MoveTo((CX + YA), (CY + X1))
     CALL LineTo((CX + YB), (CY + X2))
     X1 = (X1 + XV1) MOD M
     Y1 = (Y1 + YV1) MOD M
     X2 = (X2 + XV2) MOD M
     Y2 = (Y2 + YV2) MOD M
   NEXT Cnt
   X1 = XA1
   X2 = XB1
   Y1 = YA1
   Y2 = YB1
   CALL SetPlotColor(Black%)
   FOR Cnt = 1 TO Total
     XA = (X1 * 9) \ MaxDelta
     XB = (X2 * 9) \ MaxDelta
     YA = (Y1 * 9) \ MaxDelta
     YB = (Y2 * 9) \ MaxDelta
     CALL MoveTo((CX + XA), (CY - Y1))
     CALL LineTo((CX + XB), (CY - Y2))
     CALL MoveTo((CX - YA), (CY + X1))
     CALL LineTo((CX - YB), (CY + X2))
     CALL MoveTo((CX - XA), (CY - Y1))
     CALL LineTo((CX - XB), (CY - Y2))
     CALL MoveTo((CX - YA), (CY - X1))
     CALL LineTo((CX - YB), (CY - X2))
     CALL MoveTo((CX - XA), (CY + Y1))
     CALL LineTo((CX - XB), (CY + Y2))
     CALL MoveTo((CX + YA), (CY - X1))
     CALL LineTo((CX + YB), (CY - X2))
     CALL MoveTo((CX + XA), (CY + Y1))
     CALL LineTo((CX + XB), (CY + Y2))
     CALL MoveTo((CX + YA), (CY + X1))
     CALL LineTo((CX + YB), (CY + X2))
     X1 = (X1 + XV1) MOD M
     Y1 = (Y1 + YV1) MOD M
     X2 = (X2 + XV2) MOD M
     Y2 = (Y2 + YV2) MOD M
   NEXT Cnt
 LOOP

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END

Pause:
 KEY(2) OFF
 WaitKey
 KEY(2) ON
 RETURN

