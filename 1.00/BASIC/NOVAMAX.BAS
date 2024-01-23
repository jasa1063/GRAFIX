 '******************************************************************************
 '* NOVAMAX - Author Unknown                                                   *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON

 DEFINT A-Z
 DIM Palettes(30)

 A = Blue
 B = Green
 C = Cyan
 D = Red

Again:
 RANDOMIZE TIMER
 CALL SetPlotColor(A)
 FOR J = 0 TO 319 STEP 2
   CALL ExtLine(J, 199, 160, 100)
 NEXT J
 CALL SetPlotColor(B)
 FOR J = 0 TO 319 STEP 2
   CALL ExtLine(J, 0, 160, 100)
 NEXT J
 CALL SetPlotColor(C)
 FOR J = 0 TO 199 STEP 2
   CALL ExtLine(160, 100, 319, J)
 NEXT J
 CALL SetPlotColor(D)
 FOR J = 0 TO 199 STEP 2
   CALL ExtLine(160, 100, 0, J)
 NEXT J
 SetPalette (RND * 4 + 1), (RND * 11 + 1) + 4
 FOR J = 0 TO 319 STEP 4
   CALL ExtLine(J, 199, 160, 100)
 NEXT J
 CALL SetPlotColor(C)
 FOR J = 0 TO 319 STEP 4
   CALL ExtLine(J, 0, 160, 100)
 NEXT J
 CALL SetPlotColor(B)
 FOR J = 0 TO 199 STEP 4
   CALL ExtLine(160, 100, 319, J)
 NEXT J
 CALL SetPlotColor(A)
 FOR J = 0 TO 199 STEP 4
   CALL ExtLine(160, 100, 0, J)
 NEXT J
 CALL SetPlotColor(C)
 FOR J = 0 TO 319 STEP 8
   CALL ExtLine(J, 199, 160, 100)
 NEXT J
 CALL SetPlotColor(D)
 FOR J = 0 TO 319 STEP 8
   CALL ExtLine(J, 0, 160, 100)
 NEXT J
 CALL SetPlotColor(A)
 FOR J = 0 TO 199 STEP 8
   CALL ExtLine(160, 100, 319, J)
 NEXT J
 CALL SetPlotColor(B)
 FOR J = 0 TO 199 STEP 8
   CALL ExtLine(160, 100, 0, J)
 NEXT J
 FOR K = 1 TO 30
   Palettes(K) = K MOD 15
 NEXT K
 FOR K = 15 TO 1 STEP -1
   CALL PaletteUsing(Palettes(), K)
   CALL Pause(3)
 NEXT K
 GOTO Again

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END

