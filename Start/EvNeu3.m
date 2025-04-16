function [melhor] = EvNeu (fname, numparam, numger, populacaoSize,  populacao1, populacaoSob)

populacao = rand(numparam, populacaoSize);
score = zeros(1, populacaoSize);
classe = -0.8*ones(1, populacaoSize);

 for j= 1:populacao1
    classe(j) = 0.8;
  end;
  
% initialize the network
net = newff(populacao, classe, numparam);
net.layers{1}.transferFcn = 'tansig';
%net.layers{2}.transferFcn = 'tansig';
%net = init(net);
%net.trainParam.showWindow = 0;
%train(net, populacao, classe);
%pause
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.3;
net.divideParam.testRatio = 0.1;
%net.trainParam.epochs = 5;
iniav = 1;
for i=1:numger
  % avalia a populacao
     for j= iniav:populacaoSize
        score(j) = feval(fname, populacao(: , j)');
 %       adapt(net, populacao(: , j), log(score(j)));
     end;
 % evita que reavalie os elementos sobreviventes
     iniav = populacaoSob +1;
     
% ordena o conjunto 
   for j=2:populacaoSize
    t = j;
    while (t >1)
      if (score(t) < score(t-1))
          aux1 = populacao(:, t);  aux2 = score(t);
          populacao(:, t)  = populacao(:, t-1);  score(t) = score(t-1); 
          populacao(:, t-1)  = aux1; score(t-1) = aux2;
          t=t-1;
          
      else t = 0;    
      end;    
     end;
    end;
  melhor = populacao(:, 1);
  
% dar nota para treino da populacao

for j= 1:populacaoSize
    classe(j) = log(score(j));
  end;
 
  train(net, populacao, classe);
  classe
  populacao
  classe(1)
  pause
 % gera a nova populacao
  j = populacaoSob+1;
  while (j <= populacaoSize)
     ind = rand(numparam, 1);
     while (sim(net, ind) > classe(1)) 
        ind = rand(numparam, 1);
     end;
    populacao(:, j) = ind;
    j=j+1;
  end;    
fprintf('__________________ fim da %1.1f geracao. Melhor score: %3g  __________________\n\n ', i, score(1));
fprintf('%f  ', melhor);
fprintf('\n\n ');

end

end