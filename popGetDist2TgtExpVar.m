function popGetDist2TgtExpVar(popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt,sessionList)
% function popGetDist2TgtExpVar(popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt,sessionList)
%
%
%
%
%
%
% Andres    :   v1.0    :   init. 11 Nov 2014

%% Get and plot explained variance with values <= p-vals (ErrorInfo.analysis.ANOVA.pValCrit)
ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));

if ~isfield(ErrorInfo.analysis,'balanced')
    ErrorInfo.analysis.balanced = 1;
end

% dist12
[expVarDist12,nDist12,pValsDist12,muDist12,FDist12,ErrorInfo] = getEpochsExpVar(popDist1Epochs,popDist2Epochs,ErrorInfo);
ErrorInfo.analysis.typeVble = 'dist12';
popPlotDist2TgtExpVar(expVarDist12,pValsDist12,ErrorInfo)
clear expVarDist12 nDist12 pValsDist12 muDist12 FDist12

% dist23
[expVarDist23,nDist23,pValsDist23,muDist23,FDist23,ErrorInfo] = getEpochsExpVar(popDist2Epochs,popDist3Epochs,ErrorInfo);
ErrorInfo.analysis.typeVble = 'dist23';
popPlotDist2TgtExpVar(expVarDist23,pValsDist23,ErrorInfo)
clear expVarDist23 nDist23 pValsDist23 muDist23 FDist23

% dist13
[expVarDist13,nDist13,pValsDist13,muDist13,FDist13,ErrorInfo] = getEpochsExpVar(popDist1Epochs,popDist3Epochs,ErrorInfo);
ErrorInfo.analysis.typeVble = 'dist13';
popPlotDist2TgtExpVar(expVarDist13,pValsDist13,ErrorInfo)
clear expVarDist13 nDist13 pValsDist13 muDist13 FDist13

% dist123
[expVarDist123,nDist123,pValsDist123,muDist123,FDist123] = getDist2TgtExpVar(popDist1Epochs,popDist2Epochs,popDist3Epochs,popDistDcdTgt,ErrorInfo);
ErrorInfo.analysis.typeVble = 'dist123';
popPlotDist2TgtExpVar(expVarDist123,pValsDist123,ErrorInfo) 
sfn2014_SwapChannels_popPlotDist2TgtExpVar(expVarDist123,pValsDist123,ErrorInfo) 
clear expVarDist123 nDist123 pValsDist123 muDist123 FDist123




