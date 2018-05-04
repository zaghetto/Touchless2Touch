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
[nTP, TP nFN, FN, nTN, TN, nFP, FP, eer] =  plotRoc(w, w_valid, w2, w2_valid, ws, ws2, NumSamples, TotaldeArquivos, limThresh, showCurve);

% Save results. 
% This file is loaded in main_MonteCarlo.m in order to evaluate the
% algorithm.
save main_match_result.mat







