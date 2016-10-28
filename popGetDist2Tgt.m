function [popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt] = popGetDist2Tgt(sessionList)
%
%
%
%
%
%
%
% Author:   Andres 
%
% Andres    :   v1.0    : init. Created 31 Oct 2014
% Andres    :   v2.0    : modified popGetTgt to get only dist2Tgt regarless 
%                         of true target location. 11 Nov 2014

%% Check if epochs for all sessions and target are already available
if nargin == 1
%% If only sessionList so need to load each session
disp('Running dist2tgt for each session from scratch...')
%popCorrEpochs = [];

popDist1Epochs = [];
popDist2Epochs = [];
popDist3Epochs = [];
popDistDcdTgt = repmat(struct(...
    'dcdTgt',[],...
    'expTgt',[]),...
    [3 1]);

for iSess = 1:length(sessionList)
    % Select sessions
    session = sessionList{iSess};
    fprintf('.\n.\n.\n%s...\n',session)
    
    % load paths and dirs
    dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    
    % load files
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    disp('Done loading')
    
    % Downsampling files!! Finally!!
    [corrEpochs,incorrEpochs,ErrorInfo] = downSampEpochs(corrEpochs,incorrEpochs,ErrorInfo);
    
    % Get tgtErrPs
    [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
    
    % pop of correct epochs
    % Running out RAM of memory. Need another computer!!
    %popCorrEpochs = [popCorrEpochs corrEpochs];
    clear corrEpochs incorrEpochs
    
    % Get dist2Tgt
    disp('Done getting tgtErr')
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
    disp('Done dist2tgt')
    clear tgtErrRPs
    
    % Get dist2Tgt regarless of true target
    [dist1Epochs,dist2Epochs,dist3Epochs,distDcdTgt] = getDist2Tgt(tgt2DistEpochs,ErrorInfo);
    clear tgt2DistEpochs
    % Add trials to dist2Tgt population
    popDist1Epochs = [popDist1Epochs dist1Epochs];
    popDist2Epochs = [popDist2Epochs dist2Epochs];
    popDist3Epochs = [popDist3Epochs dist3Epochs];
    
    % Add true target and decoded target for each trial
    for iDist = 1:3
        popDistDcdTgt(iDist).dcdTgt = [popDistDcdTgt(iDist).dcdTgt distDcdTgt(iDist).dcdTgt];
        popDistDcdTgt(iDist).expTgt = [popDistDcdTgt(iDist).expTgt distDcdTgt(iDist).expTgt];
    end
    
    clear dist1Epochs dist2Epochs dist3Epochs distDcdTgt
end
else
    %% If since popTgtErrPs are available, only separate dist2tgt for population 
    disp('Running dist2tgt on popTgtErrPs...')
    [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(popTgtErrPs,popDcdTgt);  $$ changed ErrorInfo for popDcdTgt!!!!

    
end
    
%% Save
ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
% Save the two structures
saveFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popDist2Tgt');
fprintf('Saving population matrix in folder...\n%s\n',saveFilename)
%save(saveFilename,'popCorrEpochs','popDist1Epochs','popDist2Epochs','popDist3Epochs','popDistDcdTgt','sessionList','ErrorInfo','-v7.3')
save(saveFilename,'popDist1Epochs','popDist2Epochs','popDist3Epochs','popDistDcdTgt','sessionList','ErrorInfo','-v7.3')

end
