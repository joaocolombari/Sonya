function [IM] = file2tableF(n, file, varargin)
% file2tableF - Lê valores numéricos de um arquivo de texto após '='.
% Se variáveis forem passadas, procura expressões como "varname = valor"
% Exemplo de linha suportada: output_power: AVG(...) = -2.36575e-013

    arq = fopen(file, 'r');
    if arq > (-1)
        % Pula as primeiras n linhas
        for i = 1:n
            fgets(arq);
        end

        % Lê o restante do arquivo como texto
        words = fscanf(arq, '%c');

        if nargin <= 2
            % Caso nenhuma variável específica seja passada
            values = regexp(words, '=\s*(-?[0-9]+\.?[0-9]*([eE][\+\-]?[0-9]+)?)', 'tokens');
            IM = zeros(1, length(values));
            for i = 1:length(values)
                IM(i) = str2double(values{i}{1});
            end
        else
          j = 0;
          IM = [];
          for i = 1:(nargin - 2)
              % Match variable name with optional space or colon before it, then '='
              pattern = ['(^|\s|:)' regexptranslate('escape', varargin{i}) '.*?=\s*(-?[0-9]+\.?[0-9]*([eE][\+\-]?[0-9]+)?)'];
              values = regexp(words, pattern, 'tokens');
              if ~isempty(values)
                  strval = values{1}{2};  % The value is the 2nd capture group
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
        IM = [];
    end
end
