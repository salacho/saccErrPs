function mainParams = setDefaultParams(session,dirs,varargin)
% function mainParams = setDefaultParams(session,dirs,varargin)
%
% Sets defaults parameters into structure used in the rest of the code.  
%
% Added doErrPs option.
%
% Author    : Andres 
% 
% andres    : 1.1   : initial. Created 14 Jan 2014
% andres    : 1.2   : grouped structures properly for ease managing. 26 Feb 2014
% 

%% Parsing files or loading previously parsed files params
mainParams.session                      = session;  % session in the form 'CS20120304'
mainParams.filedate                     = str2double(mainParams.session(3:end));
mainParams.nChs                         = 96;       % total number of channels. Need to un-hard code this
mainParams.chList                       = 1:96;     % list of all the good channels
mainParams.dirs                         = dirs;

%% Epoch params
mainParams.epochInfo.nChs               = mainParams.nChs;      % rebundancy required for other stages of the code
mainParams.epochInfo.chList             = mainParams.chList;    % list of all the good channels
mainParams.epochInfo.blockType          = 0;        % Zero. Usually three blocks, 1) training, 2) ordered targets, 3) random targets
mainParams.epochInfo.decodOnly          = true;     % True if selecting only trials from the block where decoding occurs
mainParams.epochInfo.freqRange          = [1 10];   % [0.6 14] % low and high freq. values to filter data
mainParams.epochInfo.filtLowBound       = mainParams.epochInfo.freqRange(1);      % filter low freq. bound
mainParams.epochInfo.filtHighBound      = mainParams.epochInfo.freqRange(2);      % filter high freq. bound
mainParams.epochInfo.typeRef            = 'lfp';    % type of files loaded, lfps ('lfp'), laplacian ('lapla'), CAR (common-averaged referenced 'car')
mainParams.epochInfo.itiExtraTime       = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
mainParams.epochInfo.baselineLen        = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
mainParams.epochInfo.preOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
mainParams.epochInfo.postOutcomeTime    = 600;      % ms. pre-outcome stimuli presentation time (ms)
mainParams.epochInfo.doErrPs            = true;     % logical. True to get ErrPs epochs
mainParams.epochInfo.NewErrPs           = true;     % logical. Avoid getting new ErrPs if files do not exist
mainParams.epochInfo.saveEpochs         = true;     % logical. True to save epochs in file
mainParams.epochInfo.loadFile           = true;     % logical. True to load previously saved epoched data (if exist)
mainParams.epochInfo.rmvBaseline        = true;     % flag useful for analysis and decoding
mainParams.epochInfo.rmvBaseDone        = false;    % flag to avoid removing baseline more than once. Need to add to ErrorInfo structure after loading old files
mainParams.epochInfo.epochLen           = mainParams.epochInfo.preOutcomeTime + mainParams.epochInfo.postOutcomeTime;

%% BCI params
mainParams.BCIparams.arrays             = {'PFC','SEF','FEF'};  % name of the arrays or source of the data
mainParams.BCIparams.arrayChs           = [1:32,33:64,65:96];   % distribution between arrays and channels

%% Decoder structure
%mainParams.decoder.arrays              = {'PFC','SEF'};        % areas from which channels are selected for decoding
mainParams.decoder.dcdType              = 'regress';            % type of decoder used 'regress', 'logitreg', 'lda'
% mainParams.decoder.dcdWindow          = [50 600];             % [ms ms] Data window, with zero at feedback onset, for decoder [-100 500], Start ms End from feedback onset 
% mainParams.decoder.lenEpoch           = (mainParams.decoder.dcdWindow(2) - mainParams.decoder.dcdWindow(1));  % ms. Length of data used for decoding
% mainParams.decoder.baselineLen        = 200;                  % ms. length of window before feedback onset to remove baseline (its mean) from 
% mainParams.decoder.baselineDone       = false;                % logical. Flag for data which baseline have been removed
mainParams.decoder.trainDecoder         = true;                 % was 'loadDecoder'. Train a new decoder every time  AFSG(2014-02-26) 
mainParams.decoder.loadDecoder          = false;                % load trained decoder 
mainParams.decoder.saveDecoder          = true;                 % logical. Save latest decoder
mainParams.decoder.oldSession           = 'CS20130617';         % was 'oldSession'. Session which has already trained decoder to be loaded (if loadDecoder is true) AFSG (2014-02-26) 
mainParams.decoder.oldDecoder           = [];                   % the full oldDecoder. Full Matrix. 
mainParams.decoder.oldDecoderName       = '';                   % The complete name of the decoder to use. If not, leave empty.         
mainParams.decoder.nIter                = 100;                  % number of iteration the decoder is run
mainParams.decoder.crossValPerc         = 10;                   % Percentage of trials used to test decoder using cross-validation
mainParams.decoder.typeVal              = 'alltrain';           % 'alltest','crossval' type of validation. Can be leave-one-out validation ('loov'); cross-validation ('crossval'); no validation, just training ('alltrain'), test all trials usign a previously trained decoder ('alltest')
mainParams.decoder.visible              = 'true';               % show decoder performance after decoding...
mainParams.decoder.dataTransform        = 'zscore';                % 'none', 'sqr','sqrt','log','zscore'
mainParams.decoder.dataTransformed      = 0;
mainParams.decoder.dataTransfVals.zscoreMu  = [];
mainParams.decoder.dataTransfVals.zscoreSig = [];
mainParams.decoder.dataTransfVals.maxMaxVal = [];
% mainParams.decoder.predWindows        = [50 100; ...
%                                         100 150;...
%                                         150 250;...
%                                         250 350;...
%                                         350 600];             % ms. Boundaries of the time sections for the predictors, which mean values will be taken from

%% Signal processing
mainParams.signalProcess.baselineLen    = 200;                  % was 'mainParams.decoder.baselineLen'  % ms. length of window before feedback onset to remove baseline (its mean) from 
mainParams.signalProcess.baselineDone   = false;                % was 'mainParams.decoder.baselineDone' % logical. Flag for data which baseline have been removed
mainParams.signalProcess.arrays         = {'SEF'};        % was mainParams.decoder.arrays. % areas from which channels are selected for decoding
mainParams.signalProcess.dcdWindow      = [0 600];             % was mainParams.decoder.dcdWindow. % [ms ms] Data window, with zero at feedback onset, for decoder [-100 500], Start ms End from feedback onset 
mainParams.signalProcess.getDcdWindow   = true;                 % logical. Flag to select from epoch the data window
mainParams.signalProcess.epochLen       = (mainParams.signalProcess.dcdWindow(2) - mainParams.signalProcess.dcdWindow(1));  % was mainParams.decoder.lenEpoch. % ms. Length of data used for decoding

%% Feature selection and extraction
mainParams.featSelect.predSelectType    = 'none';              % 'anova', 'rayleigh'; 'rate'; 'pca/svd'
mainParams.featSelect.predSelectCrit    = 0.05;                 % feature selection criteria. For anova it is the p-value. For SVD it will be the number of SVD or the minimum explained variance
mainParams.featSelect.predDomain        = 'time';               % 'time', 'freq', 'rate' Domain from which predictors are selected
mainParams.featSelect.doPerm            = true;                 % Do permutation of all trials so taking 1:10 is equal to sampling them randomly
mainParams.featSelect.predFunction      = {'mean'};           %{'mean'};{'none'} % {'mean2'} function applied to the predWindows. If more than one, size(predWindow,1) = size(predFunction); it will have a one-to-one approach for each predWindow: {'max','min','max','min','max'}
switch mainParams.featSelect.predFunction{1}
    case 'none'
        mainParams.featSelect.numPredPerCh      = mainParams.signalProcess.epochLen;
        mainParams.featSelect.predWindows       = [];
    case 'mean'
        mainParams.featSelect.predWindows       = [50 100; ...  % was mainParams.decoder.predWindows
                                                100 150;...
                                                150 250;...
                                                250 350;...
                                                350 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
%         mainParams.featSelect.predWindows       = [25 75; ...  % was mainParams.decoder.predWindows
%                                                 75 150;...
%                                                 150 300;...
%                                                 300 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        mainParams.featSelect.numPredPerCh      = size(mainParams.featSelect.predWindows,1);
    case {'minMax','mean2'}
        mainParams.featSelect.predWindows       = [25 75; ...  % was mainParams.decoder.predWindows
                                                75 150;...
                                                150 300;...
                                                300 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        mainParams.featSelect.numPredPerCh      = size(mainParams.featSelect.predWindows,1);
    otherwise
        dispfprintf('Function %s not availabel!!...\n',mainParams.featSelect.predFunction{1})
end

%% Updating values to match featSelect.predWindows
%% Signal processing
if ~isempty(mainParams.featSelect.predWindows)
    if (mainParams.signalProcess.dcdWindow(1,1) >= mainParams.featSelect.predWindows(1,1))
        mainParams.signalProcess.dcdWindow(1,1) = mainParams.featSelect.predWindows(1,1);
        mainParams.signalProcess.epochLen       = (mainParams.signalProcess.dcdWindow(2) - mainParams.signalProcess.dcdWindow(1));  % was mainParams.decoder.lenEpoch. % ms. Length of data used for decoding
    end
end

%% Eye traces info
mainParams.eyeTraces.blockType          = 0;        % Zero. Usually three blocks, 1) training, 2) ordered targets, 3) random targets
mainParams.eyeTraces.decodOnly          = true;     % True if selecting only trials from the block where decoding occurs
mainParams.eyeTraces.itiExtraTime       = 500;      % ms. after start of iti get extra 'itiExtraTime' ms from each epoch
mainParams.eyeTraces.baselineLen        = 200;      % ms. Length of baseline epoch ErrorInfo.epochInfo.baselineLen
mainParams.eyeTraces.preOutcomeTime     = 600;      % ms. pre-outcome stimuli presentation time (ms)
mainParams.eyeTraces.postOutcomeTime    = 600;      % ms. pre-outcome stimuli presentation time (ms)
mainParams.eyeTraces.doEyes             = false;    % logical. True to load and run analysis on eye traces (i.e. pupilometry for performance monitoring)
mainParams.eyeTraces.saveTraces         = true;     % logical, saves eye traces
mainParams.eyeTraces.loadFile           = true;     % logical. True to load previously saved eye traces data (if exist)
mainParams.eyeTraces.rmvBaseline        = true;     % flag useful for analysis and decoding
mainParams.eyeTraces.rmvBaseDone        = false;    % flag to avoid removing baseline more than once. Need to add to ErrorInfo structure after loading old files

%% Plotting params
mainParams.plotInfo.getPlots            = false;    % logical. False to only run code to save epoched data. true to do extra analysis and plot figures
mainParams.plotInfo.clims               = false;    % use normalized limits for all plots
mainParams.plotInfo.visible             = 'on';     % string. 'on' or 'off'. 'on' to make plots visible
mainParams.plotInfo.savePlot            = false;    % logical. true to save plots in folder DataOut/session.
mainParams.plotInfo.equalLimits         = true;     % logical. true to use equal Y limits in all plots of one figure
mainParams.plotInfo.clims               = false;    % logical. True to plot all spectrograms using normalized limits
mainParams.plotInfo.maxError            = 60;       % integer. max. and (-min.) value that error bar can have in Y axis when
                                                    % using equal Y lims. If max. of error bars > maxError or min. error bars < -maxError,'Ylim',[-maxError maxError] instead.
mainParams.plotInfo.maxMean             = 50;       % integer. max. and (-min.) value that mean data can have in Y axis
                                                    % when using equal Y lims. If max. of mean vals > maxMean or min. mean vals. < -maxMean,'Ylim',[-maxMean maxMean] instead.
mainParams.plotInfo.stdError            = 0;        % Use standard errors intead of standard deviations in plots since you are using standard error of the mean 
mainParams.plotInfo.arrayLoc            = {'PFC','SEF','FEF'};     % cell. list of arrays plotted
mainParams.epochInfo.epochDetrend       = 0;                  % logical. True for detrending epochs to be plotted 
%mainParams.plotInfo.savePlot = true;                   % logical. True to save plot

%% Spectrogram 
TW  = 3;                %time-bandwidth window
K   = 2;                %number of slepian functions. K <= 2TW -1, [3,2] better than [2,2], [2,1]
window  =  0.2;         %length of window: 20 ms
winstep =  0.025;       %step the window is moved: 10 ms
fMin = 0;               %low freq.
fMax = 500;             % high freq.

% Filter values for spectrogram must be between freq. boundaries of loaded data
if mainParams.epochInfo.freqRange(1) < fMin, fMin = mainParams.epochInfo.freqRange(1); end
if mainParams.epochInfo.freqRange(2) < fMax, fMax = mainParams.epochInfo.freqRange(2); end

% Creating spec params structure
mainParams.specParams.movingWin = [window winstep];
mainParams.specParams.params = struct(...
                    'tapers',   [TW K],...                  % TW: time-bandwidth product. K: number of tapers to be used (K < 2TW-1).
                    'pad',      0,...                       % zero padding. 0 to the next power of 2
                    'Fs',       1000,...                    % Sampling frequency. 1000 Hz by default
                    'fpass',    [fMin fMax],...             % frequency band for filter
                    'err',      0,...                       % 0 for no error bars
                    'trialave', 0);                         % 0 for no average across trial/channels

clear TW K fMin fMax window windstep

end
