function [newCorrEpochs,newIncorrEpochs,ErrorInfo] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo)
% function [newCorrEpochs,newIncorrEpochs,ErrorInfo] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo)
%
% Removes noisy trials from correct and incorrect epochs matrix
% 
% 
%
%
% Author : Andres.
% 
% Andres :  init    : 30 Oct 2014
% Andres :  

% Pre-allocate memory
corrEpochsNoisyTrials = zeros(size(corrEpochs,2),1);
incorrEpochsNoisyTrials = zeros(size(incorrEpochs,2),1);

%% Remove noisy trials from all channels using a threshold criteria
if ErrorInfo.epochInfo.rmvNoisyErrP && (~ErrorInfo.epochInfo.rmvNoisyChs)
    
    % Get epochs and channels with noisy data
    corrNoisyIndx = (any(abs(corrEpochs) >= ErrorInfo.epochInfo.rmvNoisyErrPthresh,3));
    incorrNoisyIndx = any(abs(incorrEpochs) >= ErrorInfo.epochInfo.rmvNoisyErrPthresh,3);
    
    % Remove noisy epochs (from all channels)
    disp('Analyzing noisy trials for correct epochs')
    for iEpoch = 1:size(corrNoisyIndx,2)
        if any(corrNoisyIndx(:,iEpoch))      % is any ch from correct trials noisy?
            % Add that trial to the ones that will be used
            corrEpochsNoisyTrials(iEpoch) = 1;
            fprintf('Correct trial %i is noisy\n',iEpoch)
        end
    end
    disp('Analyzing noisy trials for incorrect epochs')
    for iEpoch = 1:size(incorrNoisyIndx,2)
        if any(incorrNoisyIndx(:,iEpoch))      % is any ch from incorrect trials noisy?
            % Add that trial to the ones that will be used
            incorrEpochsNoisyTrials(iEpoch) = 1;
            fprintf('Correct trial %i is noisy\n',iEpoch)
        end
    end
    % Setting flag on to keep track of changes to data
    ErrorInfo.epochInfo.rmvNoisyErrPDone = 1;
    
    % Saving noisy trials removed
    ErrorInfo.signalProcess.corrEpochsNoisyTrials = corrEpochsNoisyTrials;
    ErrorInfo.signalProcess.incorrEpochsNoisyTrials = incorrEpochsNoisyTrials;
    
    %% Create new epochs matrices with only trials that passed the criteria
    newCorrEpochs = corrEpochs(:,(~corrEpochsNoisyTrials),:);
    newIncorrEpochs = incorrEpochs(:,(~incorrEpochsNoisyTrials),:);
    
    %% Update ErrorInfo.epochInfo
    disp('Updating the ErrorInfo.epochInfo fields!!!')
    ErrorInfo.epochInfo.corrExpTgt = ErrorInfo.epochInfo.corrExpTgt(~corrEpochsNoisyTrials); % [867x1 double]
    ErrorInfo.epochInfo.corrDcdTgt = ErrorInfo.epochInfo.corrDcdTgt(~corrEpochsNoisyTrials); % [867x1 double]
    ErrorInfo.epochInfo.incorrExpTgt = ErrorInfo.epochInfo.incorrExpTgt(~incorrEpochsNoisyTrials); % [498x1 double]
    ErrorInfo.epochInfo.incorrDcdTgt = ErrorInfo.epochInfo.incorrDcdTgt(~incorrEpochsNoisyTrials); %[498x1 double]
    
    ErrorInfo.epochInfo.nCorr = size(newCorrEpochs,2);% 867
    ErrorInfo.epochInfo.nError = size(newIncorrEpochs,2); %498
    
    ErrorInfo.epochInfo.corrPrevTrialDcdTgt = ErrorInfo.epochInfo.corrPrevTrialDcdTgt(~corrEpochsNoisyTrials); %[867x1 double]
    ErrorInfo.epochInfo.corrPrevTrialExpTgt = ErrorInfo.epochInfo.corrPrevTrialExpTgt(~corrEpochsNoisyTrials); %[867x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialDcdTgt = ErrorInfo.epochInfo.incorrPrevTrialDcdTgt(~incorrEpochsNoisyTrials); %[498x1 double]
    ErrorInfo.epochInfo.incorrPrevTrialExpTgt = ErrorInfo.epochInfo.incorrPrevTrialExpTgt(~incorrEpochsNoisyTrials); %[498x1 double]
end

