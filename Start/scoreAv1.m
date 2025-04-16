function [sc] = scoreAv(x, specif)

pos = regexpi(specif, '[=>vV</wW]');

model = specif(pos);
dados = str2num(specif(pos+1:end));

switch model 
    
    case '<'
 % is use to weights, the first is for the left side
       if (length(dados) < 3)
           dados(3) = dados(2); dados(2) =0;
       end;
       sc = max([0 x*dados(2)/dados(1)  dados(3)*(x -dados(1))/abs(dados(1))+dados(2)]);

    case '>'
       sc = max(0, (dados(1)- x)/abs(dados(1)))*dados(2);
       
    case '='
       sc = (abs(dados(1)- x)/abs(dados(1)))*dados(2);    
    
    case '/'
        sc = (x/dados(1))*dados(2);
       
    case 'v'
% when there are two weights, the first is for the left side
       if (length(dados) < 4)
          dados(4) = dados(3);
       end;
% if the first limit is higher, invert with the second
       if (dados(1) > dados(2))
           aux = dados(1);
           dados(1) = dados(2); dados(2) = aux;
       end
       sc = max ([0, dados(3)*(dados(1) - x)/abs(dados(1)), dados(4)*(x - dados(2))/abs(dados(2))]);

    case 'V'
% when there are two weights, the first is for the left side
       if (length(dados) < 5)
          dados(5) = dados(4);
          dados(4) = dados(3);
       end;
% if the first limit is higher, invert with the second
       if (dados(1) > dados(2))
           aux = dados(1);
           dados(1) = dados(2); dados(2) = aux;
       end
       sc = max ([0, dados(3)*(dados(1) - x)/abs(dados(1)), dados(4)*(x - dados(2))/abs(dados(2))]);
       if x < dados(5)
         sc=Inf('double')
       end;

    case {'W', 'w'}
        i=1;
        nump = (length(dados) -1)/2;
        while ((i < nump) && (x > dados(2*i-1)))
          i=i+1;
        end;
        if( i == 1) 
          x1 = dados(1);   y1 = dados(2);   x2= dados(3);   y2= dados(4);
         else 
            x1 = dados(2*i-3);    y1 =  dados(2*i-2);     x2 = dados(2*i-1);      y2 = dados(2*i);
        end
        sc = y1 + (x-x1)*(y2-y1)/(x2-x1);
        sc = max(0, sc)*dados(nump*2+1);

end
end 