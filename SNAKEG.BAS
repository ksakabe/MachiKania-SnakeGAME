REM ========================
REM  SNAKE for MachiKania
REM   - W/A/S/D : move
REM   - Q       : quit
REM   - R       : restart (after game over)
REM ========================

USEVAR MAXN,SCORE,GAMEOVER
USEVAR REPEAT,OLDHI
USEVAR DLY,LE,DIR
USEVAR OX,OY,CX,CY
USEVAR HI,TI,HX,HY,NX,NY
USEVAR TX,TY,FX,FY,EAT
USEVAR SX,SY

REM --- Key codes (assume ASCII) ---
USEVAR K_W,K_A,K_S,K_D,K_Q,K_R
USEVAR B_U,B_D,B_L,B_R,B_S,B_F
K_W=$57:K_A=$41:K_S=$53:K_D=$44:K_Q=$51:K_R=$52
B_U=1  :B_D=2  :B_L=4  :B_R=8  :B_S=16:B_F=32

LABEL INIT

rem RANDOMIZE TIMER

W  = 32:H  = 20
OX =  2:OY =  2

MAXN = 800
DIM SX(MAXN),SY(MAXN)

CLS

GOSUB DRAW_UI

LE  = 5
DIR = 4:REM 1=UP 2=LEFT 3=DOWN 4=RIGHT
SCORE = 0

CX = W / 2
CY = H / 2

HI = 0
TI = 1

REM --- Initialize snake horizontally ---
FOR I = 1 TO LE
  HI = HI + 1
  SX(HI) = CX - (LE - I)
  SY(HI) = CY
NEXT

GOSUB DRAW_SNAKE_INIT
GOSUB SPAWN_FOOD

LABEL MAIN
REM --- Key poll ---
K = INKEY()
B = KEYS()

IF K!=0 OR B!=0 THEN GOSUB HANDLE_KEY

GOSUB STEP_MOVE
IF GAMEOVER = 1 THEN GOTO GAME_OVER

GOTO MAIN

REM ========================
REM  GAME OVER / RESTART
REM ========================

LABEL GAME_OVER
CURSOR 1, OY + H + 3
PRINT "GAME OVER. Score="; SCORE; "  (R:restart / Q:quit)"

LABEL WAIT_RESTART
K=INKEY():B=KEYS()
REM IF K = 0 THEN GOTO WAIT_RESTART
WHILE (K=0) AND (B=0)
  K=INKEY():B=KEYS()
WEND

IF (K=K_R) OR (B=B_S) THEN GOTO INIT
IF (K=K_Q) OR (B=B_F) THEN END

GOTO WAIT_RESTART
END

REM ========================
REM  UI / DRAW
REM ========================

LABEL DRAW_UI
CLS
CURSOR 0,0 : PRINT "SNAKE (W/A/S/D or BUTTON)  Quit:Q/Fire"
CURSOR 0,1 : PRINT "Score: 0"

REM  Top border
CURSOR OX, OY
PRINT "+";
FOR I=1 TO W
  PRINT "-";
NEXT
PRINT "+"

REM  Side borders
FOR R = 1 TO H
  CURSOR OX, OY + R
  PRINT "|";
  FOR I=1 TO W
    PRINT " ";
  NEXT
  PRINT "|"
NEXT

REM  Bottom border
CURSOR OX, OY + H + 1
PRINT "+";
FOR I=1 TO W
  PRINT "-";
NEXT
PRINT "+"
RETURN


LABEL DRAW_SNAKE_INIT
FOR I = TI TO HI
  X = SX(I) : Y = SY(I)
  CURSOR OX + X, OY + Y
  IF I = HI THEN
    PRINT "O"
  ELSE
    PRINT "o"
  ENDIF
NEXT
RETURN


REM ========================
REM  FOOD
REM ========================

LABEL SPAWN_FOOD
REPEAT = 1
WHILE REPEAT = 1
  REM  RND#() returns [0,1)
  REM  Force int->real by adding 0.0
  FX = INT(RND#() * FLOAT#(W)) + 1
  FY = INT(RND#() * FLOAT#(H)) + 1

  REPEAT = 0
  FOR I = TI TO HI
    IF SX(I) = FX AND SY(I) = FY THEN REPEAT = 1
  NEXT
WEND

CURSOR OX + FX, OY + FY
COLOR 4:PRINT "*":COLOR 7
RETURN


REM ========================
REM  INPUT
REM ========================

LABEL HANDLE_KEY
REM  Quit
IF K=K_Q OR B=B_F THEN END

REM  Prevent reverse direction
IF (K=K_W OR B=B_U) AND DIR != 3 THEN DIR = 1
IF (K=K_A OR B=B_L) AND DIR != 4 THEN DIR = 2
IF (K=K_S OR B=B_D) AND DIR != 1 THEN DIR = 3
IF (K=K_D OR B=B_R) AND DIR != 2 THEN DIR = 4
RETURN


REM ========================
REM  GAME STEP
REM ========================

LABEL STEP_MOVE
GAMEOVER = 0

HX = SX(HI) : HY = SY(HI)
NX = HX      : NY = HY

IF DIR = 1 THEN NY = HY - 1
IF DIR = 2 THEN NX = HX - 1
IF DIR = 3 THEN NY = HY + 1
IF DIR = 4 THEN NX = HX + 1

REM  Wall collision
IF (NX < 1) OR (NX > W) OR (NY < 1) OR (NY > H) THEN GAMEOVER = 1 :RETURN

REM  Self collision
FOR I = TI TO HI
  IF (SX(I) = NX) AND (SY(I) = NY) THEN GAMEOVER = 1 : RETURN
NEXT

REM  Move head forward
OLDHI = HI
HI = HI + 1
IF HI > MAXN THEN HI = 1
SX(HI) = NX : SY(HI) = NY

REM  Turn old head to body
CURSOR OX + SX(OLDHI), OY + SY(OLDHI)
PRINT "o"

EAT = 0
IF NX = FX AND NY = FY THEN EAT = 1

IF EAT = 1 THEN
  LE = LE + 1
  SCORE = SCORE + 10
  CURSOR 7,1
  COLOR 5
  PRINT SCORE; "   "
  COLOR 7

  GOSUB SPAWN_FOOD
ELSE
  REM  erase tail
  TX = SX(TI) : TY = SY(TI)
  CURSOR OX + TX, OY + TY
  PRINT " "

  TI = TI + 1
  IF TI > MAXN THEN TI = 1
ENDIF

REM  draw new head
CURSOR OX + NX, OY + NY
PRINT "O"

REM  crude speed control
FOR DLY = 1 TO 400
  DELAYMS 1
NEXT

RETURN


