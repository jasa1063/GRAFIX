 '******************************************************************************
 '* RANDOM BOXES - Taken from the August, 1988 issue of PCM magazine           *
 '*                                                                            *
 '* Modified for QuickBASIC 4.0 with GRAFIX driver                             *
 '*     By Joseph A. Albrecht - Sep 1988                                       *
 '*                                                                            *
 '* Press F1 to exit program                                                   *
 '* Press F2 to clear screen                                                   *
 '******************************************************************************
 '$INCLUDE: 'GRAFIX.DEF'

 CALL EnableGraphics
 ON KEY(1) GOSUB EndProgram
 KEY(1) ON
 ON KEY(2) GOSUB ClrScreen
 KEY(2) ON

 DEFINT A-Z
 DEF FNRND (Max) = INT(RND * Max) + 1

 MXSize = 90
 MYSize = 70
 MaxX = 319 - MXSize
 MaxY = 199 - MYSize
 MaxColor = 16
 DO
   X = FNRND(MaxX)
   Y = FNRND(MaxY)
   XSize = FNRND(MXSize)
   YSize = FNRND(MYSize)
   BoxColor = FNRND(MaxColor) - 1
   CALL FillBox(X, Y, X + XSize, Y + YSize, BoxColor)
 LOOP

ClrScreen:
  KEY(2) OFF
  Call ClearScreen
  KEY(2) ON
  RETURN

EndProgram:
 KEY(1) OFF
 CALL ExitGraphics
 END

