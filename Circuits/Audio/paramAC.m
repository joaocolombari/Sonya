function paramAC(circuito, x)
% paramAC - Generates the parameter file "param" for SPICE simulation
% 
% This function writes parameter values into a text file to be used
% by the Gagabiro Valve Power Amplifier circuit in LTspice.
%
% INPUTS:
%   circuito - folder or path where the circuit files are stored (string)
%   x        - vector of design parameters (length 25)
%
% Author: João Victor Colombari Carlet
% Email:  jvccarlet@usp.br

% OS-independent file separator
slash = filesep;

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

% --- Close file ---
fclose(arq);
end
