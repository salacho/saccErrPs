function thesis_meanEpochs
%
%
%
%
%
%
%
clear all, close all, clc
sbj = 'chico';          % 'jonah'

%% Paths and folders
dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved

%% Select subject list
if strcmp(sbj,'chico')  %% Chico
    sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
else    %% Jonah
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
end

%% Load data
iSess = 1;

session = sessionList{iSess};
ErrorInfo = setDefaultParams(session,dirs);

% Update to lad 600-600 data
ErrorInfo.epochInfo.freqRange           = [1 10];   % [0.6 14] % low and high freq. values to filter data
ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
ErrorInfo.epochInfo.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.postOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.epochLen            = ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime;
ErrorInfo.eyeTraces.doEyes              = 0;
 
% Load already saved LFP epochs and spikes
[corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);

%% Check for noisy trials and channels
ErrorInfo.signalProcess.ch2StDevAbove = plotChsVariability(corrEpochs,incorrEpochs,ErrorInfo);

if ErrorInfo.epochInfo.rmvNoisyErrP
    [corrEpochs,incorrEpochs,ErrorInfo] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo);
end
if ErrorInfo.epochInfo.rmvNoisyChsDone
    [corrEpochs,incorrEpochs,ErrorInfo] = removeNoisyChs(corrEpochs,incorrEpochs,ErrorInfo);
end

%% Choosing ErrRPs per target location to see any target bias
[tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);

%% Corr and Incorr epochs based on previous trial outcome
[corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);

%% Choosing ErrRPs by distance to true target location
[tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);

% Group all dist2tgt regarless of true target location
[dist1Epochs,dist2Epochs,dist3Epochs,distDcdTgt] = getDist2Tgt(tgt2DistEpochs,ErrorInfo);

%% Amp max and min per trials and channel
[ampDecoding,~,~] = getDist2TgtMaxMinAmp(tgt2DistEpochs,tgtErrRPs,ErrorInfo);
% plotPredictorsDist2Tgt(ampDecoding,ErrorInfo)

%% Laterality analysis 
[latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>

%% Get max and min values for correct and incorrect trials, mean, std for
% all targets in order to normalize plot
ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);

%% Plotting epochs
plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
close all

%% Plot ErrRPs per target location
plotTgtErrRPs(tgtErrRPs,ErrorInfo)
close all

%% Explained variance for correct and error epochs
ErrorInfo.analysis.balanced = 1;
[expVar,n,pVals,mu,F,ErrorInfo] = getEpochsExpVar(corrEpochs,incorrEpochs,ErrorInfo);

%% Explained variance per target for correct and error epochs
[expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);

% %% Exp.Var. previous trial outcome for correct and incorrect trials
% % Correct
% [expVarCorr,nCorr,pValsCorr,muCorr,FCorr,ErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,ErrorInfo);
% % Incorrect
% [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,ErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo);
  
%% Plotting Explained Variance per channel
plotEpochsExpVar(expVar,pVals,ErrorInfo)
close all

%% Plotting Tgt Explained Variance per channel
plotEpochsTgtExpVar(expVarTgt,pValsTgt,ErrorInfo)
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Spectrograms

% Update to lad 600-600 data
ErrorInfo.epochInfo.freqRange           = [0 200];   % [0.6 14] % low and high freq. values to filter data
ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
ErrorInfo.epochInfo.preOutcomeTime      = 400;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.postOutcomeTime     = 1000;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.epochLen            = ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime;
ErrorInfo.eyeTraces.doEyes              = 0;
 
dataFolder = 'E:\Data\saccErrP\';
specfileName = fullfile(dataFolder,session,sprintf('%s-%s',session,'corrIncorrEpochs-downSamp1[400-1000ms]-butt4[0.0-200Hz].mat'));
fprintf('Loading file %s....\n',specfileName)
tStart = tic;
load(specfileName);
tEnd = toc(tStart);

end

   
