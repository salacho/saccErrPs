function plotMean1ChErrRPs(corrEpochs,incorrEpochs,ErrorInfo,plotChs)
%
%
%
%
% INPUT 
% plotChs:      vector. Three numbers, each one per array. [21,41,70]
%
%
%
% Author :  Andres
% andres    :  1.1  : init.
% andres    :  1.2  : made more efficient

tStart = tic;
%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);

corrIncorrColors = [26 150 65;...   %corr 
                    215 25 28]/255; %incorr

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

hFigArray = figure;
set(hFigArray,'PaperPositionMode','auto','Position',[50 420 1681 420],...
    'name',sprintf('Correct-Incorrect mean epochs for one ch per array %i',yLimTxt),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
for iSub = 1:3
    subplot(1,3,iSub)
    hold on
    hPlotarray(iSub,1) = plot(detrend(corrMean(plotChs(iSub),:)),'color',corrIncorrColors(1,:),'lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
    hPlotarray(iSub,2) = plot(detrend(incorrMean(plotChs(iSub),:)),'color',corrIncorrColors(2,:),'lineStyle',plotParams.lineStyle,'lineWidth',plotParams.lineWidth);
    set(gca,'FontSize',plotParams.axisFontSize+5,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    axis tight
    legend(gca,'Correct','Error','Location','NorthWest')
    xlabel('Time to feedback onset [ms]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
    ylabel('Amplitude [mV]','FontSize',plotParams.axisFontSize+5,'FontWeight',plotParams.axisFontWeight)
    title(sprintf('LFP ch %i PFC',plotChs(iSub)),'FontSize',plotParams.titleFontSize+1,'FontWeight',plotParams.titleFontWeight)
end

if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanEpochs-1ChPerArray-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFigArray,saveFilename)
end

end