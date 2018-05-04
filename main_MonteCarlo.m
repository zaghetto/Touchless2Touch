%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Alexandre Zaghetto (zaghetto@unb.br)             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local: Department of Computer Science                    %
%        University of Brasília                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version: 2018/05/04                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Calculate EER using Monte Carlo method.     %                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prepare envoronment
clear all
close all

% Load matching results from main_match.m script
load main_match_result.mat

% Monte Carlo
total = 1;

% Total number of individuals
TotNumInd = TotaldeArquivos/NumSamples;

% Randomly chose all fingerprint samples of 20 individuals
NSubSet = 20;

% Perform Monte Carlo
for monte = 1:100
    
    i_dk = randperm(TotNumInd);
    
    for p = 1:4
        
        [Dk_w, Dk_w_valid, Dk_w2_d,  Dk_w2_valid] = sampleDk(p, i_dk, NumSamples, NSubSet, TotaldeArquivos, w, w_valid, w2, w2_valid);
        
        % Vector with TP and FN matches
        [Dk_i, Dk_j] = find(Dk_w_valid == 1);
        samplesTPFN = zeros(1,length(Dk_i));
        for k = 1:length(Dk_i)
            samplesTPFN(k) = Dk_w( Dk_i(k), Dk_j(k) );
        end
                
        % Vector with TN and FP matches
        for n = 1:NumSamples
            
            rows = (1:NumSamples:100-NumSamples) + n-1;
            
            k = 1;
            
            for i = 1:length(rows)
                
                cols = (i*NumSamples+1:NumSamples:100) +  n-1;
                
                for j = 1:length(cols)
                    
                    samplesTNFP(k) = Dk_w2_d(rows(i),cols(j));
                    
                    k = k + 1;
                    
                end
                
            end
            
            eer(total) = eerSample(samplesTPFN, samplesTNFP);
            
            total = total + 1;
            
        end
        
        p = p+1;
        
    end
end

% Plot results
close all

EXPERIMENTS = eer;
index = histfit(EXPERIMENTS, round(sqrt(length(EXPERIMENTS))), 'normal')
index(1).FaceColor = [.9 .9 .9];
i = find( abs(index(2).XData-mean(EXPERIMENTS)) == min(abs(index(2).XData-mean(EXPERIMENTS))))
hold on
stem(index(2).XData(i), index(2).YData(i),'ob','LineWidth',2)

j = find(abs((abs(index(2).XData) - abs(mean(EXPERIMENTS) - std(EXPERIMENTS)))) == min(abs((abs(index(2).XData) - abs(mean(EXPERIMENTS) - std(EXPERIMENTS)))))  )
k = find(abs((abs(index(2).XData) - abs(mean(EXPERIMENTS) + std(EXPERIMENTS)))) == min(abs((abs(index(2).XData) - abs(mean(EXPERIMENTS) + std(EXPERIMENTS)))))  )
stem([index(2).XData(j) index(2).XData(k)], [index(2).YData(j) index(2).YData(k) ],'xk','LineWidth',2)

set(gca,'fontsize', 14)

grid on
xlabel('Equal Error Rate')
ylabel('Number of Experiments')

h = legend('Histogram', 'Gaussian fit', ['M_{EEE} = ' num2str(round(mean(10000*EXPERIMENTS))/100) '%'], ['S_{EER} = \pm' num2str(round(std(10000*EXPERIMENTS))/100) '%'])
set(h,'fontsize', 10)





