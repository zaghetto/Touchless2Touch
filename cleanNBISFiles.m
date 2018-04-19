% funcao para deletar todos os arquivos que nao serao utilizados.

function [] = clean_up(folder, jpeg, bmp)

delete([folder '*.brw']);
delete([folder '*.dm']);
delete([folder '*.hcm']);
delete([folder '*.lcm']);
delete([folder '*.lfm']);
delete([folder '*.min']);
delete([folder '*.qm']);
delete([folder '*.xyt']);

if (jpeg == 1)
    delete([folder '*.jpg']);
    
end
    
if (bmp == 1)
    delete([folder '*.bmp']);
    
end
    
end

