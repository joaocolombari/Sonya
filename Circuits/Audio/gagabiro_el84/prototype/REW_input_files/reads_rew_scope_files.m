% Nome do arquivo (troque pelo seu arquivo)
filename = 'test.txt';

% Abrir arquivo
fid = fopen(filename, 'r');
if fid == -1
    error('Erro ao abrir o arquivo.');
end

% Variáveis para armazenar dados
time = [];
channel = [];

% Ler linha por linha
while ~feof(fid)
    line = fgetl(fid);
    % Procurar linhas com dados numéricos (tempo e amplitude)
    if ~isempty(line) && ~startsWith(line, {'Scope','Trigger','Sample','Date','CH1','Time',' '})
        % Tentar extrair dois números da linha
        nums = sscanf(line, '%f %f');
        if length(nums) == 2
            time(end+1) = nums(1);
            channel(end+1) = nums(2);
        end
    end
end

fclose(fid);

% Plotar os dados
figure;
plot(time, channel, '-o');
xlabel('Tempo (s)');
ylabel('Amplitude (V)');
title('Sinal capturado pelo Escopo REW');
grid on;
