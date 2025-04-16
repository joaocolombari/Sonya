 function [melhor] = EvNeu (fname, X0, numparam, numger, populacaoIni, populacao1, populacaoTr, layertype, neuronlayer)

% X0 is the initial condition;
% numparam is the number of parameters
% numger is the number of generations
% populacaoIni is the initial population size
% populacaoTr is train population size
% populacao1 the number of new individuos at each generation
% layertype: 'radbas' or 'tansig'
% neurolayer indicates howm many layers e neurons. Ex.:
% [numpara, numparam] two layers with numpar neurons
step =1.0;
red = 0.8;
populacao = rand(numparam, populacaoIni);
populacao(:, 1) = X0';
score = 10*ones(1, populacaoIni);
score(1, 1:populacao1) = 0;
melhor = inf(numparam, 1);
melhorscore = Inf( 'double'); 
populacaoT = [ ];
scoreT = [ ]; 

% initialize the network
net = newff(populacao, score, neuronlayer);
net.layers{1}.transferFcn = layertype;

net = init(net);
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.0;

% nova geracao 
for i=1:(numger+1)
  stpin = 0;
  base = melhor;
  % avalia a nova populacao
  for j= 1:size(populacao, 2)
    score(j) = feval(fname, populacao(: , j)');
    if (score(j) < melhorscore) 
      melhorscore = score(j);
      melhor = populacao(:, j);
      if (abs(populacao(:,j)-base) < (1-red)*step)
        disp('no change in step');
        else stpin=1;
      end;  
    end;  
  end;
     
      
  % verifica na populacao quem esta proximo
  populacaoAux = [];
  scoreAux     = [];

  for j=1:size(populacaoT, 2)
   if (abs(populacaoT(:,j)-melhor) < step/(red))
      populacaoAux = [populacaoAux, populacaoT(:, j)];
      scoreAux     = [scoreAux, scoreT(j)];
      end;  
  end;  

  populacaoT = [populacaoAux, populacao];
  scoreT     = [scoreAux, score];
  size(populacaoT, 2);
  
  if stpin  
   step = min(step/red, 1);
   else step=step*red;
  end;
  
  fprintf('\n__________________  inicio da %1.0f geracao   Melhor score: %3g  __________________\n\n ', i, melhorscore);
  fprintf('melhor: ');
  fprintf('%3.2g  ', melhor);
  fprintf('\n step: %3.2g', step);
  fprintf('\n\n ');

% treina se a populacao   
  net= train(net, populacaoT, log(scoreT));

% gera mais individuos para populacao
  populacao = zeros(numparam, populacao1+1);
  score = inf(1, populacao1+1);
  stepn = min((melhor(:)+step), 1) - max((melhor(:)-step), 0);
  inter = diag(stepn);

  for j=1:(100*numparam)
    ind = inter*rand(numparam, 1) + max((melhor(:)-step), 0);
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

  populacao = populacao(:, 1:populacao1);
  score = score(1, 1:populacao1);
  
 end;
end