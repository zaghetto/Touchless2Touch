function eer = eerSample(samplesTPFN, samplesTNFP)

% Thresholds
T = 0:1:150;

% Counter
conta = 1;

for k = T
    
    % Apply threshold
    Zw = samplesTPFN>k;
    Zw2 = samplesTNFP>k;
    
    % Initialize variables
    TPs(conta) = 0;
    FNs(conta) = 0;
    FPs(conta) = 0;
    TNs(conta) = 0;
    
    TPs(conta) = TPs(conta)+sum(sum(Zw));
    FNs(conta) = FNs(conta)+sum(sum(1-Zw));
    FPs(conta) = FPs(conta)+sum(sum(Zw2));
    TNs(conta) = TNs(conta)+sum(sum(1-Zw2));
    
    conta = conta + 1;
    
end

TPs = TPs/length(samplesTPFN);
FNs = FNs/length(samplesTPFN);
TNs = TNs/length(samplesTNFP);
FPs = FPs/length(samplesTNFP);

eer = (FNs(find(abs(FPs-FNs)<=min(abs(FPs-FNs)),1)) +...
    FPs(find(abs(FPs-FNs)<=min(abs(FPs-FNs)),1)))/2;

return