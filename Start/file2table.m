function [table,row,column] = file2table(arq,number_jmpline) % função que recebe o arquivo em .printsw0 e o transforma em uma tabela, retornando
                                              % a tabela, o número de linhas e o número de colunas, respectivamente
                                              
i = 1;
j = 1;
row = 0;
column = 0;
if(number_jmpline ~= 0)
    for k = 0:1:(number_jmpline-1)
        arq = jmpline(arq); % pula-se a primeira linha, que contem a especificação da tabela
    end
end

while(~feof(arq))   % esse while irá verificar quantas linhas e colunas existem nessa tabela
    aux = fscanf(arq,'%c',1);
    if(strcmp(aux,sprintf(' ')))
        
        while(strcmp(aux,sprintf(' ')))
            aux = fscanf(arq,'%c',1);         
        end
        
        fseek(arq,-1,0);
        
    else
        if(strcmp(aux,sprintf('\r')))
            fseek(arq,1,0);
            row = row + 1; 
        else
            if(~isempty(aux))
               fseek(arq,-1,0);
               aux = fscanf(arq,'%s',1);
               if(row == 0)
                column = column + 1;
               end
            end
        
        end
    end
end

table = zeros(row,column);  %aloca-se a matriz "tabela"
frewind(arq);     % retorna ao começo do arquivo
for k = 0:1:(number_jmpline - 1)
arq = jmpline(arq); % pula-se a primeira linha, que contem a especificação da tabela
end
while(~feof(arq))   % esse while recuperará para a tabela os valores do arquivo
     aux = fscanf(arq,'%c',1);
     
     while(strcmp(aux,sprintf(' ')))
        aux = fscanf(arq,'%c',1);
        
        
                
     end
     if(strcmp(aux,sprintf('\r')))
        fseek(arq,1,0);
        %table(i,j) = cellstr('pula');
        j = 1;
        i = i+1; 
         
     else
         if(~isempty(aux))
            fseek(arq,-1,0);
            aux = fscanf(arq,'%s',1);
            table(i,j) = str2double(aux);
            j = j+1;
         end

     end
    
    
end


end
