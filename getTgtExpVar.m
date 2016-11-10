function [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo)
% function [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo)
%
% Calculates ANOVA 1 covariate for all correct and incorrect epochs for 
% each one of the targets (6). For the ANOVa analysis, labels with zeros are 
% for correct trials, ones are for incorrect (error) trials. See
% tgtErrorID.
% 
% INPUT
% tgtErrRPs
%
% OUTPUT
% expVarTgt
% 
% Andres v1.0
% Andres    : v2.0  : added the option of balanced (same number of trials) analysis since it is the proper one. 11 Nov 2014

ErrorInfo.analysis.ANOVA.analDim = 2;
ErrorInfo.analysis.ANOVA.epochLabel = [0,1];
ErrorInfo.analysis.ANOVA.grandMeanMethod = 0;
ErrorInfo.analysis.ANOVA.calcOmega2ExpVar = 0;

% Params
Tgts = unique(ErrorInfo.epochInfo.corrExpTgt);
nTgts = length(Tgts);
[nChs,~,nSamps] = size(tgtErrRPs(1).corrEpochs);

% Initialize vbles
expVarTgt = nan(nTgts,nChs,nSamps); 
pValsTgt = nan(nTgts,nChs,nSamps); 
muTgt = nan(nTgts,nChs,ErrorInfo.analysis.ANOVA.analDim,nSamps);
nTgt = nan(nTgts,ErrorInfo.analysis.ANOVA.analDim);
fTgt = nan(nTgts,nChs,nSamps); 

% Running variance analysis for each target
for iTgt = 1:nTgts
    fprintf('Calculating ANOVA for Tgt%i\n',iTgt)
    
    % Fix 2 dims
    if and(strcmpi(ErrorInfo.session(1),'p'),isfield(tgtErrRPs,'corr'))
        tgtCorrEpochs = fixEpochs3dims(tgtErrRPs(iTgt).corr);        %correct epochs
        tgtIncorrEpochs = fixEpochs3dims(tgtErrRPs(iTgt).incorr);    %error epochs
    else
        tgtCorrEpochs = fixEpochs3dims(tgtErrRPs(iTgt).corrEpochs);        %correct epochs
        tgtIncorrEpochs = fixEpochs3dims(tgtErrRPs(iTgt).incorrEpochs);    %error epochs
    end
    
    if ~(size(tgtIncorrEpochs,2) == 0)
        % No nans
        ErrorInfo.analysis.ANOVA.nanTgtANOVA(iTgt) = 0;
        % If balanced number of trials
        if ErrorInfo.analysis.balanced
            nBalanced = min([size(tgtCorrEpochs,2) size(tgtIncorrEpochs,2)]);
            % Randomly choosing trials, not always the first ones
            corrIndxRandBalance = randsample(size(tgtCorrEpochs,2),nBalanced);
            incorrIndxRandBalance = randsample(size(tgtIncorrEpochs,2),nBalanced);
            % Data and labels for analysis
            tgtErrorEpochs = [tgtCorrEpochs(:,corrIndxRandBalance,:), tgtIncorrEpochs(:,incorrIndxRandBalance,:)];      % unified epochs
            tgtErrorID = [zeros(nBalanced,1);ones(nBalanced,1)];                            % labeling epochs correct(0) or incorrect/error (1)
        else
            % Data and labels for analysis
            tgtErrorEpochs = [tgtCorrEpochs, tgtIncorrEpochs];                                    %unified epochs
            tgtErrorID = [zeros(size(tgtCorrEpochs,2),1);ones(size(tgtIncorrEpochs,2),1)];        % labeling epochs correct(0) or incorrect/error (1)
        end
        % Running ANOVA
        [expVar,nTgt(iTgt,:),pVals,muTgt(iTgt,:,:,:),F] = myANOVA1(tgtErrorEpochs,tgtErrorID,ErrorInfo.analysis.ANOVA.analDim,ErrorInfo.analysis.ANOVA.epochLabel,ErrorInfo.analysis.ANOVA.grandMeanMethod,ErrorInfo.analysis.ANOVA.calcOmega2ExpVar);
        expVarTgt(iTgt,:,:) = squeeze(expVar);
        pValsTgt(iTgt,:,:)  = squeeze(pVals);
        fTgt(iTgt,:,:)      = squeeze(F);
    else
        ErrorInfo.analysis.ANOVA.nanTgtANOVA(iTgt) = 1;
    end
end

