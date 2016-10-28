function [popNumTrialsPerTgt,popNumTrialsPerDist2Tgt,ErrorInfo] = popGetErrNumTrialsPerTgt(sessionList)
%
%
%
%  popNumTrialsPerDist2Tgt [numSession nTgts ndist2Tgt]
%
%
% 09 Nov 2014

% Vbles
numDist2Tgt = 3;
nTgts = 6;
% Preallocate memory
popNumTrialsPerTgt = nan(length(sessionList),nTgts); 
popNumTrialsPerDist2Tgt = nan(length(sessionList),nTgts,numDist2Tgt); 

%% Start iteration
for iSess = 1:length(sessionList)
    % Select sessions
    session = sessionList{iSess};
    fprintf('.\n.\n.\n.\n%s...\n',session)
    
    % load paths and dirs
    dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    % load files
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    % Downsample files
    disp('Done loading')
    % Get tgtErrPs
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    disp('Done getting tgtErr')
    clear corrEpochs incorrEpochs
    % Get dist2Tgt
    [~,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    disp('Done dist2tgt')
    % Number Trials
    popNumTrialsPerTgt(iSess,:) = [tgtErrRPs(:).nIncorrTrials];
    popNumTrialsPerDist2Tgt(iSess,:,:) = numSampErrTrials;
    
    clear tgtErrRPs 
end

end

