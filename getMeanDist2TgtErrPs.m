function [incorrMeanDist2Tgt,incorrStdDist2Tgt,incorrMeanDist2TgtArray,incorrStdDist2TgtArray,ErrorInfo,meanDist2Tgt,stdDist2Tgt] = ...
    getMeanDist2TgtErrPs(tgt2DistEpochs,ErrorInfo)
% function [incorrMeanDist2Tgt,incorrStdDist2Tgt,incorrMeanDist2TgtArray,incorrStdDist2TgtArray,ErrorInfo] = ...
%     getMeanDist2TgtErrPs(tgt2DistEpochs,ErrorInfo)
% 
% Get the mean epochs for each dist2target trials (for incorrect trials) 
% for each true target location, and also regarless of this factor. 
%
% INPUT
% tgt2DistEpochs:           structure [1:numTargets].For each target it
%                           has the following fields:
%         dist2tgt          vector. All possible distances of incorrect targets to true location    
%         dcdTgtRange:      vector. Possible dcd targets given to this location (erroneous locations). 
%                           Possible values taken by dcd target for this true target location (iTgt)
%         numEpochsPerDist: integer. Number of epochs for each distance to true location
%         epochDist1:       matrix. [numChns numEpochs(for distance 1) numDataPoints]. 
%                           Error epochs with error at a distance 1 to the target location
%         epochDist2:       matrix. [numChns numEpochs(for distance 2) numDataPoints]. 
%                           Error epochs with error at a distance 2 to the target location
%         epochDist3:       matrix. [numChns numEpochs(for distance 3) numDataPoints]. 
%                           Error epochs with error at a distance 3 to the target location
%         dcdTgtDist1:      vector. Decoded targets for the error epochs with distance 1 to the target location
%         dcdTgtDist2:      vector. Decoded targets for the error epochs with distance 2 to the target location
%         dcdTgtDist3:      vector. Decoded targets for the error epochs with distance 3 to the target location
%         stdEpochDist1:    vector. Std of error epochs for distance 1 to target location
%         stdEpochDist2:    vector. Std of error epochs for distance 2 to target location
%         stdEpochDist3:    vector. Std of error epochs for distance 3 to target location
%         meanEpochDist1:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 1 to target location
%         meanEpochDist2:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 2 to target location
%         meanEpochDist3:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 3 to target location
%
% OUTPUT
% incorrMeanDist2Tgt
% incorrStdDist2Tgt
% incorrMeanDist2TgtArray
% incorrStdDist2TgtArray
% meanDist2Tgt:             matrix. Mean epoch waveform for this dist2tgt. [3(Dist2Tgt) numChannels numSamples]
% stdDist2Tgt:              matrix. St.Dev. of epochs for this dist2tgt. [3(Dist2Tgt) numChannels numSamples]
%
% Andres    : v1.0  : init. Created 04 Nov 2014
% Andres    : v1.1  : added the mean and st.dev. for dist2Tgt regarless of
%                     true target location. 25 Nov. 2014

%% Vbles
Tgts  = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);

%% Pre allocating memory
% Params
nDist2Tgt = 3;
nChs = ErrorInfo.epochInfo.nChs;
nDataPoints = ErrorInfo.epochInfo.epochLen;
nArrays = ErrorInfo.plotInfo.nArrays;
% incorrect vbles
incorrMeanDist2Tgt  = nan(nDist2Tgt,nTgts,nChs,nDataPoints);
incorrStdDist2Tgt   = zeros(nDist2Tgt,nTgts,nChs,nDataPoints);
incorrMeanDist2TgtArray =  nan(nArrays,nDist2Tgt,nTgts,nDataPoints);
incorrStdDist2TgtArray  = zeros(nArrays,nDist2Tgt,nTgts,nDataPoints);
nIncorrTrials = zeros(nTgts,nDist2Tgt);
incorrStdError = nIncorrTrials;

%% Mean epochs for each dist2target
disp('')
for iTgt = 1:nTgts
    for iDist = 1:nDist2Tgt
        % Number of trials per dist2Tgt for this target
        nIncorrTrials(iTgt,iDist) = tgt2DistEpochs(iTgt).numEpochsPerDist(iDist);
        % Standard deviation or error
        if ErrorInfo.plotInfo.stdError
            incorrStdError(iTgt,iDist) =  sqrt(nIncorrTrials(iTgt,iDist));              % get standard error of the mean
            if incorrStdError(iTgt,iDist) == 0; incorrStdError(iTgt,iDist) = 1; end     % Kludge! For dist2Tgt with no trials!! to avoid division by 0
        else
            incorrStdError(iTgt,iDist)  = 1;    % get standard deviation
        end
        % Get mean and st.dev/error
        switch nIncorrTrials(iTgt,iDist)
            case 0                                                                      % no epochs for this target location for incorrect trials
                fprintf('For dist2Tgt%i and target %i no epochs available\n',iDist,iTgt)
            case 1                                                                      % only one epoch for this target and dist2Tgt location for incorrect trials
                incorrMeanDist2Tgt(iDist,iTgt,:,:) = eval(sprintf('tgt2DistEpochs(iTgt).epochDist%i;',iDist));
                fprintf('For dist2Tgt%i and target %i, 1 epochs available\n',iDist,iTgt)
            otherwise                                                                   % getting mean vals for incorrect trials
                fprintf('For dist2Tgt%i and target %i, %i epochs available\n',iDist,iTgt,nIncorrTrials(iTgt,iDist))
                incorrMeanDist2Tgt(iDist,iTgt,:,:) = eval(sprintf('squeeze(nanmean(tgt2DistEpochs(iTgt).epochDist%i,2));',iDist));
                % Standard deviation/error per location
                incorrStdDist2Tgt(iDist,iTgt,:,:) = eval(sprintf('squeeze(nanstd(tgt2DistEpochs(iTgt).epochDist%i,0,2))/incorrStdError(iTgt,iDist);',iDist));
        end
    end
end

%% Agregate channels and trials per array for mean and st.dev./error
nChsPerArray = length(ErrorInfo.plotInfo.arrayChs(1,:)); %#ok<NASGU>
for iArray = 1:ErrorInfo.plotInfo.nArrays
    for iTgt = 1:nTgts
        for iDist = 1:nDist2Tgt
            %fprintf('Calculating array mean and std for target %i and dist2Tgt %i...\n',iTgt,iDist)
            % For each dist2Tgt incorrect epochs
            if nIncorrTrials(iTgt,iDist) == 0                                  % no epochs
                fprintf('Target %i and dist2Tgt %i. No trials \n',iTgt,iDist)
            elseif nIncorrTrials(iTgt,iDist) == 1                              % only one epoch
                fprintf('Target %i and dist2Tgt %i has 1 epochs available\n',iTgt,iDist)
                 incorrMeanDist2TgtArray(iArray,iDist,iTgt,:) = eval(sprintf('nanmean(reshape(tgt2DistEpochs(iTgt).epochDist%i(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*nIncorrTrials(iTgt,iDist) nDataPoints]),1);',iDist));
            else                                                         % more than one epoch
                fprintf('Target %i and dist2Tgt%i have %i epochs available\n',iTgt,iDist,nIncorrTrials(iTgt,iDist))
                 incorrMeanDist2TgtArray(iArray,iDist,iTgt,:) = eval(sprintf('nanmean(reshape(tgt2DistEpochs(iTgt).epochDist%i(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*nIncorrTrials(iTgt,iDist) nDataPoints]),1);',iDist));
                 incorrStdDist2TgtArray(iArray,iDist,iTgt,:) = eval(sprintf('nanstd(reshape(tgt2DistEpochs(iTgt).epochDist%i(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*nIncorrTrials(iTgt,iDist) nDataPoints]),[],1);',iDist));
            end
        end
   end
end

%% Get mean and St. dev for each dist2Tgt regardless of true target location
% Separate trials per dist2Tgt regarless of true target location
[dist1Epochs,dist2Epochs,dist3Epochs,~] = getDist2Tgt(tgt2DistEpochs,ErrorInfo);
% Get mean and st.dev.
meanDist2Tgt = nan(nDist2Tgt,nChs,nDataPoints);
stdDist2Tgt = nan(nDist2Tgt,nChs,nDataPoints);
% Calculating...
meanDist2Tgt(1,:,:) = nanmean(dist1Epochs,2);
meanDist2Tgt(2,:,:) = nanmean(dist2Epochs,2);
meanDist2Tgt(3,:,:) = nanmean(dist3Epochs,2);
stdDist2Tgt(1,:,:) = nanstd(dist1Epochs,[],2);
stdDist2Tgt(2,:,:) = nanstd(dist2Epochs,[],2);
stdDist2Tgt(3,:,:) = nanstd(dist3Epochs,[],2);

% Save number of trials per target and dist2Tgt
ErrorInfo.epochInfo.nTrialsDist2Tgt = nIncorrTrials;
