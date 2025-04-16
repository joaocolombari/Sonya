function [sc, sci] = fitnessHSP(x)
% sc da o scores total e sci sao os valores parciais
warning('off', 'all');


global slash;
global simuladorltspice;
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
global GainMin; 
global SlewMin;
global LocutMin;
global HicutMin;
global PowW;
global THDMin;

% Pega dados do menu.m
%1
Gain= ParDados{1, 2};
GainMin = scoreAvPar(1, Gain);
%2
Slew= ParDados{2, 2};
SlewMin = scoreAvPar(1, Slew);
%3
Locut= ParDados{3, 2};
LocutMin = scoreAvPar(1, Locut);
%4
Hicut= ParDados{4, 2};
HicutMin = scoreAvPar(1, Hicut);
%5
Pow= ParDados{5, 2};
PowW= scoreAvPar(1, Pow);
%6
THD= ParDados{6, 2};
THDMin= scoreAvPar(1,THD);
%7
Tolerancia=ParDados{7,2};
%8
Peso=ParDados{8,2};
PesoTHD= scoreAvPar(1,Peso);

% denormaliza os genes
j=1;
for i=1:length(genesLB) 
    if (dif(i) ~= 0)
        xr(i)= (x(j)*dif(i)+genesLB(i));
        xe(i)= x(j);
        j=j+1;
    else
        xr(i)=genesLB(i);
        xe(i)=0;
    end;
    if (snap(i) ~= 0) xr(i) = round(xr(i)/snap(i))*snap(i);  end;
end;

disp ______________________________
cont=cont +1;
fprintf('simulacao = %d (sucesso = %d)\n', cont, contsuc);

% used parameters
for i = 1:length(xr)
    if (mod(i, 10) == 0) 
        fprintf('\n');
    end
    fprintf('X%i= %1.2f   ', i, xr(i));
end;    
fprintf('\n'); 

%%
% primeira simulacao: determina o ganho
ind=1;

% Gera o param
arq = fopen([circuito slash 'param'],'w');
paramAC(arq,xr);
fclose(arq);


% Executa a primeira simulacao 
[a, b] = system([simuladorltspice circuito slash ...
'circuito.sp >circuito.lis']);

% Captura resultados
simsucess=0;
% Primeiro AC
Meas = LeMeas1('circuito.ma0', 4);      % saidas do .meas ac
if(length(Meas) > 4)
    simsucess =1;
    maxac=Meas(1); minac=Meas(2); locut=Meas(3); hicut=Meas(4); 
    
% Reposta  
grave=abs(locut-maxac);
agudo=abs(hicut-maxac);
respfreq=maxac-minac;  % swing na resposta em frequencia (dB)
    
% Segundo Tran 0
Meas = LeMeas1('circuito.mt0', 7);      % saidas do .meas tran
if(length(Meas) > 16)
simsucess =2;
% Tensao 
maxv=Meas(1); minv=Meas(2);  rmsv=Meas(3);
% Corrente
maxi=Meas(4); mini=Meas(5);  rmsi=Meas(6);
% Harmonas
h1=Meas(7); h2=Meas(8); h3=Meas(9); h4=Meas(10); h5=Meas(1);
h6=Meas(12); h7=Meas(13); h8=Meas(14); h9=Meas(15);
% THD
if h1<=0.8
THDcir=Inf;
else 
THDcir=sqrt(h2^2+h3^2+h4^2+h5^2+h6^2+h7^2+h8^2+h9^2)/h1*100;
end
THDcirpeso=sqrt((h2*(2)^2/4)^2+(h3*(3)^2/4)^2+(h4*(4)^2/4)^2+(h5*(5)^2/4)^2+(h6*(6)^2/4)^2+(h7*(7)^2/4)^2+(h8*(8)^2/4)^2+(h9*9^2/4)^2)/(h1)*100;
    
% 
        
Ganho=20*log10(rmsv/(1.1/sqrt(2)));
OutPow=rmsv*rmsi;                         
        
% Segundo Tran 1 (slew)         % saidas .meas da segunda tran
Meas = LeMeas1('circuito.mt1', 4);
if(length(Meas) > 4)
simsucess=3;
            
% slew rate
slewrate=Meas(3); %V/s
            
% avaliacao
                
% Ganho Maximo
FGM = scoreAv(abs(Ganho), Gain);                
                
% Slew rate
FSL = scoreAv(slewrate*1e-6, Slew);     
                
% Output power
FOP = scoreAv(OutPow,Pow);         
                
% THD
FHD = scoreAv(THDcir,THD);      
                
% THD ponderado 
FPHD = scoreAv(THDcirpeso,Peso);    
                
% Resposta em dB
FFR = scoreAv(respfreq,Tolerancia);    
                
% Resposta grave
FRG = scoreAv(grave,Locut);       
                
% Resposta agudo
FRA = scoreAv(agudo,Hicut);      
                
%final score
sc = (FGM + FSL + FOP + FHD + FPHD + FFR + FRG + FRA)^2;
               
sci = [FGM FSL FOP FHD FPHD FFR FRG FRA];
                
contsuc= contsuc+1;
                
         
% Salva melhor solucao
if(Best.score > sc)

arq=fopen([circuito slash 'results' slash 'optimos.' modo namext],'a+');
fprintf(arq,'%d  %.3g\n', cont, sc);
fclose(arq);
beep;
Best.score = sc;
fprintf('\n*> ');
arq = fopen([circuito slash 'paramop' namext],'w');
% Aqui tem que ter infos do circuito E AS FUNCOES. 
fprintf(arq, '*Score=%.3g  Ganho=%.2gdB FGanho=%.2g SlewRate=%.2gV/us FSlewRate=%.2g OutputPower=%.2gW FOutputPower=%.2g \n', sc, Ganho, FGM,slewrate, FSL, OutPow, FOP);
fprintf(arq,'*THD=%.3g FTHD=%.3g PTHD=%.3g%% FPTHD=%.3g Variacao_em_freq=+-%.2gdB FVariacao_em_freq=+-%.2g \n', THDcir, FHD, THDcirpeso,FPHD, respfreq, FFR);
fprintf(arq,'*Variacao_grave=+-%.2gdB FVariacao_grave=+-%.2g Variacao_agudo=+-%.2gdB FVariacao_agudo=+-%.2g \r\n\n',grave, FRG, agudo, FRA);
paramAC(arq,xr);
% write the optimizations conditions
    fprintf(arq, '\r\n********************* %s ********************************************', datestr(now));
    for i=1:length(ParDados)
      fprintf(arq, '\r\n* %s: \t %s', ParDados{i, :});
    end;
%paramOpt(xr); %gera um arquivo de simulção que pode ser usado pelo usuário  
fclose(arq);
if(Best.scoreT > sc)
Best.scoreT = sc;
Best.parameters = xr;
xT = x;
arq = fopen([circuito slash 'paramopT' namext],'w');
fprintf(arq, '*Score=%.3g  Ganho=%.2gdB FGanho=%.2g SlewRate=%.2gV/us FSlewRate=%.2g OutputPower=%.2gW FOutputPower=%.2g \n', sc, Ganho, FGM,slewrate, FSL, OutPow, FOP);
fprintf(arq,'*THD=%.3g FTHD=%.3g PTHD=%.3g%% FPTHD=%.3g Variacao_em_freq=+-%.2gdB FVariacao_em_freq=+-%.2g \n', THDcir, FHD, THDcirpeso,FPHD, respfreq, FFR);
fprintf(arq,'*Variacao_grave=+-%.2gdB FVariacao_grave=+-%.2g Variacao_agudo=+-%.2gdB FVariacao_agudo=+-%.2g \r\n\n',grave, FRG, agudo, FRA);
paramAC(arq,xr);
% write the optimizations conditions
    fprintf(arq, '\r\n********************* %s ********************************************', datestr(now));
    for i=1:length(ParDados)
      fprintf(arq, '\r\n* %s: \t %s', ParDados{i, :});
    end;  
%paramOpt(xr) %gera um arquivo de simulção que pode ser usado pelo usuário
fclose(arq);
BestRes{modoind} = Best;
end
                    
% plot graphics
scorePlot(1, end+1) = cont;    scorePlot(2, end) = sc;
figure(711)
set(711, 'Name', [circuito ': Cont=' num2str(contopt, '%.1f') ...
', Best Score=' num2str(Best.scoreT, '%1.3g')], ...
'NumberTitle', 'off', 'MenuBar', 'none'); 
subplot(2, 1, 1);
semilogy(scorePlot(1, :), scorePlot(2, :), 'o');
title('score x cont');
subplot(2, 1, 2)
xp = [ x; xT]';
bar(xp, 'grouped');
title(['better parameters: score=' num2str(sc, '%1.3g')]);
pause(0.2);
end
               
% Resultados
fprintf('Score=%.3g  Ganho=%.2gdB FGanho=%.2g SlewRate=%.2gV/us FSlewRate=%.2g OutputPower=%.2gW FOutputPower=%.2g \n', sc, Ganho, FGM,slewrate, FSL, OutPow, FOP);
fprintf('THD=%.3g FTHD=%.3g PTHD=%.3g%% FPTHD=%.3g Variacao_em_freq=+-%.2gdB FVariacao_em_freq=+-%.2g \n', THDcir, FHD, THDcirpeso,FPHD, respfreq, FFR);
fprintf('Variacao_grave=+-%.2gdB FVariacao_grave=+-%.2g Variacao_agudo=+-%.2gdB FVariacao_agudo=+-%.2g \r\n',grave, FRG, agudo, FRA);
        end
    end
end

% problemas na simulacao
if (simsucess ~= 3)
sc = inf('double');
sci = [ inf('double')  inf('double')  inf('double') ...
inf('double')  inf('double')  inf('double') inf('double') ...
inf('double') inf('double') inf('double') inf('double') ...
inf('double') inf('double')];
    fprintf('Score=%.3g  \n',sc);
if (simsucess == 0)   
fprintf('Error  first simulation \n');
elseif (simsucess == 1)   
fprintf('Error  AC  \n');
fprintf('Graves=+-%.3gdB Agudos=+-%.3gdB \n', grave, agudo);
elseif (simsucess == 2)   
fprintf('Error Tran  \n');
fprintf('Graves=+-%.3gdB Agudos=+-%.3gdB \n', grave, agudo);
fprintf('Ganho=%.3g OutPow=%.3gW \n', Ganho, OutPow);
fprintf('THD=%2.4g%% PTHD=%2.4g%% \n', THDcir, THDcirpeso); 
     
  end;
end;

end

