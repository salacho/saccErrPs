function bigTrainingData = getBigTrainingData(sessionsList)
% function nameBigTrainingData = getBigTrainingData(sessionsList)
%
% Creates a big training data set that follows the same structure as a
% regular sata set. Takes into account the type of decoder, params and
% windows to be used by the testing decoder.
%
% INPUT
% sessionList:      cell. {numSessions x 1}. List the names of the sessions
%
%
%
%
%

%sessionsList = chicoBCIsessions;
nSessions = length(sessionsList);
cumXvals = [];

for iSession = 1:nSessions
    session = sessionsList{iSession};
    dirs = initErrDirs;                             % Paths where all data is loaded from and where chronic Recordings analysis are saved
    mainParams = setDefaultParams(session,dirs);    % disp(mainParams)
    if mainParams.epochInfo.loadFile
        [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(mainParams);     % loading already saved file
    else
        [corrEpochs,incorrEpochs,~,ErrorInfo] = newErrRPs(mainParams);      % Running the whole process, not loading
        warning('File does not exist for session %s',session)                       %#ok<*WNTAG>
    end
    [corrEpochs,incorrEpochs,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);     % Signal processing
    [Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo);          % Feature extraction and selection

    cumXvals = [cumXvals; Xvals];
    
    clear corrEpochs incorrEpochs Xvals
end


bigDataSession = sprintf('%s-s-%i',sessionsList{1},sessionsList{nSessions},nSessions);
save(sprintf('%s.mat',saveFilename))
bigTrainingData = saveFilename;


% Saving population decoding values
if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionsList{1},sessionsList{nSessions},nSessions,ErrorInfo.decoder.oldSession);
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionsList{1},sessionsList{nSessions},nSessions);
end

saveFilename = createFileForm(#popDcdResults.decoder{1}#,ErrorInfo,'decoder');                 %#ok<*NASGU>


end

