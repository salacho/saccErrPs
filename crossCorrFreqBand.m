function xcrossFreqBand = crossCorrFreqBand(trialsFreqBand)
% function crossCorrFreqBand(trialsFreqBand)
%
% Correlation between the power spectrum at different frequencies. 
% Must be done across trials!! 
%
% Using Masimore et al. 2004 J. Neurosc. Methods
%
% Check corrigendum: division by (N-1) was not include initially in the equation)
%
%
%
% trialsFreqBand = popIncorrFreqBand;
%
%
% 24 Oct. 2016

[nTimes,nFreqs,nTrials,nChs] = size(trialsFreqBand);
mu = nan(nTimes,nFreqs,nChs);
sd = nan(nTimes,nFreqs,nChs);
xcrossFreqBand = nan(nFreqs,nFreqs,nChs);

%% mean and standard deviation window per freq. band
for kFreq = 1:nFreqs
    fprintf('Computing mean and S.D. from all trials for freq %i out of %i...\n',kFreq,nFreqs)
    for kCh = 1:nChs
        mu(:,kFreq,kCh) = nanmean(squeeze(trialsFreqBand(:,kFreq,:,kCh)),2);
        sd(:,kFreq,kCh) = nanstd(squeeze(trialsFreqBand(:,kFreq,:,kCh)),[],2);
    end
end

%% cross-correlation
Sij = nan(nTrials,1);
for iFreq = 1:nFreqs
    fprintf('Computing cross-correlation for freq %i out of %i...\n',iFreq,nFreqs)
    for jFreq = 1:nFreqs
        for iCh = 1:nChs
            % Current data
            Si = squeeze(trialsFreqBand(:,iFreq,:,iCh));                         
            Sj = squeeze(trialsFreqBand(:,jFreq,:,iCh));
            % Eval across trials
            for iTrial =1:nTrials 
                Sij(iTrial) = ((Si(:,iTrial)-mu(:,iFreq,iCh))')*(Sj(:,iTrial)-mu(:,jFreq,iCh)); 
            end
            % normalize
            xcrossFreqBand(iFreq,jFreq,iCh) = sum(Sij)/((nTrials - 1)*((sd(:,iFreq,iCh)')*sd(:,jFreq,iCh)));
        end
    end
end

% if doNormalize xcorr
%     % Normalizing each band
%     for kFreq = 1:nFreqs
%         for kCh = 1:nChs
%             tempM = nanmean(squeeze(errDiffFreqBand(:,kFreq,kCh)));
%             tempSD = nanstd(squeeze(errDiffFreqBand(:,kFreq,kCh)));
%             errDiffFreqBandNorm(:,kFreq,kCh) = (errDiffFreqBand(:,kFreq,kCh)-tempM)/tempSD;
%         end
%     end
%     % get xcorr
%     for iFreq = 1:nFreqs
%         for jFreq = 1:nFreqs
%             for iCh = 1:nChs
%                 xcrossFreqBand(iFreq,jFreq,iCh) = xcorr(squeeze(errDiffFreqBandNorm(:,iFreq,iCh)),squeeze(errDiffFreqBand(:,jFreq,iCh)),0,'coeff');
%             end
%         end
%     end
% else
%     % NOT Normalizing each band get xcorr
%     for iFreq = 1:nFreqs
%         for jFreq = 1:nFreqs
%             for iCh = 1:nChs
%                 xcrossFreqBand(iFreq,jFreq,iCh) = xcorr(squeeze(errDiffFreqBand(:,iFreq,iCh)),squeeze(errDiffFreqBand(:,jFreq,iCh)),0,'coeff');
%             end
%         end
%     end
% end

end

% xcrossFreqBand ---> 45,6,96
%
%
%
%
%
%
%