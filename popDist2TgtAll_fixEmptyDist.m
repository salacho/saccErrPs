function [meanPopDist2Tgt,stdPopDist2Tgt] = popDist2TgtAll_fixEmptyDist(meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo)
% function [meanPopDist2Tgt,stdPopDist2Tgt] = popDist2TgtAll_fixEmptyDist(meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo)
%
%
%
%
%
% 24 Nov.  2016


for iTgt = 1:popErrorInfo.epochInfo.nTgts
    % Size
    [nChs,nSamps] = size(meanPopDist2Tgt(iTgt).dist1);
    % Mean
    if isempty(meanPopDist2Tgt(iTgt).dist2),meanPopDist2Tgt(iTgt).dist2 = zeros(nChs,nSamps);
    end
    if isempty(meanPopDist2Tgt(iTgt).dist3),meanPopDist2Tgt(iTgt).dist3 = zeros(nChs,nSamps);
    end
    % St.Dev
    if isempty(stdPopDist2Tgt(iTgt).dist1),stdPopDist2Tgt(iTgt).dist1 = zeros(nChs,nSamps);
    end
    if isempty(stdPopDist2Tgt(iTgt).dist2),stdPopDist2Tgt(iTgt).dist2 = zeros(nChs,nSamps);
    end
    if isempty(stdPopDist2Tgt(iTgt).dist3),stdPopDist2Tgt(iTgt).dist3 = zeros(nChs,nSamps);
    end
end


end




