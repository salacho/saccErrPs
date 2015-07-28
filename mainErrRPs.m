 function ErrorInfo = mainErrRPs(session,mainParams)
% function ErrorInfo = mainErrRPs(session,mainParams)
%
% Main script to analyze ErrRPs in the intracranial data. Chico and Jonah.
% Most of the analysis are done on lfp data but spike data anlysis should 
% also be run. Most of the matrices are saved as well as several plots
% related to the arrays and the averaged waveforms.
%
% INPUT 
% session:
% mainParams
%   loadFile:         load file using specific params.
%   dataType:         string. 'lfp', 'lapla'
%   freqRange:        vector. Values of frequency range of data to load 
%                   (if loadFile = 1) or to parse in epochs. The vector
%                   freqRange has both the low and high freq. values used
%                   by a butterworth filter of order 4 to filter the data
%                   prior parsing in epochs.
%
% Try the following: 
% sessionList = {'CS20120816';'CS20120817';...
%     'CS20120912';'CS20120913';'CS20120914';...
%     'CS20120918';'CS20120919';'CS20120920';'CS20120921';...
%     'CS20120925';'CS20120926';'CS20120927';'CS20120928';...
%     'CS20121001';'CS20121002';'CS20121003';'CS20121004';'CS20121005';...
%     'CS20130410';...
%     'CS20130501';'CS20130502';'CS20130503';...
%     'CS20130617'};
% % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
% for iSes = 1:length(sessionList)
%     session = sessionList{iSes};
%     % mainErrRPs Params
%         % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
%         fprintf('Running analysis for session %s...\n',session)
%         mainErrRPs(session);
%         close all
% end
%
%
%
%
%
allChicoSessionList = {'CS20120815';'CS20120817';...
    'CS20120824';...
    'CS20120912';'CS20120913';'CS20120914';...
    'CS20120917';'CS20120918';'CS20120919';'CS20120920';'CS20120921';...
    'CS20120924';'CS20120925';'CS20120926';'CS20120927';'CS20120928';...
    'CS20121001';'CS20121002';'CS20121003';'CS20121004';'CS20121005';...
    'CS20121012';...
    'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';...
    'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026';...
    'CS20121105';'CS20121106';'CS20121108';...
    'CS20121113';'CS20121114';'CS20121115';'CS20121116';...
    'CS20121119';'CS20121120';'CS20121121';...
    'CS20121126';'CS20121127';'CS20121128';...
    'CS20130410';'CS20130411';'CS20130412';...
    'CS20130415';'CS20130416';'CS20130417';'CS20130418';...
    'CS20130422';'CS20130423';'CS20130424';'CS20130425';'CS20130426';...
    'CS20130428';'CS20130429';'CS20130430';...
    'CS20130501';'CS20130502';'CS20130503';...
    'CS20130617';'CS20130618'};
% 
%
% Andres v2.0
% Created May 2013
% Last modified 11 July 2013

% For session = 'CS20130501';
%
% error('Error in session CS20130501, possibly the fact only first and second block, no third one...')
%
% Attempted to access TrainTrials(0); index must be a positive integer or logical.
% 
% Error in goodDecodTrls (line 45)
%     lastTrainTrial = TrainTrials(end);
% 
% Error in getOutcmInfo (line 111)
% CRinfo = goodDecodTrls(CRinfo,bhvEv);
% 
% Error in mainErrRPs (line 100)
%     [ErrorInfo,OutcomeInfo,~] = getOutcmInfo(ErrorInfo,blockType,decodOnly);        %Get all
%     events and possible outcomes

%% 
% NEED TO CHANGE EPOCH SIZE FOR PUPIL AND FOR ErrPs , the do not have to be the same. Different pipelines,
% 
% disp('EXCLUDE OUTLIER TRIALS, trials with voltage deflections > +-300 uV for EEG')
% disp('RUN EVERYTHING BUT WITH DECODONLY OPTION SET TO TRUE')
% disp('corrBaseline and incorrBaseline must be, IF NOT EQUAL, almost EQUAL -> in mainErrPs')

%% Main params session = 'JS20131007'   
%session = 'CS20120914'
%session = 'CS20130618'
session = 'CS20130617';
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
mainParams = setDefaultParams(session,dirs);
disp(mainParams)

% Load already saved epochs
if mainParams.epochInfo.loadFile
    [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = loadErrRPs(mainParams);
else
    % Running the whole process, not loading
    [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(mainParams);
end

%% if decoding
if 1
    %% Signal processing
    [corrEpochs,incorrEpochs,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Feature extraction and selection
    [Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Detecting presence of ErrPs
    [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo);
end
%% If only creating epoched data and no plots are to be created

% Plotting params
if mainParams.getPlots
    ErrorInfo.plotInfo.arrayLoc = {'PFC','SEF','FEF'};
    ErrorInfo.epochInfo.epochDetrend = 0;
    %ErrorInfo.plotInfo.savePlot = true;
    ErrorInfo.plotInfo.visiblePlot  = 1;          
    ErrorInfo.plotInfo.equalLimits  = 1;

    %% Choosing ErrRPs per target location to see any target bias
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    %
    %% Choosing ErrRPs by distance to true target location
    [tgt2DistEpochs] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    
    %% Get max and min values for correct and incorrect trials, mean, std for
    % all targets in order to normalize plot
    ErrorInfo = getErrRPsEqualLimits(corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs,ErrorInfo);
    
    %% Get mean values for ErrRPs
    [corrMean,incorrMean,corrMeanBaseline,incorrMeanBaseline,corrMeanTgt,incorrMeanTgt,dist2tgtMean] = ...
        getErrRPsMean(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,tgtErrRPs,tgt2DistEpochs,ErrorInfo);
    
%     %% Get ErrRPs spectrogram
% $$$$$    
%     mainParams.specParams.params.Fs = ErrorInfo.epochInfo.Fs;       % Updating the sampling frequency
%     ErrorInfo.specgram = mainParams.specParams; 
%     ErrorInfo.plotInfo.dummyCh = 55;
%     % Calculate spectrogram
%     [meanCorrSpec,meanIncorrSpec,meanDiffSpec,...
%         corrSpec,incorrSpec,diffSpec,...
%         tgtCorrSpec,tgtIncorrSpec,dist2tgtSpec,ErrorInfo] = ...
%         getErrRPsSpecgram(corrMean,incorrMean,corrMeanTgt,incorrMeanTgt,dist2tgtMean,ErrorInfo);  
% $$$$$$$$$$$$$$$$$$$$$$$$$$meanCorr,meanIncorr,tgtMeanCorr,tgtMeanIncorr,dist2tgtMean,ErrorInfo  
    %% Getting envelopes (to send Xmax cards...)
    % [envelopCorrEpochs,envelopCorrMean,envelopIncorrEpochs,envelopIncorrMean] = getEnvelopeErrRPs(corrEpochs,incorrEpochs);
    
    %% Explained variance for correct and error epochs
    ErrorInfo.epochInfo.ANOVA.grandMeanMethod = 0;
    ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar = 0;
    ErrorEpochs = [corrEpochs, incorrEpochs];
    ErrorID = [zeros(ErrorInfo.epochInfo.nCorr,1);ones(ErrorInfo.epochInfo.nError,1)];
    ErrorInfo.epochInfo.ANOVA.analDim = 2;
    %ErrorInfo.epochInfo.ANOVA.epochLabel
    
    [expVar,n,pVals,mu,F] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.epochInfo.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
    expVar = squeeze(expVar);
    pVals = squeeze(pVals);
    ErrorInfo.epochInfo.pValCrit = 0.05;
    figure, imagesc(squeeze(pVals)<0.01)
    
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);
    
    %% Mean
    corrMean = squeeze(nanmean(corrEpochs,2));
    incorrMean = squeeze(nanmean(incorrEpochs,2));
%     meanCorrBaseline = squeeze(nanmean(corrBaseline,2));
%     meanIncorrBaseline = squeeze(nanmean(incorrBaseline,2));

    %% Baseline STD
    
    %% Signal template correlation decoder
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% PLOTTING RESULTS %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Plot specgram
    plotMeanSpecgram(meanCorrSpec,meanIncorrSpec,meanDiffSpec,ErrorInfo)

    %% Plotting single epochs
    %plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    plotSingleErrRPs(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,ErrorInfo)
    plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plotting epochs
    %plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    plotMeanErrRPs(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,ErrorInfo)
    plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
    close all
    
    %% Plot ErrRPs per target location
    plotTgtErrRPs(tgtErrRPs,ErrorInfo)
    close all
    
    %% Plot ErrRPs per distance to true target location
    plotTgtDistanceEpochs(tgt2DistEpochs,corrEpochs,ErrorInfo)
    close all
    
    %% Plotting envelopes
    % corrMean = squeeze(mean(corrEpochs,2));
    % incorrMean = squeeze(mean(incorrEpochs,2));
    % plotEnvelopeErrRPs(envelopCorrMean,envelopIncorrMean,corrMean,incorrMean,ErrorInfo);%envelopCorrEpochs,envelopIncorrEpochs)
    % close all
    
    %% Plotting Explained Variance per channel
    plotEpochsExpVar(expVar,pVals,ErrorInfo)
    close all
    
    %% Plotting Tgt Explained Variance per channel
    plotEpochsTgtExpVar(expVarTgt,pValsTgt,ErrorInfo)
    % close all
    
    %% find(p <= 0.05);
end   % end of noPlots    

