 function [ErrorInfo,decoder] = mainErrRPs(session,decodeErrP,getPlots,rmBadChls)
% function [ErrorInfo,decoder] = mainErrRPs(session,decodeErrP,getPlots)
%
% Usage: [ErrorInfo,decoder] = mainErrRPs(session,0,1)
%
% Main script to analyze ErrRPs in the intracranial data. Chico and Jonah.
% Most of the analysis are done on lfp data but spike data anlysis should 
% also be run. Most of the matrices are saved as well as several plots
% related to the arrays and the averaged waveforms.
%
% INPUT 
% session:          string. Name of the session -> 'CC20140204'
% decodeErrP:       logical. True to run decoder. False just to convert
%                   epochs
% OUTPUT
% ErrorInfo:        structure with info about epoch's, spikes' and decoder's 
%                   params; trial and session info, as well as time onset for 
%                   different parts of the trials.
%
% OLD PARAMS
% mainParams
%   loadFile:         load file using specific params.
%   dataType:         string. 'lfp', 'lapla'
%   freqRange:        vector. Values of frequency range of data to load 
%                   (if loadFile = 1) or to parse in epochs. The vector
%                   freqRange has both the low and high freq. values used
%                   by a butterworth filter of order 4 to filter the data
%                   prior parsing in epochs.
%
% Andres v2.0
% Created May 2013
% Last modified 04 April 2014

% NEED TO CHANGE EPOCH SIZE FOR PUPIL AND FOR ErrPs , the do not have to be the same. Different pipelines,
% 
% disp('EXCLUDE OUTLIER TRIALS, trials with voltage deflections > +-300 uV for EEG')
% disp('RUN EVERYTHING BUT WITH DECODE ONLY OPTION SET TO TRUE')
% disp('corrBaseline and incorrBaseline must be, IF NOT EQUAL, almost EQUAL -> in mainErrPs')

%[chicoManSortedSessions,jonahManSortedSessions] = manSortedSessions;

%% Main params session 
% session = 'CS20120817'; %'JS20140425';
% sessionList = sfnSAbstractSessionList('chico'); session = sessionList{1}

dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
ErrorInfo = setDefaultParams(session,dirs);
% Change folder to save data since HD full
if strcmp(ErrorInfo.epochInfo.filtType,'butter') && (ErrorInfo.epochInfo.filtOrder == 1), ErrorInfo.dirs.DataOut = 'E:\Analysis\dlysac\ErrRPs';                            % Local Dir to output analyzed datafiles and figures too
end
disp(ErrorInfo)

% Load already saved LFP epochs and spikes
if ErrorInfo.epochInfo.loadFile
    if ErrorInfo.epochInfo.doErrPs
        [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    end
    if ErrorInfo.spikeInfo.doSpikes
        [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = loadErrSpikes(ErrorInfo); 
    end
else
    % Running the whole process, not loading
    if ErrorInfo.epochInfo.doErrPs
        [corrEpochs,incorrEpochs,~,ErrorInfo] = newErrRPs(ErrorInfo);
    end
    if ErrorInfo.spikeInfo.doSpikes
        [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = newErrSpikes(ErrorInfo);
    end
end

% %% Downsampling files!! Finally!! Only for old files...should have
% downsampling at creation of files since frequency components are already gone
% [corrEpochs,incorrEpochs,ErrorInfo] = downSampEpochs(corrEpochs,incorrEpochs,ErrorInfo);

% OJOOOOOOOOOOOO!!!!!!!!!!
warning('Update ErrorInfo.epochInfo.rmvNoisyErrPthresh!!!') %#ok<WNTAG>
%% Check for noisy trials and channels
ErrorInfo.signalProcess.ch2StDevAbove = plotChsVariability(corrEpochs,incorrEpochs,ErrorInfo);

if ErrorInfo.epochInfo.rmvNoisyErrP
    [corrEpochs,incorrEpochs,ErrorInfo] = removeNoisyErrPs(corrEpochs,incorrEpochs,ErrorInfo);
end
if ErrorInfo.epochInfo.rmvNoisyChsDone
    [corrEpochs,incorrEpochs,ErrorInfo] = removeNoisyChs(corrEpochs,incorrEpochs,ErrorInfo);
end

%% if spikes
% Computes all spike cell-arrays for all sessions (mamually sorted if manSorted == 1)
manSorted = 1; popGetNewErrSpikes(manSorted);          
% Get statistics
getRasterStatistics(corrRaster,incorrRaster,ErrorInfo)
% Plot rasters
plotErrRaster(corrRaster,incorrRaster,ErrorInfo)
% Histogram
getSpkPSTH(corrRaster,incorrRaster,ErrorInfo)

%% if decoding
if decodeErrP
    %% Signal processing
    [corrEpochs,incorrEpochs,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Feature extraction and selection
    [Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Detecting presence of ErrPs
    [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo);
else
    decoder = '';
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
plotPredictorsDist2Tgt(ampDecoding,ErrorInfo)

%% Laterality analysis 
[latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo); %#ok<ASGLU>

%% Get max and min values for correct and incorrect trials, mean, std for
% all targets in order to normalize plot
ErrorInfo = getErrRPsEqualLimits(ErrorInfo,corrEpochs,incorrEpochs,tgtErrRPs,tgt2DistEpochs);

%% Get ErrRPs spectrogram
% Calculate spectrogram
[corrSpec,incorrSpec,ErrorInfo] = getErrRPsSpecgram(ErrorInfo,corrEpochs,incorrEpochs);

% % Getting envelopes (to send Xmax cards...)
% [envelopCorrEpochs,envelopCorrMean,envelopIncorrEpochs,envelopIncorrMean] = getEnvelopeErrRPs(corrEpochs,incorrEpochs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% PLOTTING RESULTS %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot specgram
plotMeanSpecgram(corrSpec,incorrSpec,ErrorInfo)

%% Plotting single epochs
plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
close all

%% Plotting epochs
plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
close all

%% Plot based on previous trial outcome
plotMeanErrPsPrevTrial(corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo)

%% Plot ErrRPs per target location
plotTgtErrRPs(tgtErrRPs,ErrorInfo)
close all

%% Plot ErrRPs per distance to true target location 
ErrorInfo.plotInfo.tracePerArrayPerTgt = 1;          % plot traces per target and per array
plotDist2Tgt(tgt2DistEpochs,tgtErrRPs,corrEpochs,ErrorInfo)
close all

%% Plot ErrRPs per distance to true target location for previous outcome trials
ErrorInfo.plotInfo.tracePerArrayPerTgt = 1;          % plot traces per target and per array
plotDist2TgtPerCh(tgt2DistEpochs,tgtErrRPs,ErrorInfo)
close all

%% Plot Mean per laterality 
plotMeanLatErrPs(latMeanCh,latStdCh,latMeanArray,latStdArray,ErrorInfo)

%% Plot per Channel ErrRPs per distance to true target location

%% Plot exp.var. previous trial outcome
plotCorrIncorrPrevOutcomeExpVar(expVarCorr,expVarIncorr,pValsCorr,pValsIncorr,ErrorInfo)

%% Num incorrect trials
plotNumTrialsErrDcdTgt(tgtErrRPs,tgt2DistEpochs,ErrorInfo);

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
close all

%% Previous Trial Outcome effect
% Correct
ErrorInfo.analysis.typeVble = 'correct';
plotExpVarPrevTrialOutcome(expVarCorr,pValsCorr,ErrorInfo) 
% Incorrect
ErrorInfo.analysis.typeVble = 'incorrect';
plotExpVarPrevTrialOutcome(expVarIncorr,pValsIncorr,ErrorInfo) 

%% find(p <= 0.05);

if rmBadChls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Remove bad channels
    chs2Remove = [3,8,12,18,24,27,32,42,46,56,65,70];
    allChs = ones(1,96);
    allChs(chs2Remove) = 0;
    chs2Keep = logical(allChs);
    goodCorrEpochs = corrEpochs(chs2Keep,:,:);
    goodIncorrEpochs = incorrEpochs(chs2Keep,:,:);
    %% Explained variance for correct and error epochs
    ErrorInfo.epochInfo.ANOVA.grandMeanMethod = 0;
    ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar = 0;
    ErrorEpochs = [goodCorrEpochs, goodIncorrEpochs];
    ErrorID = [zeros(ErrorInfo.epochInfo.nCorr,1);ones(ErrorInfo.epochInfo.nError,1)];
    ErrorInfo.epochInfo.ANOVA.analDim = 2;
    [expVar,n,pVals,mu,F] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.epochInfo.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
    expVar = squeeze(expVar);
    pVals = squeeze(pVals);
    ErrorInfo.epochInfo.pValCrit = 0.05;
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    %% Explained variance for correct and error epochs
    [expVar,n,pVals,mu,F,ErrorInfo] = getEpochsExpVar(corrEpochs,incorrEpochs,ErrorInfo);
    %% Explained variance per target for correct and error epochs
    [expVarTgt,nTgt,pValsTgt,muTgt,fTgt,ErrorInfo] = getTgtExpVar(tgtErrRPs,ErrorInfo);

    %% Exp.Var. previous trial outcome for correct and incorrect trials
    % Correct    
    [expVarCorr,nCorr,pValsCorr,muCorr,FCorr,ErrorInfo] = getEpochsExpVar(corrEpochsCorrPrev,corrEpochsErrPrev,ErrorInfo);
    % Incorrect
    [expVarIncorr,nIncorr,pValsIncorr,muIncorr,FIncorr,ErrorInfo] = getEpochsExpVar(incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo);
end

 
