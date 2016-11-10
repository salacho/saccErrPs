function [corrEpochs,incorrEpochs,ErrorInfo] = updateErrorInfo2ReplaceBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo,ErrorInfo10Hz)
% function [corrEpochs,incorrEpochs,ErrorInfo] = updateErrorInfo2ReplaceBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo,ErrorInfo10Hz)
%
%
%
%
%
%
%


% Remove bad trials
if ErrorInfo.epochInfo.rmvNoisyErrP && ~ErrorInfo.epochInfo.rmvNoisyErrPDone
    
    ErrorInfo.signalProcess.badTrialsCorr = ErrorInfo10Hz.signalProcess.badTrialsCorr;
    ErrorInfo.signalProcess.badTrialsIncorr = ErrorInfo10Hz.signalProcess.badTrialsIncorr;
    
    % Get only good trials
    goodTrialsCorr = find(~ErrorInfo.signalProcess.badTrialsCorr);
    goodTrialsIncorr = find(~ErrorInfo.signalProcess.badTrialsIncorr);
    fprintf('Removing bad trials...\n')
    
    %% Create new epochs matrices with only trials that passed the criteria
    corrEpochs = corrEpochsRaw(:,(goodTrialsCorr),:);                     %#ok<*FNDSB> % decoder window of correct data trials       % decoder window of correct data trials
    incorrEpochs  = incorrEpochsRaw(:,(goodTrialsIncorr),:);               % decoder window of incorrect data trials
    
    % Updating number of trials
    ErrorInfo.epochInfo.nCorr = length(goodTrialsCorr);
    ErrorInfo.epochInfo.nError = length(goodTrialsIncorr);
    % Trial info
    ErrorInfo.nChs = size(corrEpochsRaw,1);
    ErrorInfo.epochInfo.nChs = size(corrEpochsRaw,1);
    
    disp('Updating the ErrorInfo.epochInfo fields!!!')
    ErrorInfo.epochInfo.corrExpTgt = ErrorInfo.epochInfo.corrExpTgt(goodTrialsCorr); % [867x1 double]
    ErrorInfo.epochInfo.corrDcdTgt = ErrorInfo.epochInfo.corrDcdTgt(goodTrialsCorr); % [867x1 double]
    ErrorInfo.epochInfo.incorrExpTgt = ErrorInfo.epochInfo.incorrExpTgt(goodTrialsIncorr); % [498x1 double]
    ErrorInfo.epochInfo.incorrDcdTgt = ErrorInfo.epochInfo.incorrDcdTgt(goodTrialsIncorr); %[498x1 double]
    
    % Setting flag on to keep track of changes to data
    ErrorInfo.epochInfo.rmvNoisyErrPDone = 1;
    % Saving noisy trials removed
    ErrorInfo.signalProcess.corrEpochsNoisyTrials = ErrorInfo10Hz.signalProcess.badTrialsCorr;
    ErrorInfo.signalProcess.incorrEpochsNoisyTrials = ErrorInfo10Hz.signalProcess.badTrialsIncorr;
    
    %% Update ErrorInfo.epochInfo
    ErrorInfo.epochInfo.nCorr = size(corrEpochs,2);% 867
    ErrorInfo.epochInfo.nError = size(incorrEpochs ,2); %498
    
    ErrorInfo.epochInfo.corrPrevTrialDcdTgt = ErrorInfo.epochInfo.corrPrevTrialDcdTgt(goodTrialsCorr); %[867x1 double]
    ErrorInfo.epochInfo.corrPrevTrialExpTgt = ErrorInfo.epochInfo.corrPrevTrialExpTgt(goodTrialsCorr); %[867x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialDcdTgt = ErrorInfo.epochInfo.incorrPrevTrialDcdTgt(goodTrialsIncorr); %[498x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialExpTgt = ErrorInfo.epochInfo.incorrPrevTrialExpTgt(goodTrialsIncorr); %[498x1 double]
    
    ErrorInfo.epochInfo.nCorrBad = sum(ErrorInfo.signalProcess.badTrialsCorr);
    ErrorInfo.epochInfo.nErrorBad = sum(ErrorInfo.signalProcess.badTrialsIncorr);
    
else
    corrEpochs = corrEpochsRaw;
    incorrEpochs = incorrEpochsRaw;
    % Update number of channels if the input included 'sgnChs'
    ErrorInfo.nChs = size(corrEpochsRaw,1);
    ErrorInfo.epochInfo.nChs = size(corrEpochsRaw,1);
    ErrorInfo.epochInfo.nCorrBad = 0;
    ErrorInfo.epochInfo.nErrorBad = 0;
    warning('Did not remove bad trials!!!')
end


end