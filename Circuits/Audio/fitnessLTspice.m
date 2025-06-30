function [sc, sci] = fitnessLTspice(x)
%---------------------------------------------------%
% Fitness function for the GAGABIRO power amplifier %
% Viva Joao Bosco e Aldir Blanc!!                   %
% Author: Joao Victor Colombari Carlet              %
% Contact: jvccarlet@usp.br                         %
%---------------------------------------------------%

warning('off', 'all');

global slash simuladorltspiceXVII circuito ParDados genesLB Best BestRes ...
       scorePlot xT modoind modo dif snap cont contsuc namext contopt;

% === Target limits ===
target_Vaa    = ParDados{1, 2};
target_Pow    = ParDados{2, 2};
target_Gain   = ParDados{3, 2}; 
target_THD    = ParDados{4, 2}; 
target_StdDev = ParDados{5, 2};
target_Locut  = ParDados{6, 2}; 
target_Hicut  = ParDados{7, 2}; 
target_Slew   = ParDados{8, 2}; 
target_GedLee = ParDados{9, 2}; 

% === Denormalization ===
j = 1;
xr = zeros(size(genesLB));
for i = 1:length(genesLB)
    if dif(i) ~= 0
        xr(i) = x(j) * dif(i) + genesLB(i);
        xe(i) = x(j);
        j = j + 1;
    else
        xr(i) = genesLB(i);
        xe(i) = 0;
    end
    if snap(i) ~= 0
        xr(i) = round(xr(i) / snap(i)) * snap(i);
    end
end

% === Debug ===
disp '______________________________'
cont = cont + 1;
fprintf('Simulation = %d (success = %d)\n', cont, contsuc);
for i = 1:length(xr)
    fprintf('X%02d = %1.2f   ', i, xr(i));
    if mod(i, 5) == 0, fprintf('\n'); end
end
fprintf('\n');

% === Simulation Setup ===
step_success = false(1, 4);  % [powerTHD, acSweep, slewRate, gedlee]

% === Power Supply Voltage ===
vaa = xr(24);

% === TRAN: Power & THD ===
paramAC(circuito, xr, 'tran');
success = runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
if ~success
    paramAC(circuito, xr, 'tran', 0.01);
    runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20); 
    % if doesnt work again, log will be empty and meas fails, thus no 
    % further check is necessary 
end
output_power = file2table_LTspice(1, [circuito slash 'circuit.log'], 'output_power');
gain_rms     = file2table_LTspice(1, [circuito slash 'circuit.log'], 'gain_rms');
[~, thd]     = readFourierTable([circuito slash 'circuit.log']);
if ~isempty(output_power) && ~isempty(gain_rms) && ~isnan(thd)
   step_success(1) = true;
end
gain_db = 20 * log10(gain_rms);


% === AC Sweep ===
paramAC(circuito, xr, 'ac');
success = runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
if ~success
    paramAC(circuito, xr, 'ac', 0.01);
    runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
end
varNames = {'f20hz','f30hz','f40hz','f50hz','f70hz','f100hz', ...
            'f200hz','f500hz','f700hz','f1000hz','f2000hz','f2122hz', ...
            'f5000hz','f7000hz','f10000hz','f20000hz'};
AC_values = file2table_LTspice_ac(1, [circuito slash 'circuit.log'], varNames{:});
fclo = file2table_LTspice(1, [circuito slash 'circuit.log'], 'fclo'); if isempty(fclo), fclo = NaN; end
fchi = file2table_LTspice(1, [circuito slash 'circuit.log'], 'fchi'); if isempty(fchi), fchi = NaN; end
if ~isempty(AC_values) && all(~isnan(AC_values))
    step_success(2) = true;
end
StdDev = std(AC_values);

% === TRAN: Slew Rate ===
paramAC(circuito, xr, 'slew');
success = runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
if ~success
    paramAC(circuito, xr, 'slew', 0.01);
    runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
end
slew = file2table_LTspice(1, [circuito slash 'circuit.log'], 'slew');
if ~isempty(slew)
    step_success(3) = true;
end
slew_rate = abs(slew) * 1e-6;


% === TRAN: GedLee ===
paramAC(circuito, xr, 'gedlee');
success = runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
if ~success
    paramAC(circuito, xr, 'gedlee', 0.01);
    runsSafe(simuladorltspiceXVII, [circuito slash 'circuit.sp'], 20);
end
varNames = {}; 
for i = 0:100; 
    varNames{end+1} = ['min' num2str(i)]; 
    varNames{end+1} = ['max' num2str(i)]; 
end
gedlee_values = file2table_LTspice(1, [circuito slash 'circuit.log'], varNames{:});
if any(~isnan(gedlee_values))
    step_success(4) = true;
end
gm = gedlee_from_meas(gedlee_values(1:2:end), gedlee_values(2:2:end));

% === Score Computation ===
FVA = scoreAv(vaa,          target_Vaa);
FGA = scoreAv(gain_db,      target_Gain);  
FOP = scoreAv(output_power, target_Pow);
FHD = scoreAv(thd,          target_THD);
FSD = scoreAv(StdDev,       target_StdDev);
FLC = scoreAv(fclo,         target_Locut);
FHC = scoreAv(fchi,         target_Hicut);
FSL = scoreAv(slew_rate,    target_Slew);
FGL = scoreAv(gm,           target_GedLee);

result_parts = [vaa, gain_db, output_power, thd, StdDev, fclo, fchi, slew_rate, gm];
score_parts = [FVA, FGA, FOP, FHD, FSD, FLC, FHC, FSL, FGL];

% === Failure case ===
if ~all(step_success)
    sc = inf; sci = inf(1,9);
    failed_steps = find(~step_success);
    fprintf('\n❌ Simulation failed at step(s): %s. Score = %.3g\n', num2str(failed_steps), sc);
elseif any(~isfinite(score_parts))
    fprintf('❌ Invalid score component detected. Assigning Inf.\n');
    sc = inf; sci = inf(1,9);
else
    sc  = (sum(score_parts))^2;
    sci = score_parts;
    contsuc = contsuc + 1;
end

% === Best Score Logging ===
if Best.score > sc
    Best.score = sc;

    % --- Logs run and score in optimosFile --- %
    optimosFile = [circuito slash 'results' slash 'optimos.' modo namext];
    if cont == 1 && exist(optimosFile, "file")
        delete(optimosFile);
    end

    % Append new result
    arq = fopen(optimosFile, 'a+');
    fprintf(arq, 'run: %4d\tScore = %.3e\n', cont, sc);
    fclose(arq);
    beep;

    % --- Logs results summary in paramopFile --- %
    % Delete old result file only at the beginning
    paramopFile = [circuito slash 'results' slash 'paramop_results' namext];
    if cont == 1 || exist(paramopFile, "file")
        delete(paramopFile);
    end

    % Save paramop summary
    arq = fopen(paramopFile, 'w');
    fprintf(arq, ['* Best Solution Summary\n\n' ...
        '* Score = %.4g\n' ...
        '* Vaa = %.2fV (Score = %.2f)\n' ...
        '* Gain = %.2fdB (Score = %.2f)\n' ...
        '* Output Power = %.2fW (Score = %.2f)\n' ...
        '* THD = %.4f%% (Score = %.2f)\n' ...
        '* Std Dev (Freq Response) = %.2f dB (Score = %.2f)\n' ...
        '* Low Cutoff = %.2f Hz (Score = %.2f)\n' ...
        '* High Cutoff = %.2f Hz (Score = %.2f)\n' ...
        '* Slew Rate = %.2f V/us (Score = %.2f)\n' ...
        '* GedLee = %.2f (Score = %.2f)\n\n'], ...
        sc, vaa, FVA, gain_db, FGA, output_power, FOP, thd, FHD, StdDev, FSD, ...
        fclo, FLC, fchi, FHC, slew_rate, FSL, gm, FGL);
    fprintf(arq, '\n* Best Solution Vector:\n');
    fprintf(arq, '%g ', xr);
    fprintf(arq, '\n');
    fclose(arq);

    paramOpt(circuito, xr, 'paramop', sc, cont, result_parts, sci); % Save param file

    % === Rounded Param File (E-series) ===
    xr_rounded = roundToEseries(xr, ...
        'res_idx', 1:18, 'res_series', 'e24', ...
        'cap_idx', 19:23, 'cap_series', 'e12');
    
    paramOpt(circuito, xr_rounded, 'paramop_rounded');

    % Save best of all time
    if Best.scoreT > sc
        Best.scoreT = sc;
        Best.parameters = xr;
        xT = x;

        % Define output file path
        paramopTFile = [circuito slash 'results' slash 'paramopT_results' namext];
        if cont == 1 || exist(paramopTFile, "file")
            delete(paramopTFile);
        end

        % Save paramopT summary
        arq = fopen(paramopTFile, 'w');
        fprintf(arq, ['* Top Solution (BestT) Summary\n\n' ...
            '* Score = %.4g\n' ...
            '* Vaa = %.2fV (Score = %.2f)\n' ...
            '* Gain = %.2fdB (Score = %.2f)\n' ...
            '* Output Power = %.2fW (Score = %.2f)\n' ...
            '* THD = %.4f%% (Score = %.2f)\n' ...
            '* Std Dev (Freq Response) = %.2f dB (Score = %.2f)\n' ...
            '* Low Cutoff = %.2f Hz (Score = %.2f)\n' ...
            '* High Cutoff = %.2f Hz (Score = %.2f)\n' ...
            '* Slew Rate = %.2f V/us (Score = %.2f)\n' ...
            '* GedLee = %.2f (Score = %.2f)\n\n'], ...
            sc, vaa, FVA, gain_db, FGA, output_power, FOP, thd, FHD, StdDev, FSD, ...
            fclo, FLC, fchi, FHC, slew_rate, FSL, gm, FGL);
        fprintf(arq, '\n* Best Solution Vector:\n');
        fprintf(arq, '%g ', xr);
        fprintf(arq, '\n');
        fclose(arq);

        paramOpt(circuito, xr, 'paramopT', sc, cont, result_parts, score_parts);


        % === Rounded Param File (E-series) ===
        xr_rounded = roundToEseries(xr, ...
            'res_idx', 1:18, 'res_series', 'e24', ...
            'cap_idx', 19:23, 'cap_series', 'e12');
        
        paramOpt(circuito, xr_rounded, 'paramopT_rounded');

        BestRes{modoind} = Best;
    end
end

% === Plotting === 
if sc == Best.scoreT
    if size(scorePlot,1) < 2
        scorePlot = zeros(2,0);
    end
    scorePlot(:, end+1) = [cont; sc];
    
    figure(711);
    set(711, 'Name', [circuito ': Iteration=' num2str(contopt, '%.1f') ...
                      ', Best Score=' num2str(Best.scoreT, '%1.3g')], ...
        'NumberTitle', 'off', 'MenuBar', 'none');
    subplot(2,1,1); semilogy(scorePlot(1,:), scorePlot(2,:), '.'); title('Score Evolution');
    xlabel('Iteration'); ylabel('Score');
    subplot(2,1,2); bar([x; xT]', 'grouped');
    legend('Current', 'Best'); title(['Parameter Comparison | Score = ' num2str(sc,'%1.3g')]);
    pause(0.2);
end

end
