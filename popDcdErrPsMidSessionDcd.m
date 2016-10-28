function popDcdErrPsMidSessionDcd
% function popDcdErrPsMidSessionDcd
%
% Runs error detection using a decoder trained with data from an agreggatted of sessions
% (half of the previous ones). All data is saved in a structure containing all params, 
% all sessions decoded and decoders used. All the data is used to train the decoder.
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
% i.e. 'popCS20120815-CS20130618-65-CS20130617-reg-oldDcd-[600-600ms]-[1.0-10Hz]-dcdPerf-bestParams.mat'
%
% Author    : Andres
% 
% andres    : 1.1   : init. 19 March 2014
% andres    : 1.1   : init. 20 March 2014. 

error('THIS CODE IS OLD, only supports Chico''s data, and has not been updated!!! You should be using ''popDcdErrPsPrevSessionTrain.m''')
return

%% First need all sessions with tehir decoded build using 'alltrain' in ErrorInfo.decoder.typeVal 
doMidSessions = 1;
if doMidSessions, numTrainSessions = 10; end

%% Dirs and Paths
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
[sessionList,sessionsBCIperf] = chicoBCIsessions;
nSessions = length(sessionList);
if numTrainSessions == 33
    midSessions = round(nSessions/2);
else
    midSessions = 0;
end

%% Initialize vbles
corrDcd     = nan(nSessions,1);
errorDcd    = nan(nSessions,1);
overallDcd  = nan(nSessions,1);
oldDecoders = cell(nSessions,1); oldDecoders{1} = 'none';

if doMidSessions
    %oldDcdMidSessions = sprintf('pop%s-%s-%i-%s',sessionList{midSessions+1},sessionList{end},midSessions,'midsessions');
    oldDcdMidSessions = sprintf('pop%s-%s-%i',sessionList{1},sessionList{midSessions},midSessions);
    oldDecoders(1:midSessions) = repmat({'none'},[midSessions,1]);
end

%% Start each session
for iSession = midSessions + 1:nSessions
    tStart = tic;
    session = sessionList{iSession};
    % Use previous session trained decoder or an aggregatted of half the sessions
    if doMidSessions
        oldSession = oldDcdMidSessions;             % half the sessions
    else
        oldSession = sessionList{iSession - 1};     %#ok<*UNRCH> % previous sessions.
    end
    oldDecoders{iSession} = oldSession;
    
    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    % Load epochs (this does not depend on decoding params)
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Update ErrorInfo
    ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
        availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf,oldSession);
    
    %% Old decoder
    if doMidSessions
        % Create fullname of decoder to load
        loadFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popTest');                 %#ok<*NASGU>
        loadDecoder = load(loadFilename);                                   % includes: newB, decoder, ErrorInfo
        ErrorInfo.decoder.oldDecoder = loadDecoder.oldB;
        % Updating dataTransfVals from 'oldSession' decoder to apply to the new one.
        ErrorInfo.decoder.dataTransfVals = loadDecoder.decoder.dataTransfVals;
    end
    
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
    emailme('dataconversionstate@gmail.com','DataConversionState','Finished oldDcd popTest DcdErrPs',['Finished ',session,' in ',num2str(tElapsed/60),' min.'],userEmail);
end

%% Saving decoded values for all params
dcdVals{1} = corrDcd;
dcdVals{2} = errorDcd;
dcdVals{3} = overallDcd;
dcdVals{4} = sessionList;
dcdVals{5} = oldDecoders;
dcdVals{6} = {'corrDcd','errorDcd','overallDcd','sessionList','oldDecoders'};

% Session for the population 
if doMidSessions
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{midSessions+1},sessionList{end},nSessions-midSessions,ErrorInfo.decoder.oldSession);
    rootFilename = createFileForm(decoder,ErrorInfo,'popTest');                 %#ok<*NASGU>
else
    % Session for the population
    if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
        ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{end},length(sessionList),'alltest');
    else
        ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
    end
    rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 %#ok<*NASGU>
end

saveFilename = sprintf('%s-dcdPerf-bestParams.mat',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList') 
save(saveFilename,'ErrorInfos','dcdVals') 

end