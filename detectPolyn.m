function new_vecw = detectPolyn(Img, N)

[H,W] = size(Img);

Imf = uint8(255*ones(H,W));

k = 1;

for i = 1 : H
    
    for j = 1 : W
        
        if Img(i, j) ~= 255
            %pega os primeiros pontos de interseccao da imagem para gerar a
            %curva
            Imf(i, j) = 0;
            %vetores vec sao para armazenar os valores onde encontramos os
            %pontos para gerar a interpolacao
            vech(k) = i;
            vecw(k) = j;
            k = k + 1;            
            break;
        end
    end
    
end

pol = polyfit(vech, -vecw+H,N);

new_vecw = polyval(pol, vech);


end

