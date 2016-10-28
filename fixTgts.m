function ErrorInfo = fixTgts(ErrorInfo,tgtErrRPs)
% function ErrorInfo = fixTgts(ErrorInfo)
%
% Fixes lack of target valus for some missing targets. Reposition values in
% proper target index.
%
% Andres    :   v1      : init. 20 Oct 2016   


nTgts = 6;
listTgts = 1:nTgts;
oldTgtErrRPs = tgtErrRPs;

if ErrorInfo.epochInfo.nTgts ~= nTgts

    fieldTxt = fields(tgtErrRPs(1));
    
    corrEpochs: [0x1 double]
    incorrEpochs: [0x1 double]
    incorrDcdTgt: [0x1 double]
    nIncorrDcdTgts: [0 0 0 0 0]
    nIncorrTrials: 0
    normIncorrDcdTgts: [NaN NaN NaN NaN NaN]
    
    
    % save old vals
    nCorrEpochsTgt = ErrorInfo.epochInfo.nCorrEpochsTgt;
    nIncorrEpochsTgt = ErrorInfo.epochInfo.nIncorrEpochsTgt;
    ratioCorrIncorr = ErrorInfo.epochInfo.ratioCorrIncorr;
    Tgts = ErrorInfo.epochInfo.Tgts;

    % Initially replace with zeros
    ErrorInfo.epochInfo.nCorrEpochsTgt = zeros(1,nTgts);
    ErrorInfo.epochInfo.nIncorrEpochsTgt = zeros(1,nTgts);
    ErrorInfo.epochInfo.ratioCorrIncorr = zeros(1,nTgts);
    ErrorInfo.epochInfo.Tgts = listTgts;

    % Replace vals with the original ones but now in proper location
    for iTgt=1:ErrorInfo.epochInfo.nTgts
        newTgt = Tgts(iTgt);
        ErrorInfo.epochInfo.nCorrEpochsTgt(newTgt) = nCorrEpochsTgt(iTgt);
        ErrorInfo.epochInfo.nIncorrEpochsTgt(newTgt) = nIncorrEpochsTgt(iTgt);
        ErrorInfo.epochInfo.ratioCorrIncorr(newTgt) = ratioCorrIncorr(iTgt);
    end
    ErrorInfo.epochInfo.nTgts = nTgts;
end

end   
                         