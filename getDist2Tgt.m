function [dist1Epochs,dist2Epochs,dist3Epochs,distDcdTgt] = getDist2Tgt(tgt2DistEpochs,ErrorInfo) %#ok<INUSL>
%
% Combines dist2Tgt trials from all targets so dist2Tgt is what only matters. 
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
% dist1Epochs:              matrix. [numChannels x numTrials x numSamples].
%                           All incorrect trials for this session decoded 1 target away from true target
% dist2Epochs:              matrix. [numChannels x numTrials x numSamples].
%                           All incorrect trials for this session decoded 2 targets away from true target
% dist3Epochs:              matrix. [numChannels x numTrials x numSamples].
%                           All incorrect trials for this session decoded 3 targets away from true target
% distDcdTgt:               structure. Has the fields dcdTgt and expTgt, vectors with the expected (true) and decoded 
%                           target location for all three dist2Tgt vals
% Author    : Andres
% 
% Andres    : init.     : 11 Nov 2014
%

disp('Grouping all dist2Tgt regarless of the true target location!!...')

dist1Epochs = [];
dist2Epochs = [];
dist3Epochs = [];
distDcdTgt = repmat(struct(...
    'dcdTgt',[],...
    'expTgt',[]),...
    [3 1]);

for iTgt = 1:ErrorInfo.epochInfo.nTgts
    % Kludge!! From previous versions. Fix dimensionality so it is always 3
    % or empty array
    for iDist = 1:3
        eval(sprintf('tgt2DistEpochs(iTgt).epochDist%i = fixEpochs3dims(tgt2DistEpochs(iTgt).epochDist%i);',iDist,iDist));
        % Aggregate trials
        eval(sprintf('dist%iEpochs = [dist%iEpochs tgt2DistEpochs(iTgt).epochDist%i];',iDist,iDist,iDist));
        % Save the decoded target
        eval(sprintf('distDcdTgt(%i).dcdTgt = [distDcdTgt(%i).dcdTgt tgt2DistEpochs(iTgt).dcdTgtDist%i];',iDist,iDist,iDist));
        % Save the true target
        eval(sprintf('distDcdTgt(%i).expTgt = [distDcdTgt(%i).expTgt repmat(iTgt,[1 tgt2DistEpochs(iTgt).numEpochsPerDist(%i)])];',iDist,iDist,iDist));
    end
end

