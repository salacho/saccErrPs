function plotPopMeanSpecgram(meanCorrSpec,meanIncorrSpec,ErrorInfo)
% function plotPopMeanSpecgram(meanCorrSpec,meanIncorrSpec,ErrorInfo)
%
% INPUT
% corrSpec:         matrix. Spectrogram for correct trials in the form [fSamples, tSamples, ntrials,nchs]
% incorrSpec:       matrix. Spectrogram for incorrect trials in the form [fSamples, tSamples, ntrials,nchs]
% ErrorInfo:        
%
%
%
%
% Author    : Andres    
% 
% Andres    : v1.0  : init. 03 Dec 2014

%% Params
plotInfo = ErrorInfo.plotInfo;
timeVals = ErrorInfo.specParams.tSpec;
freqVals = ErrorInfo.specParams.fSpec;
nTime = length(ErrorInfo.specParams.tSpec);
% nFreq = length(ErrorInfo.specParams.fSpec);
chList = ErrorInfo.chList;
% nChs = length(chList);

% Time vals to plot
specTimeStart = -ErrorInfo.epochInfo.preOutcomeTime/1000 + ErrorInfo.specParams.movingWin(1)/2;
timeRange = ErrorInfo.epochInfo.postOutcomeTime/1000 + ErrorInfo.epochInfo.preOutcomeTime/1000; 
timeVector = 0:ErrorInfo.specParams.movingWin(2):timeRange;
timeVector = specTimeStart + timeVector(1:nTime);

% Freq vals to plot
freqVector = freqVals;

% Get mean trials spec
outcomStr = {'Corr','Incorr'};

% Transform data to be plotted
[meanCorrSpec,meanIncorrSpec,ErrorInfo] = transfSpec(meanCorrSpec,meanIncorrSpec,ErrorInfo);

% max and min limit
for iArray = 1:length(plotInfo.arrayLoc)
    nArrayChs = length(plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end));
    % Corr
    climCorr(1,iArray) =  min(reshape(meanCorrSpec(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)),...
        [length(timeVector)*length(freqVector)*nArrayChs 1]));
    climCorr(2,iArray) = max(reshape(meanCorrSpec(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)),...
        [length(timeVector)*length(freqVector)*nArrayChs 1]));
    % Incorr
    climIncorr(1,iArray) =  min(reshape(meanIncorrSpec(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)),...
        [length(timeVector)*length(freqVector)*nArrayChs 1]));
    climIncorr(2,iArray) = max(reshape(meanIncorrSpec(:,:,plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)),...
        [length(timeVector)*length(freqVector)*nArrayChs 1]));
    % ErrDiff
   temp = climIncorr(:,iArray) - climCorr(:,iArray);
   climErrDiff(:,iArray) = [min(temp),max(temp)];
end

%% Plot each frequency range set in plotInfo.specgram.freqs
for iFreq = 1:size(plotInfo.specgram.freqs,1)
    % Set the frequency range to plot
    ErrorInfo.plotInfo.specgram.fStart =  ErrorInfo.plotInfo.specgram.freqs(iFreq,1);
    ErrorInfo.plotInfo.specgram.fEnd = ErrorInfo.plotInfo.specgram.freqs(iFreq,2);
    
    % Find index of range of interest
    [~,tStartIndx] = min(abs(timeVals - plotInfo.specgram.tStart));
    [~,tEndIndx] = min(abs(timeVals - ErrorInfo.epochInfo.preOutcomeTime/1000 - plotInfo.specgram.tEnd));
    [~,fStartIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fStart));
    [~,fEndIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fEnd));
    
    % Vector of time and frequency to plot
    time2plot = timeVector(tStartIndx:tEndIndx);
    freq2plot = freqVector(fStartIndx:fEndIndx); %always aim a bit higuer than the freq. of interest
    
    % Text
    infoStr = getInfoStr(ErrorInfo);

    %% Plot for each channel mean epochs correct and incorrect spectrogram
    % Plot
%     for ii = 1:nChs
%         iCh = chList(ii);
%         disp(iCh)
%         hFig = figure;
%         set(gcf,'PaperPositionMode','auto','Position',[360   186   623   736],...
%             'name',sprintf('%s mean for ch%i %s',ErrorInfo.session,iCh,infoStr.strSpecTrans),...
%             'NumberTitle','off','Visible',plotInfo.visible);
%         % For correct and incorrect epochs
%         for iOut = 1:length(outcomStr)
%             % Plot per channel
%             subplot(3,1,iOut)
%             eval(sprintf('data2plot = squeeze(mean%sSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))'';',outcomStr{iOut}))         % remember to flip
%             imagesc(time2plot,freq2plot,data2plot)
%             set(gca,'Ydir','normal');
%             colorbar
%             % Axis properties
%             title(sprintf('Freq. Power Mean %s epochs. Ch%i %s %s',outcomStr{iOut},iCh,infoStr.strSpecTrans,infoStr.strSpecRange),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
%             xlabel(sprintf('Time to feedback onset %s [s]',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
%             ylabel('Frequency [Hz]','FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
%         end
%         % For incorrect - correct (freq.Power Diff)
%         subplot(3,1,3)
%         data2plot = squeeze(meanIncorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))' - squeeze(meanCorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))';
%         imagesc(time2plot,freq2plot,data2plot)
%         set(gca,'Ydir','normal');
%         colorbar
%         % Axis properties
%         title(sprintf('Freq. Power Mean ErrDiff epochs %s Ch%i %s',infoStr.strSpecTrans,iCh,infoStr.strSpecRange),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
%         xlabel(sprintf('Time to feedback onset %s [s]',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
%         ylabel('Frequency [Hz]','FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
%         
% %         disp('Pausing the whole analysis!!')
% %         pause
%         if plotInfo.savePlot
%             saveFilename = sprintf('%s-corrIncorr-meanEpochSpectrog%s-ch%i-%s%s.png',infoStr.strPrefix,...
%                 infoStr.strSpecTrans,iCh,infoStr.strSpecRange,infoStr.strSuffix);
%             saveas(hFig,saveFilename)
%             close(hFig)
%         end
%         
%     end
%     
    %% Plot all channels correct and incorrect spectrogram
    % For each array
    for iArray = 1:length(plotInfo.arrayLoc)
        fprintf('For array %s and %i-%iHz...\n',plotInfo.arrayLoc{iArray},ErrorInfo.plotInfo.specgram.fStart,ErrorInfo.plotInfo.specgram.fEnd)
        
        %% For corr and incorr
        if ErrorInfo.plotInfo.specgram.doCorr
            for iOut = 1:length(outcomStr)
                hFig = figure;
                set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
                    'name',sprintf('%s %s mean for %s-%s',ErrorInfo.session,outcomStr{iOut},plotInfo.arrayLoc{iArray},infoStr.strSpecTrans,infoStr.strSpecRange),...
                    'NumberTitle','off','Visible',plotInfo.visible);
                
                % Plot all channel
                for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
                    subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
                    subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
                    
                    % Data 2 top
                    eval(sprintf('data2plot = squeeze(mean%sSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))'';',outcomStr{iOut}))         % remember to flip
                    eval(sprintf('climVal = clim%s;',outcomStr{iOut}));
                    imagesc(time2plot,freq2plot,data2plot);%,[climVal(1,iArray) climVal(2,iArray)])
                    set(gca,'Ydir','normal');
                    % add or no colorbar
                    if ErrorInfo.plotInfo.specgram.doColorbar
                        colorbar
                    end
                    % Axis properties
                    title(sprintf('Ch%i',iCh),'FontSize',plotInfo.axisFontSz-1)
                    set(gca,'FontSize',plotInfo.axisFontSz)
                    axis tight
                end
                
                % legend
                subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
                legPlots = nan(3,1);
                for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
                legend(legPlots,{[char(plotInfo.arrayLoc(iArray)),infoStr.strSpecTrans],outcomStr{iOut},ErrorInfo.session},0)
                axis off                                                                % remove axis and background
                
                % Saving figures
                if plotInfo.savePlot
                    saveFilename = sprintf('%s-%s-meanEpochSpectrog%s-%s-%s%s.png',infoStr.strPrefix,...
                        outcomStr{iOut},infoStr.strSpecTrans,plotInfo.arrayLoc{iArray},infoStr.strSpecRange,infoStr.strSuffix);
                    saveas(hFig,saveFilename)   
                    close(hFig)
                end
            end
        end
        
        for iClim = 0:1
            %% Incorrect - Correct
            hFig = figure;
            set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
                'name',sprintf('%s Error-Corr and mean for %s-%s',ErrorInfo.session,plotInfo.arrayLoc{iArray},infoStr.strSpecTrans,infoStr.strSpecRange),...
                'NumberTitle','off','Visible',plotInfo.visible);
            
            % Plot all channel
            for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
                subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
                subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
                % Plot
                climVal = climErrDiff(:,iArray);
                data2plot = squeeze(meanIncorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))' - squeeze(meanCorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))';
                if iClim, imagesc(time2plot,freq2plot,data2plot,[climVal(1) climVal(2)])
                else imagesc(time2plot,freq2plot,data2plot)
                end
                set(gca,'Ydir','normal');
                %colorbar
                % Axis properties
                title(sprintf('Ch%i',iCh),'FontSize',plotInfo.axisFontSz-1)
                set(gca,'FontSize',plotInfo.axisFontSz)
                axis tight
            end
            
            % legend
            subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
            legPlots = nan(3,1);
            for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
            hLeg = legend(legPlots,{[char(plotInfo.arrayLoc(iArray)),infoStr.strSpecTrans],'Error-Corr',ErrorInfo.session},0);
            set(hLeg,'box','off')
            axis off                                                                % remove axis and background
            
            subplot(plotInfo.layout.rows,plotInfo.layout.colms,6)                             % use subplot to place legend outside the graph
            legColorbar(1) = imagesc(time2plot,freq2plot,climVal);%,[climVal(1,iArray) climVal(2,iArray)])
            hColor = colorbar; hLeg = legend(legColorbar,sprintf('%s',ErrorInfo.plotInfo.specgram.transfType),0);
            set(hLeg,'box','off','fontweight','bold'), axis off                                                                % remove axis and background
            hold on
            
            % Saving figures
            if plotInfo.savePlot
                saveFilename = sprintf('%s-ErrDiff-meanEpochSpectrog%s-%s-clim%i-%s-%s%s.png',infoStr.strPrefix,...
                    infoStr.strSpecTrans,plotInfo.arrayLoc{iArray},iClim,ErrorInfo.plotInfo.specgram.transfType,infoStr.strSpecRange,infoStr.strSuffix);
                saveas(hFig,saveFilename)
                close(hFig)
            end
        end
    end
end


end % EOF


%--------------------------------------------------------------------------
function [tempCorrSpec,tempIncorrSpec,ErrorInfo] = transfSpec(meanCorrSpec,meanIncorrSpec,ErrorInfo)
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

tempCorrSpec = nan(size(meanCorrSpec));
tempIncorrSpec = nan(size(meanIncorrSpec));
fprintf('Spectrogram transformed using %s\n',lower(ErrorInfo.plotInfo.specgram.transfType));

switch lower(ErrorInfo.plotInfo.specgram.transfType)
    
    case 'db'
        tempCorrSpec = db(meanCorrSpec);
        tempIncorrSpec = db(meanIncorrSpec);
        % Flag transfType was applied
        ErrorInfo.plotInfo.specgram.transfDone = 1;
    
    case 'freqzscore' % Z-score each freq. band over all time axis
        
        nTimes = length(ErrorInfo.specParams.tSpec);
        % For each freq. band
        for iFreq = 1:length(ErrorInfo.specParams.fSpec)
            meanVal = nanmean(squeeze(meanCorrSpec(:,iFreq,:)),1);
            stdVal = nanstd(squeeze(meanCorrSpec(:,iFreq,:)),[],1);
            tempCorrSpec(:,iFreq,:) = (squeeze(meanCorrSpec(:,iFreq,:)) - repmat(meanVal,[nTimes 1]))./repmat(stdVal,[nTimes 1]);
            meanVal = nanmean(squeeze(meanIncorrSpec(:,iFreq,:)),1);
            stdVal = nanstd(squeeze(meanIncorrSpec(:,iFreq,:)),[],1);
            tempIncorrSpec(:,iFreq,:) = (squeeze(meanIncorrSpec(:,iFreq,:)) - repmat(meanVal,[nTimes 1]))./repmat(stdVal,[nTimes 1]);
        end
        % Flag transfType was applied
        ErrorInfo.plotInfo.specgram.transfDone = 1;
     
    case 'norm'
        nTimes = length(ErrorInfo.specParams.tSpec);
        % For each freq. band
        for iFreq = 1:length(ErrorInfo.specParams.fSpec)
            sumVal = sum(squeeze(meanCorrSpec(:,iFreq,:)),1);       %gives vector of nchs
            tempCorrSpec(:,iFreq,:) = squeeze(meanCorrSpec(:,iFreq,:))./repmat(sumVal,[nTimes 1]);
            sumVal = sum(squeeze(meanIncorrSpec(:,iFreq,:)),1);
            tempIncorrSpec(:,iFreq,:) = squeeze(meanIncorrSpec(:,iFreq,:))./repmat(sumVal,[nTimes 1]);
        end
        % Flag transfType was applied
        ErrorInfo.plotInfo.specgram.transfDone = 1;
     
    case 'allzscore' % Z-score based on all data, along all freqs. and time points
        % Flag transfType was applied
        meanVal = nanmean(reshape(meanCorrSpec,[numel(meanCorrSpec) 1]));
        stdVal = nanstd(reshape(meanCorrSpec,[numel(meanCorrSpec) 1]));
        tempCorrSpec = (meanCorrSpec - meanVal)/stdVal;

        meanVal = nanmean(reshape(meanIncorrSpec,[numel(meanIncorrSpec) 1]));
        stdVal = nanstd(reshape(meanIncorrSpec,[numel(meanIncorrSpec) 1]));
        tempIncorrSpec = (meanIncorrSpec - meanVal)/stdVal;
        
        ErrorInfo.plotInfo.specgram.transfDone = 1;

    case 'none' % Z-score based oin all data, along all freqs. and time points
        tempCorrSpec = meanCorrSpec;
        tempIncorrSpec = meanIncorrSpec;
end

end
