%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Alexandre Zaghetto (zaghetto@unb.br)            %
%          Pedro Salum Franco                              %
%          Daniel Sandoval                                 % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local: Department of Computer Science                    %
%        University of Brasília                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version: 2018-04-19                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Touchless-to-touch fingerprint convertion.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure
clc;
clear all;
close all;
warning('off','all')

% Prepare folders

PATHNAME = uigetdir([], 'Select image folder');
arquivos = dir([PATHNAME '/*.bmp']);

TotaldeArquivos = length(arquivos);

delete([PATHNAME '\avgBinaries\*.*']);

delete([PATHNAME '\processed\xyt\*.*']);
delete([PATHNAME '\processed\images\*.*']);
delete([PATHNAME '\processed\other']);

mkdir([PATHNAME '\avgBinaries']);

mkdir([PATHNAME '\processed\xyt']);
mkdir([PATHNAME '\processed\images']);
mkdir([PATHNAME '\processed\other']);

% Convert current folder format for NBIS
PATHCYG = currPathNBIS(PATHNAME);

% Quality indices
TotalQ = zeros(1, TotaldeArquivos);

tic
% Start convertion
parfor numimg = 1:TotaldeArquivos
    
    disp(numimg)
    
    existeArquivo = exist([PATHNAME '/processed/imagem_final_' num2str(numimg)  '.jpg'],'file') ~= 2;
    
    if existeArquivo
    
        mkdir([PATHNAME '/binarias' num2str(numimg)]);

        arquivos = dir([PATHNAME '/*.bmp']);
        
        FILENAME = arquivos(numimg).name;
        NOME = FILENAME(1:end-4);

        I = imread([PATHNAME '/' FILENAME]);
        [h, w] = size(I);

        % Local histogram equalization
        Funcao = @(block_struct) histeq(block_struct.data);

        % For different block sizes
        for TamanhoBloco = 9

            % Local histogram equalization
            Iblocada = blockproc(I,[TamanhoBloco TamanhoBloco],Funcao);                       

            % For different gamma values
            for Gamma = 1.5

                % ICorrecaoGama = (double(Iblocada)/max(max(double(Iblocada)))).^Gama;
                c = 1/(255.^Gamma);
                ICorrecaoGama = c*double(Iblocada).^Gamma;                

                % For different filter sizes and standard deviations
                for TamanhoFiltro = 3:2:9
                    Filtro = fspecial('gaussian', TamanhoFiltro, TamanhoFiltro/(2*sqrt(2*log(2))));
                    Ifinal = imfilter(uint8(255-255*ICorrecaoGama),Filtro);
                    imwrite(Ifinal,[PATHNAME '/binarias' num2str(numimg) '/' NOME num2str(TamanhoBloco) '_G' num2str(Gamma) '_F' num2str(TamanhoFiltro) '_D' num2str(TamanhoFiltro/(2*sqrt(2*log(2)))) '.jpg' ],'jpg','Quality',100);
                end

            end

        end

        % Verify which of the files are jpeg files
        arquivos = dir([PATHNAME '/binarias' num2str(numimg) '/*.jpg']);
        numArqu = length(arquivos);

        for i = 1:numArqu
            
            % Load image
            NOME_HIST =  arquivos(i).name;
            NOME_HIST_RAW = NOME_HIST(1:end-4);

            % Call mindtct for binary image generation
            system(['mindtct -b ' PATHCYG '/binarias' num2str(numimg) '/' NOME_HIST ' ' PATHCYG '/binarias' num2str(numimg) '/' NOME_HIST_RAW '_output'] );

            % Abre o arquivo bin?rio gerado pelo mindtct
            fid = fopen([PATHNAME '/binarias' num2str(numimg) '/' NOME_HIST_RAW '_output.brw'],'rb');
            Binaria = fread(fid,h*w,'uint8');
            Binaria = vec2mat(Binaria,w);
            imwrite(Binaria,[PATHNAME '/binarias' num2str(numimg) '/' NOME_HIST_RAW '_output_bin.bmp']);
            fclose(fid);
        end
                
        cleanNBISFiles([PATHNAME '/binarias' num2str(numimg) '/'],1,0);

        % Number of binary images
        arquivos = dir([PATHNAME '/binarias' num2str(numimg) '/*_output_bin.bmp']);
        numArqu = length(arquivos);

        % Open each image
        NOME_BIN = zeros(h, w, numArqu);
                                        
        for i = 1:numArqu
            NOME_BIN(:,:, i) =  double(imread([PATHNAME '/binarias' num2str(numimg) '/' arquivos(i).name]));           
        end
        
        % Compute and write average
        BIN_FINAL = uint8(mean(NOME_BIN,3));
        
        imwrite(BIN_FINAL,[PATHNAME '/avgBinaries/' NOME '.bmp']);
                
        % Perform crop
        MASCARA = not(BIN_FINAL<255);
        [i,j] = find(MASCARA == 0);

        maxH = max(i);
        minH = min(i);
        maxW = max(j);
        minW = min(j);
        
        BIN_FINAL_CROP = BIN_FINAL(minH:maxH,minW:maxW);

        % Apply geometry distortion
        ImgDistort = geomDistor( uint8(BIN_FINAL_CROP), 2);

        % Crop distorted image
        MASCARA = not(ImgDistort<255);                
        [i,j] = find(MASCARA == 0);

        maxH = max(i);
        minH = min(i);
        maxW = max(j);
        minW = min(j);
        
        % Crop distorted image
        ImgDistortCrop = ImgDistort(minH:maxH,minW:maxW);
        
        % Add noise
        ImgRuido = addNoise(uint8(ImgDistortCrop));
                
        % Fade borders        
        ImgCropped = uint8(fadeCrop(ImgRuido, 2, 6));
       
        % Imagem convertion for mindtct input
        imwrite(ImgCropped, [PATHNAME '/processed/imagem_final_' num2str(numimg)  '.jpg'], 'jpg', 'Quality', 100);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % From this point forward, generate files for NFIQ %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Call mindtct
        system(['mindtct -b ' PATHCYG '/processed/imagem_final_' num2str(numimg)  '.jpg ' PATHCYG '/processed/' NOME '_output'] );

        % Call nfiq for fingerprint quality check
        [n, Q] = system(['nfiq ' PATHCYG '/processed/imagem_final_' num2str(numimg)  '.jpg -d']);

        movefile([PATHNAME '/processed/' NOME '_output.xyt'],[PATHNAME '/processed/xyt/imagem_final_' num2str(numimg) '.xyt']);
        
        rmdir([PATHNAME '/binarias' num2str(numimg) '/'],'s');

    else  

        % Call nfiq for fingerprint quality check
        [n, Q] = system(['nfiq ' PATHCYG '/processed/imagem_final_' num2str(numimg)  '.jpg -d']);
        
    end
    
        TotalQ(numimg) = str2double(Q);
                     
end
toc

% Data set quality 
[media_nfiq, N, X] = fingQuality(TotalQ)

% Move files 
movefile([PATHNAME '\processed\*.jpg'],[PATHNAME '\processed\images\']);
movefile([PATHNAME '\processed\*output*.*'],[PATHNAME '\processed\other\']);

delete([PATHNAME '\avgBinaries\*.*']);
rmdir([PATHNAME '\avgBinaries']);

keepFiles([PATHNAME '\processed\'], '.jpg')

save main_convert_result.mat














