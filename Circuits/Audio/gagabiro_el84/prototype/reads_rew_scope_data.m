% === READ REW SCOPE FILE AND PLOT (with voltage scaling) ===

filename = 'test_1/test.txt';  % Replace with your actual file path
fid = fopen(filename, 'r');
if fid == -1
    error('Could not open file.');
end

% Initialize
time = [];
raw_amplitude = [];
scale_factor = 1.0;  % Default, will update if CH1 scale is found
data_section = false;

while ~feof(fid)
    line = fgetl(fid);

    % Capture the scaling factor from metadata
    if contains(line, 'CH1 one volt')
        tokens = regexp(line, 'CH1 one volt\s*:\s*([\d\.Ee+-]+)', 'tokens');
        if ~isempty(tokens)
            scale_factor = str2double(tokens{1}{1});
        end
    end

    % Start reading numerical data
    if contains(line, 'Time CH1')
        data_section = true;
        continue
    end

    % Read time + raw amplitude values
    if data_section
        nums = sscanf(line, '%f %f');
        if length(nums) == 2
            time(end+1) = nums(1);
            raw_amplitude(end+1) = nums(2);
        end
    end
end

fclose(fid);

% Convert raw amplitude to real voltage
voltage = raw_amplitude / scale_factor;

% === Apply input attenuation compensation: +23.2068 dB ===
gain_dB = 18.83;
gain = 10^(gain_dB / 20);  
voltage = voltage * gain;

% Plot
figure;
plot(time * 1000, voltage, 'b');
xlabel('Time (ms)');
ylabel('Amplitude (V)');
title('REW Scope Waveform (Scaled to Volts)');
grid on;
