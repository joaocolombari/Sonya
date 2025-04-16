function [melhor] = EvNeu (fname, X0, numparam, numger, populacaoSize, populacao1, populacaoTr)

step =0.5;
red = 0.8;
populacao = rand(numparam, populacaoSize);
populacao(:, 1) = X0';
score = 10*ones(1, populacaoSize);
score(1, 1:populacao1) = 0;
melhor = [];
melhorscore = Inf( 'double'); 
populacaoT = [ ];
scoreT = [ ]; 

% initialize the network
net = newff(populacao, score, numparam);
%net.layers{1}.transferFcn = 'radbas';
net = init(net);
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.2;

% nova geracao 
 for i=1:numger
 stepin = 0;
    % avalia a nova populacao
     for j= 1:size(populacao, 2)
        score(j) = feval(fname, populacao(: , j)');
        if score(j) < melhorscore
            melhorscore = score(j);
            melhor = populacao(:, j);
            stepin = 1;
        end;  
        %log(score(j))
        %sim(net, populacao(:, j))
     end;
     
     if stepin  
          step = min(step/(red*red), 1);
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
  
  if size(populacaoT, 2) > populacaoTr
      populacaoT = populacaoT(:, 1:populacaoTr);
      scoreT= scoreT(1, 1:populacaoTr);
  end;  
 
   % treina se a populacao 
    net= train(net, populacaoT, log(scoreT));
    %log(scoreT);
    % pause
   
    fprintf('__________________ fim da %1.0f geracao           Melhor score: %3g  __________________\n\n ', i, melhorscore);
    fprintf('melhor: ');
    fprintf('%3.2g  ', melhor);
    fprintf('\n step: %3.2g', step);
    fprintf('\n\n ');
   % pause
    populacao = zeros(numparam, populacao1+1);
    score = inf(1, populacao1+1);
    
   % gera mais individuos para populacao

   for j=1:(100*numparam)
        ind = (rand(numparam, 1) - 0.5)*step;
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

  step = step*red;
  populacao = populacao(:, 1:populacao1);
  score = score(1, 1:populacao1);
  
 end;

end