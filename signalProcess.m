function [dataCorr,dataIncorr,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo)
% function [dataCorr,dataIncorr,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo)
%
% Signal processing of correct and incorrect trials. Includes removing
% baseline, detrending, and others
%
% INPUT
% corrEpochs:       matrix. All the correct epochs. [numChannels numEpochs numDatapoints].
% incorrEpochs:     matrix. All the incorrect epochs. [numChannels numEpochs numDatapoints].
% ErrorInfo:      structure. Has all the info for signal processing.
%
% OUTPUT
% dataCorr:       matrix. All the correct epochs post processing. [numSigChannels numEpochs numDatapoints].
% dataIncorr:     matrix. All the incorrect epochs post processing. [numSigChannels numEpochs numDatapoints].
% ErrorInfo:      structure. Updated structure that has all the info for signal processing.
%
% With 'numSigChannels' as the correct/good channels
%
% Author    : Andres
%
% andres    : 1.1   : initial


%% Main processing parameters
Fs              = ErrorInfo.epochInfo.Fs;                       % Sampling frequency
dcdWindow       = ErrorInfo.signalProcess.dcdWindow/1000;       % Boundaries (changed from seconds to ms) for data window used for decoding (with respect to feedback onset)
epochLen        = ErrorInfo.signalProcess.epochLen/1000;        % from ms to seconds. Length of data used for decoding
baselineTime    = ErrorInfo.signalProcess.baselineLen/1000;     % Data length to take baseline from (in ms)
preStimTime     = ErrorInfo.epochInfo.preOutcomeTime/1000;      % Data length before stimulus presentation
nChs            = ErrorInfo.epochInfo.nChs;                     % number of channels
rmvBaseline     = ErrorInfo.epochInfo.rmvBaseline;              % Flag setting if baseline is removed
rmvBaseDone     = ErrorInfo.epochInfo.rmvBaseDone;              % Flag used when baseline has been removed
arrays          = ErrorInfo.signalProcess.arrays;               % arrays used for analysis
arrayChs        = ErrorInfo.BCIparams.arrayChs;                % designated channels for each array

%% Choosing channels from arrays
sgnChs  = [];                                           % List of all the chosen channels
for ii = 1:length(arrays)
    fprintf('Taking channels from array %s...\n',arrays{ii})
    switch lower(arrays{ii})
    case lower('PFC')
        sgnChs  = [sgnChs ,arrayChs(1:32)]; %#ok<*AGROW>
    case lower('SEF')
        sgnChs  = [sgnChs ,arrayChs(33:64)];
    case lower('FEF')
        sgnChs  = [sgnChs ,arrayChs(65:96)];
    end
end

% ============================
% Remove noisy channels here 
% ============================
% List of all the good channels
nChs = length(sgnChs);
fprintf('A total of %i good channels...\n',nChs)

%% Signal processing

if ErrorInfo.signalProcess.getDcdWindow
    % Getting designated window of data
    dataCorr = corrEpochs(sgnChs,:,(preStimTime + dcdWindow(1))*Fs+1:(preStimTime + dcdWindow(2))*Fs);         % decoder window of correct data trials
    dataIncorr = incorrEpochs(sgnChs,:,(preStimTime + dcdWindow(1))*Fs+1:(preStimTime + dcdWindow(2))*Fs);     % decoder window of incorrect data trials
    
    if isfield(ErrorInfo.featSelect,'predWindows') && (~isempty(ErrorInfo.featSelect.predWindows))         % as safeguard for predFunction = 'none'
        % Shifting the data window to match decoder analysis windows
        if ErrorInfo.featSelect.predWindows(end,end) <= ErrorInfo.signalProcess.dcdWindow(2)
            ErrorInfo.featSelect.predWindows = ErrorInfo.featSelect.predWindows - ErrorInfo.signalProcess.dcdWindow(1);
            if ErrorInfo.featSelect.predWindows(1,1) == 0, ErrorInfo.featSelect.predWindows(1,1) = 1; end
        else
            warning('Analysis window %i-%i is smaller than decoder analysis predWindow %i',ErrorInfo.signalProcess.dcdWindow,ErrorInfo.featSelect.predWindows(end,end)) %#ok<*WNTAG>
        end
    end
end
    
% Removing baseline in the sgnChs (the good channels)
if rmvBaseline && (~rmvBaseDone) 
    warning('Removing %i ms baseline mean value before feedback onset...\n',1000*baselineTime)
    % Select data window for decoding
    dataCorr    = dataCorr - repmat(mean(corrEpochs(sgnChs,:,round((preStimTime-baselineTime)*Fs):preStimTime*Fs-1),3),[1,1,round(epochLen*Fs)]);
    dataIncorr  = dataIncorr - repmat(mean(incorrEpochs(sgnChs,:,round((preStimTime-baselineTime)*Fs):preStimTime*Fs-1),3),[1,1,round(epochLen*Fs)]);
    rmvBaseDone = true;
end

% Update the structure vbles
ErrorInfo.signalProcess.baselineDone = rmvBaseDone;
ErrorInfo.epochInfo.rmvBaseDone = rmvBaseDone; 
if size(dataCorr,3) == size(dataIncorr,3)
    ErrorInfo.epochInfo.epochLen    =  size(dataCorr,3);        % trial length in ms
else
    warning('Error: ''corrEpochs'' and ''incorrEpochs'' should have the same trial  length!!')
end
% Updating list of channels
ErrorInfo.nChs = nChs;
ErrorInfo.epochInfo.nChs = nChs;
ErrorInfo.epochInfo.chList = sgnChs;
ErrorInfo.chList = sgnChs;

% ============================
% Add option for Downsampling
% ============================

% ============================
% Remove noisy trials here
% ============================
%ErrorInfo.epochInfo.nCorr = ;
%ErrorInfo.epochInfo.nError = ;
% Adding number of trials to structure
fprintf('Total of %i/%i correct/incorrect artifact free trials...\n',ErrorInfo.epochInfo.nCorr,ErrorInfo.epochInfo.nError)

