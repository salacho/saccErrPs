function [meanCorrSpec,meanIncorrSpec,meanDiffSpec,corrSpec,incorrSpec,diffSpec,tgtCorrSpec,tgtIncorrSpec,dist2tgtSpec,ErrorInfo] = getErrRPsSpecgram(meanCorr,meanIncorr,tgtMeanCorr,tgtMeanIncorr,dist2tgtMean,ErrorInfo)   
% function [meanCorrSpec,meanIncorrSpec,meanDiffSpec,corrSpec,incorrSpec,diffSpec,tgtCorrSpec,tgtIncorrSpec,dist2tgtSpec,ErrorInfo] = getErrRPsSpecgram(meanCorr,meanIncorr,tgtMeanCorr,tgtMeanIncorr,dist2tgtMean,ErrorInfo)   
%
% Get spectrogram of all error-related data, mean correct, incorrect, target 
% specific and for each distance of decoded target to true target location. 
% The multitaper method is used to calculate the spectrogram, the chronux 
% toolbox, mtspegramc is required. Data must be in the form [samples x channels/trials]
%
% INPUT
% meanCorr:             matrix. [numChannels lengthEpoch]. Average of correct trials
% meanIncorr:           matrix. [numChannels lengthEpoch]. Average of incorrect trials
% tgtMeanCorr:          matrix. [numTargets numChannels lengthEpoch]. Average of correct trials per target
% tgtMeanIncorr:        matrix. [numTargets numChannels lengthEpoch]. Average of incorrect trials per target
% dist2tgtMean:         matrix of structure with field meanIncorr. dist2tgtMean(numTargets,maxDist2tgt).meanIncorr 
%                       'maxDist2tgt' is the max. distance from incorrect decoded target to true target 
%                       location (since 6 targets, max. dist. is 3). The field 
%                       meanIncorr is the average of incorrect trials per target with 
%                       a given distance from decoded target to true target location 
% OUTPUT
% meanCorrSpec:         matrix. [numTimeBins x numFreqBins x numArrays]. Spectrogram of averaged correct trials, averaged of all channels (per array)
% meanIncorrSpec:       matrix. [numTimeBins x numFreqBins x numArrays]. Spectrogram of averaged incorrect trials, averaged of all channels (per array)
% meanDiffSpec:         matrix. [numTimeBins x numFreqBins x numArrays]. Spectrogram of difference of incorrect - correct averaged trials, averaged of all channels (per array) 
% corrSpec:             matrix. [numTimeBins x numFreqBins x numChannels]. Spectrogram of averaged correct trials
% incorrSpec:           matrix. [numTimeBins x numFreqBins x numChannels]. Spectrogram of averaged incorrect trials
% diffSpec:             matrix. [numTimeBins x numFreqBins x numChannels]. Spectrogram of difference of incorrect - correct averaged trials
% tgtCorrSpec:          matrix. [numTimeBins x numFreqBins x numChannels x numTargets]. 
%                       Spectrogram of averaged correct trials per target location
% tgtIncorrSpec:        matrix. [numTimeBins x numFreqBins x numChannels x numTargets]. 
%                       Spectrogram of averaged correct trials per target location
% dist2tgtSpec:         matrix of structure with field 'spec'. dist2tgtMean(numTargets,maxDist2tgt).spec 
%                       'maxDist2tgt' is the max. distance from incorrect decoded target to true target 
%                       location (since 6 targets, max. dist. is 3). The field 
%                       'spec' is the spectrogram of the averaged incorrect trials per target with 
%                       a given distance from decoded target to true target location 
% ErrorInfo:            Info structure. The files 'fSpec' and tSpec are
%                       added to the nested structure 'specParams'. fSpec has the list of frequency 
%                       values after the spectrogram is calculated, tSpec has the list of sample/time values
% Andres V.1.0
% Created 18 July 2013
% Last modified 22 July 2013

maxDist2tgt = 3;                                    % Max. distance of a decoded target to a true one (with 6 targets choice)

% Main spectrogram params
SpecInfo    = ErrorInfo.specgram;                   % specgram info structure
nChs        = ErrorInfo.epochInfo.nChs;             % number of channels
lenEpoch    = ErrorInfo.epochInfo.lenEpoch;         % length of epoch/trial
nTgts       = ErrorInfo.epochInfo.nTgts;            % Total number of targets
% Checking dimensionality and orientation matches the one required to get specgram
meanCorr    = dimCheck(meanCorr,lenEpoch,nChs);
meanIncorr  = dimCheck(meanIncorr,lenEpoch,nChs);
meanDiff    = meanIncorr - meanCorr;                % Difference between mean correct and error trials

disp(['Channels',num2str(nChs)])

%% Calculating the spectrogram
% First channel to pre-allocate memory
[firstSpec,ErrorInfo.specgram.tSpec,ErrorInfo.specgram.fSpec] = ...
    mtspecgramc(meanCorr(:,1),SpecInfo.movingWin,SpecInfo.params);

% Changing time axis values to match epoch origin
ErrorInfo.specgram.tSpec = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,length(ErrorInfo.specgram.tSpec));

% Pre-allocating memory for mean values of all channels of an array
meanCorrSpec    = nan(size(firstSpec,1),size(firstSpec,2),length(ErrorInfo.plotInfo.arrayLoc));    	% mean correct trials specgram
meanIncorrSpec  = nan(size(firstSpec,1),size(firstSpec,2),length(ErrorInfo.plotInfo.arrayLoc));    	% mean correct trials specgram
meanDiffSpec    = nan(size(firstSpec,1),size(firstSpec,2),length(ErrorInfo.plotInfo.arrayLoc));    	% mean correct trials specgram
corrSpec        = nan(size(firstSpec,1),size(firstSpec,2),nChs);    	% mean correct trials specgram
incorrSpec      = nan(size(firstSpec,1),size(firstSpec,2),nChs);            % mean incorrect trials specgram
diffSpec    = nan(size(firstSpec,1),size(firstSpec,2),nChs);            % difference of mean incorrect and correct trials specgram
tgtCorrSpec     = nan(size(firstSpec,1),size(firstSpec,2),nChs,nTgts);      % mean correct trials specgram per target
tgtIncorrSpec   = nan(size(firstSpec,1),size(firstSpec,2),nChs,nTgts);      % mean incorrect trials specgram
dist2tgtSpec    = repmat(struct('spec',[]),nTgts,maxDist2tgt);              % spectrogram for each distance of decoded target to true target location

% Get specgram
[corrSpec,~,~]      = mtspecgramc(meanCorr,SpecInfo.movingWin,SpecInfo.params);
[incorrSpec,~,~]    = mtspecgramc(meanIncorr,SpecInfo.movingWin,SpecInfo.params);
[diffSpec,~,~]      = mtspecgramc(meanDiff,SpecInfo.movingWin,SpecInfo.params);

% Spectrogram from mean trace from all channels of an array
for ii = 1:length(ErrorInfo.plotInfo.arrayLoc)
    [meanCorrSpec(:,:,ii),tSpec,fSpec]   = mtspecgramc(mean(meanCorr(:,1+32*(ii-1):ii*32),2),SpecInfo.movingWin,SpecInfo.params);
    [meanIncorrSpec(:,:,ii),tSpec,fSpec] = mtspecgramc(mean(meanIncorr(:,1+32*(ii-1):ii*32),2),SpecInfo.movingWin,SpecInfo.params);
    [meanDiffSpec(:,:,ii),tSpec,fSpec]   = mtspecgramc(mean(meanIncorr(:,1+32*(ii-1):ii*32),2)-mean(meanCorr(:,1+32*(ii-1):ii*32),2),SpecInfo.movingWin,SpecInfo.params);
end

% Running each target and each channel
for iTgt = 1:nTgts 
    fprintf('Calculating spectrogram for target %i...\n',iTgt)
    % Correct orientation of data/ per target 
    corrTgtMean   = dimCheck(squeeze(tgtMeanCorr(iTgt,:,:)),lenEpoch,nChs);       % Checking dim(1)= samples, dim(2) = channels/trials
    incorrTgtMean = dimCheck(squeeze(tgtMeanIncorr(iTgt,:,:)),lenEpoch,nChs);     % Checking dim(1)= samples, dim(2) = channels/trials
    % Specgram for correct and error data/per target
    [tgtCorrSpec,~,~]   = mtspecgramc(corrTgtMean,SpecInfo.movingWin,SpecInfo.params);
    [tgtIncorrSpec,~,~] = mtspecgramc(incorrTgtMean,SpecInfo.movingWin,SpecInfo.params);
    % For dist2tgt/per target
    for iDist = 1:maxDist2tgt
        if ~isempty(dist2tgtMean(iTgt,iDist).meanIncorr)
            % Checking dim(1) = samples, dim(2) = channels/trials 
            dist2TgtMean = dimCheck(dist2tgtMean(iTgt,iDist).meanIncorr,lenEpoch,nChs);
            % Spectrogram for each dist2tgt
            [dist2tgtSpec(iTgt,iDist).spec,dist2tgtSpec(iTgt,iDist).tSpec,dist2tgtSpec(iTgt,iDist).fSpec] = ...
                mtspecgramc(dist2TgtMean,SpecInfo.movingWin,SpecInfo.params);       
        end
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script to check orientation of data %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function transData = dimCheck(dataVals,lenEpoch,nChs)
% function transData = dimCheck(dataVals,lenEpoch,nChs)
% 
% Tiny script to check if orientation of files matches the one required by
% mtspegramc. Data must be in the form [samples x channels/trials]
%
% INPUT
% dataVals:     matrix. [samples channel/trials] or [channel/trials x samples]. 
%               Usually channels, not trials.
% lenEpoch:     integer. Number of samples
% nChs:         integer. Number of channels or trials
%
% OUTPUT
% transData:    matrix. [samples channel/trials]. Data oriented as required
%               by mtspecgramc
%
% Andres V.1.1
% Last modified 22 July 2013

dataDim = size(dataVals);

if (dataDim(1) == nChs) && (dataDim(2) == lenEpoch)       % if second dim equal samples, must
    transData = dataVals';
elseif (dataDim(2) == nChs) && (dataDim(1) == lenEpoch)   % data has same dimension and orientation
    transData = dataVals;
else
    error('Data dimensionality does not match the trial length (%i) and number of channels/trials (%i)\n',lenEpoch,nChs)
end

end