global modo;
global nvars;
global genesLB;
global inicialSol;
global dif;
global modoind;
global namext;
global cont;
global circuito;
global slash;
global fitness;
global scorePlot;
global xT;
global Best;
global contopt;

contopt=1;
namext = '';
prompt={'Number of Runs','Max simulations (more than 1 run)','Extension of the output file', 'seed', 'mode'};
name='Algoritm Running';
numlines=1;
defaultanswer={'1','4000', '', '', '4'};
entrada=inputdlg(prompt,name,numlines,defaultanswer);
% check if the dialog was answered
if (length(entrada) == 5)
 namext = entrada{3};
 system(['del ' circuito slash 'results' slash 'optimos.' modo namext]);
 profile on;
 switch modo
 case 'GA'
    modoind=1;
    load optimtool_GA.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.nvars= nvars;
    optimproblem.fitnessfcn = eval(['@(x)' fitness '(x)']);
    optimproblem.options.PopInitRange = [optimproblem.lb; optimproblem.ub];
    optimproblem.options.PopulationSize=[100];
    optimproblem.options.Generations=round(str2num(entrada{2})/sum(optimproblem.options.PopulationSize))-1;
    
   % inicializa os geradores para se repetir resultados
    if ~isempty(entrada{4}) 
         rand('seed', str2double(entrada{4}));
         randn('seed', str2double(entrada{4}));
     end;
     
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 1
        optimtool(optimproblem);
     else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
           cont = 0; Best.score = Inf('double'); Best.scoreT = Inf('double'); scorePlot = [ ; ];
           ga(optimproblem);
          end;
    end;
 
 case 'SA'
    modoind=2;
    load optimtool_SA.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    optimproblem.options.InitialTemperature=2.0;
    optimproblem.options.ReannealInterval= 50;
    optimproblem.options.MaxFunEvals=[str2num(entrada{2})];
    optimproblem.options.TempInf= 0.1;
    j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
        optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
        j=j+1;
      end;
    end;   
  
    % gera condicoes iniciais
    if ~isempty(entrada{4}) 
        samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
        rand('seed', str2double(entrada{4}));
        optimproblem.x0 = rand(samples, 1,nvars);
     end;
    
    Best.scoreT = Inf('double');
    if str2double(entrada{1}) == 1
        optimtool(optimproblem);
    else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
           cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
           simulannealbnd(optimproblem);
           if ~isempty(entrada{4}) 
            optimproblem.x0 = rand(samples, 1,nvars);
          end;
         end;
    end;
      
 case 'PS'
    modoind=3;
    load optimtool_PS.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    optimproblem.options.MaxFunEvals = str2num(entrada{2});
    j=1;
    for i=1:length(genesLB)
       if (dif(i) ~= 0)  
          optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
          j=j+1;
       end;
    end;  
    
    % gera condicoes iniciais
    if ~isempty(entrada{4}) 
         samples  = RandStream('mt19937ar', 'Seed', str2double(entrada{4})); % this stream is used to generate the initial conditions
         rand('seed', str2double(entrada{4}));
         optimproblem.x0 = rand(samples, 1,nvars);
     end;
     
     Best.scoreT = Inf('double');
     if str2double(entrada{1}) == 1
        optimtool(optimproblem);
     else for i=1:str2double(entrada{1});
           fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT); 
           cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
           patternsearch(optimproblem);
           if ~isempty(entrada{4}) 
            optimproblem.x0 = rand(samples, 1,nvars);
          end;
         end;
    end;
    
  case 'MM'
    load optimtool_MM.mat;
    optimproblem.lb = zeros(1, nvars);
    optimproblem.ub = ones(1, nvars);
    optimproblem.x0 = zeros(1, nvars);
    optimproblem.objective = eval(['@(x)' fitness '(x)']);
    j=1;
    for i=1:length(genesLB)
       if (dif(i) ~= 0)  
          optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
          j=j+1; 
       end;
     end;
    modoind=4;
    optimtool(optimproblem);
    
 case 'SAM'
    modoind=5;
  
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
       init.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
      cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
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

   
         
    Best.scoreT = Inf('double');
    for i=1:str2double(entrada{1});
      fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
      cont = 0; Best.score = Inf('double');  scorePlot = [ ; ];
      annealwithcrossovers3(optimproblem);
      if ~isempty(entrada{4}) 
        optimproblem.x0 = rand(samples, 1,nvars);
      end;
   end;
 
    
 case 'SCE'
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
          optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
          j=j+1;
       end;
    end;
   fun = 'fitness';
   modoind=6;
   saida= SCE(fun, optimproblem.x0, optimproblem.lb, optimproblem.ub);
 
 case 'PSO'
   modoind=7;
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
       init.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
      cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      saida= PSO(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, str2double(entrada{2}), 2*length(optimproblem.x0));
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
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
    j=1;
    for i=1:length(genesLB)
      if (dif(i) ~= 0)  
          optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
          j=j+1;
       end;
    end;
   fun = 'fitness'; VTR = 1.e-8;
   modoind=8;
   Best.scoreT = Inf('double');
   Rnvars = length(optimproblem.x0);
   
   for i=1:str2num(entrada{1});
    fprintf('\n__________________  inicio da %1.0f otimizacao   Melhor score: %3g  __________________\n\n ', i, Best.scoreT);
    cont = 0; Best.score = Inf('double');
    saida= devec3(fun, VTR, Rnvars, optimproblem.lb, optimproblem.ub, [], 6*Rnvars, round(str2num(entrada{2})/(6*Rnvars)));
   end;
   
case 'EvN'
   modoind=9;
   fun = 'fitness';
   optimproblem.x0 = zeros(1, nvars);
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
   modoind=10;
   optimproblem.lb = zeros(1, nvars);
   optimproblem.ub = ones(1, nvars);
   optimproblem.x0 = zeros(1, nvars);
   fun = 'fitness';
   j=1;
   for i=1:length(genesLB)
     if (dif(i) ~= 0)  
       optimproblem.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
      cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
      saida= PSON2(fitness, optimproblem.x0, optimproblem.lb, optimproblem.ub, 6*length(optimproblem.x0), length(optimproblem.x0), 300, 'radbas', round(nvars/2), str2double(entrada{2}));
      if ~isempty(entrada{4}) 
         optimproblem.x0 = rand(samples, 1,nvars);
      end;
   end;
   
   case 'PSw'
   modoind=11;

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
       InitPop(1).x(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
   modoind=12;
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
       init.x0(j)= (inicialSol(i) - genesLB(i))/dif(i);
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
      cont = 0; Best.score = Inf('double'); scorePlot = [ ; ];
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
   
 end %switch
end  %if 
profile viewer;