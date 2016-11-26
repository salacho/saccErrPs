function plot_groupIterDist2Tgt(subject)
%
%
%
%
%
%
%
% clear all, clc, close all, subject = 'jonah';

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
    loadFilename = fullfile(dirs.DataIn,'popAnalysis','24Nov2016_rng_1000Iter',sprintf('pop%s-%s-%i_iterDist2Tgt_expVar-rngIter.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
else
    loadFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_Ttest.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
end
load(loadFilename)

%% Update the dirs and paths
popErrorInfo.dirs = dirs;

%% Get mean of all results
% expVar
ev123 = squeeze(nanmean(expVar123,2));
ev12 = squeeze(nanmean(expVar12,2));
ev13 = squeeze(nanmean(expVar13,2));
ev23 = squeeze(nanmean(expVar23,2));
% pVals
p123 = squeeze(nanmean(pVals123,2));
p13 = squeeze(nanmean(pVals12,2));
p12 = squeeze(nanmean(pVals13,2));
p23 = squeeze(nanmean(pVals23,2));

%% Explained variance for Previous Trial Outcome effect
popErrorInfo.dirs.withRngSeedIter = 1;

distType = '123';
eval(sprintf('evType = ev%s;',distType)); eval(sprintf('pType = p%s;',distType))
popErrorInfo.analysis.typeVble = sprintf('dist%s',distType);
popErrorInfo.plotInfo.doBonferroni = 0; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 
popErrorInfo.plotInfo.doBonferroni = 1; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 

distType = '12';
eval(sprintf('evType = ev%s;',distType)); eval(sprintf('pType = p%s;',distType))
popErrorInfo.plotInfo.doBonferroni = 0; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 
popErrorInfo.plotInfo.doBonferroni = 1; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 

distType = '13';
eval(sprintf('evType = ev%s;',distType)); eval(sprintf('pType = p%s;',distType))
popErrorInfo.analysis.typeVble = sprintf('dist%s',distType);
popErrorInfo.plotInfo.doBonferroni = 0; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 
popErrorInfo.plotInfo.doBonferroni = 1; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 

distType = '23';
eval(sprintf('evType = ev%s;',distType)); eval(sprintf('pType = p%s;',distType))
popErrorInfo.analysis.typeVble = sprintf('dist%s',distType);
popErrorInfo.plotInfo.doBonferroni = 0; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 
popErrorInfo.plotInfo.doBonferroni = 1; 
plot_Dist2tgtExpVar_aveIter(evType,pType,popErrorInfo), plot_Dist2tgtPval_aveIter(evType,pType,popErrorInfo) 

end