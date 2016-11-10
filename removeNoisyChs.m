function [newCorrEpochs,newIncorrEpochs,ErrorInfo] = removeNoisyChs(corrEpochs,incorrEpochs,ErrorInfo)
% function [newCorrEpochs,newIncorrEpochs,ErrorInfo] = removeNoisyChs(corrEpochs,incorrEpochs,ErrorInfo)
%
%
%
%
%
%
%
% Author : Andres.
% 
% Andres :  init    : 30 Oct 2014
% Andres :  

ch2StDevAbove
ErrorInfo.chList

%% Remove bad channels using a bad channels list
ErrorInfo.epochInfo.rmvNoisyChs         = false;    % logical, removes completely from analysis the bad channels
%ErrorInfo.epochInfo.rmvNoisyChsDone     = false;    % logical. Flag to state bad channels have been removed from all files
ErrorInfo.epochInfo.noisyChsList        = [];       % matrix [3 x chNumbers]. In case there is a list of bad channels to remove due to known problems in specific channels

if ErrorInfo.epochInfo.rmvNoisyChs

    
    goodChs
    
    ErrorInfo.nChs = length(goodChs);
    ErrorInfo.epochInfo.nChs
    ErrorInfo.epochInfo.chList

end

% This can happen later 
ErrorInfo.epochInfo.rmvNoisyErrP