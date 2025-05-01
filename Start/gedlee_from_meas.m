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

    if length(minValues) ~= length(maxValues)
        error('minValues and maxValues must have the same length.');
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
    if gain == 0
        warning('Gain is zero — invalid transfer curve.');
        gm = inf;
        return;
    end

    % Normalize output by gain
    Values = Values / gain;

    % --- GedLee computation ---
    T = @(x) interp1(input, Values, x, 'spline', 'extrap'); % interpolator

    % Numerical derivatives via finite differences
    dT  = @(x) gradient(T(x), x);
    d2T = @(x) gradient(dT(x), x);

    % Define integrand
    integrand = @(x) cos(x * pi / 2).^2 .* (d2T(x)).^2;

    % Compute integral numerically from -1 to 1
    try
        gm = sqrt(integral(integrand, -1, 1));
    catch
        gm = inf;
        warning('GedLee integral failed. Assigning inf.');
    end
end
