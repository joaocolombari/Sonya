% Parâmetros do sinal
fs = 48000;           % taxa de amostragem
t = 0:1/fs:20;         % vetor de tempo (1 segundo)
f = 1000;             % frequência do sinal (1 kHz)
V_rms = 1.1883;          % tensão RMS desejada
V_peak = V_rms * sqrt(2);  % converter RMS para pico

% Gerar senoide full-scale
x = V_peak * sin(2*pi*f*t);

x_normalized = x / V_peak; % entre -1 e 1

sound(x_normalized, fs) % toca em full scale digital

% % Plot
% figure;
% plot(t(1:500), x(1:500)); % mostrar apenas primeiros ciclos
% xlabel('Tempo (s)');
% ylabel('Tensão (V)');
% title('Sinal Senoidal em Full-Scale');
% grid on;
