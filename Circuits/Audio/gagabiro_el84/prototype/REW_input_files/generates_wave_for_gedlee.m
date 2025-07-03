% === GEDLEE Sweep Generator ===
% Generates a 1 kHz sine wave with stepwise increasing amplitude
% 0 to 1 V in 10 mV steps (101 steps total), each lasting 2 ms

fs = 48000;               % Sampling rate (Hz)
f_sine = 1000;            % Sine wave frequency (Hz)
step_duration = 0.002;    % Duration of each amplitude step (2 ms)
n_steps = 101;            % From 0 V to 1 V in 10 mV steps (inclusive)
t_total = step_duration * n_steps;
t = 0:1/fs:t_total - 1/fs;  % Time vector

% Create amplitude vector: 0 V, 0.01 V, ..., 1 V (101 levels)
amp = 0.01 * floor(t / step_duration);

% Generate the signal: 1 kHz sine modulated by amplitude
signal = amp .* sin(2 * pi * f_sine * t);

% Normalize for safety margin (optional)
signal = 0.99 * signal / max(abs(signal));

% Export the waveform as 32-bit float WAV
audiowrite('gedlee_sweep_float32.wav', signal', fs, 'BitsPerSample', 32);
disp('File "gedlee_sweep_float32.wav" successfully generated.');

% === Optional: Plot the first 20 ms ===
figure;
plot(t * 1000, signal, 'b');
xlabel('Time (ms)');
ylabel('Amplitude');
title('GedLee Sweep Signal (0 to 1 V, 1 kHz)');
grid on;
%xlim([0 20]);  % Plot first few steps for inspection
