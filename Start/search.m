function find = search(vector,wanted) % função que procura no vetor "vector" pelo valor "wanted", ou o mais proximo.
    aux = Inf('double');
    for i = 1:1:numel(vector)
       if(abs(wanted-vector(i))<aux)
            aux = abs(wanted-vector(i));
            find = i;
       end
    end
end