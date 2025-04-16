function [xmin,fmin,histout] = PSOQ(fun,x0,lb,ub,maxeval,D,nPop,maxit, neigh)
% https://www.mathworks.com/matlabcentral/fileexchange/69145-quantum-behaved-particle-swarm-optimization
% https://www.youtube.com/watch?v=G53AwRaZR1M
% INPUT:
%   fun     : function handle for optimization
%   D       : problem dimension (number of variables)
%   nPop    : number of particles in the swarm
%   lb      : lower bound constrain
%   ub      : upper bound constrain
%   maxit   : max number of iterations
%   maxeval : max number of function evaluations
% OUTPUT:
%   xmin    : best solution found
%   fmin    : function value at the best solution, f(xmin)
%   histout : record of function evaluations and fitness value by iteration
%   neigh   : vizinhanca da solucao inicial onde serã pegas a outras solucoes
% EXAMPLE:
% fun = @griewankfcn;
% D = 30;
% nPop = 50;
% lb = -600;
% ub = 600;
% maxit = 1000;
% maxeval = 10000*D;
% [xmin,fmin,histout] = QPSO(fun,D,nPop,lb,ub,maxit,maxeval);
% OR DIRECTLY:
% [xmin,fmin,histout] = QPSO(@griewankfcn,30,50,-600,600,1000,10000*30);
% QPSO parameters:
w1 = 0.3;
w2 = 1.0;
c1 = 1.0;
c2 = 1.5;

% Initializing solution
%x = unifrnd(lb,ub,[nPop,D]);
% Evaluate initial population
x = zeros(nPop,D);
f_x = zeros(1,nPop);
lbx0 = max(x0(:)-neigh*(ub(:)-lb(:)), lb(:));
ubx0 = min(x0(:)+neigh*(ub(:)-lb(:)), ub(:));
for i = 1:nPop,
    if i == 1,
       x(1,:) = x0(:)';
    else
       x(i,:) = lbx0(:)' + rand(1,D).*(ubx0(:)'-lbx0(:)'); %Origimal
    end;
    f_x(i) = feval(fun,x(i,:));
end

pbest = x;
histout = zeros(maxit,2);
%f_x = feval(fun,x)
fval = nPop;
f_pbest = f_x;
[~,g] = min(f_pbest);
gbest = pbest(g,:);
f_gbest = f_pbest(g);
it = 1;
histout(it,1) = fval;
histout(it,2) = f_gbest;
while it < maxit && fval < maxeval
% faz o b variar sendo maior no inicio, converge mais lentamente, e menor ao fim
    fprintf('_______termino da iteraçao = %d___________\n', it);
    alpha = (w2 - w1) *(((maxit - it)/maxit)) + w1;
% revised version
    mbest = sum(pbest)/nPop;
    mbest=0;
    cont=0;
    for i=1:nPop
      if f_pbest(i) < inf('double')
        mbest=mbest+pbest(i,:);
        cont=cont+1;
      end;
    end;
    mbest=mbest/cont;

    for i = 1:nPop
        fi = rand(1,D);
% Local atractor 
        p = (c1*fi.*pbest(i,:) + c2*(1-fi).*gbest)./(c1*fi + c2*(1-fi));
        %p = (c1*fi.*pbest(i,:) + c2*(1-fi).*gbest)/(c1 + c2);
        u = rand(1,D);
        
        b = alpha*abs(x(i,:) - mbest);
        v = sqrt(log(1./u));
        %v = log(1./u);
        if rand < 0.5
            x(i,:) = p + b .* v;
        else
            x(i,:) = p - b .* v;
        end;

        % Keeping bounds
        x(i,:) = max(x(i,:),lb);
        x(i,:) = min(x(i,:),ub);
        f_x(i) = feval(fun,x(i,:));
        
        fval = fval + 1;
        if f_x(i) < f_pbest(i)
            pbest(i,:) = x(i,:);
            f_pbest(i) = f_x(i);
        end
        if f_pbest(i) < f_gbest
            gbest = pbest(i,:);
            f_gbest = f_pbest(i);
        end
    end
    
    it = it + 1;
    histout(it,1) = fval;
    histout(it,2) = f_gbest;
end
xmin = gbest; 
fmin = f_gbest;
histout(it+1:end,:) = [];
%figure
%semilogy(histout(:,1),histout(:,2))
%title('Gaussian Q-PSO')
%xlabel('Function evaluations')
%ylabel('Fitness')
%grid on
end