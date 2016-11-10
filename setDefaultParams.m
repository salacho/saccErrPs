function ErrorInfo = setDefaultParams(session,dirs,varargin)
% function mainParams = setDefaultParams(session,dirs,varargin)
%
% Sets defaults parameters into structure used in the rest of the chronic recordings code.  
%
% Added doErrPs option.
%
% Author    : Andres 
% 
% Andres    : 1.1   : initial. Created 14 Jan 2014
% Andres    : 1.2   : grouped structures properly for ease managing. 26 Feb 2014
% Andres    : 1.3   : added spike analysis params. 15 Oct 2014

if length(session) < 15
    % is only one session
else
    % a session list
    session = sprintf('%spop%s-%s-%i',char(session{1}(1)),session{1},session{end},length(session));
end

    
%% Parsing files or loading previously parsed files params
ErrorInfo.session                       = session;  % session in the form 'CS20120304'
ErrorInfo.filedate                      = str2double(ErrorInfo.session(3:end));
ErrorInfo.nChs                          = 96;       % total number of channels. Need to un-hard code this
ErrorInfo.chList                        = 1:96;     % list of all the good channels
ErrorInfo.dirs                          = dirs;     % path to folders

%% Spikes info
ErrorInfo.spikeInfo.nChs                = ErrorInfo.nChs;
ErrorInfo.spikeInfo.doSpikes            = true;     % perform spike analysis
ErrorInfo.spikeInfo.saveSpikes          = true;     % save spike data matrices
ErrorInfo.spikeInfo.spkSampFreq         = 30000;    % Sampling frequency of the spike data
ErrorInfo.spikeInfo.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.spikeInfo.postOutcomeTime     = 1000;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.spikeInfo.manSorted           = true;    % load manually sorted spikes
ErrorInfo.spikeInfo.spikeType           = 'unsorted'; % string. Can be 'unsorted' or 'sorted'. Include spikes that were not sorted, refered here as unit 0? 
ErrorInfo.spikeInfo.lumpUnits           = false;     % aggregate or not all units from one electrode -spike sorting is ommitted-
ErrorInfo.spikeInfo.useChnlsWithUnitsOnly = false;  % True if using only channels with sorted units 

ErrorInfo.spikeInfo.binSz               = 50;      % integer. Bin size used for computing the PSTH, in milliseconds. 

%% Epoch params
ErrorInfo.epochInfo.doErrPs             = true;     % logical. True to get ErrPs epochs
ErrorInfo.epochInfo.nChs                = ErrorInfo.nChs;      % rebundancy required for other stages of the code
ErrorInfo.epochInfo.chList              = ErrorInfo.chList;    % list of all the good channels
ErrorInfo.epochInfo.blockType           = 0;        % Zero. Usually three blocks, 1) training, 2) ordered targets, 3) random targets
ErrorInfo.epochInfo.decodOnly           = true;     % True if selecting only trials from the block where decoding occurs
ErrorInfo.epochInfo.freqRange           = [1 10];   % [0.6 14] % low and high freq. values to filter data
ErrorInfo.epochInfo.filtType            = 'butter'; % string. name of filr used by function 'setFilterParams.m' in 'getErrRPs.m'
ErrorInfo.epochInfo.filtOrder           = 4;        % set filter order
ErrorInfo.epochInfo.filtLowBound        = ErrorInfo.epochInfo.freqRange(1);      % filter low freq. bound
ErrorInfo.epochInfo.filtHighBound       = ErrorInfo.epochInfo.freqRange(2);      % filter high freq. bound
ErrorInfo.epochInfo.typeRef             = 'lfp';    % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
ErrorInfo.epochInfo.itiExtraTime        = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
ErrorInfo.epochInfo.baselineLen         = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
ErrorInfo.epochInfo.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.postOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.epochInfo.NewErrPs            = true;     % logical. Avoid getting new ErrPs if files do not exist
ErrorInfo.epochInfo.saveEpochs          = true;     % logical. True to save epochs in file
ErrorInfo.epochInfo.loadFile            = true;     % logical. True to load previously saved epoched data (if exist)
ErrorInfo.epochInfo.rmvBaseline         = false;     % flag useful for analysis and decoding
ErrorInfo.epochInfo.rmvBaseDone         = false;    % flag to avoid removing baseline more than once. Need to add to ErrorInfo structure after loading old files
ErrorInfo.epochInfo.epochDetrend        = 0;                  % logical. True for detrending epochs to be plotted 
ErrorInfo.epochInfo.epochLen            = ErrorInfo.epochInfo.preOutcomeTime + ErrorInfo.epochInfo.postOutcomeTime;
ErrorInfo.epochInfo.rmvNoisyErrP        = 1;        % logical. True to remove noisy trials
ErrorInfo.epochInfo.rmvNoisyErrPthresh  = 110;      % threshold used to remove noisy trials.
ErrorInfo.epochInfo.rmvNoisyErrPDone    = 0;        % logical. Flag to state bad epochs have been removed from all channels
ErrorInfo.epochInfo.rmvNoisyChs         = false;    % logical, removes completely from analysis the bad channels
ErrorInfo.epochInfo.rmvNoisyChsDone     = false;    % logical. Flag to state bad channels have been removed from all files
ErrorInfo.epochInfo.noisyChsStDevFactor = 2.5;      % matrix [3 x chNumbers]. In case there is a list of bad channels to remove due to known problems in specific channels
ErrorInfo.epochInfo.noisyChsList        = [];       % matrix [3 x chNumbers]. In case there is a list of bad channels to remove due to known problems in specific channels
ErrorInfo.epochInfo.getMeanArrayEpoch   = true;     % logical. True to get the mean and st.dev/error epoch from all trials and channels per array.

%% BCI params
if strcmpi(session(1),'c')          % 'chico'
        ErrorInfo.BCIparams.arrays  = {'PFC','SEF','FEF'};          % name of the arrays or source of the data
elseif strcmpi(session(1),'j')      % 'jonah'  
        ErrorInfo.BCIparams.arrays  =  {'SEF','FEF','PFC'};
end
ErrorInfo.BCIparams.arrayChs            = [1:32;33:64;65:96];   % distribution between arrays and channels
ErrorInfo.BCIparams.nArrays             = length(ErrorInfo.BCIparams.arrays);

%% Decoder structure
%mainParams.decoder.arrays              = {'PFC','SEF'};        % areas from which channels are selected for decoding
ErrorInfo.decoder.dcdType               = 'regress';            % type of decoder used 'regress', 'logitreg', 'lda'
% mainParams.decoder.dcdWindow          = [50 600];             % [ms ms] Data window, with zero at feedback onset, for decoder [-100 500], Start ms End from feedback onset 
% mainParams.decoder.lenEpoch           = (mainParams.decoder.dcdWindow(2) - mainParams.decoder.dcdWindow(1));  % ms. Length of data used for decoding
% mainParams.decoder.baselineLen        = 200;                  % ms. length of window before feedback onset to remove baseline (its mean) from 
% mainParams.decoder.baselineDone       = false;                % logical. Flag for data which baseline have been removed
ErrorInfo.decoder.trainDecoder          = true;                 % was 'loadDecoder'. Train a new decoder every time  AFSG(2014-02-26) 
ErrorInfo.decoder.loadDecoder           = false;                % load trained decoder 
ErrorInfo.decoder.saveDecoder           = true;                 % logical. Save latest decoder
ErrorInfo.decoder.oldSession            = 'XXXXXXXXXX';         % was 'oldSession'. Session which has already trained decoder to be loaded (if loadDecoder is true) AFSG (2014-02-26) 
ErrorInfo.decoder.oldDecoder            = [];                   % the full oldDecoder. Full Matrix. 
ErrorInfo.decoder.oldDecoderName        = '';%[dirs.DataOut,...
   % '\popAnalysis\popCS20130424-CS20130617-10-reg-xvals-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat'];                   % The complete name of the decoder to use. If not, leave empty.         
ErrorInfo.decoder.nIter                 = 100;                  % number of iteration the decoder is run
ErrorInfo.decoder.crossValPerc          = 10;                   % Percentage of trials used to test decoder using cross-validation
ErrorInfo.decoder.typeVal               = 'crossval';           % 'alltest','crossval' type of validation. Can be leave-one-out validation ('loov'); cross-validation ('crossval'); no validation, just training ('alltrain'), test all trials usign a previously trained decoder ('alltest')
ErrorInfo.decoder.visible               = 'true';               % show decoder performance after decoding...
ErrorInfo.decoder.dataTransform         = 'zscore';             % 'none', 'sqr','sqrt','log','zscore'
ErrorInfo.decoder.dataTransformed       = 0;
ErrorInfo.decoder.dataTransfVals.zscoreMu  = [];
ErrorInfo.decoder.dataTransfVals.zscoreSig = [];
ErrorInfo.decoder.dataTransfVals.maxMaxVal = [];
% mainParams.decoder.predWindows        = [50 100; ...
%                                         100 150;...
%                                         150 250;...
%                                         250 350;...
%                                         350 600];             % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
ErrorInfo.decoder.unsupervisedDcd       = 1;                    % logical. 1 for unsupervised learning, 1 supervised. 0 uses previously trained decoder, fixed for all the session. 1 will load the Xvals from previous sessions (based on 'mainParams.decoder.oldDecoderName'), not the decoder, then add the Xvals from the previous trials and trains a new decoder to test the current trial.
ErrorInfo.decoder.Xvals                 = [];                   % matrix. [numTrials x numCovariates]. Predictors matrix.
ErrorInfo.decoder.Yvals                 = [];                   % vector. [numTrials x 1]. True labels for each trial, elated to the predictor's matrix 

%% Signal processing
ErrorInfo.signalProcess.baselineLen     = 200;                  % was 'mainParams.decoder.baselineLen'  % ms. length of window before feedback onset to remove baseline (its mean) from 
ErrorInfo.signalProcess.baselineDone    = false;                % was 'mainParams.decoder.baselineDone' % logical. Flag for data which baseline have been removed

if strcmpi(session(1),'c')          % 'chico', left hemisphere arrays
    ErrorInfo.signalProcess.arrays         = {'SEF'};           % was mainParams.decoder.arrays. % areas from which channels are selected for decoding
    ErrorInfo.signalProcess.arrayLaterality = 'left';
    ErrorInfo.signalProcess.ipsilatTgts = [3 4 5];
    ErrorInfo.signalProcess.contralatTgts = [6 1 2]; 
    ErrorInfo.signalProcess.contraIndx      = 2;               % index/location of the column for plotting contralateral targets
    ErrorInfo.signalProcess.ipsiIndx        = 1;               % index/location of the column for plotting ipsilateral targets
elseif strcmpi(session(1),'j')      % 'jonah', right hemisphere arrays  
    ErrorInfo.signalProcess.arrays         = {'FEF','PFC'};    % was mainParams.decoder.arrays. % areas from which channels are selected for decoding
    ErrorInfo.signalProcess.arrayLaterality = 'right';
    ErrorInfo.signalProcess.ipsilatTgts     = [6 1 2];         % targets located ipsilateral to the implanted hemisphere
    ErrorInfo.signalProcess.contralatTgts   = [3 4 5];         % targets located contralateral to the implanted hemisphere
    ErrorInfo.signalProcess.contraIndx      = 1;               % index/location of the column for plotting contralateral targets
    ErrorInfo.signalProcess.ipsiIndx        = 2;               % index/location of the column for plotting ipsilateral targets
end

ErrorInfo.signalProcess.dcdWindow       = [0 600];             % was mainParams.decoder.dcdWindow. % [ms ms] Data window, with zero at feedback onset, for decoder [-100 500], Start ms End from feedback onset 
ErrorInfo.signalProcess.getDcdWindow    = true;                % logical. Flag to select from epoch the data window
ErrorInfo.signalProcess.epochLen        = (ErrorInfo.signalProcess.dcdWindow(2) - ErrorInfo.signalProcess.dcdWindow(1));  % was mainParams.decoder.lenEpoch. % ms. Length of data used for decoding
ErrorInfo.signalProcess.downSamp        = true;                % logical. True to down sample the epochs to values easy to handle 
ErrorInfo.signalProcess.downSampFactor  = 10;                  % integer. Factor data samples are downsampled to
% If no downsampling, put 1 as the factor  to properly name files
if ~ErrorInfo.signalProcess.downSamp        
    ErrorInfo.signalProcess.downSampFactor = 1;
end

%% Feature selection and extraction
ErrorInfo.featSelect.predSelectType     = 'none';              % 'anova', 'rayleigh'; 'rate'; 'pca/svd'
ErrorInfo.featSelect.predSelectCrit     = 0.05;                % feature selection criteria. For anova it is the p-value. For SVD it will be the number of SVD or the minimum explained variance
ErrorInfo.featSelect.predDomain         = 'time';              % 'time', 'freq', 'rate' Domain from which predictors are selected
ErrorInfo.featSelect.doPerm             = true;                % Do permutation of all trials so taking 1:10 is equal to sampling them randomly
ErrorInfo.featSelect.predFunction       = {'mean'};            % {'mean'};{'none'} % {'mean2'} function applied to the predWindows. If more than one, size(predWindow,1) = size(predFunction); it will have a one-to-one approach for each predWindow: {'max','min','max','min','max'}
switch ErrorInfo.featSelect.predFunction{1}
    case 'none'
        ErrorInfo.featSelect.numPredPerCh      = ErrorInfo.signalProcess.epochLen;
        ErrorInfo.featSelect.predWindows       = [];
    case 'mean'
        ErrorInfo.featSelect.predWindows       = [50 100; ...  % was mainParams.decoder.predWindows
                                                100 150;...
                                                150 250;...
                                                250 350;...
                                                350 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
%         ErrorInfo.featSelect.predWindows       = [25 75; ...  % was mainParams.decoder.predWindows
%                                                 75 150;...
%                                                 150 300;...
%                                                 300 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        ErrorInfo.featSelect.numPredPerCh      = size(ErrorInfo.featSelect.predWindows,1);
    case {'minMax','mean2'}
        ErrorInfo.featSelect.predWindows       = [25 75; ...  % was mainParams.decoder.predWindows
                                                75 150;...
                                                150 300;...
                                                300 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        ErrorInfo.featSelect.numPredPerCh      = size(ErrorInfo.featSelect.predWindows,1);
    otherwise
        dispfprintf('Function %s not availabel!!...\n',ErrorInfo.featSelect.predFunction{1})
end

%% Updating values to match featSelect.predWindows
%% Signal processing
if ~isempty(ErrorInfo.featSelect.predWindows)
    if (ErrorInfo.signalProcess.dcdWindow(1,1) >= ErrorInfo.featSelect.predWindows(1,1))
        ErrorInfo.signalProcess.dcdWindow(1,1) = ErrorInfo.featSelect.predWindows(1,1);
        ErrorInfo.signalProcess.epochLen       = (ErrorInfo.signalProcess.dcdWindow(2) - ErrorInfo.signalProcess.dcdWindow(1));  % was mainParams.decoder.lenEpoch. % ms. Length of data used for decoding
    end
end

%% Eye traces info
ErrorInfo.eyeTraces.blockType           = 0;        % Zero. Usually three blocks, 1) training, 2) ordered targets, 3) random targets
ErrorInfo.eyeTraces.decodOnly           = true;     % True if selecting only trials from the block where decoding occurs
ErrorInfo.eyeTraces.itiExtraTime        = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
ErrorInfo.eyeTraces.baselineLen         = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
ErrorInfo.eyeTraces.preOutcomeTime      = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.eyeTraces.postOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
ErrorInfo.eyeTraces.doEyes              = false;     % logical. True to load and run analysis on eye traces (i.e. pupilometry for performance monitoring)
ErrorInfo.eyeTraces.saveTraces          = true;     % logical, saves eye traces
ErrorInfo.eyeTraces.loadFile            = true;     % logical. True to load previously saved eye traces data (if exist)
ErrorInfo.eyeTraces.rmvBaseline         = true;     % flag useful for analysis and decoding
ErrorInfo.eyeTraces.rmvBaseDone         = false;    % flag to avoid removing baseline more than once. Need to add to ErrorInfo structure after loading old files

%% Plotting params
ErrorInfo.plotInfo.getPlots             = true;     % logical. False to only run code to save epoched data. true to do extra analysis and plot figures
ErrorInfo.plotInfo.clims                = false;    % use normalized limits for all plots
                                                    % using equal Y lims. If max. of error bars > maxError or min. error bars < -maxError,'Ylim',[-maxError maxError] instead.
ErrorInfo.plotInfo.visible              = 'off';     % string. 'on' or 'off'. 'on' to make plots visible
ErrorInfo.plotInfo.savePlot             = true;     % logical. true to save plots in folder DataOut/session.

ErrorInfo.plotInfo.equalLimits          = true;     % logical. true to use equal Y limits in all plots of one figure
ErrorInfo.plotInfo.stdError             = 0;        % Use standard errors instead of standard deviations in plots since you are using standard error of the mean 
ErrorInfo.plotInfo.maxError             = 60;       % integer. max. and (-min.) value that error bars can have in Y axis when
ErrorInfo.plotInfo.maxMean              = 50;       % integer. max. and (-min.) value that mean data can have in Y axis
                                                   % when using equal Y lims. If max. of mean vals > maxMean or min. mean vals. < -maxMean,'Ylim',[-maxMean maxMean] instead.
if strcmpi(session(1),'c')          % 'chico'
    ErrorInfo.plotInfo.arrayLoc         = {'PFC','SEF','FEF'};          % name of the arrays or source of the data
elseif strcmpi(session(1),'j')      % 'jonah'
    ErrorInfo.plotInfo.arrayLoc         =  {'SEF','FEF','PFC'};         % cell. list of arrays plotted
end
ErrorInfo.plotInfo.nArrays              = length(ErrorInfo.plotInfo.arrayLoc);
ErrorInfo.plotInfo.arrayChs             = [1:32;33:64;65:96];

ErrorInfo.plotInfo.lineWidth            = 4;
ErrorInfo.plotInfo.lineStyle            = '--';
ErrorInfo.plotInfo.titleFontSz          = 12;        
ErrorInfo.plotInfo.titleFontWeight      = 'Bold';
ErrorInfo.plotInfo.nXtick               = 8;
ErrorInfo.plotInfo.axisFontSz           = 7;        
ErrorInfo.plotInfo.axisFontWeight       = 'Bold';

% Define Colormap for 32 channels
FigHand = figure; ErrorInfo.plotInfo.colorMap = colormap; close(FigHand); nColors = 32;
ErrorInfo.plotInfo.colorMap = ErrorInfo.plotInfo.colorMap(1:round(length(ErrorInfo.plotInfo.colorMap)/nColors):end,:);   % 32 different colors
% Define Colormap for 6 targets
FigHand = figure; ErrorInfo.plotInfo.colorTgt = colormap; close(FigHand); nColors = 6;
ErrorInfo.plotInfo.colorTgt = ErrorInfo.plotInfo.colorTgt(1:round(length(ErrorInfo.plotInfo.colorTgt)/nColors):end,:);   % 6 different colors for the target location
% ErrP colors matching colors in EEG plots
ErrorInfo.plotInfo.plotColors           = [26 150 65; 215 25 28]/255;   % used for error bars plots
ErrorInfo.plotInfo.colorErrP            = [[26 150 65]/255;...          % Correct
                                           [215 25 28]/255;...          % Incorrect
                                           [0 0 128]/255;...            % Err difference
                                           [0 0 0]];                    % P300 signal in EEG studies
ErrorInfo.plotInfo.distColors           = [26 150 65;
                                            0 255 0; 
                                            253 141 60; 
                                            215 25 28;
                                            0 0 0]/255;             % [green, lime green, orange, red]
ErrorInfo.plotInfo.dist2TgtAllAxis      = true;                         % Used in  'plotTgtDistanceEpochsPerCh.m' draws axis  ticks and values in all 6 targets dist2Tgt subplots.  
ErrorInfo.plotInfo.tracePerArrayPerTgt  = 1;
ErrorInfo.plotInfo.arrayColor           = [1 1 1];
% Layout for 32-channel array plots
test.NNs = 0; test.lapla = 0;
ErrorInfo.plotInfo.layout               = layout(1,test);               % Layout info to plot on 32 channels per array as well 
% Six target location plot
ErrorInfo.plotInfo.TgtPlot.rows         = 12;
ErrorInfo.plotInfo.TgtPlot.colms        = 12;
ErrorInfo.plotInfo.TgtPlot.subplot      = {57:60,7:10,3:6,49:52,99:102,103:106};       %{[3:6],[7:10],[49:52],[57:60],[99:102],[103:106]};
% Center of 6 target location to place legend 
tgtLoc = ErrorInfo.plotInfo.TgtPlot.subplot{4}; tgtFirst = tgtLoc(end) + 1; tgtLoc = ErrorInfo.plotInfo.TgtPlot.subplot{1}; tgtLast = tgtLoc(1) - 1; tgtLoc = (tgtFirst:tgtLast);
ErrorInfo.plotInfo.TgtPlot.tgtCntr = [tgtLoc,tgtLoc + ErrorInfo.plotInfo.TgtPlot.colms,tgtLoc + 2*ErrorInfo.plotInfo.TgtPlot.colms,tgtLoc + 3*ErrorInfo.plotInfo.TgtPlot.colms];

% Color for laterality
ErrorInfo.plotInfo.colorIpsiContra([1 3],:) = repmat(ErrorInfo.plotInfo.colorErrP(1,:),[2 1]);
ErrorInfo.plotInfo.colorIpsiContra([2 4],:) = repmat(ErrorInfo.plotInfo.colorErrP(2,:),[2 1]);
ErrorInfo.plotInfo.colorIpsiContra(5,:) = [0 0 0];
hFig = figure; colorMapVals = colormap; close(hFig);
ErrorInfo.plotInfo.colorIpsiContraError = colorMapVals(linspace(1,64,4),:);
ErrorInfo.plotInfo.colorIpsiContraError(5,:) =  [0 0 0];

% Target info
ErrorInfo.plotInfo.targets              = 1:length(1:6);                                   %all possible targets
ErrorInfo.plotInfo.nTgts                = length(ErrorInfo.plotInfo.targets);

% Spectrogram params
ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting  
ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting  
ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot
%ErrorInfo.plotInfo.specgram.freqs       = [0 10;10 15;10 30;30 40;40 60;30 60;60 100];      % range (lower/upper) of frequencies to plot
ErrorInfo.plotInfo.specgram.freqs       = [0 10;0 30;0 70;10 40;20 60;30 70;30 100;60 100;60 200;100 200];      % range (lower/upper) of frequencies to plot
ErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points
ErrorInfo.plotInfo.specgram.transfDone  = 0;                              % logical. Flag to lable normType was applied.

%% Analysis
ErrorInfo.analysis.dataTransform        = 'zscore'; % string. Transformation for decoder approach. Can be 'sqrt', 'sqr', 'log', 'none', 'max', 'min'
ErrorInfo.analysis.dataTransfDone       = 0;        % logical. Flag set to one when data transformation has been done
ErrorInfo.analysis.dist2TgtAmpStart     = 0;        % in milliseconds. With respect to feedback onset
ErrorInfo.analysis.dist2TgtAmpEnd       = 350;      % in milliseconds. With respect to feedback onset
ErrorInfo.analysis.ANOVA.grandMeanMethod = 0;
ErrorInfo.analysis.ANOVA.calcOmega2ExpVar = 0;
ErrorInfo.analysis.ANOVA.analDim        = 2;
ErrorInfo.analysis.ANOVA.pValCrit       = 0.01;     % criteria to select statistical significance of tests
ErrorInfo.analysis.balanced             = true;     % logical. True to do analysis with balanced number of samples (i.e. for one-way ANOVA analysis)

%% Population analysis
ErrorInfo.analysis.pop.saveFile              = true;     % logical. True to save file collecting info form a population of sessions
ErrorInfo.analysis.pop.saveFilename          = '';       % strin. Prefix appended to all files used in this population analysis
ErrorInfo.analysis.pop.sessionList           = {};       % cell array. List of sessions used for population analysis
ErrorInfo.analysis.pop.savePlot              = 1;
disp('Ojo!!! .analysis.pop used to be .popAnal...')

%% Spectrogram 
TW  = 3;                %time-bandwidth window
K   = 2;                %number of slepian functions. K <= 2TW -1, [3,2] better than [2,2], [2,1]
window  =  0.3;         %length of window: 20 ms
winstep =  0.025;       %step the window is moved: 10 ms
fMin = 0;               %low freq.
fMax = 500;             % high freq.

% Filter values for spectrogram must be between freq. boundaries of loaded data
if ErrorInfo.epochInfo.freqRange(1) < fMin, fMin = ErrorInfo.epochInfo.freqRange(1); end
if ErrorInfo.epochInfo.freqRange(2) < fMax, fMax = ErrorInfo.epochInfo.freqRange(2); end

% Creating spec params structure
ErrorInfo.specParams.movingWin = [window winstep];
ErrorInfo.specParams.params = struct(...
                    'tapers',   [TW K],...                  % TW: time-bandwidth product. K: number of tapers to be used (K < 2TW-1).
                    'pad',      0,...                       % zero padding. 0 to the next power of 2
                    'Fs',       1000,...                    % Sampling frequency. 1000 Hz by default
                    'fpass',    [fMin fMax],...             % frequency band for filter
                    'err',      0,...                       % 0 for no error bars
                    'trialave', 0);                         % 0 for no average across trial/channels

clear TW K fMin fMax window windstep

end
