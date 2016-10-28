function infoStr = getInfoStr(ErrorInfo)
% function infoStr = getInfoStr(ErrorInfo)
%
% Creates the diferent strings used for naming titles, axis and figures.
%
% INPUT
% ErrorInfo.epochInfo.typeRef
% ErrorInfo.plotInfo.stdError
% ErrorInfo.epochInfo.rmvNoisyErrPDone
% ErrorInfo.plotInfo.equalLimits
%
% OUTPUT
%
% Andres    : v1.0  : init. Created 03 Nov 2014

% Filter type and order
switch lower(ErrorInfo.epochInfo.filtType)
    case 'butter',  strFiltType = 'butt';
    otherwise,      strFiltType = 'error'; error('The filter type ''%s'' is not recognized...\n',ErrorInfo.epochInfo.filtType)
end

% Any re-referencing to the data?
switch ErrorInfo.epochInfo.typeRef
    case 'lfp',     strgRef = '';
    case 'lapla',   strgRef = '-lapla';
    case 'car',     strgRef = '-car';
end

% Using standar deviation or standard error?
if ErrorInfo.plotInfo.stdError, stdTxt = '-StError';
else stdTxt = '-StDev';
end

% Bad trials were removed?
if ErrorInfo.epochInfo.rmvNoisyErrPDone, noisyEpochStr = '-rmvNoisTrials';
else noisyEpochStr = '';
end

% Using equal range on Y axis for all plots?
if ErrorInfo.plotInfo.equalLimits, yLimTxt = '-equalY'; else yLimTxt = ''; end

% Downsampled data
if ErrorInfo.signalProcess.downSamp, downSampStr = sprintf('-downSamp%i',ErrorInfo.signalProcess.downSampFactor); else downSampStr = ''; end
 
% Specgram transform done
if ErrorInfo.plotInfo.specgram.transfDone
    switch lower(ErrorInfo.plotInfo.specgram.transfType)
        case 'freqzscore', strSpecTrans = '-freqzsc';
        case 'allzscore', strSpecTrans = '-allzsc';
        case 'norm', strSpecTrans = '-norm';
        case 'none',strSpecTrans = '';
        otherwise, strSpecTrans = '';
    end
else strSpecTrans = '';
end

% Spectrogram time and freq range
strSpecRange = sprintf('[%0.1f-%0.1fsecs]-[%i-%iHz]',ErrorInfo.plotInfo.specgram.tStart,ErrorInfo.plotInfo.specgram.tEnd,ErrorInfo.plotInfo.specgram.fStart,ErrorInfo.plotInfo.specgram.fEnd);

% Time and filter filename tail 
strSuffix = sprintf('%s[%i-%ims]-%s%i[%0.1f-%iHz]',downSampStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,strFiltType,ErrorInfo.epochInfo.filtOrder,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);

if strcmpi(ErrorInfo.session(1),'p'), strPrefix = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
else strPrefix = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session);
end

%% Adding all string vals to infoStr structure
infoStr.strgRef = strgRef;
infoStr.stdTxt = stdTxt;
infoStr.strFiltType = strFiltType;
infoStr.noisyEpochStr = noisyEpochStr;
infoStr.yLimTxt = yLimTxt;
infoStr.downSampStr = downSampStr;
infoStr.strSpecRange = strSpecRange;
infoStr.strPrefix = strPrefix;
infoStr.strSuffix = strSuffix;
infoStr.strSpecTrans = strSpecTrans;

% Aggregate of all strings
infoStr.signProcStr = sprintf('%s%s%s%s%s',stdTxt,yLimTxt,noisyEpochStr,strgRef);
 