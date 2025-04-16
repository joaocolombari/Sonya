function [IM,Vdd,knee] = searchIV(nomearq) % função que descobre os valores de IM e Vdd respectivos, desde que exista um .printsw0 no diretório

    arq = fopen(nomearq,'r');
    IMVdd = file2table(arq,1);   % transforma a tabela de nomearq em uma tabela
    fclose(arq);
    for i = 1:1:(numel(IMVdd)/2)  % fazendo os vetores receberem os valores da tabela
        IM(i) = IMVdd(i,2);   
        Vdd(i) = IMVdd(i,1);
    end
    
        knee = searchknee(IM,Vdd); % encontra-se o ponto da curva no gráfico IM X Vdd, o qual é chamado de "knee" 
    
    
end