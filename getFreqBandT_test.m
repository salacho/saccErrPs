function [expVar,n,pVals,mu,F,ErrorInfo] = getFreqBandT_test(popCorrFreqBand,popIncorrFreqBand,ErrorInfo)
% function [expVar,n,pVals,mu,F,ErrorInfo] = getFreqBandT_test(popCorrFreqBand,popIncorrFreqBand,ErrorInfo)
% 
% [times x freqBands x samples x chs]
%
%
%
%
%
% Andres    : v1.0  : init. June 2013
% Andres    : v2.0  : moved all to a function. 09 Nov 2014
% Andres    : V3    : using expVarTgt as example, changed to get T-test for freqBands

ErrorInfo.analysis.ANOVA.grandMeanMethod = 0;
ErrorInfo.analysis.ANOVA.calcOmega2ExpVar = 0;
ErrorInfo.analysis.ANOVA.analDim = 3;

% Number trials
nCorr = size(popCorrFreqBand,ErrorInfo.analysis.ANOVA.analDim);
nError = size(popIncorrFreqBand,ErrorInfo.analysis.ANOVA.analDim);

if ~isfield(ErrorInfo.analysis,'balanced')
    disp('Could not find ErrorInfo.analysis.balanced, adding it and forcing balanced analysis!!')
    ErrorInfo.analysis.balanced = 1;
end

if ErrorInfo.analysis.balanced
    % Create vbles
    nBalanced = min([nCorr nError]);
    % Randomly choosing trials, not always the first ones
    corrIndxRandBalance = randsample(nCorr,nBalanced);
    incorrIndxRandBalance = randsample(nError,nBalanced);
    % Data and labels for analysis
    ErrorEpochs = cat(3,popCorrFreqBand(:,:,corrIndxRandBalance,:), popIncorrFreqBand(:,:,incorrIndxRandBalance,:));
    ErrorID = [zeros(nBalanced,1);ones(nBalanced,1)];
else
    % Create vbles
    ErrorEpochs = cat(3,popCorrFreqBand, popIncorrFreqBand);
    ErrorID = [zeros(nCorr,1);ones(nError,1)];
end

%ErrorInfo.analysis.ANOVA.epochLabel
[expVar,n,pVals,mu,F] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);
F = squeeze(F);

%     figure, imagesc(squeeze(pVals)<0.01)
%     close all
end



