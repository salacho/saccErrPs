function [corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials] = getMeanErrPs(corrEpochs,incorrEpochs,ErrorInfo)
%
%
%[corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials,tgtCorrMeanTrials,tgtIncorrMeanTrials,dist2tgtMean] = ...
%    getMeanErrPs(corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs,ErrorInfo)
%
% Get mean values for correct and error trials, all channels, reduce trials
% to a grand average. This also applies for target and dist2tgt specific trials. 
%
% INPUT
% corrEpochs:           matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:         matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
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
%                       nChs, nTgts, epochLen.
%
% OUTPUT
% corrMeanTrials:             matrix. [numChannels lengthEpoch]. Average of correct trials
% incorrMeanTrials:           matrix. [numChannels lengthEpoch]. Average of incorrect trials
% tgtCorrMeanTrials:          matrix. [numTargets numChannels lengthEpoch]. Average of correct trials per target
% tgtIncorrMeanTrials:        matrix. [numTargets numChannels lengthEpoch]. Average of incorrect trials per target
% dist2tgtMean:         matrix of structure with field incorrMeanTrials. dist2tgtMean(numTargets,maxDist2tgt).incorrMeanTrials 
%                       'maxDist2tgt' is the max. distance from incorrect decoded target to true target 
%                       location (since 6 targets, max. dist. is 3). The field 
%                       incorrMeanTrials is the average of incorrect trials per target with 
%                       a given distance from decoded target to true target location 
%
% Author:   Andres 
%
% Andres    : v1.0  : init. Created 19 July 2013
% Andres    : v2.0  : changed vbles names and added dimensionality check. 29 October 2014

tStart      = tic;                              % timing the code
nChs        = ErrorInfo.epochInfo.nChs;         % total number of channels
nTgts       = ErrorInfo.epochInfo.nTgts;        % total number of targets
epochLen    = ErrorInfo.epochInfo.epochLen;     % length of epoch
maxDist2tgt = 3;                                % max. distance from incorrect decoded target to true target location (since 6 targets, max. dist. is 3)

%% Get trial mean and standard error or deviation 
% Select type of error bars for mean correct and incorrect trials
fprintf('Plotting Error Bars for mean epochs per ch and array - %s\n',ErrorInfo.session)

if ErrorInfo.plotInfo.stdError
    corrStdError    =  sqrt(size(corrEpochs,2));            % get standard error of the mean 
    incorrStdError  =  sqrt(size(incorrEpochs,2));          % get standard error of the mean
else
    corrStdError    = 1;    % get standard deviation
    incorrStdError  = 1;    % get standard deviation
end

% Correct Mean Trials
if ndims(corrEpochs) == 3
    corrMeanTrials = squeeze(nanmean(corrEpochs,2));
    corrStdTrials = squeeze(nanstd(corrEpochs,0,2))/corrStdError;   % std epoch for correct trials
elseif ndims(corrEpochs) == 2                                       %#ok<ISMAT>
    corrMeanTrials = corrEpochs;                                    % only one epoch, hence no mean
    corrStdTrials = zeros(size(corrMeanTrials));   % std epoch for correct trials
else error('Number of dims for corrEpochs do not match')
end

% Incorrect Mean Trials
if ndims(incorrEpochs) == 3
    incorrMeanTrials = squeeze(mean(incorrEpochs,2));
    incorrStdTrials    = zeros(size(incorrEpochs))/incorrStdError;  % std = 0 since only one epoch for correct trials
elseif ndims(incorrEpochs) == 2                                     %#ok<ISMAT>
    incorrMeanTrials = incorrEpochs;                                % only one epoch, hence no mean
    incorrStdTrials = zeros(size(incorrMeanTrials));   % std epoch for correct trials
else error('Number of dims for incorrEpochs do not match')
end



% 
% 
% %% Target specific mean values
% % Pre-allocating memory
% tgtCorrMeanTrials     = nan(nTgts,nChs,epochLen);
% tgtIncorrMeanTrials   = nan(nTgts,nChs,epochLen);
% %dist2tgtMean    = repmat(struct('meanIncorr',nan(nChs,epochLen)),nTgts,maxDist2tgt);
% dist2tgtMean    = repmat(struct('incorrMeanTrials',[]),nTgts,maxDist2tgt);
% 
% %% For each target
% for iTgt = 1:nTgts
%     fprintf('Calculating mean values for target %i...\n',iTgt)
%     tgtCorrMeanTrials(iTgt,:,:)   = squeeze(nanmean(tgtErrRPs(iTgt).corrEpochs,2));
%     tgtIncorrMeanTrials(iTgt,:,:) = squeeze(nanmean(tgtErrRPs(iTgt).incorrEpochs,2));
%     
%     %% For each dist2tgt
%     distVals = tgt2DistEpochs(iTgt).dist2tgt;                               % List of distance of dcd target to true location
%     if ~isempty(distVals)
%         for iDist = 1:length(distVals)
%             % Mean or error epochs
%             iMeanDistTxt = sprintf('meanEpochDist%i',distVals(iDist));      % name of field with meanEpoch
%             dist2tgtMean(iTgt,iDist).meanIncorr = tgt2DistEpochs(iTgt).(iMeanDistTxt);  % mean error epoch for this distance to target location
%         end
%     % If no no incorrect trials for this target 
%     else
%         fprintf('No dist2tgt values for target %i...\n',iTgt)
%         % dist2tgtMean(iTgt,1).meanIncorr = [];
%     end
% end
% 
% tElapsed = toc(tStart);
% fprintf('Getting mean values for all targets took %0.2f seconds...\n',tElapsed)
