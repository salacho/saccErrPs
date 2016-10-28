function [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = loadErrRPs(ErrorInfo)
% function [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = loadErrRPs(ErrorInfo)
% 
% Loads ErrRPs files containing both correct and incorrect epochs (based on 
% the decoder selections) using the time stamps given by pre and post 
% outcome time using as time zero either the presentation of the correct or 
% incorrect stimuli. All used params are in mainParams. See below for more info. 
%
% INPUT
% ErrorInfo:       structure with fields used to load, filter and epoch files
%   session:        string. Name of the session, usually in the form 'CS20120910'.
%   nChs:           integer. total number of channels. Need to un-hard code this
%   freqRange:      vector. low and high freq. values to filter data
%   preOutcomeTime: integer. Pre-outcome stimuli presentation time (ms)
%   postOutcomeTime:integer. Post-outcome stimuli presentation time (ms)
%
% OUTPUT
% corrEpochs:       matrix. All the correct epochs. [numChannels numEpochs numDatapoints].
% incorrEpochs:     matrix. All the incorrect epochs. [numChannels numEpochs numDatapoints].
% corrBaseline:     matrix. Correct baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                   It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
% incorrBaseline:   matrix. Incorrect epochs baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                   It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
% ErrorInfo:        structure. Has all the info regarding how the epochs were obtained.
%          
% Andres v.1.0
% Andres v.2.0      Added eyeTraces
% Created 14 June 2013
% Last modiffied 05 Sept 2013

%% Initial values and paths
% type of data from which epochs are taken from
switch ErrorInfo.epochInfo.typeRef
    case 'lfp',  strgRef = '';
    case 'lapla',strgRef = 'lapla_';
    case 'car',  strgRef = 'car';
end

infoStr = getInfoStr(ErrorInfo);

% For backwards compatibility
infoStr2 = infoStr;
if or(strcmp(infoStr.downSampStr,'downSamp1'),strcmp(infoStr.downSampStr,'-downSamp1')) 
    infoStr2.downSampStr= '';
end

if strcmp(infoStr.strFiltType,'butt'), infoStr2.strFiltType = '';
end 
if strcmp(infoStr.strSuffix,'-downSamp1[600-600ms]-butt4[1.0-10Hz]'),infoStr2.strSuffix ='-[600-600ms]-[1.0-10Hz]';
end
      
%% Load ErrPs
if ErrorInfo.epochInfo.doErrPs
    if ~isfield(ErrorInfo.epochInfo,'NewErrPs')
        ErrorInfo.epochInfo.NewErrPs = 0;
    end
    
    % Specific vals used to get ErrRPs epochs saved, for backward compatibility
    if ~isfield(ErrorInfo.epochInfo,'nChs')
        ErrorInfo.epochInfo.nChs = ErrorInfo.nChs;             % total number of channels. Need to un-hard code this
    end
    
    %% Loading ErrPs files
    tStart = tic;
    % Complete name of epochs file to be loaded
    loadFilename = sprintf('%s-corrIncorrEpochs%s.mat',infoStr.strPrefix,infoStr.strSuffix);
    loadFilename2 = sprintf('%s-corrIncorrEpochs%s.mat',infoStr2.strPrefix,infoStr2.strSuffix);
    
    %loadFilenameOld = sprintf('%s-corrIncorrEpochs-%s[%i-%ims]-[%0.1f-%iHz].mat',infoStr.strPrefix,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    
%     % For backwards compatibility!
%     if (strcmp(ErrorInfo.epochInfo.filtType,'butter')) && (ErrorInfo.epochInfo.filtOrder == 4) && exist(loadFilenameOld,'file')
%         loadFilename = loadFilenameOld;
%     else loadFilename = loadFilenameNew;
%     end
        
    % Loading...
    % If files exists, just load it
    if or(exist(loadFilename,'file'),exist(loadFilename2,'file'))
        if exist(loadFilename,'file'), fprintf('Patience...loading file %s\n',loadFilename);
            ErrRPs = load(loadFilename);
        else fprintf('Patience...loading file %s\n',loadFilename2); 
            ErrRPs = load(loadFilename2);
        end
        
        tElapsed     = toc(tStart);
        fprintf('Loading took %0.2d seconds\n',tElapsed)
        % Separate files 
        corrEpochs   = ErrRPs.corrEpochs;        % correct epochs
        incorrEpochs = ErrRPs.incorrEpochs;      % incorrect epochs
        
        % Vbles from loaded 'ErrorInfo' that need to be recovered!!
        % Specially after downsampling!!
        ErrorInfo.epochInfo.corrExpTgt      = ErrRPs.ErrorInfo.epochInfo.corrExpTgt; 
        ErrorInfo.epochInfo.corrDcdTgt      = ErrRPs.ErrorInfo.epochInfo.corrDcdTgt; 
        ErrorInfo.epochInfo.incorrExpTgt    = ErrRPs.ErrorInfo.epochInfo.incorrExpTgt; 
        ErrorInfo.epochInfo.incorrDcdTgt    = ErrRPs.ErrorInfo.epochInfo.incorrDcdTgt; 
        ErrorInfo.epochInfo.Fs              = ErrRPs.ErrorInfo.epochInfo.Fs; 
        ErrorInfo.specParams.params.Fs      = ErrorInfo.epochInfo.Fs;
        
        % AFSG (2014-02-27) ErrorInfo = ErrRPs.ErrorInfo;         % info structure. Do not replace info structure, what matters is what we currently have. This files have not changed   
        
        % To solve backwards compatibility issues
        ErrorInfo.epochInfo.nCorr = size(corrEpochs,2);
        ErrorInfo.epochInfo.nError = size(incorrEpochs,2);
        ErrorInfo.epochInfo.numSamps = size(corrEpochs,3);

        % Adding the events, behav and BCI info
        % Kludge! new files have different info structure fields. (AFSG-20141023)
        if ~isfield(ErrRPs.ErrorInfo,'BCItrialInfo')
            [dummyInfo,~] = getOutcmInfo(ErrorInfo,ErrorInfo.epochInfo.blockType,ErrorInfo.epochInfo.decodOnly);        %Get all events and possible outcomes
            ErrRPs.ErrorInfo.BCItrialInfo = dummyInfo.BCItrialInfo;
        else
            ErrorInfo.BCItrialInfo = ErrRPs.ErrorInfo.BCItrialInfo;
        end
        % Kludge! Adding previous trial info
        if ~isfield(ErrRPs.ErrorInfo.epochInfo,'incorrPrevTrialDcdTgt')
            warning('Cannot find previous trial info...loading it!!...') 
            
            % KLUDGE!!! Going to server for data
            origDataIn = ErrorInfo.dirs.DataIn;
            ErrorInfo.dirs.DataIn = 'Z:\bci\mat';
            [~,OutcomeInfo] = getOutcmInfo(ErrorInfo,ErrorInfo.epochInfo.blockType,ErrorInfo.epochInfo.decodOnly);        %Get all events and possible outcomes
            ErrorInfo.dirs.DataIn = origDataIn;
            
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
        else
            ErrorInfo.epochInfo.corrPrevTrialDcdTgt = ErrRPs.ErrorInfo.epochInfo.corrPrevTrialDcdTgt;            % Previous trial true response
            ErrorInfo.epochInfo.corrPrevTrialExpTgt = ErrRPs.ErrorInfo.epochInfo.corrPrevTrialExpTgt;     % Previous trial expected response
            ErrorInfo.epochInfo.incorrPrevTrialDcdTgt = ErrRPs.ErrorInfo.epochInfo.incorrPrevTrialDcdTgt;            % Previous trial true response
            ErrorInfo.epochInfo.incorrPrevTrialExpTgt = ErrRPs.ErrorInfo.epochInfo.incorrPrevTrialExpTgt;     % Previous trial expected response
        end
        
        ErrorInfo.Behav = ErrRPs.ErrorInfo.Behav;
     	ErrorInfo.EventInfo = ErrRPs.ErrorInfo.EventInfo;

        warning('Do not use signalProcess nor decoder fields from old ErrorInfo structure!!') 
        
% AFSG (2014-02-27) Do not need this since the latest ErrorInfo will be saved!!
%         % Solving problems with new params for backward compatibility
%         if isfield(ErrorInfo.epochInfo,'baselineLen')
%             if ErrorInfo.epochInfo.baselineLen == 2         % I meant 2 seconds but this values is in ms.
%                 ErrorInfo.epochInfo.baselineLen = 200;
%             end
%         else
%             ErrorInfo.epochInfo.baselineLen = 200;
%         end
%         if ~isfield(ErrorInfo.epochInfo,'rmvBaseline')
%             ErrorInfo.epochInfo.rmvBaseline = true;                % flag useful for analysis and decoding
%         end
%         if ~isfield(ErrorInfo.epochInfo,'rmvBaseDone')
%             ErrorInfo.epochInfo.rmvBaseDone    = false;               % flag to avoid removing baseline more than once. Need to add to ErrorInfo structure after loading old files
%         end
%         
%         % Solving issues with decoder params for backward compatibility
%         if ~isfield(ErrorInfo,'decoder')
%             % AFSG (2014-02-27) ErrorInfo.decoder.arrays        = {'PFC','SEF'};        % areas from which channels are selected for decoding
%             % AFSG (2014-02-27) ErrorInfo.decoder.dcdWindow     = [50 600];             % [ms ms] Data window, with zero at feedback onset, for decoder [-100 500], Start ms End from feedback onset
%             % AFSG (2014-02-27) ErrorInfo.decoder.lenEpoch      = (ErrorInfo.decoder.dcdWindow(2) - ErrorInfo.decoder.dcdWindow(1));  % ms. Length of data used for decoding
%             % AFSG (2014-02-27) ErrorInfo.decoder.baselineLen   = 200;                  % ms. length of window before feedback onset to remove baseline (its mean) from
%             % AFSG (2014-02-27) ErrorInfo.decoder.baselineDone  = false;                % logical. Flag indicating when baseline has been removed. 
%             %% Decoder structure
%             ErrorInfo.decoder.dcdType              = 'regress';            % type of decoder used 'regress', 'logitreg', 'lda'
%             ErrorInfo.decoder.trainDecoder         = true;                 % was 'loadDecoder'. Train a new decoder every time  AFSG(2014-02-26)
%             ErrorInfo.decoder.loadDecoder          = false;                % load trained decoder
%             ErrorInfo.decoder.saveDecoder          = true;                 % logical. Save latest decoder
%             ErrorInfo.decoder.oldSession           = 'CS20120912';         % was 'oldSession'. Session which has already trained decoder to be loaded (if loadDecoder is true) AFSG (2014-02-26)
%             ErrorInfo.decoder.oldDecoder           = '';                   % complete name of the decoder to use. If not, leave empty.
%             ErrorInfo.decoder.nIter                = 100;                  % number of iteration the decoder is run
%             ErrorInfo.decoder.crossValPerc         = 10;                   % Percentage of trials used to test decoder using cross-validation
%             ErrorInfo.decoder.typeVal              = 'crossval';           % type of validation. Can be leave-one-out validation ('loov'); cross-validation ('crossval'); no validation, just training ('alltrain')
%             %ErrorInfo.decoder.loov          = 1;                          % leave-one-out-validation
%             % AFSG (2014-02-27) ErrorInfo.decoder.predWindows   = [50 100;100 150;150 250;...
%             % AFSG (2014-02-27)                                     250 350;350 600]; 	% ms. Boundaries of the time sections for the predictors, which mean values will be taken from
%         end
        
        % If files do not exits, create them
    elseif ErrorInfo.epochInfo.NewErrPs
        fprintf('Could not find %s...\nRunning all channels instead...\n',loadFilename);
        [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(ErrorInfo); %#ok<ASGLU>
    else
        warning('Could not find %s\n and ''NewErrPs'' flag is set to false. No more analysis will be done!!...\n',loadFilename) %#ok<*WNTAG>
        corrEpochs = []; incorrEpochs = [];
    end
    
    %% Sampling Frequency required for spectrogram
    if ~isfield(ErrorInfo.epochInfo,'Fs')
        ErrorInfo.epochInfo.Fs = 1000;                  % Solving issues with previous files saved. Need Fs for filter
    end
end

%% Changing paths if using a diferent computer
newDirs                     = initErrDirs;              % new paths
ErrorInfo.dirs.DataIn       = newDirs.DataIn;           % place eachpath in proper field...
ErrorInfo.dirs.Code         = newDirs.Code;
ErrorInfo.dirs.DataOut      = newDirs.DataOut;
ErrorInfo.dirs.BCIparams    = newDirs.BCIparams;
ErrorInfo.dirs.PTB          = newDirs.PTB;
ErrorInfo.dirs.saveFilename = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session);

%% Loading eye traces
if ErrorInfo.eyeTraces.doEyes
    % Complete name of eye traces to be loaded
    loadEyeFilename = sprintf('%s-corrIncorrEyeTrace-[%i-%ims].mat',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime);
    % If file exist, just load it
    if exist(loadEyeFilename,'file')
        fprintf('Patience...loading epoched eye traces %s\n',loadEyeFilename);
        eyeTraces = load(loadEyeFilename);
        % If eyeTraces file does not exist, get it
    else
        fprintf('Could not find %s...\nReading and epoching all eye traces instead...\n',loadEyeFilename);
        [eyeTraces,ErrorInfo] = getEyeTraces(ErrorInfo); 
        % Load and run analysis on eye traces (i.e. pupilometry for performance monitoring)
    end
else
    eyeTraces = [];
end
