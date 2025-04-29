function [sc] = scoreAv(x, specif)
%--------------------------------------------------------------------------
% scoreAv - Evaluates a penalty score based on how a value `x` meets a
%           given specification string `specif`.
%
% Used in circuit optimization to measure how well a parameter satisfies
% design constraints (e.g., gain > 20 dB, THD < 1%).
%
% INPUTS:
%   x       - A numeric value or vector representing a measurement
%             (e.g., gain, power, THD).
%   specif  - A string that defines the performance requirement and scoring rule.
%             Format: [condition] [target] [weight(s)]
%
%             Supported condition types:
%               '> target weight'      → Penalize if x < target
%               '< target weight'      → Penalize if x > target
%               '= target weight'      → Penalize deviation from target
%               '/ factor weight'      → Proportional score (x/factor)*weight
%               'v min max w1 w2'      → Window: penalty if outside [min,max]
%               'V min max w1 w2 minv' → Window + hard lower bound
%               'w x1 y1 x2 y2 ... W'  → Piecewise-linear score, final weight
%
%             Optional prefix:
%               'Max', 'Min', 'Mea'    → Apply max, min, or mean to `x` vector
%
% OUTPUT:
%   sc      - The computed penalty score (≥ 0). A score of 0 means perfect
%             compliance. A higher score indicates a deviation from the spec.
%             In the case of 'V', it can return Inf for disqualifying values.
%
% EXAMPLES:
%   scoreAv(25, '> 20 1')       → Returns 0
%   scoreAv(15, '> 20 1')       → Returns 0.25
%   scoreAv(0.8, '< 1 2')       → Returns 0
%   scoreAv(1.2, '< 1 2')       → Returns 0.4
%   scoreAv([1 2 3], 'Max> 2 1')→ Returns 0, because max([1 2 3]) > 2
%
%--------------------------------------------------------------------------

pos1 = regexpi(specif, '[M]');
if  ~(isempty(pos1))
    model = specif(pos1:pos1+2);
    switch model
        case  { 'Max' ,  'max', 'MAX'}
            x=max(x);
         case   { 'Min' ,  'min', 'MIN'}
            x=min(x);
         case   { 'Mea' ,  'mea', 'MEA'}
            x=mean(x);
    end;
end;

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