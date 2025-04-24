function paramAC(circuito, x)

% Gera novo arquivo param.txt para o simulador SPICE
% com base no modelo Gagabiro Valve Power Amplifier

slash = filesep;

% Limpa arquivos antigos
if exist([circuito slash 'param.txt'], "file")
    system('del param.txt');
end

% Abre novo arquivo para escrita
arq = fopen([circuito slash 'param.txt'],'w');

% Cabeçalho
fprintf(arq,['***************************************\n' ...
'*** GAGABIRO VALVE POWER AMPLIFIER\t***\n' ...
'***\tAUTHOR:  JOAO CARLET\t\t\t***\n' ...
'*** CONTACT: JVCCARLET@USP.BR\t\t***\n' ...
'***************************************\n\n']);

% RESISTORES
fprintf(arq,'*RESISTORS\n');
for i = 1:18
    fprintf(arq,'.param      X%d = %g\n', i, x(i));
end

% CAPACITORES
fprintf(arq,'\n*CAPACITORS\n');
for i = 19:23
    fprintf(arq,'.param      X%d = %g\n', i, x(i));
end

% VOLTAGE SOURCES
fprintf(arq,'\n*VOLTAGE SOURCES\n');
for i = 23:25
    fprintf(arq,'.param      X%d = %g\n', i, x(i));
end

fclose(arq);
end
