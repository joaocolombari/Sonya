function gm = gedlee_from_meas(minValues, maxValues, varargin)
% gedlee_from_meas - Calculates GedLee Metric from LTspice .MEAS min/max results
%
% Inputs:
%   minValues - Vector of MIN(v(out)) values over time windows
%   maxValues - Vector of MAX(v(out)) values over same time windows
%
% Optional:
%   'plot'    - true/false flag for diagnostic plotting (default: false)
%
% Output:
%   gm        - GedLee Metric value (scalar)
%
% Author: João Victor Colombari Carlet
% Contact: jvccarlet@usp.br

    % === Defaults ===
    doPlot = false;

    % Parse optional arguments
    for k = 1:2:length(varargin)
        switch lower(varargin{k})
            case 'plot'
                doPlot = logical(varargin{k+1});
        end
    end

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
    refInput = 0.45;  % Gain normalization reference
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
    % Dense interpolation
    x_dense = linspace(-1, 1, 1000);
    y = interp1(input, Values, x_dense, 'spline', 'extrap');

    % Derivatives
    dy  = gradient(y, x_dense);
    d2y = gradient(dy, x_dense);

    % Integrand
    integrand = cos(x_dense * pi / 2).^2 .* (d2y).^2;

    % Compute GedLee metric
    try
        gm = sqrt(trapz(x_dense, integrand));
    catch
        gm = inf;
        warning('GedLee integral failed. Assigning inf.');
    end

    % --- Optional plotting ---
    if doPlot
        figure;
        subplot(3,1,1);
        plot(input, Values, 'o-', x_dense, y, 'r');
        xlabel('Input (V)'); ylabel('Output (V)');
        title('Transfer Curve (Normalized)');
        legend('Measured','Interpolated','Location','Best');
        grid on;

        subplot(3,1,2);
        plot(x_dense, dy, 'b', x_dense, d2y, 'r');
        xlabel('Input (V)'); ylabel('Derivative');
        title('First and Second Derivatives');
        legend('dy','d2y','Location','Best');
        grid on;

        subplot(3,1,3);
        plot(x_dense, integrand, 'k');
        xlabel('Input (V)'); ylabel('Integrand');
        title('GedLee Integrand');
        grid on;
    end
end
