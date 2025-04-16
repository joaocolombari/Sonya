function [melhor] = EvNeu (fname, numparam, numger, populacaoSize,  populacao1, populacaoSob)

step =0.5;
red = 0.95;
populacao = rand(numparam, populacaoSize);
score = 10*ones(1, populacaoSize);
score(1, 1:populacao1) = 0;
melhor = [];
melhorscore = Inf( 'double'); 
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
iniciop=1;
i=1;
while (i <= numger)
  % avalia a populacao
  populacao

     for j= iniciop:size(populacao, 2)
        score(j) = feval(fname, populacao(: , j)');
        if score(j) < melhorscore
            melhorscore = score(j);
            melhor = populacao(:, j);
            step = max(step*2, 1);
       end;   
        %log(score(j))
        %sim(net, populacao(:, j))
     end;

% se nova populacao for grande entao acrescenta, ordena e treina
if (size(populacao, 2) > populacao1)  
 % junta novos membros a populacao
 i=i+1;
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
     log(scoreT)
    % pause
     melhor = populacaoT(:, 1);
    populacao = [];
     score = [ ];
end;   

% gera mais individuos para populacao
  iniciop = size(populacao, 2) +1;
  j = iniciop;
  conttent=0;
  while (conttent < 1000)
     ind = rand(numparam, 1);
     while (sim(net, ind) > (log(scoreT(populacaoSob))) && (conttent < 1000))
        ind = rand(numparam, 1)*step;
        ind = abs(rem(melhor + ind, 1));
        conttent= conttent+1;
     end;
    populacao(:, j) = ind;
    j=j+1;
  end;  
  step=step*red;
fprintf('__________________ fim da %1.0f geracao           Melhor score: %3g  __________________\n\n ', i, scoreT(1));
fprintf('melhor: ');
fprintf(' %3.2g  ', melhor);
fprintf('step: %3.2g', step);
fprintf('\n\n ');

end;

end