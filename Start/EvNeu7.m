function [melhor] = EvNeu (fname, numparam, numger, populacaoSize,  populacao1, populacaoSob)

step =0.5;
red = 0.8;
populacao = rand(numparam, populacaoSize);
score = 10*ones(1, populacaoSize);
score(1, 1:populacao1) = 0;
melhor = [];
melhorscore = Inf( 'double'); 
populacaoT = [ ];
scoreT = [ ]; 

% initialize the network
net = newff(populacao, score, [numparam, numparam]);
net.layers{1}.transferFcn = 'radbas';
net = init(net);
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.2;

% nova geracao 
for i=1:numger
  
    % avalia a nova populacao
     for j= 1:size(populacao, 2)
        score(j) = feval(fname, populacao(: , j)');
        if score(j) < melhorscore
            melhorscore = score(j);
            melhor = populacao(:, j);
            step = min(step*2, 2);
        end;   
        %log(score(j))
        %sim(net, populacao(:, j))
     end;

 % junta novos membros a populacao

  populacaoT = [populacaoT, populacao];
  scoreT        = [scoreT, score];
  
 % ordena populacao e poe os melhores a partir da nova acrescentada 
  for j=(size(populacaoT, 2) - size(populacao, 2) + 1):size(populacaoT, 2)
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

   % treina se a populacao 
    net= train(net, populacaoT, log(scoreT));
    %log(scoreT);
    % pause
    populacao = zeros(numparam, populacao1+1);
    score = inf(1, populacao1+1);
 
   % gera mais individuos para populacao
   for j=1:4000
        ind = rand(numparam, 1)*step;
        ind = abs(rem(melhor + ind, 1));
        populacao(:, populacao1+1) = ind;
        score(populacao1+1) = sim(net, ind);
        t= populacao1+1;
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

  step=step*red;
  fprintf('__________________ fim da %1.0f geracao           Melhor score: %3g  __________________\n\n ', i, melhorscore);
  fprintf('melhor: ');
  fprintf(' %3.2g  ', melhor);
  fprintf('step: %3.2g', step);
  fprintf('\n\n ');

end;

end