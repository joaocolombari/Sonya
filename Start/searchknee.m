function knee = searchknee(IM,Vdd) % fun��o que encontra, e retorna, o ponto da curva no gr�fico IM X Vdd, o qual � chamado de "knee"
aux = Inf('double');


    for w = 1:1:(numel(IM)-1)
        angulo = atand( ( log10(    IM(w+1)   )-log10(     IM(w)   ))/(Vdd(w+1)-Vdd(w)) );
        if(abs(angulo - 15) < aux)  % tomando que o angulo de 15 graus � um bom angulo para o angulo de curvatura da reta tangente ao "joelho" do grafico
            aux = abs(angulo - 15);
            knee = w;
        end
    end



    
end