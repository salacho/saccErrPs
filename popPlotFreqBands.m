function popPlotFreqBands(errDiffFreqBand,freqBands,errDiffFreqTxt,ErrorInfo)
% function popPlotFreqBands(errDiffFreqBand,freqBands,errDiffFreqTxt,ErrorInfo)
%
%
%
%
%
%
% 24 Oct. 2016

%% Vars
nFreqs = size(freqBands,1);
% Text
infoStr = getInfoStr(ErrorInfo);
chList = ErrorInfo.chList;

%% All channels together
%%%%%%% line
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[2087 65 399 885],...
    'name',sprintf('%s freq. bands %s','line'),...
    'NumberTitle','off','visible','off');

for iFreq = 1:nFreqs
    subplot(nFreqs,1,iFreq)
    plot(chList,(squeeze(errDiffFreqBand(:,iFreq,:))),'linewidth',1), hold on
    title(sprintf('%s-[%i-%iHz]',errDiffFreqTxt{iFreq},freqBands(iFreq,:)),'fontweight','bold'), axis tight
    % plot array lines
    clim(1) = nanmin(nanmin(squeeze(errDiffFreqBand(:,iFreq,:))));
    clim(2) = nanmax(nanmax(squeeze(errDiffFreqBand(:,iFreq,:))));
    plot([32,32],clim,'--k','linewidth',2)
    plot([64,64],clim,'--k','linewidth',2), hold off
end
% Saving figures
saveFilename = sprintf('%s-ErrDiff-freqBand%s-allChsLines-%s%s.png',infoStr.strPrefix,...
    infoStr.strSpecTrans,infoStr.strSpecRange,infoStr.strSuffix);
saveas(hFig,saveFilename)
close(hFig)

%%%%%% *
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[2087 65 399 885],...
    'name',sprintf('%s freq. bands %s','*'),...
    'NumberTitle','off','visible','off');

for iFreq = 1:nFreqs
    subplot(nFreqs,1,iFreq)
    plot(chList,(squeeze(errDiffFreqBand(:,iFreq,:))),'*','markersize',2), hold on
    title(sprintf('%s-[%i-%iHz]',errDiffFreqTxt{iFreq},freqBands(iFreq,:)),'fontweight','bold'), axis tight
    % plot array lines
    clim(1) = nanmin(nanmin(squeeze(errDiffFreqBand(:,iFreq,:))));
    clim(2) = nanmax(nanmax(squeeze(errDiffFreqBand(:,iFreq,:))));
    plot([32,32],clim,'--k','linewidth',2)
    plot([64,64],clim,'--k','linewidth',2), hold off
end
% Saving figures
saveFilename = sprintf('%s-ErrDiff-freqBand%s-allChsDots-%s%s.png',infoStr.strPrefix,...
    infoStr.strSpecTrans,infoStr.strSpecRange,infoStr.strSuffix);
saveas(hFig,saveFilename)
close(hFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Per array
plotInfo = ErrorInfo.plotInfo;
nTime = length(ErrorInfo.specParams.tSpec);
clim = nan(2,3);
transfType = lower(ErrorInfo.plotInfo.specgram.transfType);

% Time vals to plot
specTimeStart = -ErrorInfo.epochInfo.preOutcomeTime/1000 + ErrorInfo.specParams.movingWin(1)/2;
timeRange = ErrorInfo.epochInfo.postOutcomeTime/1000 + ErrorInfo.epochInfo.preOutcomeTime/1000; 
timeVector = 0:ErrorInfo.specParams.movingWin(2):timeRange;
timeVector = specTimeStart + timeVector(1:nTime);

XtickLabels = timeVector;
YtickLabels = errDiffFreqTxt;
YtickPos = 1:nFreqs;

for iArray = 1:length(plotInfo.arrayLoc)
    
    % Vector of time and frequency to plot
    time2plot = XtickLabels;
    freq2plot = YtickPos;            %always aim a bit higher than the freq. of interest
    
    %% Plot all channels correct and incorrect spectrogram
    % For each array
    fprintf('For array %s and frequency bands...\n',plotInfo.arrayLoc{iArray})
    
    data2plot = transfSpec((errDiffFreqBand(:,:,:)),transfType);
    % get clims per array
    clim(1,iArray) = nanmin(nanmin(nanmin(squeeze(data2plot(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end))))));
    clim(2,iArray) = nanmax(nanmax(nanmax(squeeze(data2plot(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end))))));


    for iClim = 0:1
        %% Incorrect - Correct
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
            'name',sprintf('%s Error-Corr and mean for %s-%s',ErrorInfo.session,plotInfo.arrayLoc{iArray},infoStr.strSpecTrans,infoStr.strSpecRange),...
            'NumberTitle','off','Visible','off');
        
        % Plot all channel
        for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
            % Plot
            data2plot = transfSpec(squeeze(errDiffFreqBand(:,:,iCh))',transfType);
            
            if iClim, imagesc(time2plot,freq2plot,data2plot,[clim(1,iArray) clim(2,iArray)])
            else imagesc(time2plot,freq2plot,data2plot)
            end
            set(gca,'Ydir','normal');
            %colorbar
            % Axis properties
            title(sprintf('Ch%i',iCh),'FontSize',plotInfo.axisFontSz-1)
            set(gca,'FontSize',plotInfo.axisFontSz,'YtickLabels',YtickLabels,'Ytick',YtickPos)
            axis tight
        end
        
        % legend arrays
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
        legPlots = nan(3,1);
        for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
        hLeg = legend(legPlots,{[char(plotInfo.arrayLoc(iArray)),infoStr.strSpecTrans],'Error-Corr',ErrorInfo.session([1:5,10:end])},0);
        set(hLeg,'box','off','fontsize',9)
        axis off                                                                % remove axis and background
        
        % legend transform
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,6)                             % use subplot to place legend outside the graph
        data2plot = clim(:,iArray);
        legColorbar(1) = imagesc(time2plot,freq2plot,data2plot);%,[climVal(1,iArray) climVal(2,iArray)])
        hColor = colorbar; hLeg = legend(legColorbar,sprintf('clim%i-%s',iClim,ErrorInfo.plotInfo.specgram.transfType),0,'location','northoutside');
        set(hLeg,'box','off','fontweight','bold'), axis off                                                                % remove axis and background
        hold on
        
        % Saving figures
        if plotInfo.savePlot
            saveFilename = sprintf('%s-ErrDiff-freqBand%s-%s-clim%i-%s%s.png',infoStr.strPrefix,...
                infoStr.strSpecTrans,plotInfo.arrayLoc{iArray},iClim,transfType,infoStr.strSuffix);
            saveas(hFig,saveFilename)
            close(hFig)
        end
    end
end


end

%--------------------------------------------------------------------------
function errDiffFreqBandTrans = transfSpec(errDiffFreqBand,transfType)
% function [tempCorrSpec,tempIncorrSpec,ErrorInfo] = transfSpec(meanCorrSpec,meanIncorrSpec,ErrorInfo)
%
% Transforms spectrogram data using a specified type of normalization/transformation approach 
% included in 'ErrorInfo.plotInfo.specgram.transfType'.
%
% INPUT
% meanCorrSpec:         matrix. Mean spectrogram of correct trials in the form 
%                       [nTimeBins x nFreqBins x nChns].
% meanIncorrSpec:       matrix. Mean spectrogram of incorrect trials in the form 
%                       [nTimeBins x nFreqBins x nChns].
%
% OUTPUT
% tempCorrSpec:         matrix. Mean spectrogram of correct trials in the form 
%                       [nTimeBins x nFreqBins x nChns] normalized or transformed 
%                       applying 'ErrorInfo.plotInfo.specgram.transfType' approach.
% tempIncorrSpec:       matrix. Mean spectrogram of incorrect trials in the form 
%                       [nTimeBins x nFreqBins x nChns] normalized or transformed 
%                       applying 'ErrorInfo.plotInfo.specgram.transfType' approach.
%
% Author    :   Andres
% 
% Andres    :   v1.0    : init. 08 Dec. 2014
%

switch lower(transfType)
    case 'db'
        errDiffFreqBandTrans = db(errDiffFreqBand);
    case 'none' % Z-score based oin all data, along all freqs. and time points
        errDiffFreqBandTrans = errDiffFreqBand;
end

end


