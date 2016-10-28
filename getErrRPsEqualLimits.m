function ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs)
% function ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);
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
%         sampErrEpochDist1:vector. Standard error mean of incorrect epochs for distance 1 to target location
%         sampErrEpochDist2:vector. Standard error mean of incorrect epochs for distance 2 to target location
%         sampErrEpochDist3:vector. Standard error mean of incorrect epochs for distance 3 to target location
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
% Last modified: 29 Oct 2014

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

%% Getting epochs' mean and st.dev/error per channel and per array
tempFlag = ErrorInfo.epochInfo.getMeanArrayEpoch; ErrorInfo.epochInfo.getMeanArrayEpoch = true;
[corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials,corrArrayMean,incorrArrayMean,corrArrayStd,incorrArrayStd] = ...
    getMeanTrialsErrPs(corrEpochs,incorrEpochs,ErrorInfo);
ErrorInfo.epochInfo.getMeanArrayEpoch = tempFlag;

%% Getting max. and min. vals
disp('For plotSingleErrRPs and plotMeanErrRPs...')
for iArray = 1:nArrays
    %% Getting max. and min. vals for epochs (for plotSingleErrRPs)
    % Values per array
    corrVals    = corrMeanTrials(ErrorInfo.plotInfo.arrayChs(iArray,:),:);         % mean values incorrect trials for this array
    incorrVals  = incorrMeanTrials(ErrorInfo.plotInfo.arrayChs(iArray,:),:);       % mean values incorrect trials for array
    corrStd     = corrStdTrials(ErrorInfo.plotInfo.arrayChs(iArray,:),:);          % st.dev or st.error values correct trials for this array
    incorrStd   = incorrStdTrials(ErrorInfo.plotInfo.arrayChs(iArray,:),:);        % st.dev or st.error incorrect trials for this array
    
    % Max. and Min. vals. for Mean-Epochs
    if max(max(corrVals,[],2)) > maxError                   	% if values bigger than maxError, use a fixed one
        yMax.corrMeanEpoch(iArray)      = maxError;
    else yMax.corrMeanEpoch(iArray)     = max(max(corrVals,[],2));
    end
    if max(max(incorrVals,[],2))> maxError                      % if values bigger than maxError, use a fixed one
        yMax.incorrMeanEpoch(iArray)    = maxError;
    else yMax.incorrMeanEpoch(iArray)   = max(max(incorrVals,[],2));
    end
    if min(min(corrVals,[],2)) < -maxError                      % if values smaller than -maxError, use a fixed one
        yMin.corrMeanEpoch(iArray)      = -maxError;
    else yMin.corrMeanEpoch(iArray)     = min(min(corrVals,[],2));
    end
    if min(min(incorrVals,[],2)) < -maxError                    % if values smaller than -maxError, use a fixed one
        yMin.incorrMeanEpoch(iArray)    = -maxError;
    else yMin.incorrMeanEpoch(iArray)   = min(min(incorrVals,[],2));
    end
    yMax.bothMeanEpoch(iArray)  = max(yMax.corrMeanEpoch(iArray),yMax.incorrMeanEpoch(iArray));
    yMin.bothMeanEpoch(iArray)  = min(yMin.corrMeanEpoch(iArray),yMin.incorrMeanEpoch(iArray));
    
    % Max. and Min. vals. for Error-Bars of Mean-Epochs per channel
    tmpMaxCorr = (max(corrVals + corrStd,[],2));                % max. values of error bars per channel
    if max(tmpMaxCorr) > maxError                               % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMax.errorCorrMeanEpoch(iArray)     = maxError;
    else yMax.errorCorrMeanEpoch(iArray)    = max(tmpMaxCorr);
    end
    tmpMaxIncorr = (max(incorrVals + incorrStd,[],2));          % max. values of error bars per channel
    if max(tmpMaxIncorr) > maxError                             % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMax.errorIncorrMeanEpoch(iArray)   = maxError;
    else yMax.errorIncorrMeanEpoch(iArray)  = max(tmpMaxIncorr);
    end
    yMax.errorBothMeanEpoch(iArray)         = max(yMax.errorCorrMeanEpoch(iArray),yMax.errorIncorrMeanEpoch(iArray));
    tmpMinCorr = (min(corrVals - corrStd,[],2));                % min. values of error bars per channel
    if min(tmpMinCorr) < -maxError                              % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMin.errorCorrMeanEpoch(iArray)     = -maxError;
    else yMin.errorCorrMeanEpoch(iArray)    = min(tmpMinCorr);
    end
    tmpMinIncorr = (min(incorrVals - incorrStd,[],2));          % min. values of error bars per channel
    if min(tmpMinIncorr) < -maxError                            % STD values way too big for PFC array, make other channels too small, add a fixed boundary
        yMin.errorIncorrMeanEpoch(iArray)   = -maxError;
    else yMin.errorIncorrMeanEpoch(iArray)  = min(tmpMinIncorr);
    end
    yMin.errorBothMeanEpoch(iArray)         = min(yMin.errorCorrMeanEpoch(iArray),yMin.errorIncorrMeanEpoch(iArray));
    
    %% Max. and Min. per array (for plotMeanErrRPs)
    %max. vals
    if max(corrArrayMean(iArray,:))> maxError         % If values are bigger than maxError, replace it by fixed value.
        yMax.meanPerArrayCorr(iArray)    = maxError;
    else yMax.meanPerArrayCorr(iArray)   = max(corrArrayMean(iArray,:));
    end
    if max(corrArrayMean(iArray,:) + corrArrayStd(iArray,:)) > maxError         % If values are bigger than maxError, replace it by fixed value.
        yMax.errorPerArrayCorr(iArray)    = maxError;
    else yMax.errorPerArrayCorr(iArray)   = max(corrArrayMean(iArray,:) + corrArrayStd(iArray,:));
    end

    if max(incorrArrayMean(iArray,:))> maxError         % If values are bigger than maxError, replace it by fixed value.
        yMax.meanPerArrayIncorr(iArray)    = maxError;
    else yMax.meanPerArrayIncorr(iArray)   = max(incorrArrayMean(iArray,:));
    end
    if max(incorrArrayMean(iArray,:) + incorrArrayStd(iArray,:)) > maxError         % If values are bigger than maxError, replace it by fixed value.
        yMax.errorPerArrayIncorr(iArray)    = maxError;
    else yMax.errorPerArrayIncorr(iArray)   = max(incorrArrayMean(iArray,:) + incorrArrayStd(iArray,:));
    end
    yMax.maxPerArray = max(max(yMax.errorPerArrayCorr),max(yMax.errorPerArrayIncorr));
    
    %min. vals.
    if min(corrArrayMean(iArray,:)) < -maxError         % If values are bigger than maxError, replace it by fixed value.
        yMin.meanPerArrayCorr(iArray)    = -maxError;
    else yMin.meanPerArrayCorr(iArray)   = min(corrArrayMean(iArray,:));
    end
    if min(corrArrayMean(iArray,:) - corrArrayStd(iArray,:)) < -maxError         % If values are bigger than maxError, replace it by fixed value.
        yMin.errorPerArrayCorr(iArray)    = -maxError;
    else yMin.errorPerArrayCorr(iArray)   = min(corrArrayMean(iArray,:) - corrArrayStd(iArray,:));
    end

    if min(incorrArrayMean(iArray,:)) < -maxError         % If values are bigger than maxError, replace it by fixed value.
        yMin.meanPerArrayIncorr(iArray)    = -maxError;
    else yMin.meanPerArrayIncorr(iArray)   = min(incorrArrayMean(iArray,:));
    end
    if min(incorrArrayMean(iArray,:) - incorrArrayStd(iArray,:)) < -maxError         % If values are bigger than maxError, replace it by fixed value.
        yMin.errorPerArrayIncorr(iArray)    = -maxError;
    else yMin.errorPerArrayIncorr(iArray)   = min(incorrArrayMean(iArray,:) - incorrArrayStd(iArray,:));
    end
    yMin.minPerArray = min(min(yMin.errorPerArrayCorr),min(yMin.errorPerArrayIncorr));
end

%% Get Max. and Min. vals. for each targets (for plotTgtErrRPs)
%correct
[nChs,~,nDataPoints] = size(tgtErrRPs(1).corrEpochs);
corrMeanTgt = nan(nTgts,nChs,nDataPoints);                                          % epochs' mean
%incorrect
[nChs,~,nDataPoints] = size(tgtErrRPs(1).incorrEpochs);
incorrMeanTgt = nan(nTgts,nChs,nDataPoints);
disp('For plotTgtErrRPs...')

%% For each target
[corrMeanTgt,incorrMeanTgt,corrStdTgt,incorrStdTgt,corrMeanTgtArray,incorrMeanTgtArray,corrStdTgtArray,incorrStdTgtArray] = ...
    getMeanTgtErrPs(tgtErrRPs,ErrorInfo);

%% Distance-to-targets plots (for plotTgtDistanceEpochs)
[incorrMeanDist2Tgt,incorrStdDist2Tgt,incorrMeanDist2TgtArray,incorrStdDist2TgtArray,ErrorInfo] = ...
    getMeanDist2TgtErrPs(tgt2DistEpochs,ErrorInfo);

for iTgt = 1:nTgts
    % Getting Mean values for correct and incorrect epochs for target iTgt
    corrMean    = squeeze(corrMeanTgt(iTgt,:,:));           % mean values for correct trials for this target
    incorrMean  = squeeze(incorrMeanTgt(iTgt,:,:));
    % Standard deviation per location
    stdCorr     = squeeze(corrStdTgt(iTgt,:,:));        	% standard deviation/error for correct trials for this target
    stdIncorr   = squeeze(incorrStdTgt(iTgt,:,:));          % standard deviation/error for incorrect trials for this target
    
    for iArray = 1:nArrays
        %% Mean values per ch and array
        corrVals        = corrMean(ErrorInfo.plotInfo.arrayChs(iArray,:),:);
        stdCorrVals     = stdCorr(ErrorInfo.plotInfo.arrayChs(iArray,:),:);
        incorrVals      = incorrMean(ErrorInfo.plotInfo.arrayChs(iArray,:),:);
        stdIncorrVals   = stdIncorr(ErrorInfo.plotInfo.arrayChs(iArray,:),:);
        
        % Get max. vals. per target. See pre-allocating memory section at
        % the beginning of code
        if max(max(corrVals + stdCorrVals,[],2)) > maxError;                % If values are bigger than maxError, replace it by fixed value.
            yMax.errorCorrTgt(iTgt,iArray)      = maxError;
        else yMax.errorCorrTgt(iTgt,iArray)     = max(max(corrVals + stdCorrVals,[],2));
        end
        if max(max(incorrVals + stdIncorrVals,[],2)) > maxError             % If values are bigger than maxError, replace it by fixed value.
            yMax.errorIncorrTgt(iTgt,iArray)    = maxError;
        else yMax.errorIncorrTgt(iTgt,iArray)   = max(max(incorrVals + stdIncorrVals,[],2));
        end
        % Max. Y limit for plot of errorbars per ch/per array/per target
        yMax.errorBothTgt(iTgt,iArray) = max(yMax.errorCorrTgt(iTgt,iArray),yMax.errorIncorrTgt(iTgt,iArray));
        % Get min. vals. per target
        if min(min(corrVals - stdCorrVals,[],2)) < -maxError;               % If values are smaller than -maxError, replace it by fixed value.
            yMin.errorCorrTgt(iTgt,iArray)      = -maxError;
        else yMin.errorCorrTgt(iTgt,iArray)     = min(min(corrVals - stdCorrVals,[],2));
        end
        if min(min(incorrVals - stdIncorrVals,[],2)) < -maxError            % If values are smaller than -maxError, replace it by fixed value.
            yMin.errorIncorrTgt(iTgt,iArray)    = -maxError;
        else yMin.errorIncorrTgt(iTgt,iArray)   = min(min(incorrVals - stdIncorrVals,[],2));
        end
        % Min. Y limit for plot of errorbars per ch/per array/per target
        yMin.errorBothTgt(iTgt,iArray) = min(yMin.errorCorrTgt(iTgt,iArray),yMin.errorIncorrTgt(iTgt,iArray));
        
        %% Values for averaged channels and trials per array error-bar plot
        % Getting max. values
        if max(corrMeanTgtArray(iArray,iTgt,:) + corrStdTgtArray(iArray,iTgt,:)) > maxError               % If values are bigger than maxError, replace it by fixed value.
            yMax.errorCorrArrayTgt(iTgt,iArray)     = maxError;
        else yMax.errorCorrArrayTgt(iTgt,iArray)    = max(corrMeanTgtArray(iArray,iTgt,:) + corrStdTgtArray(iArray,iTgt,:));
        end
        if max(incorrMeanTgtArray(iArray,iTgt,:) + incorrStdTgtArray(iArray,iTgt,:)) > maxError           % If values are bigger than maxError, replace it by fixed value.
            yMax.errorIncorrArrayTgt(iTgt,iArray)    = maxError;
        else yMax.errorIncorrArrayTgt(iTgt,iArray)  = max(incorrMeanTgtArray(iArray,iTgt,:) + incorrStdTgtArray(iArray,iTgt,:));
        end
        yMax.errorBothArrayTgt(iTgt,iArray) = max(yMax.errorCorrArrayTgt(iTgt,iArray),yMax.errorIncorrArrayTgt(iTgt,iArray));
        
        % Getting min. values for averaged-channels per array error-bar plot
        if min(corrMeanTgtArray(iArray,iTgt,:) - corrStdTgtArray(iArray,iTgt,:)) < -maxError
            yMin.errorCorrArrayTgt(iTgt,iArray)     = -maxError;
        else yMin.errorCorrArrayTgt(iTgt,iArray)    = min(corrMeanTgtArray(iArray,iTgt,:) - corrStdTgtArray(iArray,iTgt,:));
        end
        if min(incorrMeanTgtArray(iArray,iTgt,:) - incorrStdTgtArray(iArray,iTgt,:)) < -maxError
            yMin.errorIncorrArrayTgt(iTgt,iArray)   = -maxError;
        else yMin.errorIncorrArrayTgt(iTgt,iArray)  = min(incorrMeanTgtArray(iArray,iTgt,:) - incorrStdTgtArray(iArray,iTgt,:));
        end
        yMin.errorBothArrayTgt(iTgt,iArray) = min(yMin.errorCorrArrayTgt(iTgt,iArray),yMin.errorIncorrArrayTgt(iTgt,iArray));
        
        %% Limits to plot all targets in each channel and array (each target a different color)
        %Max.
        if max(max(corrVals)) > maxMean
            yMax.corrTgt(iTgt,iArray)   = maxMean;                  % If values are bigger than maxMean, replace it by fixed value.
        else yMax.corrTgt(iTgt,iArray)  = max(max(corrVals));
        end
        if max(max(incorrVals)) > maxMean
            yMax.incorrTgt(iTgt,iArray) = maxMean;                  % If values are bigger than maxMean, replace it by fixed value.
        else yMax.incorrTgt(iTgt,iArray)= max(max(incorrVals));
        end
        yMax.bothTgt(iTgt,iArray) = max(yMax.corrTgt(iTgt,iArray),yMax.incorrTgt(iTgt,iArray));
        %Min.
        if min(min(corrVals)) < -maxMean
            yMin.corrTgt(iTgt,iArray)   = -maxMean;                 % If values are smaller than -maxMean, replace it by fixed value.
        else yMin.corrTgt(iTgt,iArray)  = min(min(corrVals));
        end
        if min(min(incorrVals)) < -maxMean
            yMin.incorrTgt(iTgt,iArray) = -maxMean;                 % If values are smaller than -maxMean, replace it by fixed value.
        else yMin.incorrTgt(iTgt,iArray)= min(min(incorrVals));
        end
        yMin.bothTgt(iTgt,iArray) = min(yMin.corrTgt(iTgt,iArray),yMin.incorrTgt(iTgt,iArray));
    end

    %% Distance-to-targets plots (for plotTgtDistanceEpochs)

    for iArray = 1:nArrays                                                       	% For each array
        fprintf('Target%i-Array%i\n',iTgt,iArray)
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0                          % Only when there are incorrect trials for target 'iTgt'
            corrEpochTgt    = squeeze(corrMeanTgtArray(iArray,iTgt,:));    % Correct trials
            distVals        = tgt2DistEpochs(iTgt).dist2tgt;                        % List of distance of dcd target to true location
            
            % Max. and Min. vals for correct trials See pre-allocating memory
            % section at the beginning of code
            if max(max(corrEpochTgt)) > maxMean
                yMax.chCorrTgt(iTgt,iArray)     = maxMean;
            else yMax.chCorrTgt(iTgt,iArray)    = max(max(corrEpochTgt));
            end
            if min(min(corrEpochTgt)) < -maxMean
                yMin.chCorrTgt(iTgt,iArray)     = -maxMean;
            else yMin.chCorrTgt(iTgt,iArray)    = min(min(corrEpochTgt));
            end
            if max(nanmean(corrEpochTgt,1)) > maxMean
                yMax.meanCorrTgt(iTgt,iArray)   = maxMean;
            else yMax.meanCorrTgt(iTgt,iArray)  = max(nanmean(corrEpochTgt));
            end
            if min(nanmean(corrEpochTgt,1)) < -maxMean
                yMin.meanCorrTgt(iTgt,iArray)   = -maxMean;
            else yMin.meanCorrTgt(iTgt,iArray)  = min(nanmean(corrEpochTgt));
            end
            % Max. and Min. for incorrect trials. See pre-allocating memory
            % section at the beginning of code
            
            
            for iDist = 1:length(distVals)                                      % For each dist2tgt
                meanIncorrEpoch = squeeze(incorrMeanDist2Tgt(iDist,iTgt,:,:));        % mean trials per channel, for each array. 
                stdIncorrEpoch = squeeze(incorrStdDist2Tgt(iDist,iTgt,:,:));
                arraysMeanIncorrEpoch = squeeze(incorrMeanDist2TgtArray(iArray,iDist,iTgt,:));   % mean of channels and trials for each array 
                arraysStdIncorrEpoch = squeeze(incorrStdDist2TgtArray(iArray,iDist,iTgt,:));   % mean of channels and trials for each array 
                
                %% Dist2tgt per ch per array
                if max(max(meanIncorrEpoch+stdIncorrEpoch)) > maxMean
                    yMax.chDist2tgtLim(iTgt,iDist)   = maxMean;
                else yMax.chDist2tgtLim(iTgt,iDist)  = max(max(meanIncorrEpoch+stdIncorrEpoch));
                end
                if min(min(meanIncorrEpoch-stdIncorrEpoch)) < -maxMean
                    yMin.chDist2tgtLim(iTgt,iDist)   = -maxMean;
                else yMin.chDist2tgtLim(iTgt,iDist)  = min(min(meanIncorrEpoch-stdIncorrEpoch));
                end
                
                %% Mean of dist2tgt per array
                if max(nanmean(arraysMeanIncorrEpoch + arraysStdIncorrEpoch)) > maxMean
                    yMax.meanArrayDist2tgtLim(iTgt,iArray,iDist)   = maxMean;
                else yMax.meanArrayDist2tgtLim(iTgt,iArray,iDist)  = max(nanmean(arraysMeanIncorrEpoch + arraysStdIncorrEpoch));
                end
                if min(nanmean(arraysMeanIncorrEpoch - arraysStdIncorrEpoch)) < -maxMean
                    yMin.meanArrayDist2tgtLim(iTgt,iArray,iDist)   = -maxMean;
                else yMin.meanArrayDist2tgtLim(iTgt,iArray,iDist)  = min(nanmean(arraysMeanIncorrEpoch - arraysStdIncorrEpoch));
                end
            end
        else
            fprintf('No trials for target %i...\n',iTgt)
        end
        % Max. and Min. for all chs per array (1st plot plotTgtDistanceEpochs)
        yMax.bothChDist2tgt(iTgt,iArray) = max(yMax.chCorrTgt(iTgt,iArray),max(yMax.chDist2tgtLim(iTgt,iArray,:)));
        yMin.bothChDist2tgt(iTgt,iArray) = min(yMin.chCorrTgt(iTgt,iArray),min(yMin.chDist2tgtLim(iTgt,iArray,:)));
    end
    % All arrays and dist2tgt (2nd plot)
    yMax.bothMeanDist2tgt(iTgt) = max(nanmean(nanmean(yMax.errorCorrTgt(iTgt,:))),max(max(yMax.meanArrayDist2tgtLim(iTgt,:))));
    yMin.bothMeanDist2tgt(iTgt) = min(nanmean(nanmean(yMin.errorCorrTgt(iTgt,:))),min(min(yMin.meanArrayDist2tgtLim(iTgt,:))));
end

%% Mean of dist2tgt per target location (6Tgts-polar plot)
for iArray = 1:nArrays
    % All dist2tgt per array (3rd plot)
    yMax.bothArrayMeanDist2tgt(iArray) = max(max(yMax.errorCorrTgt(:,iArray)),max(yMax.meanDist2tgtLim(:,iArray)));
    yMin.bothArrayMeanDist2tgt(iArray) = min(min(yMin.errorCorrTgt(:,iArray)),min(yMin.meanDist2tgtLim(:,iArray)));
end

% Saving values in structure
ErrorInfo.plotInfo.equalLim.yMax = yMax;
ErrorInfo.plotInfo.equalLim.yMin = yMin;

% Time it took to run this code
tElapsed = toc(tStart);
fprintf('Time to get equal Y limits was %0.2f seconds\n',tElapsed);
