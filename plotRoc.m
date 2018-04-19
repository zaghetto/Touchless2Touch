function [nTP, TP nFN, FN, nTN, TN, nFP, FP, eer] =  plotRoc(w, w_valid, w2, w2_valid, ws, ws2, NumSamples, TotaldeArquivos, limThresh, showCurve)

linhas = 1:NumSamples:TotaldeArquivos;

nTP = sum(sum(w_valid));
nFN = nTP;
nTN = sum(sum(w2_valid));
nFP = nTN;

% Thresholds
T = 0:1:limThresh;

conta = 1;

for k = T
    
    % Apply threshold
    Z = (w2+w)>k;
    
    % Initialize variables
    TP(conta) = 0;
    FN(conta) = 0;
    FP(conta) = 0;
    TN(conta) = 0;
    
    % True Positive and False Negatives
    for i = 1:length(linhas)
        
        BlockTPFN = Z(linhas(i):linhas(i)+NumSamples-1, linhas(i):linhas(i)+NumSamples-1);
        
        TP(conta) = TP(conta)+sum(sum( BlockTPFN ));
        FN(conta) = FN(conta)+sum(sum(1-BlockTPFN))-((NumSamples^2 - NumSamples)/2 + NumSamples);
        
    end
    
    % False Positives and True Negatives
    for i = 1:length(linhas)-1
        
        BlockTNFP = Z(linhas(i):linhas(i)+NumSamples-1, linhas(i+1):TotaldeArquivos);
        
        FP(conta) = FP(conta) + sum(sum(BlockTNFP));
        TN(conta) = TN(conta) + sum(sum(1-BlockTNFP));
        
    end
    
    % Increment counter
    conta = conta +1;
    
end

% Percentages
TP = TP/nTP;
FN = FN/nFN;
TN = TN/nTN;
FP = FP/nFP;

% Calulate EER

eer = (FN(find(abs(FP-FN)<=min(abs(FP-FN)),1)) +...
    FP(find(abs(FP-FN)<=min(abs(FP-FN)),1)))/2

% Plot error rate
figure;
title(['EER: ' num2str(eer)]);
set(gca,'FontSize',12);
p = plot(FP,'--');
set(p,'LineWidth',2)
hold on
p = plot(FN,'r');
set(p,'LineWidth',2)
xlabel('Threshold')
ylabel('Error Rate (%)')
grid on
legend('False acceptance','False rejection','Location','Best');


end











