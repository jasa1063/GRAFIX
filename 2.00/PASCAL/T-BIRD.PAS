{
 ******************************************************************************
 * T-BIRD - Line drawing demo for the 160x200x16 color graphics mode.	      *
 *									      *
 * Written for GRAFIX by:  Joseph A. Albrecht				      *
 *									      *
 * Press ESC to exit program						      *
 ******************************************************************************
}

PROGRAM ThunderBird;

USES
  Crt,
  Dos,
  Grafix;

TYPE
  Colors = ARRAY [0..13] OF INTEGER;

VAR
  I, J, K, L: INTEGER;
  H, M, S, S100: WORD;
  Ch: CHAR;

CONST
  LC: Colors = (0, 15, 3, 3, 3, 3, 3, 4, 3, 4, 3, 3, 15, 0);

{Mainline}
BEGIN

  LowGraphics;
  WHILE True DO
  BEGIN
    ClearScreen;
    L := 0;
    K := 156;
    Ch := #255;
    FOR J := 80 TO K DO
      FOR I := 0 TO J DO
	BEGIN
	  IF KeyPressed THEN
	    Ch := ReadKey;
	  IF Ch = #27 THEN
	    BEGIN
	      ExitGraphics;
	      Halt(0);
	    END;
          SetPlotColor(LC[L]);
	  ExtLine(I, J, K - I, K - J);
	  ExtLine(K - I, J, I, K - J);
	  ExtLine(J, I, K - J, K - I);
	  ExtLine(K - J, I, J, K - I);
	  L := (L + 1) Mod 14;
	END;
    GetTime(H, M, S, S100);
    K := S;
    J := 1;
    REPEAT
      GetTime(H, M, S, S100);
      IF K <> S THEN
	BEGIN
	  Inc(J);
	  K := S
	END;
    UNTIL (J = 7) OR KeyPressed;
  END;

END.

