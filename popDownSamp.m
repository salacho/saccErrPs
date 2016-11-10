function [popCorr,popIncorr,ErrorInfo] = popDownSamp(popCorr,popIncorr,ErrorInfo)
% function [popCorr,popIncorr,ErrorInfo] = popDownSamp(popCorr,popIncorr,ErrorInfo)
%
%
%
%
%
%
% 29 Oct. 2016

%% Downsampling epochs
if size(popCorr,3) == 120
else
    if ErrorInfo.signalProcess.downSamp
        % Downsampling factor
        Nth = ErrorInfo.signalProcess.downSampFactor;
        % DownSample
        epochVals = downsample(squeeze(popCorr(:,1,:))',Nth)';                       % each column is considered a separate sequence.
        corrDown = nan([size(epochVals,1),size(popCorr,2),size(epochVals,2)]);
        epochVals = downsample(squeeze(popIncorr(:,1,:))',Nth)';                       % each column is considered a separate sequence.
        incorrDown = nan([size(epochVals,1),size(popIncorr,2),size(epochVals,2)]);
        
        %% Corr
        for iTrial = 1:size(popCorr,2)
            fprintf('Downsampling corr trial %i by a factor of %i...\n',iTrial,Nth)
            % if downsampling
            currTrial = popCorr(:,iTrial,:);
            corrDown(:,iTrial,:) = downsample(squeeze(popCorr(:,iTrial,:))',Nth)';                       % each column is considered a separate sequence.
        end
        popCorr = corrDown; clear corrDown
        
        %% Incorr
        for iTrial = 1:size(popIncorr,2)
            fprintf('Downsampling incorr trial %i by a factor of %i...\n',iTrial,Nth)
            % if downsampling
            currTrial = popIncorr(:,iTrial,:);
            incorrDown(:,iTrial,:) = downsample(squeeze(popIncorr(:,iTrial,:))',Nth)';                       % each column is considered a separate sequence.
        end
        popIncorr = incorrDown; clear incorrDown
        
        % Updating sampling frequency due to downsampling
        ErrorInfo.epochInfo.Fs = ErrorInfo.epochInfo.Fs/ErrorInfo.signalProcess.downSampFactor;
        ErrorInfo.epochInfo.epochLen = ErrorInfo.epochInfo.epochLen/ErrorInfo.signalProcess.downSampFactor;
        ErrorInfo.specParams.params.Fs = ErrorInfo.epochInfo.Fs;
        ErrorInfo.epochInfo.numSamps = size(popIncorr,3);
    end
end

