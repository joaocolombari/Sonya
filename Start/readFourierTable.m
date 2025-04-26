function [fourierTable, thd] = readFourierTable(file)
% readFourierTable - Extracts Fourier harmonic table and THD from a SPICE simulation log file.
%
% This function scans a text log (e.g., LTspice, HSPICE output) to extract:
%   - A table of harmonic data (Harmonic Number, Frequency, Magnitude, etc.)
%   - Total Harmonic Distortion (THD) value as a percentage
%
% INPUT:
%   file - Path to the text log file containing the Fourier analysis (string)
%
% OUTPUT:
%   fourierTable - MATLAB table containing harmonic data:
%                  Columns: Harmonic, Frequency_Hz, FourierComponent, 
%                  NormalizedComponent, Phase_deg, NormalizedPhase_deg
%   thd          - Total Harmonic Distortion value extracted (in %)
%
% The function looks for sections starting with "Harmonic" and "Frequency",
% and automatically reads the data until a blank line or another block starts.
%
% Example of a supported line:
%     1    1.000e+03  1.946e-06  1.000e+00  87.90°  0.00°
%
% Author: João Victor Colombari Carlet
% Email:  jvccarlet@usp.br
%

    fid = fopen(file, 'r');
    if fid < 0
        error('Could not open file: %s', file);
    end

    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    lines = lines{1};

    % Locate the header of the Fourier table
    headerLine = find(contains(lines, 'Harmonic') & contains(lines, 'Frequency'));
    if isempty(headerLine)
        warning('Fourier table not found.');
        fourierTable = table();
        thd = NaN;
        return;
    end

    % Read harmonic lines
    tableData = [];
    i = headerLine + 1;
    while i <= length(lines)
        line = strtrim(lines{i});
        if isempty(line) || startsWith(line, 'Total') || startsWith(line, 'Date')
            break;
        end

        % Extract 6 numbers from the line using regular expressions
        numbers = regexp(line, '([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|\d+)', 'match');
        if numel(numbers) >= 6
            nums = str2double(numbers(1:6));
            tableData = [tableData; nums]; %#ok<AGROW>
        end
        i = i + 1;
    end

    % Create MATLAB table if data was found
    if ~isempty(tableData)
        fourierTable = array2table(tableData, ...
            'VariableNames', {'Harmonic', 'Frequency_Hz', 'FourierComponent', ...
                              'NormalizedComponent', 'Phase_deg', 'NormalizedPhase_deg'});
    else
        warning('No valid harmonic data found.');
        fourierTable = table();
    end

    % Extract Total Harmonic Distortion (THD)
    thdLine = find(contains(lines, 'Total Harmonic Distortion'));
    thd = NaN;
    if ~isempty(thdLine)
        match = regexp(lines{thdLine(1)}, '([\d\.]+)%', 'tokens');
        if ~isempty(match)
            thd = str2double(match{1}{1});
        end
    end
end
