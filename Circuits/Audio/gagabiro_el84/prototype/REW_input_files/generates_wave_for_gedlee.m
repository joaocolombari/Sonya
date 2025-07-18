% === GEDLEE Sweep Generator (20s repeat) ===

fs = 48000;               % Sampling rate (Hz)
f_sine = 1000;            % Sine wave frequency (Hz)
step_duration = 0.002;    % Duration of each amplitude step (2 ms)
n_steps = 101;            % From 0 V to 1 V in 10 mV steps (101 total)
t_one_sweep = step_duration * n_steps;

% Time vector for one sweep cycle
t = 0:1/fs:t_one_sweep - 1/fs;

% Amplitude vector: 0 V, 0.01 V, ..., 1 V
amp = 0.01 * floor(t / step_duration);

% Base sweep signal: 1 kHz sine modulated by stepwise amplitude
one_sweep = amp .* sin(2 * pi * f_sine * t);

% Repeat to fill exactly 20 seconds
n_repeats = floor(20 / t_one_sweep);  % Number of full repetitions
signal = repmat(one_sweep, 1, n_repeats);

% Ensure exact 20 s duration (trim any excess samples)
total_samples = min(length(signal), fs * 20);
signal = signal(1:total_samples);


% Normalize signal to 99% of full-scale peak (based on 1.1883 Vrms)
V_rms_fullscale = 1.1883;
V_peak_fullscale = V_rms_fullscale * sqrt(2);
signal = signal / (max(abs(signal)) * V_peak_fullscale);

% Save as 32-bit float WAV file
audiowrite('gedlee_sweep_20s_float32.wav', signal', fs, 'BitsPerSample', 32);
disp('File "gedlee_sweep_20s_float32.wav" successfully generated.');

% Plot the first sweep cycle (20 ms)
figure;
plot((0:length(t)-1)/fs * 1000, one_sweep);
xlabel('Time (ms)');
ylabel('Amplitude (V)');
title('GedLee Sweep (First Cycle)');
grid on;
