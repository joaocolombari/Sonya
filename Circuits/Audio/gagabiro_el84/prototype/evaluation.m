function [sc, sci] = evaluation(directory_name, vaa)

warning('off', 'all');

global ParDados 

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

fprintf('Evaluating directory: %s\n\n', directory_name);

%% === TRAN: Power & THD ===
tran_file = fullfile(directory_name, 'tran.txt');
if ~exist(tran_file, 'file')
    warning('TRAN file not found: %s', tran_file);
    sc = NaN; sci = NaN; return;
end

data = readREWScope(tran_file, 'window_ms', 100, 'trim_mode', 'zero');

input_voltage = 10^(-1/2);              % -10dBV in RMS Volts
output_voltage = rms(data.voltage);     
gain_rms = output_voltage / input_voltage;
output_power = output_voltage^2 / 6;    % 6Ω speaker
gain_db = 20 * log10(gain_rms);

% --- THD calculation ---
totalhd=100*10^(thd(data.voltage, data.fs, 10)/20);

%% === AC Sweep ===
ac_file = fullfile(directory_name, 'ac.txt');
if ~exist(ac_file, 'file')
    warning('AC Sweep file not found: %s', ac_file);
    sc = NaN; sci = NaN; return;
end

data = readREWMeasurement(ac_file);

f_target = [20 30 40 50 70 100 200 500 700 1000 2000 2122 5000 7000 10000 20000];
AC_values = interp1(log10(data.freq), data.mag_dB, log10(f_target), 'pchip', 'extrap');

[gmax, idx_max] = max(data.mag_dB);
target = gmax / sqrt(2);

% Low cutoff
idx_low = find(data.mag_dB(1:idx_max) <= target, 1, 'last');
fclo = interp1(data.mag_dB(idx_low:idx_low+1), data.freq(idx_low:idx_low+1), target);

% High cutoff
idx_high = find(data.mag_dB(idx_max:end) <= target, 1, 'first');
if ~isempty(idx_high) && idx_high > 1
    idx_high = idx_high + idx_max - 1;
    fchi = interp1(data.mag_dB(idx_high-1:idx_high), data.freq(idx_high-1:idx_high), target);
else
    fchi = inf;
    warning('High cutoff frequency out of measurement range.');
end

StdDev = std(AC_values);

%% === TRAN: Slew Rate ===
slew_file = fullfile(directory_name, 'rise_and_fall.txt');
if ~exist(slew_file, 'file')
    warning('Rise & Fall file not found: %s', slew_file);
    sc = NaN; sci = NaN; return;
end

data = readREWScope(slew_file, 'window_ms', 10, 'trim_mode', 'zero');

Vmax = max(data.voltage);
Vmin = min(data.voltage);
Vmid = (Vmax + Vmin)/2;

dy = diff(data.voltage) ./ diff(data.time);      % dV/dt
[~, idx] = min(abs(data.voltage - Vmid));
slew_rate = abs(dy(idx)) * 1e-6;  % Convert V/s -> V/μs

%% === TRAN: GedLee ===
ged_file = fullfile(directory_name, 'gedlee.txt');
if ~exist(ged_file, 'file')
    warning('GedLee file not found: %s', ged_file);
    sc = NaN; sci = NaN; return;
end

data = readREWScope(ged_file, 'window_ms', 202, 'trim_mode', 'gedlee');

window_ms = 2;
window_samples = round(data.fs * window_ms / 1000);
n_windows = floor(length(data.voltage)/window_samples);

max_vals = zeros(1, n_windows);
min_vals = zeros(1, n_windows);

for k = 1:n_windows
    idx_start = (k-1)*window_samples + 1;
    idx_end   = k*window_samples;
    segment   = data.voltage(idx_start:idx_end);

    max_vals(k) = max(segment);
    min_vals(k) = min(segment);
end

gm = gedlee_from_meas(min_vals, max_vals, 'plot', true);

%% === Score Computation ===
FVA = scoreAv(vaa,          target_Vaa);
FGA = scoreAv(gain_db,      target_Gain);  
FOP = scoreAv(output_power, target_Pow);
FHD = scoreAv(totalhd,      target_THD);
FSD = scoreAv(StdDev,       target_StdDev);
FLC = scoreAv(fclo,         target_Locut);
FHC = scoreAv(fchi,         target_Hicut);
FSL = scoreAv(slew_rate,    target_Slew);
FGL = scoreAv(gm,           target_GedLee);

score_parts = [FVA, FGA, FOP, FHD, FSD, FLC, FHC, FSL, FGL];

sc  = (sum(score_parts))^2;
sci = score_parts;

%% === Log results ===
results_file = fullfile(directory_name, 'results.txt');
arq = fopen(results_file, 'w');  % overwrite once

fprintf(arq, '* Evaluation of measured results in directory: %s\n\n', directory_name);
fprintf(arq, '* Score = %.4g\n', sc);
fprintf(arq, '* Vaa = %.2fV (Score = %.2f)\n', vaa, FVA);
fprintf(arq, '* Gain = %.2fdB (Score = %.2f)\n', gain_db, FGA);
fprintf(arq, '* Output Power = %.2fW (Score = %.2f)\n', output_power, FOP);
fprintf(arq, '* THD = %.4f%% (Score = %.2f)\n', totalhd, FHD);
fprintf(arq, '* Std Dev (Freq Response) = %.2f dB (Score = %.2f)\n', StdDev, FSD);
fprintf(arq, '* Low Cutoff = %.2f Hz (Score = %.2f)\n', fclo, FLC);
fprintf(arq, '* High Cutoff = %.2f Hz (Score = %.2f)\n', fchi, FHC);
fprintf(arq, '* Slew Rate = %.2f V/us (Score = %.2f)\n', slew_rate, FSL);
fprintf(arq, '* GedLee = %.2f (Score = %.2f)\n', gm, FGL);

fclose(arq);

end