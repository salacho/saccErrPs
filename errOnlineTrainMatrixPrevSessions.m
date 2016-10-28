function errOnlineTrainMatrixPrevSessions
% function [popXvals,popYvals,popInfo] = errOnlineTrainMatrixPrevSessions
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
% andres    : 1.2   : init. 21 March 2014. Added the option of usign only a number of the previous sessions to test on the next one
% andres    : 1.3   : Changed format to be used in online MOnkey sacc BCI test.

subjName    = 'jonah';
dirs        = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail   = 'salacho1@gmail.com';

%% All sessions
switch subjName
    case 'chico', [sessionList,~] = chicoBCIsessions(0,1);      %beforeSessions = 0, newOnly = 1
    case 'jonah', sessionList = jonahBCIsessions;
end
disp('The decoder will be trained with sessions:'); disp(sessionList); 
nSessions = length(sessionList);
numTrainSessions = nSessions;

%% Params iterated (that will change)
warning('Using SEF by default for both monkeys!!!')  %#ok<*WNTAG>
if strcmpi(sessionList{1}(1),'c')           % 'chico'
    availArrays = {'PFC','SEF','FEF'};      % name of the arrays or source of the data
    arrayIndx   = [2,2];
elseif strcmpi(sessionList{1}(1),'j')       % 'jonah'
    availArrays =  {'SEF','FEF','PFC'};
    arrayIndx   = [1,1];
end
rmvBaseline     = false;
predFunction    = {'mean'};
predSelectType  = {'none'};
dataTransf      = {'zscore'};

% AFSG (2014-03-21) midSessions = round(nSessions/2);

% AFSG (2014-03-21)
% if doMidSessions, lastSession = midSessions;
% else lastSession = nSessions; %#ok<*UNRCH>
% end

% Sessions used for trainning the decoder
trainSessions = sessionList;
firstSession = trainSessions{1};
lastSession = trainSessions{end};

%% Initialize vbles
popXvals = [];
popYvals = [];
popNumTrials.all = 0;
kk = 0;

%% Collect all training data (subset of previous sessions) for each sessions
for iTrainSession = 1:numTrainSessions              % AFSG (2014-03-21) was for iSession = 1:lastSession
    kk = kk + 1;
    tStart = tic;
    session = trainSessions{iTrainSession};         % AFSG (2014-03-21) was session = sessionList{iSession};
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
    if strcmpi(ErrorInfo.decoder.typeVal,'alltrain')
        % Signal processing
        [corrEpochsProcess,incorrEpochsProcess,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
        % Feature extraction and selection
        [Xvals,ErrorInfo] = selectFeatures(corrEpochsProcess,incorrEpochsProcess,ErrorInfo);
        % Aggregatting all observations
        popXvals                = [popXvals; Xvals];
        popYvals                = [popYvals; ErrorInfo.featSelect.Yvals];
        popNumTrials.all        = popNumTrials.all + length(ErrorInfo.featSelect.Yvals);
        popNumTrials.Corr(kk)   = ErrorInfo.epochInfo.nCorr;
        popNumTrials.Error(kk)  = ErrorInfo.epochInfo.nError;
    else
        error('The type of validation is not allTraining!!!...Change it!!')
    end
    clear corrEpochs incorrEpochs corrEpochsProcess incorrEpochsProcess Xvals
end

%% Name of session for the population
ErrorInfo.session = sprintf('pop%s-%s-%i',firstSession,lastSession,numTrainSessions);

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
fprintf('Saving Xvals %s\n',rootFilename)
saveFilename = sprintf('%s',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList')
save(saveFilename,'popXvals','popYvals','popInfo')

tElapsed = toc(tStart);
%% Email me, end of ErrP analysis
emailme('dataconversionstate@gmail.com','DataConversionState','Finished oldDcd popTest DcdErrPs',['Finished ',ErrorInfo.session,' in ',num2str(tElapsed/60),' min.'],userEmail);




