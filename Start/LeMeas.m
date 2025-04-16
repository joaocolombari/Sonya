function [M] =  LeMeas(arq, n) % pula n linha e le dois numeros, M1 e M2

 %arq = jmpline(arq);
 %arq = jmpline(arq);
 %arq = jmpline(arq);  % pula-se a tres linhas
for i=1:n
 fgets(arq);
end;
 M=fscanf(arq,'%f');

end