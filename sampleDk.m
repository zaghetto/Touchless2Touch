function [Dk_w, Dk_w_valid, Dk_w2,  Dk_w2_valid] = sampleDk(p, i_dk, NumSamples, NSubSet, TotalFiles, w, w_valid, w2, w2_valid)

infe = NSubSet*(p-1) + 1;
supe = NSubSet*p;

% samplesTPFN
elems = sort(i_dk(infe:supe));

d = NSubSet*NumSamples;

Dk_w = zeros(d, d);
Dk_w_valid = zeros(d, d);

Dk_w2 = zeros(d, TotalFiles);
Dk_w2_d = zeros(d, d);

Dk_w2_valid = zeros(d,TotalFiles);
Dk_w2_valid_d = zeros(d, d);

cont = 1;

for i = elems
    
    infe = NumSamples*(i-1) + 1;
    supe = NumSamples*i;
    
    infeb = NumSamples*(cont-1) + 1;
    supeb = NumSamples*cont;
    
    Dk_w(infeb:supeb,infeb:supeb) = w(infe:supe, infe:supe);
    Dk_w_valid(infeb:supeb,infeb:supeb) = w_valid(infe:supe,infe:supe);
    
    Dk_w2(infeb:supeb, :) = w2(infe:supe, :);
    Dk_w2_d(:, infeb:supeb) = Dk_w2(:,infe:supe);
        
    Dk_w2_valid(infeb:supeb, :) = w2_valid(infe:supe, :);
    Dk_w2_valid_d(:, infeb:supeb) = Dk_w2_valid(:,infe:supe);
    
    
    cont = cont + 1;
end

