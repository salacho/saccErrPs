function [corrEpochs,incorrEpochs,ErrorInfo] = getErrRPs(OutcomeInfo,ErrorInfo)
% function [corrEpochs,incorrEpochs,ErrorInfo] = getErrRPs(OutcomeInfo,ErrorInfo)
%
% Extracts the error-related potential epochs using ErrorInfo.epochInfo pre 
% and postOutcome time and filter settings. Data is saved in the
% ErrorInfo.dirs.DataOut/session folder using the params vaules (ErrorInfo.epochInfo.saveEpochs).
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
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% corrBaseline:             matrix. Correct baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
% incorrBaseline:           matrix. Incorrect epochs baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].% ErrorInfo:                ErrRps info structure. The structure 'epochInfo' is included
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% Author    : Andres 
%
% andres    : 1.1   : initial. Created June 2013 
% andres    : 2.0   : Added option to open a type of file and included the Fs in ErrorInfo structure
% andres    : 2.1   : Changed values in ms to samples to be compatible with Fs different to 1000. 05 Sept 2013

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%') 
fprintf('Starting ErrRPs analysis for %s\n',ErrorInfo.session)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

% Strings/names for loading and saving...
infoStr = getInfoStr(ErrorInfo);

%type of data to load
switch ErrorInfo.epochInfo.typeRef
    case 'lfp'
        strgRef = '';
    case 'lapla'
        strgRef = 'lapla_';
    case 'car'
        strgRef = 'car';
end

% Vbles for each outcome
outcomes = {'outcm1','outcm7'};
nOuts = length(outcomes);
    
% Since no Fs info for laplacian, need to figure it out by ourselves
if strcmp(ErrorInfo.epochInfo.typeRef,'lfp') || strcmp(ErrorInfo.epochInfo.typeRef,'lapla')
    getFsName = sprintf('%s-lfp%03d.mat',fullfile(ErrorInfo.dirs.DataIn,ErrorInfo.session,ErrorInfo.session),2);
    FsFile = load(getFsName);
    Fs = FsFile.ChInfo.Fs;
else
    disp('Add other criteria to extract the sampling frequency!')
end

%% Initializing vbles for epochs and baseline
% epochSampLen before downsampling
epochSampLen = round((ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime)/1000*Fs);

if ErrorInfo.signalProcess.downSamp
    % if downsampling 
    epochMatrixSampLen = round((ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime)/1000*(Fs/ErrorInfo.signalProcess.downSampFactor));
    % Initializing vbles for epochs and baseline
    corrEpochs   = nan(ErrorInfo.epochInfo.nChs,OutcomeInfo.noutcms(1),epochMatrixSampLen);   % From ms to downsampled samples
    incorrEpochs = nan(ErrorInfo.epochInfo.nChs,OutcomeInfo.noutcms(7),epochMatrixSampLen);   % From ms to downsampled samples
    % Downsampling factor
    Nth = ErrorInfo.signalProcess.downSampFactor;
else
    % if not downsampling (why not?) 
    corrEpochs   = nan(ErrorInfo.epochInfo.nChs,OutcomeInfo.noutcms(1),epochSampLen);   % From ms to samples
    incorrEpochs = nan(ErrorInfo.epochInfo.nChs,OutcomeInfo.noutcms(7),epochSampLen);   % From ms to samples
end

%% Load each channel
for iCh = 1:ErrorInfo.epochInfo.nChs
    dataStr = sprintf('%slfp%03d',strgRef,iCh);                             % name of this channel
    dataName = sprintf('%s-%s.mat',fullfile(ErrorInfo.dirs.DataIn,ErrorInfo.session,ErrorInfo.session),dataStr);
    fprintf('Loading and processing %s...\n',dataStr)                       % display channel loaded
    data = load(dataName);
    data2epoch = data.(dataStr);                                            % vector with data in milliseconds. See data.ChInfo.Fs
    data.ChInfo.Fs = Fs;                                                    % Sampling frequency
    
    % Filtering data2epoch to filtData
    ErrorInfo.epochInfo.Fs = data.ChInfo.Fs;                                % Sampling frequency
    if iCh == 1
        FiltParams = setFilterParams([ErrorInfo.epochInfo.filtLowBound ErrorInfo.epochInfo.filtHighBound],ErrorInfo.epochInfo.filtType,ErrorInfo.epochInfo.filtOrder,data.ChInfo.Fs);
    end
    %disp('FiltParams:'), disp(FiltParams)
    %[Bcoef,Acoef] = butter(4,freqBands);   % Band width signal using Nyquist Freq to normalized 0.5-20 Hz band
    %filtData = filtfilt(Bcoef,Acoef,data2epoch);
    disp('Filtering data...')
    filtData = filtfilt(FiltParams.b,FiltParams.a,data2epoch);

    % Running analysis for each outcome
    for iOut = 1:nOuts
        outTrials       = OutcomeInfo.(outcomes{iOut}).outcmTrials;
        trialStartTimes = OutcomeInfo.(outcomes{iOut}).TrialStartTimes;     % beginning of trials
        itiOnsetTime    = OutcomeInfo.(outcomes{iOut}).itiOnsetTime;        %#ok<*NASGU> % beginning of iti for next trial to start
        
        % Creating matrix to nest all epochs
        epochVals = nan(OutcomeInfo.(outcomes{iOut}).nTrials,epochSampLen);
        
        % Center of analysis window
        if iOut == 1
            %outcomeStimuli = OutcomeInfo.(outcomes{iOut}).juiceOn;         % correct target acknowledgement by delivering juice reward
            outcomeStimuli = OutcomeInfo.(outcomes{iOut}).rwdStimOn;        % correct target presentation
        else
            outcomeStimuli = OutcomeInfo.(outcomes{iOut}).punChc;           % incorrect target presentation. Punishment
        end
        
        % Extract epochs per trial, per channel
        for iTrial = 1:OutcomeInfo.(outcomes{iOut}).nTrials
            preSamples = round((outcomeStimuli(iTrial) - ErrorInfo.epochInfo.preOutcomeTime)/1000*Fs) + 1;
            postSamples = round((outcomeStimuli(iTrial) + ErrorInfo.epochInfo.postOutcomeTime)/1000*Fs);
            % Kludge! Sample size issues. If extra needed, add in the
            % postOutcome window
            if length(preSamples:postSamples) ~= epochSampLen
                postSamples = postSamples + epochSampLen - length(preSamples:postSamples);
            end
            epochVals(iTrial,:) = filtData(preSamples:postSamples);
        end
        
        %% Downsampling epochs
        if ErrorInfo.signalProcess.downSamp
            data2Downsamp = epochVals';          % Must be in the form [nSamples x nTrials], for matrix downsampling each column 
            fprintf('Downsampling in %s channel %i by a factor of %i...\n',outcomes{iOut},iCh,Nth)
            %  Each column is considered a separate sequence.
            epochVals = downsample(data2Downsamp,Nth)';                       % each column is considered a separate sequence.
        end
        
        %% Creating corr and incorr epochs
        if iOut == 1
            corrEpochs(iCh,:,:) = epochVals;
        else
            incorrEpochs(iCh,:,:) = epochVals;
        end
        clear epochVals                                                     % erase these vbles to continue with the next outcome
    end
    clear dataStr dataName data data2epoch filtData                         % erase data for this channel
end

% Updating sampling frequency due to downsampling
if ErrorInfo.signalProcess.downSamp
    ErrorInfo.epochInfo.Fs = ErrorInfo.epochInfo.Fs/ErrorInfo.signalProcess.downSampFactor;
    ErrorInfo.epochInfo.epochLen = ErrorInfo.epochInfo.epochLen/ErrorInfo.signalProcess.downSampFactor;
    ErrorInfo.specParams.params.Fs = ErrorInfo.epochInfo.Fs;
end

%% Size of epoch
ErrorInfo.epochInfo.epochSampLen = size(corrEpochs,3);
ErrorInfo.epochInfo.numSamps = size(corrEpochs,3);

% Saving the expected and decoded target (ground true and decoder's value)
% for current and previous trial
iOutVal = 'outcm1';
ErrorInfo.epochInfo.corrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
ErrorInfo.epochInfo.corrDcdTgt = OutcomeInfo.(iOutVal).Response;
ErrorInfo.epochInfo.corrPrevTrialDcdTgt = OutcomeInfo.(iOutVal).prevTrialResponse;            % Previous trial true response
ErrorInfo.epochInfo.corrPrevTrialExpTgt = OutcomeInfo.(iOutVal).preTrialExpectedResponse;     % Previous trial expected response
iOutVal = 'outcm7';
ErrorInfo.epochInfo.incorrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
ErrorInfo.epochInfo.incorrDcdTgt = OutcomeInfo.(iOutVal).Response;
ErrorInfo.epochInfo.incorrPrevTrialDcdTgt = OutcomeInfo.(iOutVal).prevTrialResponse;            % Previous trial true response
ErrorInfo.epochInfo.incorrPrevTrialExpTgt = OutcomeInfo.(iOutVal).preTrialExpectedResponse;     % Previous trial expected response

%% Saving epochs
if ErrorInfo.epochInfo.saveEpochs
    saveFilename = sprintf('%s-corrIncorrEpochs%s.mat',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        infoStr.strSuffix);
    save(saveFilename,'corrEpochs','incorrEpochs','ErrorInfo','-v7.3')
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Set filter parameter %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  FiltParams = setFilterParams(freqRange, filtType, filtOrder, smpRate)
FNyquist = smpRate/2;
switch filtType
  case 'butter';
      % upper limit must be < Nyquist
      if (freqRange(2) < FNyquist) || (freqRange(2) == inf)
          % Low-pass filtering -- only input high-cutoff frequency
          if (freqRange(1) == 0) && (freqRange(2) ~= inf)
              [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(2)/FNyquist, 'low');
            % High-pass filtering -- only input low-cutoff frequency
          elseif (freqRange(2) == inf) && (freqRange(1) < FNyquist)
              [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(1)/FNyquist, 'high');
              % Band-pass filtering -- input [low,high] cutoff frequencies
          else
              [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(:)/FNyquist);
          end
      else
          % No filter required (Both parameters are 1)
          if (freqRange(2) == FNyquist) && (freqRange(1) == 0)
              FiltParams.b = 1; FiltParams.a = 1;
              % High pass filter
          elseif(freqRange(2) == FNyquist) && (freqRange(1) > 0)
              [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(1)/FNyquist, 'high');
          else
              error('Filter upper limit (%i Hz) is higher than Nyquist frequency (%i Hz)',freqRange(2),FNyquist);
          end
      end
  otherwise;
      error('setFilterParams: Filter type %s unknown',filtType);
end
end