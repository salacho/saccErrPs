function popDist2TgtAll = popDist2Tgt_allTgtTogether(popDist2Tgt)
% function popDist2TgtAll = popDist2Tgt_allTgtTogether(popDist2Tgt)
%
% Need data from popMainErrPs.m from population from Chico or Jonah
%
% INPUT
% popDist2Tgt
%
% OUTPUT
% popDist2TgtAll
%     dist1 
%     dist2 
%     dist3 
%     numEpochsPerDist 
%     normNumEpochsPerDist 
%     nIncorrTrials
%
%
%
% 23 Nov. 2016

nTgt = 6;

% pre-allocate memory
popDist2TgtAll.dist1 = [];
popDist2TgtAll.dist2 = [];
popDist2TgtAll.dist3 = [];
popDist2TgtAll.numEpochsPerDist = [0 0 0];

% Iterat
for iTgt = 1:nTgt;
    popDist2TgtAll.dist1 = cat(2,popDist2TgtAll.dist1,popDist2Tgt(iTgt).epochDist1);
    popDist2TgtAll.dist2 = cat(2,popDist2TgtAll.dist2,popDist2Tgt(iTgt).epochDist2);
    
    % KLUDGE!!! only 1 trial for Tgt4 dist3
    if isempty(popDist2Tgt(iTgt).epochDist3)
    else
        if ndims(popDist2Tgt(iTgt).epochDist3) == 2;  tmpVal = permute(popDist2Tgt(iTgt).epochDist3,[1 3 2]); %#ok<ISMAT>
        else tmpVal = popDist2Tgt(iTgt).epochDist3;
        end
    end
    
    popDist2TgtAll.dist3 = cat(2,popDist2TgtAll.dist3,tmpVal);
    popDist2TgtAll.numEpochsPerDist = popDist2TgtAll.numEpochsPerDist + popDist2Tgt(iTgt).numEpochsPerDist;
end
              
popDist2TgtAll.normNumEpochsPerDist = popDist2TgtAll.numEpochsPerDist/sum(popDist2TgtAll.numEpochsPerDist);
popDist2TgtAll.nIncorrTrials = sum(popDist2TgtAll.numEpochsPerDist);


end