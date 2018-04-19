function [ cropped ] = fadeCrop( imagem, grau, fade )

[h,w] = size(imagem);
x = [0:50:500];
y = [100 80 60 50 50 50 50 50 50 50 50];

p = polyfit(x,y,grau);
polinomio = polyval(p,[0:1:h]);

somaFade = fliplr([0:fade:255]);
tamSomaFade = size(somaFade);

cropped = uint8(255*ones(h,w));

for i = 1:h
    for j = 1:w
        if(j>polinomio(i) && j<(w-polinomio(i)))
            cropped(i,j) = imagem(i,j);
            if(ceil(j-polinomio(i))<=tamSomaFade(2))
                cropped(i,j) = cropped(i,j) + somaFade(ceil(j-polinomio(i)));
            end
            if(ceil((w-polinomio(i))-j) > 0 && ceil((w-polinomio(i))-j)<=tamSomaFade(2))
                cropped(i,j) = cropped(i,j) + somaFade(ceil((w-polinomio(i))-j));
            end
        end
        if(cropped(i,j) > 255)
            cropped(i,j) = 255;
        end
    end
end

%fazendo o fade em cima
for j = 1:w
    for i = 1:tamSomaFade(2)
        cropped(i,j) = cropped(i,j) + somaFade(i);
        if(cropped(i,j) > 255)
            cropped(i,j) = 255;
        end
    end
end

%fazendo  fade em baixo
somaFade = fliplr(somaFade);
for j = 1:w
    for i = (h-tamSomaFade(2)+1):h
        cropped(i,j) = cropped(i,j) + somaFade(i-h+tamSomaFade(2));
        if(cropped(i,j) > 255)
            cropped(i,j) = 255;
        end
    end
end

%     figure
%     imshow(cropped);

end

