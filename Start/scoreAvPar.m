function [par] = scoreAvPar(i, specif)

pos = regexpi(specif, '[=>vV</wW]');

model = specif(pos);
dados = str2num(specif(pos+1:end));
par = dados(i);

end