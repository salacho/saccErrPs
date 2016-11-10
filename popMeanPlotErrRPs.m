function popMeanPlotErrRPs(popMeanCorrEpochs,popMeanIncorrEpochs,popStdCorrEpochs,popStdIncorrEpochs,popErrorInfo)
% function popPlotErrRPs(popMeanCorrEpochs,popMeanIncorrEpochs,popStdCorrEpochs,popStdIncorrEpochs,popErrorInfo)
% 
% Plots all epochs for both correct and incorrect outcomes, channels and arrays.
%
% INPUT
% popMeanCorrEpochs:       matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% popMeanIncorrEpochs:     matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% popErrorInfo:        structure. 
%   visiblePlot:    logical. true for figures to be visible. False to do
%                   batch processes without figures popping continuously.
%
% Andres
% Created 20 June 2013
% Last modified 20 June 2013
% Andres    :   v2.0    : modified all parameters to match other files.

%% Params
% Getting layout for array/channel distribution
timeVector = (1:1:length(popMeanCorrEpochs(1,:)));            % x values for error bar lot

%% Plot session-averaged signals for each channel and array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 947],...
        'name',sprintf('%s Population Correct-Incorrect session mean epochs for %s array',popErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','Visible',popErrorInfo.visiblePlot);
    
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hPlot(ii,1) = plot((popMeanCorrEpochs(iCh,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
        hold on
        hPlot(ii,2) = plot((popMeanIncorrEpochs(iCh,:)),'r','lineWidth',plotParams.lineWidth);                 % plot incorrect epochs
        axis tight
        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        % % legend
        % if subCh == 1
        % legend(hPlot(ii,:),{'Correct','Error'},'location','SouthWest')
        % end
    end
    
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error'},0)
    axis off                                                                % remove axis and background

    
    % Saving figures
    if popErrorInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochs-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(popErrorInfo.dirs.popDataOut,popErrorInfo.session),...
            arrayLoc{ii},strgRef,popErrorInfo.epochInfo.preOutcomeTime,popErrorInfo.epochInfo.postOutcomeTime,popErrorInfo.epochInfo.filtLowBound,popErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig hPlot legPlots

%% Plot error bars for session averages for each channels and array (same a previous plot but including standard deviation)
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean session epochs Error bars for %s array',popErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','Visible',popErrorInfo.visiblePlot);
    
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        
        plotParams.plotColors(1,:) = [0 0 1];
        [plotErrCorr] = plotErrorBars(timeVector,popMeanCorrEpochs(iCh,:),popMeanCorrEpochs(iCh,:)-popStdCorrEpochs(iCh,:),popMeanCorrEpochs(iCh,:)+popStdCorrEpochs(iCh,:),plotParams);               % Blue for correct epochs
        plotParams.plotColors(1,:) = [1 0 0];
        [plotErrIncorr] = plotErrorBars(timeVector,popMeanIncorrEpochs(iCh,:),popMeanIncorrEpochs(iCh,:)-popStdIncorrEpochs(iCh,:),popMeanIncorrEpochs(iCh,:)+popStdIncorrEpochs(iCh,:),plotParams);     % Red for correct epochs
        axis tight
        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        
        % % legend
        % if subCh == 1
        %    legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest')
        % end
    end
    
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error'},'Location','Best')
    axis off                                                                % remove axis and background

    
    % Saving figures
    if popErrorInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanChsErrorBar-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(popErrorInfo.dirs.popDataOut,popErrorInfo.session),...
            arrayLoc{ii},strgRef,popErrorInfo.epochInfo.preOutcomeTime,popErrorInfo.epochInfo.postOutcomeTime,popErrorInfo.epochInfo.filtLowBound,popErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig hPlot legPlots

%% Plot all array's channels in one

% Plots mean traces for each array with same color, different color and with std
colorType = 1;
titleTxt = 'allChsColor';
hFig(colorType) = figure;
set(hFig(colorType),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s Correct-Incorrect sessions mean per array %s',popErrorInfo.session,titleTxt),...
    'NumberTitle','off','visible',popErrorInfo.visiblePlot);

% Plot for each array
for ii = 1:3
    for iCh = 1+(ii-1)*32:(ii)*32
        % Get trace color vals
        chColor =  mod(iCh-1,size(plotParams.Color,1))+1;       % Trace color from colormap
        colorVal1 = plotParams.Color(chColor,:);
        colorVal2 = colorVal1;
        % Plot
        subCh =  mod(iCh-1,size(plotParams.Color,1))+1;
        subplot(2,3,1+(ii-1)), hold on,
        hPlot(subCh) = plot(detrend(popMeanCorrEpochs(iCh,:)),'Color',colorVal1);
        % legend
        legendTxt{iCh} = sprintf('Ch%i',iCh);
        % title
        title(['Correct Mean for channels of array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
        subplot(2,3,4+(ii-1)), hold on
        plot(detrend(popMeanIncorrEpochs(iCh,:)),'Color',colorVal2)
        % Title
        title(['Incorrect Mean for channels of array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
    end
    
    % First row plot properties
    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    xlabel('Time from reward stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
    ylabel('Signal voltage [uV]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
    axis tight;
    % Second row plot properties
    subplot(2,3,1+(ii-1)), axis tight
    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    
    xlabel('Time from punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
    ylabel('Signal voltage [uV]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
end

% Saving figures
if popErrorInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanChsColorEpochs-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(popErrorInfo.dirs.popDataOut,popErrorInfo.session),...
        titleTxt,popErrorInfo.epochInfo.preOutcomeTime,popErrorInfo.epochInfo.postOutcomeTime,popErrorInfo.epochInfo.filtLowBound,popErrorInfo.epochInfo.filtHighBound);
    saveas(hFig(colorType),saveFilename)
end
clear hFig hPlot

%% Overlay of both correct and incorrect epochs
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
    'name',sprintf('%s Correct-Incorrect overlay of mean epochs and std for all arrays',popErrorInfo.session),...
    'NumberTitle','off','visible',popErrorInfo.visiblePlot);

% Plot together mean and std for correct and incorrect for each array
for ii = 1:3
    % Get mean and std values
    meanChCorr = mean(popMeanCorrEpochs(1+(ii-1)*32:(ii)*32,:),1);
    stdChCorr = std(popMeanCorrEpochs(1+(ii-1)*32:(ii)*32,:),1);
    meanChIncorr = mean(popMeanIncorrEpochs(1+(ii-1)*32:(ii)*32,:),1);
    stdChIncorr = std(popMeanIncorrEpochs(1+(ii-1)*32:(ii)*32,:),1);
    
    % Plot error bars
    subplot(1,3,ii), hold on,
    plotParams.plotColors(1,:) = [0 0 1];
    [plotErrCorr] = plotErrorBars(timeVector,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
    title(['Correct and Incorrect Mean/STD for ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
    plotParams.plotColors(1,:) = [1 0 0];
    [plotErrIncorr] = plotErrorBars(timeVector,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
    
    % Plot properties
    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight','normal')
    ylabel('Signal voltage [uV]','FontSize',plotParams.axisFontSize+4,'FontWeight','normal')
    axis tight;
    legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest')
end

% Saving figures
if popErrorInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr_meanArrayEpochs-[%i-%ims]-[%0.1f-%iHz].png',fullfile(popErrorInfo.dirs.popDataOut,popErrorInfo.session),...
        popErrorInfo.epochInfo.preOutcomeTime,popErrorInfo.epochInfo.postOutcomeTime,popErrorInfo.epochInfo.filtLowBound,popErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
end
clear hFig hPlot


