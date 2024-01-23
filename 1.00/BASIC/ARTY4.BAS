 '******************************************************************************
 '* ARTY4 - Translated from the TURBO PASCAL 4.0 demo program                  *
 '*                                                                            *
 '* Modified For QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '* Press F2 to pause program                                                  *
 '* Press F3 to redraw image                                                   *
 '* Press F4 to change background color                                        *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON
 ON KEY(2) GOSUB PauseProgram
 KEY(2) ON
 ON KEY(3) GOSUB RedrawImage
 KEY(3) ON
 ON KEY(4) GOSUB SetBackgroundColor
 KEY(4) ON

 CONST Lines = 100, TotalColors = 4, MaxColor = 15

 DEFINT A-Z
 DIM LX1(Lines), LY1(Lines), LX2(Lines), LY2(Lines)
 DIM LColors(Lines, TotalColors), Colors(TotalColors)

MainLoop:
 GOSUB Initialize
 DO
   GOSUB EraseCurrentLine
   IF ColorCount = 0 THEN GOSUB SelectNewColors
   IF IncrementCount = 0 THEN GOSUB SelectNewDeltaValues
   GOSUB AdjustX1
   GOSUB AdjustY1
   GOSUB AdjustX2
   GOSUB AdjustY2
   IF INT(RND * 5) = 3 THEN
     X1 = (X1 + X2) \ 2
     Y2 = (Y1 + Y2) \ 2
   END IF
   GOSUB DrawCurrentLine
   GOSUB UpdateLine
 LOOP

Initialize:
 CALL ClearScreen
 RANDOMIZE TIMER
 MaxX = 319
 MaxY = 199
 MaxDelta = 7
 L = 1
 IncrementCount = 0
 BackColor = Black%
 StartX = MaxX \ 2
 StartY = MaxY \ 2
 FOR I = 1 TO Lines
   LX1(I) = StartX
   LY1(I) = StartY
   LX2(I) = StartX
   LY2(I) = StartY
 NEXT I
 X1 = StartX
 Y1 = StartY
 X2 = StartX
 Y2 = StartY
 GOSUB SelectNewColors
 CALL SetBackColor(BackColor)
 RETURN

AdjustX1:
 TestX1 = DeltaX1 + X1
 IF (TestX1 < 1) OR (TestX1 > MaxX) THEN
   TestX1 = X1
   DeltaX1 = -DeltaX1
 END IF
 X1 = TestX1
 RETURN

AdjustY1:
 TestY1 = DeltaY1 + Y1
 IF (TestY1 < 1) OR (TestY1 > MaxY) THEN
   TestY1 = Y1
   DeltaY1 = -DeltaY1
 END IF
 Y1 = TestY1
 RETURN

AdjustX2:
 TestX2 = DeltaX2 + X2
 IF (TestX2 < 1) OR (TestX2 > MaxX) THEN
   TestX2 = X2
   DeltaX2 = -DeltaX2
 END IF
 X2 = TestX2
 RETURN

AdjustY2:
 TestY2 = DeltaY2 + Y2
 IF (TestY2 < 1) OR (TestY2 > MaxY) THEN
   TestY2 = Y2
   DeltaY2 = -DeltaY2
 END IF
 Y2 = TestY2
 RETURN

SelectNewColors:
 Colors(1) = INT(RND * MaxColor + 1)
 Colors(2) = INT(RND * MaxColor + 1)
 Colors(3) = INT(RND * MaxColor + 1)
 Colors(4) = INT(RND * MaxColor + 1)
 ColorCount = INT(RND * 5 + 1) * 3
 RETURN

SelectNewDeltaValues:
 DeltaX1 = INT(RND * MaxDelta) - (MaxDelta \ 2)
 DeltaY1 = INT(RND * MaxDelta) - (MaxDelta \ 2)
 DeltaX2 = INT(RND * MaxDelta) - (MaxDelta \ 2)
 DeltaY2 = INT(RND * MaxDelta) - (MaxDelta \ 2)
 IncrementCount = INT(RND * 4 + 1) * 2
 RETURN

SaveCurrentLine:
 LX1(L) = X1
 LY1(L) = Y1
 LX2(L) = X2
 LY2(L) = Y2
 LColors(L, 1) = Colors(1)
 LColors(L, 2) = Colors(2)
 LColors(L, 3) = Colors(3)
 LColors(L, 4) = Colors(4)
 RETURN

UpdateLine:
 L = L + 1
 IF L > Lines THEN L = 1
 ColorCount = ColorCount - 1
 IncrementCount = IncrementCount - 1
 RETURN

DrawCurrentLine:
 CALL SetPlotColor(Colors(1))
 CALL ExtLine(X1, Y1, X2, Y2)
 CALL SetPlotColor(Colors(2))
 CALL ExtLine(MaxX - X1, Y1, MaxX - X2, Y2)
 CALL SetPlotColor(Colors(3))
 CALL ExtLine(X1, MaxY - Y1, X2, MaxY - Y2)
 CALL SetPlotColor(Colors(4))
 CALL ExtLine(MaxX - X1, MaxY - Y1, MaxX - X2, MaxY - Y2)
 GOSUB SaveCurrentLine
 RETURN

EraseCurrentLine:
 CALL SetPlotColor(Black%)
 CALL ExtLine(LX1(L), LY1(L), LX2(L), LY2(L))
 CALL ExtLine(MaxX - LX1(L), LY1(L), MaxX - LX2(L), LY2(L))
 CALL ExtLine(LX1(L), MaxY - LY1(L), LX2(L), MaxY - LY2(L))
 CALL ExtLine(MaxX - LX1(L), MaxY - LY1(L), MaxX - LX2(L), MaxY - LY2(L))
 RETURN

EndProgram:
 KEY(1) OFF
 KEY(2) OFF
 KEY(3) OFF
 KEY(4) OFF
 CALL ExitGraphics
 END

PauseProgram:
 KEY(2) OFF
 CALL WaitKey
 KEY(2) ON
 RETURN

RedrawImage:
 KEY(3) ON
 RETURN MainLoop

SetBackgroundColor:
 IF BackColor > MaxColor THEN
   BackColor = 0
 ELSE
   BackColor = BackColor + 1
 END IF
 CALL SetBackColor(BackColor)
 RETURN

