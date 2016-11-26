function plot_groupIterPrevTrialOutcm(subject)
%
%
%
%
%
%
%
% clear all, clc, close all, subject = 'chico';

dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
withRngSeedIter = 1;

%% Get sessionsList for subject
if strcmpi(subject,'chico')
   disp('Loading popEpochs for Chico...')
   sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
   popErrorInfo.subject = 'chico';
   session = 'popCS20121012-1026-11';
else
    disp('Loading popEpochs for Jonah...')
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
    popErrorInfo.subject = 'jonah';
    session = 'popJS20140318-0328-9';
end

%% Load file
%loadFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_corr1Incorr1Corr2_Ttest.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
if withRngSeedIter
    loadFilename = fullfile(dirs.DataIn,'popAnalysis','24Nov2016_rng_1000Iter',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_Ttest-rndSeedIter.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
else
    loadFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_Ttest.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
end
load(loadFilename)

%% Update dirs and paths
popErrorInfo.dirs = dirs;

expVarCorrAve = squeeze(nanmean(expVarCorr,2));
expVarIncorrAve = squeeze(nanmean(expVarIncorr,2));
pValsCorrAve = squeeze(nanmean(pValsCorr,2));
pValsIncorrAve = squeeze(nanmean(pValsIncorr,2));

%% Explained variance for Previous Trial Outcome effect
% Correct
popErrorInfo.analysis.typeVble = 'corr2';
popErrorInfo.dirs.withRngSeedIter = withRngSeedIter;
plotExpVarPrevTrialOutcome_aveIter(expVarCorrAve,pValsCorrAve,popErrorInfo) 
plotPvalPrevTrialOutcome_aveIter(expVarCorrAve,pValsCorrAve,popErrorInfo) 
% Incorrect
popErrorInfo.analysis.typeVble = 'incorr2';
plotExpVarPrevTrialOutcome_aveIter(expVarIncorrAve,pValsIncorrAve,popErrorInfo) 
plotPvalPrevTrialOutcome_aveIter(expVarIncorrAve,pValsIncorrAve,popErrorInfo) 

end
