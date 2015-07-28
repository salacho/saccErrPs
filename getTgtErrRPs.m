function [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
% function [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
% 
% This function separates the epochs per target location, both for the
% correct and incorrect matrices.
%
% INPUT
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% ErrorInfo:                ErrRps info structure. Has all the fields
%                           related to the analysis of ErrRPs.
%         session:          string. Usually in the form 'CS20120925'
%         filedate:         integer. Date in the order YYYMMDD: i.e. 20120925
%         dirs:             structure. Has the DataIn ans DataOut path for reading and saving files respectively.
%         Behav:            structure with all behavioral info from the
%                           data conversion Event functions.
%         EventInfo:        structure. Has all the events obtained in
%                           getOutcomeInfo.m
%         BCIparams:        structure. Decoder parameters (blockType and decodeOnly)
%         tgtDirections:    vector. Target locations in radians. 
%         trialInfo:        structure. Similar to EventInfo but specific to
%                           correct and incorrect trials
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% OUTPUT
% tgtErrRPs:                cell with numTargets cells. Each cell has two
%                           field, one is corrEpochs (correct epochs for this expected target), 
%                           the other incorrEpochs (error epochs for this
%                           expected target).
%         corrEpochs:       matrix. Correct epochs for the specific target.
%                           [numChnls,numEpochs,numDatapoints]
%         incorrEpochs:     matrix. Incorrect epochs for the specific
%                           target. [numChnls,numEpochs,numDatapoints]
%        incorrDcdTgt:      vector. Decoded target for error (incorrect)
%                           epochs.
% ErrorInfo:                ErrRps info structure updated 
% 
% Andres v1.0
% Created 14 June 2013
% Last modified 11 July 2013

Tgts = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);

for iTgt = 1:nTgts
    % Correct epochs
    iTgtCorrEpochs = (Tgts(iTgt) == ErrorInfo.epochInfo.corrExpTgt);
    tgtErrRPs(iTgt).corrEpochs = corrEpochs(:,iTgtCorrEpochs,:);
    % Incorrect epochs
    iTgtIncorrEpochs = (Tgts(iTgt) == ErrorInfo.epochInfo.incorrExpTgt);
    tgtErrRPs(iTgt).incorrEpochs = incorrEpochs(:,iTgtIncorrEpochs,:);
    tgtErrRPs(iTgt).incorrDcdTgt = ErrorInfo.epochInfo.incorrDcdTgt(iTgtIncorrEpochs);
%     ErrorInfo.epochInfo.corrDcdTgt 
    ErrorInfo.epochInfo.nCorrEpochsTgt(iTgt) = size(tgtErrRPs(iTgt).corrEpochs,2);
    ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) = size(tgtErrRPs(iTgt).incorrEpochs,2);
	ErrorInfo.epochInfo.ratioCorrIncorr(iTgt) = ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt)./ErrorInfo.epochInfo.nCorrEpochsTgt(iTgt);
end

ErrorInfo.epochInfo.Tgts = Tgts;
ErrorInfo.epochInfo.nTgts = nTgts;