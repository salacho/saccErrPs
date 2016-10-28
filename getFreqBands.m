function [corrFreqBand,incorrFreqBand] = getFreqBands(corrSpec,incorrSpec,ErrorInfo)
% function [corrFreqBand,incorrFreqBand] = getFreqBands(corrSpec,incorrSpec,ErrorInfo)
%
%
%
%
% 24 Oct 2016


freqBands = ErrorInfo.plotInfo.specgram.freqs;
% transfType = ErrorInfo.plotInfo.specgram.transfType;
fSpec = ErrorInfo.specParams.fSpec;
nFreqs = size(freqBands,1);
nChs = size(corrSpec,4);

for iFreq = 1:nFreqs 
    % freq to index
    [vals,indx1] = min(abs(freqBands(iFreq,1) - fSpec));
    [vals,indx2] = min(abs(freqBands(iFreq,2) - fSpec));
    % corr/incorrSpec indx
    indxFreq(iFreq,1) = indx1;
    indxFreq(iFreq,2) = indx2;
end

% Extract freq bands
nCorr = size(corrSpec,3);
nIncorr = size(incorrSpec,3);
corrFreqBand = nan(numel(ErrorInfo.specParams.tSpec),nChs,nFreqs,nCorr);
incorrFreqBand = nan(numel(ErrorInfo.specParams.tSpec),nChs,nFreqs,nIncorr);

for iFreq = 1:nFreqs
    fprintf('Computing frequency band %i out of %i...\n',iFreq,nFreqs)
    % Corr
    for iCorr =1:nCorr, corrFreqBand(:,:,iFreq,iCorr) = squeeze(nanmean(corrSpec(:,indxFreq(iFreq,1):indxFreq(iFreq,2),iCorr,:),2)); end
    % Incorr
    for iIncorr =1:nIncorr, incorrFreqBand(:,:,iFreq,iIncorr) = nanmean(incorrSpec(:,indxFreq(iFreq,1):indxFreq(iFreq,2),iIncorr,:),2); end 
end

%% Permute dims
corrFreqBand = permute(corrFreqBand,[1,3,4,2]);
incorrFreqBand = permute(incorrFreqBand,[1,3,4,2]);

% sum(sum(sum(sum(isnan(incorrFreqBand)))))
% sum(sum(sum(sum(isnan(corrFreqBand)))))

end
