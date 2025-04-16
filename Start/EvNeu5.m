function [melhor] = EvNeu (fname, numparam, numger, populacaoSize,  populacao1, populacaoSob)

step =0.5;
red = 0.8;
populacao = rand(numparam, populacaoSize);
score = 10*ones(1, populacaoSize);
score(1, 1:populacao1) = 0;

populacaoT = [ ];
scoreT = [ ]; 

% initialize the network
net = newff(populacao, score, numparam);
net.layers{1}.transferFcn = 'radbas';
%net.layers{2}.transferFcn = 'tansig';
net = init(net);
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.2;
%net.trainParam.epochs = 5;1, 

for i=1:numger
  % avalia a populacao
  populacao

     for j= 1:length(populacao(1, :))
        score(j) = feval(fname, populacao(: , j)');
        %log(score(j))
        %sim(net, populacao(:, j))
     end;

 % junta novos membros a populacao
  populacaoT = [populacaoT, populacao];
  scoreT        = [scoreT, score];
  
 % ordena populacao e poe os melhores a partir da nova acrescentada 
if (length(populacao(1, :)) > 0)
 for j=(length(populacaoT(1, :))-length(populacao(1, :))+1):length(populacaoT(1, :))
    t = j;
    while (t >1)
      if (scoreT(t) < scoreT(t-1))
          aux1 = populacaoT(:, t);  aux2 = scoreT(t);
          populacaoT(:, t)  = populacaoT(:, t-1);  scoreT(t) = scoreT(t-1); 
          populacaoT(:, t-1)  = aux1; scoreT(t-1) = aux2;
          t=t-1;
        else t = 0;    
      end;    
     end;
  end;
end; 
%classe = -0.8*ones(1, length(populacaoT));
%classe(1, 1:populacao1) = 0.8; 
   
     net= train(net, populacaoT, log(scoreT));
     log(scoreT)
    % pause

     melhor = populacaoT(:, 1);

 % gera a nova populacao
  j = 1;
  conttent=0;
  populacao = [];
  score = [ ];
  while ((j <= populacaoSize) && (conttent < 1000))
     ind = rand(numparam, 1);
     while (sim(net, ind) > (log(scoreT(populacaoSob))) && (conttent < 1000))
        ind = rand(numparam, 1)*step;
        ind = abs(rem(populacaoT(1:numparam, 1) + ind, 1));
        conttent= conttent+1;
     end;
    populacao(:, j) = ind;
    j=j+1;
  end;  
  step=step*red;
fprintf('__________________ fim da %1.1f geracao. Melhor score: %3g  __________________\n\n ', i, scoreT(1));
fprintf('%f  ', melhor);
fprintf('\n\n ');

end;

end