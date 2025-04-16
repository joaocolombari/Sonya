function checkModel (Model)

    if(strcmp(Model,'Model35'))
        return;
    end
    
    arq = fopen(Model,'r');
    text = fscanf(arq,'%s');
    fclose(arq);
    
    arq = fopen(Model,'w');
    fprintf(arq,'%s','.PARAM Wpadrao = 1um');
    fprintf(arq,'\r\n');
    fprintf(arq,'%s',text);
    
    fclose(arq);
    delete(Model);
    

end