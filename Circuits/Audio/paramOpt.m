function paramOpt(circuito, x, filename)
% paramOpt - Writes best parameter set to a custom output file for LTspice simulation
%
% This function saves the optimized parameters for the Gagabiro Valve Power Amplifier
% into a specified parameter file (e.g., 'paramop', 'paramopT', etc.).
%
% INPUTS:
%   circuito - Name or path to the circuit folder (string)
%   x        - Vector containing optimized parameter values
%   filename - Desired name for the output file (string, e.g., 'paramop')
%
% Author: João Victor Colombari Carlet
% Contact: jvccarlet@usp.br

slash = filesep;

% Construct output file path
outfile = [circuito slash filename];

% Delete old file if it exists
if exist(outfile, "file")
    delete(outfile);
end

% Open new file for writing
arq = fopen(outfile, 'w');

% Write header
fprintf(arq, ['***************************************\n' ...
              '*** BEST PARAMETERS - GAGABIRO AMP ***\n' ...
              '*** AUTHOR: JOAO VICTOR CARLET     ***\n' ...
              '*** CONTACT: JVCCARLET@USP.BR      ***\n' ...
              '***************************************\n\n']);

% Write resistor values (X1 to X18)
fprintf(arq, '*RESISTORS\n');
for i = 1:18
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% Write capacitor values (X19 to X23)
fprintf(arq, '\n*CAPACITORS\n');
for i = 19:23
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% Write voltage source values (X24 and X25)
fprintf(arq, '\n*VOLTAGE SOURCES\n');
for i = 24:25
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% Close file
fclose(arq);
end
