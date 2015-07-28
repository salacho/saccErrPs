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

 ErrorInfo.plotInfo.equalLim.yMax.maxChs = 30
 ErrorInfo.plotInfo.equalLim.yMin.minChs = -33

tStart = tic;
%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);

% Plotting params
plotParams.nXtick = 6;
plotParams.axisFontSize = 13; %(AFSG-20140304) 7;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 17; %(AFSG-20140304)12; 
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 4; %(AFSG-20140304) 1.5;
plotParams.lineStyle = '-';
% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors

XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
arrayLoc = ErrorInfo.plotInfo.arrayLoc;

% Mean values 
if ndims(corrEpochs) == 3                           
    corrMean = squeeze(mean(corrEpochs,2));
elseif ndims(corrEpochs) == 2                               %#ok<ISMAT>
    corrMean = corrEpochs;                                  % only one epoch, hence no mean
else error('Number of dims for corrEpochs do not match')
end

if ndims(incorrEpochs) == 3                           
    incorrMean = squeeze(mean(incorrEpochs,2));
elseif ndims(incorrEpochs) == 2                             %#ok<ISMAT>
    incorrMean = incorrEpochs;                              % only one epoch, hence no mean
else error('Number of dims for incorrEpochs do not match')
end

% Signals used to extract epochs plotted here
switch ErrorInfo.epochInfo.typeRef
    case 'lfp'
        strgRef = '';
    case 'lapla'
        strgRef = 'lapla-';
    case 'car'
        strgRef = 'car';
        stop
end

% Identifier used in saveFilename and in Figure name
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

% Plots mean traces for each array with same color, different color and with std
xVals = (1:1:length(corrMean(1,:)));            % x values for error bar lot

%% Plot only one channels per array

hFigarray = figure;
subplot(1,3,1)
hold on 
hPlotarray(1,1) = plot(detrend(corrMean(21,:)),'b','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
hPlotarray(1,2) = plot(detrend(incorrMean(21,:)),'r','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
set(gca,'FontSize',plotParams.axisFontSize+5,'Xtick',XtickPos,'XtickLabel',XtickLabels)
axis tight
legend(gca,'Correct','Error','Location','NorthWest')
xlabel('Time to feedback onset [ms]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
ylabel('Amplitude [mV]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
title('LFP ch 21 PFC','FontSize',plotParams.titleFontSize+1,'FontWeight',plotParams.titleFontWeight)
subplot(1,3,2)
hold on 
hPlotarray(2,1) = plot(detrend(corrMean(41,:)),'b','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
hPlotarray(2,2) = plot(detrend(incorrMean(41,:)),'r','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
set(gca,'FontSize',plotParams.axisFontSize+5,'Xtick',XtickPos,'XtickLabel',XtickLabels)
axis tight
legend(gca,'Correct','Error','Location','NorthWest')
xlabel('Time to feedback onset [ms]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
ylabel('Amplitude [mV]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
title('LFP ch 41 SEF','FontSize',plotParams.titleFontSize+1,'FontWeight',plotParams.titleFontWeight)
subplot(1,3,3)
hold on 
hPlotarray(3,1) = plot(detrend(corrMean(70,:)),'b','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
hPlotarray(3,2) = plot(detrend(incorrMean(70,:)),'r','lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
set(gca,'FontSize',plotParams.axisFontSize+5,'Xtick',XtickPos,'XtickLabel',XtickLabels)
axis tight
legend(gca,'Correct','Error','Location','NorthWest')
xlabel('Time to feedback onset [ms]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
ylabel('Amplitude [mV]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
title('LFP ch 70 FEF','FontSize',plotParams.titleFontSize+1,'FontWeight',plotParams.titleFontWeight)

%% Plot averaged signals for each channels and array
hFig = 1:length(arrayLoc);
hPlot = nan(ErrorInfo.epochInfo.nChs,2);
for ii = 1:length(arrayLoc)
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean epochs chs for %s array %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hPlot(ii,1) = plot(detrend(corrMean(iCh,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
        hold on
        hPlot(ii,2) = plot(detrend(incorrMean(iCh,:)),'r','lineWidth',plotParams.lineWidth);                 % plot incorrect epochs
        axis tight
        if ErrorInfo.plotInfo.equalLimits
            set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothMeanEpoch(ii) ErrorInfo.plotInfo.equalLim.yMax.bothMeanEpoch(ii)])
        else
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        end
    end
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legPlots = nan(2,1);
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpoch-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig hPlot legPlots

%% Plot all array's channels in one

plotParams.nXtick = 12;
colorType = 1;
% Figure name
titleTxt = 'allChsColor';
hFig(colorType) = figure;
set(hFig(colorType),'PaperPositionMode','auto','Position',[886 57 1664 860],...
    'name',sprintf('%s Correct-Incorrect mean epochs array/channels %s',ErrorInfo.session,titleTxt),...
    'NumberTitle','off','visible',ErrorInfo.plotInfo.visible);

% Plot for each array
for ii = 1:3
    for iCh = 1+(ii-1)*32:(ii)*32
        % Get trace color vals
        chColor     = mod(iCh-1,size(plotParams.Color,1))+1;       % Trace color from colormap
        colorVal1   = plotParams.Color(chColor,:);
        colorVal2   = colorVal1;
        % Plot
        subCh       = mod(iCh-1,size(plotParams.Color,1))+1;
        subplot(2,3,1+(ii-1)), hold on,
        hPlot(subCh)= plot(detrend(corrMean(iCh,:)),'Color',colorVal1);
        % legend
        %legendTxt{iCh} = sprintf('Ch%i',iCh); 
        % title
        title(['Correct Mean for channels of array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
        subplot(2,3,4+(ii-1)), hold on
        plot(detrend(incorrMean(iCh,:)),'Color',colorVal2)
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
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-epochsMean-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        titleTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig(colorType),saveFilename)
end
clear hFig hPlot

%% Overlay of both correct and incorrect epochs
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
    'name',sprintf('%s Correct-Incorrect chs mean and std for all arrays. %s',ErrorInfo.session,yLimTxt),...
    'NumberTitle','off','visible',ErrorInfo.plotInfo.visible);

% Plot together mean and std for correct and incorrect for each array
for ii = 1:3
    % Get mean and std values
    meanChCorr      = nanmean(corrMean(1+(ii-1)*32:(ii)*32,:),1);
    stdChCorr       = nanstd(corrMean(1+(ii-1)*32:(ii)*32,:),1);
    meanChIncorr    = nanmean(incorrMean(1+(ii-1)*32:(ii)*32,:),1);
    stdChIncorr     = nanstd(incorrMean(1+(ii-1)*32:(ii)*32,:),1);
    
    % Plot error bars
    subplot(1,3,ii), hold on,
    %plotParams.plotColors(1,:) = [0 0 1];
    plotParams.plotColors(1,:) = [26 150 65]/255;
    
    [plotErrCorr]   = plotErrorBars(xVals,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
    title(['Correct and Incorrect Mean/STD for ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
    %plotParams.plotColors(1,:) = [1 0 0];
    plotParams.plotColors(1,:) = [215 25 28]/255;
    [plotErrIncorr] = plotErrorBars(xVals,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
    
    % Plot properties
    xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
    ylabel('Signal voltage [uV]','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
    axis tight;
    if ErrorInfo.plotInfo.equalLimits
        set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
            'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.minChs ErrorInfo.plotInfo.equalLim.yMax.maxChs])        
    else
        set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    end
    legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontWeight','Bold')
end

% Saving figures
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-chsErrorBars-%s[%i-%ims]-[%0.1f-%iHz]-iSLC2014.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),yLimTxt,...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
end
clear hFig hPlot

%% Error Difference
meanCorrBaseline = squeeze(nanmean(corrBaseline,2)); 
meanIncorrBaseline = squeeze(nanmean(incorrBaseline,2));
diffCorrError = corrMean - incorrMean;

hFig = 1:length(arrayLoc);
hPlot = nan(ErrorInfo.epochInfo.nChs,1);
for ii = 1:length(arrayLoc)
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect epochs mean diff. chs for %s array %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hPlot(ii,1) = plot(detrend(diffCorrError(iCh,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
        %hPlot(ii,1) = plot((corrMean(iCh,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
        hold on
        axis tight
        if ErrorInfo.plotInfo.equalLimits
            set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothMeanEpoch(ii) ErrorInfo.plotInfo.equalLim.yMax.bothMeanEpoch(ii)])
        else
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        end
    end
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legPlots = plot(0,'Color',plotParams.errorColors(1,:),'lineWidth',1);   % plot fake data to polace legends
    legend(legPlots,{'Correct-Error Diff.'},0)%,'FontSize',8)
    axis off                                                                % remove axis and background
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpoch-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig hPlot legPlots

% Time it took to run this code
tElapsed = toc(tStart);
fprintf('Time it took to get equal Y limits was %0.2f seconds\n',tElapsed);
