function [corrTrialSpkTimes,incorrTrialSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo)
% function [corrTrialSpkTimes,incorrTrialSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo)
%
% Organize all spike times per trial and outcome (correct and incorrect),
% for each spkTimes vector using trial times given in OutcomeInfo. All
% these spike times belong to one channel or unit. Time zero is the feedback onset time, 
% hence values span from -preOutcome to +postOutcome time, in milliseconds. 
%
% INPUT
%
% spkTimes:                 vector. Time stamps for spike events for all session. 
% OutcomeInfo:              Structure with the following vector/cells:
%     TimeUnits:            'ms'
%     nTrials:              Total number of trials
%     lastTrainTrial:       Last trial in the training block. Used to have
%                           access to only decoder-controlled trials.
%     outcmLbl:             Vector [7x1]. Number for that outcome.
%     outcmTxt:             String. Name of the different outcomes ('correct',
%                           'noFix','fixBreak','sacMaxRt','sacNoTrgt','sacBrk',
%                           'inCorrect').
%     noutcms:              String. Vector with total number of trials for each outcome.
%     block:                String. Informs if trials used were from the first, 
%                           second or third block ('Train','Blocked', 'Random' 
%                           respectively). If all blockes are used 'All' is used instead.  
%     nGoodTrls:            Number of good trials.
%     BCtrials:             Brain/decoder-controlled trials
%     BCcode:               EventCode for BC trials. For eye-controlled it is 5001. 
%                           Refer to 'setBhvParam_dlySaccBCI_chico.m', check for 
%                           bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
%     outcm%i:              Structure with times for different events for outcome i (from 1 to 7).  
% ErrorInfo:                Chronic Recording info structure. 
%
% OUTPUT
%
% corrTrialSpkTimes:        cell array spike times for all correct trials.  
%                           Each trial is a cell array with spike times
%                           Each correct trial is a cell array with spike times.
% incorrTrialSpkTimes:      cell array spike times for all incorrect trials.  
%                           Each incorrect trial is a cell with spike times
%
% Author : Andres
% 
% Andres :  init    : 15 Oct 2014
% Andres :  

% Vbles for each outcome
outcomes = {'outcm1','outcm7'};
nOuts = length(outcomes);

% Running analysis for each outcome
for iOut = 1:nOuts
    fprintf('Extracting spike data for %s...\n',outcomes{iOut})
    % Center of analysis window
    if iOut == 1
        %outcomeStimuli = OutcomeInfo.(outcomes{iOut}).juiceOn;         % correct target acknowledgement by delivering juice reward
        outcomeStimuli = OutcomeInfo.(outcomes{iOut}).rwdStimOn;        % correct target presentation
    else
        outcomeStimuli = OutcomeInfo.(outcomes{iOut}).punChc;           % incorrect target presentation. Punishment
    end
    % Analysis window
    analWindow(1,:) = (outcomeStimuli - ErrorInfo.spikeInfo.preOutcomeTime);
    analWindow(2,:) = (outcomeStimuli + ErrorInfo.spikeInfo.postOutcomeTime);
    
    % Extract epochs per trial, per channel
    for iTrial = 1:OutcomeInfo.(outcomes{iOut}).nTrials
        % For each trial find spikes times within feedback onset. Also center spike times to feedback onset
        outcomeSpk{iTrial} = spkTimes((spkTimes >= analWindow(1,iTrial)) & (spkTimes <= analWindow(2,iTrial))) - outcomeStimuli(iTrial);
    end
    
    % Saving corr and incorr spike times
    if iOut == 1
        corrTrialSpkTimes = outcomeSpk;
    else
        incorrTrialSpkTimes = outcomeSpk;
    end
    clear outcomeSpk analWindow                                                     % erase these vbles to continue with the next outcome
end

end
