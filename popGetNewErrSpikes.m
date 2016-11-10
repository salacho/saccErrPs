function popGetNewErrSpikes(manSorted)
% function popGetNewErrSpikes(manSorted)
%
% Computes the cell array for spike data for all the sessions established
% in either Chico and Jonah manually sorted sessions, or in all sessions
% included in allSpikeSession.m
%
% The cell arrays are saved in their respective folders.
%
% INPUT
% manSorted:    logical. True if only manually sorted sessions for both
%               monkeys. False loads sessions in 'allSpikeSessions.m'
%
% Author : Andres 
% 
% Andres :  v1.0    :   22 Oct 2014. init


if manSorted
    %% Get spike cell arrays for manually sorted sessions
    [chicoManSortedSessions,jonahManSortedSessions] = manSortedSessions;
    
    %% For Chico
    for iSession = 1:length(chicoManSortedSessions)
        session = chicoManSortedSessions{iSession};
        dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
        ErrorInfo = setDefaultParams(session,dirs);
        disp(ErrorInfo)
        % Load already saved LFP epochs and spikes
        [~,~,~,~,ErrorInfo] = newErrSpikes(ErrorInfo);
        clear ErrorInfo
    end
    
    %% For Jonah
    for iSession = 1:length(jonahManSortedSessions)
        session = jonahManSortedSessions{iSession};
        dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
        ErrorInfo = setDefaultParams(session,dirs);
        disp(ErrorInfo)
        % Load already saved LFP epochs and spikes
        [~,~,~,~,ErrorInfo] = newErrSpikes(ErrorInfo);
        clear ErrorInfo
    end
    
else
    % Load sessionsList
    sessionsList = allSpikeSessions;
    
    for iSess = 1:length(sessionsList)
        session = sessionsList{iSess};
        dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
        ErrorInfo = setDefaultParams(session,dirs);
        disp(ErrorInfo)
        % Load already saved LFP epochs and spikes
        [~,~,~,~,ErrorInfo] = newErrSpikes(ErrorInfo);
        clear ErrorInfo
    end
end


    