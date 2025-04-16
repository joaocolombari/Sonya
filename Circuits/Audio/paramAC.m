function paramAC(arq, x)
global slash;
global modelo;
global modelsD;
global CirOpDir;

% Limpa arquivos 
if exist('circuito.ma0') 
  system('del circuito.ma0');
end;
if exist('circuito.mt0') 
  system('del circuito.mt0');
end;
if exist('circuito.mt1') 
  system('del circuito.mt1');
end;
if exist('circuito.lis') 
  system('del circuito.lis');
end;

% Escreve novo 

fprintf(arq,'* * * * * * * * * * \n');
% da include do modelo de simulacaod
fprintf(arq, '.include %s%s%s%s%s\r\n',CirOpDir, slash, modelsD, slash, modelo);

% coloca os parametros
fprintf(arq,'.Param   ');
for i = 1:length(x)
    if (mod(i, 7) == 0) fprintf(arq,'\r\n.Param   ');
    end
    fprintf(arq,'X%i= %1.3f  ', i, x(i)); 
end;    
fprintf(arq,'\r\n');  
fprintf(arq,'* ( ');  
for i = 1:length(x)
    fprintf(arq,'%1.3f  ', x(i)); 
end;    

fprintf(arq,')\r\n');  
fprintf(arq,'\n\nV5 in 0 0 AC 1 SIN (0 1.1 1k)\n');

% Comandos de Execucao
fprintf(arq,'\n* * * * * * * * * * \n \n* COMANDOS \n \n* * * * * * * * * *\n\n');
fprintf(arq,'.param cond=0\n');
fprintf(arq,'.if (cond==0)\n');
fprintf(arq,'.TRAN 10u 1000ms START=990ms\n');
fprintf(arq,'.FOUR 1k V(OUT)\n');
fprintf(arq,'.AC DEC 100 0.1 100k\n');
fprintf(arq,'.FFT V(OUT) freq=1k fmin=1k fmax=9k np=1024 FORMAT=UNORM \n');
fprintf(arq,'*.PROBE TRAN V(OUT) V(N010) V(N023)\n');
fprintf(arq,'*.PROBE AC V(OUT) V(N010) V(N023)\n');

% Faz os comandos MEASURE

fprintf(arq,'\n* MEDIDAS\n');

% Tensao
fprintf(arq,'.MEASURE TRAN maxv max V(out)\n');
fprintf(arq,'.MEASURE TRAN minv min V(out)\n');
fprintf(arq,'.MEASURE TRAN rmsv RMS v(out) FROM=990ms TO=1000ms\n\n');

% Corrente
fprintf(arq,'.MEASURE TRAN maxi max I(Rout)\n');
fprintf(arq,'.MEASURE TRAN mini min I(Rout)\n');
fprintf(arq,'.MEASURE TRAN rmsi RMS I(Rout) FROM=990ms TO=1000ms\n\n');

% Frequencia
fprintf(arq,'.MEASURE AC maxac MAX vdb(out) FROM=0.1HZ TO=100KHZ\n');
fprintf(arq,'.MEASURE AC minac MIN vdb(out) FROM=20HZ TO=15KHZ\n');
fprintf(arq,'.MEASURE AC locut find vdb(out) AT=%i\n', 20);
fprintf(arq,'.MEASURE AC hicut find vdb(out) AT=%i\n\n', 15000);

% FFT
fprintf(arq,'.MEASURE FFT h1 find vm(out) AT=1k\n');
fprintf(arq,'.MEASURE FFT h2 find vm(out) AT=2k\n');
fprintf(arq,'.MEASURE FFT h3 find vm(out) AT=3k\n');
fprintf(arq,'.MEASURE FFT h4 find vm(out) AT=4k\n');
fprintf(arq,'.MEASURE FFT h5 find vm(out) AT=5k\n');
fprintf(arq,'.MEASURE FFT h6 find vm(out) AT=6k\n');
fprintf(arq,'.MEASURE FFT h7 find vm(out) AT=7k\n');
fprintf(arq,'.MEASURE FFT h8 find vm(out) AT=8k\n');
fprintf(arq,'.MEASURE FFT h9 find vm(out) AT=9k\n');
fprintf(arq,'.endif\n');

% Slew Rate
fprintf(arq,'\n.alter\n');
fprintf(arq,'.param cond=1\n');
fprintf(arq,'.TRAN 10u 10m\n');
fprintf(arq,'V5 in 0 PULSE (0 1.1 0 10p 10p 1m 2m)\n');
fprintf(arq,'.MEASURE TRAN MAXSLEW MAX V(OUT)\n');
fprintf(arq,'.MEASURE TRAN MINSLEW MIN V(OUT)\n');
fprintf(arq,'.MEASURE TRAN SLEW DERIV V(OUT) WHEN V(OUT)="(MAXSLEW+MINSLEW)/2"\n');

end
