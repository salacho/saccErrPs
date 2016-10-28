function [corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials,corrArrayMean,incorrArrayMean,corrArrayStd,incorrArrayStd] = ...
    getMeanTrialsErrPs(corrEpochs,incorrEpochs,ErrorInfo)
% function [corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials] = getMeanTrialsErrPs(corrEpochs,incorrEpochs,ErrorInfo)
%
% Get mean values for correct and error trials. 
%
% INPUT
% corrEpochs:           matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:         matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% ErrorInfo:            ErrRps info structure. The structure 'epochInfo' has 
%                       nChs, nTgts, epochLen.
%
% OUTPUT
% corrMeanTrials:             matrix. [numChannels lengthEpoch]. Average of correct trials
% incorrMeanTrials:           matrix. [numChannels lengthEpoch]. Average of incorrect trials
%
% Author:   Andres 
%
% Andres    : v1.0  : init. Created 19 July 2013
% Andres    : v2.0  : changed vbles names and added dimensionality check. 29 October 2014

corrArrayMean = []; incorrArrayMean = []; corrArrayStd = []; incorrArrayStd = [];

%% Get trial mean and standard error or deviation 
% Select type of error bars for mean correct and incorrect trials

if ErrorInfo.plotInfo.stdError
    fprintf('Calculating corr-incorr trials mean and standard error for %s\n',ErrorInfo.session)
    corrStdError    =  sqrt(size(corrEpochs,2));            % get standard error of the mean 
    incorrStdError  =  sqrt(size(incorrEpochs,2));          % get standard error of the mean
else
    fprintf('Calculating corr-incorr trials mean and standard deviation for %s\n',ErrorInfo.session)
    corrStdError    = 1;    % get standard deviation
    incorrStdError  = 1;    % get standard deviation
end

% Correct Mean Trials
if ndims(corrEpochs) == 3
    corrMeanTrials = squeeze(nanmean(corrEpochs,2));
    corrStdTrials = squeeze(nanstd(corrEpochs,0,2))/corrStdError;   % std epoch for correct trials
elseif ndims(corrEpochs) == 2                                       
    corrMeanTrials = corrEpochs;                                    % only one epoch, hence no mean
    corrStdTrials = zeros(size(corrMeanTrials));   % std epoch for correct trials
else error('Number of dims for corrEpochs do not match')
end

% Incorrect Mean Trials
if ndims(incorrEpochs) == 3
    incorrMeanTrials = squeeze(mean(incorrEpochs,2));
    incorrStdTrials = squeeze(nanstd(incorrEpochs,0,2))/incorrStdError;   % std epoch for correct trials
elseif ndims(incorrEpochs) == 2                                     
    incorrMeanTrials = incorrEpochs;                                % only one epoch, hence no mean
    incorrStdTrials = zeros(size(incorrMeanTrials));   % std epoch for correct trials
else error('Number of dims for incorrEpochs do not match')
end

%% Get mean values and standard error or deviation from all data per array (trials and channels)
if ErrorInfo.epochInfo.getMeanArrayEpoch
    disp('Calculating mean and st.dev./error epoch for each array...')
    
    nChs = size(corrEpochs,1);
    if ndims(corrEpochs) == 3,  corrNumTrials = size(corrEpochs,2); nSamples = size(corrEpochs,3);
    elseif ndims(corrEpochs) == 2, nSamples = size(corrEpochs,2); corrEpochs = reshape(corrEpochs,[nChs,1,nSamples]); corrNumTrials = 1; %#ok<*ISMAT>
    else error('The size of corrEpochs is incorrect!!')
    end
    
    if ndims(incorrEpochs) == 3,  incorrNumTrials = size(incorrEpochs,2);
    elseif ndims(incorrEpochs) == 2, incorrNumTrials = 1; incorrEpochs = reshape(incorrEpochs,[nChs,1,nSamples]);
    else error('The size of incorrEpochs is incorrect!!')
    end
    
    % Preallocate memory
    corrArrayMean = nan(ErrorInfo.plotInfo.nArrays,nSamples);
    incorrArrayMean = nan(ErrorInfo.plotInfo.nArrays,nSamples);
    corrArrayStd = nan(ErrorInfo.plotInfo.nArrays,nSamples);
    incorrArrayStd = nan(ErrorInfo.plotInfo.nArrays,nSamples);
    
    for iArray = 1:ErrorInfo.plotInfo.nArrays
        % Number channels per array
        nChsPerArray = length(ErrorInfo.plotInfo.arrayChs(iArray,:));
        % Mean values
        corrArrayMean(iArray,:) = nanmean(reshape(corrEpochs(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*corrNumTrials nSamples]),1);
        incorrArrayMean(iArray,:) = nanmean(reshape(incorrEpochs(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*incorrNumTrials nSamples]),1);
        % Standard deviation or error
        if ErrorInfo.plotInfo.stdError
            fprintf('Calculating corr-incorr trials mean and standard error for %s - %s\n',ErrorInfo.session,ErrorInfo.plotInfo.arrayLoc{iArray})
            corrStdError    =  sqrt(nChsPerArray*corrNumTrials);            % get standard error of the mean
            incorrStdError  =  sqrt(nChsPerArray*incorrNumTrials);          % get standard error of the mean
        else
            fprintf('Calculating corr-incorr trials mean and standard deviation for %s - %s\n',ErrorInfo.session,ErrorInfo.plotInfo.arrayLoc{iArray})
            corrStdError    = 1;    % get standard deviation
            incorrStdError  = 1;    % get standard deviation
        end
        corrArrayStd(iArray,:) = nanstd(reshape(corrEpochs(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*corrNumTrials nSamples]),0,1)/corrStdError;   % std epoch for correct trials
        incorrArrayStd(iArray,:) = nanstd(reshape(incorrEpochs(ErrorInfo.plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*incorrNumTrials nSamples]),0,1)/incorrStdError;   % std epoch for correct trials
    end
end