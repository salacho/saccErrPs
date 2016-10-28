function popDcdErrPsPrevSessionTrain(subjName,numTrainSessions)
% function popDcdErrPsPrevSessionTrain
%
% Runs error detection using a decoder trained with data from a previous
% session (the one from the last session or from previous sessions). 
% All data is saved in a structure containing all params, all sessions decoded 
% and decoders used. 
% 
% INPUT 
% subjName:             string. Name of the subject. Can be 'chico' or
%                       'jonah'. Determines what session list are used for 
%                       the training.
% numTrainSessions:     integer. Number of previous sessions used to train
%                       a decoder. The sessions chosen come from the list
%                       loaded from chicoBCIsessions or jonahBCISessions 
%                       (for Chico and Jonah respectively) and are automatically 
%                       extracted from this list.  The files loaded are in the 
%                       popAnalysis folder under the following naming schema:
%                       popFirstSession-LastSession-numTrainSessions-decoderUsed-train-[minTimeWind-maxTimeWindowsms]-[lowFiltBound-HighFiltBound]-predictFunct-arrays-featuresTimeWindowsUsed.mat        
%                       e.g. 'popJS20140325-JS20140327-3-reg-train-[600-600ms]-[1.0-10Hz]-mn-FEF-PFC-50-100-100-150-150-250-250-350-350-600.mat'
% OUTPUT
% 
% ErrorInfos:       cell. [numSessions x 1]. Contains all the ErrorInfo structure for each session trained.       
% dcdVals: 
%     dcdVals{1}:   matrix. Contains the values stored in 'corrDcd'. The decoder performance for correct trials.
%     dcdVals{2}:   matrix. Contains the values stored in 'errorDcd'. The decoder performance for incorrect/error trials.
%     dcdVals{3}:   matrix. Contains the values stored in 'overallDcd'. The decoder performance for all (correct and incorrect) trials.
%     dcdVals{4}:   cell. [numSessions x 1]. Contains the list of sessions, named 'sessionList'.
%     dcdVals{5}:   cell. [numSessions-1 x 1]. Contains the list of the session name for the trained decoder, named 'oldDecoders'.
%     dcdVals{6}:   cell. Contains the list of the original names of the other values in the cell structure. 
%                   Usually has: {'corrDcd','errorDcd','overallDcd','sessionList','oldDecoders'}. 
%                   This means dcdVals{1} = 'corrDcd'; dcdVals{2} = 'errorDcd'; ...
% 
% All these data is saved in disk. The naming scheme used has the following structure: 
% 'popFirstSession-lastSession-numSessions-lastLoadDecoder-decoder-oldDcd-[preTime-portTimems]-[lowFreq-highFreqHz]-dcdPerf-numTrainSessions'prevSessions'-bestParams'
% i.e. 'popCS20120815-CS20130618-65-CS20130617-reg-oldDcd-[600-600ms]-[1.0-10Hz]-dcdPerf-1prevSessions-bestParams.mat'
%
% Author    : Andres
% 
% andres    : 1.1   : init. 19 March 2014
% andres    : 1.2   : added Jonah compatibility and cleaned up the code. 11April 2014

%% First need all sessions with their decoded build using 'alltrain' in 'popTrainMatrixPrevSessions.m' 
% subjName = 'jonah';
% numTrainSessions = 10;

%% Dirs and Paths
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail = 'salacho1@gmail.com';

%% Params iterated (that will change)
switch subjName
    case 'chico', availArrays = {'PFC','SEF','FEF'}; arrayIndx  = [2,2];
        warning('Using SEF for Chico!!!')  %#ok<*WNTAG>
        rmvBaseline     = false;
        predFunction    = {'mean'};
        predSelectType  = {'none'};
        dataTransf      = {'zscore'};
    case 'jonah', availArrays = {'SEF','FEF','PFC'}; arrayIndx  = [2,3];
        warning('Using FEF and PFC for Jonah!!!')  %#ok<*WNTAG>
        rmvBaseline     = false;
        predFunction    = {'mean'};
        predSelectType  = {'none'};
        dataTransf      = {'none'};
end

%% All sessions
switch subjName
    case 'chico', [sessionList,~] = chicoBCIsessions(0,0);        % beforeSessions = 0, onlyNew = 1
    case 'jonah', [sessionList,~] = jonahBCIsessions;
end
nSessions = length(sessionList);

%% Initialize vbles
corrDcd     = nan(nSessions,1);
errorDcd    = nan(nSessions,1);
overallDcd  = nan(nSessions,1);
oldDecoders = cell(nSessions,1); oldDecoders{1} = 'none';

%% Start each session
for iSession = numTrainSessions + 1:nSessions
    tStart = tic;
    session = sessionList{iSession};
    
    trainSessions = sessionList(iSession - numTrainSessions:iSession-1);
    firstSession = trainSessions{1};
    lastSession = trainSessions{end};
    
    %Use previous session trained decoder or an aggregatted of half the sessions
    oldSession     = sprintf('pop%s-%s-%i',firstSession,lastSession,numTrainSessions);      % AFSG (2014-03-21) was oldSession = sessionList{iSession - 1};     % previous sessions.
    oldDecoders{iSession} = oldSession;
    
    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    % Load epochs (this does not depend on decoding params)
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Safeguard for empty corrEpochs and incorrEpochs matrix
    if any([isempty(corrEpochs),isempty(incorrEpochs)]), error('corrEpochs or incorrEpochs are empty matrices'); end
    
    %% Update ErrorInfo
    ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
        availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf,oldSession);
    
    %% Signal processing
    [corrEpochsProcess,incorrEpochsProcess,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
    
    %% Feature extraction and selection
    [Xvals,ErrorInfo] = selectFeatures(corrEpochsProcess,incorrEpochsProcess,ErrorInfo);
    
    %% Detecting presence of ErrPs
    [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo);
    %Best Dcd. Perf.: SEF-array	0Base	mean-predFun  none-predSel    zscore-dataTransf
    
    %% Save all results
    ErrorInfos{iSession} = ErrorInfo;
    corrDcd(iSession)    = decoder.performance.corrDcd; %#ok<*AGROW>
    errorDcd(iSession)   = decoder.performance.errorDcd;
    overallDcd(iSession) = decoder.performance.overallDcd;
    
    %% Time
    tElapsed = toc(tStart);
    sprintf('It took %0.2f seconds to run session %s...\n',tElapsed, session)
    disp('')
    %% Email me, end of ErrP analysis
    emailme('dataconversionstate@gmail.com','DataConversionState','Finished allTest DcdErrPs',['Finished ',session,' in ',num2str(tElapsed/60),' min.'],userEmail);
end

%% Saving decoded values for all params
dcdVals{1} = corrDcd;
dcdVals{2} = errorDcd;
dcdVals{3} = overallDcd;
dcdVals{4} = sessionList;
dcdVals{5} = oldDecoders;
dcdVals{6} = {'corrDcd','errorDcd','overallDcd','sessionList','oldDecoders'};

% Session for the population 
if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{end},length(sessionList),'alltest');
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
end

rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 %#ok<*NASGU>
saveFilename = sprintf('%s-dcdPerf-%iprevSessions-bestParams.mat',rootFilename,numTrainSessions);       % (AFSG 2014-3-22) was saveFilename = sprintf('%s-dcdPerf-bestParams.mat',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList') 
save(saveFilename,'ErrorInfos','dcdVals') 

end