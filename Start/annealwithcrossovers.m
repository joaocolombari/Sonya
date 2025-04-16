function [minimum,fval] = annealwithcrossovers(options)
%ANNEALWITHCROSSOVERS finds the minimum of a multi-objective function of
%several variables for a given set of weights. It uses an AOF
%(aggregate objective function) as a guide while monitoring all the multi-
%objective functions independently.
%   ANNEALWITHCROSSOVERS attempts to solve problems of the form:
%    min F(X)  subject to:  LB <= X <= UB        (bounds)
%                                                           
%   [X, fval] = FMINCON(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
%   structure with the following template:
%
%    options = struct(...
%    'Display', 'crossovers',...  % it can be 'final', 'iter', 'crossovers', or 'none'
%    'TolFun', 1e-6,...
%    'ObjectiveLimit', -1e+20,...
%    'TolCon', 1e-6,...
%    'CoolSched',@(T) (.8*T),...
%    'InitTemp',10,...                % initial temperature
%    'MaxTriesWithoutBest',10000,...  %max number of attempts without a new best before finishing
%    'MaxSuccess',200,...
%    'MaxTries',300,...
%    'StopTemp',1e-8,...
%    'StopVal',-Inf,...
%    'MaxtoLocal',25,...
%    'TimeLimit',1,...    % time in seconds
%    'LockOn',1,...         % lock to variables that are showing progress
%    'Crossover',0,...      % able or disable crossovers
%    'Initial_Sigma',1);
%
%   Author: Tiago Oliveira Weber
%   E-mail: tiago.oliveira.weber@gmail.com
%   Date: 02/04/2013


%****************************************************
%   Optimization Structure
%****************************************************
def = struct(...
    'Display', 'final',...
    'TolFun', 1e-6,...
    'ObjectiveLimit', -1e+20,...
    'TolCon', 1e-6,...
    'CoolSched',@(T) (.8*T),...
    'InitTemp',1,...
    'MaxTriesWithoutBest',1000,...
    'MaxSuccess',200,...
    'MaxTries',300,...
    'StopTemp',1e-8,...
    'StopVal',-Inf,...
    'MaxtoLocal',25,...
    'TimeLimit',1,...
    'LockOn',1,...
    'Crossover',1,...
    'Initial_Sigma',1);

% Check input
if ~nargin %user wants default options
    options = def;
else %user gave all input, check if options structure is complete
    if ~isstruct(options)
        error('MATLAB:anneal:badOptions',...
            'Input argument ''options'' is not a structure')
    end
    %fs = {'CoolSched','Generator','InitTemp','MaxConsRelj',...
    %    'MaxSuccess','MaxTries','StopTemp','StopVal','Verbosity','MaxtoLocal'};
    %for nm=1:length(fs)
    %    if ~isfield(options,fs{nm}), options.(fs{nm}) = def.(fs{nm}); end
    %end
end

% main settings

loss = options.fitnessfcn;
parent = options.x0; %initial solution
lb = options.lb; %lower boundary
ub = options.ub; %upper boundary
Tinit = options.InitTemp;        % initial temp
minT = options.StopTemp;         % stopping temp
cool = options.CoolSched;        % annealing schedule
InitSigma = options.Initial_Sigma;
minF = options.StopVal;
max_tries_without_best = options.MaxTriesWithoutBest;
max_try = options.MaxTries;
max_success = options.MaxSuccess;
timelimit = options.TimeLimit;
lock_on = options.LockOn;
crossover = options.Crossover;
max_to_local = options.MaxtoLocal; %added by me to define the maximum errors until it decides it's a local minimum
max_sim = options.MaxSim; % numero maximo de simulacoes
if strcmp(options.Display,'final')
    report = 1;
elseif strcmp(options.Display,'iter')
    report = 2;
elseif strcmp(options.Display,'crossovers')
    report = 3;
else
    report = 0;
end

%****************************************************
%   Optimization Variables
%****************************************************
weight_change = 10;
memory_size = 10;
multiple_variables = 1;
local_minimuns = 0;
local_minimuns_history = 0;
stop_criteria = 0;
crossover_ntobetter(1) = 0;
keep_pos = zeros(1,multiple_variables); %determine if the variable to be randomically changed keeps the same or changes based on previous results
increaseweight = weight_change;
weightmemorysize = memory_size;
cont_sim = 0;
%global specweight; %only to be able to change it after local minimuns
%global safe_specweightafterzero;
%global total_bestcost; %only to update the best solution displayed after the weight change
%global transistor_region_satisfied;
%global timelimit;
%global crossover;
%increaseweight = 5;
%weightmemorysize = 5;
%keep_tries = 0;
%max_keep_tries = 2;


%****************************************************
%   Optimization Start
%****************************************************
tic;
sigma=ones(1,length(parent))*InitSigma; %added by me to represent the sigma (on the variation on each step) for each variable
%k = 1;                           % boltzmann constant
k = 0.0029; % to make P = 0.5 when Temperature = 25� and (olde-newe)/olde = -0.05
% counters etc
itry = 0;
failcounter = 0;
modifyalot = 0; % this will set to 1 when it finds a local minimum
%modifyalot = 0; % this will set to 1 when it finds a local minimum
%global local_minimuns; %make it global so it can be printed during optimization
success = 0;
finished = 0;
consec = 0;
intmax_notbest_count = 0;
T = Tinit;
%[initenergy,mof] = loss(parent);
[initenergy,mof] = feval(loss, parent);
cont_sim = cont_sim +1;
nfunctions = length(mof)-1;
oldenergy = initenergy;

iteration_counter = 0;
crossover_already_better = 0;
total = 0;
if report==2, fprintf(1,'\n  T = %7.5f, loss = %10.5f\n',T,oldenergy); end;

bestsolution_x = parent;
bestsolution_cost = inf;

anchorcosts_splited = ones(1,nfunctions)*inf;
anchor_x = ones(nfunctions,length(parent));
bestsolution_costs_splited = ones(1,nfunctions)*inf;
anchorcost = ones(1,nfunctions)*inf;
%anchorcost(i) = newenergy;
for i=1:nfunctions
    anchorcosts_splited(i) = inf;
    anchor_x(i,:) = parent;
    bestsolution_costs_splited(i) = inf;
    anchorcost(i) = inf;
    %for j=1:size(parent,2)
    %    anchor_prob(i,j) = lb(j); %#ok<AGROW>
    %end
end
real_objs = 0.01*initenergy;
%*************************
%   Main Loop
%*************************

roll = 0;
transistor_region_satisfied = 1;
while ((~finished) && (cont_sim < max_sim));
    roll = roll + 1;
    itry = itry+1; % iteration counter per temperature schedule
    iteration_counter = iteration_counter + 1;
    if stop_criteria == 1;
        finished = 1;
        %break;
    end
    %failcounter    
    if (toc > timelimit)
        finished = 1;
        disp('Finishing due to time >= timelimit')        
        %break
    end
    if itry >= max_try || success >= max_success || failcounter > max_to_local || intmax_notbest_count >= max_tries_without_best
        if T < minT || intmax_notbest_count >= max_tries_without_best; %stop criteria
            disp('Finishing due to intmax_notbest_count >= max_tries_without_best')
            finished = 1; %it will finish the optimization loop
            total = total + itry;
            %break;
        elseif failcounter > max_to_local       %if it has reached found a local minimum
            
            if (transistor_region_satisfied == 1)
                %T = (T+Tinit)/2;                       %initializes temperature
                T = (2*T+Tinit)/3;                       %initializes temperature
                local_minimuns = local_minimuns +1;
                local_minimuns_history = local_minimuns_history +1;
                if (crossover)
                    if (oldenergy > real_objs*1)             %NOT TOO CLOSE TO THE SPECS
                        modifyalot = 1;                       %enables the next process to modify a lot the variables (to mess around
                    else
                        modifyalot = 0;          %TOO CLOSE, IGNORE CROSSOVER
                        local_minimuns = local_minimuns - 1;
                        local_minimuns_history = local_minimuns_history - 1;
                    end
                else
                    modifyalot = 0;
                end
            else
                %T = (T+Tinit)/2;                       %initializes temperature
                T = T+(Tinit)/5;                       %initializes temperature
                %local_minimuns = local_minimuns +1;
                %local_minimuns_history = local_minimuns_history +1;
                %parent = (lb+(ub-lb).*rand(1,length(lb)).*0.5) + x./2;
                %x = (lb+(ub-lb).*rand(1,length(lb)).*0.5) + x./2;
            end
            failcounter = 0;
        else
            T = cool(T);  % decrease T according to cooling schedule
            if report==2, % output
                fprintf(1,'  T = %7.5f, loss = %10.5f\n',T,oldenergy);
            end
            total = total + itry;
            itry = 1;
            %failcounter = 0;
            %success = 1;
        end
    end
    x = parent;
    oldx = x;
    if modifyalot == 0
        position = zeros(1,multiple_variables); %just to allocate memory
        for i=1:multiple_variables; %find the position
            if (keep_pos(i) == 0 || lock_on == 0)
                position(i) = randint(1,1,length(x))+1; %generates random integer matrix of 1x1 in the range of length(x)
            else
                position(i) = keep_pos(i);
            end
            %x(position(i)) = x(position(i))+((x(position(i))*abs(randn)*sigma(position(i)))); %randn = normally random pseudonumber
            x(position(i)) = x(position(i))+((x(position(i))*randn*sigma(position(i)))); %randn = normally random pseudonumber
            %x(position(i)) = x(position(i))+((randn*sigma(position(i)))); %randn = normally random pseudonumber
            
            
            while (x(position(i))<lb(position(i)) || x(position(i))>ub(position(i)))
                x(position(i)) = oldx(position(i));
                sigma(position(i)) = sigma_calculation(sigma(position(i)),2,1);
                position(i) = randint(1,1,length(x))+1; %generates random integer matrix of 1x1 in the range of length(x)
                %x(position(i)) = x(position(i))+((x(position(i))*abs(randn)*sigma(position(i)))); %randn = normally random pseudonumber
                x(position(i)) = x(position(i))+((x(position(i))*randn*sigma(position(i)))); %randn = normally random pseudonumber
                %x(position(i)) = x(position(i))+((randn*sigma(position(i)))); %randn = normally random pseudonumber
                %x(position(i)) = x(position(i))+((x(position(i))*(randn)*sigma(position(i)))); %randn = normally random pseudonumber
            end
        end
    elseif modifyalot == 1
        crossover_iteration_start(local_minimuns) = iteration_counter;         %#ok<AGROW>
        if (local_minimuns>1)
            if (~crossover_already_better)
                %if (length(crossover_ntobetter) < local_minimuns) % if no better was found after the last crossover
                crossover_ntobetter(local_minimuns-1) = -1;                         %#ok<AGROW>
                %fw = fopen('crossovers.txt','a');
                %fprintf(fw,'%d, %f \n',local_minimuns-1, crossover_ntobetter(local_minimuns-1));
                %fclose(fw);
                %fw = fopen('crossovers_total.txt','a');
                %fprintf(fw,'%d, %f \n',local_minimuns-1, crossover_ntobetter(local_minimuns-1));
                %fclose(fw);
            end
            crossover_already_better = 0;
        end
        %move the response toward the anchor point
        costs_splitedm = bestsolution_costs_splited;
        %for i=1:size(costs_splited,2)
        %    %costs_splitedm(i) = costs_splited{i};%/max(specweight{i},1e-5);
        %    costs_splitedm(i) = bestsolution_costs_splited(i);
        %end
        
        worst_spec_index = 1;
        worst_spec_cost = -inf;
        for i=1:nfunctions
            if costs_splitedm(i) > worst_spec_cost
                worst_spec_cost = costs_splitedm(i);
                %worst_spec_cost = bestsolution_costs_splited(i);
                worst_spec_index = i;
            end
        end
        if (report == 2)
            fprintf(1,'Local minimum found - worst_spec = %d \n',worst_spec_index);
        end
        
        %spec_index(local_minimuns) = roulet_for_specs(specname,costs_splitedm,safe_specweightafterzero);
        
        
        selected = roulet_for_specs(nfunctions,costs_splitedm);
        
        % adding spec to local minimum history
        %spec_index(local_minimuns_history) = worst_spec_index;
        spec_index(local_minimuns_history) = selected; %#ok<AGROW>
        
        if (spec_index(local_minimuns_history) == 0)
            keyboard
        end
        %if(local_minimuns > 10)
        %    keyboard
        %end
        %end of roulet
        
        %adding local minimum to memory
        localminsol(local_minimuns_history,:) = parent;               %#ok<AGROW>
        
        %parent = recombination_p(parent,anchor_x(spec_index(local_minimuns),:));
        if (intmax_notbest_count >  max_tries_without_best/2)
            %x = recombination_p(parent,anchor_x(selected,:));
            x = recombination_p(parent,bestsolution_x);
            parent = bestsolution_x;
            clear spec_index;
            local_minimuns_history = 0;           
            if (report == 2 || report == 3)
                disp('PARENT RESCUED');
            end
        else
            x = recombination_p(parent,anchor_x(selected,:));
            parent = recombination_p(parent,anchor_x(selected,:));
            if (report == 2 || report == 3)
                fprintf(1,'CROSSOVER with anchor = %d \n',selected);
            end
            
            %PRINT TO FILE
            %fc=fopen('./last_crossover.txt','w');
            %fprintf(fc,'Last Crossover Event \n');
            %for i=1:nfunctions
            %    fprintf(fc,'anchor from function %d = %f \n',i,costs_splitedm(i));
            %end
            %fprintf(fc,'\n Selected anchor = %d \n',selected);
            %fprintf(fc,'\n Worst Spec from function  %d \n',worst_spec_index);
            %fclose(fc);
            
        end
        %parent = (anchor_x(spec_index,:)+bestsolution_x+parent)/3;  %mean of the three
        
        % Running "new" parent to set old energy
        %[oldenergy,tempcosts_splited,temp]=loss(parent);
        %[oldenergy,tempcosts_splited] = loss(parent);
        [oldenergy,tempcosts_splited] = feval(loss,parent);
        con_sim = cont_sim +1; 
        
        %updating parent energy
        if (exist('spec_index','var'))
            totald = totaldistance(newparam,localminsol);
            old_prox_penalty = (sqrt(abs(oldenergy*(0.0001/totald))));
            %old_prox_penalty = 0;
            for i=max(1,length(spec_index)-weightmemorysize):length(spec_index)
                old_prox_penalty = old_prox_penalty + increaseweight*tempcosts_splited(spec_index(i));%/specweight(spec_index(i));
            end
        else
            old_prox_penalty = 0;
        end
        
        sigma = sigma.*1.1;
        %for i=1:length(parent)
        %    sigma(i)=options.Initial_Sigma; %added by me to represent the sigma (on the variation on each step) for each variable
        %end
        %keyboard
        modifyalot = 0;
    end
    newparam = x;
    
    %newenergy = loss(newparam);
    %[cost_solutions,costs_splited]=loss(newparam);
    [cost_solutions,costs_splited]=feval(loss, newparam);
    newenergy=cost_solutions;
    cont_sim = cont_sim +1;
    if (newenergy <= minF), % This sets the stopping criteria on 0
        parent = newparam;
        oldenergy = newenergy;
        old_prox_penalty = prox_penalty;
        finished = 1;
        disp('Finishing due to newenergy <= minF')
        %break
    end
    
    
    %*****************
    %Decision over the best of all solutions (just to keep track)
    %*****************
    if newenergy < bestsolution_cost
        intmax_notbest_count = 0;
        bestsolution_cost = newenergy;
        bestsolution_x = newparam;
        bestsolution_costs_splited = costs_splited;
        %measurements for crossovers
        if (local_minimuns>1 && ~crossover_already_better && crossover)
            crossover_ntobetter(local_minimuns) = iteration_counter - crossover_iteration_start(local_minimuns); %#ok<AGROW>
            crossover_already_better = 1;
            %fw = fopen('crossovers.txt','a');
            %fprintf(fw,'%d, %f \n',local_minimuns, crossover_ntobetter(local_minimuns));
            %fclose(fw);
            %fw = fopen('crossovers_total.txt','a');
            %fprintf(fw,'%d, %f \n',local_minimuns-1, crossover_ntobetter(local_minimuns-1));
            %fclose(fw);
        end
    else
        intmax_notbest_count = intmax_notbest_count + 1;
    end
    
    
    %*****************
    %prox_penalty calculation
    %*****************
    %prox_penalty based on distance from all anchor points
    if (exist('localminsol','var') && (transistor_region_satisfied == 1) && exist('spec_index','var'))
        totald = totaldistance(newparam,localminsol);
        prox_penalty = (sqrt(abs(newenergy*(0.0001/totald))));
        %prox_penalty = 0;
        for i=max(1,length(spec_index)-weightmemorysize):length(spec_index)
            prox_penalty = prox_penalty + increaseweight*costs_splited(spec_index(i)); %/specweight{spec_index(i)};
        end
    else
        prox_penalty = 0;
        old_prox_penalty = 0;
    end
    
    %totald = totaldistance(newparam,bestsolution_x,anchor_x);
    %totald = totaldistance(newparam,newparam,anchor_x);
    %if sum(itry == (0:9:10))
    %    keyboard
    %end
    
    %prox_penalty = 0;
    
    %*****************
    %sigma calculation
    %*****************
    for i=1:multiple_variables
        position(i);
        sigma(position(i)) = sigma_calculation(sigma(position(i)),newenergy+prox_penalty,oldenergy+old_prox_penalty);
        %if abs(sigma(position(i))) < 0.1 % I thought I had done this before but couldn't find it in the code
        %    sigma(position(i)) = -sigma(position(i));
        %end
    end
    
    
    %*****************
    %Decision over the new solution
    %*****************
    if (((oldenergy+old_prox_penalty)-(newenergy+prox_penalty))/(oldenergy+old_prox_penalty)>0.005) %allow only significant improvements to reset the failcounter %BEFORE IT WAS 0.01
        failcounter = 0; %check if it's not the same as consec
    end
    if ((oldenergy+old_prox_penalty)-(newenergy+prox_penalty) > 0) % why 1e-6 and not 0 ?
        keep_pos = position; %continue changing the same variables
        parent = newparam;
        oldenergy = newenergy;
        old_prox_penalty = prox_penalty;
        success = success+1;
        consec = 0;
        %failcounter = 0; %check if it's not the same as consec
    else
        %if keep_tries >= max_keep_tries
        keep_pos(1:end) = 0; %don't lock on these variables if it was not a success
        %    keep_tries = 0;
        %else
        %    keep_tries = keep_tries + 1;
        %    keep_pos = position;
        %end

        failcounter = failcounter+1; %total failcounter
        %if (rand < exp( (oldenergy-newenergy)/(k*T) ));
        if (rand < exp( ((oldenergy+old_prox_penalty)-(newenergy+prox_penalty))/(abs((oldenergy+old_prox_penalty))*k*T)));        %prox_penalty is to stimulate something
            parent = newparam;
            oldenergy = newenergy;
            old_prox_penalty = prox_penalty;
            success = success+1; %shouldn't I reset consec? maybe not cause it's not actually a REAL sucess
            consec = 0;
            %failcounter = 0;
        else
            success = 0;
            consec = consec+1;
            %failcounter = failcounter+1; %total failcounter
        end
    end
    
    %*****************
    %Decision over the anchor points
    %*****************
    %if max(fail)==0 % if no spec failed
    %number = 0;
    for i=1:nfunctions % for all specs
        if (( (costs_splited(i)*0.95+newenergy*0.05) < (anchorcosts_splited(i)*0.95+anchorcost(i)*0.05)) || anchorcost(i) == inf)
            anchorcosts_splited(i) = costs_splited(i);
            anchor_x(i,:) = newparam;
            anchorcost(i) = newenergy;
            %        number = number+1;
        end
    end
    %number
    %end
    
    %*****************
    %Decision over the probabilities of anchor points
    %*****************
    %for i=1:size(specname,2)
    anchor_prob = zeros(nfunctions,nfunctions);
    for i=1:nfunctions        
        for j=1:nfunctions
            if (anchorcosts_splited(i)<=0)
                prob = ((anchorcosts_splited(i)-anchorcosts_splited(i)*1.1)/(costs_splited(i)-anchorcosts_splited(i)*1.1))^2 *0.5;
            else
                prob = (anchorcosts_splited(i)/costs_splited(i))^2 *0.5;
            end
            anchor_prob(i,j) = newparam(j)*(prob)+anchor_prob(i,j)*(1-prob);
            %if (anchor_prob(i,j) > ub(j) || anchor_prob(i,j) < lb(j))
            %keyboard
            %end
        end
    end
    %if intmax_notbest_count == 30
    %    keyboard
    %end
    %*****************
    if (report == 2)
        costs_splited_str = '';
        for i=1:length(costs_splited)
            costs_splited_str = sprintf('%s function %d = %f \t',costs_splited_str,i, costs_splited(i));
            if (i==5 || i==10 || i==15 || i==20 || i==25)
                costs_splited_str = sprintf('%s \n',costs_splited_str);
            end
        end
        fprintf('\nCOSTS\n%s',costs_splited_str);
        bcosts_splited_str = '';
        for i=1:length(costs_splited)
            bcosts_splited_str = sprintf('%s function %d = %f \t',bcosts_splited_str,i,bestsolution_costs_splited(i));
            if (i==5 || i==10 || i==15 || i==20 || i==25)
                bcosts_splited_str = sprintf('%s \n',bcosts_splited_str);
            end
        end
        fprintf('\nBEST COSTS\n%s',bcosts_splited_str);
        
        
        newenergystr  = num2str(newenergy);
        if exist('worst_spec_index','var')
            fprintf('\n Last worst spec = %d',worst_spec_index);
        end
        if exist('spec_index','var')
            %fprintf('Last roulet selected spec = %s',specname{spec_index(local_minimuns)});
            fprintf('Last roulet selected spec = %d',selected);
        end
        fprintf('\nPresent cost = \t \t %s',newenergystr);
        bestsolution_coststr  = num2str(bestsolution_cost);
        fprintf('\nBest solution cost = %s',bestsolution_coststr);
        fprintf('\nNot best counter = %d',intmax_notbest_count);
        fprintf('\nFail counter = %d',failcounter);
        fprintf('\nLocal minimuns = %d\n',local_minimuns);
        %sigma %print sigma
        %keep_pos %print keep_pos
        %update global total_bestcost
    end
    %total_bestcost = bestsolution_cost;
end


minimum = bestsolution_x;
fval = bestsolution_cost;
if report;
    fprintf(1, '\n  Initial temperature2:     \t%g\n', Tinit);
    fprintf(1, '  Final temperature:       \t%g\n', T);
    fprintf(1, '  Consecutive rejections:  \t%i\n', consec);
    fprintf(1, '  Max tries without best:  \t%i\n', intmax_notbest_count);
    fprintf(1, '  Number of function calls:\t%i\n', total);
    fprintf(1, '  Total final loss:        \t%g\n', fval);
end

end


function [child] = recombination_p(a,b)
% selector = 1 means A gene will go to child
% selector = 0 means B gene will go to child
% the parent is A in our algorithm
p = 0.5; %probability of starting with a
p_ka = 0.5; %keep a
p_kb = 0.7; %keep b
if rand < p
    selector(1) = 1;
else
    selector(1) = 0;
end
for i=2:size(a,2)
    if selector(i-1) == 0        
        if rand < p_kb;
            selector(i) = 0;
        else
            selector(i) = 1;
        end    
    elseif selector(i-1) == 1
        if rand < p_ka;
            selector(i) = 1;
        else
            selector(i) = 0;
        end
    end
end

%child = a.*selector + b.*~selector;
%child = a.*selector + b.*~selector;
child = a.*(selector*0.75+~selector*0.25) + b.*(~selector*0.75+selector*0.25);

%child = a.*(selectorm+1)/2 + b.*(~selectorm)/2;
end

function [spec_index] = roulet_for_specs(nfunctions,bestsolution_costs_splited)

total_roulet_spec_cost = 0;
%prealocation
roulet_spec_cost = zeros(1,nfunctions);
roulet_percentage = zeros(1,nfunctions);
%************
for i=1:nfunctions
    if bestsolution_costs_splited(i) <= 0
        %nothing
        roulet_spec_cost(i) = 0;
    else
        total_roulet_spec_cost = total_roulet_spec_cost + bestsolution_costs_splited(i); %put after the loop as sum
        roulet_spec_cost(i) = bestsolution_costs_splited(i);
    end
end
roulet_percentage(1) = roulet_spec_cost(1)/total_roulet_spec_cost;
for i=2:nfunctions
    roulet_percentage(i) =  roulet_percentage(i-1)+roulet_spec_cost(i)/total_roulet_spec_cost;
end
p_result = rand; % spin of the roulette
spec_index = 1;
for i=1:nfunctions
    if roulet_percentage(i) >= p_result
        spec_index = i;
        break
    end
end
end

function [new_sigma] = sigma_calculation(old_sigma,newenergy,oldenergy)
%calculation
xbad = -0.1;
xgood = 0.1;
xequal = 0;
maxdelta = 1.5;
meandelta = 1;
mindelta = 0.75;

x=(oldenergy-newenergy)/abs(oldenergy);
if (x<xbad)
    new_sigma=(mindelta)*old_sigma;    
elseif (x<xequal)
    new_sigma=(x*(meandelta-mindelta)/(xequal-xbad)+meandelta)*old_sigma;
elseif (x<xgood)
    new_sigma=(x*(meandelta-maxdelta)/(xgood-xequal)+maxdelta)*old_sigma;
else
    new_sigma=meandelta*old_sigma;
end

end

function [totaldistance] = totaldistance(newparam,memory)
%function [totaldistance] = totaldistance(newparam,bestsolution_x,anchor_x)

%totaldistance=sum(newparam-bestsolution_x);
totaldistance = 0;
for i=1:size(memory,1)
    totaldistance = totaldistance + sum(((newparam-memory(i,:)).^2));
end

end