function popGetExpVar(popCorr,popIncorr,popDcdTgt,sessionList)
% function popGetExpVar(popCorr,popIncorr,popDcdTgt,sessionList)
%
%
%
%
%
%
% Andres    :   v1.0    :   init. 12 Nov 2014

%% Get and plot explained variance with values <= p-vals (ErrorInfo.analysis.ANOVA.pValCrit)
ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));

if ~isfield(ErrorInfo.analysis,'balanced')
    ErrorInfo.analysis.balanced = 1;
end

% Population correct vs. incorrect trials
[expVar,n,pVals,mu,F,ErrorInfo] = getEpochsExpVar(popCorr,popIncorr,ErrorInfo);
ErrorInfo.analysis.typeVble = 'popCorrIncorr';
popPlotCorrIncorrExpVar(expVar,pVals,ErrorInfo)



