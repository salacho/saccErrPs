function [tgt2DistEpochs] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo)
%
% Separates error epochs by the distance to the real (expected) target
% using the values given in 'dist2tgt'. The vble 'dist2tgt' has the
% distance of the column target to the true target lcation (in this case
% target 1). Using circular shifting this location can be used for all 6
% targets.
%
% INPUT
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
%
% OUTPUT
% tgt2DistEpochs:           structure from 1:numTargets.For each target it
%                           has the following fields:
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
% Andres v1.0
% Created May 2013
% Last modified 12 July 2013

% Targets and distance to true locations
nTgts = ErrorInfo.epochInfo.nTgts;  % total number of values
dist2tgt = [0 1 2 3 2 1];           % distance of decoded target to true target location (for Tgt 1) in the ith column of dist2tgt.

% Create structure to store epochs based on distance to true target location (iTgt)
tgt2DistEpochs = repmat(struct(...
    'dist2tgt',[],...       % all possible distances of incorrect targets to true location    
    'dcdTgtRange',[],...        % possible values taken by dcd target for this true target location (iTgt)
    'numEpochsPerDist',[],...   % number of epochs for each distance to true location
    'dcdTgtDist1',[],...        % decoded targets for the error epochs with distance 1 to the target location
    'epochDist1',[],...         % error epochs with error at a distance 1 to the target location
    'meanEpochDist1',[],...     % mean error epoch for distance 1 to target location
    'stdEpochDist1',[],...      % std of error epochs for distance 1 to target location
    'dcdTgtDist2',[],...        % decoded targets for the error epochs with distance 2 to the target location
    'epochDist2',[],...         % error epochs with error at a distance 2 to the target location
    'meanEpochDist2',[],...     % mean error epoch for distance 2 to target location
    'stdEpochDist2',[],...      % std of error epochs for distance 2 to target location
    'dcdTgtDist3',[],...        % decoded targets for the error epochs with distance 3 to the target location
    'epochDist3',[],...         % error epochs with error at a distance 3 to the target location
    'meanEpochDist3',[],...    % mean error epoch for distance 3 to target location
    'stdEpochDist3',[]),...      % std of error epochs for distance 3 to target location
    [1 nTgts]);

% Analysis per target
for iTgt  = 1:nTgts
    % Incorrect epochs, each target
    incorrDcdTgt = tgtErrRPs(iTgt).incorrDcdTgt;        % decoded target for this target location
    iTgtDist2tgt = circshift(dist2tgt,[0 iTgt-1]);      % distance to expected target for ith location
    tmpDist = iTgtDist2tgt(incorrDcdTgt);
    distVals = unique(tmpDist);
    %   dist2expTgt{iTgt} = tmpDist;                    % distance to expected target for all locations
    iTgtEpochs = tgtErrRPs(iTgt).incorrEpochs;          % incorrect epochs for ith target
    % dcd targets for all locations
    iTgtDcdTgts = unique(incorrDcdTgt)';                % possible other target values the decoder took for this target location
    
    tgt2DistEpochs(iTgt).dist2tgt = distVals;           % all possible distances of incorrect targets to true location
    tgt2DistEpochs(iTgt).dcdTgtRange = iTgtDcdTgts;     % possible values taken by dcd target for this true target location (iTgt)
    tgt2DistEpochs(iTgt).numEpochsPerDist = [];         % number of epochs for each distance to true location
   
   % Organize error epochs based on dcd target distance to target location (given by 'iTgtDist2tgt')
   for ii = 1:length(distVals)
       % Index for ii distance to target location
       iDist2tgt = find(tmpDist == distVals(ii));       % epochs with decoded tgts at a 'distVals(ii)' distance from real target location
       iDcdTgt = incorrDcdTgt(iDist2tgt)';              % dcdTgts for this distance to true target location
       % Total number of epochs per distance to true target location  
       tgt2DistEpochs(iTgt).numEpochsPerDist(1,ii) = length(iDcdTgt);               % total number of epochs for this distance to true target location
       % Error epochs
       iDistTxt = sprintf('epochDist%i',distVals(ii));  % name of field with distance ii
       tgt2DistEpochs(iTgt).(iDistTxt) = squeeze(iTgtEpochs(:,iDist2tgt,:));        % storing epochs in structure
       % Name of Mean epochs
       iMeanDistTxt = sprintf('meanEpochDist%i',distVals(ii));                      % name of mean
       % Name of Standard deviation epochs
       stdDistTxt = sprintf('stdEpochDist%i',distVals(ii));
       % when there are more than 1 trials (so mean can be taken) 
       numDims = ndims(tgt2DistEpochs(iTgt).(iDistTxt));
       if  numDims == 3                               
           tgt2DistEpochs(iTgt).(iMeanDistTxt) = squeeze(mean(tgt2DistEpochs(iTgt).(iDistTxt),2));      % mean error epoch for this distance to target location
           tgt2DistEpochs(iTgt).(stdDistTxt) = squeeze(std(tgt2DistEpochs(iTgt).(iDistTxt),0,2));       % std of error epoch for this distance to target location
       elseif numDims == 2                                                                              % if only one trial, this is the mean
           tgt2DistEpochs(iTgt).(iMeanDistTxt) = tgt2DistEpochs(iTgt).(iDistTxt);                       % mean epoch for one epoch at 'ii' distance to target location
           tgt2DistEpochs(iTgt).(stdDistTxt) = zeros(ErrorInfo.epochInfo.nChs,ErrorInfo.epochInfo.epochLen);    % std of one trial is zero at 'ii' distance to target location
       else
           warning('Number of dimensions is not 2 or 3!') %#ok<WNTAG>
       end
       % Dcd targets
       iDcdTgtTxt = sprintf('dcdTgtDist%i',distVals(ii));                           % name of std
       tgt2DistEpochs(iTgt).(iDcdTgtTxt) = iDcdTgt;                                 % storing dcd targets in structure
   end
end

