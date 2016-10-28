function popDcdErrPsFixedDecoder(subjName,oldSessionDcd)
% function popDcdErrPsFixedDecoder
%
% Runs error detection using a unique decoder trained with data from previous
% session. All data is saved in a structure containing all params, all sessions decoded. 
% All the data is used to train the decoder.
%
% INPUT
% subjName:         string. Subject name. Can be 'chico' or 'jonah' 
% oldSessionDcd:    string. Root to load the decoder saved in the popAnalysis 
%                   folder. Common usage has the following structure:
%                   popFirstSession-lastSession-totalNumSessions.
%                   i.e. 'popCS20120815-CS20140411-80'
%
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
% 'popFirstSession-lastSession-numSessions-lastLoadDecoder-decoder-oldDcd-[preTime-portTimems]-[lowFreq-highFreqHz]-dcdPerf-bestParams'
% i.e. 'popCS20120815-CS20130618-65-popCS20130617-reg-oldDcd-[600-600ms]-[1.0-10Hz]-dcdPerf-bestParams.mat'
%
% Author    : Andres
% 
% andres    : 1.1   : init. 07 April 2014
% andres    : 1.2   : added Jonah copatibility and option to include current session

%% First need all sessions with their decoded build using 'alltrain' in 'errPopTrainMatrixPrevSessions.m' 
% subjName = 'jonah';


%% Old decoder
% switch subjName
%     case 'chico',
% % oldSessionDcd = 'popCS20140303-CS20140411-15';  %Chico
%         % oldSessionDcd = 'popCS20120815-CS20140411-80';  %Chico
%         %oldSessionDcd = 'popCS20140320-CS20140411-10';
%         %oldSessionDcd = 'popCS20140303-CS20140414-16';
%         %oldSessionDcd = 'popCS20140414-CS20140418-5';
%         oldSessionDcd = 'popCS20140409-CS20140423-11';
%     case 'jonah'
%         %oldSessionDcd = 'popJS20140318-JS20140328-9'; 
%         %oldSessionDcd = 'popJS20140414-JS20140418-5';
%         oldSessionDcd = 'popJS20140414-JS20140423-8';
%         % Jonah
%         %oldSessionDcd = 'popJS20140318-JS20140411-10';
% end

%% Dirs and Paths
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail = 'salacho1@gmail.com';

%% All sessions
switch subjName
    case 'chico', [sessionList,~] = chicoBCIsessions(0,1);        % beforeSessions = 0, onlyNew = 1
    case 'jonah', sessionList = jonahBCIsessions;
end
nSessions = length(sessionList);

%% Params iterated (that will change)
switch subjName
    case 'chico', availArrays = {'PFC','SEF','FEF'}; arrayIndx = [2,2];
        warning('Using SEF for Chico!!!')  %#ok<*WNTAG>
        rmvBaseline     = false;
        predFunction    = {'mean'};
        predSelectType  = {'none'};
        dataTransf      = {'zscore'};
    case 'jonah', availArrays = {'SEF','FEF','PFC'}; arrayIndx = [2,3];
        warning('Using FEF and PFC for Jonah!!!')  %#ok<*WNTAG>
        rmvBaseline     = false;
        predFunction    = {'mean'};
        predSelectType  = {'none'};
        dataTransf      = {'none'};
end

%% Initialize vbles
corrDcd     = nan(nSessions,1);
errorDcd    = nan(nSessions,1);
overallDcd  = nan(nSessions,1);
oldDecoders = cell(nSessions,1); oldDecoders{1} = 'none';

%% Checking files are for the same monkey
if strcmpi(oldSessionDcd(4),subjName(1))
    if strcmpi(oldSessionDcd(4),'c')
    else strcmpi(oldSessionDcd(4),'j')
    end
else  
   error('The input variables subjName and oldSessionDcd are not for the same monkey')
end

warning('Find the ''guion'' since 2 digit number of sessions, not last only!!!')
numTrainSessions = str2double(oldSessionDcd(end-1:end));

%% Start each session
for iSession = 1:nSessions
    tStart = tic;
    session = sessionList{iSession};            % current sessions
    oldDecoders{iSession} = oldSessionDcd;         % old decoder used

    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    % Load epochs (this does not depend on decoding params)
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Safeguard for empty corrEpochs and incorrEpochs matrix
    if any([isempty(corrEpochs),isempty(incorrEpochs)]), error('corrEpochs or incorrEpochs are empty matrices'); end

    %% Update ErrorInfo
    ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
        availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf,oldSessionDcd);
    
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
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s-%s',sessionList{1},sessionList{end},length(sessionList),oldSessionDcd,'alltest');
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
end

rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 %#ok<*NASGU>
saveFilename = sprintf('%s-dcdPerf-%iprevSessions-bestParams.mat',rootFilename,numTrainSessions);       % (AFSG 2014-3-22) was saveFilename = sprintf('%s-dcdPerf-bestParams.mat',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList') 
save(saveFilename,'ErrorInfos','dcdVals') 

end