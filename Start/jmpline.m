function arq = jmpline(arq) % essa função recebe um arquivo e pula uma linha dele
    
    aux = '';
    
    while(~strcmp(aux,sprintf('\r')))
        aux = fscanf(arq,'%c',1);
    end
    
end
