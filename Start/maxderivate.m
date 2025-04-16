function [MAX indice] = maxderivate(x,y)   %encontra á maxima derivada, em módulo, do gráfico formado pelos pontos y e x

    aux = -Inf('double');
    auxi = 1;
    for i = 1:1:(numel(x)-1)
        derive = ( y(i+1) - y(i) ) / ( x(i+1) - x(i));
        if(abs(derive) > aux)
            aux = abs(derive);
            auxi = i;
        end
    end
    MAX = aux;
    indice = auxi;
end