function getSpkPSTH(corrRaster,incorrRaster,ErrorInfo)
% function getSpkPSTH(corrRaster,incorrRaster,ErrorInfo)
%
% Post-stimulus time histogram (PSTH)
%
%
%
%
%
%
% Author : Andres.
% 
% Andres :  init    : 20 Oct 2014
% Andres :  

%% Set vbles required for analysis
plotInfo = ErrorInfo.plotInfo;
binSz = ErrorInfo.spikeInfo.binSz;
spkSampFreq = ErrorInfo.spikeInfo.spkSampFreq;

preOutcomeTime = ErrorInfo.spikeInfo.preOutcomeTime;
postOutcomeTime = ErrorInfo.spikeInfo.postOutcomeTime;
binSampSz   = binSz/1000*spkSampFreq;         % in milliseconds
corrSz  = size(corrRaster);
incorrSz = size(incorrRaster);
nArrays     = plotInfo.nArrays;
nCellUnits  = corrSz(1);

% % Optimal bin size
% meanSpk = 
% varSpk = 
% (2*varSpk - meanSpk)/(binSampSz^2)

%% Spike-number histogram

% Bin data
if noMatterFeedbackOnset
    binStart = 1:binSampSz:corrSz(3);
    binEnd   = binSampSz:binSampSz:corrSz(3);
    minValBins = min(length(binStart),length(binEnd));
    binStart = binStart(1:minValBins);
    binEnd   = binEnd(1:minValBins);
    
    corrPSTH = nan(corrSz(1),corrSz(2),minValBins);
    incorrPSTH = nan(incorrSz(1),incorrSz(2),minValBins);
    timeVector = nan(1,minValBins);
    
    % Binned number spikes
    for iBin = 1:minValBins
        fprintf('Binning data into windows of %i milliseconds...\n',ErrorInfo.spikeInfo.binSz)
        disp(iBin)
        corrPSTH(:,:,iBin) = squeeze(sum(corrRaster(:,:,binStart(iBin):binEnd(iBin)),3));
        incorrPSTH(:,:,iBin) = squeeze(sum(incorrRaster(:,:,binStart(iBin):binEnd(iBin)),3));
        timeVector(1,iBin) = mean(ErrorInfo.spikeInfo.timeVector(binStart(iBin):binEnd(iBin)));
    end
    fprintf('Count of corrPSTH and incorrPSTH nans?: [%i-%i]\n',[sum(sum(sum(isnan(corrPSTH)))) sum(sum(sum(isnan(incorrPSTH))))])
    
else % if want to start counting spikes after feedback onset
    nPreSamp = preOutcomeTime/1000*spkSampFreq;
    nPostSamp = postOutcomeTime/1000*spkSampFreq;
    
   
    
    
    
end


%% Find time onset on binned data


% Spike rate
corrSpkRate = corrPSTH/(ErrorInfo.spikeInfo.binSz/1000);
incorrSpkRate = incorrPSTH/(ErrorInfo.spikeInfo.binSz/1000);

% Mean and variance of firing rate
meanCorrSpkRate = squeeze(nanmean(corrSpkRate,2));
meanIncorrSpkRate = squeeze(nanmean(incorrSpkRate,2));
varCorrSpkRate = squeeze(nanvar(corrSpkRate,[],2));
varIncorrSpkRate = squeeze(nanvar(incorrSpkRate,[],2));
sampErrCorrSpkRate = squeeze(nanstd(corrSpkRate,[],2))./sqrt(corrSz(2));
sampErrIncorrSpkRate = squeeze(nanstd(incorrSpkRate,[],2))./sqrt(incorrSz(2));

%% 
hFig = figure;
subplot(2,1,1)
imagesc(~meanCorrSpkRate);
set(gca,'Ydir','normal')
colormap(gray)
subplot(2,1,2)
imagesc(~meanIncorrSpkRate)
colormap(gray)
set(gca,'Ydir','normal')

%% Binned Firing Rate
% Visualize single unit/cell mean firing rate traces
maxMeanVal = max(max(max(meanCorrSpkRate)),max(max(meanIncorrSpkRate)));
for iCellUnit = 1:nCellUnits
    plot(timeVector,meanCorrSpkRate(iCellUnit,:),'color',ErrorInfo.plotInfo.colorErrP(1,:),'lineWidth',ErrorInfo.plotInfo.lineWidth)
    ylim([0 maxMeanVal])
    title(sprintf('corrMeanSpkRate cellUnit%i%',iCellUnit))
    hold on 
    
    plot(timeVector,meanIncorrSpkRate(iCellUnit,:),'color',ErrorInfo.plotInfo.colorErrP(2,:),'lineWidth',ErrorInfo.plotInfo.lineWidth)
    ylim([0 maxMeanVal])
    title(sprintf('incorrMeanSpkRate cellUnit%i%',iCellUnit))
    legend({'Corr','Err'})
    % hist corrPSTH(iCellUnit,)
    hold off
    pause
end

% Visualize single unit/cell mean and sample error bars firing rate traces
% maxBar = max(max(max(meanCorrSpkRate+stdCorrSpkRate),max(meanIncorrSpkRate+stdIncorrSpkRate)));
% minBar = min(min(min(meanCorrSpkRate-stdCorrSpkRate),min(meanIncorrSpkRate-stdIncorrSpkRate)));
figure
for iCellUnit = 1:nCellUnits
    % Plot corr error bars
    ErrorInfo.plotInfo.plotColors(1,:) = ErrorInfo.plotInfo.colorErrP(1,:);
    [plotErrCorr] = plotErrorBars(timeVector,meanCorrSpkRate(iCellUnit,:),meanCorrSpkRate(iCellUnit,:)-sampErrCorrSpkRate(iCellUnit,:),meanCorrSpkRate(iCellUnit,:)+sampErrCorrSpkRate(iCellUnit,:),ErrorInfo.plotInfo);
    hold on
    % Plot err error bars
    ErrorInfo.plotInfo.plotColors(1,:) = ErrorInfo.plotInfo.colorErrP(2,:);
    [plotErrIncorr] = plotErrorBars(timeVector,meanIncorrSpkRate(iCellUnit,:),meanIncorrSpkRate(iCellUnit,:)-sampErrIncorrSpkRate(iCellUnit,:),meanIncorrSpkRate(iCellUnit,:)+sampErrIncorrSpkRate(iCellUnit,:),ErrorInfo.plotInfo);
    %axis off
    %ylim([minBar maxBar])
    title(iCellUnit)
    %legend({'Corr','Err'})
    pause
    hold off
    clf
end

%% Visualize mean firing rate traces for all cells/units per array
for iArray = 1:nArrays
    disp(['Plotting array ',ErrorInfo.plotInfo.arrayLoc{iArray}])
    cellsUnit2plot = find(ErrorInfo.spikeInfo.arrayCellUnits{iArray});
    nCells2plot = length(cellsUnit2plot);
    nSide1 = ceil(sqrt(nCells2plot));
    nSide2 = round(sqrt(nCells2plot));
    
    % Set figure properties
    hFig = figure;
    set(hFig,'Position',[257    80   836   841],'PaperPositionMode','auto',...
        'name',sprintf('%s mean firing rate for correct-incorrect trials in %s %s',ErrorInfo.session,...
        ErrorInfo.plotInfo.arrayLoc{iArray},ErrorInfo.spikeInfo.txtRoot),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

    for iCellUnit = 1:nCells2plot
        %disp(iCellUnit)
        iCell = cellsUnit2plot(iCellUnit);
        subplot(nSide1,nSide2,iCellUnit)
        plot(timeVector,meanCorrSpkRate(iCell,:),'color',ErrorInfo.plotInfo.colorErrP(1,:),'lineWidth',ErrorInfo.plotInfo.lineWidth)
        %axis off
        ylim([0 maxMeanVal])
        hold on
        plot(timeVector,meanIncorrSpkRate(iCell,:),'color',ErrorInfo.plotInfo.colorErrP(2,:),'lineWidth',ErrorInfo.plotInfo.lineWidth)
        ylim([0 maxMeanVal])
        title(iCellUnit)
        %legend({'Corr','Err'})
        % hist corrPSTH(iCellUnit,)
        hold off
    end
end
    
%% Visualize mean and sample error bars firing rate traces for all cells/units per array
for iArray = 1:nArrays
    disp(['Plotting array ',ErrorInfo.plotInfo.arrayLoc{iArray}])
    cellsUnit2plot = find(ErrorInfo.spikeInfo.arrayCellUnits{iArray});
    nCells2plot = length(cellsUnit2plot);
    nSide1 = ceil(sqrt(nCells2plot));
    nSide2 = round(sqrt(nCells2plot));
    
    % Set figure properties
    hFig = figure;
    set(hFig,'Position',[257    80   836   841],'PaperPositionMode','auto',...
        'name',sprintf('%s error bars firing rate for correct-incorrect trials in %s %s',ErrorInfo.session,...
        ErrorInfo.plotInfo.arrayLoc{iArray},ErrorInfo.spikeInfo.txtRoot),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

    for iCellUnit = 1:nCells2plot
        %disp(iCellUnit)
        iCell = cellsUnit2plot(iCellUnit);
        subplot(nSide1,nSide2,iCellUnit)
        
        % Plot corr error bars
        ErrorInfo.plotInfo.plotColors(1,:) = ErrorInfo.plotInfo.colorErrP(1,:);
        [plotErr(iCellUnit,1)] = plotErrorBars(timeVector,meanCorrSpkRate(iCell,:),meanCorrSpkRate(iCell,:)-sampErrCorrSpkRate(iCell,:),meanCorrSpkRate(iCell,:)+sampErrCorrSpkRate(iCell,:),ErrorInfo.plotInfo);
        axisH(iCellUnit,1) = gca;
        hold on
        % Plot err error bars
        ErrorInfo.plotInfo.plotColors(1,:) = ErrorInfo.plotInfo.colorErrP(2,:);
        [plotErr(iCellUnit,2)] = plotErrorBars(timeVector,meanIncorrSpkRate(iCell,:),meanIncorrSpkRate(iCell,:)-sampErrIncorrSpkRate(iCell,:),meanIncorrSpkRate(iCell,:)+sampErrIncorrSpkRate(iCell,:),ErrorInfo.plotInfo);
        axisH(iCellUnit,2) = gca;
        axis tight
        %ylim([0 maxMeanVal])
        %ylim([0 maxMeanVal])
        title(iCellUnit,'FontSize',ErrorInfo.plotInfo.axisFontSz + 2);
        %legend({'Corr','Err'})
        hold off
    end
    set(axisH,'FontSize',ErrorInfo.plotInfo.axisFontSz)
    clear axisH plotErr
end

%% meanRate pre and post stimulus onset

%To get sum spike pre and post outcome need equal window sizes
[~,zeroIndxSamp] = min(abs(ErrorInfo.spikeInfo.timeVector));
preWindSz = length(ErrorInfo.spikeInfo.timeVector(1:zeroIndxSamp));
postWindSz = length(ErrorInfo.spikeInfo.timeVector(zeroIndxSamp+1:end));

corrMeanRaster = squeeze(mean(corrRaster,2));           
incorrMeanRaster = squeeze(mean(incorrRaster,2));

if preWindSz <= postWindSz
    preFirstSamp = 1;
    postLastSamp = zeroIndxSamp + zeroIndxSamp;
else 
    preFirstSamp = zeroIndxSamp - (postWindSz - 1);
    postLastSamp = zeroIndxSamp + postWindSz;
end

% Plot Ox and Xs for correct and incorrect cells
if length(preFirstSamp:zeroIndxSamp) == length(zeroIndxSamp+1:postLastSamp)
    %     % Sum of spike count per trial
    %     corrSumPre = (sum(corrRaster(:,:,preFirstSamp:zeroIndxSamp),3));
    %     corrSumPost = (sum(corrRaster(:,:,zeroIndxSamp+1:postLastSamp),3));
    %     incorrSumPre = (sum(incorrRaster(:,:,preFirstSamp:zeroIndxSamp),3));
    %     incorrSumPost = (sum(incorrRaster(:,:,zeroIndxSamp+1:postLastSamp),3));
    
    % Sum of mean spike count
    corrSumMeanPre = (sum(corrMeanRaster(:,preFirstSamp:zeroIndxSamp),2));
    corrSumMeanPost = (sum(corrMeanRaster(:,zeroIndxSamp+1:postLastSamp),2));
    incorrSumMeanPre = (sum(incorrMeanRaster(:,preFirstSamp:zeroIndxSamp),2));
    incorrSumMeanPost = (sum(incorrMeanRaster(:,zeroIndxSamp+1:postLastSamp),2));
    
    % Plot per array
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','position',[26 451 1219 340]);
    
    for iArray = 1:nArrays
        subplot(1,3,iArray)
        cellsUnit2plot = find(ErrorInfo.spikeInfo.arrayCellUnits{iArray});
        maxPrePost = max([corrSumMeanPre(cellsUnit2plot);corrSumMeanPost(cellsUnit2plot);incorrSumMeanPre(cellsUnit2plot);incorrSumMeanPost(cellsUnit2plot)]);
        
        % Line
        plot([0 maxPrePost],[0 maxPrePost],'k','lineStyle',':','lineWidth',ErrorInfo.plotInfo.lineWidth-3)
        hold on
        % Values
        plot(corrSumMeanPre(cellsUnit2plot),corrSumMeanPost(cellsUnit2plot),'O','color',ErrorInfo.plotInfo.colorErrP(1,:))
        plot(incorrSumMeanPre(cellsUnit2plot),incorrSumMeanPost(cellsUnit2plot),'X','color',ErrorInfo.plotInfo.colorErrP(2,:))
        % Correlation Coefficients
        corrR(:,:,iArray) = corrcoef(corrSumMeanPre',corrSumMeanPost');
        incorrR(:,:,iArray) = corrcoef(incorrSumMeanPre',incorrSumMeanPost');
        % Properties
        xlabel('Spike count preOutcome onset','FontSize',ErrorInfo.plotInfo.axisFontSz + 4,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
        ylabel('Spike count postOutcome onset','FontSize',ErrorInfo.plotInfo.axisFontSz + 4,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
        axis tight
        title(sprintf('%s-%s',ErrorInfo.session,ErrorInfo.plotInfo.arrayLoc{iArray}),'FontSize',ErrorInfo.plotInfo.titleFontSz, 'FontWeight',ErrorInfo.plotInfo.titleFontWeight)
    end
else
    error('Number of elements for pre and post outcome window is different!!!')
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-PreVsPostSpikeCount-[%i-%ims]%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
    ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.spikeInfo.txtRoot);
    saveas(hFig,saveFilename)
end

% subplot(2,1,1), imagesc(squeeze(corrPSTH(1,:,:))), subplot(2,1,2), imagesc(squeeze(incorrPSTH(1,:,:)))

%% Inter-Spike Interval (ISI)











  