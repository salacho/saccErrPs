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

ErrorInfo.epochInfo.ANOVA.analDim = 2;
ErrorInfo.epochInfo.ANOVA.epochLabel = [0,1];
ErrorInfo.epochInfo.ANOVA.grandMeanMethod = 0;
ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar = 0;

% Params
Tgts = unique(ErrorInfo.epochInfo.corrExpTgt);
nTgts = length(Tgts);
nChs = ErrorInfo.epochInfo.nChs;
epochLen = ErrorInfo.epochInfo.epochLen;

% Initialize vbles
expVarTgt = nan(nTgts,nChs,epochLen); 
pValsTgt = nan(nTgts,nChs,epochLen); 
muTgt = nan(nTgts,nChs,ErrorInfo.epochInfo.ANOVA.analDim,epochLen);
nTgt = nan(nTgts,ErrorInfo.epochInfo.ANOVA.analDim);
fTgt = nan(nTgts,nChs,epochLen); 

% Running variance analysis for each target
for iTgt = 1:nTgts
    fprintf('Calculating ANOVA for Tgt%i\n',iTgt)
    
    corrEpochs = tgtErrRPs(iTgt).corrEpochs;        %correct epochs
    incorrEpochs = tgtErrRPs(iTgt).incorrEpochs;    %error epochs
    tgtErrorEpochs = [corrEpochs, incorrEpochs];    %unified epochs
    
    if ~(size(incorrEpochs,2) == 0)
        tgtErrorID = [zeros(size(corrEpochs,2),1);ones(size(incorrEpochs,2),1)];    % labeling epochs correct(0) or incorrect/error (1)
        % Running ANOVA
        [expVar,nTgt(iTgt,:),pVals,muTgt(iTgt,:,:,:),F] = myANOVA1(tgtErrorEpochs,tgtErrorID,ErrorInfo.epochInfo.ANOVA.analDim,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
        expVarTgt(iTgt,:,:) = squeeze(expVar);
        pValsTgt(iTgt,:,:)  = squeeze(pVals);
        fTgt(iTgt,:,:)      = squeeze(F);
        % No nans
        ErrorInfo.epochInfo.ANOVA.nanTgtANOVA(iTgt) = 0;
    else
        ErrorInfo.epochInfo.ANOVA.nanTgtANOVA(iTgt) = 1;
    end    
end

