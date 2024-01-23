 '******************************************************************************
 '* PUT-1 ('PUT' COLORS USING PSET, PRESET, AND, OR, XOR)                      *
 '*     by Raymond C. Yancy - Oct 1987                                         *
 '*                                                                            *
 '* Modified For QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-Z
 DIM Box(69), C$(15), M$(5)

 FOR N = 0 TO 15
   READ C$(N)
 NEXT N
 FOR N = 1 TO 5
   READ M$(N)
 NEXT N

 CALL SetTextColor(Yellow)
 GOSUB DrawBoxes
 CALL SetTextColor(Brown)
 CALL SetCursor(5, 5)
 CALL PrintString("ACTION:")
 FOR N = 1 TO 5
   GOSUB PrintNames
 NEXT N
 CALL SetTextColor(LtCyan)
 CALL PrintString(" ")
 CALL PrintString(" Enter number " + CHR$(24))
 CALL PrintString(" ")
 CALL PrintString("       or")
 CALL PrintString(" ")
 CALL PrintString(" press <Return>")
 CALL PrintString(" ")
 CALL PrintStringX(" for next color")

MainLoop:
 C = -1
 WHILE C < 0 OR C > 15
   CALL SetTextColor(Yellow)
   CALL SetCursor(2, 1)
   CALL PrintStringX(SPACE$(16))
   CALL SetCursor(2, 2)
   CALL GetInput("Enter Color ", A$)
   C = VAL(A$)
   CALL SetCursor(2, 1)
   CALL PrintStringX(SPACE$(16))
 WEND
 GOSUB DrawBoxes
 CALL FillBox(0, 0, 15, 15, C)
 CALL ExtGet(0, 0, 15, 15, Box())
 CALL ExtPut(0, 0, Box(), PutXor)
 IF C = 0 THEN
   CALL SetTextColor(Gray)
 ELSE
   CALL SetTextColor(C)
 END IF
 CALL SetCursor(2, 8 - LEN(C$(C)) / 2)
 CALL PrintStringX(C$(C))
 CALL ClearKey

 N = 0
 DO UNTIL N >= 1 AND N <= 5
   A$ = ""
   WHILE A$ = ""
     A$ = INKEY$
   WEND
   N = VAL(A$)
   IF A$ = CHR$(13) THEN EXIT DO
   IF A$ = CHR$(27) THEN GOSUB EndProgram
 LOOP

NextAction:
 IF A$ = CHR$(13) THEN
   CALL SetCursor(2, 3)
   CALL PrintStringX(SPACE$(10))
   GOTO MainLoop
 END IF
 CALL SetTextColor(Yellow)
 FOR B = 1 TO 3
   CALL SetCursor(N * 2 + 6, 2)
   CALL PrintStringX(SPACE$(14))
   CALL Pause(8)
   GOSUB PrintNames
   CALL Pause(8)
 NEXT B
 X = 145
 Y = 20
 FOR J = 0 TO 15
   ON N GOSUB ShowPreset, ShowPset, ShowAnd, ShowOr, ShowXor
   X = X + 48
   IF X > 290 THEN
     X = 145
     Y = Y + 48
   END IF
 NEXT J
 M = 0
 DO UNTIL M >= 1 AND M <= 5
   A$ = ""
   WHILE A$ = ""
     A$ = INKEY$
   WEND
   M = VAL(A$)
   IF A$ = CHR$(13) THEN EXIT DO
   IF A$ = CHR$(27) THEN GOSUB EndProgram
 LOOP
 CALL SetTextColor(Brown)
 GOSUB PrintNames
 GOSUB DrawBoxes
 N = M
 GOTO NextAction

ShowPreset:
 CALL ExtPut(X, Y, Box(), PutPreset)
 RETURN

ShowPset:
 CALL ExtPut(X, Y, Box(), PutPset)
 RETURN

ShowAnd:
 CALL ExtPut(X, Y, Box(), PutAnd)
 RETURN

ShowOr:
 CALL ExtPut(X, Y, Box(), PutOr)
 RETURN

ShowXor:
 CALL ExtPut(X, Y, Box(), PutXor)
 RETURN

PrintNames:
 CALL SetCursor(N * 2 + 6, 2)
 CALL PrintStringX(M$(N))
 FOR P = 1 TO 12 - LEN(M$(N))
   CALL PrintStringX(".")
 NEXT P
 CALL PrintString(STR$(N))
 RETURN

DrawBoxes:
 CALL FillBox(129, 4, 319, 195, Black)
 CALL DrawBox(129, 4, 319, 195, Red)
 CALL SetPlotColor(Red)
 CALL ExtLine(4, 24, 124, 24)
 X = 137
 Y = 12
 FOR J = 0 TO 15
   CALL FillBox(X, Y, X + 31, Y + 31, J)
   IF J = 0 THEN CALL DrawBox(X, Y, X + 31, Y + 31, Gray)
   X = X + 48
   IF X > 283 THEN
     X = 136
     Y = Y + 48
   END IF
 NEXT J
 RETURN

EndProgram:
 CALL ExitGraphics
 END

 DATA BLACK,BLUE,GREEN,CYAN,RED,MAGENTA,BROWN,LT GREY,GREY
 DATA LT BLUE,LT GREEN,LT CYAN,LT RED,LT MAGENTA,YELLOW,WHITE
 DATA PRESET,PSET,AND,OR,XOR

