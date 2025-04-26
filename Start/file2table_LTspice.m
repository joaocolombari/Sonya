function [IM] = file2table_LTspice(n, file, varargin)
% file2tableF - Reads numeric values from a text file after '=' signs.
%
% This function searches a text file for numeric values associated with "=" signs.
% If specific variable names are provided, it searches for expressions like "varname = value".
% Otherwise, it extracts all numbers found after any '=' in the file.
%
% Example of a supported line: output_power: AVG(...) = -2.36575e-013
%
% INPUTS:
%   n       - Number of lines to skip before starting the search (integer).
%   file    - Path to the text file (string).
%   varargin - (Optional) List of variable names to search for. If provided, only values
%              associated with these variables will be extracted.
%
% OUTPUT:
%   IM      - A vector containing the extracted numeric values.
%
% Author: João Victor Colombari Carlet
% Email:  jvccarlet@usp.br
%

    arq = fopen(file, 'r');
    if arq > (-1)
        % Skip the first n lines
        for i = 1:n
            fgets(arq);
        end

        % Read the rest of the file as a single string
        words = fscanf(arq, '%c');

        if nargin <= 2
            % No specific variables given: extract all numbers after '='
            values = regexp(words, '=\s*(-?[0-9]+\.?[0-9]*([eE][\+\-]?[0-9]+)?)', 'tokens');
            IM = zeros(1, length(values));
            for i = 1:length(values)
                IM(i) = str2double(values{i}{1});
            end
        else
            % Specific variable names given
            j = 0;
            IM = [];
            for i = 1:(nargin - 2)
                % Build a flexible regex pattern to match the variable name followed by '=' and a number
                pattern = ['(^|\s|:)' regexptranslate('escape', varargin{i}) '.*?=\s*(-?[0-9]+\.?[0-9]*([eE][\+\-]?[0-9]+)?)'];
                values = regexp(words, pattern, 'tokens');
                if ~isempty(values)
                    strval = values{1}{2};  % Get the numeric value (second capture group)
                    x = str2double(strval);
                    if ~isempty(x)
                        j = j + 1;
                        IM(j) = x;
                    end
                end
            end
        end

        fclose(arq);
    else
        % File could not be opened
        IM = [];
    end
end
