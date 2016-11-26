function thesisData2Spectrograms
%
%
%
%
%
% clear all, clc, close all

switch subjName
    case 'chico', 
        sessionsListC = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
    case 'jonah', 
        sessionsListJ = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
end


cSessions = {'CS20140303';%'CS20140304';
'CS20140317';
'CS20140318';
'CS20140319';
'CS20140320';
'CS20140321';
'CS20140324';
'CS20140325';
'CS20140326';
'CS20140327';
'CS20140328'};

jSessions = {'JS20140318';
'JS20140319';
'JS20140320';
'JS20140321';
'JS20140324';
'JS20140325';
'JS20140326';
'JS20140327';
'JS20140328'};       % 'JS20140407';       % not converted  'JS20140408';       % not converted   'JS20140409';       % not converted    'JS20140410';       % not converted
%'JS20140411'};       % bad file. Not converted

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%       GET EPOCHS FOR SPECTROGRAMS     %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Chico

sessionsListC = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
sessionsListJ = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.

dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
for iSess = 1:length(sessionsListC)     %cSessions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListC{iSess};     %cSessions
    ErrorInfo = setDefaultParams(session,dirs);
    ErrorInfo.eyeTraces.doEye = 1;
    [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(ErrorInfo);
end    
    
%% Jonah
dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
for iSess = 14:length(sessionsListJ)        % jSessions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListJ{iSess};         % jSessions
    ErrorInfo = setDefaultParams(session,dirs);
    ErrorInfo.eyeTraces.doEye = 1;
    [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(ErrorInfo);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%              GET SPECTROGRAMS         %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iSess = 1:length(sessionsListC)
    dirs = initErrDirs('getSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListC{iSess};
    ErrorInfo = setDefaultParams(session,dirs);
    
    %% Load 1-10Hz already saved LFP epochs
    % Used 1-10Hz data to get labels for bad trials
    ErrorInfo.epochInfo.freqRange           = [1 10];   % [0.6 14] % low and high freq. values to filter data
    ErrorInfo.epochInfo.filtType            = 'butter'; % string. name of filr used by function 'setFilterParams.m' in 'getErrRPs.m'
    ErrorInfo.epochInfo.filtOrder           = 4;        % set filter order
    ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
    ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
    ErrorInfo.epochInfo.typeRef             = 'lfp';    % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
    ErrorInfo.epochInfo.itiExtraTime        = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
    ErrorInfo.epochInfo.baselineLen         = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
    ErrorInfo.epochInfo.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.postOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
    [corrEpochsRaw,incorrEpochsRaw,~,ErrorInfo10Hz] = loadErrRPs(ErrorInfo);
    
     %% Need to remove bad trials!!
    ErrorInfo10Hz.epochInfo.badChStDevFactor    = 3;
    %[corrEpochs10Hz,incorrEpochs10Hz,ErrorInfo10Hz] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo10Hz);
    [~,~,ErrorInfo10Hz] = removeBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo10Hz);
    
    %% Load 0-200Hz LFP epochs
    dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    % Update to lad 600-600 data
    ErrorInfo.epochInfo.freqRange           = [0 200];   % [0.6 14] % low and high freq. values to filter data
    ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
    ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
    ErrorInfo.epochInfo.preOutcomeTime      = 400;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.postOutcomeTime     = 1000;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.epochLen            = ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime;
    [corrEpochsRaw,incorrEpochsRaw,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Update ErrorInfo from 10Hz to remove bad trials
    [corrEpochs,incorrEpochs,ErrorInfo] = updateErrorInfo2ReplaceBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo,ErrorInfo10Hz);
    
    %% Choosing ErrRPs per target location to see any target bias
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    

%     % For quality purposes
%     ratioCorrIncorrC{iSess} = ErrorInfo.epochInfo.ratioCorrIncorr;
%     TgtsC{iSess} = ErrorInfo.epochInfo.Tgts;
% end
    
    % Fix incorrect indexing for target params
    %ErrorInfo = fixTgts(ErrorInfo,tgtErrRPs);
    
    %% Corr and Incorr epochs based on previous trial outcome
    [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
        getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Choosing ErrRPs by distance to true target location
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
    % Group all dist2tgt regarless of true target location
    [dist1Epochs,dist2Epochs,dist3Epochs,distDcdTgt] = getDist2Tgt(tgt2DistEpochs,ErrorInfo);
    
    %% Amp max and min per trials and channel
    [ampDecoding,~,~] = getDist2TgtMaxMinAmp(tgt2DistEpochs,tgtErrRPs,ErrorInfo);
    
    %plotPredictorsDist2Tgt(ampDecoding,ErrorInfo)
    
    %% Laterality analysis
    [latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>
    
    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);
    
    %% Get ErrRPs spectrogram
    % Calculate spectrogram

    [corrSpec,incorrSpec,ErrorInfo] = getErrRPsSpecgram(ErrorInfo,corrEpochs,incorrEpochs);

    %% Save spec
    savefilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.saveFilename,session),'spec.mat');
    save(savefilename,'corrSpec','incorrSpec','ErrorInfo','session','-v7.3')
    
    clear corrSpec incorrSpec corrEpochs incorrEpochs
end

%% Jonah
for isess = 1:length(sessionsListJ)
    dirs = initErrDirs('getSpecJonah');                         % paths where all data is loaded from and where chronic recordings analysis are saved
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListJ{isess};
    ErrorInfo = setDefaultParams(session,dirs);
    
    %% load 1-10hz already saved lfp epochs
    % used 1-10hz data to get labels for bad trials
    ErrorInfo.epochInfo.freqRange           = [1 10];   % [0.6 14] % low and high freq. values to filter data
    ErrorInfo.epochInfo.filtType            = 'butter'; % string. name of filr used by function 'setFilterParams.m' in 'getErrRPs.m'
    ErrorInfo.epochInfo.filtOrder           = 4;        % set filter order
    ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
    ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
    ErrorInfo.epochInfo.typeRef             = 'lfp';    % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
    ErrorInfo.epochInfo.itiExtraTime        = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
    ErrorInfo.epochInfo.baselineLen         = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
    ErrorInfo.epochInfo.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.postOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
    [corrEpochsRaw,incorrEpochsRaw,~,ErrorInfo10Hz] = loadErrRPs(ErrorInfo);
    
     %% Need to remove bad trials!!
    ErrorInfo10Hz.epochInfo.badChStDevFactor    = 3;
    %[corrEpochs10Hz,incorrEpochs10Hz,ErrorInfo10Hz] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo10Hz);
    [~,~,ErrorInfo10Hz] = removeBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo10Hz);
    
    %% Load 0-200Hz LFP epochs
    dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    % Update to lad 600-600 data
    ErrorInfo.epochInfo.freqRange           = [0 200];   % [0.6 14] % low and high freq. values to filter data
    ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
    ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
    ErrorInfo.epochInfo.preOutcomeTime      = 400;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.postOutcomeTime     = 1000;      % ms. pre-outcome stimuli presentation time (ms)
    ErrorInfo.epochInfo.epochLen            = ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime;
    [corrEpochsRaw,incorrEpochsRaw,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Update ErrorInfo from 10Hz to remove bad trials
    [corrEpochs,incorrEpochs,ErrorInfo] = updateErrorInfo2ReplaceBadTrials(corrEpochsRaw,incorrEpochsRaw,ErrorInfo,ErrorInfo10Hz);
    
    %% Choosing ErrRPs per target location to see any target bias
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);

%     % For quality purposes
%     ratioCorrIncorrJ{iSess} = ErrorInfo.epochInfo.ratioCorrIncorr;
%     TgtsJ{iSess} = ErrorInfo.epochInfo.Tgts;
% end

    % Fix incorrect indexing for target params
    %ErrorInfo = fixTgts(ErrorInfo);

    %% Corr and Incorr epochs based on previous trial outcome
    [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
        getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Choosing ErrRPs by distance to true target location
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
    % Group all dist2tgt regarless of true target location
    [dist1Epochs,dist2Epochs,dist3Epochs,distDcdTgt] = getDist2Tgt(tgt2DistEpochs,ErrorInfo);
    
    %% Amp max and min per trials and channel
    [ampDecoding,~,~] = getDist2TgtMaxMinAmp(tgt2DistEpochs,tgtErrRPs,ErrorInfo);
    
    %plotPredictorsDist2Tgt(ampDecoding,ErrorInfo)
    
    %% Laterality analysis
    [latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>
    
    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);
    
    %% Get ErrRPs spectrogram
    % Calculate spectrogram

    [corrSpec,incorrSpec,ErrorInfo] = getErrRPsSpecgram(ErrorInfo,corrEpochs,incorrEpochs);

    %% Save spec
    savefilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.saveFilename,session),'spec.mat');
    save(savefilename,'corrSpec','incorrSpec','ErrorInfo','session','-v7.3')
    
    clear corrSpec incorrSpec corrEpochs incorrEpochs
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%          PLOT SPECTROGRAMS          %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, clc ,close all
sessionsListC = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
sessionsListJ = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.

dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
% chico
for iSess = 1:length(sessionsListC)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListC{iSess};
    ErrorInfo = setDefaultParams(session,dirs);

    %% load spec
    loadfilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);

    % Plot params for ErrDiff
    ErrorInfo.plotInfo.specgram.doColorbar = 0;
    ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting
    ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting
    ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
    ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot
    %ErrorInfo.plotInfo.specgram.freqs       = [0 10;10 15;10 30;30 40;40 60;30 60;60 100];      % range (lower/upper) of frequencies to plot
    ErrorInfo.plotInfo.specgram.freqs       = [0 10;0 30;0 70;10 40;20 60;30 70;30 100;60 100;60 200;100 200];      % range (lower/upper) of frequencies to plot
    ErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
    % Only plot ErrDiff
    ErrorInfo.plotInfo.specgram.doCorr = 1;
    
    %% Plot spectrogram
    fprintf('Running spectrograms...\n')
    plotMeanSpecgram(corrSpec,incorrSpec,ErrorInfo)
    %     % Mean vals/vars
    %     meanCorrSpec = squeeze(nanmean(corrSpec,3));
    %     meanIncorrSpec = squeeze(nanmean(incorrSpec,3));
    %     tSpec = ErrorInfo.specParams.tSpec;
    %     fSpec = ErrorInfo.specParams.fSpec;
    %     iStart = 1;
    %     iEnd = 15;
    %     for ii=1:96,
    %         data2plot = db(squeeze(meanIncorrSpec(:,iStart:iEnd,ii)-meanCorrSpec(:,iStart:iEnd,ii))');
    %         imagesc(tspec-0.6,fspec(iStart:iEnd),data2plot), set(gca,'ydir','normal'),
    %         title(ii), pause,
    %     end
end

% Jonah
for iSess = 1:length(sessionsListJ)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    session = sessionsListJ{iSess};
    ErrorInfo = setDefaultParams(session,dirs);

    %% load spec
    loadfilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);

    % Plot params for ErrDiff
    ErrorInfo.plotInfo.specgram.doColorbar = 0;
    ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting
    ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting
    ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
    ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot
    %ErrorInfo.plotInfo.specgram.freqs       = [0 10;10 15;10 30;30 40;40 60;30 60;60 100];      % range (lower/upper) of frequencies to plot
    ErrorInfo.plotInfo.specgram.freqs       = [0 10;0 30;0 70;10 40;20 60;30 70;30 100;60 100;60 200;100 200];      % range (lower/upper) of frequencies to plot
    ErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
    % Only plot ErrDiff
    ErrorInfo.plotInfo.specgram.doCorr = 1;
    
    %% Plot spectrogram
    fprintf('Running spectrograms...\n')
    plotMeanSpecgram(corrSpec,incorrSpec,ErrorInfo)
    %     % Mean vals/vars
    %     meanCorrSpec = squeeze(nanmean(corrSpec,3));
    %     meanIncorrSpec = squeeze(nanmean(incorrSpec,3));
    %     tSpec = ErrorInfo.specParams.tSpec;
    %     fSpec = ErrorInfo.specParams.fSpec;
    %     iStart = 1;
    %     iEnd = 15;
    %     for ii=1:96,
    %         data2plot = db(squeeze(meanIncorrSpec(:,iStart:iEnd,ii)-meanCorrSpec(:,iStart:iEnd,ii))');
    %         imagesc(tspec-0.6,fspec(iStart:iEnd),data2plot), set(gca,'ydir','normal'),
    %         title(ii), pause,
    %     end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%              FREQUENCY BANDS          %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%
% Chico
%%%%%%%%%%%%%%%
clear all, clc, close all

sessionsListC = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
freqBands = [1 4;4 8;8 13;13 30;30 80;80 200];

popCorrFreqBand = [];
popIncorrFreqBand = [];
for iSess = 1:length(sessionsListC)
    session = sessionsListC{iSess};
    ErrorInfo = setDefaultParams(session,dirs);

    % load spec
    loadfilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);

    % Extract freq bands
    ErrorInfo.plotInfo.specgram.freqs       = freqBands;      % range (lower/upper) of frequencies to plot
    [corrFreqBand,incorrFreqBand] = getFreqBands(corrSpec,incorrSpec,ErrorInfo);
    
    % Append vals for each session
    popCorrFreqBand = cat(3,popCorrFreqBand,corrFreqBand);
    popIncorrFreqBand= cat(3,popIncorrFreqBand,incorrFreqBand);
end
% save freqbands
ErrorInfo.session = sprintf('pop%s-%s-%i',sessionsListC{1},sessionsListC{end}(7:end),numel(sessionsListC));
saveFreqbandName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),'freqBands.mat');
save(saveFreqbandName,'popCorrFreqBand','popIncorrFreqBand','ErrorInfo','freqBands','sessionsListC')

%%%%%%%%%%%%%%%
% Jonah
%%%%%%%%%%%%%%%
clear all, clc, close all

sessionsListJ = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
freqBands = [1 4;4 8;8 13;13 30;30 80;80 200];

popCorrFreqBand = [];
popIncorrFreqBand = [];
for iSess = 1:length(sessionsListJ)
    session = sessionsListJ{iSess};
    ErrorInfo = setDefaultParams(session,dirs);

    % load spec
    loadfilename = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);

    % Extract freq bands
    ErrorInfo.plotInfo.specgram.freqs       = freqBands;      % range (lower/upper) of frequencies to plot
    [corrFreqBand,incorrFreqBand] = getFreqBands(corrSpec,incorrSpec,ErrorInfo);
    
    % Append vals for each session
    popCorrFreqBand = cat(3,popCorrFreqBand,corrFreqBand);
    popIncorrFreqBand= cat(3,popIncorrFreqBand,incorrFreqBand);
end
% save freqbands
ErrorInfo.session = sprintf('pop%s-%s-%i',sessionsListJ{1},sessionsListJ{end}(7:end),numel(sessionsListJ));
saveFreqbandName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),'freqBands.mat');
save(saveFreqbandName,'popCorrFreqBand','popIncorrFreqBand','ErrorInfo','freqBands','sessionsListJ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot freq.bands 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ErrorInfo.plotInfo.specgram.doColorbar = 0;
ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot

freqBands = [1 4;4 8;8 13;13 30;30 80;80 200];
errDiffFreqTxt = {'delta','theta','alpha','beta','gamma','highGam'};

errDiffFreqBand = (squeeze(nanmean(popIncorrFreqBand,3)) - squeeze(nanmean(popCorrFreqBand,3)));
% plot spec freq. bands.
% db
ErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
popPlotFreqBands(errDiffFreqBand,freqBands,errDiffFreqTxt,ErrorInfo)
% none
ErrorInfo.plotInfo.specgram.transfType  = 'none';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
popPlotFreqBands(errDiffFreqBand,freqBands,errDiffFreqTxt,ErrorInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Freq. band two sample T-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ErrorInfo.analysis.balanced = 1;
[expVarFreq,nFreq,pValsFreq,muFreq,FFreq,ErrorInfo] = getFreqBandT_test(popCorrFreqBand,popIncorrFreqBand,ErrorInfo);

% save freqbands
saveFreqbandName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),'Ttest_freqBands.mat');
save(saveFreqbandName,'expVarFreq','nFreq','pValsFreq','muFreq','FFreq','ErrorInfo')

popPlotTtest_FreqBands(expVarFreq,pValsFreq,errDiffFreqTxt,ErrorInfo)
popPlotTtest_FreqBands_bonferroniCorrected(expVarFreq,pValsFreq,errDiffFreqTxt,ErrorInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Amplitude-amplitude cross-frequency coupling %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nTimes = size(popCorrFreqBand,1);
specTimeStart = -ErrorInfo.epochInfo.preOutcomeTime/1000 + ErrorInfo.specParams.movingWin(1)/2;
timeRange = ErrorInfo.epochInfo.postOutcomeTime/1000 + ErrorInfo.epochInfo.preOutcomeTime/1000; 
timeVector = 0:ErrorInfo.specParams.movingWin(2):timeRange;
timeVector = specTimeStart + timeVector(1:nTimes);
[~,fdbackStart] = min(abs(timeVector));

% Compute cross-coherence
preCorrXcorrFreqBand = crossCorrFreqBand(popCorrFreqBand(1:fdbackStart,:,:,:));
preIncorrXcorrFreqBand = crossCorrFreqBand(popIncorrFreqBand(1:fdbackStart,:,:,:));
postCorrXcorrFreqBand = crossCorrFreqBand(popCorrFreqBand(fdbackStart:end,:,:,:));
postIncorrXcorrFreqBand = crossCorrFreqBand(popIncorrFreqBand(fdbackStart:end,:,:,:));

if any((ErrorInfo.session(1:4) == 'J')), sessionList = sessionsListJ;
else sessionList = sessionsListC;
end

saveCrossFreqName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),'crossFreqCoupling.mat');
save(saveCrossFreqName,'preIncorrXcorrFreqBand','postIncorrXcorrFreqBand','preCorrXcorrFreqBand','postCorrXcorrFreqBand','errDiffFreqTxt','ErrorInfo','sessionList')

%%%%%%% Error subtracting pre and post. What about negative values that are subtracted? %%%%%%%
%
% ErrorInfo.plotInfo.dataPeriod = 'postErrDiff';
% plotCrossCorrFreqBand(postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo,PosNegVals)
% 
% ErrorInfo.plotInfo.dataPeriod = 'preErrDiff';
% plotCrossCorrFreqBand(preIncorrXcorrFreqBand,preCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo,PosNegVals)        
% 
% ErrorInfo.plotInfo.dataPeriod = 'postPreIncorr';
% plotCrossCorrFreqBand(postIncorrXcorrFreqBand,preIncorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo,PosNegVals)
%
%%%%%%% Error subtracting pre and post. What about negative values that are subtracted? %%%%%%%

% ErrorInfo.plotInfo.dataPeriod = 'postIncorr-postCorr';
% ErrorInfo.plotInfo.legendTxt = {'postIncorr','postCorr'};
% plotCrossCorrFreqBand_both(postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% 
% ErrorInfo.plotInfo.dataPeriod = 'preIncorr-preCorr';
% ErrorInfo.plotInfo.legendTxt = {'preIncorr','preCorr'};
% plotCrossCorrFreqBand_both(preIncorrXcorrFreqBand,preCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% 
% ErrorInfo.plotInfo.dataPeriod = 'preIncorr-postIncorr';
% ErrorInfo.plotInfo.legendTxt = {'preIncorr','postIncorr'};
% plotCrossCorrFreqBand_both(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% 
% ErrorInfo.plotInfo.dataPeriod = 'preCorr-postCorr';
% ErrorInfo.plotInfo.legendTxt = {'preCorr','postCorr'};
% plotCrossCorrFreqBand_both(preCorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)

ErrorInfo.plotInfo.dataPeriod = 'postCorr-preIncorr-postIncorr';
ErrorInfo.plotInfo.legendTxt = {'postCorr','preIncorr','postIncorr'};
plotCrossCorrFreqBand_three(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)

%% True results comparison
errDiffFreqTxt = {'delta','theta','alpha','beta','gamma','highGam'};
ErrorInfo.plotInfo.dataPeriod = 'postCorr-preIncorr-postIncorr';
ErrorInfo.plotInfo.legendTxt = {'postCorr','preIncorr','postIncorr'};

for iCoupling =1:numel(errDiffFreqTxt)
    CouplingBand = errDiffFreqTxt{iCoupling};
    plotCrossCorrFreqBand_three_1Freq(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,postCorrXcorrFreqBand,...
        errDiffFreqTxt,ErrorInfo,CouplingBand)
end

%%%% TRUE PLOT OF DIFFERENCES!!!
plotCrossCorrFreqBand_ErrDiffpostPreDiff(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,preCorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1000 iter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in cluster run 1000 times
subject = 'jonah';
pop_iterCrossFreqAmpTtest(iIter,subject)
% aggregate results
pop_groupIterCrossFreqCoupling_fileExist(subject)
% load aggregated iters
if strcmp(subject,'chico')
    load('E:\Data\saccErrP\popAnalysis\24Nov2016_rng_1000Iter\popCS20121012-1026-11_iterCrossFreqCoupling-allIter-rndShuffle.mat')
else
    load('E:\Data\saccErrP\popAnalysis\24Nov2016_rng_1000Iter\popJS20140318-0328-9_iterCrossFreqCoupling-allIter-rndShuffle.mat')
end
% plot average across iter
plotCrossCorrFreqBand_ErrDiffpostPreDiff_aveGroup1000Iter(preIncorrXcorrFreqBand_allIter,postIncorrXcorrFreqBand_allIter,preCorrXcorrFreqBand_allIter,postCorrXcorrFreqBand_allIter,errDiffFreqTxt,ErrorInfo)

end
