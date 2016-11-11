function pop_iterPrevTrialOutcomeTtest(subject)
%
%
%
%
%
%
% clear all, close all, clc
% subject = 'jonah';

%% Paths and dirs
% Get all correct and incorrect epochs
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved

%% Load pop files
% Extract or load popEpochs
if strcmpi(subject,'chico')
   disp('Loading popEpochs for Chico...')
   sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
   popFilesPath = fullfile(dirs.DataIn,'popAnalysis','popCS20121012-CS20121026-11-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
   load(popFilesPath);
   popErrorInfo.subject = 'chico';
else
    disp('Loading popEpochs for Jonah...')
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
    popFilesPath = fullfile(dirs.DataIn,'popAnalysis','popJS20140318-JS20140328-9-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
    load(popFilesPath);
    popErrorInfo.subject = 'jonah';
end

%% Down sample data!!
if ~isfield(popErrorInfo.epochInfo,'nCorrBad')
    ErrorInfo.signalProcess.downSampFactor = 10;
    [popCorr,popIncorr,ErrorInfo] = popDownSamp(popCorr,popIncorr,ErrorInfo);
end

%% Get epochs for both options in previous trial outcome (correct and
% incorrect)
[corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,popErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(popCorr,popIncorr,popErrorInfo);

%% T.test previous trial outcome for correct and incorrect trials
popErrorInfo.analysis.balanced = 1;

if popErrorInfo.analysis.balanced
    % Define vars
    nIter = 1000;
    % Correct
    expVarCorr  = nan(size(corrEpochsCorrPrev,1),nIter,size(corrEpochsCorrPrev,3));
    pValsCorr   = nan(size(corrEpochsCorrPrev,1),nIter,size(corrEpochsCorrPrev,3));
    FCorr       = nan(size(corrEpochsCorrPrev,1),nIter,size(corrEpochsCorrPrev,3));
    muCorr      = nan(size(corrEpochsCorrPrev,1),2,size(corrEpochsCorrPrev,3),nIter);
    nCorr = nan(2,nIter);
    % Incorrect
    expVarIncorr = nan(size(incorrEpochsCorrPrev,1),nIter,size(incorrEpochsCorrPrev,3));
    pValsIncorr  = nan(size(incorrEpochsCorrPrev,1),nIter,size(incorrEpochsCorrPrev,3));
    FIncorr      = nan(size(incorrEpochsCorrPrev,1),nIter,size(incorrEpochsCorrPrev,3));
    muIncorr     = nan(size(incorrEpochsCorrPrev,1),2,size(incorrEpochsCorrPrev,3),nIter);
    nIncorr = nan(2,nIter);
    
    % Iterate
    for iIter =1:nIter
        fprintf('T-test for previous trial outcome for iter %i...\n',iIter)
        [expVarCorr(:,iIter,:),nCorr(:,iIter),pValsCorr(:,iIter,:),muCorr(:,:,:,iIter),FCorr(:,iIter,:),popErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,popErrorInfo);
        [expVarIncorr(:,iIter,:),nIncorr(:,iIter),pValsIncorr(:,iIter,:),muIncorr(:,:,:,iIter),FIncorr(:,iIter,:),popErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,popErrorInfo);
    end
else
    % Correct
    [expVarCorr,nCorr,pValsCorr,muCorr,FCorr,popErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,popErrorInfo);
    % Incorrect
    [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,popErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,popErrorInfo);
end

saveFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterPrevTrialOutcome_Ttest.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
save(saveFilename,'expVarCorr','nCorr','pValsCorr','muCorr','FCorr','expVarIncorr','nIncorr','pValsIncorr','muIncorr','FIncorr','nIter','popErrorInfo','-v7.3')

% get 95% upper bound and 5% lower bound and get mean.

end
