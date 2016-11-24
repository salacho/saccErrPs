function [meanPopDist2Tgt,stdPopDist2Tgt] = popDist2Tgt_getMeanStD(popCorr,popDist2TgtAll)
% function [meanPopDist2Tgt,stdPopDist2Tgt] = popDist2Tgt_getMeanStD(popCorr,popDist2TgtAll)
%
% INPUT
% popDist2TgtAll
% popCorr
%
% OUTPUT
% meanPopDist2Tgt
% stdPopDist2Tgt
%
%
% 23 Nov. 2016

meanPopDist2Tgt.dist1 = squeeze(nanmean(popDist2TgtAll.dist1,2));
meanPopDist2Tgt.dist2 = squeeze(nanmean(popDist2TgtAll.dist2,2));
meanPopDist2Tgt.dist3 = squeeze(nanmean(popDist2TgtAll.dist3,2));
stdPopDist2Tgt.dist1 = squeeze(nanstd(popDist2TgtAll.dist1,[],2));
stdPopDist2Tgt.dist2 = squeeze(nanstd(popDist2TgtAll.dist2,[],2));
stdPopDist2Tgt.dist3 = squeeze(nanstd(popDist2TgtAll.dist3,[],2));

meanPopDist2Tgt.corr = squeeze(nanmean(popCorr,2));
stdPopDist2Tgt.corr = squeeze(nanstd(popCorr,[],2));

end