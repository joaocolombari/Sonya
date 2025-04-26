***************************************
*** GAGABIRO VALVE POWER AMPLIFIER 	***
***	AUTHOR:  JOAO CARLET			***
*** CONTACT: JVCCARLET@USP.BR		***
***************************************

*RESISTORS
R1 		0 		N023 	{int(X1)*1R}
R2 		N021 	V_PP 	{int(X2)*1R}
R3 		0 		N010 	{int(X3)*1R}
R4 		N008 	V_PP 	{int(X4)*1R}
R5 		N003 	V_PP 	{int(X5)*1R}
R6 		N009 	N017 	{int(X6)*1R}
R7 		V_in 	N017 	{int(X7)*1R}
R8 		N010 	N011 	{int(X8)*1R}
R9 		0 		N012 	{int(X9)*1R}
R14 	N019 	N020 	{int(X10)*1R}
R15 	N019 	0 		{int(X11)*1R}
R16 	N006 	N007 	{int(X12)*1R}
R17 	N022 	0 		{int(X13)*1R}
R18 	N009 	N006 	{int(X14)*1R}
R28 	V_grid 	N004 	{int(X15)*1R}
R29 	N015 	V_grid 	{int(X16)*1R}
R32 	N016 	N015 	{int(X17)*1R}
R33 	N005 	N004 	{int(X18)*1R}

*LOAD RESISTOR
Rload 	0 		out 	8

*CAPACITORS
C1 		N010 	N009 	{int(X19)*1u}
C2 		N017 	N019 	{int(X20)*1n}
C3 		N022 	0 		{int(X21)*1u}
C5 		N015 	N008 	{int(X22)*1u}
C6 		N004 	N003 	{int(X23)*1u}

*BIPOLARS
Q1 N013 N021 N023 	0 BC847C
Q4 N021 N023 0 		0 BC847C

*OUTPUT TRANSFORMER
XU1 N001 N002 V_PP N014 N018 out NC_01 0 PAT4002

*VALVES
XU2 N001 N002 N005 0 EL84
XU3 N018 N014 N016 0 EL84
XU6 N008 N011 N013 12AU7
XU7 N003 N012 N013 12AU7
XU8 V_PP N007 N009 12AU7
XU9 N006 N020 N022 12AU7

*SOURCES
V4 V_PP 0 {int(X24)}
V5 V_in 0 SINE(0 0.447 1k) AC 1
V1 V_grid 0 {int(X25)}

*COMMANDS
.ac dec 100 0.01 100meg
.probe v(out)
.meas AC f20hz find v(out) at=20
.meas AC f30hz find v(out) at=20
.meas AC f40hz find v(out) at=20
.meas AC f50hz find v(out) at=50.05
.meas AC f70hz find v(out) at=70
.meas AC f100hz find v(out) at=100
.meas AC f200hz find v(out) at=200
.meas AC f500hz find v(out) at=500
.meas AC f700hz find v(out) at=700
.meas AC f1000hz find v(out) at=1000
.meas AC f2000hz find v(out) at=2000
.meas AC f2122hz find v(out) at=2122
.meas AC f5000hz find v(out) at=5000
.meas AC f7000hz find v(out) at=7000
.meas AC f10000hz find v(out) at=10000
.meas AC f20000hz find v(out) at=20000

*INCLUDES
.include ./param
.model NPN NPN
.model PNP PNP
.lib C:\Users\Colombari\Documents\LTspiceXVII\lib\cmp\standard.bjt
.lib trafos.lib
.lib tube.lib
.lib tubes.lib
.backanno
.end
