function paramOpt(circuito, x, filename, score, runNumber)
% paramOpt - Writes best parameter set to a custom output file for LTspice simulation
%
% Saves the optimized parameters for the Gagabiro Valve Power Amplifier into a
% specified parameter file (e.g., 'paramop', 'paramopT'), with optional score and run info.
%
% INPUTS:
%   circuito   - Name or path to the circuit folder (string)
%   x          - Vector of optimized parameter values
%   filename   - Name of the output file (e.g., 'paramop')
%   score      - (Optional) Score value to log as comment
%   runNumber  - (Optional) Run number to log as comment
%
% Author: João Victor Colombari Carlet
% Contact: jvccarlet@usp.br

slash = filesep;
outfile = [circuito slash filename];

% Delete existing file
if exist(outfile, "file")
    delete(outfile);
end

% Open new file
arq = fopen(outfile, 'w');

% Write header
fprintf(arq, '***************************************\n');
fprintf(arq, '*** BEST PARAMETERS - GAGABIRO AMP ***\n');
fprintf(arq, '*** AUTHOR: JOAO VICTOR CARLET     ***\n');
fprintf(arq, '*** CONTACT: JVCCARLET@USP.BR      ***\n');
fprintf(arq, '***************************************\n');

% Optional score and run info
if nargin >= 4
    fprintf(arq, '*** Run #%d | Score = %.4g ***\n', runNumber, score);
end

fprintf(arq, '\n');

% Resistors
fprintf(arq, '*RESISTORS\n');
for i = 1:18
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% Capacitors
fprintf(arq, '\n*CAPACITORS\n');
for i = 19:23
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

% Voltage sources
fprintf(arq, '\n*VOLTAGE SOURCES\n');
for i = 24:25
    fprintf(arq, '.param      X%d = %g\n', i, x(i));
end

fclose(arq);
end
