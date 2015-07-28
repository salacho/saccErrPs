function [meanCorr,meanIncorr,meanCorrBaseline,meanIncorrBaseline,tgtMeanCorr,tgtMeanIncorr,dist2tgtMean] = getErrRPsMean(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,tgtErrRPs,tgt2DistEpochs,ErrorInfo)
% function [meanCorr,meanIncorr,meanCorrBaseline,meanIncorrBaseline,tgtMeanCorr,tgtMeanIncorr,dist2tgtMean] = getErrRPsMean(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,tgtErrRPs,tgt2DistEpochs,ErrorInfo);
%
% Get mean values for correct and error trials, all channels, reduce trials
% to a grand average. This also applies for target and dist2tgt specific trials. 
%
% INPUT
% corrEpochs:           matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:         matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% corrBaseline:         matrix. Correct baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                       It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
% incorrBaseline:       matrix. Incorrect epochs baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                       It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
% tgtErrRPs:            cell with numTargets cells. Each cell has two
%                       field, one is corrEpochs (correct epochs for this expected target), 
%                       the other incorrEpochs (error epochs for this
%                       expected target).
%   corrEpochs:         matrix. Correct epochs for the specific target.
%                       [numChnls,numEpochs,numDatapoints]
%   incorrEpochs:       matrix. Incorrect epochs for the specific
%                       target. [numChnls,numEpochs,numDatapoints]
%   incorrDcdTgt:       vector. Decoded target for error (incorrect)
%                       epochs.
%   tgt2DistEpochs:     structure from 1:numTargets.For each target it
%                       has the following fields:
%   dcdTgtRange:        vector. Possible dcd targets given to this location (erroneous locations). 
%                       Possible values taken by dcd target for this true target location (iTgt)
%   numEpochsPerDist    integer. Number of epochs for each distance to true location
%   epochDist1:         matrix. [numChns numEpochs(for distance 1) numDataPoints]. 
%                       Error epochs with error at a distance 1 to the target location
%   epochDist2:         matrix. [numChns numEpochs(for distance 2) numDataPoints]. 
%                       Error epochs with error at a distance 2 to the target location
%   epochDist3:         matrix. [numChns numEpochs(for distance 3) numDataPoints]. 
%                       Error epochs with error at a distance 3 to the target location
%   dcdTgtDist1:        vector. Decoded targets for the error epochs with distance 1 to the target location
%   dcdTgtDist2:        vector. Decoded targets for the error epochs with distance 2 to the target location
%   dcdTgtDist3:        vector. Decoded targets for the error epochs with distance 3 to the target location
%   stdEpochDist1:      vector. Std of error epochs for distance 1 to target location
%   stdEpochDist2:      vector. Std of error epochs for distance 2 to target location
%   stdEpochDist3:      vector. Std of error epochs for distance 3 to target location
%   meanEpochDist1:     matrix. [numChannels numDatapoints]. Mean error epoch for distance 1 to target location
%   meanEpochDist2:     matrix. [numChannels numDatapoints]. Mean error epoch for distance 2 to target location
%   meanEpochDist3:     matrix. [numChannels numDatapoints]. Mean error epoch for distance 3 to target location
% ErrorInfo:            ErrRps info structure. The structure 'epochInfo' has 
%                       nChs, nTgts, lenEpoch.
%
% OUTPUT
% meanCorr:             matrix. [numChannels lengthEpoch]. Average of correct trials
% meanIncorr:           matrix. [numChannels lengthEpoch]. Average of incorrect trials
% meanCorrBaseline:     matrix. Mean correct baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                       It has the form [numChs ErrorInfo.Behav.dur.itiDur*Fs].
% meanIncorrBaseline:   matrix. Mean incorrect epochs baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                       It has the form [numChs ErrorInfo.Behav.dur.itiDur*Fs].
% tgtMeanCorr:          matrix. [numTargets numChannels lengthEpoch]. Average of correct trials per target
% tgtMeanIncorr:        matrix. [numTargets numChannels lengthEpoch]. Average of incorrect trials per target
% dist2tgtMean:         matrix of structure with field meanIncorr. dist2tgtMean(numTargets,maxDist2tgt).meanIncorr 
%                       'maxDist2tgt' is the max. distance from incorrect decoded target to true target 
%                       location (since 6 targets, max. dist. is 3). The field 
%                       meanIncorr is the average of incorrect trials per target with 
%                       a given distance from decoded target to true target location 
%
% Andres v1.0
% Created 19 July 2013
% Last modified 19 July 2013

tStart      = tic;                              % timing the code
nChs        = ErrorInfo.epochInfo.nChs;         % total number of channels
nTgts       = ErrorInfo.epochInfo.nTgts;        % total number of targets
lenEpoch    = ErrorInfo.epochInfo.lenEpoch;     % length of epoch
maxDist2tgt = 3;                                % max. distance from incorrect decoded target to true target location (since 6 targets, max. dist. is 3)

%% Mean 
meanCorr = squeeze(nanmean(corrEpochs,2));
meanIncorr = squeeze(nanmean(incorrEpochs,2));
meanCorrBaseline = squeeze(nanmean(corrBaseline,2)); 
meanIncorrBaseline = squeeze(nanmean(incorrBaseline,2));

% Pre-allocating memory
tgtMeanCorr     = nan(nTgts,nChs,lenEpoch);
tgtMeanIncorr   = nan(nTgts,nChs,lenEpoch);
%dist2tgtMean    = repmat(struct('meanIncorr',nan(nChs,lenEpoch)),nTgts,maxDist2tgt);
dist2tgtMean    = repmat(struct('meanIncorr',[]),nTgts,maxDist2tgt);

%% For each target
for iTgt = 1:nTgts
    fprintf('Calculating mean values for target %i...\n',iTgt)
    tgtMeanCorr(iTgt,:,:)   = squeeze(nanmean(tgtErrRPs(iTgt).corrEpochs,2));
    tgtMeanIncorr(iTgt,:,:) = squeeze(nanmean(tgtErrRPs(iTgt).incorrEpochs,2));
    
    %% For each dist2tgt
    distVals = tgt2DistEpochs(iTgt).dist2tgt;                               % List of distance of dcd target to true location
    if ~isempty(distVals)
        for iDist = 1:length(distVals)
            % Mean or error epochs
            iMeanDistTxt = sprintf('meanEpochDist%i',distVals(iDist));      % name of field with meanEpoch
            dist2tgtMean(iTgt,iDist).meanIncorr = tgt2DistEpochs(iTgt).(iMeanDistTxt);  % mean error epoch for this distance to target location
        end
    % If no no incorrect trials for this target 
    else
        fprintf('No dist2tgt values for target %i...\n',iTgt)
        % dist2tgtMean(iTgt,1).meanIncorr = [];
    end
end

tElapsed = toc(tStart);
fprintf('Getting mean values for all targets took %0.2f seconds...\n',tElapsed)
