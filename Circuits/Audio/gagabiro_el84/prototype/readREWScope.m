function data = readREWScope(filename, varargin)
%READREWSCOPEFILE Reads and processes REW Scope exported data
%
%   data = readREWScopeFile(filename, 'window_ms', value, 'trim_mode', mode)
%
%   INPUTS:
%       filename  - path to REW scope export file (text format)
%
%   Optional name-value pairs:
%       'window_ms' - segment length to extract in milliseconds (default: full)
%       'trim_mode' - 'none' (default), 'zero' (first zero crossing),
%                     'peak' (first maximum)
%
%   OUTPUT:
%       data struct with fields:
%           .time     -> time vector (s)
%           .voltage  -> scaled voltage vector (V)
%           .fs       -> estimated sampling rate (Hz)

    % Defaults
    window_ms = [];
    trim_mode = 'none';

    % Parse optional arguments
    for k = 1:2:length(varargin)
        switch lower(varargin{k})
            case 'window_ms'
                window_ms = varargin{k+1};
            case 'trim_mode'
                trim_mode = lower(varargin{k+1});
        end
    end

    % Open file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    % Init
    time = [];
    raw_amp = [];
    scale_factor = 1.0;
    data_section = false;

    % Read line by line
    while ~feof(fid)
        line = fgetl(fid);

        % Capture the scaling factor from metadata
        if contains(line, 'CH1 one volt')
            tokens = regexp(line, 'CH1 one volt\s*:\s*([\d\.Ee+-]+)', 'tokens');
            if ~isempty(tokens)
                scale_factor = str2double(tokens{1}{1});
            end
        end

        % Look for header (start of data)
        if contains(line, 'Time CH1')
            data_section = true;
            continue
        end

        % Read numerical data
        if data_section
            nums = sscanf(line, '%f %f');
            if length(nums) == 2
                time(end+1) = nums(1);
                raw_amp(end+1) = nums(2);
            end
        end
    end
    fclose(fid);

    % Convert raw amplitude to real voltage
    voltage = raw_amp / scale_factor;

    % Estimate sampling rate
    if length(time) > 1
        fs = 1 / mean(diff(time));
    else
        fs = NaN;
    end

    % Apply optional trimming
    if ~isempty(window_ms) && ~strcmp(trim_mode,'none')
        window_samples = round(fs * window_ms / 1000);

        switch trim_mode
            case 'zero'
                start_idx = find(voltage(1:end-1).*voltage(2:end) <= 0, 1, 'first');
            case 'peak'
                [~, peak_idx] = max(voltage);           % fisrt peak index
                start_idx = peak_idx;
            case 'gedlee'
                % 1) first local max
                [~, peak_idx] = max(voltage);           % fisrt peak index

                % 2) zero-crossings after that peak
                zc_rel = find(voltage(peak_idx:end-1).*voltage(peak_idx+1:end) <= 0);

                % 3) choose the zero AFTER two periods from the peak
                %    (two periods => take the 2*n + 1 = 5th zero-cross after the peak)
                nPeriods = 1.5;
                targetZC = 2*nPeriods + 1;   % => 5
                if ~isempty(zc_rel)
                    k = min(targetZC, numel(zc_rel));
                    end_idx = peak_idx + zc_rel(k);
                else
                    end_idx = peak_idx;
                end
                start_idx = end_idx-window_samples;
            otherwise
                start_idx = 1;
        end

        end_idx = min(start_idx + window_samples - 1, length(voltage));
        voltage = voltage(start_idx:end_idx);
        time = time(start_idx:end_idx) - time(start_idx);
    end

    % Return struct
    data.time = time(:);
    data.voltage = voltage(:);
    data.fs = fs;
end