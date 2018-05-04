function [w, w_valid, w2, w2_valid, ws, ws2, linhas] = performMatch(TotaldeArquivos, PATHNAME, NumSamples)

% Debug cell array
ws = {};
ws2 = {};

% Limits
linhas = 1:NumSamples:TotaldeArquivos;

% Perform matching of each
parfor i=1:TotaldeArquivos
    for j=1:TotaldeArquivos
        if i<=j;
            [i j]
            [unused, value] = system(['bozorth3 -l ' PATHNAME '/imagem_final_' num2str(i)  '.xyt ' PATHNAME '/imagem_final_' num2str(j) '.xyt'] );
            %C = strsplit(value);
            % w(i,j)= str2double(C{end-1});
            w(i,j)= str2double(value);
            ws{i,j} = [num2str(i) '_' num2str(j)];
        end
    end
end

w_valid = triu(ones(TotaldeArquivos,TotaldeArquivos));

% Use w to calculate TP and FN
for i = 1:TotaldeArquivos
    
    w(i,i) = 0;
    w_valid(i, i) = 0;
    
    % ws is for debug
    ws{i,i} = [];
    
end

% Use w2 to calculate TN and FP
w2 = w;
w2_valid = w_valid;

% ws2 is for debug
ws2 = ws;

% Preserve only elements that are relevant for TP and FN calculations
for i = 1:length(linhas)-1
    w(linhas(i):linhas(i)+NumSamples-1, linhas(i+1):TotaldeArquivos) = 0;
    w_valid(linhas(i):linhas(i)+NumSamples-1, linhas(i+1):TotaldeArquivos) = 0;
end

% Number of True Positive tests
nTP = sum(sum(w_valid));
% nTP = length(linhas)* (NumSamples^2 - NumSamples)/2;


% Number of False Negative tests
nFN = nTP;

% Preserve only elements that are relevant for TN and FP calculations
for i = 1:length(linhas)
    
    w2(linhas(i):linhas(i)+NumSamples-1, linhas(i):linhas(i)+NumSamples-1) = 0;
    w2_valid(linhas(i):linhas(i)+NumSamples-1, linhas(i):linhas(i)+NumSamples-1) = 0;
    
    for j = linhas(i):linhas(i)+NumSamples-1
        for k = linhas(i):linhas(i)+NumSamples-1
            ws2{j, k} = [];
        end
    end
    
end


return












