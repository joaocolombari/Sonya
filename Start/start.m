%Janela principal do Otimizador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = {'Alpha', 'Beta','Gamma','Delta_Ga','Delta_SA', 'OTA1', 'OTA2 (Folded-Cascode)','Alpha espelhado','Beta espelhado','Gamma espelhado','Delta espelhado -AG', 'Delta espelhado -SA'};
[choice,v] = listdlg('Name', 'OTIMIZAÇÃO', 'PromptString','Escolha um Circuito', 'SelectionMode','single', 'ListString',str, 'ListSize', [220 100]);
path(path,'..\Start\');
if v == 1 
switch choice
    case 1
        imshow('..\Alpha\CircuitoAlphatabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Alpha\');
        %mainAlpha;
        cd '..\Alpha\'
        run '..\Alpha\mainAlpha.m';
    case 2
        imshow('..\Beta\CircuitoBetatabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Beta\');
        %mainBeta
        cd '..\Beta\'
        run '..\Beta\mainBeta.m';
    case 3
        imshow('..\Gamma\CircuitoGammatabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Gamma');
        %mainGamma;
        cd  '..\Gamma\'
        run '..\Gamma\mainGamma.m';
    case 4
        imshow('..\Delta\CircuitoDeltatabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Delta\');
        %mainDelta;
        cd '..\Delta\'
        run '..\Delta\mainDelta.m';
    case 5
        imshow('..\Delta_SA\CircuitoDeltatabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Delta\'
        run '..\Delta\mainDelta_SA.m';
    case 6
        imshow('..\OTA\CircuitoOTAtabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\OTA\');
        %mainOTA;
        cd '..\OTA\'
        run '..\OTA\mainOTA.m';
    case 7
        imshow('..\Folded-cascode\CircuitoFoldedCascodetabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Folded-cascode\'
        run '..\Folded-Cascode\mainFoldedCascode.m';
    case 8
        imshow('..\Alpha_espelhado\CircuitoAlpha_espelhadotabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Alpha_espelhado\'
        run '..\Alpha_espelhado\mainAlphaespelhado.m';
    case 9
        imshow('..\Beta_espelhado\CircuitoBeta_espelhadotabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Beta_espelhado\'
        run '..\Beta_espelhado\mainBetaespelhado.m';
    case 10
        imshow('..\Gamma_espelhado\CircuitoGamma_espelhadotabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Gamma');
        %mainGamma;
        cd  '..\Gamma_espelhado\'
        run '..\Gamma_espelhado\mainGammaespelhado.m';
    case 11
        imshow('..\Delta_espelhado\CircuitoDelta_espelhadotabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Delta_espelhado\'
        run '..\Delta_espelhado\mainDeltaespelhado.m';
    case 12
        imshow('..\Delta_espelhado_SA\CircuitoDelta_espelhadotabela.png', 'InitialMagnification', 120, 'Border', 'tight');
        %path(path,'..\Folded-cascode\');
        %mainFoldedCascode;
        cd '..\Delta_espelhado\'
        run '..\Delta_espelhado\mainDeltaespelhado_SA.m';
end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%