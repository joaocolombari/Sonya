function [value] = scoreVal(specif)
% find an expected value for the parameter

pos = regexpi(specif, '[=>vV</wW]');

model = specif(pos);
dados = str2num(specif(pos+1:end));

switch model
    case {'<','>','=', '/'} 
     value = dados(1);
    case {'v','V'}
     value = (dados(2)+dados(1))/2;      
    case {'W', 'w'}
     value = dados(end-2);
end

end 
      
   