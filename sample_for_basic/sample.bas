1000 CLEAR1500,&HC000:DEFINTA-Z
1010 UA=&HD000:BLOAD"BGMDRV.BIN"
1020 DEFUSR9=UA+&H0 'U=USR9(1)'START BGM DRIVER
1030                'U=USR9(0)'END BGM DRIVER
1040 DEFUSR1=UA+&H3 'U=USR1(&HC000)'PLAY BGM (&HC000=BGM DATA)
1050 DEFUSR2=UA+&H6 'U=USR2(0)'STOP BGM
1060 DEFUSR3=UA+&H9 'U=USR3(&HC800)'PLAY SE (&HC800=SE DATA)
1070 DEFUSR4=UA+&HC 'U=USR4(1)'FADE OUT (WAIT=1)
1080 DEFUSR5=UA+&HF 'U=USR5(0)'IF U<>0 PLAYING NOW
1081 DEFUSR6=UA+&H12'U=USR6(1)'1=PAUSE/0=UNPAUSE
1082 DEFUSR7=UA+&H15'U=USR7(0)'IF U<>0 THEN PAUSE
1090 '
1100 A$="U=USR9(0)":KEY1,A$+CHR$(13)
1110 PRINT"'KEY1,"+CHR$(34)+A$+CHR$(34)+"'END BGM DRIVER":PRINT
1120 ON ERROR GOTO 1290:ON STOP GOSUB 1290:STOP ON
1130 U=USR9(1):PRINT"U=USR9(1)'START BGM DRIVER":PRINT
1140 '
1150 LA=&HC000:BLOAD"BGM02.BIN",LA:U=USR1(LA)'PLAY BGM
1160 '
1170 A=&HC800
1171 S1=A:GOSUB 5010 'SET SE1
1180 U=USR3(S1):PRINT"U=USR3(S1)'play SE1":PRINT
1181 S2=A:GOSUB 5010 'SET SE2
1190 TIME=0:FOR I=0 TO 1:I=-(TIME>60):NEXT
1200 U=USR3(S2):PRINT"U=USR3(S2)'play SE2":PRINT
1211 S3=A:GOSUB 5010 'SET SE3
1212 TIME=0:FOR I=0 TO 1:I=-(TIME>60):NEXT
1213 U=USR3(S3):PRINT"U=USR3(S3)'play SE3":PRINT
1210 '
1220 PRINT "SPACE=SE1 / ENTER=SE2 / ESC=PAUSE / OTHER=END"
1230 I$=INPUT$(1)
1240 IF I$=CHR$(32) THEN U=USR3(S1):GOTO 1230
1250 IF I$=CHR$(13) THEN U=USR3(S2):GOTO 1230
1251 IF I$=CHR$(27) THEN U=USR3(S3):PA=1-PA:U=USR6(PA):GOTO 1230
1260 U=USR4(4)'FADE OUT (WAIT=4)
1270 U=USR5(0):IF U THEN 1270
1280 '
1290 U=USR9(0)'TERMINATE BGM DIRVER
1300 ON ERROR GOTO 0:STOP OFF:END
1310 '
5000 'LOAD SE
5010 READ D:POKE A,D:A=A+1 'PRIORITY
5020 READ A$,D
5030 IF A$="FREQ" THEN POKE A,0:POKE A+1,D AND 255:POKE A+2,PEEK(VARPTR(D)+1):A=A+3:GOTO 5020
5040 IF A$="VOL"  THEN POKE A,1:POKE A+1,D:A=A+2:GOTO 5020
5050 IF A$="NOISE"THEN POKE A,2:POKE A+1,D:A=A+2:GOTO 5020
5060 IF A$="WAIT" THEN POKE A,3:POKE A+1,D:A=A+2:GOTO 5020
5070 IF A$="END"  THEN POKE A,4:A=A+1:RETURN
5080 ERROR 0:POKE A,4:A=A+1:RETURN
5090 '
5100 'SE1
5110 DATA 32 :'PRIORITY
5120 DATA "FREQ",&H8000 :'32768=TONE OFF
5130 DATA "VOL",13,"NOISE",&H80,"WAIT",0
5140 DATA "VOL",12,"NOISE",&H90,"WAIT",0
5150 DATA "VOL",11,"NOISE",&H91,"WAIT",0
5160 DATA "VOL",10,"NOISE",&H92,"WAIT",0
5170 DATA "VOL",9, "NOISE",&H93,"WAIT",0
5180 DATA "VOL",7, "NOISE",&H8A,"WAIT",0
5190 DATA "VOL",6, "NOISE",&H8C,"WAIT",0
5200 DATA "VOL",5, "NOISE",&H8F,"WAIT",0
5210 DATA "VOL",4, "NOISE",&H8C,"WAIT",0
5220 DATA "VOL",3, "NOISE",&H8A,"WAIT",0
5230 DATA "VOL",2, "NOISE",&H88,"WAIT",0
5240 DATA "VOL",1, "NOISE",&H84,"WAIT",0
5250 DATA "END",0
5260 'SE2
5270 DATA 64 :'PRIORITY
5280 DATA "VOL",10,"FREQ",&H6020,"WAIT",0
5290 DATA "VOL",9 ,"FREQ",&H6080,"WAIT",1
5300 DATA "VOL",8 ,"FREQ",&H6070,"WAIT",1
5310 DATA "VOL",7 ,"FREQ",&H6060,"WAIT",1
5320 DATA "VOL",6 ,"FREQ",&H6050,"WAIT",1
5330 DATA "VOL",5 ,"FREQ",&H6040,"WAIT",1
5340 DATA "VOL",4 ,"FREQ",&H6030,"WAIT",1
5350 DATA "VOL",3 ,"FREQ",&H6020,"WAIT",1
5360 DATA "VOL",2 ,"FREQ",&H6010,"WAIT",1
5370 DATA "VOL",1 ,"FREQ",&H6000,"WAIT",1
5380 DATA "END",0
5390 'SE3
5400 DATA 64 :'PRIORITY
5410 DATA "VOL",12,"FREQ",&H6000,"WAIT",0
5420 DATA "VOL",11,"FREQ",&H6010,"WAIT",0
5430 DATA "VOL",10,"FREQ",&H6020,"WAIT",0
5440 DATA "VOL",11,"FREQ",&H6010,"WAIT",0
5450 DATA "VOL",12,"FREQ",&H6000,"WAIT",0
5460 DATA "VOL",11,"FREQ",&H6010,"WAIT",0
5470 DATA "VOL",10,"FREQ",&H6020,"WAIT",0
5480 DATA "VOL",9,"FREQ",&H6080,"WAIT",0
5490 DATA "VOL",8,"FREQ",&H6090,"WAIT",0
5500 DATA "VOL",7,"FREQ",&H60A0,"WAIT",0
5510 DATA "VOL",8,"FREQ",&H6090,"WAIT",0
5520 DATA "VOL",9,"FREQ",&H6080,"WAIT",0
5530 DATA "VOL",8,"FREQ",&H6090,"WAIT",0
5540 DATA "VOL",7,"FREQ",&H60A0,"WAIT",0
5550 DATA "END",0
