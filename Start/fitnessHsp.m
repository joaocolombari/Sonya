function [sc, sci] = fitnessHsp(x)
% sc da o scores total e sci sao os valores parciais
warning('off', 'all');

global modelo;
global modelsD;
global slash;
global simulador;
global simuladorRF;
global simuladorRFpar;
global circuito;
global ParDados
global genesLB;

global Best
global BestRes;
global scorePlot;
global xT;
global modoind;
global modo;
global dif;
global snap;
global cont;
global contsuc;
global namext;
global contopt;
global const;

global Vdd;
global Vss;
global Cl;
global PhNBd;
global FreqV;
global HarNum;
global ModelosMult;
global VoltC;


Vdd = max(str2num(ParDados{1, 2}));
if (length(str2num(ParDados{1, 2})) == 2)
    Vss = min(str2num(ParDados{1, 2}));
else
    Vss = 0;
end
Cl= str2num(ParDados{2,2});
HarNum = str2num(ParDados{3,2});
PhNBd = str2num(ParDados{4,2});
VoltC = str2num(ParDados{5,2});
AmpOut = ParDados{6, 2};
MedOut = ParDados{7, 2};
FreqMax= ParDados{8, 2};
FreqMaxV = scoreAvpar(1, FreqMax);
FreqMin= ParDados{9, 2};
FreqMinV = scoreAvpar(1, FreqMin);
FreqV = (FreqMaxV+FreqMinV)/2;
CGain = ParDados{10, 2};
TCGain = ParDados{11, 2};
Pot = ParDados{12, 2};
THD = ParDados{13, 2};
EH =  ParDados{14, 2};
if (length(ParDados{15, 2}) > 0);
    MultModels = textscan(ParDados{15, 2}, '%s');
else MultModels= textscan(modelo, '%s');
end;
PhNoise = ParDados{16, 2};
Area = ParDados{17, 2};
FOM = ParDados{18, 2};
const = str2num(ParDados{19, 2});

% os parametros x (gerados) vao de 0 a 1;  a partir deles sao gerados os parametros xr para o arquivo de simulacao
%xr = x.*dif+genesLB;

j=1;
simsucess =0; 

% denormaliza os gens
for i=1:length(genesLB) 
    if (dif(i) ~= 0)
        xr(i)= (x(j)*dif(i)+genesLB(i));
        j=j+1;
    else xr(i)=genesLB(i);
    end;
    if (snap(i) ~= 0) xr(i) = round(xr(i)/snap(i))*snap(i);  end;
end;

% calculo de area do circuito .. nao ta sendo usado
cond = [circuito slash 'AreaCirMea.m'];
if exist(cond)
   eval(['cd ', circuito]);
   AreaMed = AreaCirMea(xr);
   eval('cd ..');
else AreaMed = 0;
end;

disp ______________________________
cont=cont +1;
fprintf('simulação = %d (sucesso = %d)\n', cont, contsuc);
% used parameters
for i = 1:length(xr)
    if (mod(i, 10) == 0) 
        fprintf('\n');
    end
    fprintf('X%i= %1.2f   ', i, xr(i));
end;    
fprintf('\n'); 

% primeira simulacao: determina o ganho
ind=1;
NumModel =length(MultModels{1});
param_mod_HSP([circuito slash 'param'], xr);
 
for i=1:NumModel;
 modelsim = MultModels{1}(i); 
 arq = fopen([circuito slash 'circuito' num2str(i) '.sp']  ,'w');
 fprintf(arq, '* Circuito Completo \r\n\r\n');
 fprintf(arq, '.include ..%s..%s%s%s%s\r\n', slash, slash, modelsD, slash, modelsim{1});
 fprintf(arq, '.include circuito.sp \r\n');
 if exist([circuito slash 'ring' num2str(xr(length(xr)))], 'file');
     fprintf(arq, '.include ring%s \r\n', num2str(xr(length(xr))));
 end;
 fprintf(arq, '.end');
 fclose(arq);
 % executa a simulacao
 [a1, b] = system ([simuladorRFpar circuito slash 'circuito' num2str(i) '.sp -o saida' num2str(i)]);
 end;

%modelsim ='modeltsmc65_ff'; 
%param_mod_HSP([circuito slash 'param3'], xr, modelsim);
% executa a simulacao
%[a3, b3] = system ([simuladorRFpar circuito slash 'circuito3.sp -o saida3']);

% [~, b] = system (['START /Realtime/wait/min C:\synopsys\Hspice_A-2008.03\BIN\hspicerf.exe ' circuito '\circuito.sp']);
% verificar termino da execucao e nao seixar mais de 50seg. Matar e travar

HSexe=true;
timelimit=20;
tf=0;
ti = tic;
while ((tf<=timelimit)  && (HSexe))
    [a, b] = system('taskkill /F /IM DpAgent.exe /T');
    [a, b] = system('taskkill /F /IM WerFault.exe /T');
    [a, b] = system('tasklist /fi "imagename eq hspicerf.exe" /fo csv /nh');
    if (b(1) == 'I')
     HSexe = false;
    else 
     pause(0.005); 
     tf =toc(ti);
    end
end
if (tf > timelimit) 
    [a, b] =system('taskkill /IM "hspicerf.exe" /f /T'); 
end
 fprintf('simulation run time= %.2gseg \n', tf);

FFreqMax=0;  FFreqMin=0; FCGain=0; FTCGain=0;  FPot=0; FPhNoise=0; FMedOut=0; FAmpOut=0; FEH=0; FTHD=0; FFOMer = 0;
errosimul= false; VoltCm=0; FreqMm=0;

for j=1:NumModel
 % read the simulation results
MeasB =zeros(length(VoltC), 6+HarNum);
MeasP =zeros(length(VoltC), 3);
runTB=zeros(length(VoltC), 1); runTP=zeros(length(VoltC), 1); 

for i=1: length(VoltC);
 indice=num2str(i-1);
 aux=LeMeas1(['saida' num2str(j) '.msnf' indice], 3, 1);
 if length(aux) == (6+HarNum);
     runTB(i)=1;
     MeasB(i,:)=aux;
 end;
 aux=0;
 aux=LeMeas1(['saida' num2str(j) '.msnnoi' indice], 3, 1);
 if length(aux) == 3;
     runTP(i)=1;
     MeasP(i, :)=aux;
 end;

end;
simRes= min(runTB'*runTB, runTP'*runTP);
 fprintf('right results = %i \n', simRes);


% obtain the simulation results
if (simRes > 1)
  VoltCm = VoltC(1: simRes);
%  fprintf('usou o resultado \n\r');   
  FreqMt=MeasB(:, 1)/1.0e9;
  FreqG(:, j)=FreqMt;
  FreqM = FreqMt(1: simRes);
  % avoid equal frequences
  for k=1:(length(VoltCm)-1)
      for m=(k+1):length(VoltCm)
          if (FreqM(k) == FreqM(m))
              FreqM(k) = FreqM(k) + 1e-6*k;
              m = (length(VoltCm)+1);
          end;
      end;
  end;
  
 %ajustes para achar a tensao de controle que da a faixa de freq. 
  if FreqM(1) > FreqM(length(VoltCm))
      VoltCPl = min(VoltCm); VoltCLe = max(VoltCm);
  else VoltCPl = max(VoltCm); VoltCLe = min(VoltCm);
  end;
  VoltCFreqMax = VoltCLe;
  if FreqMaxV >= max(FreqM) 
      VoltCFreqMax = VoltCPl;
  elseif FreqMaxV > min(FreqM)
      VoltCFreqMax = interp1(FreqM', VoltCm, FreqMaxV, 'linear');
  end;
  VoltCFreqMin = VoltCPl;
  if FreqMinV <= min(FreqM) 
      VoltCFreqMin = VoltCLe;
  elseif FreqMinV < max(FreqM)
      VoltCFreqMin = interp1(FreqM', VoltCm, FreqMinV, 'linear');
  end;
  %fprintf('freq= %.5fGHz \n ',  FreqM);
  %fprintf('VoltCFreqMax = %.5fV  VoltCFreqMin = %.5fV \n', VoltCFreqMax, VoltCFreqMin);

  PotM=-MeasB(1:simRes, 2)/1.0e-6;
  VoutM=MeasB(1:simRes,3:HarNum+4);
  PhNoiseM= MeasP(1:simRes, 1);

% calcula o ganho na regiao de operacao do oscilador
 if (length(VoltCm) == 1)
   CGainM(j)= FreqM(1)/(Vdd - Vss);
   aux(1)= FreqM(1)/(Vdd-Vss); 
 else  
  if (VoltCFreqMax ~= VoltCFreqMin)
   CGainM(j) = abs((FreqMaxV - FreqMinV)/(VoltCFreqMax - VoltCFreqMin));
   else
      CGainM(j)= abs((max(FreqM) - min(FreqM))/(max(VoltCm) - min(VoltCm)));
  end
% calcula o ganho por intervalo
  for i=1: length(VoltCm)-1;
   aux(i)= abs((FreqM(i) - FreqM(i+1))/(VoltCm(i) - VoltCm(i+1)));
  end;
 end;
 
 TCGainM(j)=max(aux);
  
% find the THD, EHD and OHD from the measurements
  EHaux =zeros(length(VoltCm), 1); OHaux=zeros(length(VoltCm), 1);
  for i=3:(HarNum+2)
       if mod(i, 2) == 1
          EHaux = EHaux + VoutM(:, i).*VoutM(:,i);
          else OHaux = OHaux + VoutM(:,i).*VoutM(:,i);
       end;    
  end;

  THaux=EHaux+OHaux+VoutM(:, 2).*VoutM(:, 2);  

% find the ratio
  THDaux=100*sqrt((EHaux+OHaux)./THaux);
  %interp1(VoltCm', THDaux, VoltCFreqMax, 'linear')
  %interp1(VoltCm', THDaux, VoltCFreqMin, 'linear')
  THDM(j)= (interp1(VoltCm', THDaux, VoltCFreqMax, 'linear') + interp1(VoltCm', THDaux, VoltCFreqMin, 'linear'))/2;
  FTHD = FTHD + scoreAv(THDM(j), THD);
  
  EHaux=100*sqrt(EHaux./THaux);
  %interp1(VoltCm', EHaux, VoltCFreqMax, 'linear')
  %interp1(VoltCm', EHaux, VoltCFreqMin, 'linear')
  EHM(j)= (interp1(VoltCm', EHaux, VoltCFreqMax, 'linear') + interp1(VoltCm', EHaux, VoltCFreqMin, 'linear'))/2;
  FEH = FEH + scoreAv(EHM(j), EH);
  
  FreqMaxM(j) = max(FreqM);
  FFreqMax = FFreqMax + scoreAv(FreqMaxM(j), FreqMax);
  FreqMinM(j)= min(FreqM);
  FFreqMin = FFreqMin + scoreAv(FreqMinM(j), FreqMin);
  FCGain = FCGain + (scoreAv(CGainM(j), CGain))^2;
  FTCGain = FCGain + (scoreAv(TCGainM(j), TCGain))^2;
  
  PotMM(j)= (interp1(VoltCm', PotM, VoltCFreqMax, 'linear') + interp1(VoltCm', PotM, VoltCFreqMin, 'linear'))/2;
  FPot = FPot + scoreAv(PotMM(j), Pot);
  
  PhNoiseMM(j)= (interp1(VoltCm', PhNoiseM, VoltCFreqMax, 'linear')+  interp1(VoltCm', PhNoiseM, VoltCFreqMin, 'linear'))/2;
  FPhNoise = FPhNoise + scoreAv(PhNoiseMM(j), PhNoise);
  
  MedOutM(j)= (interp1(VoltCm', VoutM(:, 1), VoltCFreqMax, 'linear') + interp1(VoltCm', VoutM(:, 1), VoltCFreqMin, 'linear'))/2;
  FMedOut = FMedOut + scoreAv(MedOutM(j), MedOut);
  
  AmpOutM(j)= (interp1(VoltCm', VoutM(:, 2), VoltCFreqMax, 'linear') + interp1(VoltCm', VoutM(:, 2), VoltCFreqMin, 'linear'));
  FAmpOut = FAmpOut + scoreAv(AmpOutM(j), AmpOut); 
  
  % Figure of Merit calculation
  FOMer(j) = (PhNoiseMM(j) + 10*log10(PotMM(j)/1e3) + -20*log10((FreqMaxM(j)+FreqMinM(j))*1e3/(2*PhNBd)));
  FFOMer = FFOMer + scoreAv(FOMer(j), FOM);
 else 
    j=NumModel+1;
    errosimul=true;
end;
end;
  if not(errosimul) 
  contsuc = contsuc + 1;    
  FEH=abs(FEH/NumModel); FTHD=abs(FTHD/NumModel); FPot=abs(FPot/NumModel); 
  FPhNoise=abs(FPhNoise/NumModel); FMedOut=abs(FMedOut/NumModel); FAmpOut=abs(FAmpOut/NumModel);
  FFreqMax = abs(FFreqMax/NumModel); FFreqMin = abs(FFreqMin/NumModel);  FCGain = sqrt(abs(FCGain))/NumModel;
  FTCGain = sqrt(abs(FTCGain))/NumModel; FFOMer = abs(FFOMer/NumModel);
      
  %Area
  FArea = scoreAv(AreaMed, Area);
  
%final score

sc =  (FFreqMax^2 + FFreqMin^2 + FCGain^2 + FTCGain^2 + FPot^2 + FMedOut^2 + FAmpOut^2 + FPhNoise^2 + FEH^2 + FTHD^2 +FArea^2 + FFOMer^2);
sci = [FFreqMax   FFreqMin   FCGain   FTCGain   FPot   FMedOut   FAmpOut   FPhNoise   FEH   FTHD  FArea  FFOMer];
fprintf('\n');

    % save the best solution
    if(Best.score > sc)
      arq = fopen([circuito slash 'results' slash 'optimos.' modo namext],'a+');
      fprintf(arq,'%d  %.3g\n', cont, sc);
      fclose(arq);
      arq = fopen([circuito slash 'results' slash 'optimosDet.' modo namext],'a+');
      fprintf(arq,'%d\n', cont);
fprintf(arq,'\r\n*Score=%.3g  Power=%.3guW_%.3guW  (FPower=%.2g) AmpOut=%.2gVpp_%.2gVpp (FAmpOut=%.2g) MedOut=%.2gV_%.2gV (FMedOut=%.2g) \r\n',sc, max(PotMM),  min(PotMM), FPot, max(AmpOutM), min(AmpOutM), FAmpOut, max(MedOutM), min(MedOutM), FMedOut);
fprintf(arq,'Area=%.2gum2 (Farea=%.2g) FreqMax=%.3gGHz_%.3gGHz (FFreqMax=%.2g)  FreqMin=%.3gGHz_%.3gGHz (FFreqMin=%.2g) CGain=%.2gGHz/V_%.2gGHz/V (FCGain=%.2g) \r\n', AreaMed, FArea, max(FreqMaxM), min(FreqMaxM), FFreqMax, max(FreqMinM), min(FreqMinM), FFreqMin, max(CGainM), min(CGainM), FCGain) ;
fprintf(arq,'TCGain=%.2gGHz/V_%.2gGHz/V (FTCGain=%.2g) PhNoise=%.3gdBc_%.3gdBc (FPhNoise=%.2g) EH=%.2g%%_%.2g%% (FEH=%.2g) THD=%.2g%%_%.2g%% (FTHD=%.2g) FOM=%.3gdb_%.3gdb FFOM=%.2g\r\n', max(TCGainM), min(TCGainM), FTCGain, max(PhNoiseMM), min(PhNoiseMM), FPhNoise, max(EHM), min(EHM), FEH, max(THDM), min(THDM), FTHD, max(FOMer), min(FOMer), FFOMer );
fprintf(arq,'( ');  
      for i = 1:length(x)
        fprintf(arq,'%1.3f  ', xr(i)); 
      end;    
      fprintf(arq,')\r\n\r\n');  
      fclose(arq);
      
      beep;
      Best.score = sc;
      fprintf('*> ');
      arq = fopen([circuito slash 'paramop' namext],'w');
fprintf(arq,'\r\n*Score=%.3g  Power=%.3guW_%.3guW  (FPower=%.2g) AmpOut=%.2gVpp_%.2gVpp (FAmpOut=%.2g) MedOut=%.2gV_%.2gV (FMedOut=%.2g) \r\n',sc, max(PotMM),  min(PotMM), FPot, max(AmpOutM), min(AmpOutM), FAmpOut, max(MedOutM), min(MedOutM), FMedOut);
fprintf(arq,'*Area=%.2gum2 (Farea=%.2g) FreqMax=%.3gGHz_%.3gGHz (FFreqMax=%.2g)  FreqMin=%.3gGHz_%.3gGHz (FFreqMin=%.2g) CGain=%.2gGHz/V_%.2gGHz/V (FCGain=%.2g) \r\n', AreaMed, FArea, max(FreqMaxM), min(FreqMaxM), FFreqMax, max(FreqMinM), min(FreqMinM), FFreqMin, max(CGainM), min(CGainM), FCGain) ;
fprintf(arq,'*TCGain=%.2gGHz/V_%.2gGHz/V (FTCGain=%.2g) PhNoise=%.3gdBc_%.3gdBc (FPhNoise=%.2g) EH=%.2g%%_%.2g%% (FEH=%.2g) THD=%.3g%%_%.3g%% (FTHD=%.2g) FOM=%.3gdb_%.3gdb FFOM=%.2g\r\n', max(TCGainM), min(TCGainM), FTCGain, max(PhNoiseMM), min(PhNoiseMM), FPhNoise, max(EHM), min(EHM), FEH, max(THDM), min(THDM), FTHD, max(FOMer), min(FOMer), FFOMer );
      %gera um arquivo de simulção que pode ser usado peo usuário  
      modelsim ='modeltsmc65_tt'; 
      paramOpt(arq, xr, modelsim);    
      fclose(arq);
      if(Best.scoreT > sc)
         Best.scoreT = sc;
         Best.parameters = xr;
         xT = x;
         arq = fopen([circuito slash 'paramopT' namext],'w');
fprintf(arq,'\r\n*Score=%.3g  Power=%.3guW_%.3guW  (FPower=%.2g) AmpOut=%.2gVpp_%.2gVpp (FAmpOut=%.2g) MedOut=%.2gV_%.2gV (FMedOut=%.2g) \r\n',sc, max(PotMM),  min(PotMM), FPot, max(AmpOutM), min(AmpOutM), FAmpOut, max(MedOutM), min(MedOutM), FMedOut);
fprintf(arq,'*Area=%.2gum2 (Farea=%.2g) FreqMax=%.3gGHz_%.3gGHz (FFreqMax=%.2g)  FreqMin=%.3gGHz_%.3gGHz (FFreqMin=%.2g) CGain=%.2gGHz/V_%.2gGHz/V (FCGain=%.2g) \r\n', AreaMed, FArea, max(FreqMaxM), min(FreqMaxM), FFreqMax, max(FreqMinM), min(FreqMinM), FFreqMin, max(CGainM), min(CGainM), FCGain) ;
fprintf(arq,'*TCGain=%.2gGHz/V_%.2gGHz/V (FTCGain=%.2g) PhNoise=%.3gdBc_%.3gdBc (FPhNoise=%.2g) EH=%.2g%%_%.2g%% (FEH=%.2g) THD=%.3g%%_%.3g%% (FTHD=%.2g) FOM=%.3gdb_%.3gdb FFOM=%.2g\r\n', max(TCGainM), min(TCGainM), FTCGain, max(PhNoiseMM), min(PhNoiseMM), FPhNoise, max(EHM), min(EHM), FEH, max(THDM), min(THDM), FTHD, max(FOMer), min(FOMer), FFOMer );
 
         %gera um arquivo de simulção que pode ser usado peo usuário 
         paramOpt(arq, xr, modelsim);               
         fclose(arq);
         BestRes{modoind} = Best;
      end;
                    
 % plot graphics
      scorePlot(1, end+1) = cont;    scorePlot(2, end) = sc;
      figure(711)
      set(711, 'Name', [circuito ': Cont=' num2str(contopt, '%d') '  ContSuc=' num2str(contsuc, '%d') ', Best Score=' num2str(Best.scoreT, '%1.3g')], 'NumberTitle', 'off', 'MenuBar', 'none'); 
      subplot(3, 1, 1);
      semilogy(scorePlot(1, :), scorePlot(2, :), 'o');
      title('score x cont');
      subplot(3, 1, 2)
      xp = [ x; xT]';
      bar(xp, 'grouped');
      title(['better parameters: score=' num2str(sc, '%1.3g')]);
      subplot(3, 1, 3)
      plot(VoltC, FreqG(:, 1), '*:');
      title('Freq x VoltC');
      hold on;
      for i=2:NumModel
      plot(VoltC, FreqG(:, i), '*:');
      end
      hold off
     % pause(0.2);
end;

% performance results
fprintf('Score=%.3g  Power=%.3guW_%.3guW  (FPower=%.2g) AmpOut=%.2gVpp_%.2gVpp (FAmpOut=%.2g) MedOut=%.2gV_%.2gV (FMedOut=%.2g) \n',sc, max(PotMM),  min(PotMM), FPot, max(AmpOutM), min(AmpOutM), FAmpOut, max(MedOutM), min(MedOutM), FMedOut);
fprintf('Area=%.2gum2 (Farea=%.2g) FreqMax=%.3gGHz_%.3gGHz (FFreqMax=%.2g)  FreqMin=%.3gGHz_%.3gGHz (FFreqMin=%.2g) CGain=%.2gGHz/V_%.2gGHz/V (FCGain=%.2g) \n', AreaMed, FArea, max(FreqMaxM), min(FreqMaxM), FFreqMax, max(FreqMinM), min(FreqMinM), FFreqMin, max(CGainM), min(CGainM), FCGain) ;
fprintf('TCGain=%.2gGHz/V_%.2gGHz/V (TFCGain=%.2g) PhNoise=%.3gdBc_%.3gdBc (FPhNoise=%.2g) EH=%.2g%%_%.2g%% (FEH=%.2g) THD=%.2g%%_%.2g%% (FTHD=%.2g) FOM=%.3gdb_%.3gdb FFOM=%.2g\r\n', max(TCGainM), min(TCGainM), FTCGain, max(PhNoiseMM), min(PhNoiseMM), FPhNoise, max(EHM), min(EHM), FEH, max(THDM), min(THDM), FTHD, max(FOMer), min(FOMer), FFOMer);
 
   % problemas na simulacao
else sc = inf('double');
    sci = [ inf('double') inf('double') inf('double')  inf('double')  inf('double')  inf('double')  inf('double')  inf('double') inf('double') inf('double') inf('double') inf('double')];
    fprintf('\nScore=%.3g  \n\n',sc);
    j=4;
end;
 
warning('on', 'all');
    end
