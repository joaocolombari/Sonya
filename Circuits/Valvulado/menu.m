global ParDados;
global VarDados;
global VarNames;
global NameMenu;
global mudamenu;

ParDados= {    	['Gain (dB)'] ['> 20 1'];                               %1
               	['Slew Rate (V/us)'] ['< 10 2'];                        %2
               	['Low Cut Frequency (Hz)'] ['< 20 5'];                  %3
               	['High Cut Frequency (Hz)'] ['> 15000 5'];              %4      
               	['Output Power (W)'] ['> 20 3'];                        %5
               	['THD (%)'] ['< 1 5'];                                  %6
                ['B+ Pre and Phase Inverter (V)'] ['< 300 1'];          %7  x21
                ['B+ Power Push-Pull Pair (V)'] ['< 500 3'];            %8  x19
                ['B- Power Tube Grids (V)'] ['< 40 3'];                 %9  x18
                ['B- Phase Inverter Tail Transistor (V)'] ['< 40 3']};  %10 x20
           
VarDados= { 	['r1 (ohms)'] [ '0.5'] ['5.0'] ['0.5'] ['0'];
                ['r2 (ohms)']  [ '0.5'] ['5.0'] ['0.5'] ['0']; 
                ['r3 (ohms)'] [ '0.5'] ['5.0'] ['0.5'] ['0']; 
                ['r4 e r5 (ohms)'] [ '0.5'] ['5.0'] ['0.5'] ['0']; 
                ['r6 e r7 (ohms)'] [ '0.5'] ['5.0'] ['0.5'] ['0']; 
                ['r8 e r9 (ohms)']  [ '0.5'] ['5.0'] ['0.5'] ['0']; 
                ['r10 (ohms)'] [ '1.0'] ['500.0'] ['1.0'] ['0']; 
                ['r11 (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 
                ['r12 (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 
                ['r13 (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 	
                ['falante (r14) (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 
                ['r15 (ohms)'] [ '0.5'] ['20.0'] ['0.5'] ['0']; 
                ['r16 (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 
                ['r17 (ohms)'] [ '0.5'] ['20.0'] ['0.5'] ['0'];
                ['r18 (ohms)'] [ '1.0'] ['100.0'] ['1.0'] ['0']; 
                ['c1 e c2 (uF)'] [ '1.0'] ['30.0'] ['1.0'] ['0'];
                ['c3 (uF)'] [ '1.0'] ['30.0'] ['1.0'] ['0']};
%                 ['V1 (V)'] [ '10'] ['30.0'] ['50'];
%                 ['V2 (V)'] [ '250'] ['30.0'] ['480'];
%                 ['V3 (V)'] [ '-50'] ['30.0'] ['0'];
%                 ['V4 (V)'] [ '200'] ['30.0'] ['400'];
%                 qq coisa add os quatro em VarNames

 NameMenu='Tube Power Amp Optimization';
 
 VarNames= {    ['x1'] ['x2'] ['x3'] ['x4'] ['x5'] ['x6'] ['x7'] ['x8'] ['x9'] ['x10'] ['x11'] ['x12'] ['x13'] ['x14'] ['x15'] ['x16'] ['x17']};

% caso seja feita mudancas no menu colocar mudamenu = 1
mudamenu = 0;
            
menuCir
           
           