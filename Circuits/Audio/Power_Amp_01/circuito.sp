***AMPLIFICADOR DE POTENCIA VALVULADO

* * * * * * * * * * 
**OPTIONS 

.options NOMOD NOTOP numdgt=10 statfl=1 NXX Noelck=1 MEASFILE=1 NOTOP RUNLVL=1 dcon=1 ingold=1 Measdgt=8 *post=2
* Nomod (supress model output) NOPAGE (suppress page eject) numdgt (numero de digitos)
* Noelck bypass element checking *NOTOP supress element check *dcon desability auto conver
* ingold notacao cientifica *Measfile todos os dados num unico arquivo
* NXX stop echoing  *statfl supress .st0  *RUNLVL runs acurracy post=2 (saida grafica)

* * * * * * * * * * 
* NAO SEI QQ EH ISSO RSRS 

.model D D
.model NPN NPN
.model PNP PNP

* * * * * * * * * * 

.SUBCKT EL34X 1 2 3 4 
.PARAM 
+ MU=11 	EX=1.35 	KG1=650 
+ KG2=4200 	KP=60 		KVB=24
+ CCG=15P 	CPG1=1P 	CCP=8P 
+ RGI=1K 

RE1  7 0  1G      							* DUMMY SO NODE 7 HAS 2 CONNECTIONS
E1   7 0  VALUE='V(4,3)/KP*LOG(1+EXP((1/MU+V(2,3)/V(4,3))*KP))'		* E1 BREAKS UP LONG EQUATION FOR G1.
G1   1 3  VALUE='(PWR(V(7),EX)+(SGN(V(7))*PWR(V(7),EX)))/KG1*ATAN(V(1,3)/KVB)'
G2   4 3  VALUE='(EXP(EX*(LOG((V(4,3)/MU)+V(2,3)))))/KG2'
RCP  1 3  1G      							* FOR CONVERGENCE
C1   2 3  'CCG'   							* CATHODE-GRID 1
C2   1 2  'CPG1'  							* GRID 1-PLATE
C3   1 3  'CCP'  							* CATHODE-PLATE
R1   2 5  'RGI'   							* FOR GRID CURRENT
D3   5 3  DX      							* FOR GRID CURRENT
.MODEL DX D IS=1N RS=1 CJO=10PF TT=1N 
.ENDS EL34X

.SUBCKT X12AU7X 1 2 3 
.PARAM
+ MU=21.5 	EX=1.3 		KG1=1180 
+ KP=84 	KVB=300 	RGI=2000
+ CCG=2.3P  	CGP=2.2P 	CCP=1.0P  					

E1 7 0 VALUE='V(1,3)/KP*LOG(1+EXP(KP*(1/MU+V(2,3)/SQRT(KVB+V(1,3)*V(1,3)))))'
RE1 7 0 1G
G1 1 3 VALUE='(PWR(V(7),EX)+(SGN(V(7))*PWR(V(7),EX)))/KG1'
RCP 1 3 1G    								* TO AVOID FLOATING NODES IN MU-FOLLOWER
C1 2 3 'CCG'  								* CATHODE-GRID WAS 1.6P
C2 2 1 'CGP'  								* GRID-PLATE WAS 1.5P
C3 1 3 'CCP' 								* CATHODE-PLATE WAS 0.5P
D3 5 3 DX     								* FOR GRID CURRENT
R1 2 5 'RGI'  								* FOR GRID CURRENT
.MODEL DX D IS=1N RS=1 CJO=10PF TT=1N
.ENDS X12AU7X

* * * * * * * * * * 
* SEMICONDUTORES

* DIODO:
.model NSCW100X D 
+ Is=16.88n 	Rs=8.163 	N=9.626 
+ Cjo=42p 	Xti=20 		LEVEL=1 	
D1 N009 N017 NSCW100X

* Q1:
.model X2N3904X NPN
+ IS=1E-14 	VAF=100		Bf=300 
+ IKF=0.4 	XTB=1.5 	BR=4 
+ CJC=4E-12 	CJE=8E-12 	RB=20
+ RC=0.1 	RE=0.1 		TR=250E-9 
+ TF=350E-12 	ITF=1 		VTF=2 
+ XTF=3		*Vceo=40 	*Icrating=200m 
+ *mfg=NXP
Q1 N014 N019 N021 X2N3904X

* Q2:
.model X2N2907X PNP
+ IS=1E-14 	VAF=120 	BF=250 
+ IKF=0.3 	XTB=1.5 	BR=3 
+ CJC=8E-12     CJE=30E-12 	TR=100E-9 
+ TF=400E-12 	ITF=1 		VTF=2 
+ XTF=3 	RB=10 		RC=.3 
+ RE=.2  	*Vceo=40 	*Icrating=600m 	
+ *mfg=NXP
Q2 N020 N017 N015 X2N2907X

* * * * * * * * * * 

* RESISTORES 
R1 N025 N021 R1
R2 N025 N019 R2
R3 N019 0 R3
R4 0 N010 R4
R5 0 N011 R5
R6 N005 N001 R6
R7 N007 N001 R7
R8 N012 N006 R8
R9 N018 N012 R9
R10 in N024 R10
R11 in 0 R11
R12 0 N017 R12
R13 N015 N009 R13
Rout 0 OUT R14
R15 N020 N004 R15
R16 N026 N027 R16
R17 N027 OUT R17
R18 N027 0 R18

* CAPS
C1 N006 N005 C1
C2 N018 N007 C2
C3 N010 N009 C3

* TRAFO
L1 N013 N003 3.8182
L2 N003 N002 5.0614
L3 N016 N013 3.8182
L4 N022 N016 5.0614
L5 OUT 0 0.06458
k1 L1 L2 IDEAL
k2 L1 L3 IDEAL
K3 L1 L4 IDEAL
K4 L1 L5 IDEAL
K5 L2 L3 IDEAL
k6 L2 L4 IDEAL
k7 L2 L5 IDEAL
k8 L3 L4 IDEAL 
k9 L3 L5 IDEAL
k10 L4 L5 IDEAL

* FONTES
V1 N012 0 V1
V2 N013 0 V2
V3 N025 0 V3
V4 N001 0 V4

* PROBLEMAS

XU1 N005 N010 N014 X12AU7X
XU2 N007 N011 N014 X12AU7X
XU3 N001 N004 N009 X12AU7X
XU4 N020 N024 N026 X12AU7X
XU5 N002 N006 0 N003 EL34X
XU6 N022 N018 0 N016 EL34X


.param R1 = 'nint(X1)*1R'
.param R2 = 'nint(X2)*1R'
.param R3 = 'nint(X3)*1R'
.param R4 = 'nint(X4)*1R'
.param R5 = 'nint(X4)*1R'
.param R6 = 'nint(X5)*1R'
.param R7 = 'nint(X5)*1R'
.param R8 = 'nint(X6)*1R'
.param R9 = 'nint(X6)*1R'
.param R10 = 'nint(X7)*1R'
.param R11 = 'nint(X8)*1R'
.param R12 = 'nint(X9)*1R'
.param R13 = 'nint(X10)*1R'
.param R14 = 'nint(X11)*1R'
.param R15 = 'nint(X12)*1R'
.param R16 = 'nint(X13)*1R'
.param R17 = 'nint(X14)*1R'
.param R18 = 'nint(X15)*1R'
.param C1 = 'nint(X16)*1n'
.param C2 = 'nint(X16)*1n'
.param C3 = 'nint(X17)*1n'

.param V1 = 'nint(X18)*1V'
.param V2 = 'nint(X19)*1V'
.param V3 = 'nint(X20)*1V'
.param V4 = 'nint(X21)*1V'

.include param

* * * * * * * * * * 

.end
