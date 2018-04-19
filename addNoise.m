function I_am_the_walrus = addNoise(Imagem)


% Original image with padding
Orig = Imagem;
[ho wo] = size(Imagem);
Ip = uint8(255*ones(2*ho, 2*wo));
Ip(round(ho/2):round(ho/2)+ho-1,round(wo/2):round(wo/2)+wo-1 ) = Imagem;
[h w] = size(Ip);

% Default greylevel
color = 255;

% Total number of locations
Ntotal = h*w;

Delta = 100;

% Maximum distance (diagonal)
DistTotal = ceil(sqrt((ho/2)^2 + (wo/2)^2));

% Generate equally spaced distances
Distancias = 0:Delta:DistTotal;

% Max and min percentage of noise
minpercent = 1;
maxpercent = 3;

for d = 2:length(Distancias)
    
    % Percentage of locations where noise will be added as a function distance
    Percent = minpercent + ((maxpercent-minpercent)/DistTotal)*Distancias(d-1);
    
    % Percentage of locations where noise will be added
    N = (Percent/100)*Ntotal;
        
    % Randomly generate angles between 1 and 180 
    concat = ceil(N/180);
    ang = [];      
    for i = 1:concat
      ang = [ang randperm(180)];
    end
    
    % Randomly generate elippse major axis between 1 and 5
    concat = ceil(N/5);
    a = [];
    for i = 1:concat
        a = [a randperm(5)];
    end
    
    % Randomly generate elippse major axis between 1 and 2
    concat = ceil(N/2);
    b = [];      
    for i = 1:concat
      b = [b randperm(2)];
    end
    
    % Limits valid area
    fator = max(w, h);
        
    % Randomly generate rows indices 
    concat = ceil(N/fator);
    i = [];
    for n = 1:concat
        i = [i randperm(fator)];
    end
    
    % Randomly generate column indices
    concat = ceil(N/fator);
    j = [];      
    for n = 1:concat
      j = [j randperm(fator)];
    end
    
    % Select locations inside a circular region of interest
    D = sqrt( (i(1:round(N))-h/2).^2 + (j(1:round(N))-w/2).^2 );
    ivalid = find(D > Distancias(d-1) & D < Distancias(d) );
    
    % Initialize tmeporary image
    Itemp = zeros(h, w);
    
    % List of lications that will be processed
    list = zeros(h * w, 2);
     
    % For each selected point apply ellipses with randomly selected parameters
    for k = ivalid    
        
        toplist = 1;
        c = sqrt(a(k)* a(k) - b(k) * b(k));
        j(k) = round(j(k));
        i(k) = round(i(k));
        list(toplist, 1) = i(k);
        list(toplist, 2) = j(k);
        Itemp(i(k), j(k)) = color;
        
        colorEll = randi([0 255]);
        
        while (toplist > 0)
            
            y = list(toplist, 1);
            x = list(toplist, 2); 
            toplist = toplist - 1;

            if local_isValid(y, x + 1, i(k), j(k), a(k), c, ang(k), Itemp, h, w, color)
                toplist = toplist + 1;
                list(toplist, 1) = y;
                list(toplist, 2) = x + 1;
                Ip(list(toplist, 1), list(toplist, 2)) = colorEll;
                Itemp(list(toplist, 1), list(toplist, 2)) = color;        
            end
            
            if local_isValid(y - 1, x, i(k), j(k), a(k), c, ang(k), Itemp, h, w, color)
                toplist = toplist + 1;
                list(toplist, 1) = y - 1;
                list(toplist, 2) = x;
                Ip(list(toplist, 1), list(toplist, 2)) = colorEll;
                Itemp(list(toplist, 1), list(toplist, 2)) = color;
            end
            
            if local_isValid(y, x - 1, i(k), j(k), a(k), c, ang(k), Itemp, h, w, color)
                toplist = toplist + 1;
                list(toplist, 1) = y;
                list(toplist, 2) = x - 1;
                Ip(list(toplist, 1), list(toplist, 2)) = colorEll;
                Itemp(list(toplist, 1), list(toplist, 2)) = color;        
            end
            
            if local_isValid(y + 1, x, i(k), j(k), a(k), c, ang(k), Itemp, h, w, color) == 1
                toplist = toplist + 1;
                list(toplist, 1) = y + 1;
                list(toplist, 2) = x;
                Ip(list(toplist, 1), list(toplist, 2)) = colorEll;
                Itemp(list(toplist, 1), list(toplist, 2)) = color;        
            end

       end
                        
    end
    
end

% Define gaussian filter using full width at half maximum (FWHM)
fsize = 3;
hf = fspecial('gaussian',[fsize fsize], fsize/(2*sqrt(2*log(2))));

% Filter processed image
Ifinale = imfilter(Ip, hf);

% Computes a mask
mask = double(Orig > 200);
mask = bwmorph(mask,'clean');

% Ifinale = double(255*Mascara)+double(imfilter(Ip,h)).*double(not(Mascara));

% Remove padding
Iffp = Ifinale(round(ho/2):round(ho/2)+ho-1,round(wo/2):round(wo/2)+wo-1 );

% Compute gamma coefficients as a function of the distance
gamamax = 1.2;
gamamin = 0.1;
gamma = zeros(ho, wo);
for i = 1:ho
    for j = 1:wo        
        D = sqrt((i-ho/2)^2 + (j-wo/2)^2);
        gamma(i,j) = gamamax -(gamamax-gamamin)*D/(DistTotal);        
    end
end

% Apply gamma transformation
Iffp = double(Iffp)./255;
IGamma = Iffp.^gamma;   
IGamma = uint8(255*IGamma);

% c = 1./(255.^gamma);
% IGamma = c.*(double(Iffp).^gamma);

% Mask image generating sharp edges and keeping white background
INoise = uint8(double(255*mask)+double(IGamma).*double(1-double(mask)));

% Perform morphological operations to select transition areas
[BW1, thresh] = edge(mask,'canny');
BW1 = bwmorph(BW1,'thin');
BW1 = bwmorph(BW1,'clean');

se1 = strel('disk',1);
dilatedI = imdilate(BW1,se1);

% Blur image
fsize = 3;
hf = fspecial('gaussian',[fsize fsize], fsize/(2*sqrt(2*log(2))));
INoiseF = imfilter(INoise, hf);

% Keep transitions blured while central part remains untouched
I_am_the_walrus = uint8(double(INoiseF).*dilatedI + (1-dilatedI).*double(INoise));

end


function is_val = local_isValid(y, x, y0, x0, a, c, teta, im, ny, nx, color)

d1 = (x - x0 - c * cos(teta))^2 + (y - y0 - c * sin(teta))^2;
d1 = sqrt(d1);

d2 = (x - x0 + c * cos(teta))^2 + (y - y0 + c * sin(teta))^2;
d2 = sqrt(d2);

if (d1 + d2 <= 2*a) && (x>0) && (y>0) && (x <= nx) && (y <= ny) && (im(y, x) ~= color)        
    is_val = 1;
else
    is_val = 0;
end


end

