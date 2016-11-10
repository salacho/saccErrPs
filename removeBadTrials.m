function [corrEpochsGood,incorrEpochsGood,ErrorInfo] = removeBadTrials(corrEpochsRmBad,incorrEpochsRmBad,ErrorInfo)
% function [corrEpochsGood,incorrEpochsGood,ErrorInfo] = removeBadTrials(corrEpochs,incorrEpochs,ErrorInfo)
%
% This function removes bad trials automatically using the list of bad
% trials from 'eegGetBadTrials.m'
%
% INPUT
% corrEpochsRmBad:      matrix. [numChs]
% incorrEpochsRmBad:    matrix. [numChs]
% badTrialsCorr:        vector of logicals. [numCorrectTrials x 1]
% badTrialsIncorr:      vector of logicals. [numIncorrectTrials x 1]
%
%
% Andres    :   v1      : init. 07 Aug 2015.
% Andres    :   v.1.2   : remove bad trials from trial info cueTgt, dcdTgt, etc. 26 Aug 2015

% corrEpochsRmBad = sessCorrEpochs; incorrEpochsRmBad = sessIncorrEpochs; ErrorInfo = sessErrorInfo;
% corrEpochsRmBad = corrEpochs; incorrEpochsRmBad = incorrEpochs; ErrorInfo = sessErrorInfo;


%% First ErrPs
% Remove bad trials
if ErrorInfo.epochInfo.rmvNoisyErrP && ~ErrorInfo.epochInfo.rmvNoisyErrPDone
    % Find bad trials
    fprintf('Getting bad trials...\n')
    [ErrorInfo.signalProcess.badTrialsCorr,ErrorInfo.signalProcess.badTrialsIncorr,...
        ErrorInfo.signalProcess.badChsCorrIncorr,ErrorInfo] = ...
        getBadTrials(corrEpochsRmBad,incorrEpochsRmBad,ErrorInfo,ErrorInfo.epochInfo.badChStDevFactor);
    
    % Get only good trials
    goodTrialsCorr = find(~ErrorInfo.signalProcess.badTrialsCorr);
    goodTrialsIncorr = find(~ErrorInfo.signalProcess.badTrialsIncorr);
    fprintf('Removing bad trials...\n')
    
    %% Create new epochs matrices with only trials that passed the criteria
    corrEpochsGood = corrEpochsRmBad(:,(goodTrialsCorr),:);                     %#ok<*FNDSB> % decoder window of correct data trials       % decoder window of correct data trials
    incorrEpochsGood  = incorrEpochsRmBad(:,(goodTrialsIncorr),:);               % decoder window of incorrect data trials
    
    % Updating number of trials
    ErrorInfo.epochInfo.nCorr = length(goodTrialsCorr);
    ErrorInfo.epochInfo.nError = length(goodTrialsIncorr);
    % Trial info
    ErrorInfo.nChs = size(corrEpochsRmBad,1);
    ErrorInfo.epochInfo.nChs = size(corrEpochsRmBad,1);
    
    disp('Updating the ErrorInfo.epochInfo fields!!!')
    ErrorInfo.epochInfo.corrExpTgt = ErrorInfo.epochInfo.corrExpTgt(goodTrialsCorr); % [867x1 double]
    ErrorInfo.epochInfo.corrDcdTgt = ErrorInfo.epochInfo.corrDcdTgt(goodTrialsCorr); % [867x1 double]
    ErrorInfo.epochInfo.incorrExpTgt = ErrorInfo.epochInfo.incorrExpTgt(goodTrialsIncorr); % [498x1 double]
    ErrorInfo.epochInfo.incorrDcdTgt = ErrorInfo.epochInfo.incorrDcdTgt(goodTrialsIncorr); %[498x1 double]

    % Setting flag on to keep track of changes to data
    ErrorInfo.epochInfo.rmvNoisyErrPDone = 1;
    % Saving noisy trials removed
    ErrorInfo.signalProcess.corrEpochsNoisyTrials = ErrorInfo.signalProcess.badTrialsCorr;
    ErrorInfo.signalProcess.incorrEpochsNoisyTrials = ErrorInfo.signalProcess.badTrialsIncorr;
    
    %% Update ErrorInfo.epochInfo
    ErrorInfo.epochInfo.nCorr = size(corrEpochsGood,2);% 867
    ErrorInfo.epochInfo.nError = size(incorrEpochsGood ,2); %498
    
    ErrorInfo.epochInfo.corrPrevTrialDcdTgt = ErrorInfo.epochInfo.corrPrevTrialDcdTgt(goodTrialsCorr); %[867x1 double]
    ErrorInfo.epochInfo.corrPrevTrialExpTgt = ErrorInfo.epochInfo.corrPrevTrialExpTgt(goodTrialsCorr); %[867x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialDcdTgt = ErrorInfo.epochInfo.incorrPrevTrialDcdTgt(goodTrialsIncorr); %[498x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialExpTgt = ErrorInfo.epochInfo.incorrPrevTrialExpTgt(goodTrialsIncorr); %[498x1 double]
   
    ErrorInfo.epochInfo.nCorrBad = sum(ErrorInfo.signalProcess.badTrialsCorr);
    ErrorInfo.epochInfo.nErrorBad = sum(ErrorInfo.signalProcess.badTrialsIncorr);
    
else
    corrEpochsGood = corrEpochsRmBad;
    incorrEpochsGood = incorrEpochsRmBad;
    % Update number of channels if the input included 'sgnChs'
    ErrorInfo.nChs = size(corrEpochsRmBad,1);
    ErrorInfo.epochInfo.nChs = size(corrEpochsRmBad,1);
    ErrorInfo.epochInfo.nCorrBad = 0;
    ErrorInfo.epochInfo.nErrorBad = 0;
    warning('Did not remove bad trials!!!')
end


end