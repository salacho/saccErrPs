function [badTrialsCorr,badTrialsIncorr,badChsCorrIncorr,ErrorInfo] = getBadTrials(corrEpochs,incorrEpochs,ErrorInfo,badChStDevFactor)
% function [badTrialsCorr,badTrialsIncorr,badChsCorrIncorr,ErrorInfo] = getBadTrials(corrEpochs,incorrEpochs,ErrorInfo,badChStDevFactor,plotBad);
%
% This function labels the bad trials automatically by detecting trials with
% ampitude larger than 'badChStDevFactor' times the standard deviation from the mean.
% Usually values that are >>95% of the variance of all data (if normally distributed).
%
% INPUT
% corrEpochs
% incorrEpochs
% badChStDevFactor:     double. Value to multiply the standard deviation
%                       and used as threshold to find if traces cross it or
%                       not to set a trial as bad or not.
%
% OUTPUT
% badTrialsCorr:        vector of logicals. [numCorrectTrials x 1]. Bad/noisy
%                       correct trials
% badTrialsIncorr:      vector of logicals. [numIncorrectTrials x 1]. Bad/noisy trials
%                       incorrect trials
% badChsCorrIncorr:     vector of logical. [numChs x 1]. Noisy channels for all correct and incorrect trials
%
% Andres    :   v1  : init. 07 Aug 2015.

% StdDevFactorList = 4;
%badChStDevFactor = StdDevFactorList(1);

% ErrorInfo = ErrorInfo10Hz;

if nargin < 5, plotBad = 0;  end
if nargin < 6, getBaxter2ndEpochs = 0; end

badTrialsCorr = []; badTrialsIncorr = []; badChsCorrIncorr = [];

if ErrorInfo.epochInfo.rmvNoisyErrP && ~ErrorInfo.epochInfo.rmvNoisyErrPDone
    % Saving in structure
    ErrorInfo.epochInfo.badChStDevFactor = badChStDevFactor;
    
    % Vbles
    Fs = ErrorInfo.epochInfo.Fs;
    nIncorr = size(incorrEpochs,2);
    [nChs,nCorr,~] = size(corrEpochs);
   
    % Criteria to call a channel badCh
    ErrorInfo.signalProcess.minNumBadTrialsPerCh = mean(nCorr+nIncorr)*0.1;% if at least 20% of all
    
    % AFSG 27102016
    %     % Fix time windows
    %     ErrorInfo = fixOutcomeTimeWindows(ErrorInfo);
 
    %% For both primary and secondary ErrPs
    preStimTime = ErrorInfo.epochInfo.preOutcomeTime/1000;          % Data length before stimulus presentation
    dcdWindow = ErrorInfo.signalProcess.dcdWindow/1000;
   
    %% Sample Indeces for beginning and end of analysis window (when baseline removed also that period is important since noise there affects baseline removal)
    if ErrorInfo.epochInfo.rmvBaseline;              % Flag setting if baseline is removed
        disp('Starting bad trial analysis window at baseline removal time...')
        baselineTime = ErrorInfo.signalProcess.baselineLen/1000;     % Data length to take baseline from (in ms)
        iStart = round((preStimTime - baselineTime)*Fs+1);              % starting at the feedback onset time. It does not matter if there is a 100 ms delay after the feedback code is sent (for baxter). This only matters for the baseline removal section
    else
        iStart = round((preStimTime + dcdWindow(1))*Fs+1);              % starting at the feedback onset time. It does not matter if there is a 100 ms delay after the feedback code is sent (for baxter). This only matters for the baseline removal section
    end
    iEnd = round((preStimTime + dcdWindow(2))*Fs);                      % last sample
   
    % Get only window for covariates but also including period of baseline removal (if any)
    corrEpochsProc = corrEpochs(:,:,iStart:iEnd);                   % decoder window of correct data trials       % decoder window of correct data trials
    incorrEpochsProc = incorrEpochs(:,:,iStart:iEnd);               % decoder window of incorrect data trials
    nSamp = iEnd-iStart+1;
   
    % Remove trials with amplitude > badChStDevFactor standard deviations (outliers/noise)
    badSampCorr = zeros(size(corrEpochsProc));
    badSampIncorr = zeros(size(incorrEpochsProc));
   
    badChTrialsCorr = zeros(nChs,nCorr);
    badChTrialsIncorr = zeros(nChs,nIncorr);
   
    % Get samp,trials,chs with outliers
    for iCh = 1:nChs
        %% Correct
        corrCh = squeeze(corrEpochsProc(iCh,:,:))';
        corrChMn = nanmean(corrCh,2);
        corrStdCh = nanstd(corrCh,1,2);
        %         %Smooth the Std.Dev.
        %         corrStdChSmooth = filtfilt(FiltParams.b,FiltParams.a,corrStdCh);
       
        %corrThreshold = (corrChMn + badChStDevFactor*(corrStdChSmooth + mean(corrStdCh)));
        corrThresholdUp = (corrChMn + badChStDevFactor*corrStdCh);
        corrThresholdDw = (corrChMn - badChStDevFactor*corrStdCh);
       
        % Check if values above stand.dev.
        for iTrial = 1:nCorr,
            badSampCorrUp = corrCh(:,iTrial) > corrThresholdUp ;
            badSampCorrDw = corrCh(:,iTrial) < corrThresholdDw ;
           
            %plot(corrCh(:,iTrial),'b'), hold on, plot(-corrThreshold,'r'), plot(corrThreshold,'g')
            badSampCorr(iCh,iTrial,:) = badSampCorrUp + badSampCorrDw;
           
            % Fill information matrix
            if any(badSampCorr(iCh,iTrial,:))
                badChTrialsCorr(iCh,iTrial) = 1;
            end
        end
       
        %% Incorrect
        incorrCh = squeeze(incorrEpochsProc(iCh,:,:))';
        incorrChMn = nanmean(incorrCh,2);
        incorrStdCh = nanstd(incorrCh,1,2);
        %         %Smooth the Std.Dev.
        %         incorrStdChSmooth = filtfilt(FiltParams.b,FiltParams.a,incorrStdCh);
       
        %incorrThreshold = (incorrChMn + badChStDevFactor*(incorrStdChSmooth + mean(incorrStdCh)));
        incorrThresholdUp = (incorrChMn + badChStDevFactor*incorrStdCh);
        incorrThresholdDw = (incorrChMn - badChStDevFactor*incorrStdCh);
       
        % Check if values above stand.dev.
        for iTrial = 1:nIncorr,
            badSampIncorrUp = incorrCh(:,iTrial) > incorrThresholdUp ;
            badSampIncorrDw = incorrCh(:,iTrial) < incorrThresholdDw ;
            badSampIncorr(iCh,iTrial,:) = badSampIncorrUp + badSampIncorrDw;
           
            % Fill information matrix
            if any(badSampIncorr(iCh,iTrial,:))
                badChTrialsIncorr(iCh,iTrial) = 1;
            end
        end
    end
   
    % Sum all samples per trial/all channels
    badTrialsSumCorr = sum(badChTrialsCorr,1);
    badTrialsSumIncorr = sum(badChTrialsIncorr,1);
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bad channels accross trials and dcdWindow
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    badChsSumCorr = sum(badChTrialsCorr,2);
    badChsSumIncorr = sum(badChTrialsIncorr,2);
   
    % Get bad channels
    % The noise should be similar in all, only some extremely noisy, hence
    % use mean and st.dev.
    badChMeanCorr = nanmean(badChsSumCorr); badChStdevCorr = nanstd(badChsSumCorr);
    badChMeanIncorr = nanmean(badChsSumIncorr); badChStdevIncorr = nanstd(badChsSumIncorr);
    % Bad channels
    badChsCorr = and(badChsSumCorr > 2*badChStdevCorr + badChMeanCorr,badChsSumCorr > ErrorInfo.signalProcess.minNumBadTrialsPerCh);
    badChsIncorr = and(badChsSumIncorr > 2*badChStdevIncorr + badChMeanIncorr,badChsSumIncorr > ErrorInfo.signalProcess.minNumBadTrialsPerCh);
    % Bad channels fro both correct and incorrect trials
    badChsCorrIncorr = or(badChsCorr,badChsIncorr);
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bad trial flag across channels and dcdWindow
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Only bad trials that happen in at least channels
    badTrialsSumCorrMin = badTrialsSumCorr > 10;
    badTrialsSumIncorrMin = badTrialsSumIncorr > 10;
    
    % Bad trials
    badTrialsCorr = badTrialsSumCorrMin ~= 0;
    badTrialsIncorr = badTrialsSumIncorrMin ~= 0;
   
    % Plot corr-incorr channels and trials
    if plotBad
        figure,
        subplot(2,3,1), imagesc(badChTrialsCorr),title(sprintf('badChTrialsCorr and badChStDevFactor: %0.2f',badChStDevFactor))
        subplot(2,3,2), plot(badChsSumCorr,'*'),title('badChsSumCorr'), hold on
        plot(badChsCorr,'r*')
        subplot(2,3,3), plot(badTrialsSumCorr,'*'),title('badTrialsSumCorr'), hold on
        plot(badTrialsCorr,'r*')
        subplot(2,3,4), imagesc(badChTrialsIncorr),title(sprintf('badChTrialsIncorr and badChStDevFactor: %0.2f',badChStDevFactor))
        subplot(2,3,5), plot(badChsSumIncorr,'*'),title('badChsSumIncorr'), hold on
        plot(badChsIncorr,'r*')
        subplot(2,3,6), plot(badTrialsSumIncorr,'*'),title('badTrialsSumIncorr'), hold on
        plot(badTrialsIncorr,'r*')
    end
   
    fprintf('\nNumber of badTrialsCorr %i\n',sum(badTrialsCorr > 0))
    fprintf('Number of badTrialsIncorr %i\n',sum(badTrialsIncorr > 0))
    fprintf('Number of badChsCorrIncorr %i\n',sum(badChsCorrIncorr> 0))

    %% Store values
    if ~getBaxter2ndEpochs
        ErrorInfo.signalProcess.badTrialsSumCorr = badTrialsSumCorr;
        ErrorInfo.signalProcess.badTrialsSumIncorr = badTrialsSumIncorr;
        ErrorInfo.signalProcess.badTrialsSumCorrMin = badTrialsSumCorrMin;
        ErrorInfo.signalProcess.badTrialsSumIncorrMin = badTrialsSumIncorrMin;
        ErrorInfo.signalProcess.badTrialsCorr = badTrialsCorr;
        ErrorInfo.signalProcess.badTrialsIncorr = badTrialsIncorr;
        ErrorInfo.signalProcess.badChsCorrIncorr = badChsCorrIncorr;
        ErrorInfo.signalProcess.badChsSumCorr = badChsSumCorr;
        ErrorInfo.signalProcess.badChsSumIncorr = badChsSumIncorr;
        % Matrices
        ErrorInfo.signalProcess.badChTrialsIncorr = badChTrialsIncorr;
        ErrorInfo.signalProcess.badChTrialsCorr = badChTrialsCorr;
    else
        %% For general analysis!
        ErrorInfo.signalProcess.badTrialsSumCorr = badTrialsSumCorr;
        ErrorInfo.signalProcess.badTrialsSumIncorr = badTrialsSumIncorr;
        ErrorInfo.signalProcess.badTrialsCorr = badTrialsCorr;
        ErrorInfo.signalProcess.badTrialsIncorr = badTrialsIncorr;
        ErrorInfo.signalProcess.badChsCorrIncorr = badChsCorrIncorr;
        ErrorInfo.signalProcess.badChsSumCorr = badChsSumCorr;
        ErrorInfo.signalProcess.badChsSumIncorr = badChsSumIncorr;
        % Matrices
        ErrorInfo.signalProcess.badChTrialsIncorr = badChTrialsIncorr;
        ErrorInfo.signalProcess.badChTrialsCorr = badChTrialsCorr;

        % To keep track of secondary errors
        ErrorInfo.signalProcess.badTrialsSumCorr2 = badTrialsSumCorr;
        ErrorInfo.signalProcess.badTrialsSumIncorr2 = badTrialsSumIncorr;
        ErrorInfo.signalProcess.badTrialsCorr2 = badTrialsCorr;
        ErrorInfo.signalProcess.badTrialsIncorr2 = badTrialsIncorr;
        ErrorInfo.signalProcess.badChsCorrIncorr2 = badChsCorrIncorr;
        ErrorInfo.signalProcess.badChsSumCorr2 = badChsSumCorr;
        ErrorInfo.signalProcess.badChsSumIncorr2 = badChsSumIncorr;
        % Matrices
        ErrorInfo.signalProcess.badChTrialsIncorr2 = badChTrialsIncorr;
        ErrorInfo.signalProcess.badChTrialsCorr2 = badChTrialsCorr;
    end
end

end