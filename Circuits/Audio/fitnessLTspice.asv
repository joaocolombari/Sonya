function [sc, sci] = fitnessLTspice(x)
%---------------------------------------------------%
% Fitness function for the GAGABIRO power amplifier %
% Viva Joao Bosco e Aldir Blanc!!                   %
% Author: Joao Victor Colombari Carlet              %
% Contact: jvccarlet@usp.br                         %
%---------------------------------------------------%

% sc gives the total score, and sci gives the partial scores
warning('off', 'all');

% this function calls LTspice XVII simulator and is entirelly made for
% using it. If you want to use any other one, go to CirOp.m and add it or
% just check if it is already there. Then you'd change where it matters,
% specially when simmulations are calld ;)

global slash;
global simuladorltspiceXVII;
global circuito;
global ParDados;
global genesLB;
global Best;
global BestRes;
global scorePlot;
global xT;
global modoind;
global modo;
global dif;
global snap;
global cont;
global contsuc;
global namext;
global contopt;

% takes targets from menu
target_Pow          = ParDados{1, 2};
target_Gain         = ParDados{2, 2}; 
target_THD          = ParDados{3, 2}; 
target_StdDev       = ParDados{4, 2};
target_Locut        = ParDados{5, 2}; 
target_Hicut        = ParDados{6, 2}; 
target_Slew         = ParDados{7, 2}; 
target_GedLee       = ParDados{8, 2}; 

% denormalizes genes
j = 1;
for i = 1:length(genesLB)
    if (dif(i) ~= 0)
        xr(i) = (x(j) * dif(i) + genesLB(i));
        xe(i) = x(j);
        j = j + 1;
    else
        xr(i) = genesLB(i);
        xe(i) = 0;
    end
    if (snap(i) ~= 0)
        xr(i) = round(xr(i) / snap(i)) * snap(i);
    end
end

% Print debug info
disp '______________________________'
cont = cont + 1;
fprintf('Simulation = %d (success = %d)\n', cont, contsuc);

% Print parameters used
for i = 1:length(xr)
    if (mod(i, 10) == 0)
        fprintf('\n');
    end
    fprintf('X%i = %1.2f   ', i, xr(i));
end
fprintf('\n');

%% New set of simulations and data capture

% Fitness captures results using custom functions 
% So far, we had used both LeMeas1 and file2tableF for doing this, but
% LTspice puts results into a distinct form, so we implemented
% file2tableLTspice and readFourierTable to take it.

% generates new set of genes into a param file
paramAC(circuito,xr);

simsuccess=0;

% First simmulation - tran for power and harmonic distortion
[a, b] = system([simuladorltspiceXVII circuito slash 'circuit_tran.sp']);
if a == 0
    disp('Simulation command ran successfully.');
else
    disp('Simulation command FAILED.');
    disp(b); % Show error text
end

% Captures gain, power and fourier outputs
output_power = file2table_LTspice(1, [circuito slash 'circuit_tran.log'], 'output_power');
gain_rms = file2table_LTspice(1, [circuito slash 'circuit_tran.log'], 'gain_rms');
[fourierTable, thd] = readFourierTable([circuito slash 'circuit_tran.log']);

% Quick check for the log
if (~isempty(output_power) || isempty(fourierTable) || isnan(thd))
    simsuccess = 1;
end

% Computes gain in db
gain_db = 20*log10(gain_rms);

% Second simmulation - AC
[a, b] = system([simuladorltspiceXVII circuito slash 'circuit_ac.sp']);
if a == 0
    disp('Simulation command ran successfully.');
else
    disp('Simulation command FAILED.');
    disp(b); % Show error text
end

% Captures AC measures

% Build list of variable names dynamically
varNames = {};   % initialize cell array

varNames = {'f20hz', 'f30hz', 'f40hz', 'f50hz', 'f70hz', ...
            'f100hz', 'f200hz', 'f500hz', 'f700hz', 'f1000hz', ...
            'f2000hz', 'f2122hz', 'f5000hz', 'f7000hz', 'f10000hz', 'f20000hz'};

AC_values = file2table_LTspice_ac(1, [circuito slash 'circuit_ac.log'], varNames{:});

fclo = file2table_LTspice(1, [circuito slash 'circuit_ac.log'],'fclo');
fchi = file2table_LTspice(1, [circuito slash 'circuit_ac.log'],'fchi');

if isempty(fclo), fclo = NaN; end
if isempty(fchi), fchi = NaN; end

% Quick check for the log
if ~isempty(AC_values) && all(~isnan(AC_values))
    simsuccess = 2;   % Simulation was successful
end

% Computes standard deviation of the frequency response
StdDev = std(AC_values);

% Third simmulation - tran for slew analysis
[a, b] = system([simuladorltspiceXVII circuito slash 'circuit_slew.sp']);
if a == 0
    disp('Simulation command ran successfully.');
else
    disp('Simulation command FAILED.');
    disp(b); % Show error text
end

% Captures slew variable
slew = file2table_LTspice(1, [circuito slash 'circuit_slew.log'],'slew');

% Quick check for the log
if (~isempty(slew))
    simsuccess = 3;
end

slew_rate = abs(slew)*1e6;

% Fourth simulation - tran for GedLee metric
[a, b] = system([simuladorltspiceXVII circuito slash 'circuit_gedlee.sp']);
if a == 0
    disp('Simulation command ran successfully.');
else
    disp('Simulation command FAILED.');
    disp(b); % Show error text
end

% Build list of variable names dynamically
varNames = {};   % reset cell array

for i = 0:100
    varNames{end+1} = ['min' num2str(i)];  % adds 'MIN0', 'MIN1', ..., 'MIN100'
    varNames{end+1} = ['max' num2str(i)];  % adds 'MAX0', 'MAX1', ..., 'MAX100'
end

% captures variables
gedlee_values = file2table_LTspice(1, [circuito slash 'circuit_gedlee.log'], varNames{:});

% Quick check for the log 
if any(~isnan(gedlee_values))
    simsuccess = 4;   % Simulation was successful
end

%% --- Post-Simulation Data Processing ---

% 1. Gain Evaluation (dB scale)
FGA = scoreAv(gain_db, target_Gain);  

% 2. Output Power Evaluation
FOP = scoreAv(output_power, target_Pow);

% 3. Total Harmonic Distortion (THD)
FHD = scoreAv(thd, target_THD);

% 4. Standard Deviation of Frequency Response (AC)
FSD = scoreAv(StdDev, target_StdDev);

% 5. Low-Frequency Cutoff Point (Hz)
FLC = scoreAv(fclo, target_Locut);

% 6. High-Frequency Cutoff Point (Hz)
FHC = scoreAv(fchi, target_Hicut);

% 7. Slew Rate (V/µs)
FSL = scoreAv(slew_rate, target_Slew); % Converts to V/us

% 8. GedLee Metric (Nonlinear distortion metric)
FGL = scoreAv(gedlee_values, target_GedLee);

% Ensure all components are valid numbers
score_parts = [FGA, FOP, FHD, FSD, FLC, FHC, FSL, FGL];
if any(cellfun(@isempty, {FGA, FOP, FHD, FSD, FLC, FHC, FSL, FGL})) || any(~isfinite(score_parts))
    warning('❌ One or more score components is missing or invalid. Assigning infinite score.');
    sc = inf;
    sci = inf(1, 8);
    return;
end

% --- Final Score Calculation ---
% A sum-of-squares strategy that heavily penalizes poor performance
sc = (FGA + FOP + FHD + FSD + FLC + FHC + FSL + FGL)^2

% --- Store individual score components ---
sci = [FGA, FOP, FHD, FSD, FLC, FHC, FSL, FGL];

% --- Count successful simulation runs ---
contsuc = contsuc + 1;

%% outputs

if Best.score > sc
    Best.score = sc;

    % Clean previous results only at the start of optimization
    optimosFile = [circuito slash 'results' slash 'optimos.' modo namext];
    if cont == 1 && exist(optimosFile, "file")
        delete(optimosFile);
    end

    % Append new result
    arq = fopen(optimosFile, 'a+');
    fprintf(arq, 'run: %4d\tScore = %.3e\n', cont, sc);
    fclose(arq);
    beep;

    % Save current best parameters to paramop
    % Define the output file path
    paramopFile = [circuito slash 'results' slash 'paramop_results' namext];
    % Delete previous version if it exists
    if exist(paramopFile, "file")
        delete(paramopFile);
    end
    % Open new file for writing
    arq = fopen(paramopFile, 'w');
    % Write results to the file
    fprintf(arq, ['* Best Solution Summary\n' ...
        '* Score = %.4g\n' ...
        '* Gain = %.2fdB (Score = %.2f)\n' ...
        '* Output Power = %.2fW (Score = %.2f)\n' ...
        '* THD = %.4f%% (Score = %.2f)\n' ...
        '* Std Dev (Freq Response) = %.2f dB (Score = %.2f)\n' ...
        '* Low Cutoff = %.2f Hz (Score = %.2f)\n' ...
        '* High Cutoff = %.2f Hz (Score = %.2f)\n' ...
        '* Slew Rate = %.2f V/us (Score = %.2f)\n' ...
        '* GedLee Score = %.2f (Score = %.2f)\n'], ...
        sc, gain_db, FGA, output_power, FOP, thd, FHD, StdDev, FSD, ...
        fclo, FLC, fchi, FHC, slew_rate, FSL, gedlee_values, FGL);
    fclose(arq);

    % Write the optimized parameters in LTspice param for include
    paramOpt(circuito, xr, 'paramop'); 

    % Save best solution overall (BestT)
    if Best.scoreT > sc
        Best.scoreT = sc;
        Best.parameters = xr;
        xT = x;

        % Define output file path
        paramopTFile = [circuito slash 'results' slash 'paramopT_results' namext];
        % Delete previous file if it exists
        if exist(paramopTFile, "file")
            delete(paramopTFile);
        end
        % Open new file for writing
        arq = fopen(paramopTFile, 'w');
        % Write top solution summary
        fprintf(arq, ['* Top Solution (BestT)\n' ...
            '* Score = %.4g\n' ...
            '* Gain = %.2fdB (Score = %.2f)\n' ...
            '* Output Power = %.2fW (Score = %.2f)\n' ...
            '* THD = %.4f%% (Score = %.2f)\n' ...
            '* Std Dev (Freq Response) = %.2f dB (Score = %.2f)\n' ...
            '* Low Cutoff = %.2f Hz (Score = %.2f)\n' ...
            '* High Cutoff = %.2f Hz (Score = %.2f)\n' ...
            '* Slew Rate = %.2f V/us (Score = %.2f)\n' ...
            '* GedLee Score = %.2f (Score = %.2f)\n'], ...
            sc, gain_db, FGA, output_power, FOP, thd, FHD, StdDev, FSD, ...
            fclo, FLC, fchi, FHC, slew_rate, FSL, gedlee_values, FGL);
        fclose(arq);

        % Write the optimized parameters in LTspice param for include
        paramOpt(circuito, xr, 'paramopT');       

        % Save result to memory
        BestRes{modoind} = Best;
    end
end
                    
% --- Plot optimization score history and compare current vs best parameters ---

if size(scorePlot,1) < 2
    scorePlot = zeros(2,0);  % Initialize as empty 2-row matrix
end

scorePlot(:, end+1) = [cont; sc];  % Append both values at once

% Create or update figure
figure(711);
set(711, ...
    'Name', [circuito ': Iteration=' num2str(contopt, '%.1f') ...
             ', Best Score=' num2str(Best.scoreT, '%1.3g')], ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none');

% --- Subplot 1: Score evolution ---
subplot(2, 1, 1);
semilogy(scorePlot(1, :), scorePlot(2, :), 'o-');  % semilog y-axis for better visibility
xlabel('Iteration');
ylabel('Score');
title('Score Evolution');

% --- Subplot 2: Parameter comparison ---
subplot(2, 1, 2);
xp = [x; xT]';  % x = current solution, xT = best solution
bar(xp, 'grouped');
legend('Current', 'Best', 'Location', 'northeast');
xlabel('Parameter Index');
ylabel('Parameter Value');
title(['Parameter Comparison | Current Score = ' num2str(sc, '%1.3g')]);

pause(0.2);  % Allow time for plot to update smoothly
               
% --- Handle simulation failures ---
if simsuccess ~= 4
    sc = inf('double');  % Assign infinite score on failure
    sci = inf(1, 8);      % Assuming 8 evaluation metrics in current setup

    fprintf('\n⚠️ Simulation Error Detected | Score = %.3g\n', sc);

    switch simsuccess
        case 0
            fprintf('❌ Error in first simulation (transient - power/THD).\n');
        case 1
            fprintf('❌ Error reading AC file.\n');
        case 2
            fprintf('❌ Error reading TR file 0 (likely gain or power).\n');
        case 3
            fprintf('⚠️ Partial success, likely failed at slew or GedLee.\n');
        otherwise
            fprintf('❓ Unknown simulation status.\n');
    end

    % Optionally log known metrics if they were partially available
    if exist('gain_rms', 'var'),      fprintf('Gain (dB) = %.3g dB\n', gain_db); end
    if exist('output_power', 'var'),  fprintf('Output Power = %.3g W\n', output_power); end
    if exist('thd', 'var'),           fprintf('THD = %.4g %%\n', thd); end
    if exist('std_dev_ac', 'var'),    fprintf('AC Response Std. Dev. = %.3g dB\n', StdDev); end
    if exist('fclo', 'var'),          fprintf('Low Cutoff Frequency = %.3g Hz\n', fclo); end
    if exist('fchi', 'var'),          fprintf('High Cutoff Frequency = %.3g Hz\n', fchi); end
    if exist('slew', 'var'),          fprintf('Slew Rate = %.3g V/us\n', slew_rate); end
    if exist('gedlee_values', 'var') && ~isempty(gedlee_values)
        fprintf('GedLee Metric (max peak-to-peak) = %.3g V\n', max(gedlee_values) - min(gedlee_values));
end

% --- Print current parameter values ---
fprintf('\n🔧 Used Parameters:\n');
for i = 1:length(xr)
    fprintf('X%02d = %8.2f   ', i, xr(i));
    if mod(i, 5) == 0, fprintf('\n'); end  % print 5 per line
end
fprintf('\n\n');

end

