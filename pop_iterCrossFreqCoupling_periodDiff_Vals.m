function pop_iterCrossFreqCoupling_periodDiff_Vals(subject)
%
%
%
%
%
%
%  clear all, clc, close all, subject = 'jonah';

%% Get data
if strcmp(subject,'chico'), load('E:\Data\saccErrP\popAnalysis\popCS20121012-1026-11_iterCrossFreqCoupling-allIter.mat')
else load('E:\Data\saccErrP\popAnalysis\popJS20140318-0328-9_iterCrossFreqCoupling-allIter.mat')
end

%%% TRUE PLOT OF DIFFERENCES!!!
%plotCrossCorrFreqBand_ErrDiffpostPreDiff_aveGroup1000Iter(preIncorrXcorrFreqBand_allIter,postIncorrXcorrFreqBand_allIter,preCorrXcorrFreqBand_allIter,postCorrXcorrFreqBand_allIter,errDiffFreqTxt,ErrorInfo)

%% Remove iterations with empty vals
indxPreCorr = find(squeeze(preCorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPreIncorr = find(squeeze(preIncorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPostCorr = find(squeeze(postCorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPostIncorr = find(squeeze(postIncorrXcorrFreqBand_allIter(1,1,1,:) == 0));

preCorrXcorrFreqBand = mean(preCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreCorr)),4);
preIncorrXcorrFreqBand = mean(preIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreIncorr)),4);
postCorrXcorrFreqBand = mean(postCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostCorr)),4);
postIncorrXcorrFreqBand = mean(postIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostIncorr)),4);

% Get pre-post diff to account for real change due to feedback presentation
postPreIncorr = postIncorrXcorrFreqBand - preIncorrXcorrFreqBand;
postPreCorr = postCorrXcorrFreqBand - preCorrXcorrFreqBand;
ErrDiffPre = postPreIncorr - postPreCorr;

%% Rearrange order of arrays so they all are PFC,SEF, FEF
if any((ErrorInfo.session(1:4) == 'J'))
    tmp = ErrDiffPre;
    ErrDiff(:,:,1:32) = tmp(:,:,65:96);
    ErrDiff(:,:,33:96) = tmp(:,:,1:64);
else
    ErrDiff = ErrDiffPre;
end

%% index
deltaIndx  = find(strcmp(errDiffFreqTxt,'delta'));
alphaIndx = find(strcmp(errDiffFreqTxt,'alpha'));
betaIndx = find(strcmp(errDiffFreqTxt,'beta'));
thetaIndx = find(strcmp(errDiffFreqTxt,'theta'));
gammaIndx = find(strcmp(errDiffFreqTxt,'gamma'));
hgammaIndx = find(strcmp(errDiffFreqTxt,'highGam'));

%% Data
DeltaAlpha  = squeeze(ErrDiff(deltaIndx,alphaIndx,:)); %#ok<*FNDSB>
ThetaAlpha  = squeeze(ErrDiff(thetaIndx,alphaIndx,:));
BetaAlpha   = squeeze(ErrDiff(betaIndx,alphaIndx,:));
AlphaGamma = squeeze(ErrDiff(alphaIndx,gammaIndx,:));
BetaGamma = squeeze(ErrDiff(betaIndx,gammaIndx,:));
GammaHgamma = squeeze(ErrDiff(gammaIndx,hgammaIndx,:));






end