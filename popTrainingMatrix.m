function [popXvals,popYvals,popInfo] = popTrainingMatrix
% function [popXvals,popYvals,popInfo] = popTrainingMatrix
%
% Loads all available sessions and creates a training data set prior to
% decoding session. Xvals and Yvals are the covariates and true lables
%
%
%
%
%
% Author    : Andres
% 
% andres    : 1.1   : init. 19 March 2014

dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail = 'salacho1@gmail.com';

%% Params iterated (that will change)
arrayIndx       = [2,2];        
availArrays     = {'PFC','SEF','FEF'};              
rmvBaseline     = false;
predFunction    = {'mean'};
predSelectType  = {'none'};
dataTransf      = {'zscore'};

%% All sessions
[sessionList,~] = chicoBCIsessions;
nSessions = length(sessionList);
midSessions = round(nSessions/2);

%% Initialize vbles
popXvals = [];
popYvals = [];
popNumTrials = 0;
kk = 0;

for iSession = 1:midSessions
    kk = kk + 1;
    tStart = tic;
    session = sessionList{iSession};
    popSessions{kk} = session;
    
    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    % Load epochs (this does not depend on decoding params)
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Update ErrorInfo
    ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
        availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf);
    
    %% Reinforcing alltrain and no load Decoder
    warning('Check code since this way of updating fields is not very efficient!!!...turns everything into training sessions')
    ErrorInfo.decoder.loadDecoder = 0;
    ErrorInfo.decoder.typeVal = 'alltrain';
    disp(ErrorInfo.decoder)
    
    %% Create the big/popTrain matrices
    if strcmp(lower(ErrorInfo.decoder.typeVal),'alltrain')
        % Signal processing
        [corrEpochsProcess,incorrEpochsProcess,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
        
        % Feature extraction and selection
        [Xvals,ErrorInfo] = selectFeatures(corrEpochsProcess,incorrEpochsProcess,ErrorInfo);
        
        % Aggregatting all observations
        popXvals = [popXvals; Xvals];
        popYvals = [popYvals; ErrorInfo.featSelect.Yvals];
        popNumTrials = popNumTrials + length(ErrorInfo.featSelect.Yvals);
    else
        error('The type of validation is not allTraining!!!...Change it!!')
    end
end

%% Name of the popFile
% Session for the population 
if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{midSessions},midSessions,ErrorInfo.decoder.oldSession);
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{midSessions},midSessions);
end

%% Train decoder
ErrorInfo.featSelect.Yvals = popYvals;
[ErrorInfo,decoder] = decodeErrRPs(popXvals,ErrorInfo);             % this step saves the decoder that shall be used later to check error detection

%% Everything in one cell array
popErrorInfo = ErrorInfo;
popInfo{1}  = popErrorInfo;
popInfo{2}  = popSessions ;
popInfo{3}  = popNumTrials;
popInfo{4}  = {'popErrorInfo','popSessions','popNumTrials'};

%% Save everything
rootFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popTrain');                 %#ok<*NASGU>
saveFilename = sprintf('%s.mat',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList') 
save(saveFilename,'popXvals','popYvals','popInfo') 

