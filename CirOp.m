% slach para windws '\' ou para Linus '/' 
global slash;
global simulador;
global BestRes;
global metodos;
global circuito;
global namext;
global CirOpDir;
global simuladorltspice;
global simuladorltspiceXVII;



namext = '';
slash = filesep;  % Melhor prática para compatibilidade multiplataforma
simulador='START /Realtime/wait C:\"Program Files"\synopsys\Hspice_A-2008.03\BIN\hspice.exe ';
% simuladorPar='START /Realtime C:\"Program Files"\synopsys\Hspice_A-2008.03\BIN\hspice.exe ';
% simuladorRF='START /Realtime/wait C:\"Program Files"\synopsys\Hspice_A-2008.03\BIN\hspicerf.exe ';
% simuladorRFpar='START /Realtime C:\"Program Files"\synopsys\Hspice_A-2008.03\BIN\hspicerf.exe ';
% simulador2019='START /Realtime/wait D:\Synopsys\Hspice_P-2019.06-SP1-1\WIN64\hspice.exe ';
% simulador2019par='START /Realtime D:\Synopsys\Hspice_P-2019.06-SP1-1\WIN64\hspice.exe -mp 4 -mt 4 -hpp -i ';
CirOpDir = 'C:\Users\user\Otimizador_v6c';
% simuladorEldo='C:\MentorGraphics\Eldo\AMS_13_2\ixn\bin\eldo.exe -silente -use_proc all ';
simuladorltspice='START C:\Users\Colombari\AppData\Local\Programs\ADI\LTspice\LTspice.exe';     % configure o PATH na sua maquina 
simuladorltspiceXVII='START /Realtime/wait C:\"Program Files"\LTC\LTspiceXVII\XVIIx64.exe -b '; % configure o PATH na sua maquina 


% para LINUX
%simulador = 'c:/Synopsys/Hspice_A-2008.03/BIN/hspice_mt.exe ';

BestRes = { [ ]   [ ]  [ ]  [ ]  [ ]   [ ]   [ ]   [ ]    [ ]     [ ]      [ ]     [ ]     [ ]    [ ]    [ ]    [ ]    [ ]    [ ]    [ ]   [ ]};
metodos = {'GaM'  'GA' 'SA' 'PS' 'MM' 'SAM' 'SCE' 'PSO' 'QEPSO' 'QDPSO'  'QGPSO' 'QLRPSO' 'GQPSO' 'DPSO'  'DE'  'EvN'  'PSON' 'PSw'  'EDA'  'ESS'};
%            1      2    3    4    5    6     7     8      9      10       11      12      13     14      15      16     17     18     19    20
Opt;