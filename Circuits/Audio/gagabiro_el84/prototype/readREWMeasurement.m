function measurement = readREWMeasurement(filepath)
% readREWMeasurement reads frequency response data exported by REW
% and returns it as a struct object.
%
% Input:
%   filepath   - string, full path to the .txt measurement file
%
% Output:
%   measurement - struct with fields:
%       .filename    - name of the file
%       .freq        - frequency vector (Hz)
%       .mag_dB      - magnitude in dBFS
%       .phase_deg   - phase in degrees

    % Open file
    fid = fopen(filepath, 'r');
    if fid == -1
        error('Could not open file: %s', filepath);
    end

    % Skip header lines starting with '*'
    while true
        pos = ftell(fid);  % Save position
        line = fgetl(fid);
        if ~ischar(line) || isempty(line) || line(1) ~= '*'
            fseek(fid, pos, 'bof');  % Rewind to start of numeric data
            break;
        end
    end

    % Read 3 columns of numeric data: freq, dB, phase
    data = fscanf(fid, '%f %f %f', [3, Inf])';
    fclose(fid);

    % Store in struct
    [~, name, ext] = fileparts(filepath);
    measurement = struct( ...
        'filename', [name ext], ...
        'freq', data(:,1), ...
        'mag_dB', data(:,2), ...
        'phase_deg', data(:,3) ...
    );
end
