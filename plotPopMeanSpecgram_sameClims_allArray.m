function plotPopMeanSpecgram_sameClims_allArray(meanCorrSpec,meanIncorrSpec,ErrorInfo)
% function plotPopMeanSpecgram_sameClims_allArray(meanCorrSpec,meanIncorrSpec,ErrorInfo)
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
for iFreq = 1:size(plotInfo.specgram.freqs,1)
    ErrorInfo.plotInfo.specgram.fStart =  ErrorInfo.plotInfo.specgram.freqs(iFreq,1);
    ErrorInfo.plotInfo.specgram.fEnd = ErrorInfo.plotInfo.specgram.freqs(iFreq,2);
    
    % Find index of range of interest
    [~,tStartIndx] = min(abs(timeVals - plotInfo.specgram.tStart));
    [~,tEndIndx] = min(abs(timeVals - ErrorInfo.epochInfo.preOutcomeTime/1000 - plotInfo.specgram.tEnd));
    [~,fStartIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fStart));
    [~,fEndIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fEnd));
    
    % ErrDiff
    data2plot = squeeze(meanIncorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,:)) - squeeze(meanCorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,:));
    climErrDiff(:,iFreq) = [nanmin(nanmin(nanmin(data2plot))),nanmax(nanmax(nanmax(data2plot)))];
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
    
    % Clims
    climVal = climErrDiff(:,iFreq);
    
    % Text
    infoStr = getInfoStr(ErrorInfo);
    
    %% Plot all channels correct and incorrect spectrogram
    % For each array
    for iArray = 1:length(plotInfo.arrayLoc)
        fprintf('For array %s and %i-%iHz...\n',plotInfo.arrayLoc{iArray},ErrorInfo.plotInfo.specgram.fStart,ErrorInfo.plotInfo.specgram.fEnd)
        
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
            data2plot = squeeze(meanIncorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))' - squeeze(meanCorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))';
            imagesc(time2plot,freq2plot,data2plot,[climVal(1) climVal(2)])
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
        legColorbar(1) = imagesc(time2plot,freq2plot,climVal);
        hColor = colorbar; hLeg = legend(legColorbar,sprintf('SameClim AllArrays-%s',ErrorInfo.plotInfo.specgram.transfType),0,'location','northoutside');
        set(hLeg,'box','off','fontweight','bold'), axis off                                                                % remove axis and background
        hold on
        
        % Saving figures
        if plotInfo.savePlot
            saveFilename = sprintf('%s-ErrDiff-meanEpochSpectrog%s-%s-sameClimAllArrays-%s-%s%s.png',infoStr.strPrefix,...
                infoStr.strSpecTrans,plotInfo.arrayLoc{iArray},ErrorInfo.plotInfo.specgram.transfType,infoStr.strSpecRange,infoStr.strSuffix);
            saveas(hFig,saveFilename)
            close(hFig)
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
