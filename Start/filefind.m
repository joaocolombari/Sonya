function [M] = filefind(nome) % fun��o que recebe o arquivo em .printsw0 e o transforma em uma tabela, retornando
                                              % a tabela, o n�mero de linhas e o n�mero de colunas, respectivamente
                                              
M = [];
if exist(nome, 'file')
 arq = fopen(nome,'r');
 if (arq == -1)
     pause(0.05);
  %   fclose(arq);
      arq = fopen(nome,'r');
 end;

 ind=false;
 while ((~feof(arq))&&(~ind))   % esse while ir� verificar quantas linhas e colunas existem nessa tabela
    aux = fscanf(arq,'%s',1);
    ind=(strcmp(aux,sprintf('alter#')));
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