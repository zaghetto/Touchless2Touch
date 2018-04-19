function ImagemCorrigida = geomDistor(Imagem, N)

[H,W] = size(Imagem);

new_vecw = detectPolyn(Imagem,N);

TamanhoNovaImagem = ceil(W+2*(max(new_vecw)-min(new_vecw)))+1;

Ip = 255*ones(H, TamanhoNovaImagem);

last_vecw = size(new_vecw, 2);
if last_vecw < H
    for i = last_vecw+1:H
        new_vecw(i) = new_vecw(last_vecw);
    end
end

for i = 1:H
    
       Li = imresize(Imagem(i,:),[1 W+2*(max(new_vecw) - new_vecw(i))]);      
       Ip(i,round((TamanhoNovaImagem-length(Li))/2):round((TamanhoNovaImagem-length(Li))/2)+length(Li)-1) = Li;    
end

ImagemCorrigida = uint8(Ip);

end

