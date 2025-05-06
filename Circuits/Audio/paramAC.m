function paramAC(circuito, x, mode)
% paramAC - Generates the parameter file "param" for SPICE simulation
% 
% This function writes parameter values into a text file to be used
% by the Gagabiro Valve Power Amplifier circuit in LTspice.
%
% INPUTS:
%   circuito - folder or path where the circuit files are stored (string)
%   x        - vector of design parameters (length 25)
%   mode     - selects the desired simmulation mode - tran, ac, slew or gedlee
%
% Author: João Victor Colombari Carlet
% Email:  jvccarlet@usp.br

warning('off', 'all');

% OS-independent file separator
slash = filesep;

if nargin == 0
    error('You need to specify the sile path, the gene vector and the mode: tran, ac, slew or gedlee');
end

% --- Delete old param file if it exists ---
paramFile = [circuito slash 'param'];
if exist(paramFile, "file")
    system(['del "' paramFile '"']);
end

% --- Open new file for writing ---
arq = fopen(paramFile, 'w');

% --- Write file header ---
fprintf(arq, ['***************************************\n' ...
              '*** GAGABIRO VALVE POWER AMPLIFIER ***\n' ...
              '*** AUTHOR:  JOAO CARLET            ***\n' ...
              '*** CONTACT: JVCCARLET@USP.BR       ***\n' ...
              '***************************************\n\n']);

% --- Write resistor parameters (X1 to X18) ---
fprintf(arq, '* RESISTORS\n');
for i = 1:18
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% --- Write capacitor parameters (X19 to X23) ---
fprintf(arq, '\n* CAPACITORS\n');
for i = 19:23
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% --- Write power supply voltages (X24 and X25) ---
fprintf(arq, '\n* VOLTAGE SOURCES\n');
for i = 24:25
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

switch lower(mode)
    case 'tran'
        src = [
            '\n* SOURCES\n' ...
            'V4 V_PP 0 {int(X24)}\n' ...
            'V5 V_in 0 SINE(0 0.447 1k) AC 1\n' ...
            'V1 V_grid 0 {int(X25)}\n'
        ];
        cmd = [
            '\n* COMMANDS\n' ...
            '.OPTIONS numdgt=7\n' ...
            '.OPTIONS plotwinsize=0\n' ...
            '.four 1k 10 V(out)\n' ...
            '.tran 0 100m 0 10u\n' ...
            '.probe v(out) i(Rload) v(v_in)\n' ...
            '.meas tran output_power RMS I(RLoad)*v(out)\n' ...
            '.meas TRAN Vout_rms RMS V(out)\n' ...
            '.meas TRAN Vin_rms  RMS V(v_in)\n' ...
            '.meas TRAN Gain_rms PARAM Vout_rms/Vin_rms\n'
        ];

    case 'ac'
        src = [
            '\n* SOURCES\n' ...
            'V4 V_PP 0 {int(X24)}\n' ...
            'V5 V_in 0 SINE(0 0.447 1k) AC 1\n' ...
            'V1 V_grid 0 {int(X25)}\n'
        ];

        % Frequências de interesse (em Hz)
        freqs = [20 30 40 50.05 70 100 200 500 700 1000 2000 2122 5000 7000 10000 20000];
        base_meas = '.meas AC f%dhz find v(out) at=%g\n';
        lines = arrayfun(@(f) sprintf(base_meas, round(f), f), freqs, 'UniformOutput', false);
        freq_meas_block = strjoin(lines, '');

        cmd = [
            '\n* COMMANDS\n' ...
            '.ac dec 100 0.01 100meg\n' ...
            '.probe v(out)\n' ...
            '.meas gmax max(mag(V(out)))\n' ...
            '.meas AC fchi FROM 0 TARG mag(V(out))=gmax/sqrt(2) FALL=1\n' ...
            '.meas AC fclo FROM 0 TARG mag(V(out))=gmax/sqrt(2) RISE=1\n' ...
            freq_meas_block
        ];

    case 'slew'
        src = [
            '\n*SOURCES\n' ...
            'V4 V_PP 0 {int(X24)}\n' ...
            'V5 V_in 0 PULSE(-0.447 0.447 0 10p 10p 1m 2m) AC 1\n' ...
            'V1 V_grid 0 {int(X25)}\n'
        ];
        cmd = [
            '\n* COMMANDS\n' ...
            '.tran 0 0.2 0.19 100u\n' ...
            '.probe v(out)\n' ...
            '.MEASURE TRAN MAXSLEW MAX V(OUT)\n' ...
            '.MEASURE TRAN MINSLEW MIN V(OUT)\n' ...
            '.MEASURE TRAN SLEW DERIV V(OUT) WHEN V(OUT)=(MAXSLEW+MINSLEW)/2\n'
        ];

    case 'gedlee'
        src = [
            '\n* SOURCES\n' ...
            'V2 V_PP 0 {int(X24)}\n' ...
            'V6 V_grid 0 {int(X25)}\n' ...
            'B1 V_in 0 V=v(amp)*sin(2*pi*1000*time)\n' ...
            'B2 amp 0 V={10m*ceil(time*500)-10m}\n' ...
            'B3 tref 0 V={1*time}\n'
        ];
        base_meas = '.MEAS TRAN MIN%d MIN V(out) FROM=%dm TO=%dm\n.MEAS TRAN MAX%d MAX V(out) FROM=%dm TO=%dm\n';
        blocks = arrayfun(@(k) sprintf(base_meas, k, 2*k, 2*(k+1), k, 2*k, 2*(k+1)), 0:100, 'UniformOutput', false);
        cmd = [
            '\n* COMMANDS\n' ...
            '.tran 0 0.202 0 10u\n' ...
            '.probe v(out)\n' ...
            strjoin(cellstr(blocks), '')
        ];

    otherwise
        error('Invalid mode. Use: tran, ac, slew or gedlee.');
end

fprintf(arq, src);
fprintf(arq, cmd);

% --- Close file ---
fclose(arq);
end
