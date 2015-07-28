function ErrorInfo = getErrRPsEqualLimits(corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs,ErrorInfo)
% function ErrorInfo = getErrRPsEqualLimits(corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs,ErrorInfo);
%
% Calculates the max. and min. vals for each mean and std epochs for 
% channel, array and target. These values are used later to plot traces 
% with equal Y limits so they can be compared across channels, array and targets.
%
% INPUT
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% tgtErrRPs:                cell with numTargets cells. Each cell has two
%                           field, one is corrEpochs (correct epochs for this expected target), 
%                           the other incorrEpochs (error epochs for this
%                           expected target).
%         corrEpochs:       matrix. Correct epochs for the specific target.
%                           [numChnls,numEpochs,numDatapoints]
%         incorrEpochs:     matrix. Incorrect epochs for the specific
%                           target. [numChnls,numEpochs,numDatapoints]
%        incorrDcdTgt:      vector. Decoded target for error (incorrect)
%                           epochs.
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
% ErrorInfo:                ErrRps info structure. Has all the fields
%                           related to the analysis of ErrRPs.
%         session:          string. Usually in the form 'CS20120925'
%         filedate:         integer. Date in the order YYYMMDD: i.e. 20120925
%         dirs:             structure. Has the DataIn ans DataOut path for reading and saving files respectively.
%         Behav:            structure with all behavioral info from the
%                           data conversion Event functions.
%         EventInfo:        structure. Has all the events obtained in
%                           getOutcomeInfo.m
%         BCIparams:        structure. Decoder parameters (blockType and decodeOnly)
%         tgtDirections:    vector. Target locations in radians. 
%         trialInfo:        structure. Similar to EventInfo but specific to
%                           correct and incorrect trials
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% OUTPUT
% ErrorInfo:                ErrRps info structure update in field plotInfo.equalLim. Has all the fields
%                           'yMax' and 'yMin', both with the field included
%                           in the section, pre-allocating memory. See
%                           lines 78-135
% Andres. v1.0
% Created 15 July 2013
% Last modified: 18 July 2013

disp('Calculating equal limits for Y axis...')
tStart = tic;                                                   % How long this code took?
maxError = ErrorInfo.plotInfo.maxError;                         % Max. value mean + std can be 
maxMean = ErrorInfo.plotInfo.maxMean;                           % Max. value mean of channels can be 
nArrays = length(ErrorInfo.plotInfo.arrayLoc);                  % Total number of arrays (3 brain areas)
Tgts    = unique(ErrorInfo.epochInfo.corrExpTgt)';              % Possible targets 
nTgts   = length(Tgts);                                         % Total number of targets

%% Pre-allocating memory for max. fields
numDist2tgt = 3;                            % max. number of dist2tgt values (when 6 targets are used)
yMax = struct(...
    'corrMeanEpoch',        nan(nArrays,1),...                  % max. val for mean of correct epoch 
    'incorrMeanEpoch',      nan(nArrays,1),...                  % max. val for mean of incorrect epochs per array
    'bothMeanEpoch',        nan(nArrays,1),...                  % max. val for both means of correct and incorrect epochs per array
    'errorCorrMeanEpoch',   nan(nArrays,1),...                  % max. val for correct mean + std of epochs per array
    'errorIncorrMeanEpoch', nan(nArrays,1),...                  % max. val for incorrect mean + std of epochs per array
    'errorBothMeanEpoch',   nan(nArrays,1),...                  % max. val for both correct and incorrect mean + std of epochs per array
    'meanChsCorr',          nan(nArrays,1),...                  % max. val for mean of channels of correct epoch trials
    'errorChsCorr',         nan(nArrays,1),...                  % max. val for mean + std of channels of correct epoch trials
    'meanChsIncorr',        nan(nArrays,1),...                  % max. val for mean of channels of incorrect epoch trials
    'errorChsIncorr',       nan(nArrays,1),...                  % max. val for mean and std of channels of incorrect epoch trials
    'maxChs',               [],...                              % max. val for mean and std of channels for both correct and in correct trials
    'errorCorrTgt',         nan(nTgts,nArrays),...              % max. val for correct mean + std per target
    'errorIncorrTgt',       nan(nTgts,nArrays),...              % max. val for incorrect mean + std per target
    'errorBothTgt',         nan(nTgts,nArrays),...              % max. val between both correct and incorrect mean + std per target
    'errorCorrArrayTgt',    nan(nTgts,nArrays),...              % max. val for correct mean + std per array and target
    'errorIncorrArrayTgt',  nan(nTgts,nArrays),...              % max. val for incorrect mean + std per array and target
    'errorBothArrayTgt',    nan(nTgts,nArrays),...              % max. val for both correct and incorrect mean + std per array and per target
    'corrTgt',              nan(nTgts,nArrays),...              % max. val for correct trials per target and array
    'incorrTgt',            nan(nTgts,nArrays),...              % max. val for incorrect trials per target and array
    'bothTgt',              nan(nTgts,nArrays),...              % max. val for both correct and incorrect trials per target and array
    'chCorrTgt',            nan(nTgts,nArrays),...              % max. val. for correct trials per channel, target and array
    'meanCorrTgt',          nan(nTgts,nArrays),...              % max. val. for mean of channels per array and target, for correct trials
    'chDist2tgtLim',        nan(nTgts,nArrays,numDist2tgt),...  % max. val. for mean of dist2tgt per channel, array and target, for incorrect trials
    'meanDist2tgtLim',      nan(nTgts,nArrays),...              % max. val. for mean of channels and dist2tgt per array and target, for incorrect trials
    'bothChDist2tgt',       nan(nTgts,nArrays),...              % max. val. for mean of dist2tgt per channel, array and target, for both correct and incorrect trials
    'bothMeanDist2tgt',     nan(nTgts,1));                      % max. val. for mean of channels and dist2tgt per array and target, for both correct and incorrect trials

%% Pre-allocating memory for min. fields
yMin = struct(...
    'corrMeanEpoch',        nan(nArrays,1),...                  % max. val for mean of correct epoch 
    'incorrMeanEpoch',      nan(nArrays,1),...                  % max. val for mean of incorrect epochs per array
    'bothMeanEpoch',        nan(nArrays,1),...                  % max. val for both means of correct and incorrect epochs per array
    'errorCorrMeanEpoch',   nan(nArrays,1),...                  % max. val for correct mean + std of epochs per array
    'errorIncorrMeanEpoch', nan(nArrays,1),...                  % max. val for incorrect mean + std of epochs per array
    'errorBothMeanEpoch',   nan(nArrays,1),...                  % max. val for both correct and incorrect mean + std of epochs per array
    'meanChsCorr',          nan(nArrays,1),...                  % max. val for mean of channels of correct epoch trials
    'errorChsCorr',         nan(nArrays,1),...                  % max. val for mean + std of channels of correct epoch trials
    'meanChsIncorr',        nan(nArrays,1),...                  % max. val for mean of channels of incorrect epoch trials
    'errorChsIncorr',       nan(nArrays,1),...                  % max. val for mean and std of channels of incorrect epoch trials
    'minChs',               [],...                              % min. val for mean and std of channels for both correct and in correct trials
    'errorCorrTgt',         nan(nTgts,nArrays),...              % max. val for correct mean + std per target
    'errorIncorrTgt',       nan(nTgts,nArrays),...              % max. val for incorrect mean + std per target
    'errorBothTgt',         nan(nTgts,nArrays),...              % max. val between both correct and incorrect mean + std per target
    'errorCorrArrayTgt',    nan(nTgts,nArrays),...              % max. val for correct mean + std per array and target
    'errorIncorrArrayTgt',  nan(nTgts,nArrays),...              % max. val for incorrect mean + std per array and target
    'errorBothArrayTgt',    nan(nTgts,nArrays),...              % max. val for both correct and incorrect mean + std per array and per target
    'corrTgt',              nan(nTgts,nArrays),...              % max. val for correct trials per target and array
    'incorrTgt',            nan(nTgts,nArrays),...              % max. val for incorrect trials per target and array
    'bothTgt',              nan(nTgts,nArrays),...              % max. val for both correct and incorrect trials per target and array
    'chCorrTgt',            nan(nTgts,nArrays),...              % max. val. for correct trials per channel, target and array
    'meanCorrTgt',          nan(nTgts,nArrays),...              % max. val. for mean of channels per array and target, for correct trials
    'chDist2tgtLim',        nan(nTgts,nArrays,numDist2tgt),...  % max. val. for mean of dist2tgt per channel, array and target, for incorrect trials
    'meanDist2tgtLim',      nan(nTgts,nArrays),...              % max. val. for mean of channels and dist2tgt per array and target, for incorrect trials
    'bothChDist2tgt',       nan(nTgts,nArrays),...              % max. val. for mean of dist2tgt per channel, array and target, for both correct and incorrect trials
    'bothMeanDist2tgt',     nan(nTgts,1));                      % max. val. for mean of channels and dist2tgt per array and target, for both correct and incorrect trials

%% Getting epochs' mean and std per channel and per array
if ndims(corrEpochs) == 3                           
    meanCorrEpoch   = squeeze(mean(corrEpochs,2));          % mean epoch for correct trials
    stdCorrEpoch    = squeeze(std(corrEpochs,0,2));         % std epoch for correct trials
elseif ndims(corrEpochs) == 2                               %#ok<ISMAT>
    meanCorrEpoch   = corrEpochs;                           % no mean since only one epoch for correct trials
    stdCorrEpoch    = zeros(size(corrEpochs));              % std = 0 since only one epoch for correct trials
end
if ndims(incorrEpochs) == 3
    meanIncorrEpoch = squeeze(mean(incorrEpochs,2));        % mean epoch for incorrect trials
    stdIncorrEpoch  = squeeze(std(incorrEpochs,0,2));       % std epoch for incorrect trials
elseif ndims(incorrEpochs) == 2                            	%#ok<ISMAT>
    meanIncorrEpoch = incorrEpochs;                         % no mean epoch for incorrect trials, only 1 trial
    stdIncorrEpoch  = zeros(size(incorrEpochs));            % std epoch for incorrect trials
end

%% Getting max. and min. vals
disp('For plotSingleErrRPs...')
for ii = 1:nArrays
    %% Getting max. and min. vals for epochs (for plotSingleErrRPs)
    % Values per array
    corrVals    = meanCorrEpoch(1 + 32*(ii-1):32*ii,:);         % mean values incorrect trials for this array
    incorrVals  = meanIncorrEpoch(1 + 32*(ii-1):32*ii,:);       % mean values incorrect trials for array
    corrStd     = stdCorrEpoch(1 + 32*(ii-1):32*ii,:);          % std values correct trials for this array
    incorrStd   = stdIncorrEpoch(1 + 32*(ii-1):32*ii,:);        % std values incorrect trials for this array
    
    % Max. and Min. vals. for Mean-Epochs
    if max(max(corrVals,[],2)) > maxError                   	% if values bigger than maxError, use a fixed one
        yMax.corrMeanEpoch(ii)      = maxError;
    else yMax.corrMeanEpoch(ii)     = max(max(corrVals,[],2));
    end
    if max(max(incorrVals,[],2))> maxError                      % if values bigger than maxError, use a fixed one
        yMax.incorrMeanEpoch(ii)    = maxError;
    else yMax.incorrMeanEpoch(ii)   = max(max(incorrVals,[],2));
    end
    if min(min(corrVals,[],2)) < -maxError                      % if values smaller than -maxError, use a fixed one
        yMin.corrMeanEpoch(ii)      = -maxError;
    else yMin.corrMeanEpoch(ii)     = min(min(corrVals,[],2));
    end
    if min(min(incorrVals,[],2)) < -maxError                    % if values smaller than -maxError, use a fixed one
        yMin.incorrMeanEpoch(ii)    = -maxError;
    else yMin.incorrMeanEpoch(ii)   = min(min(incorrVals,[],2));
    end
    yMax.bothMeanEpoch(ii)  = max(yMax.corrMeanEpoch(ii),yMax.incorrMeanEpoch(ii));
    yMin.bothMeanEpoch(ii)  = min(yMin.corrMeanEpoch(ii),yMin.incorrMeanEpoch(ii));
    
    % Max. and Min. vals. for Error-Bars of Mean-Epochs
    tmpMaxCorr = (max(corrVals + corrStd,[],2));                % max. values of error bars per channel
    if max(tmpMaxCorr) > maxError                               % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMax.errorCorrMeanEpoch(ii)     = maxError;
    else yMax.errorCorrMeanEpoch(ii)    = max(tmpMaxCorr);
    end
    tmpMaxIncorr = (max(incorrVals + incorrStd,[],2));          % max. values of error bars per channel
    if max(tmpMaxIncorr) > maxError                             % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMax.errorIncorrMeanEpoch(ii)   = maxError;
    else yMax.errorIncorrMeanEpoch(ii)  = max(tmpMaxIncorr);
    end
    yMax.errorBothMeanEpoch(ii)         = max(yMax.errorCorrMeanEpoch(ii),yMax.errorIncorrMeanEpoch(ii));
    tmpMinCorr = (min(corrVals - corrStd,[],2));                % min. values of error bars per channel
    if min(tmpMinCorr) < -maxError                              % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMin.errorCorrMeanEpoch(ii)     = -maxError;
    else yMin.errorCorrMeanEpoch(ii)    = min(tmpMinCorr);
    end
    tmpMinIncorr = (min(incorrVals - incorrStd,[],2));          % min. values of error bars per channel
    if min(tmpMinIncorr) < -maxError                            % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMin.errorIncorrMeanEpoch(ii)   = -maxError;
    else yMin.errorIncorrMeanEpoch(ii)  = min(tmpMinIncorr);
    end
    yMin.errorBothMeanEpoch(ii)         = min(yMin.errorCorrMeanEpoch(ii),yMin.errorIncorrMeanEpoch(ii));
    
    %% Max. and Min. for Mean-channels (for plotMeanErrRPs)
    %max. vals
    if max(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1)) > maxError         % If values are bigger than maxError, replace it by fixed value.
        yMax.meanChsCorr(ii)    = maxError;
    else yMax.meanChsCorr(ii)   = max(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if max(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1) + std(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1)) > maxError
        yMax.errorChsCorr(ii)   = maxError;
    else yMax.errorChsCorr(ii)  = max(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1) + std(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if max(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1)) > maxError       % If values are bigger than maxError, replace it by fixed value.
        yMax.meanChsIncorr(ii)  = maxError;
    else yMax.meanChsIncorr(ii) = max(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if max(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1) + std(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1)) > maxError
        yMax.errorChsIncorr(ii) = maxError;                     % If values are bigger than maxError, replace it by fixed value.
    else yMax.errorChsIncorr(ii)= max(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1) + std(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    yMax.maxChs             = max(max(yMax.errorChsCorr),max(yMax.errorChsIncorr));
    %min. vals.
    if min(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1)) < -maxError        % If values are smaller than -maxError, replace it by fixed value.
        yMin.meanChsCorr(ii)    = -maxError;
    else yMin.meanChsCorr(ii)   = min(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if min(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1) - std(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1)) < -maxError
        yMin.errorChsCorr(ii)   = -maxError;                    % If values are smaller than -maxError, replace it by fixed value.
    else yMin.errorChsCorr(ii)  = min(mean(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1) - std(meanCorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if min(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1)) < -maxError      % If values are smaller than -maxError, replace it by fixed value.
        yMin.meanChsIncorr(ii)  = -maxError;
    else yMin.meanChsIncorr(ii) = min(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    if min(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1) - std(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1)) < -maxError
        yMin.errorChsIncorr(ii) = -maxError;                    % If values are smaller than -maxError, replace it by fixed value.
    else yMin.errorChsIncorr(ii)= min(mean(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1) - std(meanIncorrEpoch(1 + 32*(ii-1):32*ii,:),1));
    end
    yMin.minChs                 = min(min(yMin.errorChsCorr),min(yMin.errorChsIncorr));
end

%% Get Max. and Min. vals. for each targets (for plotTgtErrRPs)
%correct
[nChs,~,nDataPoints] = size(tgtErrRPs(1).corrEpochs);
corrMeanTgt = nan(nTgts,nChs,nDataPoints);                                          % epochs' mean
%incorrect
[nChs,~,nDataPoints] = size(tgtErrRPs(1).incorrEpochs);
incorrMeanTgt = nan(nTgts,nChs,nDataPoints);
disp('For plotTgtErrRPs...')

for iTgt = 1:nTgts
    % Getting Mean values for correct and incorrect epochs for target iTgt
    if ndims(tgtErrRPs(iTgt).corrEpochs) == 3
        corrMeanTgt(iTgt,:,:)   = squeeze(nanmean(tgtErrRPs(iTgt).corrEpochs,2));   % getting mean since more than 1 epoch
    elseif ndims(tgtErrRPs(iTgt).corrEpochs) == 2                                   %#ok<ISMAT> % only 1 epoch, no mean
        corrMeanTgt(iTgt,:,:)   = tgtErrRPs(iTgt).corrEpochs;
    end
    % Only mean values if more than 1 epoch
    switch ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt)
        case 0                                                                      % no epochs for this target location for incorrect trials
        case 1                                                                      % only one epoch for this target location for incorrect trials
            incorrMeanTgt(iTgt,:,:) = tgtErrRPs(iTgt).incorrEpochs;
        otherwise                                                                   % getting mean vals for incorrect trials
            incorrMeanTgt(iTgt,:,:) = squeeze(nanmean(tgtErrRPs(iTgt).incorrEpochs,2));
    end
    corrMean    = squeeze(corrMeanTgt(iTgt,:,:));                                   % mean values for this target
    incorrMean  = squeeze(incorrMeanTgt(iTgt,:,:));
    % Standard deviation per location
    stdCorr     = squeeze(std(tgtErrRPs(iTgt).corrEpochs,0,2));                     % standard deviation for this target
    stdIncorr   = squeeze(std(tgtErrRPs(iTgt).incorrEpochs,0,2));

    for ii = 1:nArrays
        %% Values per ch and array 
        corrVals        = corrMean(1 + 32*(ii-1):32*ii,:);
        stdCorrVals     = stdCorr(1 + 32*(ii-1):32*ii,:);
        incorrVals      = incorrMean(1 + 32*(ii-1):32*ii,:);
        stdIncorrVals   = stdIncorr(1 + 32*(ii-1):32*ii,:);
        % Get max. vals. per target. See pre-allocating memory section at 
        % the beginning of code 
        if max(max(corrVals + stdCorrVals,[],2)) > maxError;                % If values are bigger than maxError, replace it by fixed value.
            yMax.errorCorrTgt(iTgt,ii)      = maxError;
        else yMax.errorCorrTgt(iTgt,ii)     = max(max(corrVals + stdCorrVals,[],2));
        end
        if max(max(incorrVals + stdIncorrVals,[],2)) > maxError             % If values are bigger than maxError, replace it by fixed value.
            yMax.errorIncorrTgt(iTgt,ii)    = maxError;
        else yMax.errorIncorrTgt(iTgt,ii)   = max(max(incorrVals + stdIncorrVals,[],2));
        end
        % Max. Y limit for plot of errorbars per ch/per array/per target
        yMax.errorBothTgt(iTgt,ii) = max(yMax.errorCorrTgt(iTgt,ii),yMax.errorIncorrTgt(iTgt,ii));
        % Get min. vals. per target
        if min(min(corrVals - stdCorrVals,[],2)) < -maxError;               % If values are smaller than -maxError, replace it by fixed value.
            yMin.errorCorrTgt(iTgt,ii)      = -maxError;
        else yMin.errorCorrTgt(iTgt,ii)     = min(min(corrVals - stdCorrVals,[],2));
        end
        if min(min(incorrVals - stdIncorrVals,[],2)) < -maxError            % If values are smaller than -maxError, replace it by fixed value.
            yMin.errorIncorrTgt(iTgt,ii)    = -maxError;
        else yMin.errorIncorrTgt(iTgt,ii)   = min(min(incorrVals - stdIncorrVals,[],2));
        end
        % Min. Y limit for plot of errorbars per ch/per array/per target
        yMin.errorBothTgt(iTgt,ii) = min(yMin.errorCorrTgt(iTgt,ii),yMin.errorIncorrTgt(iTgt,ii));
       
        %% Values for averaged-channels per array error-bar plot
        % Getting max. values 
        if max(mean(corrVals,1) + std(corrVals,1)) > maxError               % If values are bigger than maxError, replace it by fixed value.
            yMax.errorCorrArrayTgt(iTgt,ii)     = maxError;
        else yMax.errorCorrArrayTgt(iTgt,ii)    = max(nanmean(corrVals,1) + nanstd(corrVals,1));
        end
        if max(mean(incorrVals,1) + std(incorrVals,1)) > maxError           % If values are bigger than maxError, replace it by fixed value.
           yMax.errorIncorrArrayTgt(iTgt,ii)    = maxError;
        else yMax.errorIncorrArrayTgt(iTgt,ii)  = max(nanmean(incorrVals,1) + nanstd(incorrVals,1));
        end
        yMax.errorBothArrayTgt(iTgt,ii) = max(yMax.errorCorrArrayTgt(iTgt,ii),yMax.errorIncorrArrayTgt(iTgt,ii));
        % Getting min. values for averaged-channels per array error-bar plot
        if min(mean(corrVals,1) - std(corrVals,1)) < -maxError
            yMin.errorCorrArrayTgt(iTgt,ii)     = -maxError;
        else yMin.errorCorrArrayTgt(iTgt,ii)    = min(nanmean(corrVals,1) - nanstd(corrVals,1));
        end
        if min(mean(incorrVals,1) - std(incorrVals,1)) < -maxError
            yMin.errorIncorrArrayTgt(iTgt,ii)   = -maxError;
        else yMin.errorIncorrArrayTgt(iTgt,ii)  = min(nanmean(incorrVals,1) - nanstd(incorrVals,1));
        end
        yMin.errorBothArrayTgt(iTgt,ii) = min(yMin.errorCorrArrayTgt(iTgt,ii),yMin.errorIncorrArrayTgt(iTgt,ii));
    
        %% Limits to plot all targets in each channel and array (each target a different color)
        %Max.
        if max(max(corrVals)) > maxMean                                  
            yMax.corrTgt(iTgt,ii)   = maxMean;                  % If values are bigger than maxMean, replace it by fixed value.
        else yMax.corrTgt(iTgt,ii)  = max(max(corrVals));
        end
        if max(max(incorrVals)) > maxMean
            yMax.incorrTgt(iTgt,ii) = maxMean;                  % If values are bigger than maxMean, replace it by fixed value.
        else yMax.incorrTgt(iTgt,ii)= max(max(incorrVals));
        end
        yMax.bothTgt(iTgt,ii) = max(yMax.corrTgt(iTgt,ii),yMax.incorrTgt(iTgt,ii));
        %Min.        
        if min(min(corrVals)) < -maxMean
            yMin.corrTgt(iTgt,ii)   = -maxMean;                 % If values are smaller than -maxMean, replace it by fixed value.
        else yMin.corrTgt(iTgt,ii)  = min(min(corrVals));
        end
        if min(min(incorrVals)) < -maxMean
            yMin.incorrTgt(iTgt,ii) = -maxMean;                 % If values are smaller than -maxMean, replace it by fixed value.
        else yMin.incorrTgt(iTgt,ii)= min(min(incorrVals));
        end
        yMin.bothTgt(iTgt,ii) = min(yMin.corrTgt(iTgt,ii),yMin.incorrTgt(iTgt,ii));
    end
end

%% Distance-to-targets plots (for plotTgtDistanceEpochs)
for iTgt = 1:nTgts                                                                  % For each target
    for ii = 1:nArrays                                                              % For each array
        fprintf('Target%i-Array%i\n',iTgt,ii)
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0                          % Only when there are incorrect trials for target 'iTgt'
            corrIndx        = (ErrorInfo.epochInfo.corrDcdTgt == iTgt);             % Indexes for correct trials
            corrEpochTgt    = squeeze(nanmean(corrEpochs(1+32*(ii-1):ii*32,corrIndx,:),2));    % Correct trials
            distVals        = tgt2DistEpochs(iTgt).dist2tgt;                        % List of distance of dcd target to true location
            
            % Max. and Min. vals for correct trials See pre-allocating memory
            % section at the beginning of code
            if max(max(corrEpochTgt)) > maxMean
                yMax.chCorrTgt(iTgt,ii)     = maxMean;
            else yMax.chCorrTgt(iTgt,ii)    = max(max(corrEpochTgt));
            end
            if min(min(corrEpochTgt)) < -maxMean
                yMin.chCorrTgt(iTgt,ii)     = -maxMean;
            else yMin.chCorrTgt(iTgt,ii)    = min(min(corrEpochTgt));
            end
            if max(nanmean(corrEpochTgt,1)) > maxMean
                yMax.meanCorrTgt(iTgt,ii)   = maxMean;
            else yMax.meanCorrTgt(iTgt,ii)  = max(nanmean(corrEpochTgt));
            end
            if min(nanmean(corrEpochTgt,1)) < -maxMean
                yMin.meanCorrTgt(iTgt,ii)   = -maxMean;
            else yMin.meanCorrTgt(iTgt,ii)  = min(nanmean(corrEpochTgt));
            end
            % Max. and Min. for incorrect trials. See pre-allocating memory
            % section at the beginning of code
            for iDist = 1:length(distVals)                                      % For each dist2tgt
                iMeanDistTxt    = sprintf('meanEpochDist%i',distVals(iDist));   % name of error/incorrect epochs
                arraysMeanIncorrEpoch = tgt2DistEpochs(iTgt).(iMeanDistTxt);    % for all arrays, incorrect epochs for this distance to target location
                meanIncorrEpoch = arraysMeanIncorrEpoch(1+32*(ii-1):ii*32,:);   % for array 'ii', incorrect epochs for this dist2tgt
                
                %% Dist2tgt per ch per array
                if max(max(meanIncorrEpoch)) > maxMean
                    yMax.chDist2tgtLim(iTgt,ii,iDist)   = maxMean;
                else yMax.chDist2tgtLim(iTgt,ii,iDist)  = max(max(meanIncorrEpoch));
                end
                if min(min(meanIncorrEpoch)) < -maxMean
                    yMin.chDist2tgtLim(iTgt,ii,iDist)   = -maxMean;
                else yMin.chDist2tgtLim(iTgt,ii,iDist)  = min(min(meanIncorrEpoch));
                end
                %% Mean of dist2tgt per array
                if max(nanmean(meanIncorrEpoch)) > maxMean
                    yMax.meanDist2tgtLim(iTgt,ii)   = maxMean;
                else yMax.meanDist2tgtLim(iTgt,ii)  = max(nanmean(meanIncorrEpoch));
                end
                if min(nanmean(meanIncorrEpoch)) < -maxMean
                    yMin.meanDist2tgtLim(iTgt,ii)   = -maxMean;
                else yMin.meanDist2tgtLim(iTgt,ii)  = min(nanmean(meanIncorrEpoch));
                end
            end
        else
            fprintf('No trials for target %i...\n',iTgt)
        end
        % Max. and Min. for all chs per array (1st plot plotTgtDistanceEpochs)
        yMax.bothChDist2tgt(iTgt,ii) = max(yMax.chCorrTgt(iTgt,ii),max(yMax.chDist2tgtLim(iTgt,ii,:)));
        yMin.bothChDist2tgt(iTgt,ii) = min(yMin.chCorrTgt(iTgt,ii),min(yMin.chDist2tgtLim(iTgt,ii,:)));
    end
    % All arrays and dist2tgt (2nd plot)
    yMax.bothMeanDist2tgt(iTgt) = max(nanmean(nanmean(yMax.meanCorrTgt)),max(max(yMax.meanDist2tgtLim)));
    yMin.bothMeanDist2tgt(iTgt) = min(nanmean(nanmean(yMin.meanCorrTgt)),min(min(yMin.meanDist2tgtLim)));
end

%% Mean of dist2tgt per target location (6Tgts-polar plot)
for ii = 1:nArrays
    % All dist2tgt per array (3rd plot)
    yMax.bothArrayMeanDist2tgt(ii) = max(max(yMax.meanCorrTgt(:,ii)),max(yMax.meanDist2tgtLim(:,ii)));
    yMin.bothArrayMeanDist2tgt(ii) = min(min(yMin.meanCorrTgt(:,ii)),min(yMin.meanDist2tgtLim(:,ii)));
end

% Saving values in structure
ErrorInfo.plotInfo.equalLim.yMax = yMax;
ErrorInfo.plotInfo.equalLim.yMin = yMin;

% Time it took to run this code
tElapsed = toc(tStart);
fprintf('Time it took to get equal Y limits was %0.2f seconds\n',tElapsed);
