function [media_nfiq, N, X] = fingQuality(TotalQ)


[N,X] = hist(TotalQ,[1 2 3 4 5]);

h = bar(N)
colormap summer
set(gca,'FontSize', 14)
set(gca,'xticklabel', [])
ylabel(['Number of fingerprints'])
grid on
inclina = 15;
dispy = -10;
tam = 10;
text(1,dispy,'Excelent',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',tam); 
text(2,dispy,'Very good',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',tam);  
text(3,dispy,'Good',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',tam); 
text(3,-50,'Indice de qualidade',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',14);
text(4,dispy,'Fair',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',tam); 
text(5,dispy,'Poor',...
'HorizontalAlignment','Center','Rotation',inclina,'FontSize',tam); 

media_nfiq =0;
for i=1:5
    media_nfiq = media_nfiq + (i)*N(i);
end

media_nfiq = media_nfiq/sum(N)

return

