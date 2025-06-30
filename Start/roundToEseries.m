function x_rounded = roundToEseries(x, varargin)
% roundToEseries - Rounds selected values in x to nearest E-series
%
% Syntax:
%   x_rounded = roundToEseries(x, 'res_idx', [1:18], 'res_series', 'e24', ...
%                                  'cap_idx', [19:23], 'cap_series', 'e12')
%
% INPUTS:
%   x           - full parameter vector (length 25)
%
% Named Parameters:
%   'res_idx'   - indices for resistor rounding
%   'res_series'- 'e12' or 'e24' for resistor values
%   'cap_idx'   - indices for capacitor rounding
%   'cap_series'- 'e12' or 'e24' for capacitor values
%
% OUTPUT:
%   x_rounded   - rounded parameter vector

    % Parse inputs
    p = inputParser;
    addRequired(p, 'x');
    addParameter(p, 'res_idx', []);
    addParameter(p, 'res_series', 'e24');
    addParameter(p, 'cap_idx', []);
    addParameter(p, 'cap_series', 'e12');
    parse(p, x, varargin{:});

    x_rounded = x;

    % Round resistors
    if ~isempty(p.Results.res_idx)
        x_rounded(p.Results.res_idx) = roundSubset(x, p.Results.res_idx, p.Results.res_series);
    end

    % Round capacitors
    if ~isempty(p.Results.cap_idx)
        x_rounded(p.Results.cap_idx) = roundSubset(x, p.Results.cap_idx, p.Results.cap_series);
    end
end

function rounded_vals = roundSubset(x, idx, series)
    % Define E-series base values
    switch lower(series)
        case 'e12'
            base = [1.0 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2];
        case 'e24'
            base = [1.0 1.1 1.2 1.3 1.5 1.6 1.8 2.0 2.2 2.4 2.7 3.0 ...
                    3.3 3.6 3.9 4.3 4.7 5.1 5.6 6.2 6.8 7.5 8.2 9.1];
        otherwise
            error('Invalid E-series. Use "e12" or "e24".');
    end

    % Expand across decades
    decades = -1:6;
    e_vals = [];
    for d = decades
        e_vals = [e_vals, base * 10^d];
    end

    % Round selected values
    rounded_vals = x(idx);
    for j = 1:length(idx)
        [~, nearest] = min(abs(e_vals - x(idx(j))));
        rounded_vals(j) = e_vals(nearest);
    end
end
