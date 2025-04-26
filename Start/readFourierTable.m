function [fourierTable, thd] = readFourierTable(file)
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

        % Extract 6 numbers from the line using any whitespace
        numbers = regexp(line, '([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|\d+)', 'match');
        if numel(numbers) >= 6
            nums = str2double(numbers(1:6));
            tableData = [tableData; nums]; %#ok<AGROW>
        end
        i = i + 1;
    end

    if ~isempty(tableData)
        fourierTable = array2table(tableData, ...
            'VariableNames', {'Harmonic', 'Frequency_Hz', 'FourierComponent', ...
                              'NormalizedComponent', 'Phase_deg', 'NormalizedPhase_deg'});
    else
        warning('No valid harmonic data found.');
        fourierTable = table();
    end

    % Extract THD
    thdLine = find(contains(lines, 'Total Harmonic Distortion'));
    thd = NaN;
    if ~isempty(thdLine)
        match = regexp(lines{thdLine(1)}, '([\d\.]+)%', 'tokens');
        if ~isempty(match)
            thd = str2double(match{1}{1});
        end
    end
end
