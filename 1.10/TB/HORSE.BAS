 '******************************************************************************
 '* HORSE -- Demonstrates animation                                            *
 '*                                                                            *
 '* Modified for TURBO BASIC with GRAFIX driver                                *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to change foreground color                                        *
 '* Press F2 to change background color                                        *
 '* Press ESC to exit program                                                  *
 '******************************************************************************
 $INCLUDE "GRAFIX.BAS"

 CALL EnableGraphics

 DEFINT A-Z
 DIM H1(354), H2(354), H3(354), H4(354), H5(354), ImageError(5)

 FC = %LtWhite
 BC = %Blue
 CALL ClearScreen
 CALL SetBackColor(%Blue)

 OPEN "HORSE1.BIN" FOR RANDOM AS 1
 IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "HORSE1.BIN"
   ImageError(1) = 1
 ELSE
   CLOSE 1
   DEF SEG = VARSEG(H1(0))
   A% = VARPTR(H1(0))
   BLOAD "HORSE1.BIN", A%
 END IF
 OPEN "HORSE2.BIN" FOR RANDOM AS 1
 IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "HORSE2.BIN"
   ImageError(2) = 1
 ELSE
   CLOSE 1
   DEF SEG = VARSEG(H2(0))
   A% = VARPTR(H2(0))
   BLOAD "HORSE2.BIN", A%
 END IF
 OPEN "HORSE3.BIN" FOR RANDOM AS 1
 IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "HORSE3.BIN"
   ImageError(3) = 1
 ELSE
   CLOSE 1
   DEF SEG = VARSEG(H3(0))
   A% = VARPTR(H3(0))
   BLOAD "HORSE3.BIN", A%
 END IF
 OPEN "HORSE4.BIN" FOR RANDOM AS 1
 IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "HORSE4.BIN"
   ImageError(4) = 1
 ELSE
   CLOSE 1
   DEF SEG = VARSEG(H4(0))
   A% = VARPTR(H4(0))
   BLOAD "HORSE4.BIN", A%
 END IF
 OPEN "HORSE5.BIN" FOR RANDOM AS 1
 IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "HORSE5.BIN"
   ImageError(5) = 1
 ELSE
   CLOSE 1
   DEF SEG = VARSEG(H5(0))
   A% = VARPTR(H5(0))
   BLOAD "HORSE5.BIN", A%
 END IF
 FOR A% = 1 TO 5
   IF ImageError(A%) = 1 THEN GOTO GenerateImage
 NEXT A%
 GOTO PutImage

 '
 ' --- Generate Main Images ---
 '
GenerateImage:
 FOR G = 1 TO 5
   FOR H = 1 TO 29
     FOR J = 1 TO 6
       READ Z$
       K = VAL("&H" + Z$)
       IF K <> 0 AND ImageError(G) = 1 THEN
         M = K
         FOR N = 8 TO 0 STEP -1
           C = 2 ^ N
           IF M >= C THEN
             P = (J - 2) * 8
             IF K - C >= 0 THEN
               K = K - C
               CALL PlotPointC(P + (16 - N), H, %LtWhite)
             ELSE
               CALL PlotPointC(P + (16 - N), H, %Black)
             END IF
           END IF
         NEXT N
       END IF
     NEXT J
   NEXT H
   SELECT CASE G
     CASE 1
       IF ImageError(1) = 1 THEN
         CALL ExtGet(0, 0, 47, 28, H1())
         DEF SEG = VARSEG(H1(0))
         A% = VARPTR(H1(0))
         BSAVE "HORSE1.BIN", A%, 708
       END IF
     CASE 2
       IF ImageError(2) = 1 THEN
         CALL ExtGet(0, 0, 47, 28, H2())
         DEF SEG = VARSEG(H2(0))
         A% = VARPTR(H2(0))
         BSAVE "HORSE2.BIN", A%, 708
       END IF
     CASE 3
       IF ImageError(3) = 1 THEN
         CALL ExtGet(0, 0, 47, 28, H3())
         DEF SEG = VARSEG(H3(0))
         A% = VARPTR(H3(0))
         BSAVE "HORSE3.BIN", A%, 708
       END IF
     CASE 4
       IF ImageError(4) = 1 THEN
         CALL ExtGet(0, 0, 47, 28, H4())
         DEF SEG = VARSEG(H4(0))
         A% = VARPTR(H4(0))
         BSAVE "HORSE4.BIN", A%, 708
       END IF
     CASE 5
       IF ImageError(5) = 1 THEN
         CALL ExtGet(0, 0, 47, 28, H5())
         DEF SEG = VARSEG(H5(0))
         A% = VARPTR(H5(0))
         BSAVE "HORSE5.BIN", A%, 708
       END IF
   END SELECT
   CALL ClearScreen
 NEXT G

 '
 ' --- Prints Image Arrays Onto Screen ---
 '
PutImage:
 FOR Q = 1 TO 157 STEP 52
   CALL ExtPut(Q + 54, 85, H1(), %PutPset)
 NEXT Q
 FOR Q = 1 TO 157 STEP 52
   CALL ExtPut(Q + 54, 85, H2(), %PutPset)
 NEXT Q
 FOR Q = 1 TO 157 STEP 52
   CALL ExtPut(Q + 54, 85, H3(), %PutPset)
 NEXT Q
 FOR Q = 1 TO 157 STEP 52
   CALL ExtPut(Q + 54, 85, H4(), %PutPset)
 NEXT Q
 FOR Q = 1 TO 157 STEP 52
   CALL ExtPut(Q + 54, 85, H5(), %PutPset)
 NEXT Q
 K$ = INKEY$
 K$ = RIGHT$(K$, 1)
 IF K$ = CHR$(27) THEN
   CALL ExitGraphics
   END
 END IF
 IF K$ = CHR$(59) THEN GOSUB ChangeForColor
 IF K$ = CHR$(60) THEN GOSUB ChangeBackColor
 GOTO PutImage

 '
 ' --- Change Colors ---
 '
ChangeForColor:
 FC = FC + 1
 IF FC > 15 THEN FC = 1
 IF FC = BC THEN GOTO ChangeForColor
 CALL SetPalette(%LtWhite, FC)
 RETURN

ChangeBackColor:
 BC = BC + 1
 IF BC > 15 THEN BC = 0
 IF BC = FC THEN GOTO ChangeBackColor
 CALL SetBackColor(BC)
 RETURN

 '
 ' --- Drawing DATA ---
 '
 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
 DATA 00,06,00,00,00,00,00,76,00,00,00,00,01,9B,80
 DATA 00,00,00,01,7F,C0,00,00,00,06,F7,20,00,00,00
 DATA 0F,E7,88,00,00,00,3B,87,C4,00,00,00,0F,0E,CC
 DATA 00,03,FF,FE,3C,30,03,FC,1F,C0,7C,00,0E,BC,00
 DATA 00,0C,00,1D,0E,18,00,08,00,05,0B,1F,00,08,00
 DATA 00,0B,9D,F0,38,00,00,0F,CF,FC,70,00,00,05,DF
 DATA BF,F8,00,00,7E,F3,DF,FE,00,00,7F,E0,7F,8E,00
 DATA 00,61,C0,03,FC,00,00,63,C0,03,F8,00,00,67,80
 DATA 01,80,00,00,63,80,01,80,00,01,C1,C0,01,80,00
 DATA 01,80,E0,01,C0,00,00,00,70,01,E0,00,00,00,18
 DATA 00,30,00,00,00,1C,00,38,00,00,00,00,00,00,00
 DATA 00,00,00,00,08,00,00,00,00,00,0C,00,00,00,00
 DATA 01,BE,00,00,00,00,05,79,00,00,00,00,08,F8,80
 DATA 00,00,00,3B,FC,20,00,00,00,57,BF,D0,00,00,00
 DATA FF,BB,90,00,07,FF,01,B8,C0,03,FC,20,00,30,00
 DATA 07,D0,20,00,10,00,0F,97,6C,04,10,00,1D,1F,FF
 DATA 1C,10,00,00,1F,FF,FC,30,00,00,0F,FF,B8,F0,00
 DATA 00,0F,FF,F8,1C,00,00,0F,8F,FF,FE,00,00,3E,00
 DATA 1F,06,00,00,3C,00,3C,0C,00,00,38,00,30,38,00
 DATA 00,EC,00,70,30,00,00,CC,00,60,00,00,00,C6,00
 DATA C0,00,00,00,DC,01,00,00,00,00,D8,01,00,00,00
 DATA 00,C0,01,00,00,00,00,60,00,00,00,00,00,70,00
 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
 DATA 00,00,00,00,02,00,00,00,00,00,03,00,00,00,00
 DATA 00,3E,80,00,00,00,01,EF,C0,00,00,00,00,DF,20
 DATA 00,00,00,3F,7F,10,00,00,00,17,F7,C4,00,00,00
 DATA FF,EE,6C,00,03,FF,80,FC,30,03,FC,18,00,14,00
 DATA 0F,C8,30,00,08,00,3F,0C,7C,38,18,00,0A,1F,38
 DATA 7E,10,00,00,1F,FF,FF,10,00,00,1F,BF,FE,38,00
 DATA 00,1F,E0,FE,07,80,00,3D,E0,07,FF,C0,00,79,C0
 DATA 07,00,C0,00,F3,80,0E,00,C0,01,C3,00,0C,00,C0
 DATA 03,01,80,18,00,C0,06,00,60,70,00,80,0C,00,33
 DATA C0,01,00,18,00,3E,00,00,00,18,00,00,00,00,00
 DATA 38,00,00,00,00,00,18,00,00,00,00,00,00,00,00
 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,06,00
 DATA 00,00,00,00,76,00,00,00,00,00,9B,00,00,00,00
 DATA 00,7F,00,00,00,00,00,F7,80,00,00,00,01,E7,20
 DATA 00,00,00,01,7F,08,00,00,00,0B,FF,FC,00,03,FC
 DATA 1D,FE,CC,03,FF,7F,E0,7A,20,07,CC,10,00,1E,00
 DATA 0A,8D,EF,0C,0C,00,00,0F,3F,8E,04,00,00,0E,6F
 DATA DC,44,00,00,0D,9F,FC,7C,00,00,0F,7F,FF,C4,00
 DATA 00,0F,F8,3F,F3,00,00,3F,38,01,FF,80,00,F8,18
 DATA 01,C7,C0,00,E0,18,00,C0,C0,01,80,38,70,C0,60
 DATA 03,00,1C,3F,C0,30,76,00,06,00,00,18,3C,00,01
 DATA 80,00,00,00,00,00,C0,00,00,00,00,00,C0,00,00
 DATA 00,00,00,00,00,00,00,00,00,00,30,00,00,00,00
 DATA 00,38,00,00,00,00,00,FE,00,00,00,00,06,1F,00
 DATA 00,00,00,0F,E3,80,00,00,00,1E,FF,20,00,00,00
 DATA 1C,FD,90,00,00,00,3D,FF,E8,00,03,FF,FF,FC,D8
 DATA 01,FF,7C,3F,1C,40,03,E8,50,0C,38,00,07,4E,18
 DATA 00,38,00,0D,8E,3C,00,18,00,00,0F,F7,00,10,00
 DATA 00,07,EF,F1,D0,00,00,0F,9F,04,70,00,00,3C,70
 DATA FF,30,00,00,FF,F0,01,F0,00,01,F0,70,0C,78,00
 DATA 01,80,30,06,38,00,03,00,38,03,7C,00,03,00,18
 DATA 01,C6,00,76,00,0C,00,03,00,3C,00,06,00,01,80
 DATA 00,00,03,00,00,C0,00,00,01,C0,00,70,00,00,00
 DATA E0,00,38,00,00,00,00,00,00,00,00,00,00,00,00

