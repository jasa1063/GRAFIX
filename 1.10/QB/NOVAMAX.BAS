 '******************************************************************************
 '* NOVAMAX - Author Unknown                                                   *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     by Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics

 DEFINT A-Z
 DIM Palettes(30)

 A = Blue
 B = Green
 C = Cyan
 D = Red

Again:
 RANDOMIZE TIMER
 FOR J = 0 TO 319 STEP 2
   CALL ExtLineC(J, 199, 160, 100, A)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 319 STEP 2
   CALL ExtLineC(J, 0, 160, 100, B)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 2
   CALL ExtLineC(160, 100, 319, J, C)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 2
   CALL ExtLineC(160, 100, 0, J, D)
   GOSUB CheckKey
 NEXT J
 CALL SetPalette(INT(RND * 2 + 1), INT(RND * 15 + 1))
 FOR J = 0 TO 319 STEP 4
   CALL ExtLineC(J, 199, 160, 100, D)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 319 STEP 4
   CALL ExtLineC(J, 0, 160, 100, C)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 4
   CALL ExtLineC(160, 100, 319, J, B)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 4
   CALL ExtLineC(160, 100, 0, J, A)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 319 STEP 8
   CALL ExtLineC(J, 199, 160, 100, C)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 319 STEP 8
   CALL ExtLineC(J, 0, 160, 100, D)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 8
   CALL ExtLineC(160, 100, 319, J, A)
   GOSUB CheckKey
 NEXT J
 FOR J = 0 TO 199 STEP 8
   CALL ExtLineC(160, 100, 0, J, B)
 NEXT J
 FOR K = 1 TO 30
   Palettes(K) = K MOD 15
   GOSUB CheckKey
 NEXT K
 FOR K = 15 TO 1 STEP -1
   CALL PaletteUsing(Palettes(), K)
   CALL Pause(3)
   GOSUB CheckKey
 NEXT K
 GOTO Again

CheckKey:
 K$ = INKEY$
 IF K$ = CHR$(27) THEN
   CALL ExitGraphics
   END
 END IF
 RETURN

