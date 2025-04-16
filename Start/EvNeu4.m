function [melhor] = EvNeu (fname, numparam, numger, populacaoSize,  populacao1, populacaoSob)

populacao = rand(numparam, populacaoSize);
score = 10*ones(1, populacaoSize);
 for j= 1:populacao1
    score(j) = 1.0;
  end;

populacaoT = [ ];
scoreT = [ ]; 

% initialize the network
net = newff(populacao, score, [ numparam, numparam] );
%net.layers{1}.transferFcn = 'radbas';
%net.layers{2}.transferFcn = 'tansig';
net = init(net);
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.3;
net.divideParam.testRatio = 0.1;
%net.trainParam.epochs = 5;
iniav = 1;
for i=1:numger
  % avalia a populacao
     for j= iniav:populacaoSize
        score(j) = feval(fname, populacao(: , j)');
        log(score(j))
        sim(net, populacao(:, j))
     end;

  % treino da populacao com todos os elementos
      populacaoT = [populacao(:, iniav:populacaoSize), populacaoT];
      scoreT        = [score(:, iniav:populacaoSize), scoreT];
     %populacaoT
     %scoreT
      train(net, populacaoT, log(scoreT));
      %scoreT
      %pause
      
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

 % gera a nova populacao
  j = populacaoSob+1;
  while (j <= populacaoSize)
     ind = rand(numparam, 1);
     while (sim(net, ind) > score(1)) 
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