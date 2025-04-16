C = { [] [] [] [] }
Best = struct('score',{Inf('double')},'parameters', zeros(1, 3));
Best.score = 10;
Best.parameters = [1 2 3];
C(1) = {Best}
Best.score = 8;
Best.parameters = [1 2 3 6];
C(2) = {Best};
C{1}.parameters
C{2}.parameters
 isfield(C{1}, 'parameters')
 isfield(C{3}, 'parameters')
 met = {'GA' 'SA' 'PA' 'SAM'};
 a = 'SA'
 for j=1:length(met)
    if length(a) == length (met{j})
        if a==met{j}  i=j
     end;
    end;
 end;
 teste= { ['a'] [1] [3 ]; ['b '] [ 3]  [5]; ['c'] [1] [3 ]; ['d '] [ 3]  [5]; ['e'] [1] [3 ]; ['f '] [ 3]  [5]; ['a'] [1] [3 ]; ['f '] [ 3]  [5]; ['a'] [1] [3 ]}
 teste(10, :) = {'f' [3] [4]};
 teste
 j =length(teste)-1
  teste= teste(1:j, 1:3)