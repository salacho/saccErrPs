function [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(mainParams)
% function [corrEpochs,incorrEpochs,eyeTraces,ErrorInfo] = newErrRPs(mainParams);
%
% Calculates epochs for ErrRPs and eye traces for correct and error trials. Parameters in
% mainParams determine the frequency band and the length of the epochs (for ErrPs).
% Baseline values should all be similar but for analysis purposes we
% separate them. They corr and incorr for baseline should depend on the
% previous trial, not the present one -> chance of different baseline given
% a previous error.
%
% INPUT
% mainParams:               Structure. Contains fields related to the
%                           filtering and
% OUTPUT
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% eyeTraces:                Structure with all eye traces. These are:
%         corrPupil:        matrix. Correct pupil epochs in the form [numChs numEpochs lengthEpoch].
%         corrBasePupil:    matrix. Correct pupil baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         incorrPupil:      matrix. Incorrect pupil epochs in the form [numChs numEpochs lengthEpoch].
%         incorrBasePupil:  matrix. Incorrect pupil baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         corrEyeX:         matrix. correct eye X epochs in the form [numChs numEpochs lengthEpoch].
%         corrBaseEyeX:     matrix. Correct eye X baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         incorrEyeX:       matrix. Incorrect eye X epochs in the form [numChs numEpochs lengthEpoch].
%         incorrBaseEyeX:  matrix. Incorrect eye X baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         corrEyeY:         matrix. correct eye Y epochs in the form [numChs numEpochs lengthEpoch].
%         corrBaseEyeY:     matrix. Correct eye Y baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numCorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         incorrEyeY:       matrix. Incorrect eye Y epochs in the form [numChs numEpochs lengthEpoch].
%         incorrBaseEyeY:  matrix. Incorrect eye Y baseline given by iti in ErrorInfo.Behav.dur.itiDur. 
%                           It has the form [numChs numIncorrectEpochs ErrorInfo.Behav.dur.itiDur*Fs].
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and downsampling(if any).
%                           Also, it has the decoded and expected target values: 
%                           'corrDcdTgt', 'corrExpTgt','incorrDcdTgt', 'incorrExpTgt'.
% ErrorInfo:                ErrRps info structure. The structure 'epochInfo' is included
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% Author    : Andres 
%
% andres    : 1.1   : Initial. Created 22 July 2013
% andres    : 1.2   : Added eyeTraces. 02 Dec. 2013
% andres    : 1.3   : Removed and unified params. 27 Feb 2014

% Analysis variables
blockType = mainParams.epochInfo.blockType;       % Zero. Usually three blocks, 1) training, 2) ordered targets, 3) random targets
decodOnly = mainParams.epochInfo.decodOnly;       % True if selecting only trials from the block where decoding occurs

%% Initial values and paths
% Loading files
ErrorInfo = mainParams;

%% Defining paths
% Path and header for saved files
ErrorInfo.dirs.saveFileHeader = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session);
% Path to save files
savePath = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session);
ErrorInfo.dirs.saveFilename = savePath;
% Creating folder to save results if not there already
if ~(exist(savePath,'dir') == 7)
    mkdir(ErrorInfo.dirs.DataOut,ErrorInfo.session);      % Create folder
end

%% Reads event files and creates structure with events for each outcome
% (errors: correct target, incorrect, fixation break, saccade break, etc)
[ErrorInfo,OutcomeInfo] = getOutcmInfo(ErrorInfo,blockType,decodOnly);        %Get all events and possible outcomes

%% Get info for trials after error trials
% Loading lfps, 'CAR' data or laplacians using typeRef as flag. typeRef can
% be 'lapla' for laplacians, 'lfp' for regular lfp or 'car' for common
% averaged signals subtracting the CAR of lfp signals for each array

% Getting epochs from start of trial to start of iti + 500 ms
if ErrorInfo.epochInfo.doErrPs
    [corrEpochs,incorrEpochs,ErrorInfo] = getErrRPs(OutcomeInfo,ErrorInfo);
    % Gettig size of loaded files
    ErrorInfo.epochInfo.nCorr = size(corrEpochs,2);
    ErrorInfo.epochInfo.nError = size(incorrEpochs,2);
end

% Getting eye traces (if chosen to do so)
if ErrorInfo.eyeTraces.doEyes
    [eyeTraces,ErrorInfo] = getEyeTraces(OutcomeInfo,ErrorInfo);
else
    eyeTraces = [];
end

