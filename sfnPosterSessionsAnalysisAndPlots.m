function sfnPosterSessionsAnalysisAndPlots(subjName)
%
%
%
%
%
%
% 09 Nov 2014

% % Load online session names
% subjName = 'chico';
% [chicoSessionsList,chicoSessionsBCIperf] = onlineErrPsessions(subjName);
% subjName = 'jonah';
% [jonahSessionsList,jonahSessionsBCIperf] = onlineErrPsessions(subjName);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % For population analysis
% subjName = 'jonah';
% sessionList = sfnSAbstractSessionList(subjName); 
% sessionList = sessionList(1:6);
% session = sessionList{1}; 
% dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
% ErrorInfo = setDefaultParams(session,dirs);
% 
% [meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,ErrorInfo] = popGetTgtErrPs(sessionList,ErrorInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% For mean and ANOVA per session

sessionList = sfnSAbstractSessionList(subjName); 
for iSess = 1:length(sessionList)

    session = sessionList{iSess};
    dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    disp(ErrorInfo)
    
    % Load files
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    % Trials per target
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    % Distance to true target location
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
%     % %% Amp max and min per trials and channel
%     [ampDecoding,~,~] = getDist2TgtMaxMinAmp(tgt2DistEpochs,tgtErrRPs,ErrorInfo);
    
%     %% Fit ampDist2Tgt
%     fitDist2Tgt(ampDecoding,ErrorInfo)
    
    %% Laterality analysis
    %[latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>
    
    % Previous trial outcome
    [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);

     %% Explained variance for correct and error epochs
    [expVar,n,pVals,mu,F,ErrorInfo] = getEpochsExpVar(corrEpochs,incorrEpochs,ErrorInfo);
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);
    
    plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plotting epochs
    plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plot ErrRPs per target location
    plotTgtErrRPs(tgtErrRPs,ErrorInfo)
    close all
    
    %% Dist2Tgt
    ErrorInfo.plotInfo.tracePerArrayPerTgt = 0;
    plotTgtDistanceEpochs(tgt2DistEpochs,tgtErrRPs,corrEpochs,ErrorInfo)
    close all
    
    %% Number of trials per target and dist2Tgt
    plotNumTrialsErrDcdTgt(tgtErrRPs,tgt2DistEpochs,ErrorInfo);
    
    % Plot Exp.Var.
    %% Plotting Explained Variance per channel
    plotEpochsExpVar(expVar,pVals,ErrorInfo)
    close all
    
    %% Plotting Tgt Explained Variance per channel
    plotEpochsTgtExpVar(expVarTgt,pValsTgt,ErrorInfo)
    close all
    
    %% Previous Trial outcome
    [expVarCorr,nCorr,pValsCorr,muCorr,FCorr,ErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,ErrorInfo);
    [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,ErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo);
    
    %% Previous Trial Outcome effect
    % Correct
    ErrorInfo.analysis.typeVble = 'correct';
    plotExpVarPrevTrialOutcome(expVarCorr,pValsCorr,ErrorInfo)
    % Incorrect
    ErrorInfo.analysis.typeVble = 'incorrect';
    plotExpVarPrevTrialOutcome(expVarIncorr,pValsIncorr,ErrorInfo)
end
close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sessionList = sfnSAbstractSessionList('jonah'); 
for iSess = 1:length(sessionList)

    session = sessionList{iSess};
    dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    disp(ErrorInfo)
    
    % Load files
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    % Trials per target
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    % Distance to true target location
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
    %% Laterality analysis
    %[latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>
    
    % Previous trial outcome
    [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo);

     %% Explained variance for correct and error epochs
    [expVar,n,pVals,mu,F,ErrorInfo] = getEpochsExpVar(corrEpochs,incorrEpochs,ErrorInfo);
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);
    
    plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plotting epochs
    plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plot ErrRPs per target location
    plotTgtErrRPs(tgtErrRPs,ErrorInfo)
    close all
    
    %% Dist2Tgt
    ErrorInfo.plotInfo.tracePerArrayPerTgt = 0;
    plotTgtDistanceEpochs(tgt2DistEpochs,tgtErrRPs,corrEpochs,ErrorInfo)
    close all
    
    %% Number of trials per target and dist2Tgt
    plotNumTrialsErrDcdTgt(tgtErrRPs,tgt2DistEpochs,ErrorInfo);
    
    % Plot Exp.Var.
    %% Plotting Explained Variance per channel
    plotEpochsExpVar(expVar,pVals,ErrorInfo)
    close all
    
    %% Plotting Tgt Explained Variance per channel
    plotEpochsTgtExpVar(expVarTgt,pValsTgt,ErrorInfo)
    close all
    
    %% Previous Trial outcome
    [expVarCorr,nCorr,pValsCorr,muCorr,FCorr,ErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,ErrorInfo);
    [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,ErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo);
    
    %% Previous Trial Outcome effect
    % Correct
    ErrorInfo.analysis.typeVble = 'correct';
    plotExpVarPrevTrialOutcome(expVarCorr,pValsCorr,ErrorInfo)
    % Incorrect
    ErrorInfo.analysis.typeVble = 'incorrect';
    plotExpVarPrevTrialOutcome(expVarIncorr,pValsIncorr,ErrorInfo)
    sfn2014_SwapChannels_plotExpVarPrevTrialOutcome(expVarIncorr,pValsIncorr,ErrorInfo)
    
end

close all
clear all

