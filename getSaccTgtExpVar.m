function getSaccTgtExpVar
%
%
% Calculates ANOVA for ErrPs using expected target location as conditions
% (6 targets)
%
%
%
%
%
% author    : Andres    
% 
% andres    : 1.1   : init
%



tgtErrRPs(1)

corrEpochs: [96x48x1200 double]
incorrEpochs: [96x108x1200 double]
incorrDcdTgt: [108x1 double]
    
    
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
