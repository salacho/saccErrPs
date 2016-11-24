function pop_iterDist2TgtExp(subject)
% function pop_iterDist2TgtExp(subject)
%
%
%
% 23 Nov. 2016
%
% clear all, close all, clc
% subject = 'chico';

%% Population
% Get all correct and incorrect epochs
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved

% Extract or load popEpochs
if strcmpi(subject,'chico')
   disp('Loading popEpochs for Chico...')
   sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
   popFilesPath = fullfile(dirs.DataIn,'popAnalysis','popCS20121012-CS20121026-11-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
   load(popFilesPath);
   popErrorInfo.subject = 'chico';
   popErrorInfo.session = 'popCS20121012-CS20121026-11';
else
    disp('Loading popEpochs for Jonah...')
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
    popFilesPath = fullfile(dirs.DataIn,'popAnalysis','popJS20140318-JS20140328-9-corrIncorr--rmvNoisTrials-downSamp10[600-600ms]-butt4[1.0-10Hz].mat');
    load(popFilesPath);
    popErrorInfo.subject = 'jonah';
    popErrorInfo.session = 'popJS20140318-JS20140328-9';
end

%% Down sample data!!
if ~isfield(popErrorInfo.epochInfo,'nCorrBad')
    popErrorInfo.signalProcess.downSampFactor = 10;
    [popCorr,popIncorr,popErrorInfo] = popDownSamp(popCorr,popIncorr,popErrorInfo);
end
if popErrorInfo.epochInfo.epochLen == 1200;
    popErrorInfo.epochInfo.epochLen = 120;
end

%% Sessions name
popErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end}(7:end),numel(sessionList));

%% Separate in 6 targets
% [meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,ErrorInfo]
%[popTgtErrPs,popDcdTgt] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popDcdTgt);
[popTgtErrPs,popDist2Tgt,meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popErrorInfo);

% All dist2Tgt trials together regardless of true target location
popDist2TgtAll = popDist2Tgt_allTgtTogether(popDist2Tgt);

%% T.test previous trial outcome for correct and incorrect trials
popErrorInfo.analysis.balanced = 1;
popErrorInfo.analysis.withReplacement = 'true';

if popErrorInfo.analysis.balanced
    % Define vars
    nIter = 1000;
    % Dist123
    expVar123  = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    pVals123   = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    F123       = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    mu123      = nan(size(popDist2TgtAll.dist1,1),3,size(popDist2TgtAll.dist1,3),nIter);
    n123       = nan(3,nIter);

    % Dist12
    expVar12  = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    pVals12   = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    F12       = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    mu12      = nan(size(popDist2TgtAll.dist1,1),2,size(popDist2TgtAll.dist1,3),nIter);
    n12       = nan(2,nIter);
    
    % Dist13
    expVar13  = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    pVals13   = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    F13       = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    mu13      = nan(size(popDist2TgtAll.dist1,1),2,size(popDist2TgtAll.dist1,3),nIter);
    n13 = nan(2,nIter);

    % Dist23
    expVar23  = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    pVals23   = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    F23       = nan(size(popDist2TgtAll.dist1,1),nIter,size(popDist2TgtAll.dist1,3));
    mu23      = nan(size(popDist2TgtAll.dist1,1),2,size(popDist2TgtAll.dist1,3),nIter);
    n23 = nan(2,nIter);

    % tmpVars
    popDistDcdTgt(1).dcdTgt = 1:popDist2TgtAll.numEpochsPerDist(1);
    popDistDcdTgt(2).dcdTgt = 1:popDist2TgtAll.numEpochsPerDist(2);
    popDistDcdTgt(3).dcdTgt = 1:popDist2TgtAll.numEpochsPerDist(3);
    
    % Iterate
    for iIter =1:nIter
        rng(iIter);
        fprintf('Exp. var for Dist2Tgt 123-12-13-23...for iter %i...\n',iIter)
        [expVar123(:,iIter,:),n123(:,iIter),pVals123(:,iIter,:),mu123(:,:,:,iIter),F123(:,iIter,:)] = ...
            getDist2TgtExpVar(popDist2TgtAll.dist1,popDist2TgtAll.dist2,popDist2TgtAll.dist3,popDistDcdTgt,popErrorInfo);
        [expVar12(:,iIter,:),n12(:,iIter),pVals12(:,iIter,:),mu12(:,:,:,iIter),F12(:,iIter,:),popErrorInfo] = getEpochsExpVar(popDist2TgtAll.dist1,popDist2TgtAll.dist2,popErrorInfo);
        [expVar13(:,iIter,:),n13(:,iIter),pVals13(:,iIter,:),mu13(:,:,:,iIter),F13(:,iIter,:),popErrorInfo] = getEpochsExpVar(popDist2TgtAll.dist1,popDist2TgtAll.dist3,popErrorInfo);
        [expVar23(:,iIter,:),n23(:,iIter),pVals23(:,iIter,:),mu23(:,:,:,iIter),F23(:,iIter,:),popErrorInfo] = getEpochsExpVar(popDist2TgtAll.dist2,popDist2TgtAll.dist3,popErrorInfo);
    end
else
end

%% Save files
popErrorInfo.dirs = dirs;
saveFilename = fullfile(dirs.DataIn,'popAnalysis',sprintf('pop%s-%s-%i_iterDist2Tgt_expVar-rngIter.mat',sessionList{1},sessionList{end}(7:end),numel(sessionList)));
save(saveFilename,...
    'expVar123','pVals123','F123','mu123','n123',...
    'expVar12','pVals12','F12','mu12','n12',...
    'expVar13','pVals13','F13','mu13','n13',...
    'expVar23','pVals23','F23','mu23','n23',...
    'nIter','popErrorInfo','-v7.3')

% get 95% upper bound and 5% lower bound and get mean.

end
