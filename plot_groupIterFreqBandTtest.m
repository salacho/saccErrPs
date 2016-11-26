function plot_groupIterFreqBandTtest(subject)
% function plot_groupIterFreqBandTtest(subject)
%
%
%
%
%
%
% clear all, clc, close all, subject = 'jonah';

dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
withRngSeedIter = 1;

freqBands = [1 4;4 8;8 13;13 30;30 80;80 200];
errDiffFreqTxt = {'delta','theta','alpha','beta','gamma','highGam'};

%% Get sessionsList for subject
if strcmpi(subject,'chico')
   disp('Loading popEpochs for Chico...')
   sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
   session = 'popCS20121012-1026-11';
else
    disp('Loading popEpochs for Jonah...')
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
    session = 'popJS20140318-0328-9';
end

%% Load file
%loadFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_corr1Incorr1Corr2_Ttest.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
if withRngSeedIter
    loadFilename = fullfile(dirs.DataIn,'popAnalysis','24Nov2016_rng_1000Iter',sprintf('pop%s-%s-%i-iterTtest_freqBands-rgnIter.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
else
    loadFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i-iterTtest_freqBands',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
end
load(loadFilename)

%% Update the dirs and paths
ErrorInfo.dirs = dirs;
ErrorInfo.subject = subject;

%% Get mean of all results
eF = squeeze(nanmean(expVarFreq,3));
nF = squeeze(nanmean(nFreq,2));
pF = squeeze(nanmean(pValsFreq,3));
muF = squeeze(nanmean(muFreq,5));
fF = squeeze(nanmean(FFreq,3));

% Plot
popPlotTtest_FreqBands(eF,pF,errDiffFreqTxt,ErrorInfo)
popPlotTtest_FreqBands_bonferroniCorrected(eF,pF,errDiffFreqTxt,ErrorInfo)

end
