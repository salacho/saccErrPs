function [outputMatrix1,outputMatrix2,ErrorInfo] = downSampEpochs(inputMatrix1,inputMatrix2,ErrorInfo)
%
% Downsampling files with 3 dims in the form [nChs x nTrials x nSamples]
% Decreases the sampling rate of inputMatrix in the nSamp dimension. 
% First the dimensions of the inputMatrix are fix then downsampled at the 
% nSamp dimension by keeping every nth sample starting with the first sample. 
% 
%
% inputMatrix1:     matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the original sampling frequency
% inputMatrix2:      matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the original sampling frequency
% ErrorInfo:        structure. In the field signalProcess two elements are required: 
%                   1) downSamp -> logical to assess if downsampling is performed or not. 
%                   2) downSampFactor -> factor by which samples will be downsampled. 
%
% OUTPUT
% outputMatrix1:     matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the downsampled frequency given by the ratio of  
%                   downsampling factor ErrorInfo.signalProcess.downSampFactor. 
% outputMatrix2:     matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the downsampled frequency given by the ratio of  
%                   downsampling factor ErrorInfo.signalProcess.downSampFactor. 
%
%       New sampling frequency: 
%               newFs = ErrorInfo.epochInfo.Fs/ErrorInfo.signalProcess.downSampFactor; 
%
% ErrorInfo:        The sampling frequency in ErrorInfo.epochInfo.Fs is
%                   changed to match the downsampling process.
%
% Author    :   Andres
%
% Andres    : v1.0  : init. 13 Nov 2014

outputMatrix1 = downsampEpochsNoFs(inputMatrix1,ErrorInfo);
outputMatrix2 = downsampEpochsNoFs(inputMatrix2,ErrorInfo);

% Updating sampling frequency
ErrorInfo.epochInfo.Fs = ErrorInfo.epochInfo.Fs/ErrorInfo.signalProcess.downSampFactor;
ErrorInfo.epochInfo.epochLen = ErrorInfo.epochInfo.epochLen/ErrorInfo.signalProcess.downSampFactor;
ErrorInfo.specParams.params.Fs = ErrorInfo.epochInfo.Fs;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Subfunction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outputMatrix = downsampEpochsNoFs(inputMatrix,ErrorInfo)
% Downsampling files with 3 dims in the form [nChs x nTrials x nSamples]
% Decreases the sampling rate of inputMatrix in the nSamp dimension. 
% First the dimensions of the inputMatrix are fix then downsampled at the 
% nSamp dimension by keeping every nth sample starting with the first sample. 
% 
%
% inputMatrix:     matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the original sampling frequency
% ErrorInfo:        structure. In the field signalProcess two elements are required: 
%                   1) downSamp -> logical to assess if downsampling is performed or not. 
%                   2) downSampFactor -> factor by which samples will be downsampled. 
%
% OUTPUT
% outputMatrix:     matrix. In the form [nChs x nTrials x nSamples]. Data
%                   at the downsampled frequency given by the ratio of  
%                   downsampling factor ErrorInfo.signalProcess.downSampFactor. 
%
%       New sampling frequency: 
%               newFs = ErrorInfo.epochInfo.Fs/ErrorInfo.signalProcess.downSampFactor; 
%
% ErrorInfo:        The sampling frequency in ErrorInfo.epochInfo.Fs is
%                   changed to match the downsampling process.
% Author    :   Andres
%
% Andres    : v1.0  : init. 13 Nov 2014


%% Fixes dimensionality to get a [nChs x nTrials x nSamples]
if ~isempty(inputMatrix)                    % if empty do nothing let other code handle it!!
    matrixSz = size(inputMatrix);
    matrixDims = ndims(inputMatrix);
    if matrixDims == 2
        % Has two dimensions but is not empty. Fix
        reshapeMatrix = reshape(inputMatrix,[matrixSz(1),1,matrixSz(2)]); 
        disp('Two dims...adding the one in the middle!!')
    else
        reshapeMatrix = inputMatrix;         % already a 3 dims file
        disp('Already 3 dims...doing nothing')
    end
else
    reshapeMatrix = inputMatrix;             % leave the way it is, other code will handle it
    disp('Empty matrix, no dims...doing nothing')
end

%% Downsample
[nChs,nTrials,nSamp] = size(reshapeMatrix);
% Downsampling factor
Nth = ErrorInfo.signalProcess.downSampFactor;
% Preallocating memory
outputMatrix = nan(nChs,nTrials,length(downsample(squeeze(reshapeMatrix(1,1,:)),Nth)));

if ErrorInfo.signalProcess.downSamp
    % Downsampling epochs
    for iCh = 1:nChs
        fprintf('Downsampling channel %i by a factor of %i...\n',iCh,Nth)
        %  Each column is considered a separate sequence.
        data2Downsamp = squeeze(reshapeMatrix(iCh,:,:))';        % if several trials [nTrials nSamps], if only 1 trial [nSamp x 1];
        outputMatrix(iCh,:,:) = downsample(data2Downsamp,Nth)';                       % each column is considered a separate sequence.
    end
end
end
