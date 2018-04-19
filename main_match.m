%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Alexandre Zaghetto (zaghetto@unb.br)             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local: Department of Computer Science                    %
%        University of Brasília                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version: 2018/03/01                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Perform matching. If there are no xyt files,%
% main_convert must be executed first.                     %                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure
clc;
clear all;
close all;
warning('off','all')

% Prepare folders
PATHNAME = uigetdir([], 'Select xyt folder');
xytFiles = dir([PATHNAME '/*.xyt']);

% Number of files
TotaldeArquivos = length(xytFiles);

% Convert current folder format for NBIS
PATHCYG = currPathNBIS(PATHNAME);

% Samples per finger
NumSamples = 2;

% Perform matching
tic
[w, w_valid, w2, w2_valid, ws, ws2, linhas] = performMatch(TotaldeArquivos, PATHCYG, NumSamples);
toc

% Plot ROC
limThresh = 270;
showCurve = 1;
[nTP, TP nFN, FN, nTN, TN, nFP, FP, eer] =  plotRoc(w, w_valid, w2, w2_valid, ws, ws2, NumSamples, TotaldeArquivos, limThresh, showCurve)

save main_match_result.mat

break


% Monte Carlo
total = 1;

% Randomly chose all fingerprint samples of 20 individuals
NSubSet = 20;

for monte = 1:100
    
    i_dk = randperm(80);
    
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

close all
EXPERIMENTOS = eer;
index = histfit(EXPERIMENTOS, round(sqrt(length(EXPERIMENTOS))), 'normal')
index(1).FaceColor = [.9 .9 .9];
i = find( abs(index(2).XData-mean(EXPERIMENTOS)) == min(abs(index(2).XData-mean(EXPERIMENTOS))))
hold on
stem(index(2).XData(i), index(2).YData(i),'ob','LineWidth',2)

j = find(abs((abs(index(2).XData) - abs(mean(EXPERIMENTOS) - std(EXPERIMENTOS)))) == min(abs((abs(index(2).XData) - abs(mean(EXPERIMENTOS) - std(EXPERIMENTOS)))))  )
k = find(abs((abs(index(2).XData) - abs(mean(EXPERIMENTOS) + std(EXPERIMENTOS)))) == min(abs((abs(index(2).XData) - abs(mean(EXPERIMENTOS) + std(EXPERIMENTOS)))))  )
stem([index(2).XData(j) index(2).XData(k)], [index(2).YData(j) index(2).YData(k) ],'xk','LineWidth',2)

set(gca,'fontsize', 14)

grid on
xlabel('Equal Error Rate')
ylabel('Number of Experiments')

h = legend('Histogram', 'Gaussian fit', ['M_{EEE} = ' num2str(round(mean(10000*EXPERIMENTOS))/100) '%'], ['S_{EER} = \pm' num2str(round(std(10000*EXPERIMENTOS))/100) '%'])
set(h,'fontsize', 10)



% 
% % Plot error rate
% figure;
% set(gca,'FontSize',12);
% p = plot(FPs,'--');
% set(p,'LineWidth',2)
% hold on
% p = plot(FNs,'r');
% set(p,'LineWidth',2)
% xlabel('Threshold')
% ylabel('Error Rate (%)')
% grid on
% legend('False acceptance','False rejection','Location','Best');
% 




