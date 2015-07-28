 function [eyeTraces,ErrorInfo] = getEyeTraces(OutcomeInfo,ErrorInfo)
% function [eyeTraces,ErrorInfo] = getEyeTraces(OutcomeInfo,ErrorInfo);
%
% Extracts eye traces, EyePupil, EyeX and EyeY linked to the same epochs used 
% for ErrPs using ErrorInfo.epochInfo pre and postOutcome time. Data is saved in the
% ErrorInfo.dirs.DataOut/session folder if ErrorInfo.epochInfo.saveEpochs is true.
%
% INPUT
% OutcomeInfo:                Structure with the following vector/cells:
%     TimeUnits:            'ms'
%     nTrials:              Total number of trials
%     lastTrainTrial:       Last trial in the training block. Used to have
%                           access to only decoder-controlled trials.
%     outcmLbl:               Vector [7x1]. Number for that outcome.
%     outcmTxt:               String. Name of the different outcomes ('correct',
%                           'noFix','fixBreak','sacMaxRt','sacNoTrgt','sacBrk',
%                           'inCorrect').
%     noutcms:                String. Vector with total number of trials for 
%                           each outcome.
%     block:                String. Informs if trials used were from the first, 
%                           second or third block ('Train','Blocked', 'Random' 
%                           respectively). If all blockes are used 'All' is used instead.  
%     nGoodTrls:            Number of good trials.
%     BCtrials:             Brain/decoder-controlled trials
%     BCcode:               EventCode for BC trials. For eye-controlled it is 5001. 
%                           Refer to 'setBhvParam_dlySaccBCI_chico.m', check for 
%                           bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
%     outcm%i:                Structure with times for different events for 
%                           outcome i (from 1 to 7). The vector/cells are: 
% 
%         outcmTrials:      logical vector for the trials for this outcome
%         outcmDecoder:     logical. Decoder-controlled trials (omits the first block - training) 
%         trlNum            Trial number in PTB ;
%         TrialStartTimes:  Times for beginning of trial
%         SampleStartTime:  
%         ExpectedResponse: Expected response  
%         Response:         Response given by the decoder/NHP
%         ReactionTime:     Time between removal of fixation point and
%                           saccade onset
%         RespErrorTime:    Time when last event was collected (upon the 
%                           ocurrence of an error)  
%         BlockNumber:      Block number. 1 for training, 2 for blocked trials, 
%                           3 for randomly presented targets
%         DelayOnsetTime:   Time when delay started  
%         DelayOffsetTime:  End of delay
%         itiOnsetTime:     Start of InterTrial Interval
%         FixationOnsetTime: Fixation spot on (end of ITI) (2 for cntr-out vsn; 200+1:#fixpt's for converge vsn)
%         TargetOnsetTime:  Spatial cue (saccade target) onset
%         SaccadeOnsetTime: Saccade onset/start (timestamped as eye leaves fixation window)
%         SaccadeOffsetTime:Saccade offset/end (timestamped as eye enters saccade window around saccade target)
%         SaccadeEndptLoc:  Location of saccade target. All seem to be 12.5
%         SaccadeVector:    Location of saccade vector. All seem to be 12.5
%         FixpointLoc:      Location of fixation point. Distance from
%                           center point.
%         TrainOrTest:      cell with 'train' or 'test' for each trial
%         rwdStimOn:        vector. Time reward stimulus (secondary) onset
%         punChc:           vector. Time punishment stimulus onset
%         BCtrial:          logical, 1 for brain/decoder-controlled trials
%         nTrials:          Number of trials for this outcome (error) 
% ErrorInfo:                ErrRps info structure. Has all the fields
%                           related to the analysis of ErrRPs.
%         session:          string. Usually in the form 'CS20120925'
%         filedate:         integer. Date in the order YYYMMDD: i.e. 20120925
%         dirs:             structure. Has the DataIn ans DataOut path for reading and saving files respectively.
%         Behav:            structure with all behavioral info from the
%                           data conversion Event functions.
%         EventInfo:        structure. Has all the events obtained in
%                           getOutcomeInfo.m
%         BCIparams:        structure. Decoder parameters (blockType and decodeOnly)
%         tgtDirections:    vector. Target locations in radians. 
%         trialInfo:        structure. Similar to EventInfo but specific to
%                           correct and incorrect trials
% OUTPUT
% eyeTraces:                Structure with all eye traces. Its fields are:
%     corrEye:              Correct stim-locked eye traces
%         pupil:            matrix. Correct pupil traces in the form [numEpochs lengthEpoch].
%         eyeX:             matrix. correct eye X traces in the form [numEpochs lengthEpoch].
%         eyeY:             matrix. correct eye Y traces in the form [numEpochs lengthEpoch].
%         fields:           cell. Name of the fields with data. Usually {'pupil','eyeX','eyeY'}
%         pupilInfo:        ChInfo structure read from the original eye trace
%         xInfo:            ChInfo structure read from the original eye trace
%         yInfo:            ChInfo structure read from the original eye trace
%     incorrEye:            Incorrect stim-locked eye traces
%         pupil:            matrix. Incorrect pupil traces in the form [numEpochs lengthEpoch].
%         eyeX:             matrix. Incorrect eye X traces in the form [numEpochs lengthEpoch].
%         eyeY:             matrix. Incorrect eye Y traces in the form [numEpochs lengthEpoch].
%         fields:           cell. Name of the fields with data. Usually {'pupil','eyeX','eyeY'}
%         pupilInfo:        ChInfo structure read from the original eye trace
%         xInfo:            ChInfo structure read from the original eye trace
%         yInfo:            ChInfo structure read from the original eye trace
%     corrBaseEye:          Correct baseline eye traces
%         pupil:            matrix. Incorrect pupil traces during baseline in the form [numEpochs iti length].
%         eyeX:             matrix. Incorrect eye X traces during baseline in the form [numEpochs iti length].
%         eyeY:             matrix. Incorrect eye Y traces during baseline in the form [numEpochs iti length].
%         fields:           cell. Name of the fields with data. Usually {'pupil','eyeX','eyeY'}
%         pupilInfo:        ChInfo structure read from the original eye trace
%         xInfo:            ChInfo structure read from the original eye trace
%         yInfo:            ChInfo structure read from the original eye trace
% 	incorrBaseEye:          Incorrect baseline eye traces
%         pupil:            matrix. Incorrect pupil traces during baseline in the form [numEpochs iti length].
%         eyeX:             matrix. Incorrect eye X traces during baseline in the form [numEpochs iti length].
%         eyeY:             matrix. Incorrect eye Y traces during baseline in the form [numEpochs iti length].
%         fields:           cell. Name of the fields with data. Usually {'pupil','eyeX','eyeY'}
%         pupilInfo:        ChInfo structure read from the original eye trace
%         xInfo:            ChInfo structure read from the original eye trace
%         yInfo:            ChInfo structure read from the original eye trace
%   corrExpTgt:             vector with all the expected targets for correct trials 
%   corrDcdTgt:             vector with all the decoded targets for correct trials
%   incorrExpTgt:           vector with all the expected targets for incorrect trials 
%   incorrDcdTgt:           vector with all the decoded targets for incorrect trials 
%
% Andres v.1.0
% Created 5th Sept 2013
% Last modified: 6th Sept 2013

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%') 
fprintf('Starting eye traces analysis for %s\n',ErrorInfo.session)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

% Vbles for each outcome
outcomes = {'outcm1','outcm7'};
nOuts = length(outcomes);

%% Eye traces
%if ErrorInfo.eyeTraces.doEyes
fprintf('Extracting eye traces for %s...\n',ErrorInfo.session)
ErrorInfo.dirs.eyeFilesIn = fullfile(ErrorInfo.dirs.DataIn,ErrorInfo.session,ErrorInfo.session);
% Load eye traces
fprintf('Loading lfp001...\n')
lfp001 = load([ErrorInfo.dirs.eyeFilesIn,'-lfp001.mat']);       % to test size of file is correct
EyeLfp = lfp001.lfp001;
fprintf('Loading pupil...\n')
pupil = load([ErrorInfo.dirs.eyeFilesIn,'-EyePupil.mat']);
fprintf('Loading eyeX...\n')
eyeX  = load([ErrorInfo.dirs.eyeFilesIn,'-EyeX.mat']);
fprintf('Loading eyeY...\n')
eyeY  = load([ErrorInfo.dirs.eyeFilesIn,'-EyeY.mat']);
EyePupil = pupil.EyePupil;
EyeX = eyeX.EyeX;
EyeY = eyeY.EyeY;
ErrorInfo.eyeTraces.Fs = pupil.ChInfo.Fs;
Fs = ErrorInfo.eyeTraces.Fs;

% Only run analysis of eye traces if these have the correct length
if (length(EyeLfp) == length(EyePupil)) == (length(EyeX) == length(EyeY))
    % Pre-allocating memory (PAM) for correct and incorrect eye stim- and baseline-locked traces
    nCorrTrials = OutcomeInfo.(outcomes{1}).nTrials;                        % number correct trials
    nIncorrTrials = OutcomeInfo.(outcomes{2}).nTrials;                      % number incorrect/error trials
    eyeLen = ErrorInfo.epochInfo.preOutcomeTime/1000*Fs + ErrorInfo.epochInfo.postOutcomeTime/1000*Fs;
    baseLen = round(ErrorInfo.Behav.dur.itiDur*Fs);                         % length of baseline traces
    corrEye = struct('pupil',nan(nCorrTrials,eyeLen),...                       % correct trials eye traces
        'eyeX', nan(nCorrTrials,eyeLen),...
        'eyeY', nan(nCorrTrials,eyeLen),...
        'pupilInfo', pupil.ChInfo,...                                       % ChInfo structure    
        'xInfo', eyeX.ChInfo,...
        'yInfo', eyeY.ChInfo);
    incorrEye = struct('pupil',nan(nIncorrTrials,eyeLen),...                   % incorrect trials eye traces
        'eyeX', nan(nIncorrTrials,eyeLen),...
        'eyeY', nan(nIncorrTrials,eyeLen),...
        'pupilInfo', pupil.ChInfo,...                                       % ChInfo structure
        'xInfo', eyeX.ChInfo,...
        'yInfo', eyeY.ChInfo);
    corrBaseEye = struct('pupil',nan(nCorrTrials,baseLen),...                  % correct trials eye baseline traces
        'eyeX', nan(nCorrTrials,baseLen),...
        'eyeY', nan(nCorrTrials,baseLen),...
        'pupilInfo', pupil.ChInfo,...                                       % ChInfo structure
        'xInfo', eyeX.ChInfo,...
        'yInfo', eyeY.ChInfo);
    incorrBaseEye = struct('pupil',nan(nIncorrTrials,baseLen),...              % incorrect trials eye baseline traces
        'eyeX', nan(nIncorrTrials,baseLen),...
        'eyeY', nan(nIncorrTrials,baseLen),...
        'pupilInfo', pupil.ChInfo,...                                       % ChInfo structure
        'xInfo', eyeX.ChInfo,...
        'yInfo', eyeY.ChInfo);
    
    % Running eye traces analysis for each outcome
    for iOut = 1:nOuts
        fprintf('Starting eyetraces analysis for %s...\n',outcomes{iOut})
        outTrials       = OutcomeInfo.(outcomes{iOut}).outcmTrials;         % trials for this outcome
        trialStartTimes = OutcomeInfo.(outcomes{iOut}).TrialStartTimes;     % beginning of trials
        itiOnsetTime    = OutcomeInfo.(outcomes{iOut}).itiOnsetTime;        %#ok<*NASGU> % beginning of iti for next trial to start
        % Center times of analysis windows for all trials
        if iOut == 1
            %outcomeStimuli = OutcomeInfo.(outcomes{iOut}).juiceOn;         % correct target acknowledgement by delivering juice reward
            outcomeStimuli = OutcomeInfo.(outcomes{iOut}).rwdStimOn;        % correct target presentation
        else
            outcomeStimuli = OutcomeInfo.(outcomes{iOut}).punChc;           % incorrect target presentation. Punishment
        end
        % Start and end times for all trials
        startEyeTime     = round(outcomeStimuli-ErrorInfo.epochInfo.preOutcomeTime/1000*Fs + 1);
        endEyeTime       = round(outcomeStimuli+ErrorInfo.epochInfo.postOutcomeTime/1000*Fs);
        startEyeBaseTime = round(trialStartTimes);
        endEyeBaseTime   = round(trialStartTimes+ ErrorInfo.Behav.dur.itiDur*Fs - 1);
        % Extract epochs per trial
        for iTrial = 1:OutcomeInfo.(outcomes{iOut}).nTrials
            % Stim-locked traces
            pupilVals = EyePupil(startEyeTime(iTrial):endEyeTime(iTrial));
            xVals     = EyeX(startEyeTime(iTrial):endEyeTime(iTrial));
            yVals     = EyeY(startEyeTime(iTrial):endEyeTime(iTrial));
            % Baseline traces
            pupilBase = EyePupil(startEyeBaseTime(iTrial):endEyeBaseTime(iTrial));
            xBase     = EyeX(startEyeBaseTime(iTrial):endEyeBaseTime(iTrial));
            yBase     = EyeY(startEyeBaseTime(iTrial):endEyeBaseTime(iTrial));
            % Choose correct files
            if iOut == 1
                corrEye.pupil(iTrial,:)     = pupilVals;
                corrEye.eyeX(iTrial,:)      = xVals;
                corrEye.eyeY(iTrial,:)      = yVals;
                corrBaseEye.pupil(iTrial,:) = pupilBase;
                corrBaseEye.eyeX(iTrial,:)  = xBase;
                corrBaseEye.eyeY(iTrial,:)  = yBase;
            else
                incorrEye.pupil(iTrial,:)    = pupilVals;
                incorrEye.eyeX(iTrial,:)     = xVals;
                incorrEye.eyeY(iTrial,:)     = yVals;
                incorrBaseEye.pupil(iTrial,:)= pupilBase;                
                incorrBaseEye.eyeX(iTrial,:) = xBase;
                incorrBaseEye.eyeY(iTrial,:) = yBase;
            end
            
        end
        clear epochVals epochBaseline                                       % erase these vbles to continue with the next outcome
    end
    
    % Creating eyeTraces structure
    eyeTraces.corrEye = corrEye;
    eyeTraces.corrBaseEye = corrBaseEye;
    eyeTraces.incorrEye = incorrEye;
    eyeTraces.incorrBaseEye = incorrBaseEye;                    
    eyeTraces.nCorrTrials = nCorrTrials;
    eyeTraces.nIncorrTrials = nIncorrTrials;
    
    % Saving the expected and decoded target (ground true and decoder's value)
    iOutVal = 'outcm1';
    eyeTraces.corrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
    eyeTraces.corrDcdTgt = OutcomeInfo.(iOutVal).Response;
    iOutVal = 'outcm7';
    eyeTraces.incorrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
    eyeTraces.incorrDcdTgt = OutcomeInfo.(iOutVal).Response;
    
    % Complete name of eye traces to be saved
    if ErrorInfo.eyeTraces.saveEyeTraces
    saveEyeFilename = sprintf('%s-corrIncorrEyeTrace-[%i-%ims].mat',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime);
    save(saveEyeFilename ,'eyeTraces','ErrorInfo')
    fprintf('File %s successfully saved!\n',saveEyeFilename)
    end
else
    error('Length of eye traces does not match length of lfp data. Check dataConversion code!!')
    return
end
