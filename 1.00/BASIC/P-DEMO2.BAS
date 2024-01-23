 '*****************************************************************************
 '* P-DEMO2 (DEMONSTRATION OF EFFECTS WITH PALETTE COMMAND)                   *
 '*     by Raymond C. Yancy - Nov 1987                                        *
 '*                                                                           *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                            *
 '*     by Joseph A. Albrecht - Sep 1988                                      *
 '*                                                                           *
 '* Press F1 to exit program                                                  *
 '*****************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 CALL AudioOff
 CALL SpeakerOn
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON
 RANDOMIZE TIMER

 DEFINT A-Z
 DIM H0(15), H1(15), H2(15), H3(15), H4(15), H5(15), H6(15), H7(15), H8(15), H9(15)
 DIM H10(15), H11(15), H12(15)

 C1(1) = Green%
 C1(2) = Cyan%
 C2(1) = Blue%
 C2(2) = Cyan%
 C2(3) = Yellow%

 FOR N = 0 TO 7
   READ H0(N)
 NEXT N
 FOR N = 0 TO 7
   READ H1(N)
 NEXT N
 FOR N = 0 TO 7
   READ H2(N)
 NEXT N
 FOR N = 0 TO 7
   READ H3(N)
 NEXT N
 FOR N = 0 TO 7
   READ H4(N)
 NEXT N
 FOR N = 0 TO 7
   READ H5(N)
 NEXT N
 FOR N = 0 TO 7
   READ H6(N)
 NEXT N
 FOR N = 0 TO 7
   READ H7(N)
 NEXT N
 FOR N = 0 TO 15
   READ H8(N)
 NEXT N
 FOR N = 0 TO 15
   READ H9(N)
 NEXT N
 FOR N = 0 TO 15
   READ H10(N)
 NEXT N
 FOR N = 0 TO 15
   READ H11(N)
 NEXT N
 FOR N = 0 TO 15
   READ H12(N)
 NEXT N

 CALL PaletteUsing(H0(), 0)
 DEF SEG = &HB800
 BLOAD "P-DEMO2.BIN", 0
 DEF SEG

MainLoop:
 S1 = 120
 FOR N = 1 TO 7
   GOSUB LightCoils1
   GOSUB MakeSound
   GOSUB LightCoils2
   GOSUB MakeSound
 NEXT N
 FOR N = 1 TO 7
   GOSUB LightPosts
   GOSUB LightCoils1
   GOSUB LightCoils2
   GOSUB MakeSound
 NEXT N
 FOR N = 1 TO 4
   GOSUB LightGlobes
 NEXT N
 FOR N = 1 TO 5
   GOSUB LightArcs
   GOSUB MakeSound
 NEXT N
 CALL ClearKey
 RANDOMIZE TIMER
 TIMES = 0
 NO.TIMES = INT(RND * 7 + 1)
 A$ = ""
 WHILE A$ = "" AND TIMES < NO.TIMES
   L = 6
   GOSUB LightEmAll
   TIMES = TIMES + 1
 WEND
 GOTO MainLoop

MakeSound:
 CALL ExtSound(S1, 10, 7, 0)
 CALL ExtSound(S1 + 5, 10, 7, 1)
 CALL ExtSound(S1 + 10, 10, 7, 2)
 S1 = S1 + 5
 RETURN

LightCoils1:
 CALL PaletteUsing(H2(), 0)
 CALL Pause(3)
 RETURN

LightCoils2:
 CALL PaletteUsing(H3(), 0)
 CALL Pause(3)
 RETURN

LightPosts:
 CALL SetPalette(Green%, Brown%)
 CALL SetPalette(Cyan%, Yellow%)
 J = 1
 FOR T = 1 TO 2
   FOR Y = 193 TO 58 STEP -14
     FOR X = 42 TO 278 STEP 236
       CALL ExtPaint(X, Y, C1(J), Blue%)
     NEXT X
   NEXT Y
   GOSUB MakeSound
   CALL SetPlotColor(C1(J))
   CALL ExtLine(68, 42, 72, 42)
   CALL ExtLine(250, 42, 253, 42)
   J = J MOD 2 + 1
 NEXT T
 RETURN

LightGlobes:
 CALL PaletteUsing(H4(), 0)
 CALL Pause(3)
 CALL PaletteUsing(H5(), 0)
 CALL Pause(3)
 GOSUB MakeSound
 CALL PaletteUsing(H6(), 0)
 CALL Pause(3)
 CALL PaletteUsing(H7(), 0)
 CALL Pause(3)
 GOSUB MakeSound
 RETURN

LightArcs:
 GOSUB MakeNoise
 CALL PaletteUsing(H4(), 0)
 GOSUB GetZ
 CALL SetPalette(Gray%, C2(Z))
 CALL PaletteUsing(H5(), 0)
 GOSUB GetZ
 CALL SetPalette(LtBlue%, C2(Z))
 CALL PaletteUsing(H6(), 0)
 GOSUB GetZ
 CALL SetPalette(LtGreen%, C2(Z))
 CALL PaletteUsing(H7(), 0)
 GOSUB GetZ
 CALL SetPalette(LtBlue%, C2(Z))
 RETURN

GetZ:
 Z = INT(RND * 3) + 1
 CALL Pause(2)
 RETURN

MakeNoise:
 CALL Noise(5, 8, 12)
 RETURN

LightEmAll:
 FOR T = 1 TO 5
   CALL Noise(5, L, 18)
   CALL PaletteUsing(H8(), 0)
   CALL Pause(3)
   CALL PaletteUsing(H9(), 0)
   CALL Pause(3)
   CALL PaletteUsing(H10(), 0)
   CALL Pause(3)
   CALL PaletteUsing(H11(), 0)
   CALL Pause(3)
   CALL PaletteUsing(H12(), 0)
   CALL Pause(3)
   L = L + 1
 NEXT T
 RETURN

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 AudioOff
 END

 DATA 00,00,00,00,00,00,00,00
 DATA 00,01,08,08,08,07,03,08
 DATA 00,01,08,08,06,10,03,08
 DATA 00,01,08,08,10,03,03,08
 DATA 00,01,06,14,06,10,03,04
 DATA 00,01,14,06,10,03,04,14
 DATA 00,01,06,14,06,10,14,14
 DATA 00,01,14,06,10,03,04,14
 DATA 00,01,06,14,06,10,03,04,03,00,00,14,00,00,00,00
 DATA 00,01,14,06,10,03,04,14,00,09,00,00,06,00,00,00
 DATA 00,01,06,14,06,10,14,14,00,00,01,00,00,04,00,00
 DATA 00,01,14,06,10,03,04,14,00,10,00,00,00,00,05,00
 DATA 00,01,06,14,06,10,03,04,03,00,00,00,00,00,00,09

