function popMeanErrRPs%(sessionList,dataType)
%
%
%
%
%
%
%
%
%
% sessionList = {'CS20120816';'CS20120817';...
%     'CS20120912';'CS20120913';'CS20120914';...
%     'CS20120918';'CS20120919';'CS20120920';'CS20120921';...
%     'CS20120925';'CS20120926';'CS20120927';'CS20120928';...
%     'CS20121001';'CS20121002';'CS20121003';'CS20121004';'CS20121005';...
%     'CS20130410'};
% sessionList = {'CS20121001';'CS20121002';'CS20121003';'CS20121004';'CS20121005'};
dataTypes = {'lfp'};

% Basic params to load data
nChs = 96;
dataLen = 1201;

% Pre-allocating memory for popMeanEpochs
numSessions = length(sessionList);
popCorrEpochs = nan(numSessions,nChs,dataLen);
popIncorrEpochs = nan(numSessions,nChs,dataLen);
popMeanCorrEpochs = zeros(nChs,dataLen);
popMeanIncorrEpochs = zeros(nChs,dataLen);

% Loading correct and error mean epochs
for iSes = 1:numSessions
    % Session
    session = sessionList{iSes};
    % Load each session 
    ErrRPs = loadErrRPs(session);
    % Extract the mean correct and error epochs from ErrRPs
    popMeanCorrEpochs = popMeanCorrEpochs + squeeze(mean(ErrRPs.corrEpochs,2));         % correct mean epochs
    popMeanIncorrEpochs = popMeanIncorrEpochs + squeeze(mean(ErrRPs.incorrEpochs,2));   % error mean epochs
    
    % All sessions epochs to get std vals
    popCorrEpochs(iSes,:,:) = squeeze(mean(ErrRPs.corrEpochs,2));           % correct epochs
    popIncorrEpochs(iSes,:,:) = squeeze(mean(ErrRPs.incorrEpochs,2));       % collective error epochs
    % Error Info
    popErrorInfos(iSes) = ErrRPs.ErrorInfo;                                     % info structure

    % Epochs per target location
    %[tgtErrRPs,ErrorInfo] = getTgtErrRPs(ErrRPs.corrEpochs,ErrRPs.incorrEpochs,popErrorInfos(iSes));
end

% Population std
popStdCorrEpochs = squeeze(std(popCorrEpochs,0,1));         % std on all sessions for correct epochs
popStdIncorrEpochs = squeeze(std(popIncorrEpochs,0,1));     % std on all sessions for error epochs

% Population means
popMeanCorrEpochs = popMeanCorrEpochs/numSessions;
popMeanIncorrEpochs = popMeanIncorrEpochs/numSessions; 
popErrorInfo = popErrorInfos(1);
popErrorInfo.session = sprintf('pop%s-%s-%i',popErrorInfos(1).session,popErrorInfos(end).session,length(sessionList));

% Plotting params
popErrorInfo.visiblePlot = 'off';
popErrorInfo.savePlot = true;

% Creating folder to save population analysis
popErrorInfo.dirs.popDataOut = fullfile(popErrorInfo.dirs.DataOut,'\popAnalysis');
if ~(exist(popErrorInfo.dirs.popDataOut,'dir') == 7)
    mkdir(popErrorInfo.dirs.DataOut,'popAnalysis');      % Create folder
end

% plotting popMeanEpochs
popMeanPlotErrRPs(popMeanCorrEpochs,popMeanIncorrEpochs,popStdCorrEpochs,popStdIncorrEpochs,popErrorInfo)

% Per target pop means





