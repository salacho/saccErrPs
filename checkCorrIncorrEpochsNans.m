function anyNanInSessions = checkCorrIncorrEpochsNans
% function anyNanInSessions = checkCorrIncorrEpochsNans
%
% Loads all files with correct and incorrect epochs for the set filtering 
% boundaries and window size and checks if there are any NaNsfor each
% channel. In the past, all the NaNs seemed to be present in the FEF array.
% Sessions are loaded from chicoBCIsessions.m located in the 'helpers'
% folder.
%
% OUTPUT
% anyNanInSessions:     structure. Contains the fields: 'sessions', 
%                       'anyCorr' and 'anyIncorr'. 
%
% Author    : Andres
% andres    : 1.1   : init. 12 March 2014


%% Paths
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved

%% Load all sessions
cd ../helpers/;
sessionList = chicoBCIsessions;
cd ../ErrRPs/;

%% Iterate all sessions
for iSession = 1:length(sessionList)
    session = sessionList{iSession};
    fprintf('Checking presence of nans in session %s...\n',session)
    %% Params
    mainParams = setDefaultParams(session,dirs);
    
    %% Load already saved epochs
    if mainParams.epochInfo.loadFile
        [corrEpochs,incorrEpochs,~,~] = loadErrRPs(mainParams);
    else
        warning('That files has not been created!!!')
        % Running the whole process, not loading
        [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(mainParams);
        corrEpochs = 1;
        incorrEpochs = 1;
    end
    
    %% Store values
    anyNanInSessions(iSession).session   = session;
    anyNanInSessions(iSession).anyCorr   = squeeze(sum(sum(isnan(corrEpochs),2),3));
    anyNanInSessions(iSession).anyIncorr = squeeze(sum(sum(isnan(incorrEpochs),2),3));
    
    % Clear all vbles  
    clear ErrorInfo corrEpochs incorrEpochs mainParams 
    disp('');
end

% plot(squeeze(sum(sum(isnan(corrEpochs)))),'*g'), hold on
% plot(squeeze(sum(sum(isnan(incorrEpochs)))),'r')

