global modo;
global nvars;
global genesLB;
global inicialSol;
global dif;
global snap;
global modoind;
global namext;
global cont;
global contsuc;
global circuito;
global family;
global slash;
global fitness;
global scorePlot;
global xT;
global Best;
global contopt;
global entrada;
global caminho;

contopt=1;
namext = '';
prompt={'Number of Runs (0 for Optimtool)','Max simulations (more than 1 run)','Extension of the output file', 'seed', 'mode', 'inicialSol', 'Neighborhood of initial solution'};
name='Algoritm Running';
numlines=1;
inicialSolstr = num2str(inicialSol);
defaultanswer={'1','4000', '', '', '2', num2str(inicialSol), '1.0   1.0'};
entrada=inputdlg(prompt,name,numlines,defaultanswer, 'on');
inicialSoln =  str2num(entrada{6,1});
vizinha = str2num(entrada{7,1});

% check if the dialog was answered
if (length(entrada) == 7)
 namext = entrada{3};
 system(['del ' circuito slash 'results' slash 'optimos.' modo namext]);
  system(['del ' circuito slash 'results' slash 'optimosDet.' modo namext]);
 %profile on;
 profview = 0;

 cd ([caminho slash 'Circuits' slash family]);
 [a, b] = system([ 'del ' circuito slash 'results' slash 'optimosAll.' modo namext]);
 [a, b] = system([ 'del ' circuito slash 'results' slash 'optimosAllRes.' modo namext]);
 [a, b] = system([ 'del ' circuito slash 'results' slash 'optimosDet.' modo namext]);
 [a, b] = system([ 'del ' circuito slash 'results' slash 'optimos.' modo namext]);
    
 switch modo
 case 'GaM'
    modoind=1;
    load optimtool_GaM.mat;
    %para varias polupalacoes colocar [20:30], por exemplo uma de 20 e outra de 30
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.nvars= nvars;
    optimproblem.fitnessfcn = eval(['@(x)' 'fitnessHSPPar' '(x)']);
    optimproblem.options.PopInitRange = [optimproblem.lb; optimproblem.ub];
    optimproblem.options.PopulationSize=[20: 30];
    optimproblem.options.Generations=round(str2num(entrada{2})/sum(optimproblem.options.PopulationSize))-1;
    
   %  gera condicoes iniciais
    samples = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
     end;

    j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
        init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
        if (init.x0(j)> 1) init.x0(j)=1;
          elseif (init.x0(j)<0) init.x0(j) =0;
        end;
        j=j+1;
      end;
    end; 

    if str2double(entrada{5}) > 2
      optimproblem.x0 = rand(samples, 1, nvars);
    end;
    optimproblem.options.InitialPopulation = init.x0;
   
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 1
     cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     optimtool(optimproblem);
     profview = 0;
    else for i=1:str2double(entrada{1});
     fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
     cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     saida = ga(optimproblem);
     switch str2double(entrada{5})
       case 0
        optimproblem.options.InitialPopulation = init.x0; 
       case {2, 3}
        j=1;
        for i=1:length(genesLB)
         if (dif(i) ~= 0)  
           optimproblem.options.InitialPopulation(j)= (Best.parameters(i) - genesLB(i))/dif(i);
           j=j+1;
         end;
       end;
       otherwise
         optimproblem.options.InitialPopulation = rand(samples, 1, nvars);
     end;
     end;
    end;

 case 'GA'
    modoind=2;
    load optimtool_GA.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.nvars= nvars;
    optimproblem.fitnessfcn = eval(['@(x)' fitness '(x)']);
    optimproblem.options.PopInitRange = [optimproblem.lb; optimproblem.ub];
    optimproblem.options.PopulationSize=[20 ];
    optimproblem.options.Generations=round(str2num(entrada{2})/sum(optimproblem.options.PopulationSize))-1;
    
     %  gera condicoes iniciais
    samples = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
     end;

    j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
        init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
        if (init.x0(j)> 1) init.x0(j)=1;
          elseif (init.x0(j)<0) init.x0(j) =0;
        end;
        j=j+1;
      end;
    end; 

    if str2double(entrada{5}) > 2
      optimproblem.x0 = rand(samples, 1, nvars);
    end;
% permite colocar mais de uma condicao inicial para a simulacao
    cond = [circuito slash 'InicialCond.m'];
    InitialPop =[];
    if exist(cond)
     eval(['cd ', circuito]);
     AuxTemp = InicialCond();
     InitialPop = [init.x0; InicialCond()];
     eval('cd ..');
    else 
     InitialPop =[init.x0];     
   end;
   optimproblem.options.InitialPopulation = InitialPop;
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 1
     cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     optimtool(optimproblem);
     profview = 0;
    else for i=1:str2double(entrada{1});
     fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
     cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     saida = ga(optimproblem);
     switch str2double(entrada{5})
       case 0
        optimproblem.options.InitialPopulation = init.x0; 
       case {2, 3}
        j=1;
        for i=1:length(genesLB)
         if (dif(i) ~= 0)  
           optimproblem.options.InitialPopulation(j)= (Best.parameters(i) - genesLB(i))/dif(i);
           j=j+1;
         end;
       end;
       otherwise
         optimproblem.options.InitialPopulation = rand(samples, 1, nvars);
     end;
     end;
    end;
    
 case 'SA'
    modoind=3;
    load optimtool_SA.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    optimproblem.options.InitialTemperature=2.0;
    optimproblem.options.ReannealInterval= 30;
    optimproblem.options.MaxFunEvals=[str2num(entrada{2})];
    %optimproblem.options.TempInf= 0.1;
    optimproblem.options.AnnealingFcn = @annealingfast;
    optimproblem.options.TemperatureFcn = @TempUpdate;
    
 %  gera condicoes iniciais
    samples = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
     end;

    j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
        init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
        if (init.x0(j)> 1) init.x0(j)=1;
          elseif (init.x0(j)<0) init.x0(j) =0;
        end;
        j=j+1;
      end;
    end;   

   if str2double(entrada{5}) > 2
      init.x0 = rand(samples, 1, nvars);
   end;
   optimproblem.x0 = init.x0;

    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 0
        cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
        optimtool(optimproblem);
        profview = 0;
    else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
           cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
           saida = simulannealbnd(optimproblem);
           switch str2double(entrada{5})
           case 0
             optimproblem.x0 = init.x0; 
           case {2, 3}
             j=1;
             for i=1:length(genesLB)
              if (dif(i) ~= 0)  
                optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
                j=j+1;
              end;
             end;
          otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
          end;
         end;
    end;
   
 
 case 'PS'
    modoind=4;
    load optimtool_PS.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    optimproblem.options.MaxFunEvals = str2num(entrada{2});
    optimproblem.options.InitialMeshSize = 0.5;
    optimproblem.options.MaxMeshSize = 1.0;
    optimproblem.options.TolMesh = 1e-6;
    %optimproblem.options.TolFun = 1e-1;
    
    % gera condicoes iniciais%
    samples = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
    end;
     
    j=1;
    for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       snapr(j)=snap(i)/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
    end;
    
    if str2double(entrada{5}) > 2
       init.x0 = rand(samples, 1, nvars);
    end;
    optimproblem.x0 = init.x0;
    
    if (min(snapr) > 0) optimproblem.options.TolMesh = min(snapr); end;
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 0
        cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
        optimtool(optimproblem);
        profview = 0;
    else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
           cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
           saida = patternsearch(optimproblem);
           switch str2double(entrada{5})
           case 0
             optimproblem.x0 = init.x0; 
           case {2, 3}
             j=1;
             for i=1:length(genesLB)
              if (dif(i) ~= 0)  
                optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
                j=j+1;
              end;
             end;
          otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
          end;
         end;
    end;

    
  case 'MM'
    modoind=5;
    load optimtool_MM.mat;
    %load matlab.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    optimproblem.options.MaxFunEvals = str2num(entrada{2});
     % gera condicoes iniciais
    samples = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
    end;
     
    j=1;
    for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       snapr(j)=snap(i)/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
    end;
    
    if str2double(entrada{5}) > 2
       init.x0 = rand(samples, 1, nvars);
    end;
    optimproblem.x0 = init.x0;
    
    if (min(snapr) > 0) optimproblem.options.DiffMinChange = 2*min(snapr); end;
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 0
        cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
        optimtool(optimproblem);
        profview = 0;
    else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
           cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
           saida = fminimax(optimproblem);
           switch str2double(entrada{5})
           case 0
             optimproblem.x0 = init.x0; 
           case {2, 3}
             j=1;
             for i=1:length(genesLB)
              if (dif(i) ~= 0)  
                optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
                j=j+1;
              end;
             end;
          otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
          end;
         end;
    end;
    
 case 'SAM'
    modoind=6;
  
 %set the options
   optimproblem = struct(...
	  'fitnessfcn', fitness,...
	  'CoolSched',@(T) (.9*T),... %cooling schedule of the simulated annealing process
	  'InitTemp',50,...           %initial temperature
        'MaxConsRej',25000,...       %max consecutive rejections until stops
	  'MaxTries',10,...            %number of iterations until cooling schedule operates
        'StopTemp',1e-6,...        %minimum temperature until optimization stops
	  'StopVal',-Inf,...           %minimum value until optimization stops
	  'Verbosity',2,...            %display verbosity: 0-none; 1-only final report; 2-report at each temperature change
	  'MaxtoLocal',10,...          %max failures until a local minimum is detected
	  'Initial_Sigma',5,...       %initial deviation in variables (great numbers are better as they will automatically adapt to the problem size)
	  'lock_on',1,...              %temporary lock to variables that are showing progress
	  'crossover',1,...            %enable or disable crossovers
	  'increaseweight',0.01,...    %added weight in individual cost function to compose AOF after local minimum
	  'weightmemorysize',5,...     %memory size of local minimums
	  'totaltime',Inf,...          %time limit
	  'maxfunevals',5000);         %function evaluation limit

    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.maxfunevals = str2num(entrada{2});
    
    samples  = RandStream('mt19937ar');
    if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
    end;
    
    j=1;
    for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
    end;

    if str2double(entrada{5}) > 2
      init.x0 = rand(samples, 1, nvars);
    end;
    optimproblem.x0 = init.x0;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
          annealwithcrossovers3(optimproblem);
      switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
      end;
   end; 

    
 case 'SCE'
   modoind=7;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
          optimproblem.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
          if (init.x0(j)> 1) init.x0(j)=1;
            elseif (init.x0(j)<0) init.x0(j) =0;
          end;
          j=j+1;
       end;
    end;
   fun = 'fitness';
   saida= SCE(fun, optimproblem.x0, optimproblem.lb, optimproblem.ub);
 
 case 'PSO'
   modoind=8;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      
; % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;

   if str2double(entrada{5}) > 2
      init.x0 = rand(samples, 1, nvars);
   end;
   optimproblem.x0 = init.x0;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      neigh=vizinha(1);
      if (str2double(entrada{5})>2) 
       neigh=1;
      end;
      saida= PSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), 3*length(optimproblem.x0), neigh);
      switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
          neigh=vizinha(2);
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
          neigh=vizinha(2);
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
          neigh= 1;
      end;
   end; 
  
case 'QEPSO'
   modoind=9;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;

   if str2double(entrada{5}) > 2
      init.x0 = rand(samples, 1, nvars);
   end;
   optimproblem.x0 = init.x0;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      fprintf('QEPSO ____ \n');
      saida= QEPSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), 3*length(optimproblem.x0));
      switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
      end;
   end; 

case {'QDPSO', 'QGPSO', 'QLRPSO', 'GQPSO'}
   modoind=10;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;

   if str2double(entrada{5}) > 2
      init.x0 = rand(samples, 1, nvars);
   end;
   optimproblem.x0 = init.x0;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      fprintf('QPSO ____ \n');
      neigh=vizinha(1);
      if (str2double(entrada{5})>2) 
       neigh=1;
      end;
      switch modo
        case 'QDPSO'
        saida=QDPSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), length(optimproblem.x0), 2*length(optimproblem.x0), str2double(entrada{2}), neigh);
        case 'QGPSO'
        saida=QGPSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), length(optimproblem.x0), 2*length(optimproblem.x0), str2double(entrada{2}), neigh);
        case 'QLRPSO'
        saida=QLRPSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), length(optimproblem.x0), 2*length(optimproblem.x0), str2double(entrada{2}), neigh);
        case 'GQPSO'
        saida=GPSOQ(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), length(optimproblem.x0), 2*length(optimproblem.x0), str2double(entrada{2}), neigh);
      end;
        
        switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
          neigh=vizinha(2);
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
          neigh=vizinha(2);
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
          neigh=1;
      end;
   end; 
     
   
case 'DPSO'
   modoind=12; snapr=0;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       snapr(j)=snap(i)/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;
   optimproblem.x0 = init.x0;
   if str2double(entrada{5}) > 2
      optimproblem.x0 = rand(samples, 1, nvars);
   end;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      saida= DPSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), 2*length(optimproblem.x0), snapr);
      switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
      end;
   end; 
   
case 'DE'
    modoind=13;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
         init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
         if (init.x0(j)> 1) init.x0(j)=1;
          elseif (init.x0(j)<0) init.x0(j) =0;
         end;
        j=j+1;
      end;
   end;
   optimproblem.x0 = init.x0;
   if str2double(entrada{5}) > 2
      optimproblem.x0 = rand(samples, 1, nvars);
   end;
   VTR = 1.e-8;  Rnvars = length(optimproblem.x0);
   Best.scoreT = Inf('double');
   
   for contopt=1:str2double(entrada{1});
   fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
     cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     saida= devec3(fitness, VTR, Rnvars, optimproblem.lb, optimproblem.ub, [], 6*Rnvars, round(str2num(entrada{2})/(6*Rnvars)), optimproblem.x0);
     switch str2double(entrada{5})
      case 0
        optimproblem.x0 = init.x0; 
      case {2, 3}
        j=1;
        for i=1:length(genesLB)
        if (dif(i) ~= 0)  
          optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
          j=j+1;
         end;
        end;
      otherwise
        optimproblem.x0 = rand(samples, 1, nvars);
      end;
   end;
   
case 'EvN'
   modoind=14;
   fun = 'fitness';
   optimproblem.x0 = zeros(1, nvars);
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       optimproblem.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;

   if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
        optimproblem.x0 = rand(samples, 1, nvars);
   end;
   
%saida = EvNeu (fun,  optimproblem.x0, nvars, 200, 200, 40, 300, 'radbas', [nvars, nvars]);
   Best.scoreT = Inf('double');
   for i=1:str2double(entrada{1})
     fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
     cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     saida = EvNeu16_4(fun,  optimproblem.x0, nvars, 95, 200, 40, 300, 'radbas', round(nvars/2));
     if ~isempty(entrada{4}) 
         optimproblem.x0 = rand(samples, 1,nvars);
     end;
   end;

   case 'PSON'
   modoind=15;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       optimproblem.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (optimproblem.x0> 1) optimproblem.x0=1;
         elseif (optimproblem.x0<0) optimproblem.x0 =0;
       end;
       j=j+1;
     end;
   end;
   if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
        optimproblem.x0 = rand(samples, 1, nvars);
    end;
    
   Best.scoreT = Inf('double');
   for i=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      saida= PSON4(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, 5*length(optimproblem.x0), 2*length(optimproblem.x0), 20*length(optimproblem.x0), 'radbas', round(nvars/2), str2double(entrada{2}));
      if ~isempty(entrada{4}) 
         optimproblem.x0 = rand(samples, 1,nvars);
      end;
   end;
   
   case 'PSw'
   modoind=16;

   Problem = struct('ObjFunction', 'fitness', 'LB', zeros(1, nvars)', 'UB', ones(1, nvars)'); 
   InitPop(1).x = zeros(1, nvars)';
   Options = struct('Cognitial', 0.5, 'InerciaFinalWeight', 0.4, 'InerciaInitialWeight', 0.9, 'Social', 0.5, ...
   'MaxObj', str2num(entrada{2}), 'MaxIter', str2num(entrada{2}), 'Size', 1*nvars, ...
   'MaxVelocityFactor', 0.4, 'CPTolerance', 1.0e-5, 'InitialDelta', 2.0, 'DeltaIncreaseFactor', 2.0, 'DeltaDecreaseFactor', 0.5, ...
   'InitialDeltaFactor', 2.0, 'IPrint', 10, 'DegTolerance', 0.001, 'LinearStepSize', 1, 'EpsilonActive', 1e-1, 'TangentCone', 4,...
   'Trials', 1000, 'MVETrials', 10, 'OutputFCN', 'outputfcn', 'Vectorized', 0, 'SearchType', 1, 'Cache', 0, 'CacheChunks', 100, 'LoadCache', 0,...
   'SaveCache', 0, 'CacheFile', 'PSCache', 'RBFAlgo', 1, 'MFNAlgo', 1, 'DCARhoFactor', 5*10^-3,'RBFPoints',1,'PollSort',0,'TRType',0);

   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       InitPop(1).x(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;   
   if ~isempty(entrada{4}) 
       samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
       rand('seed', str2double(entrada{4}));
        InitPop(1).x = rand(samples, 1, nvars)';
   end;
         
   Best.scoreT = Inf('double');

   for i=1:str2double(entrada{1});
     fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
     cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
     [BestParticle, BestParticleObj, RunData] = PSwarm(Problem, InitPop, Options);
     if ~isempty(entrada{4}) 
       InitPop(1).x = rand(samples, 1,nvars)';
     end;
   end;
   
   case 'EDA'
   modoind=17;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   Popsize = nvars*8;
   edaparams{1} = {'learning_method','LearnGaussianFullModel',{}};
   edaparams{2} = {'sampling_method','SampleGaussianFullModel',{Popsize, 1}};
   edaparams{3} = {'replacement_method','elitism',{15,'fitness_ordering'}};
   edaparams{4} = {'selection_method','prop_selection',{2}};
   edaparams{5} = {'repairing_method','SetInBounds_repairing',{}};
   edaparams{6} = {'stop_cond_method','max_gen',{round(str2double(entrada{2})/Popsize)}};
   cache = [0,0,0,0,0];
   
   fun = 'fitness';
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
      samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
      rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;
   optimproblem.x0 = init.x0;
   if str2double(entrada{5}) > 2
      optimproblem.x0 = rand(samples, 1, nvars);
   end;
    
   Best.scoreT = Inf('double');
   for i=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      saida=RunEDANav(Popsize, optimproblem.x0, fitness, [optimproblem.lb; optimproblem.ub], cache, edaparams); 
      switch str2double(entrada{5})
        case 0
          optimproblem.x0 = init.x0; 
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            optimproblem.x0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
        otherwise
          optimproblem.x0 = rand(samples, 1, nvars);
      end;
   end;
   
   case 'ESS'
   modoind=18;
%set the options
   problem = struct(...
	 'f', fitness,...          %Name of the file containing the objective function (String)
	 'x_L',zeros(1, nvars),... %Lower bounds of decision variables (vector)
	 'x_U',ones(1, nvars),...  %Upper bounds of decision variables (vector)
     'x_0',zeros(1, nvars));   %Initial point(s)
     
   opts = struct(...
	 'maxeval', str2num(entrada{2}),... %Maximum number of function evaluations
     'maxtime',  36000,... %Maximum CPU time in seconds (Default 60)
     'iterprint', 1,... %Print each iteration on screen: 0-Deactivated; 1-Activated (Default 1)
     'combination', 1,... %Type of combination of Refset elements (Default 1) 1: hyper-rectangles 2: linear combinations
     'plot', 0); %Plots convergence curves: 0-Deactivated,1-Plot curves on line, 2-Plot final results
	 opts.local.balance=0.2; %Balances between quality (=0) and diversity (=1) for choosing initial points for the local search (default 0.5)    
   samples  = RandStream('mt19937ar');
   if ~isempty(entrada{4}) 
     samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
     rand('seed', str2double(entrada{4})); % initialize the rand function
   end;
    
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       init.x0(j)= (inicialSoln(i) - genesLB(i))/dif(i);
       if (init.x0(j)> 1) init.x0(j)=1;
         elseif (init.x0(j)<0) init.x0(j) =0;
       end;
       j=j+1;
     end;
   end;
   problem.x_0 = init.x0;
   if str2double(entrada{5}) > 2
    problem.x_0 = rand(samples, 1, nvars);
   end;
    
   Best.scoreT = Inf('double');
   for contopt=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', contopt, Best.scoreT);
      cont = 0; contsuc = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      MEIGO(problem, opts, 'ESS');
      switch str2double(entrada{5})
        case 0
          mproblem.x_0 = init.x0; 
        case {2, 3}
          j=1;
          for i=1:length(genesLB)
          if (dif(i) ~= 0)  
            problem.x_0(j)= (Best.parameters(i) - genesLB(i))/dif(i);
            j=j+1;
          end;
          end;
        otherwise
          problem.x_0 = rand(samples, 1, nvars);
      end;
   end; 
   
 end %switch
end  %if 
%profile viewer;
%if profview  profile viewer;
% else profile off;
% end;