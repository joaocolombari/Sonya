function [melhor] = EvNeu (fname, X0, numparam, numger, populacaoSize, populacao1, populacaoTr)

global ParDados
global pesos;

pesos = str2num(ParDados{12, 2});

step =0.5;
red = 0.8;
populacao = rand(numparam, populacaoSize);
populacao(:, 1) = X0';
score = 10*ones(6, populacaoSize);
score(:, 1:populacao1) = 0;
melhor = [];
melhorscore = Inf( 'double'); 
populacaoT = [ ];
scoreT = [ ]; 
scT = [ ];
sc =[];

% initialize the network
net = newff(populacao, score, numparam);
net.layers{1}.transferFcn = 'radbas';
net = init(net);
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.2;

% nova geracao 
 for i=1:numger
 stepin = 0;
    % avalia a nova populacao
     for j= 1:size(populacao, 2)
         %aux = score(:, j);
         [sc(j), score(:, j)] = feval(fname, populacao(: , j)');
        % score(:, j)
         %aux
        if sc(j) < melhorscore
            melhorscore = sc(j);
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
  scT             = [scT, sc];

  
 % ordena populacao e poe os melhores a partir da nova acrescentada 
  for j=(size(populacaoT, 2) - size(populacao, 2) + 1):size(populacaoT, 2)
    t = j;
    while (t >1)
      if (scT(t) < scT(t-1))
          aux1 = populacaoT(:, t);  aux2 = scoreT(:, t); aux3 = scT(t);
          populacaoT(:, t)  = populacaoT(:, t-1);  scoreT(:, t) = scoreT(:, t-1); scT(t) = scT(t-1);
          populacaoT(:, t-1)  = aux1; scoreT(:, t-1) = aux2; scT(t-1) = aux3;
          t=t-1;
        else t = 0;    
      end;    
    end;
  end;
  
  if size(populacaoT, 2) > populacaoTr
      populacaoT = populacaoT(:, 1:populacaoTr);
      scoreT= scoreT(:, 1:populacaoTr);
      scT = scT(1, 1:populacaoTr);
  end;  
  
   % treina se a populacao 
    net= train(net, populacaoT, scoreT);
    %log(scoreT);
    % pause
   
    fprintf('__________________ fim da %1.0f geracao           Melhor score: %3g  __________________\n\n ', i, melhorscore);
    fprintf('melhor: ');
    fprintf('%3.2g  ', melhor);
    fprintf('\n step: %3.2g', step);
    fprintf('\n\n ');
   % pause
    populacao = zeros(numparam, populacao1+1);
    sc = inf(1, populacao1+1);
    score = [];
   % gera mais individuos para populacao

   for j=1:2000
        ind = (rand(numparam, 1) - 0.5)*step;
        ind = abs(rem(melhor + ind, 1));
        populacao(:, populacao1+1) = ind;
        aval = sim(net, ind);
        score(:, populacao1+1) = aval;
        sc(populacao1+1) = (pesos(3)*aval(1) + pesos(2)*aval(2)  + pesos(1)*aval(3) + pesos(4)*aval(4) + pesos(5)*aval(5) + pesos(6)*aval(6))^2;
        t= populacao1+1;
        while (t >1)
         if (sc(t) < sc(t-1))
          aux1 = populacao(:, t);  aux2 = sc(t); aux3 = score(:, t);
          populacao(:, t)  = populacao(:, t-1);  sc(t) = sc(t-1); score(:, t) = score(:, t-1);
          populacao(:, t-1)  = aux1; sc(t-1) = aux2; score(:, t-1) = aux3;
          t=t-1;
           else t = 0;    
         end;    
        end;
   end;       

  step = step*red;
  populacao = populacao(:, 1:populacao1);
  sc = sc(1, 1:populacao1);
  score = score(:,  1:populacao1);
  
 end;

end