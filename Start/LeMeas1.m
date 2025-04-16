function [M] =  LeMeas1(nome, n, flag) % pula n linha e le dois numeros, M1 e M2

 %arq = jmpline(arq);
 %arq = jmpline(arq);
 %arq = jmpline(arq);  % pula-se a tres linhas

M = [];
if exist(nome, 'file')
 arq = fopen(nome,'r');
 if (arq == -1)
     pause(0.05);
  %   fclose(arq);
      arq = fopen(nome,'r');
 end;
 for i=1:n
     fgets(arq);
 end;
 M=fscanf(arq,'%f');
 fclose(arq);
 if nargin > 2
    if flag == 1
        system(['del '  nome]);
    end;
 end;
end
end
