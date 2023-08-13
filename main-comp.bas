REM : MAIN-COMP Program
   4 POKE 23658,8: RANDOMIZE : BORDER 0: INVERSE 0: PAPER 0: BRIGHT 1: CLEAR 57360: GO SUB 13: PRINT AT 20,0;: LOAD "ZAPCODE"CODE 
   5 CLS : PRINT INK 6; FLASH 1;AT 21,9;"STOP  THE TAPE"
   6 OVER 0: POKE 23606,17: POKE 23607,223
   7 INK 6: PRINT AT 11,2;"DO YOU WANT CREDITS? (Y OR N)"
   8 LET K$=INKEY$: IF K$<>"Y" AND K$<>"N" THEN GO TO 8
   9 BEEP .07,10: IF K$="N" THEN GO TO 12
  10 RANDOMIZE USR 65112: IF INKEY$<>"" THEN GO TO 10
  11 IF INKEY$="" THEN GO TO 11
  12 BEEP .02,0: CLS : LET GA=0: PRINT INK 6; FLASH 1;AT 21,9;"STOP  THE TAPE": GO TO 50
  13 INK 2: FOR B=77 TO 128 STEP 51: FOR A=0 TO 9
  15 PLOT B+A,107: DRAW 0,62: DRAW 19,0: DRAW 13,-3: DRAW 6,-8: DRAW 0,-14: DRAW -6,-8: DRAW -13,-3: DRAW -7,0: DRAW 14,-4: DRAW 8,-8: DRAW 4,-10: DRAW 8,-4
  35 NEXT A: NEXT B
  36 RETURN 
  50 OVER 0: GO SUB 13: OVER 1: INK 5: PRINT AT 9,5;"  REBELSTAR  RAIDERS ";AT 10,7;"BY JULIAN GOLLOP"
  60 PRINT AT 11,7;"ZAPCODE-M.STOCKWELL"; INK 4;AT 12,7;"Which  scenario?"
  70 PRINT INK 6;AT 13,7;"1.Moonbase";AT 14,7;"2.Starlingale";AT 15,7;"3.The Final Assault";AT 16,7;"4.Expansion"
  77 PRINT INK 5; BRIGHT 1;AT 18,6;"SCENARIO IN MEMORY-";GA
 100 LET K$=INKEY$: IF CODE K$<49 OR CODE K$>52 THEN GO TO 100
 102 IF VAL K$=GA THEN GO SUB 7700: GO TO 200
 105 FOR A=0 TO 9: BEEP .017,10: NEXT A
 107 INK 6: PRINT OVER 0; FLASH 0;AT 21,9;"START THE TAPE"
 110 IF K$="1" THEN PRINT OVER 1;AT 13,7;"██████████": PRINT AT 20,0;: LOAD "MOONBASE" DATA F$()
 111 IF K$="2" THEN PRINT OVER 1;AT 14,7;"█████████████": PRINT AT 20,0;: LOAD "STARLING" DATA F$()
 112 IF K$="3" THEN PRINT OVER 1;AT 15,7;"███████████████████": PRINT AT 20,0;: LOAD "ASSAULT" DATA F$()
 115 IF K$="4" THEN PRINT OVER 1;AT 16,7;"███████████": PRINT AT 20,0;: LOAD "EXPANSION" DATA F$()
 121 LOAD "" DATA W$()
 122 LOAD ""CODE 
 123 LOAD "" DATA D$(): LOAD "" DATA Y$()
 124 LOAD "" DATA C$()
 125 LOAD "" DATA M$()
 126 LOAD "" DATA O$()
 127 LOAD "" DATA V(): IF V(12)=1 THEN MERGE ""
 128 POKE 23658,8: PAPER V(1): BRIGHT 0: INK 9: BORDER V(1): CLS : LOAD ""SCREEN$ 
 130 DIM Z$(100,18): LET CC=1: DIM X$(20,32)
 131 LET GA=VAL K$: GO SUB 6000
 140 DIM P$(91): LET P$(88)=CHR$ 1: LET P$(70)=CHR$ 2: LET P$(69)=CHR$ 3: LET P$(68)=CHR$ 4: LET P$(89)=CHR$ 5: LET P$(91)=CHR$ 6: LET P$(66)=CHR$ 7: LET P$(82)=CHR$ 8
 200 LET CM=8: LET NV=2: INK 8: BRIGHT 8: FLASH 8: PAPER 8: OVER 1: GO SUB 7500
 205 FOR G=1 TO V(7)
 210 PRINT AT 0,0;"GAME TURN=";G;AT 1,0;"GT.s LEFT=";V(7)-G
 215 PRINT AT 0,14;F$(1);" VPs=";V(9);AT 1,14;F$(2);" VPs=";V(10)
 217 IF V(3)=0 AND V(4)=0 THEN GO TO 240
 220 FOR L=V(2) TO V(3): FOR C=V(4) TO V(5)
 225 IF CODE O$(L-1,C+1)<81 AND CODE O$(L-1,C+1)<>0 THEN LET V(9)=V(9)+V(6): GO TO 240
 230 NEXT C: NEXT L
 240 IF V(8)=1 AND (V(9)>=V(11) OR V(10)>=V(11)) THEN GO TO 1000
 245 FOR P=1 TO 2: IF P=2 THEN GO SUB 9990: PRINT AT 0,7;F$(P);"  TURN"
 250 IF GA=2 AND P=2 AND G=4 THEN GO SUB 8000
 251 FOR A=P*80-79 TO P*80
 252 IF C$(A,14)=" " THEN GO TO 258
 256 LET C$(A,4)=C$(A,3)
 257 IF CODE C$(A,6)*5<=CODE C$(A,5) THEN LET C$(A,4)=CHR$ (CODE C$(A,3)/2)
 258 NEXT A
 259 GO SUB 9990: FLASH 8: BRIGHT 8: INK 8: PAPER 8: OVER 1: INVERSE 0: LET L=11: LET C=15
 260 GO SUB 2000
 265 IF CODE O$(L-1,C+1)>0 THEN GO SUB 2020
 267 IF INKEY$="0" THEN GO TO 310
 270 IF INKEY$="V" THEN GO SUB 5500
 300 GO TO 260
 310 FOR A=20 TO -20 STEP -10: BEEP .017,A: BEEP .017,A-4: BEEP .017,A-5: NEXT A: NEXT P
 999 NEXT G
1000 IF NV<>0 AND GA=2 THEN LET V(10)=V(10)+60: GO SUB 8600
1005 BORDER 0: PAPER 0: INK 6: BRIGHT 1: CLS 
1010 LET A$=F$(2): IF V(9)>V(10) THEN LET A$=F$(1)
1015 PRINT AT 7,13;"WINNER:"
1020 PRINT AT 10,10;"▛▀▀▀▀▀▀▀▀▀▀▜";AT 11,10;"▌"; INVERSE 1;A$; INVERSE 0;"▐";AT 12,10;"▙▄▄▄▄▄▄▄▄▄▄▟"
1030 PRINT AT 14,5;"BY ";ABS (V(9)-V(10));AT 14,12;" VICTORY POINTS"
1050 PRINT AT 20,9;"ANOTHER  GAME?"
1055 FOR A=-60 TO 60: BEEP .017,A: NEXT A
1057 FOR A=60 TO -20 STEP -10: BEEP .02,A: BEEP .02,A-4: BEEP .02,A-7: NEXT A
1060 LET K$=INKEY$: IF K$<>"Y" AND K$<>"N" THEN GO TO 1060
1070 IF K$="Y" THEN CLS : GO TO 50
1900 STOP 
2000 LET K$=INKEY$: LET L=L+((K$="Z" OR K$="X" OR K$="C") AND L<21)-((K$="Q" OR K$="W" OR K$="E") AND L>2)
2005 LET C=C+((K$="E" OR K$="D" OR K$="C") AND C<31)-((K$="Q" OR K$="A" OR K$="Z") AND C>0)
2010 PRINT AT L,C;"█": BEEP .017,-15: PRINT AT L,C;"█": RETURN 
2020 LET N=CODE O$(L-1,C+1): LET W=CODE C$(N,10): PRINT OVER 0;AT 0,10;"Name:";C$(N,14 TO );AT 1,8;"Weapon:";W$(CODE C$(N,10),10 TO )
2025 LET K$=INKEY$: IF K$="" THEN PRINT AT L,C;"█": PAUSE 3: PRINT AT L,C;"█": PAUSE 8: GO TO 2025
2030 IF K$="I" THEN GO TO 2050
2035 IF K$="P" THEN GO TO 2070
2036 IF K$="S" THEN GO SUB 3000
2040 PRINT OVER 0;AT 0,0;"                                ";AT 1,8;"                 ": RETURN 
2050 GO SUB 9990: PRINT AT 0,0;C$(N,14 TO 24);" MPs=";CODE C$(N,4);"(";CODE C$(N,3);")";AT 0,22;"END=";CODE C$(N,6);"(";CODE C$(N,5);")"
2055 PRINT AT 1,0;"Skill=";CODE C$(N,7);AT 1,10;" Armour=";CODE C$(N,8);AT 1,22;"VPs=";CODE C$(N,9)
2063 FOR A=0 TO 7: BEEP .02,0: NEXT A
2065 IF INKEY$="" THEN GO TO 2065
2067 GO SUB 9990: RETURN 
2070 GO SUB 9990: PRINT AT 0,0;W$(W,10 TO );" Hit=";CODE W$(W,1)+(CODE W$(W,6)*CODE C$(N,7));"%";AT 0,19;"MP.cost=";CODE W$(W,2);"%"
2075 PRINT AT 1,0;"Close=";CODE W$(W,3);AT 1,9;"Range=";CODE W$(W,4);"(";CODE W$(W,5);")";AT 1,22;"Rounds=";CODE W$(W,7)-CODE C$(N,11)
2077 FOR A=0 TO 7: BEEP .02,-10: NEXT A
2080 IF INKEY$="" THEN GO TO 2080
2090 GO SUB 9990: RETURN 
3000 IF (N<81 AND P=2) OR (N>80 AND P=1) THEN RETURN 
3005 FOR A=0 TO 15: BEEP .016,A: NEXT A
3007 GO SUB 9990: PRINT AT 0,0;"MOVEMENT POINTS LEFT=";CODE C$(N,4)
3010 LET L1=L: LET C1=C: GO SUB 9950: GO SUB 9900
3011 LET Q=CODE C$(N,4): IF Q<=0 THEN FOR A=15 TO 0 STEP -1: BEEP .017,A: NEXT A: GO SUB 9990: RETURN 
3013 IF D=32 AND K$<>"" THEN GO TO 5000
3016 IF K$="" OR D=32 THEN PRINT AT L1,C1;C$(N,1): BEEP .01,10: PRINT AT L1,C1;C$(N,1): LET L=L1: LET C=C1: GO TO 3010
3017 BEEP .015,5
3018 LET MC=CODE M$(L1-1,C1+1,D)
3020 IF MC=0 THEN FOR A=0 TO 8: BEEP .02,20: BEEP .02,24: NEXT A: GO SUB 9990: GO TO 5018
3021 LET S=0: IF CODE O$(L-1,C+1)>0 THEN GO SUB 3060
3022 IF S=1 THEN LET S=0: LET L=L1: LET C=C1: GO TO 3010
3025 IF Q*2<MC THEN GO SUB 9990: PRINT AT 0,3;"NOT ENOUGH MOVEMENT POINTS": BEEP .5,-20: GO SUB 9990: GO TO 5019
3030 LET Q=Q-MC: IF Q<0 THEN LET Q=0
3035 PRINT OVER 0;AT 0,21;Q;" ": LET C$(N,4)=CHR$ Q
3040 POKE 22528+L1*32+C1,(CODE y$(L1-1,C1+1)): PRINT AT L1,C1;C$(N,1)
3045 PRINT INK (CODE C$(N,2));AT L,C;C$(N,1)
3047 LET O$(L1-1,C1+1)=CHR$ 0: LET O$(L-1,C+1)=CHR$ N
3050 GO TO 3010
3060 LET S=1: LET E=CODE O$(L-1,C+1)
3065 LET A=0: IF E>80 AND P=2 OR E<81 AND P=1 THEN BEEP .02,0: LET L=L1: LET C=C1: RETURN 
3067 IF CODE C$(N,4)=0 THEN GO SUB 9990: RETURN 
3070 LET L2=L: LET C2=C: LET L=L1: LET C=C1: FOR A=20 TO 10 STEP -1: BEEP .01,A: NEXT A
3085 LET MP=CODE C$(N,4): LET MC=(CODE W$(W,2)/100)*CODE C$(N,3)+(CODE M$(L1-1,C1+1,D)/2)-1
3090 LET F=1: IF MP<MC THEN LET F=MP/MC
3095 LET MP=MP-MC: IF MP<0 THEN LET MP=0:
3100 LET C$(N,4)=CHR$ INT (MP+.5)
3105 LET CH=F*(CODE W$(W,1)+(CODE C$(N,7)*CODE W$(W,6))-(CODE C$(E,7)*CODE W$(W,6)))
3106 GO SUB 9990: PRINT AT 0,0;"CHANCE TO HIT=";INT (CH+.5);"%";AT 0,20;"(";CODE C$(N,4);"=Move Pts)"
3110 IF RND*100>=CH THEN BEEP .1,-20: RETURN 
3112 LET X=CODE W$(W,3)+INT (RND*(CODE W$(W,3)+1))-CODE C$(E,8): IF X<1 THEN RETURN 
3115 GO SUB 3130
3120 RETURN 
3130 FOR A=1 TO X
3135 PRINT AT L2,C2;C$(E,1): BEEP .05,-10: PRINT AT L2,C2;C$(E,1)
3137 NEXT A
3140 LET Y=CODE C$(E,6)-X
3142 IF Y>=1 THEN LET C$(E,6)=CHR$ Y
3145 IF Y>=1 THEN LET C$(E,6)=CHR$ Y: RETURN 
3150 POKE 22528+L2*32+C2,(CODE Y$(L2-1,C2+1)): PRINT FLASH 0;AT L2,C2;C$(E,1)
3155 FOR A=40 TO -20 STEP -10: BEEP .02,A: BEEP .02,A-4: BEEP .02,A-6: NEXT A
3157 IF C$(E,14 TO 16)="Nav" THEN LET NV=NV-1
3158 IF c$(e,14 TO 17)="Main" THEN LET CM=CM-1
3159 IF CM=0 THEN LET V(9)=V(9)+80: GO TO 1000
3160 LET C$(E,4)=CHR$ 0: LET O$(L2-1,C2+1)=CHR$ 0
3165 IF E<81 THEN LET V(10)=V(10)+CODE C$(E,9)
3170 IF E>80 THEN LET V(9)=V(9)+CODE C$(E,9)
3175 RETURN 
3180 IF CODE W$(W,4)=0 OR CODE C$(N,11)>=CODE W$(W,7) THEN RETURN 
3182 BEEP .02,-5: GO SUB 9990: PRINT AT 0,0;"RANGED";AT 1,0;"COMBAT"
3185 LET L1=L: LET C1=C
3190 GO SUB 2000
3195 IF K$="S" THEN GO TO 3202
3197 IF K$="K" THEN BEEP .5,-10: LET L=L1: LET C=C1: GO SUB 9990: PRINT AT 0,0;"MOVEMENT": RETURN 
3200 GO TO 3190
3202 IF L=L1 AND C=C1 THEN GO TO 3190
3203 OVER 0: PLOT 0,0: DRAW 255,0: DRAW 0,159: DRAW -255,0: DRAW 0,-159: OVER 1
3205 LET L2=L: LET C2=C
3210 LET YN=(21-L1)*8+4: LET XN=C1*8+4
3215 LET YE=(21-L2)*8+4: LET XE=C2*8+4
3220 LET MP=CODE C$(N,4): LET MC=(CODE W$(W,2))/100*CODE C$(N,3)
3222 FOR Z=1 TO CODE W$(W,9)
3225 LET F=1: IF MC>MP THEN LET F=MP/MC
3227 IF MC<1 THEN LET MC=1
3230 LET MP=MP-MC: IF MP<0 THEN LET MP=0
3235 RANDOMIZE : LET C$(N,4)=CHR$ MP
3240 LET CH=F*(CODE W$(W,1)+CODE C$(N,7)*CODE W$(W,6)-15*(CODE C$(N,13)=1))
3245 GO SUB 9990: PRINT AT 0,0;"CHANCE TO HIT=";INT (CH+.5);"%"
3250 LET X3=XE-XN: LET Y3=YE-YN
3262 LET DF=RND*100: LET DF=DF-CH
3265 IF DF<=0 THEN LET DF=0: PRINT AT 1,0;"ON TARGET": GO TO 3270
3267 PRINT AT 1,0;"OFF TARGET"
3270 LET A=(DF*(SQR (X3*X3+Y3*Y3)))/50
3273 LET Y3=Y3+(RND*A-A/2)
3275 LET X3=X3+(RND*A-A/2)
3276 IF ABS X3<ABS Y3 THEN LET X3=X3/ABS Y3: LET Y3=Y3/ABS Y3*1
3277 IF ABS Y3<=ABS X3 THEN LET Y3=Y3/ABS X3: LET X3=X3/ABS X3*1
3280 LET CN=0: LET X4=XN: LET Y4=YN
3281 IF CODE W$(W,5)=0 THEN LET ST=255: GO TO 3283
3282 LET ST=(CODE W$(W,4)/(CODE W$(W,5)/40))/(SQR (X3*X3+Y3*Y3))
3289 PRINT AT L1,C1;C$(N,1)
3290 LET PL=0: IF POINT (XN,YN) THEN LET PL=1: PLOT XN,YN
3295 POKE 65361,0: POKE 65362,XN
3300 POKE 65363,0: POKE 65364,YN
3305 POKE 65365,127*X3: POKE 65366,127*Y3
3307 IF ST>255 THEN LET ST=255
3310 POKE 65367,ST
3315 RANDOMIZE USR 65135
3320 PRINT AT L1,C1;C$(N,1)
3322 IF PL=1 THEN PLOT XN,YN
3325 LET X5=PEEK 65362: LET Y5=PEEK 65364
3330 LET L5=21-(INT (Y5/8)): LET C5=INT (X5/8)
3332 IF CODE O$(L5-1,C5+1)>0 AND CODE W$(W,8)=1 THEN GO SUB 3350
3334 IF CODE W$(W,8)=2 OR CODE W$(W,8)=3 THEN GO SUB 3380
3335 GO SUB 9990: LET C$(N,11)=CHR$ (1+CODE C$(N,11))
3336 IF CODE C$(N,4)=0 THEN LET L=L1: LET C=C1: RETURN 
3337 IF C$(N,11)>=W$(W,7) THEN LET L=L1: LET C=C1: GO SUB 9990: PRINT AT 0,0;"NO MORE ROUNDS": FOR A=0 TO 7: BEEP .02,5: NEXT A: RETURN 
3338 PRINT AT 0,0;"ROUNDS LEFT=";CODE W$(W,7)-CODE C$(N,11);AT 1,0;"MOVEMENT POINTS LEFT=";CODE C$(N,4)
3340 NEXT Z: GO TO 3190
3350 LET E=CODE O$(L5-1,C5+1): PRINT AT L5,C5;C$(E,1)
3355 IF POINT (X5,Y5)=1 THEN PRINT AT L5,C5;C$(E,1): RETURN 
3360 PRINT AT L5,C5;C$(E,1)
3365 LET Y=CODE W$(W,4): LET X=Y+INT (RND*(Y+1))-CODE W$(W,5)/30*A-CODE C$(E,8)
3370 IF X>=1 THEN LET L2=L5: LET C2=C5: GO SUB 3130
3375 RETURN 
3380 LET Q=1: IF RND*20-V(12)<=CODE W$(W,4) THEN LET Q=0
3382 IF CODE W$(W,8)=3 THEN LET Q=1
3385 LET E=CODE O$(L5-1,C5+1): IF Q=0 THEN PRINT OVER 0;AT L5,C5;" ": IF E>0 THEN PRINT AT L5,C5;C$(E,1)
3390 RESTORE 3395: FOR Y=20 TO 2 STEP -2: READ A$: PRINT AT L5,C5;A$: BEEP .01,Y: NEXT Y
3395 DATA "Ⓠ","Ⓡ","Ⓠ","Ⓢ","Ⓡ","Ⓣ","Ⓢ","Ⓤ","Ⓣ","Ⓤ"
3400 IF E=0 THEN GO TO 3430
3410 LET Y=CODE W$(W,4): LET X=INT (RND*(Y+1))-CODE C$(E,8)+Y
3415 IF X>=1 THEN LET L2=L5: LET C2=C5: GO SUB 3130
3420 IF CODE C$(N,6)=0 THEN LET C$(N,4)=CHR$ 0
3430 IF Q=1 THEN RETURN 
3432 OVER 0: PLOT 0,0: DRAW 255,0: DRAW 0,159: DRAW -255,0: DRAW 0,-159: OVER 1
3435 LET Z$(CC,1)=CHR$ L5: LET Z$(CC,2)=CHR$ C5: FOR A=1 TO 8: LET Z$(CC,10+A)=M$(L5-1,C5+1,A): NEXT A: IF L>2 THEN LET M$(L5-1,C5+1,1)=CHR$ 2
3436 IF L>2 AND C<31 THEN LET M$(L5-1,C5+1,2)=CHR$ 3
3437 IF C<31 THEN LET M$(L5-1,C5+1,3)=CHR$ 2
3438 IF C<31 AND L<21 THEN LET M$(L5-1,C5+1,4)=CHR$ 3
3439 IF L<21 THEN LET M$(L5-1,C5+1,5)=CHR$ 2
3440 IF L<21 AND C>0 THEN LET M$(L5-1,C5+1,6)=CHR$ 3
3441 IF C>0 THEN LET M$(L5-1,C5+1,7)=CHR$ 2
3442 IF C>0 AND L>2 THEN LET M$(L5-1,C5+1,8)=CHR$ 3
3444 IF L5>2 THEN LET Z$(CC,3)=M$(L5-2,C5+1,5): LET M$(L5-2,C5+1,5)=CHR$ 3
3445 IF L5<21 THEN LET Z$(CC,4)=M$(L5,C5+1,1): LET M$(L5,C5+1,1)=CHR$ 3
3450 IF C5<31 THEN LET Z$(CC,5)=M$(L5-1,C5+2,7): LET M$(L5-1,C5+2,7)=CHR$ 3
3455 IF C5>0 THEN LET Z$(CC,6)=M$(L5-1,C5,3): LET M$(L5-1,C5,3)=CHR$ 3
3460 IF C5>0 AND L5>2 THEN LET Z$(CC,7)=M$(L5-2,C5,4): LET M$(L5-2,C5,4)=CHR$ 3
3465 IF C5<31 AND L5>2 THEN LET Z$(CC,8)=M$(L5-2,C5+2,6): LET M$(L5-2,C5+2,6)=CHR$ 3
3470 IF C5<31 AND L5<21 THEN LET Z$(CC,9)=M$(L5,C5+2,8): LET M$(L5,C5+2,8)=CHR$ 3
3475 IF C5>0 AND L5<21 THEN LET Z$(CC,10)=M$(L5,C5,2): LET M$(L5,C5,2)=CHR$ 3
3480 LET CC=CC+1: RETURN 
5000 IF K$="K" THEN RETURN 
5013 IF K$="I" THEN GO SUB 2050
5014 IF K$="P" THEN GO SUB 2070
5015 IF K$="F" THEN GO SUB 3180
5016 IF K$="V" THEN GO SUB 5500
5019 PRINT OVER 0;AT 0,0;"MOVEMENT POINTS LEFT=";CODE C$(N,4);" "
5020 LET L=L1: LET C=C1: GO TO 3010
5500 GO SUB 9990: IF V(8)=1 THEN PRINT AT 0,0;"VPs TO";AT 1,0;"WIN=";V(11): GO TO 5504
5503 PRINT AT 0,0;"GAME TURN";AT 1,0;G;" (";V(7)-G;")"
5504 PRINT AT 0,10;F$(1);" VPs=";V(9);AT 1,10;F$(2);" VPs=";V(10)
5505 FOR A=0 TO 9: BEEP .017,4: NEXT A
5510 IF INKEY$="" THEN GO TO 5510
5520 GO SUB 9990: RETURN 
6000 FOR L=1 TO 20: LET X$(L)=O$(L): NEXT L
6025 RANDOMIZE USR 65100
6030 RETURN 
7500 PRINT AT 0,0;"DEPLOYMENT"
7505 FOR L=2 TO 21: FOR C=0 TO 31
7510 PRINT INK 8; PAPER CODE D$(L-1,C+1); FLASH 8; BRIGHT 8; OVER 1; INVERSE 1;AT L,C;"█"
7530 NEXT C: NEXT L
7532 INK 5: GO SUB 9990: INK 8: LET L=11: LET C=15
7534 PRINT AT 0,0;F$(2);" DEPLOYMENT": BEEP .7,-20: PAUSE 100: GO SUB 9990
7535 FOR B=80 TO 0 STEP -80
7537 IF B=0 THEN GO SUB 9990: PRINT AT 0,0;F$(1);" DEPLOYMENT": BEEP .7,-20: FOR A=1 TO 70: NEXT A: GO SUB 9990
7540 FOR A=1 TO 80
7542 IF CODE C$(A+B,13)=0 OR C$(A+B,14)=" " THEN GO TO 7590
7545 PRINT OVER 0;AT 0,2;"NAME> ";C$(A+B,14 TO );AT 1,0;"WEAPON> ";W$(CODE C$(B+A,10),10 TO )
7550 GO SUB 2000
7555 IF K$="S" THEN GO TO 7570
7560 GO TO 7550
7570 IF B=0 AND CODE D$(L-1,C+1)<>V(13) THEN BEEP .3,-20: GO TO 7550
7571 IF B=80 AND CODE D$(L-1,C+1)<>V(14) THEN BEEP .3,-20: GO TO 7550
7573 IF CODE O$(L-1,C+1)>0 THEN BEEP .3,-20: GO TO 7550
7575 POKE 22528+L*32+C,CODE Y$(L-1,C+1)
7580 PRINT INK (CODE C$(B+A,2));AT L,C;C$(B+A,1)
7582 LET O$(L-1,C+1)=CHR$ (A+B)
7585 BEEP .02,10
7590 NEXT A
7591 NEXT B
7592 FOR L=2 TO 21: FOR C=0 TO 31
7593 IF CODE O$(L-1,C+1)>0 THEN GO TO 7600
7595 POKE 22528+L*32+C,CODE Y$(L-1,C+1)
7600 NEXT C: NEXT L
7605 GO SUB 9990: RETURN 
7700 RANDOMIZE USR 65112
7710 FOR L=1 TO 20: LET O$(L)=X$(L): NEXT L
7711 FOR A=CC-1 TO 1 STEP -1
7712 LET L=CODE Z$(A,1): LET C=CODE Z$(A,2): FOR B=1 TO 8: LET M$(L-1,C+1,B)=Z$(A,10+B): NEXT B
7713 IF L>2 THEN LET M$(L-2,C+1,5)=Z$(A,3)
7714 IF L<21 THEN LET M$(L,C+1,1)=Z$(A,4)
7715 IF C<31 THEN LET M$(L-1,C+2,7)=Z$(A,5)
7716 IF C>0 THEN LET M$(L-1,C,3)=Z$(A,6)
7717 IF C>0 AND L>2 THEN LET M$(L-2,C,4)=Z$(A,7)
7718 IF C<31 AND L>2 THEN LET M$(L-2,C+2,6)=Z$(A,8)
7719 IF C<31 AND L<21 THEN LET M$(L,C+2,8)=Z$(A,9)
7720 IF C>0 AND L<21 THEN LET M$(L,C,2)=Z$(A,10)
7725 NEXT A: LET CC=1
7749 LET V(9)=0: LET V(10)=0
7750 FOR A=1 TO 160
7760 IF C$(A,14)=" " THEN GO TO 7780
7770 LET C$(A,4)=C$(A,3)
7772 LET C$(A,6)=C$(A,5)
7774 LET C$(A,11)=CHR$ 0
7780 NEXT A
7790 RETURN 
8000 GO SUB 9990: PRINT AT 0,0;"RAIDER REINFORCEMENT"
8010 LET A=106
8020 FOR L=11 TO 12: FOR C=0 TO 3
8030 PRINT INK 6; OVER 0;AT L,C;C$(A,1)
8040 LET O$(L-1,C+1)=CHR$ A
8050 LET A=A+1
8060 NEXT C: NEXT L
8070 BEEP .02,10: GO SUB 9990: RETURN 
8600 PRINT AT 11,6;"▛": BEEP .02,0: PRINT AT 12,6;"▙": BEEP .02,0
8605 OVER 0: PAPER 0: FOR L=9 TO 14: FOR C=0 TO 5: PRINT AT L,C;" ": NEXT C: NEXT L
8607 FOR L=2 TO 4: FOR C=0 TO 3: PRINT AT L,C;" ": NEXT C: NEXT L
8610 FOR L=21 TO 19 STEP -1: FOR C=0 TO 3: PRINT AT L,C;" ": NEXT C: NEXT L
8615 FOR L=5 TO 18: FOR C=0 TO 1: PRINT AT L,C;" ": NEXT C: NEXT L
8620 INK 6: BRIGHT 1: FOR A=0 TO 80 STEP 80: FOR Y=31+A TO 48+A STEP 2: PLOT 20,Y: DRAW -(10-ABS (Y-39-A)),0: NEXT Y: NEXT A
8630 FOR A=0 TO 31
8635 RANDOMIZE USR 65083
8636 RANDOMIZE USR 65083
8637 RANDOMIZE USR 65083
8638 RANDOMIZE USR 65083
8640 RANDOMIZE USR 65060
8644 RANDOMIZE USR 65083
8645 RANDOMIZE USR 65083
8646 RANDOMIZE USR 65083
8647 RANDOMIZE USR 65083
8649 NEXT A
8700 RETURN 
9900 LET K$=INKEY$: LET L=L+((K$="Z" OR K$="X" OR K$="C") AND L<21)-((K$="Q" OR K$="W" OR K$="E") AND L>2)
9905 LET C=C+((K$="E" OR K$="D" OR K$="C") AND C<31)-((K$="Q" OR K$="A" OR K$="Z") AND C>0)
9950 LET D=32
9957 IF CODE K$<91 THEN LET D=CODE P$(CODE K$+1)
9960 RETURN 
9990 FOR A=0 TO 1: PRINT OVER 0; FLASH 0;AT A,0;"                                ": NEXT A: RETURN 