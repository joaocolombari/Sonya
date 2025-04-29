function [IM] = file2table_LTspice_ac(n, file, varargin)
% file2table_LTspice - Reads AC analysis results (dB magnitude) from LTspice log file
%
% This version is designed to extract dB values like:
%    f20hz: v(out)=(-83.1865dB,-136.34°) at 20
%
% INPUTS:
%   n        - Number of lines to skip at the beginning (integer)
%   file     - Log file name (string)
%   varargin - Variable names to extract (e.g., 'f20hz', 'f30hz', etc.)
%
% OUTPUT:
%   IM       - Vector of extracted dB values (in double)
%
% Author: João Victor Colombari Carlet
% Email:  jvccarlet@usp.br

    arq = fopen(file, 'r');
    if arq > (-1)
        % Skip first n lines
        for i = 1:n
            fgets(arq);
        end

        words = fscanf(arq, '%c');
        fclose(arq);

        IM = nan(1, nargin-2); % Pre-allocate output

        for i = 1:(nargin-2)
            % Build flexible pattern: variable name followed by parentheses with dB inside
            pattern = [regexptranslate('escape', varargin{i}) '.*?\(\s*(-?\d+\.?\d*)dB'];
            valueMatch = regexp(words, pattern, 'tokens');
            if ~isempty(valueMatch)
                IM(i) = str2double(valueMatch{1}{1});
            end
        end
    else
        IM = [];
    end
end