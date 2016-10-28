function [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
    getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo)
%
% function [corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo] =  ...
%    getCorrErrEpochsPrevTrialOutcome(corrEpochs,incorrEpochs,ErrorInfo)
%
%
%
%
% 23 Oct 2014

%% Find indexes for trials which previous outcome was correct 
indxCorrPrevTrials = ErrorInfo.epochInfo.corrPrevTrialDcdTgt == ErrorInfo.epochInfo.corrPrevTrialExpTgt;
indxIncorrPrevTrials = ErrorInfo.epochInfo.incorrPrevTrialDcdTgt == ErrorInfo.epochInfo.incorrPrevTrialExpTgt;

%% Correct and Incorrect epochs (corr/incorr)Epochs when previous trial was correct or incorrect (Corr/Err)Prev
corrEpochsCorrPrev  = corrEpochs(:,indxCorrPrevTrials,:);        % correct epochs when previous trial was correct
corrEpochsErrPrev   = corrEpochs(:,~indxCorrPrevTrials,:);        % correct epochs when previous trial was incorrect
incorrEpochsCorrPrev= incorrEpochs(:,indxIncorrPrevTrials,:);        % correct epochs when previous trial was correct
incorrEpochsErrPrev = incorrEpochs(:,~indxIncorrPrevTrials,:);        % correct epochs when previous trial was incorrect

% Number of trials 
ErrorInfo.epochInfo.nCorrEpochCorrPrevTrial   = sum(indxCorrPrevTrials);
ErrorInfo.epochInfo.nCorrEpochErrPrevTrial    = sum(~indxCorrPrevTrials);
ErrorInfo.epochInfo.nIncorrEpochCorrPrevTrial = sum(indxIncorrPrevTrials);
ErrorInfo.epochInfo.nIncorrEpochErrPrevTrial  = sum(~indxIncorrPrevTrials);
