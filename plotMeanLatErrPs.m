function plotMeanLatErrPs(latMeanCh,latStdCh,latMeanArray,latStdArray,ErrorInfo)
% function plotMeanLatErrPs(latMeanCh,latStdCh,latMeanArray,latStdArray,ErrorInfo)
%
% 
%
%
%
%
% Andres    : v1.0      : init. 10 Nov. 2014

plotInfo = ErrorInfo.plotInfo;
arrayLoc = plotInfo.arrayLoc;
nChs = ErrorInfo.nChs;

ipsiIndx = ErrorInfo.signalProcess.ipsiIndx;
contraIndx = ErrorInfo.signalProcess.contraIndx;

% Get string txts for titles, axis, saveFilename, ...
infoStr = getInfoStr(ErrorInfo);
% Line styles for ipsi and contra
lineStyles = {'-','-',':',':','-'};

%% For mean Chs
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

%% Plot averaged epochs for each channels and array
hPlot = nan(nChs,4);
for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s laterality mean for %s',ErrorInfo.session,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);

    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        % Beware, detrend works on each column, need to transpose
        hPlot(iCh,1) = plot(timeVector,detrend(latMeanCh(ipsiIndx).corr(iCh,:)'),'Color',plotInfo.colorErrP(1,:),'lineWidth',plotInfo.lineWidth-2);                   % plot Correct epochs
        hold on
        hPlot(iCh,2) = plot(timeVector,detrend(latMeanCh(ipsiIndx).incorr(iCh,:)'),'Color',plotInfo.colorErrP(2,:),'lineWidth',plotInfo.lineWidth-2);                 % plot incorrect epochs
        hPlot(iCh,3) = plot(timeVector,detrend(latMeanCh(contraIndx).corr(iCh,:)'),'Color',plotInfo.colorErrP(1,:),'lineWidth',plotInfo.lineWidth-2,'lineStyle',':');                   % plot Correct epochs
        hPlot(iCh,4) = plot(timeVector,detrend(latMeanCh(contraIndx).incorr(iCh,:)'),'Color',plotInfo.colorErrP(2,:),'lineWidth',plotInfo.lineWidth-2,'lineStyle',':');                 % plot incorrect epochs
        
        axis tight
        if plotInfo.equalLimits
            set(gca,'FontSize',plotInfo.axisFontSz,...
                'Ylim',[plotInfo.equalLim.yMin.bothMeanEpoch(iArray)-5 plotInfo.equalLim.yMax.bothMeanEpoch(iArray)+5])
        else
           set(gca,'FontSize',plotInfo.axisFontSz)
        end
    end
    % legend
    
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    legPlots = nan(5,1);
    for kk = 1:5, legPlots(kk) = plot(0,'Color',plotInfo.colorIpsiContra(kk,:),'lineWidth',2,'lineStyle',lineStyles{kk}); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'ipsiCorrectMean','ipsiErrorMean','contraCorrectMean','contraErrorMean',char(arrayLoc(iArray))},0)
    axis off                                                                % remove axis and background
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochChsLat-%s%s%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{iArray},infoStr.strgRef,infoStr.noisyEpochStr,infoStr.yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig,saveFilename)
    end
end
clear hFig hPlot legPlots

%% Plot averaged epochs and st.dev/error bars for each channels and array
plotInfo.lineWidth = plotInfo.lineWidth - 2;
for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s laterality error bars for %s',ErrorInfo.session,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);

    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
                % Beware, detrend works on each column, need to transpose
        plotInfo.plotColors(1,:) = plotInfo.colorIpsiContraError(1,:);
        plotErrorBars(timeVector,(latMeanCh(ipsiIndx).corr(iCh,:)),(latMeanCh(ipsiIndx).corr(iCh,:) - latStdCh(ipsiIndx).corr(iCh,:)), (latMeanCh(ipsiIndx).corr(iCh,:) + latStdCh(ipsiIndx).corr(iCh,:)),plotInfo);
        
        plotInfo.plotColors(1,:) = plotInfo.colorIpsiContraError(2,:);
        plotErrorBars(timeVector,(latMeanCh(ipsiIndx).incorr(iCh,:)),(latMeanCh(ipsiIndx).incorr(iCh,:) - latStdCh(ipsiIndx).corr(iCh,:)), (latMeanCh(ipsiIndx).corr(iCh,:) + latStdCh(ipsiIndx).corr(iCh,:)),plotInfo);

        plotInfo.plotColors(1,:) = plotInfo.colorIpsiContraError(3,:);
        plotErrorBars(timeVector,(latMeanCh(contraIndx).corr(iCh,:)),(latMeanCh(contraIndx).corr(iCh,:) - latStdCh(contraIndx).corr(iCh,:)), (latMeanCh(contraIndx).corr(iCh,:) + latStdCh(contraIndx).corr(iCh,:)),plotInfo);
        plotInfo.plotColors(1,:) = plotInfo.colorIpsiContraError(4,:);
        plotErrorBars(timeVector,(latMeanCh(contraIndx).incorr(iCh,:)),(latMeanCh(contraIndx).incorr(iCh,:) - latStdCh(contraIndx).corr(iCh,:)), (latMeanCh(contraIndx).corr(iCh,:) + latStdCh(contraIndx).corr(iCh,:)),plotInfo);
        
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
    legPlots = nan(5,1);
    for kk = 1:5, legPlots(kk) = plot(0,'Color',plotInfo.colorIpsiContraError(kk,:),'lineWidth',2,'lineStyle',lineStyles{kk}); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'ipsiCorrectMean','ipsiErrorMean','contraCorrectMean','contraErrorMean',char(arrayLoc(iArray))},0)
    axis off                                                                % remove axis and background
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanErrorBarsLatChs-%s%s%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{iArray},infoStr.strgRef,infoStr.noisyEpochStr,infoStr.yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig,saveFilename)
    end
end
clear hFig hPlot legPlots
plotInfo.lineWidth = plotInfo.lineWidth + 2;
 
%% Plot averaged epochs and st.dev/error bars for each channels
for iArray = 1:length(arrayLoc)
    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1437          42         986         874],...
            'name',sprintf('%s laterality error bars for ch%i in %s',ErrorInfo.session,iCh,arrayLoc{iArray}),...
            'NumberTitle','off','Visible',plotInfo.visible);
        warning('Line 131 problems with upper and lower boundaries for error bars...') %#ok<WNTAG>
        plotInfo.plotColors(1,:) = plotColor(1,:);
        plotErrorBars(timeVector,(latMeanCh(ipsiIndx).corr(iCh,:)),latMeanCh(ipsiIndx).corr(iCh,:) - latStdCh(ipsiIndx).corr(iCh,:), latMeanCh(ipsiIndx).corr(iCh,:) + latStdCh(ipsiIndx).corr(iCh,:),plotInfo);
        plotInfo.plotColors(1,:) = plotColor(2,:);
        plotErrorBars(timeVector,(latMeanCh(ipsiIndx).incorr(iCh,:)),latMeanCh(ipsiIndx).incorr(iCh,:) - latStdCh(ipsiIndx).corr(iCh,:), latMeanCh(ipsiIndx).corr(iCh,:) + latStdCh(ipsiIndx).corr(iCh,:),plotInfo);
        plotInfo.plotColors(1,:) = plotColor(3,:);
        plotErrorBars(timeVector,latMeanCh(contraIndx).corr(iCh,:),latMeanCh(contraIndx).corr(iCh,:) - latStdCh(contraIndx).corr(iCh,:), latMeanCh(contraIndx).corr(iCh,:) + latStdCh(contraIndx).corr(iCh,:),plotInfo);
        plotInfo.plotColors(1,:) = plotColor(4,:);
        plotErrorBars(timeVector,latMeanCh(contraIndx).incorr(iCh,:),latMeanCh(contraIndx).incorr(iCh,:) - latStdCh(contraIndx).corr(iCh,:), latMeanCh(contraIndx).corr(iCh,:) + latStdCh(contraIndx).corr(iCh,:),plotInfo);
        
        title(sprintf('Laterality tgts Mean%s for ch%i',infoStr.stdTxt,iCh),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
        xlabel('Time from reward/punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
        ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
        axis tight;
        % legend
        legPlots = nan(5,1);
        for kk = 1:5, legPlots(kk) = plot(0,'Color',plotColor(kk,:)); hold on, end;    % plot fake data to polace legends
        legend(legPlots,{'ipsiCorrectMean','ipsiErrorMean','contraCorrectMean','contraErrorMean',char(arrayLoc(iArray))})
        axis on                                                                % remove axis and background
        % Saving figures
        if plotInfo.savePlot
            saveFilename = sprintf('%s-corrIncorr-meanErrorBarsLatCh%i-%s%s%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
                iCh,arrayLoc{iArray},infoStr.strgRef,infoStr.noisyEpochStr,infoStr.yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
            saveas(hFig,saveFilename)
        end
    end
end
clear hFig hPlot legPlots
plotInfo.lineWidth = plotInfo.lineWidth + 2;

%% Overlay of both correct and incorrect mean and st.dev./error for all laterality trials and channels per array.
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1          41        1280         908],...
    'name',sprintf('%s Correct-Incorrect laterality mean and std epoch per array. %s',ErrorInfo.session,infoStr.yLimTxt),...
    'NumberTitle','off','visible',plotInfo.visible);

% Plot together mean and std for correct and incorrect for each array
plotInfo.lineStyle = '-';
for iArray = 1:plotInfo.nArrays
    % Plot error bars
    subplot(2,3,iArray), hold on,
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);
    [ipsi(1)]   = plotErrorBars(timeVector,latMeanArray(ipsiIndx).corr(iArray,:),latMeanArray(ipsiIndx).corr(iArray,:) - latStdArray(ipsiIndx).corr(iArray,:),latMeanArray(ipsiIndx).corr(iArray,:) + latStdArray(ipsiIndx).corr(iArray,:),plotInfo);               % Blue for correct epochs
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);
    [ipsi(2)]   = plotErrorBars(timeVector,latMeanArray(ipsiIndx).incorr(iArray,:),latMeanArray(ipsiIndx).incorr(iArray,:) - latStdArray(ipsiIndx).incorr(iArray,:),latMeanArray(ipsiIndx).incorr(iArray,:) + latStdArray(ipsiIndx).incorr(iArray,:),plotInfo);               % Blue for correct epochs
    % Plot properties
    title(sprintf('Ipsi-lateral tgts Mean%s for %s',infoStr.stdTxt,arrayLoc{iArray}),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    xlabel('Time from reward/punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    axis tight;
    if ErrorInfo.plotInfo.equalLimits
        set(gca,'FontSize',plotInfo.axisFontSz+2,...
            'Ylim',[plotInfo.equalLim.yMin.minPerArray plotInfo.equalLim.yMax.maxPerArray])        
    else
        set(gca,'FontSize',plotInfo.axisFontSz+2)
    end
    legend([ipsi(:).H],{'ipsiCorrect','ipsiError'},'location','SouthWest','FontWeight','Bold')
    
    subplot(2,3,iArray+3), hold on,
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);
    [contra(1)]   = plotErrorBars(timeVector,latMeanArray(contraIndx).corr(iArray,:),latMeanArray(contraIndx).corr(iArray,:) - latStdArray(contraIndx).corr(iArray,:),latMeanArray(contraIndx).corr(iArray,:) + latStdArray(contraIndx).corr(iArray,:),plotInfo);               % Blue for correct epochs
    plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);
    [contra(2)]   = plotErrorBars(timeVector,latMeanArray(contraIndx).incorr(iArray,:),latMeanArray(contraIndx).incorr(iArray,:) - latStdArray(contraIndx).incorr(iArray,:),latMeanArray(contraIndx).incorr(iArray,:) + latStdArray(contraIndx).incorr(iArray,:),plotInfo);               % Blue for correct epochs
    axis tight;
    % Plot properties
    title(sprintf('Contra-lateral tgts Mean%s for %s',infoStr.stdTxt,arrayLoc{iArray}),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    xlabel('Time from reward/punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
    axis tight;
    if ErrorInfo.plotInfo.equalLimits
        set(gca,'FontSize',plotInfo.axisFontSz+2,...
            'Ylim',[plotInfo.equalLim.yMin.minPerArray-10 plotInfo.equalLim.yMax.maxPerArray + 10])        
    else
        set(gca,'FontSize',plotInfo.axisFontSz+2)
    end
    legend([contra(:).H],{'contraCorrect','contraError'},'location','SouthWest','FontWeight','Bold')
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanErrorEpochPerArrayLat%s%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        infoStr.strgRef,infoStr.noisyEpochStr,infoStr.yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
end
clear hFig hPlot

    
