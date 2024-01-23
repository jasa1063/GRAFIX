 '******************************************************************************
 '* P-DEMO1 (CHANGING SHAPES WITH PALETTE COMMAND)                             *
 '*     By Raymond C. Yancy - Nov 1987                                         *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to increase screen change speed                                   *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-Z
 DIM Shape(1282), H0(15), H1(15), H2(15), H3(15), H4(15)

 FOR N = 0 TO 15
   READ H0(N)
 NEXT N
 FOR N = 0 TO 15
   READ H1(N)
 NEXT N
 FOR N = 0 TO 15
   READ H2(N)
 NEXT N
 FOR N = 0 TO 15
   READ H3(N)
 NEXT N
 FOR N = 0 TO 15
   READ H4(N)
 NEXT N

 DEF SEG = VARSEG(Shape(0))
 A = VARPTR(Shape(0))
 BLOAD "P-DEMO1.BIN", A
 DEF SEG
 FOR X = 0 TO 256 STEP 64
   FOR Y = 4 TO 132 STEP 64
     CALL ExtPut(X, Y, Shape(), PutXor)
   NEXT Y
 NEXT X

 PauseVal = 22
 S = 4
 P = PauseVal

 DO
   CALL PaletteUsing(H0(), 0)
   GOSUB DelayLoop
   CALL PaletteUsing(H1(), 0)
   GOSUB DelayLoop
   CALL PaletteUsing(H2(), 0)
   GOSUB DelayLoop
   CALL PaletteUsing(H3(), 0)
   GOSUB DelayLoop
   CALL PaletteUsing(H4(), 0)
   GOSUB DelayLoop
 LOOP

DelayLoop:
 CALL Pause(P)
 K$ = INKEY$
 K$ = RIGHT$(K$, 1)
 IF K$ = CHR$(27) THEN
   CALL ExitGraphics
   END
 END IF
 IF K$ = CHR$(59) THEN GOSUB ScreenSpeed
 RETURN

ScreenSpeed:
 P = P - S
 IF P < 0 THEN P = PauseVal
 RETURN

 DATA 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 DATA 9,1,3,3,1,3,3,1,3,3,9,9,8,9,0,15
 DATA 12,0,0,0,15,15,15,15,15,15,4,12,12,12,0,15
 DATA 10,7,7,8,7,7,8,7,7,8,10,10,10,2,14,6
 DATA 11,14,14,14,14,14,14,6,6,6,11,3,11,11,4,1

