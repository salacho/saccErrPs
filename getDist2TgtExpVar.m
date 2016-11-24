function [expVar,n,pVals,mu,F] = getDist2TgtExpVar(popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt,ErrorInfo)
%
% Calculates the explained variance of dist2Tgt trials for a population.
% Uses a balanced numbre of trials approach to be statistically consistent
% and to avoid memory problems (not enough RAM).
%
%
%
% [channels x trials x samples]
%
%
%
%
%
% Andres    : v1.0  : init. 11 Nov 2014

if ~isfield(ErrorInfo.analysis,'balanced')
    disp('Could not find ErrorInfo.analysis.balanced, adding it and forcing balanced analysis!!')
    ErrorInfo.analysis.balanced = 1;
end

%% Vbles
ErrorInfo.analysis.ANOVA.grandMeanMethod = 0;
ErrorInfo.analysis.ANOVA.calcOmega2ExpVar = 0;
ErrorInfo.analysis.ANOVA.analDim = 2;

% Fix dims
popDist1Epochs = fixEpochs3dims(popDist1Epochs);
popDist2Epochs = fixEpochs3dims(popDist2Epochs);
popDist3Epochs = fixEpochs3dims(popDist3Epochs);

% Number trials
nDist1 = length(popDistDcdTgt(1).dcdTgt);
nDist2 = length(popDistDcdTgt(2).dcdTgt);
nDist3 = length(popDistDcdTgt(3).dcdTgt);

% With replacement or not
if isfield(ErrorInfo.analysis,'withReplacement')
    withReplacement = ErrorInfo.analysis.withReplacement;
else
    withReplacement  = 0;
end

if ErrorInfo.analysis.balanced
% Create vbles
    nBalanced = min([nDist1 nDist2 nDist3]);
    % Randomly choosing trials, not always the first ones
    if withReplacement
        dist1SampIndx = randsample(nDist1,nBalanced,'true');
        dist2SampIndx = randsample(nDist2,nBalanced,'true');
        dist3SampIndx = randsample(nDist3,nBalanced,'true');
    else
        dist1SampIndx = randsample(nDist1,nBalanced);
        dist2SampIndx = randsample(nDist2,nBalanced);
        dist3SampIndx = randsample(nDist3,nBalanced);
    end
    % Data and factors for analysis
    dist2TgtEpochs = [popDist1Epochs(:,dist1SampIndx,:), popDist2Epochs(:,dist2SampIndx,:), popDist3Epochs(:,dist3SampIndx,:)];
    dist2TgtID = [zeros(nBalanced,1);ones(nBalanced,1);2*ones(nBalanced,1)];
else
    dist2TgtEpochs = [popDist1Epochs, popDist2Epochs, popDist3Epochs];
    dist2TgtID = [zeros(nDist1,1);ones(nDist2,1);2*ones(nDist3,1)];
end

%ErrorInfo.analysis.ANOVA.epochLabel
[expVar,n,pVals,mu,F] = myANOVA1(dist2TgtEpochs,dist2TgtID,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);
F = squeeze(F);

end

 