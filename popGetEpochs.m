function [popCorr,popIncorr,popDcdTgt] = popGetEpochs(sessionList)
% function [popCorr,popIncorr,popDcdTgt] = popGetEpochs(sessionList)
% 
% Aggregates all the epochs for correct and incorrect trials for a list of
% sessions given by sessionList.
%
% INPUT
% sessionList:      cell array. Each element is a session name
%
% OUTPUT
% popCorr:          matrix [nChannels x nTrials x nSamples]. Correct trials
% popIncorr:        matrix [nChannels x nTrials x nSamples]. Incorrect trials
% popDcdTgt:        structure. Has fields:
%     corrDcdTgt:   vector. Decoded target for correctly decoded trials 
%     corrExpTgt:   vector. Expected (true) target for correct trials
%     incorrDcdTgt: vector. Decoded target for incorrectly decoded trials
%     incorrExpTgt: vector. expected target for incorrect trials
%
% Author:   Andres 
%
% Andres    :   v1.0    : init. Created 31 Oct 2014
% Andres    :   v2.0    : modified popGetTgt to get only dist2Tgt regarless 
%                         of true target location. 11 Nov 2014

popCorr = [];
popIncorr = [];
popDcdTgt.epochInfo = struct(...
    'corrDcdTgt',[],...
    'corrExpTgt',[],...
    'incorrDcdTgt',[],...
    'incorrExpTgt',[],...
    'corrPrevTrialDcdTgt',[],...
    'corrPrevTrialExpTgt',[],...
    'incorrPrevTrialDcdTgt',[],...
    'incorrPrevTrialExpTgt',[]);

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
    
    % Downsampling (and fixing dimensions)
    [corrEpochs,incorrEpochs,ErrorInfo] = downSampEpochs(corrEpochs,incorrEpochs,ErrorInfo);

%     % Fix dimensionality
%     corrEpochs = fixEpochs3dims(corrEpochs);
%     incorrEpochs = fixEpochs3dims(incorrEpochs);
    
    % Add trials to dist2Tgt population
    popCorr = [popCorr  corrEpochs];
    popIncorr = [popIncorr  incorrEpochs];
    
    % Add true target and decoded target for each trial
    popDcdTgt.epochInfo.corrDcdTgt = [popDcdTgt.epochInfo.corrDcdTgt; ErrorInfo.epochInfo.corrDcdTgt];
    popDcdTgt.epochInfo.corrExpTgt = [popDcdTgt.epochInfo.corrExpTgt; ErrorInfo.epochInfo.corrExpTgt];
    popDcdTgt.epochInfo.incorrDcdTgt = [popDcdTgt.epochInfo.incorrDcdTgt; ErrorInfo.epochInfo.incorrDcdTgt];
    popDcdTgt.epochInfo.incorrExpTgt = [popDcdTgt.epochInfo.incorrExpTgt; ErrorInfo.epochInfo.incorrExpTgt];
    
    % Previous outcome info
    popDcdTgt.epochInfo.corrPrevTrialDcdTgt = [popDcdTgt.epochInfo.corrPrevTrialDcdTgt; ErrorInfo.epochInfo.corrPrevTrialDcdTgt];
    popDcdTgt.epochInfo.corrPrevTrialExpTgt = [popDcdTgt.epochInfo.corrPrevTrialExpTgt; ErrorInfo.epochInfo.corrPrevTrialExpTgt];
    popDcdTgt.epochInfo.incorrPrevTrialDcdTgt = [popDcdTgt.epochInfo.incorrPrevTrialDcdTgt; ErrorInfo.epochInfo.incorrPrevTrialDcdTgt];
    popDcdTgt.epochInfo.incorrPrevTrialExpTgt = [popDcdTgt.epochInfo.incorrPrevTrialExpTgt; ErrorInfo.epochInfo.incorrPrevTrialExpTgt];
    
    clear corrEpochs incorrEpochs
end
    
%% SaveErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
% Save the two structures
ErrorInfo.session = sprintf('pop%s-%s-%i',char(sessionList(1)),char(sessionList(end)),length(sessionList));
saveFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popEpochs');
fprintf('Saving population matrix in folder...\n%s\n',saveFilename)
save(saveFilename,'popCorr','popIncorr','popDcdTgt','sessionList','ErrorInfo','-v7.3')

end
   