global ParDados;
global VarDados;
global NameMenu;
global modo;

global slash;
global simulador;
global BestRes;
global metodos;
BestRes = { [ ] [ ] [ ] [ ] [ ] [ ] [ ]  [ ] };
slash = '\';
simulador='START /Realtime/wait C:\synopsys\Hspice_A-2008.03\BIN\hspice_mt.exe ';
BestRes = { [ ] [ ] [ ] [ ] [ ] [ ] [ ]  [ ] };
metodos = {'GA' 'SA' 'PS' 'MM' 'SAM' 'SCE' 'PSO' 'DE'}';

ParDados= { ['OutPut Curren (uA)'] ['1.0']; ['Current Precision (%)'] ['10']; 
               ['Power Supply (min max) (V)'] ['1.0 3.0']; ['Output Voltage (V)'] [ '0.6'];
               ['Power Consumption (uW)'] ['5'];   ['Constants'] ['']; ['Weak Inv. Trans.'] ['']; };
           
VarDados= { ['W1 (um)'] [ '1.0'] ['50'] ['5']; ['L1 (um)']  [ '1.0'] ['50'] ['5']; ['W2 (um)'] [ '1.0'] ['50'] ['5']; ['L2 (um)'] [ '1.0'] ['50'] ['5']; 
                ['W1 (um)'] [ '1.0'] ['50'] ['5']; ['L1 (um)']  [ '1.0'] ['50'] ['5']; ['W2 (um)'] [ '1.0'] ['50'] ['5']; ['L2 (um)'] [ '1.0'] ['50'] ['5']; };
 NameMenu='Current Source Optimization';
            
 menuCir