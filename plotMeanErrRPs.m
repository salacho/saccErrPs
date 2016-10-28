function plotMeanErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
% function plotMeanErrRPs(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,ErrorInfo)
% 
% Plots all mean epochs for both correct and incorrect outcomes, channels and arrays.
%
% INPUT
% corrEpochs:       matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:     matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% ErrorInfo:        structure. 
%   visiblePlot:    logical. true for figures to be visible. False to do
%                   batch processes without figures popping continuously.
%   equalLimits:    logical. True to use same Y limits for all plots.
%
% Andres v1.0
% Created 11 June 2013
% Last modified 16 July 2013

%  ErrorInfo.plotInfo.equalLim.yMax.maxChs = 30
%  ErrorInfo.plotInfo.equalLim.yMin.minChs = -33
% 

tStart = tic;

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(ErrorInfo);

ErrorInfo.plotInfo.colorErrP

%% Params
% Getting plot params
plotInfo = ErrorInfo.plotInfo;
nChs = ErrorInfo.epochInfo.nChs;
arrayLoc = plotInfo.arrayLoc;

% Get trials mean and std or standard error values 
tempFlag = ErrorInfo.epochInfo.getMeanArrayEpoch;
ErrorInfo.epochInfo.getMeanArrayEpoch = true;

[corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials,corrArrayMean,incorrArrayMean,corrArrayStd,incorrArrayStd] = getMeanTrialsErrPs(corrEpochs,incorrEpochs,ErrorInfo);
ErrorInfo.epochInfo.getMeanArrayEpoch = tempFlag;

% Plotting params
plotInfo.axisFontSz = 13; %(AFSG-20140304) 7;
plotInfo.titleFontSz = 17; %(AFSG-20140304)12; 
plotInfo.lineWidth = plotInfo.lineWidth - 1;

% Time vector 
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

%% Plot averaged epochs for each channels and array
hPlot = nan(nChs,2);

for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s mean for %s',ErrorInfo.session,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);

    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        % Beware, detrend works on each column, need to transpose
        hPlot(iCh,1) = plot(timeVector,(corrMeanTrials(iCh,:)'),'Color',plotInfo.colorErrP(1,:),'lineWidth',plotInfo.lineWidth);                   % plot Correct epochs
        hold on
        hPlot(iCh,2) = plot(timeVector,(incorrMeanTrials(iCh,:)'),'Color',plotInfo.colorErrP(2,:),'lineWidth',plotInfo.lineWidth);                 % plot incorrect epochs
        %hPlot(iCh,3) = plot(timeVector,(incorrMeanTrials(iCh,:)'-corrMeanTrials(iCh,:)'),'Color',plotInfo.colorErrP(3,:),'lineWidth',plotInfo.lineWidth);                 % plot incorrect epochs
        
        axis tight
        if plotInfo.equalLimits
            set(gca,'FontSize',plotInfo.axisFontSz,...
                'Ylim',[plotInfo.equalLim.yMin.bothMeanEpoch(iArray) plotInfo.equalLim.yMax.bothMeanEpoch(iArray)])
        else
           set(gca,'FontSize',plotInfo.axisFontSz)
        end
    end
    % legend
    
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    legPlots = nan(3,1);
    for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error',char(arrayLoc(iArray))},0)
    axis off                                                                % remove axis and background
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochChs-%s%s%s.png',infoStr.strPrefix,...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
end
clear hFig hPlot legPlots

%% Plot mean and error bars of epochs per channel, per array 
plotInfo.lineWidth = plotInfo.lineWidth - 1;        % making lines smaller to see error bars
for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s %s and mean for %s',ErrorInfo.session,infoStr.stdTxt,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);

    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        
        plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);
        plotErrorBars(timeVector,(corrMeanTrials(iCh,:)),(corrMeanTrials(iCh,:) - corrStdTrials(iCh,:)), (corrMeanTrials(iCh,:) + corrStdTrials(iCh,:)),plotInfo);
        
        plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);
        plotErrorBars(timeVector,(incorrMeanTrials(iCh,:)),(incorrMeanTrials(iCh,:) - incorrStdTrials(iCh,:)), (incorrMeanTrials(iCh,:) + incorrStdTrials(iCh,:)),plotInfo);
                                                 
        plot(timeVector,incorrMeanTrials(iCh,:) - corrMeanTrials(iCh,:),'color',plotInfo.colorErrP(4,:),'linewidth',2);

        axis tight
        if plotInfo.equalLimits
            set(gca,'FontSize',plotInfo.axisFontSz,...
                'Ylim',[plotInfo.equalLim.yMin.errorBothMeanEpoch(iArray) plotInfo.equalLim.yMax.errorBothMeanEpoch(iArray)])
        else
           set(gca,'FontSize',plotInfo.axisFontSz)
        end
    end
    % legend
    
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    legPlots = nan(3,1);
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legPlots(3) = plot(0,'Color',plotInfo.colorErrP(4,:),'lineWidth',2); legPlots(4) = plot(0,'Color',plotInfo.colorErrP(3,:),'lineWidth',2);
    hLeg = legend(legPlots,{'Correct','Incorrect','Incorr-Corr',char(arrayLoc(iArray))},0,'fontsize',10);
    set(hLeg,'box','off')
    
    axis off                                                                % remove axis and background
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanErrorBarEpochChs-%s%s%s.png',infoStr.strPrefix,...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
end
clear hFig hPlot legPlots
plotInfo.lineWidth = plotInfo.lineWidth + 1;        % making lines bigger again. Returning to defualt

%% Plot meanTrials values for all channels (each channel a different color) of arrays in one plot
% Figure name
titleTxt = 'allChsColor';
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[886 57 1664 860],...
    'name',sprintf('%s Correct-Incorrect mean epochs array/channels %s',ErrorInfo.session,titleTxt),...
    'NumberTitle','off','visible',ErrorInfo.plotInfo.visible);

% Plot for each array
for iArray = 1:plotInfo.nArrays
    for iCh = 1+(iArray-1)*32:(iArray)*32
        % Get trace color vals
        subCh       = mod(iCh-1,size(plotInfo.colorMap,1))+1;
        colorVal1   = plotInfo.colorMap(subCh,:);
        colorVal2   = colorVal1;
        % Plot
        subplot(2,3,1+(iArray-1)), hold on,
        hPlot(subCh)= plot(timeVector,detrend(corrMeanTrials(iCh,:)),'Color',colorVal1);
        % legend
        %legendTxt{iCh} = sprintf('Ch%i',iCh); 
        % title
        title(['Correct Mean for channels of array ',arrayLoc{iArray}],'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
        subplot(2,3,4+(iArray-1)), hold on
        plot(timeVector,detrend(incorrMeanTrials(iCh,:)),'Color',colorVal2)
        % Title
        title(['Incorrect Mean for channels of array ',arrayLoc{iArray}],'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    end
    % First row plot properties
	set(gca,'FontSize',plotInfo.axisFontSz+2)
    xlabel('Time from reward stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    axis tight;
    % Second row plot properties
    subplot(2,3,1+(iArray-1)), axis tight
    set(gca,'FontSize',plotInfo.axisFontSz+2)
    xlabel('Time from punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-overlayMeanChsPerArray-%s%s%s.png',infoStr.strPrefix,...
        titleTxt,infoStr.signProcStr,infoStr.strSuffix);
    saveas(hFig,saveFilename)
end
clear hFig hPlot

%% Overlay of both correct and incorrect mean and st.dev./error for all trials and channels per array.
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
    'name',sprintf('%s Correct-Incorrect mean and std epoch per array. %s',ErrorInfo.session,infoStr.yLimTxt),...
    'NumberTitle','off','visible',plotInfo.visible);

plotInfo.lineWidth = 3;
only1stCol = 0;

% Per array plot together mean and std for correct and incorrect
for iArray = 1:plotInfo.nArrays
    % Plot error bars
    subplot(1,3,iArray), hold on,
    
    % Zero line
    % Plot err-diff
    plotErrDiff = plot(timeVector,incorrArrayMean(iArray,:) - corrArrayMean(iArray,:),'linewidth',plotInfo.lineWidth,'color','k');
    plot([0 0],[-90 90],'--k','linewidth',plotInfo.lineWidth)

    plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);
    [plotErrCorr]   = plotErrorBars(timeVector,corrArrayMean(iArray,:),corrArrayMean(iArray,:)-corrArrayStd(iArray,:),corrArrayMean(iArray,:)+corrArrayStd(iArray,:),plotInfo);               % Blue for correct epochs
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);
    [plotErrIncorr] = plotErrorBars(timeVector,incorrArrayMean(iArray,:),incorrArrayMean(iArray,:)-incorrArrayStd(iArray,:),incorrArrayMean(iArray,:)+incorrArrayStd(iArray,:),plotInfo);     % Red for correct epochs
    
    % Plot properties
    title(sprintf('Chs Mean/%s for %s',infoStr.stdTxt,arrayLoc{iArray}),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    if only1stCol
        if iArray == 1
            ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
        end
    else
        ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    end
    xlabel('Time from feedback stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    
    axis tight;
    if ErrorInfo.plotInfo.equalLimits
        set(gca,'FontSize',plotInfo.axisFontSz+2,...
            'Ylim',[plotInfo.equalLim.yMin.minPerArray-5 plotInfo.equalLim.yMax.maxPerArray+5])        
    else
        set(gca,'FontSize',plotInfo.axisFontSz+2)
    end
    hLeg(iArray,:) = legend([plotErrCorr.H plotErrIncorr.H plotErrDiff],{'Correct','Incorrect','Incorr-Corr'},'location','SouthWest','FontWeight','Bold');
end
set(hLeg,'box','off')

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanErrorEpochPerArray%s%s.png',infoStr.strPrefix,...
        infoStr.signProcStr,infoStr.strSuffix);
    saveas(hFig,saveFilename)
end
clear hFig hPlot

%% Overlay of both correct and incorrect mean and st.dev./error for one channel representative of each array
chList = [12,44,85];
warning('Add chList %i to plot to the ErrorInfo structure \n',chList)
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
    'name',sprintf('%s Correct-Incorrect mean and std epoch per array. %s',ErrorInfo.session,infoStr.yLimTxt),...
    'NumberTitle','off','visible',plotInfo.visible);

% Per array plot together mean and std for correct and incorrect
for iArray = 1:plotInfo.nArrays
    % Plot error bars
    subplot(1,3,iArray), hold on,
    
    % Zero line
    % Plot err-diff
    plotErrDiff = plot(timeVector,incorrMeanTrials(chList(iArray),:) - corrMeanTrials(chList(iArray),:),'linewidth',plotInfo.lineWidth,'color','k');
    plot([0 0],[-110 110],'--k','linewidth',plotInfo.lineWidth)

    plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);
    [plotErrCorr]   = plotErrorBars(timeVector,corrMeanTrials(chList(iArray),:),corrMeanTrials(chList(iArray),:) - corrStdTrials(chList(iArray),:),...
        corrMeanTrials(chList(iArray),:) + corrStdTrials(chList(iArray),:),plotInfo);               % green for correct epochs
    
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);
    
    [plotErrIncorr] = plotErrorBars(timeVector,incorrMeanTrials(chList(iArray),:),incorrMeanTrials(chList(iArray),:) - incorrStdTrials(chList(iArray),:),...
        incorrMeanTrials(chList(iArray),:) + incorrStdTrials(chList(iArray),:),plotInfo);               % Red for correct epochs
    
    % Plot properties
    title(sprintf('Correct and Incorrect Mean/%s for %s %i',infoStr.stdTxt,arrayLoc{iArray},chList(iArray)),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
    xlabel('Time from feedback onset [s]','FontSize',plotInfo.axisFontSz+2,'FontWeight','Bold')
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+2,'FontWeight','Bold')
    axis tight;
%     if ErrorInfo.plotInfo.equalLimits
%         set(gca,'FontSize',plotInfo.axisFontSz+2,...
%             'Ylim',[plotInfo.equalLim.yMin.minPerArray-5 plotInfo.equalLim.yMax.maxPerArray+5])        
%     else
        set(gca,'FontSize',plotInfo.axisFontSz)
%     end
    legend([plotErrCorr.H plotErrIncorr.H plotErrDiff],{'Correct','Error','Error-Correct'},'location','SouthWest','FontWeight','Bold')
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanErrorEpochPerArray%s%s.png',infoStr.strPrefix,...
        infoStr.signProcStr,infoStr.strSuffix);
    saveas(hFig,saveFilename)
end
clear hFig hPlot

% 
% Time it took to run this code
tElapsed = toc(tStart);
fprintf('Time it took to get equal Y limits was %0.2f seconds\n',tElapsed);

end
