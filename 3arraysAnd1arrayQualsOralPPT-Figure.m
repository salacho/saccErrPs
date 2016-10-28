test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);

% Plotting params
plotParams.nXtick = 6;
plotParams.axisFontSize = 7;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 12;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 2;
plotParams.lineStyle = '-';
plotParams.stdError = 1;                % use standard error of the mean instead of standard deviation. For error bars.
% Colors
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:round(length(plotParams.Color)/10):end,:);   % 32 different colors

XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.lenEpoch-0)/plotParams.nXtick:ErrorInfo.epochInfo.lenEpoch);
arrayLoc = ErrorInfo.plotInfo.arrayLoc;

% Mean values
xVals = (1:1:size(corrEpochs,3));            % x values for error bar lot

% Signals used to extract epochs plotted here
switch ErrorInfo.epochInfo.typeRef
    case 'lfp'
        strgRef = '';
    case 'lapla'
        strgRef = 'lapla-';
    case 'car'
        strgRef = 'car';
end

%% Select type of error bars for correct and incorrect trials
fprintf('Plotting Error Bars for mean epochs per ch and array - %s\n',ErrorInfo.session)

if plotParams.stdError
    corrStdError    =  sqrt(ErrorInfo.epochInfo.nCorr);     % get standard error of the mean
    incorrStdError  =  sqrt(ErrorInfo.epochInfo.nError);    % get standard error of the mean
else
    corrStdError    = 1;    % get standard deviation
    incorrStdError  = 1;    % get standard deviation
end

% Getting mean and std of epochs for each channel per array
if ndims(corrEpochs) == 3
    meanCorrEpoch   = squeeze(mean(corrEpochs,2));      % mean epoch for correct trials
    stdCorrEpoch    = squeeze(std(corrEpochs,0,2))/corrStdError;     % std epoch for correct trials
elseif ndims(corrEpochs) == 2                           %#ok<ISMAT>
    meanCorrEpoch   = corrEpochs;                       % no mean since only one epoch for correct trials
    stdCorrEpoch    = zeros(size(corrEpochs))/corrStdError;          % std = 0 since only one epoch for correct trials
end

%% Plotting error bars for correct and incorrect trials
if ndims(incorrEpochs) == 3
    meanIncorrEpoch = squeeze(mean(incorrEpochs,2));    % mean epoch for incorrect trials
    stdIncorrEpoch  = squeeze(std(incorrEpochs,0,2))/incorrStdError;   % std epoch for incorrect trials
elseif ndims(incorrEpochs) == 2                         %#ok<ISMAT>
    meanIncorrEpoch = incorrEpochs;                     % no mean epoch for incorrect trials, only 1 trial
    stdIncorrEpoch  = zeros(size(incorrEpochs))/incorrStdError;        % std epoch for incorrect trials
end

% Getting max and min values to use equal Y limits in the plots
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

% Start plots
hFig(1) = figure;
set(hFig(1),'PaperPositionMode','auto','Position',[1281 -123 1280 948],...
    'name',sprintf('%s Correct-Incorrect epochs error bars, chs for %s array, %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);


ii = 0;
chList = [21,41,71];
for ii = 1:length(chList)
    iCh = chList(ii);
    %subplot(1,3,ii)
    % Plot error bars
    hold on
    plotParams.plotColors(1,:) = [0 0 1];
    [plotErrCorr] = plotErrorBars(xVals,meanCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) - stdCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) + stdCorrEpoch(iCh,:),plotParams);               % Blue for correct epochs
    plotParams.plotColors(1,:) = [1 0 0];
    [plotErrIncorr] = plotErrorBars(xVals,meanIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) - stdIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) + stdIncorrEpoch(iCh,:),plotParams);     % Red for correct epochs
    % Axis and legend
    axis tight
    if ErrorInfo.plotInfo.equalLimits
        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
            'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.errorBothMeanEpoch(ii) ErrorInfo.plotInfo.equalLim.yMax.errorBothMeanEpoch(ii)]);
    else
        set(gca,'FontSize',plotParams.axisFontSize+5,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    end
    % legend
    legend([plotErrCorr.H,plotErrIncorr.H],{'Correct','Error'},'Location','NorthWest')
xlabel('Time to feedback onset [ms]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
ylabel('Amplitude [mV]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
title(sprintf('LFP ch %s PFC',num2str(iCh)),'FontSize',plotParams.titleFontSize+1,'FontWeight',plotParams.titleFontWeight)
   
end

% Saving figures
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-epochsErrorBar%i-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.plotInfo.stdError,arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig(ii),saveFilename)
end
end
clear legPlots hFig hPlot plotErrCorr plotErrIncorr
