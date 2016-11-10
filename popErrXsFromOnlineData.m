function popErrXsFromOnlineData

subjName = 'jonah';
numTrainSessions = 2;
maxNumSessions = 2;

%% Paths and email
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail = 'salacho1@gmail.com';

%% All sessions
sessionList = {'JS20140415';'JS20140416'};
nSessions = length(sessionList);

availArrays = {'SEF','FEF','PFC'};
arrayIndx = [2,3];
warning('Using FEF and PFC for Jonah!!!')  %#ok<*WNTAG>
rmvBaseline     = false;
predFunction    = {'mean'};
predSelectType  = {'none'};
dataTransf      = {'none'};

numIters = nSessions - numTrainSessions;
if numIters == 0, numIters = 1; end

trainSessions = sessionList;
firstSession = trainSessions{1};
lastSession = trainSessions{end};

%% Initialize vbles
popXvals = [];
popYvals = [];
popNumTrials.all = 0;
kk = 0;

for iTrainSession = 1:numTrainSessions              % AFSG (2014-03-21) was for iSession = 1:lastSession
    kk = kk + 1;
    tStart = tic;
    session = trainSessions{iTrainSession};         % AFSG (2014-03-21) was session = sessionList{iSession};
    popSessions{kk} = session;
    
    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    %% Update ErrorInfo
    ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
        availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf);
    
    %% Reinforcing alltrain and no load Decoder
    warning('Check code since this way of updating fields is not very efficient!!!...turns everything into training sessions')
    ErrorInfo.decoder.loadDecoder = 0;
    ErrorInfo.decoder.typeVal = 'alltrain';
    disp(ErrorInfo.decoder)
    
    %% Loading online errXs
    bciDataFilename = fullfile(strrep(dirs.DataIn,'mat','raw'),session,[session,'-data.mat']);
    bciData = load(bciDataFilename);
    
    % Get trials that were decoded (correct and incorrect)
    bciTrials = ~isnan(bciData.bci.ErrPs.decoder.feedbackEvt);
    numBCItrials = sum(bciTrials);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Testing decoder performanced using a newSession %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Remember that this coded labels Y with ones when an error is found, hence
    % ~(trials == 25), ones for those that are not correct.
    errTrials = (bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 11);       % trials that are not correct -> 1
    corrTrials = (bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 25);      % trials that are not correct -> 1
    nError = sum(errTrials);
    nCorr = sum(corrTrials);
    
    % New epochs
    if isfield(bciData,'errXs'),
        errXs = bciData.errXs(bciTrials,:);
        errYs = errTrials;
    else error('The field errXs does not exist for %s data',newSession);
    end
    
    popXvals = [popXvals; errXs];
    popYvals = [popYvals; errYs];
    popNumTrials.all        = popNumTrials.all + length(errYs);
    popNumTrials.Corr(kk)   = nCorr;
    popNumTrials.Error(kk)  = nError;
end

ErrorInfo.session = sprintf('pop%s-%s-%i',firstSession,lastSession,numTrainSessions);
ErrorInfo.featSelect.trialsPerm = 1;

ErrorInfo.featSelect.Yvals = popYvals;
[ErrorInfo,decoder] = decodeErrRPs(popXvals,ErrorInfo);             % this step saves the decoder that shall be used later to check error detection

%% Saving the Xtrain
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

popJS20140415-JS20140416-2

