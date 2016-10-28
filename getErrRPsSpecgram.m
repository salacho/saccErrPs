function [corrSpec,incorrSpec,ErrorInfo] = getErrRPsSpecgram(ErrorInfo,corrEpochs,incorrEpochs) 
%
% function [corrSpec,incorrSpec,ErrorInfo] = getErrRPsSpecgram(ErrorInfo,corrEpochs,incorrEpochs) 
%
% Get spectrogram of all error-related data, mean correct, incorrect, target 
% specific and for each distance of decoded target to true target location. 
% The multitaper method is used to calculate the spectrogram, the chronux 
% toolbox, mtspegramc is required. Data must be in the form [samples x channels/trials]
%
% INPUT
% corrEpochs:           matrix. [numChannels lengthEpoch]. Average of correct trials
% incorrEpochs:         matrix. [numChannels lengthEpoch]. Average of incorrect trials
%
% OUTPUT
% corrSpec:             matrix. [numTimeBins x numFreqBins x numChannels]. Spectrogram of averaged correct trials
% incorrSpec:           matrix. [numTimeBins x numFreqBins x numChannels]. Spectrogram of averaged incorrect trials
% ErrorInfo:            Info structure. The files 'fSpec' and tSpec are
%                       added to the nested structure 'specParams'. fSpec has the list of frequency 
%                       values after the spectrogram is calculated, tSpec has the list of sample/time values
%
% Author    :  Andres V.1.0
%
% Andres    : v1    : init. Created 18 July 2013
% Andres    : v1.1  : 22 July 2013
% Andres    : v2.0  : changed code to match new params structure. Get specgram only for corr 
%                     and incorr Epochs. Tgt and dist2tgt done later based on these data. 03 Dec 2014

%% Params
ErrorInfo.specParams.params.Fs = ErrorInfo.epochInfo.Fs;       % To be sure Fs was properly updated!!

% Everything is SpecInfo from now on...
SpecInfo    = ErrorInfo.specParams;                     % specgram info structure
nChs        = ErrorInfo.epochInfo.nChs;                 % Total number of channels
numSamps    = ErrorInfo.epochInfo.numSamps;             % Total number of samples!
nCorr       = ErrorInfo.epochInfo.nCorr;                % Total number correct trials
nIncorr     = ErrorInfo.epochInfo.nError;               % Total number incorrect trials

%% For corr and incorr epochs
if (nargin == 3)                                        %(ndims(corrEpochs) == 3) && (ndims(incorrEpochs) == 3)
%     TEST DATA: to check proper analysis and resolution
%     timeVector = linspace(-0.6,0.8,numSamps);
%     dummyEpochs = repmat(reshape(2*sin(2*pi*60*timeVector) + 2*sin(2*pi*45*timeVector),[1 1 length(timeVector)]),[nChs,nCorr,1]);
%     data2analyze = squeeze(dummyEpochs(1,:,:))';
%     freqRange = SpecInfo.params.fpass(2) - SpecInfo.params.fpass(1)
%     nTimeVals = (numSamps - SpecInfo.movingWin(1)*SpecInfo.params.Fs)/(SpecInfo.movingWin(2)*SpecInfo.params.Fs) + 1;
%     % nFreqVals = (SpecInfo.params.Fs/2)/(SpecInfo.movingWin(2)*SpecInfo.params.Fs) + 1;

    
    data2analyze =  squeeze(corrEpochs(1,:,:))';
    
    % Calculating the spectrogram for first channel to pre-allocate memory
    % The data has to be in the form [samples x channels/trials]
%     [peo,SpecInfo.tSpec,SpecInfo.fSpec] = mtspecgramc(data2analyze,SpecInfo.movingWin,SpecInfo.params);        
    [~,SpecInfo.tSpec,SpecInfo.fSpec] = mtspecgramc(data2analyze,SpecInfo.movingWin,SpecInfo.params);        
    clear firstSpec
    % Size of variables
    nTime = length(SpecInfo.tSpec);
    nFreq = length(SpecInfo.fSpec);
    % Preallocate memory
    corrSpec = nan(nTime,nFreq,nCorr,nChs);
    incorrSpec = nan(nTime,nFreq,nIncorr,nChs);
    
    % Calculate for all channels
    for iCh = 1:nChs,
        fprintf('Calculating spectrogram for corrEpochs and incorrEpochs ch %i...\n',iCh)
        % Corr
        [corrSpec(:,:,:,iCh),SpecInfo.tSpec,SpecInfo.fSpec] = ...
            mtspecgramc(squeeze(corrEpochs(iCh,:,:))',SpecInfo.movingWin,SpecInfo.params);        % data has to be in the form [samples x channels/trials]
        % incorr
        [incorrSpec(:,:,:,iCh),SpecInfo.tSpec,SpecInfo.fSpec] = ...
            mtspecgramc(squeeze(incorrEpochs(iCh,:,:))',SpecInfo.movingWin,SpecInfo.params);        % data has to be in the form [samples x channels/trials]
    end
else
    error('The number of input variables is not correct!!')
end

SpecInfo.freqPerTick = (SpecInfo.fSpec(end) - SpecInfo.fSpec(1))/nFreq;
SpecInfo.secsPerTick = numSamps/SpecInfo.params.Fs/nTime;

% Update specParams
ErrorInfo.specParams = SpecInfo; 

end     % EOF
