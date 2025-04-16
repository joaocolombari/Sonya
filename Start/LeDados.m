function [M] = LeDados(nome, n, word,  flag) % fun��o que recebe o arquivo em .printsw0 e o transforma em uma tabela, retornando
                                              % a tabela, o n�mero de linhas e o n�mero de colunas, respectivamente
                                              
M = [];
%determina se da o arquivo
if exist(nome, 'file')
 arq = fopen(nome,'r');
 if (arq == -1)
     pause(0.05);
  %   fclose(arq);
      arq = fopen(nome,'r');
 end;

%salta as linhas iniciais
 for i=1:n
     fgets(arq);
 end;
 
 ind=false;
 while ((~feof(arq))&&(~ind))   % esse while ir� verificar quantas linhas e colunas existem nessa tabela
    aux = fscanf(arq,'%s',1);
    ind=(strcmp(aux,sprintf(word)));
 end;
 
 M=fscanf(arq,'%f');
 fclose(arq);
% delete the file 
 if nargin > 3
    if flag == 1
        system(['del '  nome]);
    end;
 end;
end
end