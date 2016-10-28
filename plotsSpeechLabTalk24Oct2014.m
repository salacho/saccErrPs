function plotsSpeechLabTalk24Oct2014

% [chicoManSortedSessions,jonahManSortedSessions] = manSortedSessions;
sessionList = {'CS20120919','CS20120920','CS20120921','JS20131008','JS20131009','JS20131010','JS20131011'};

% Population 
popTgt2DistEpochs = repmat(struct(...
    'dist2tgt',[],...           % all possible distances of incorrect targets to true location    
    'dcdTgtRange',[],...        % possible values taken by dcd target for this true target location (iTgt)
    'numEpochsPerDist',[],...   % number of epochs for each distance to true location
    'dcdTgtDist1',[],...        % decoded targets for the error epochs with distance 1 to the target location
    'epochDist1',[],...         % error epochs with error at a distance 1 to the target location
    'meanEpochDist1',[],...     % mean error epoch for distance 1 to target location
    'stdEpochDist1',[],...      % std of error epochs for distance 1 to target location
    'sampErrEpochDist1',[],...  % sample error of error epochs for distance 1 to target location
    'dcdTgtDist2',[],...        % decoded targets for the error epochs with distance 2 to the target location
    'epochDist2',[],...         % error epochs with error at a distance 2 to the target location
    'meanEpochDist2',[],...     % mean error epoch for distance 2 to target location
    'stdEpochDist2',[],...      % std of error epochs for distance 2 to target location
    'sampErrEpochDist2',[],...  % sample error of error epochs for distance 2 to target location
    'dcdTgtDist3',[],...        % decoded targets for the error epochs with distance 3 to the target location
    'epochDist3',[],...         % error epochs with error at a distance 3 to the target location
    'meanEpochDist3',[],...     % mean error epoch for distance 3 to target location
    'stdEpochDist3',[],...      % std of error epochs for distance 3 to target location
    'sampErrEpochDist3',[]),...  % sample error of error epochs for distance 3 to target location
    [1 ErrorInfo.epochInfo.nTgts]);


for iSess = 1:length(sessionList)%chicoManSortedSessions)
    %session = chicoManSortedSessions{iSess};
    session = sessionList{iSess};
    disp(session)
    fprintf('.\n.\n.\n.')
    % Paths and dirs
    dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    disp(ErrorInfo)
    
    % Load data
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    ErrorInfo.epochInfo.epochDetrend = 0;
    ErrorInfo.plotInfo.savePlot = false;
    ErrorInfo.plotInfo.equalLimits  = 1;
    ErrorInfo.plotInfo.visible = 'on';
    
    %% Choosing ErrRPs per target location to see any target bias
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Choosing ErrRPs by distance to true target location
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
    %% Population of for several sessions 
%     for iTgt = 1:ErrorInfo.epochInfo.nTgts
%         popTgt2DistEpochs(iTgt).dist2tgt = unique([popTgt2DistEpochs(iTgt).dist2tgt, tgt2DistEpochs(iTgt).dist2tgt])
%         popTgt2DistEpochs(iTgt).dcdTgtRange = unique([popTgt2DistEpochs(iTgt).dcdTgtRange, tgt2DistEpochs(iTgt).dcdTgtRange])
%         
%         %popTgt2DistEpochs(iTgt).numEpochsPerDist = popTgt2DistEpochs(iTgt).numEpochsPerDist + tgt2DistEpochs(iTgt).numEpochsPerDist
%         
%         dcdTgtDist1 = dcdTgtDist1 : [2 6]
%         dcdTgtDist2: [3 3]
%         dcdTgtDist3: []
%         
%         popTgt2DistEpochs(iTgt).epochDist1 = [popTgt2DistEpochs(iTgt).epochDist1 tgt2DistEpochs(iTgt).epochDist1] : [96x2x1200 double]
%         meanEpochDist1: [96x1200 double]
%         stdEpochDist1: [96x1200 double]
%         sampErrEpochDist1: [96x1200 double]
%         
%         epochDist2: [96x2x1200 double]
%         meanEpochDist2: [96x1200 double]
%         stdEpochDist2: [96x1200 double]
%         sampErrEpochDist2: [96x1200 double]
%         
%         epochDist3: []
%         meanEpochDist3: []
%         stdEpochDist3: []
%         sampErrEpochDist3: []
%     end
% end
    
    %% Corr and Incorr epochs based on previous trial outcome
    [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
        getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);
    
    
    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs,ErrorInfo);
    
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);
    
    %% Explained variance for correct and error epochs
    ErrorInfo.epochInfo.ANOVA.grandMeanMethod = 0;
    ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar = 0;
    
    % Correct trials
    ErrorEpochs = [corrEpochsCorrPrev, corrEpochsErrPrev];
    ErrorID = [zeros(ErrorInfo.epochInfo.nCorrEpochCorrPrevTrial,1);ones(ErrorInfo.epochInfo.nCorrEpochErrPrevTrial,1)];
    ErrorInfo.epochInfo.ANOVA.analDim = 2;
    [expVarCorr,nCorr,pValsCorr,muCorr,FCorr] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.epochInfo.ANOVA.analDim);
    % Check
    expVarCorr = squeeze(expVarCorr);
    pValsCorr = squeeze(pValsCorr);
    ErrorInfo.epochInfo.pValCrit = 0.05;
    
    % Incorrect trials
    ErrorEpochs = [incorrEpochsCorrPrev, incorrEpochsErrPrev];
    ErrorID = [zeros(ErrorInfo.epochInfo.nIncorrEpochCorrPrevTrial,1);ones(ErrorInfo.epochInfo.nIncorrEpochErrPrevTrial,1)];
    ErrorInfo.epochInfo.ANOVA.analDim = 2;
    [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.epochInfo.ANOVA.analDim);
    % Check
    expVarIncorr = squeeze(expVarIncorr);
    pValsIncorr = squeeze(pValsIncorr);
    ErrorInfo.epochInfo.pValCrit = 0.05;
    
    %% Mean
    plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plot
    plotMeanErrPsPrevTrial(corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo)
    
    %% Plot ErrRPs per distance to true target location
    ErrorInfo.plotInfo.tracePerArrayPerTgt = 1;          % plot traces per target and per array
    plotTgtDistanceEpochs(tgt2DistEpochs,corrEpochs,ErrorInfo)
    close all
    
    %% Plot pre Channel ErrRPs per distance to true target location
    if iSess <= 3
        plotTgtDistanceEpochsPerCh(tgt2DistEpochs,corrEpochs,ErrorInfo)
        close all
    end
    %% Target
    plotTgtErrRPs(tgtErrRPs,ErrorInfo)
    
    %% Plot expVar prev.Trial outcome
    plotCorrIncorrPrevOutcomeExpVar(expVarCorr,expVarIncorr,pValsCorr,pValsIncorr,ErrorInfo)
    
    %% Plotting Tgt Explained Variance per channel
    plotEpochsTgtExpVar(expVarTgt,pValsTgt,ErrorInfo)
    close all
    
    fprintf('.\n.\n.\n.')

end