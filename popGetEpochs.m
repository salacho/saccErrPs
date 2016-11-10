function [popCorr,popIncorr,popErrorInfo] = popGetEpochs(sessionList)
% function [popCorr,popIncorr,popErrorInfo] = popGetEpochs(sessionList)
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
% popErrorInfo:        structure. Has fields:
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

for iSess = 1:length(sessionList)
    % Select sessions
    session = sessionList{iSess};
    fprintf('.\n.\n.\n%s...\n',session)
    
    % load paths and dirs
    dirs = initErrDirs('getRaw');               % Paths where all data is loaded from and where chronic Recordings analysis are saved
    ErrorInfo = setDefaultParams(session,dirs);
    
    % load files
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    disp('Done loading')
    
    % Initialize popErrorInfo structure
    if iSess == 1
        popErrorInfo = ErrorInfo;
        popErrorInfo.epochInfo.badChStDevFactor = 3;
        fields2Blank = {'corrDcdTgt','corrExpTgt','incorrDcdTgt','incorrExpTgt',...
            'corrPrevTrialDcdTgt','corrPrevTrialExpTgt','incorrPrevTrialDcdTgt','incorrPrevTrialExpTgt'};
        for iField = 1:length(fields2Blank)
            eval(sprintf('popErrorInfo.epochInfo.%s = [];',fields2Blank{iField}))
        end
        popErrorInfo.epochInfo.nCorr = 0;
        popErrorInfo.epochInfo.nError = 0;
        popErrorInfo.epochInfo.nCorrBad  = 0;
        popErrorInfo.epochInfo.nErrorBad = 0;
    end
    
    % Downsampling (and fixing dimensions)
    %[corrEpochs,incorrEpochs,ErrorInfo] = downSampEpochs(corrEpochs,incorrEpochs,ErrorInfo);

    % Remove bad trials
    ErrorInfo.epochInfo.badChStDevFactor = 3;
    [corrEpochs,incorrEpochs,ErrorInfo] = removeBadTrials(corrEpochs,incorrEpochs,ErrorInfo);

%     % Fix dimensionality
%     corrEpochs = fixEpochs3dims(corrEpochs);
%     incorrEpochs = fixEpochs3dims(incorrEpochs);
    
    % Add trials to dist2Tgt population
    popCorr = [popCorr  corrEpochs];
    popIncorr = [popIncorr  incorrEpochs];
    
    %% Update vals
    popErrorInfo.ErrorInfo{iSess} = ErrorInfo;
    
    %     popErrorInfo.signalProcess.badTrialsCorr = popErrorInfo.signalProcess.badTrialsCorr
    %     popErrorInfo.signalProcess.badTrialsIncorr = popErrorInfo.signalProcess.badTrialsCorr
    %     popErrorInfo.signalProcess.corrEpochsNoisyTrials = ErrorInfo.signalProcess.badTrialsCorr;
    %     popErrorInfo.signalProcess.badTrialsIncorr = ErrorInfo.signalProcess.badTrialsIncorr ;
    popErrorInfo.epochInfo.nCorrList(iSess) = ErrorInfo.epochInfo.nCorr;
    popErrorInfo.epochInfo.nErrorList(iSess) = ErrorInfo.epochInfo.nError;
    popErrorInfo.epochInfo.nCorrBadList(iSess)  = ErrorInfo.epochInfo.nCorrBad;
    popErrorInfo.epochInfo.nErrorBadList(iSess) = ErrorInfo.epochInfo.nErrorBad;

    popErrorInfo.epochInfo.nCorr = popErrorInfo.epochInfo.nCorr + ErrorInfo.epochInfo.nCorr;
    popErrorInfo.epochInfo.nError = popErrorInfo.epochInfo.nError + ErrorInfo.epochInfo.nError;
    popErrorInfo.epochInfo.nCorrBad  = popErrorInfo.epochInfo.nCorrBad + ErrorInfo.epochInfo.nCorrBad;
    popErrorInfo.epochInfo.nErrorBad = popErrorInfo.epochInfo.nErrorBad + ErrorInfo.epochInfo.nErrorBad;
    
    % Add true target and decoded target for each trial
    popErrorInfo.epochInfo.corrDcdTgt = [popErrorInfo.epochInfo.corrDcdTgt; ErrorInfo.epochInfo.corrDcdTgt];
    popErrorInfo.epochInfo.corrExpTgt = [popErrorInfo.epochInfo.corrExpTgt; ErrorInfo.epochInfo.corrExpTgt];
    popErrorInfo.epochInfo.incorrDcdTgt = [popErrorInfo.epochInfo.incorrDcdTgt; ErrorInfo.epochInfo.incorrDcdTgt];
    popErrorInfo.epochInfo.incorrExpTgt = [popErrorInfo.epochInfo.incorrExpTgt; ErrorInfo.epochInfo.incorrExpTgt];
    
    % Previous outcome info
    popErrorInfo.epochInfo.corrPrevTrialDcdTgt = [popErrorInfo.epochInfo.corrPrevTrialDcdTgt; ErrorInfo.epochInfo.corrPrevTrialDcdTgt];
    popErrorInfo.epochInfo.corrPrevTrialExpTgt = [popErrorInfo.epochInfo.corrPrevTrialExpTgt; ErrorInfo.epochInfo.corrPrevTrialExpTgt];
    popErrorInfo.epochInfo.incorrPrevTrialDcdTgt = [popErrorInfo.epochInfo.incorrPrevTrialDcdTgt; ErrorInfo.epochInfo.incorrPrevTrialDcdTgt];
    popErrorInfo.epochInfo.incorrPrevTrialExpTgt = [popErrorInfo.epochInfo.incorrPrevTrialExpTgt; ErrorInfo.epochInfo.incorrPrevTrialExpTgt];
    
    clear corrEpochs incorrEpochs
end
    
%% SaveErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
% Save the two structures
ErrorInfo.session = sprintf('pop%s-%s-%i',char(sessionList(1)),char(sessionList(end)),length(sessionList));
saveFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popEpochs');
fprintf('Saving population matrix in folder...\n%s\n',saveFilename)
save(saveFilename,'popCorr','popIncorr','popErrorInfo','sessionList','-v7.3')

end
   