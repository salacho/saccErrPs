function [ampDecoding,dist2tgtMaxMinAmp,corrTgtMaxMinAmp] = getDist2TgtMaxMinAmp(tgt2DistEpochs,tgtErrRPs,ErrorInfo)
%
%
% Calculates the max and min amplitude values per trial and channel for a
% specific windo post feedback given by ErrorInfo.featSelect.dist2TgtAmpStart 
% and ErrorInfo.featSelect.dist2TgtAmpEnd. These values are store per target 
% (for correct and incorrect trials) and dist2tgt (for incorrect trials).
%
%
% Author    : Andres
%
% Andres    : v1.0  : init. 06 Nov 2014

% Vbles
rightShift  = ErrorInfo.epochInfo.preOutcomeTime/1000*ErrorInfo.epochInfo.Fs;
indxStart   = rightShift + (ErrorInfo.analysis.dist2TgtAmpStart)/1000*ErrorInfo.epochInfo.Fs; %#ok<*NASGU>
indxEnd     = rightShift + (ErrorInfo.analysis.dist2TgtAmpEnd)/1000*ErrorInfo.epochInfo.Fs;

ipsilatTgts = ErrorInfo.signalProcess.ipsilatTgts;
ipsiIndx = ErrorInfo.signalProcess.ipsiIndx;
contralatTgts = ErrorInfo.signalProcess.contralatTgts;
contraIndx = ErrorInfo.signalProcess.contraIndx;

% Each target
for iTgt = 1:ErrorInfo.epochInfo.nTgts
    % Each dist2Tgt
    for ii = 1:length(tgt2DistEpochs(iTgt).dist2tgt);
        iDist = tgt2DistEpochs(iTgt).dist2tgt(ii);
        % Fix matrix dimensions
        eval(sprintf('tgt2DistEpochs(iTgt).epochDist%i = fixEpochs3dims(tgt2DistEpochs(iTgt).epochDist%i);',iDist,iDist))
        % Get max and min
        eval(sprintf('matrixVals = (tgt2DistEpochs(iTgt).epochDist%i(:,:,indxStart:indxEnd));',iDist));
        dist2tgtMaxMinAmp{iTgt,ii}.max = nanmax(matrixVals,[],3);
        dist2tgtMaxMinAmp{iTgt,ii}.min = nanmin(matrixVals,[],3);
        dist2tgtMaxMinAmp{iTgt,ii}.iDist = iDist;
        dist2tgtMaxMinAmp{iTgt,ii}.nTrials = tgt2DistEpochs(iTgt).numEpochsPerDist(iDist);
    end
    
    % For correct trials
    tgtErrRPs(iTgt).corrEpochs = fixEpochs3dims(tgtErrRPs(iTgt).corrEpochs);
    corrTgtMaxMinAmp(iTgt).max = nanmax(tgtErrRPs(iTgt).corrEpochs(:,:,indxStart:indxEnd),[],3); 
    corrTgtMaxMinAmp(iTgt).min = nanmin(tgtErrRPs(iTgt).corrEpochs(:,:,indxStart:indxEnd),[],3); 
    corrTgtMaxMinAmp(iTgt).nTrials = size(tgtErrRPs(iTgt).corrEpochs,2);
end


%% Get dist2tgt features
factorError = [];
factorDist2Tgt = [];
factorLat = [];
factorTgt = [];
maxAmp = [];
minAmp = [];

chList = 1:96;
nChs = chList;

for iTgt = 1:ErrorInfo.epochInfo.nTgts
    fprintf('Calculating predictor matrix for dist2tgt amplitude for correct and incorrect trials, target %i...\n',iTgt)
    % Each dist2Tgt for this target
    for ii = 1:3 %size(dist2tgtMaxMinAmp,2)
        if ~isempty(dist2tgtMaxMinAmp{iTgt,ii})             % if not empty analyze
            % Incorrect trials
            % Num incorrect trials
            nErrTrials = dist2tgtMaxMinAmp{iTgt,ii}.nTrials;
            % Laterality
            if any(ipsilatTgts == iTgt)
                factorLat(end+1:end+nErrTrials,1) = repmat(ipsiIndx,[nErrTrials 1]);       
            else
                factorLat(end+1:end+nErrTrials,1) = repmat(contraIndx,[nErrTrials 1]);       
            end
            factorTgt(end+1:end+nErrTrials,1) = repmat(iTgt,[nErrTrials 1]);        % true (expected) target location 1:6
            factorError(end+1:end+nErrTrials,1) = ones(nErrTrials,1);               % one for trials that are error
            factorDist2Tgt(end+1:end+nErrTrials,1) = repmat(dist2tgtMaxMinAmp{iTgt,ii}.iDist,[nErrTrials 1]);      % dist2 tgt
            % Observations
            maxAmp(end+1:end+nErrTrials,:) = dist2tgtMaxMinAmp{iTgt,ii}.max(chList,:)';       % max amp
            minAmp(end+1:end+nErrTrials,:) = dist2tgtMaxMinAmp{iTgt,ii}.min(chList,:)';       % min amp
        end
    end
    % Correct trials for this target
    nCorrTrials = corrTgtMaxMinAmp(iTgt).nTrials;
    
    % Laterality
    if any(ipsilatTgts == iTgt)
        factorLat(end+1:end+nCorrTrials,1) = repmat(ipsiIndx,[nCorrTrials 1]);
    else
        factorLat(end+1:end+nCorrTrials,1) = repmat(contraIndx,[nCorrTrials 1]);
    end
    factorTgt(end+1:end+nCorrTrials,1) = repmat(iTgt,[nCorrTrials 1]);        % true (expected) target location 1:6
    factorError(end+1:end+nCorrTrials,1) = zeros(nCorrTrials,1);               % zero for trials that are correct
    factorDist2Tgt(end+1:end+nCorrTrials,1) = zeros(nCorrTrials,1);      % zero for correct targets
    % Observations
    maxAmp(end+1:end+nCorrTrials,:) = corrTgtMaxMinAmp(iTgt).max(chList,:)';
    minAmp(end+1:end+nCorrTrials,:) = corrTgtMaxMinAmp(iTgt).min(chList,:)';
end

%% Creating structure to output vbles
ampDecoding.factorError = factorError;
ampDecoding.factorDist2Tgt = factorDist2Tgt ;
ampDecoding.factorLat = factorLat;
ampDecoding.factorTgt = factorTgt;
ampDecoding.maxAmp = maxAmp;
ampDecoding.minAmp = minAmp;


