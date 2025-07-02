function gm = gedlee_from_meas(minValues, maxValues)
% gedlee_from_meas - Calculates GedLee Metric from LTspice .MEAS min/max results
%
% Inputs:
%   minValues - Vector of MIN(v(out)) values over time windows
%   maxValues - Vector of MAX(v(out)) values over same time windows
%
% Output:
%   gm        - GedLee Metric value (scalar)
%
% Author: João Victor Colombari Carlet
% Contact: jvccarlet@usp.br

    % === Check for empty or invalid inputs ===
    if isempty(minValues) || isempty(maxValues) || length(minValues) ~= length(maxValues)
        warning('Invalid or empty input values for GedLee. Assigning inf.');
        gm = inf;
        return;
    end

    % Flip min values to align waveform
    minValues = fliplr(minValues);

    % Construct full transfer curve with midpoint at center
    centerVal = 0.5 * (maxValues(1) + minValues(end));
    Values = [minValues(1:end-1), centerVal, maxValues(2:end)];

    % Construct corresponding input vector (assuming 10 ms per step)
    input = (-(length(Values)-1)/2:(length(Values)-1)/2) * 0.01; % volts

    % --- Gain normalization ---
    % Find gain at 0.45 V input
    refInput = 0.45;
    [~, idx] = min(abs(input - refInput));
    gain = Values(idx) / refInput;
    if gain == 0 || ~isfinite(gain)
        warning('Gain is zero or invalid — invalid transfer curve.');
        gm = inf;
        return;
    end

    % Normalize output by gain
    Values = Values / gain;

    % --- GedLee computation ---
    % Create dense and smooth interpolation
    x_dense = linspace(-1, 1, 1000);
    y = interp1(input, Values, x_dense, 'spline', 'extrap');

    % Compute first and second derivatives numerically
    dy  = gradient(y, x_dense);
    d2y = gradient(dy, x_dense);

    % Define integrand and compute GedLee integral
    integrand = cos(x_dense * pi / 2).^2 .* (d2y).^2;

    try
        gm = sqrt(trapz(x_dense, integrand));
    catch
        gm = inf;
        warning('GedLee integral failed. Assigning inf.');
    end
end
