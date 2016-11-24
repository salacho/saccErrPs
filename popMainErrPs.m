function popMainErrPs(sessionList)
%
%
%
%
%
%
%
%
% 20 Nov 2014

clear all, close all, clc, subject = 'jonah';
%[chicoManSortedSessions,jonahManSortedSessions] = manSortedSessions;
%sessionList = sfnSAbstractSessionList('chico');
%sessionList = chicoBCIsessions;
%sessionList = jonahBCIsessions;

%% Population
% Get all correct and incorrect epochs
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
loadEpochs = 1;

if strcmpi(subject(1),'c')
    sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
else
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
end

% ErrorInfo.session = sprintf('pop%s-%s-%i',char(sessionList(1)),char(sessionList(end)),length(sessionList));
% ErrorInfo = setDefaultParams(session,dirs);

% Extract or load popEpochs
if ~loadEpochs, 
    [popCorr,popIncorr,popErrorInfo] = popGetEpochs(sessionList);      % CHECK!
else
    if strcmpi(subject(1),'c')
        disp('Loading popEpochs for Chico...')
        load('E:\Data\saccErrP\popAnalysis\popCS20121012-CS20121026-11-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
        popErrorInfo.subject = 'chico';
    else
        disp('Loading popEpochs for Jonah...')
        load('E:\Data\saccErrP\popAnalysis\popJS20140318-JS20140328-9-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
        popErrorInfo.subject = 'jonah';
    end
end

%% Down sample data!!
if ~isfield(popErrorInfo.epochInfo,'nCorrBad')
    popErrorInfo.signalProcess.downSampFactor = 10;
    [popCorr,popIncorr,ErrorInfo] = popDownSamp(popCorr,popIncorr,popErrorInfo);
end
if popErrorInfo.epochInfo.epochLen == 1200;
    popErrorInfo.epochInfo.epochLen = 120;
end

%% Separate in 6 targets
% [meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,ErrorInfo]
%[popTgtErrPs,popDcdTgt] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popDcdTgt);
[popTgtErrPs,popTgt2DistEpochs,meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popErrorInfo);


% %% Save files
% tgt2DistSavefilename = 'E:\Data_20160505\dlysac\ErrRPs\popAnalysis\popJS20140318-JS20140328-9-corrIncorr-Tgt2DistEpochs-downSamp1[600-600ms]-butt4[1.0-10Hz].mat';
% save(tgt2DistSavefilename,'popTgtErrPs','popTgt2DistEpochs','meanPopTgt','meanPopDist2Tgt','stdPopDist2Tgt','ErrorInfo','popDcdTgt','sessionList','-v7.3');

%% Get epochs for both options in previous trial outcome (correct and
% incorrect)
[corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,popErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(popCorr,popIncorr,popErrorInfo);

% Get dist2Tgt after having 6 target files
popErrorInfo.epochInfo.nTgts = 6;
[popDist2Tgt,numSampErrTrials] = getTgt2DistEpochs(popTgtErrPs,popErrorInfo);

% Get Dist2Epoch from scratch
% [popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt] = popGetDist2Tgt(sessionList);
% Get explained variance
% popGetExpVar(popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt,sessionList);

% Get explained variance correct and incorrect trials
popErrorInfo.analysis.balanced = 1;
popErrorInfo.analysis.typeVble = 'popCorrIncorr';
[expVar,n,pVals,mu,F,popErrorInfo] = getEpochsExpVar(popCorr,popIncorr,popErrorInfo);

%% Plot them
% popErrorInfo = ErrorInfo;
% ErrorInfo.epochInfo = popErrorInfo.epochInfo;
% ErrorInfo.analysis = popErrorInfo.analysis;
% ErrorInfo.analysis.ANOVA.pValCrit = 0.01;
% ErrorInfo.epochInfo.epochLen = 120;
popErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},numel(sessionList));
popErrorInfo.dirs.DataOut = 'E:\Data\saccErrP\';
popErrorInfo.dirs.saveFilename = 'E:\Data\saccErrP\popAnalysis';
plotEpochsExpVar(expVar,pVals,popErrorInfo)
plotEpochsPval(expVar,pVals,popErrorInfo)

%% Explained variance per target for correct and error epochs
popErrorInfo.epochInfo.epochLen = 120; %size(popCorr,3);
popErrorInfo.analysis.balanced = 1;
[expVarTgt,nTgt,pValsTgt,muTgt,fTgt,popErrorInfo] = getTgtExpVar(popTgtErrPs,popErrorInfo); %ErrorInfo);

%% Plotting Tgt Explained Variance per channel
% ErrorInfoNew = setDefaultParams(sessionList{1},dirs);
% ErrorInfo.dirs = ErrorInfoNew.dirs;
% ErrorInfo.dirs.saveFilename = 'E:\Data_20160505\dlysac\ErrRPs\popAnalysis';
popErrorInfo.session = sprintf('pop%s-%i',sessionList{1}(1:6),numel(sessionList));
popErrorInfo.epochInfo.Tgts = 1:6;
% ErrorInfo.epochInfo.preOutcomeTime = 600;
% ErrorInfo.epochInfo.postOutcomeTime = 600;
% ErrorInfo.plotInfo.visible = 'on';
% ErrorInfo.analysis.ANOVA.pValCrit = 0.01;
% ErrorInfo.epochInfo.nTgts = 6;
% ErrorInfo.plotInfo = ErrorInfoNew.plotInfo;
% ErrorInfo.epochInfo.filtLowBound = 1;%ErrorInfoNew.epochInfo.filtLowBound;
% ErrorInfo.epochInfo.filtHighBound = 10;%ErrorInfoNew.epochInfo.filtHighBound;

plotEpochsTgtExpVar(expVarTgt,pValsTgt,popErrorInfo)
plotEpochsTgtPVal(expVarTgt,pValsTgt,popErrorInfo)
%close all

%% Exp.Var. previous trial outcome for correct and incorrect trials

% 1000 iter
subject = 'chico';
plot_groupIterPrevTrialOutcm(subject)

% Correct
[expVarCorr,nCorr,pValsCorr,muCorr,FCorr,popErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,popErrorInfo);
% Incorrect
[expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,popErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,popErrorInfo);

%% Plot
% Plot normalized number of incorrect trials trials
popPlotChicoJonahErrNormNumTrialsPerTgt

% Plot number of incorrect trials per target
% Get number of incorrect trials per target
[popNumTrialsPerTgt,popNumTrialsPerDist2Tgt,ErrorInfo] = popGetErrNumTrialsPerTgt(sessionList);
popPlotMeanStDevErrNumTrialsPerTgt(sessionsList,popNumTrialsPerTgt,popNumTrialsPerDist2Tgt,ErrorInfo);
popPlotMeanStDevErrNumTrialsPerTgt(sessionList,popNumTrialsPerDist2Tgt,ErrorInfo)

% Plot 6 tgt traces for population means 
ErrorInfo = popErrorInfo;
popPlotDist2_6TgtMeanErrorBars(meanPopDist2Tgt,stdPopDist2Tgt,sessionList,popErrorInfo)

%% Get all dist2Tgt from all targets together
popDist2Tgt = popTgt2DistEpochs; clear popTgt2DistEpochs
popDist2TgtAll = popDist2Tgt_allTgtTogether(popDist2Tgt);
[meanPopDist2Tgt,stdPopDist2Tgt] = popDist2Tgt_getMeanStD(popCorr,popDist2TgtAll);

%% PLot dist2Tgt all per array
popErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end}(7:end),numel(sessionList));
plotPopDist2TgtAll_array(meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo)

%% Explained variance for Previous Trial Outcome effect
% Correct
popErrorInfo.analysis.typeVble = 'correct';
plotExpVarPrevTrialOutcome(expVarCorr,pValsCorr,popErrorInfo) 
plotPvalPrevTrialOutcome(expVarCorr,pValsCorr,popErrorInfo) 
% Incorrect
popErrorInfo.analysis.typeVble = 'incorrect';
plotExpVarPrevTrialOutcome(expVarIncorr,pValsIncorr,popErrorInfo) 
plotPvalPrevTrialOutcome(expVarIncorr,pValsIncorr,popErrorInfo) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  POPULATION SPECTROGRAM   %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Sum the spectrograms for Jonah %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, clc ,close all
sessionsListJ = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.

dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
popCorrSpec = zeros(45,103,96);               % [time, freq, chs]
popIncorrSpec = zeros(45,103,96);             % [time, freq, chs]
popErrorInfo.nCorrBad = 0;          popErrorInfo.nIncorrBad = 0;
popErrorInfo.nCorr = 0;             popErrorInfo.nIncorr = 0;
popErrorInfo.nCorr_CorrPrev = 0;    popErrorInfo.nCorr_IncorrPrev = 0;
popErrorInfo.nIncorr_CorrPrev = 0;  popErrorInfo.nIncorr_IncorrPrev = 0;

for iSess = 1:length(sessionsListJ)
    % load sessions
    session = sessionsListJ{iSess};
    loadfilename = sprintf('%s-%s',fullfile(dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);
    % num trials
    popErrorInfo.nCorr = popErrorInfo.nCorr + size(corrSpec,3);
    popErrorInfo.nIncorr = popErrorInfo.nIncorr + size(incorrSpec,3);
    % sum epochs
    popCorrSpec = popCorrSpec + squeeze(sum(corrSpec,3));
    popIncorrSpec = popIncorrSpec + squeeze(sum(incorrSpec,3));
    
    popErrorInfo.ErrorInfo{iSess} = ErrorInfo;
    popErrorInfo.nCorrBad = popErrorInfo.nCorrBad + ErrorInfo.epochInfo.nCorrBad;
    popErrorInfo.nIncorrBad = popErrorInfo.nIncorrBad + ErrorInfo.epochInfo.nErrorBad;
    popErrorInfo.nCorr_CorrPrev = popErrorInfo.nCorr_CorrPrev +     ErrorInfo.epochInfo.nCorrEpochCorrPrevTrial;
    popErrorInfo.nCorr_IncorrPrev = popErrorInfo.nCorr_IncorrPrev + ErrorInfo.epochInfo.nCorrEpochErrPrevTrial;
    popErrorInfo.nIncorr_CorrPrev = popErrorInfo.nIncorr_CorrPrev + ErrorInfo.epochInfo.nIncorrEpochCorrPrevTrial;
    popErrorInfo.nIncorr_IncorrPrev = popErrorInfo.nIncorr_IncorrPrev + ErrorInfo.epochInfo.nIncorrEpochErrPrevTrial;
end
popMeanCorrSpec = popCorrSpec/popErrorInfo.nCorr;
popMeanIncorrSpec = popIncorrSpec/popErrorInfo.nIncorr;

% Plot params for ErrDiff
ErrorInfo.plotInfo = ErrorInfo.plotInfo;
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
popErrorInfo.plotInfo = ErrorInfo.plotInfo;

popErrorInfo.dirs = ErrorInfo.dirs;
popErrorInfo.session = sprintf('pop%s-%s-%i',sessionsListJ{1},sessionsListJ{end}(7:end),numel(sessionsListJ));
ErrorInfo.session = popErrorInfo.session;
savePopSpecName = fullfile(popErrorInfo.dirs.DataOut,'popAnalysis',sprintf('%s-meanSpec.mat',popErrorInfo.session));
save(savePopSpecName,'popMeanCorrSpec','popMeanIncorrSpec','popCorrSpec','popIncorrSpec','sessionsListJ','popErrorInfo','ErrorInfo')

%% Plot spectrogram
fprintf('Running spectrograms...\n')
plotPopMeanSpecgram(popMeanCorrSpec,popMeanIncorrSpec,ErrorInfo)
% plot all channels using the same CLIMS across ALL arrays!
popErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
plotPopMeanSpecgram_sameClims_allArray(popMeanCorrSpec,popMeanIncorrSpec,ErrorInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Sum the spectrograms for Chico %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all, clc

sessionsListC = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.

dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
popCorrSpec = zeros(45,103,96);               % [time, freq, chs]
popIncorrSpec = zeros(45,103,96);             % [time, freq, chs]
popErrorInfo.nCorrBad = 0;          popErrorInfo.nIncorrBad = 0;
popErrorInfo.nCorr = 0;             popErrorInfo.nIncorr = 0;
popErrorInfo.nCorr_CorrPrev = 0;    popErrorInfo.nCorr_IncorrPrev = 0;
popErrorInfo.nIncorr_CorrPrev = 0;  popErrorInfo.nIncorr_IncorrPrev = 0;

for iSess = 1:length(sessionsListC)
    % load sessions
    session = sessionsListC{iSess};
    loadfilename = sprintf('%s-%s',fullfile(dirs.DataOut,session,session),'spec.mat');
    fprintf('Loading %s...\n',loadfilename)
    load(loadfilename);
    % num trials
    popErrorInfo.nCorr = popErrorInfo.nCorr + size(corrSpec,3);
    popErrorInfo.nIncorr = popErrorInfo.nIncorr + size(incorrSpec,3);
    % sum epochs
    popCorrSpec = popCorrSpec + squeeze(sum(corrSpec,3));
    popIncorrSpec = popIncorrSpec + squeeze(sum(incorrSpec,3));
    
    popErrorInfo.ErrorInfo{iSess} = ErrorInfo;
    popErrorInfo.nCorrBad = popErrorInfo.nCorrBad + ErrorInfo.epochInfo.nCorrBad;
    popErrorInfo.nIncorrBad = popErrorInfo.nIncorrBad + ErrorInfo.epochInfo.nErrorBad;
    popErrorInfo.nCorr_CorrPrev = popErrorInfo.nCorr_CorrPrev +     ErrorInfo.epochInfo.nCorrEpochCorrPrevTrial;
    popErrorInfo.nCorr_IncorrPrev = popErrorInfo.nCorr_IncorrPrev + ErrorInfo.epochInfo.nCorrEpochErrPrevTrial;
    popErrorInfo.nIncorr_CorrPrev = popErrorInfo.nIncorr_CorrPrev + ErrorInfo.epochInfo.nIncorrEpochCorrPrevTrial;
    popErrorInfo.nIncorr_IncorrPrev = popErrorInfo.nIncorr_IncorrPrev + ErrorInfo.epochInfo.nIncorrEpochErrPrevTrial;
end
popMeanCorrSpec = popCorrSpec/popErrorInfo.nCorr;
popMeanIncorrSpec = popIncorrSpec/popErrorInfo.nIncorr;

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
popErrorInfo.plotInfo = ErrorInfo.plotInfo;

popErrorInfo.dirs = ErrorInfo.dirs;
popErrorInfo.session = sprintf('pop%s-%s-%i',sessionsListC{1},sessionsListC{end}(7:end),numel(sessionsListC));
ErrorInfo.session = popErrorInfo.session;
savePopSpecName = fullfile(popErrorInfo.dirs.DataOut,'popAnalysis',sprintf('%s-meanSpec.mat',popErrorInfo.session));
save(savePopSpecName,'popMeanCorrSpec','popMeanIncorrSpec','popCorrSpec','popIncorrSpec','sessionsListC','popErrorInfo','ErrorInfo')

%% Plot spectrogram
fprintf('Running spectrograms...\n')
popErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
plotPopMeanSpecgram(popMeanCorrSpec,popMeanIncorrSpec,ErrorInfo)
% plot all channels using the same CLIMS across ALL arrays!
popErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
plotPopMeanSpecgram_sameClims_allArray(popMeanCorrSpec,popMeanIncorrSpec,ErrorInfo)

end
