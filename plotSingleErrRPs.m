function ErrorInfo = plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
% function ErrorInfo = plotSingleErrRPs(corrEpochs,incorrEpochs,corrBaseline,incorrBaseline,ErrorInfo)
%
% Plot single epochss of error-related potentials (ErrRPs) inn the array 
% configuration, by target or using error bars. 
%
% INPUT
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% ErrorInfo:                ErrRps info structure. The structure 'epochInfo' is included
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% OUTPUT
% ErrorInfo:                ErrRps info structure. The structure 'epochInfo' is included
%         epochInfo:        structure. Has info regarding type of data
%                           loaded to get the epochs, time windows and filter params.
%                           Also, it has the decoded and expected target
%                           values: 'corrDcdTgt', 'corrExpTgt',
%                           'incorrDcdTgt', 'incorrExpTgt'.
% Andres v1.0

%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);

% Plotting params
plotParams.nXtick = 12;
plotParams.axisFontSize = 15; %(AFSG-20140305) 7
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 12;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 4;
plotParams.lineStyle = '-';
plotParams.stdError = 0;                % use standard error of the mean instead of standard deviation. For error bars.
% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:round(length(plotParams.Color)/10):end,:);   % 32 different colors

XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
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
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 -123 1280 948],...
        'name',sprintf('%s Correct-Incorrect epochs error bars, chs for %s array, %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        % Plot error bars
        hold on
        %(AFSG-20140304) plotParams.plotColors(1,:) = [1 0 0];
        plotParams.plotColors(1,:) = [26 150 65]/255;
        [plotErrCorr] = plotErrorBars(xVals,meanCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) - stdCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) + stdCorrEpoch(iCh,:),plotParams);               % Blue for correct epochs
        %(AFSG-20140304) plotParams.plotColors(1,:) = [1 0 0];
        plotParams.plotColors(1,:) = [215 25 28]/255;
        [plotErrIncorr] = plotErrorBars(xVals,meanIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) - stdIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) + stdIncorrEpoch(iCh,:),plotParams);     % Red for correct epochs
        % Axis and legend
        axis tight
        if ErrorInfo.plotInfo.equalLimits
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
               'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.errorBothMeanEpoch(ii) ErrorInfo.plotInfo.equalLim.yMax.errorBothMeanEpoch(ii)]);
        else
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        end
        % if subCh == 1
        %   legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontSize',plotParams.axisFontSize,'FontWeight','Bold')
        %   legend boxoff
        % end
    end
    
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error'},'Location','Best')
    axis off                                                                % remove axis and background
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-epochsErrorBar%i-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            ErrorInfo.plotInfo.stdError,arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear legPlots hFig hPlot plotErrCorr plotErrIncorr

% %% Error bar for epochs per array (averaged all channels)
% %% Plot 10 single incorrect epochs over and mean correct epoch
% for ii = 1:3
%     hFig(ii) = figure;
%     set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%         'name',sprintf('%s Correct-Incorrect mean epochs chs for %s array',ErrorInfo.session,arrayLoc{ii}),...
%         'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
%     for iCh = 1+(ii-1)*32:(ii)*32
%         subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
%         subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
%         % plot Correct epochs
%         hPlot(ii,1) = plot(detrend(mean(squeeze(corrEpochs(iCh,:,:)),1)),'k','linewidth',3);                     % correct epochs
%         hold on
%         for kk = 1:10
%             hPlot(ii,2) = plot(squeeze(detrend(incorrEpochs(iCh,kk,:))),'Color',plotParams.Color(kk,:));                 % plot incorrect epochs
%             % hPlot(ii,1) = plot(detrend(corrMean(iCh,:)),'k','linewidth',3);
%             % Axis and legend
%             axis tight
%             set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
%         end
%         % if subCh == 1
%         %   legend(hPlot(ii,:),{'Correct','Error'},'location','SouthWest')
%         % end
%     end
%     
%     % legend
%     plotParams.errorColors = [0 0 0;0 0 1];
%     subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
% 	for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
%     legend(legPlots,{'Correct','Error'},0)                 
%     axis off                                                                % remove axis and background
%     
%     % Saving figures
%     if ErrorInfo.plotInfo.savePlot
%         saveFilename = sprintf('%s-corrIncorr-singleEpochs-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
%             arrayLoc{ii},strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
%         saveas(hFig(ii),saveFilename)
%     end
% end
% clear hFig hPlot legPlots

%% Plot error bars of correct and incorrect baseline 
fprintf('Plotting Error Bars for mean baseline epochs per ch and array - %s\n',ErrorInfo.session)

% Getting mean and std of epochs for each channel per array
if ndims(corrBaseline) == 3                           
    meanCorrEpoch   = squeeze(mean(corrBaseline,2));      % mean epoch for correct trials
    stdCorrEpoch    = squeeze(std(corrBaseline,0,2));     % std epoch for correct trials
elseif ndims(corrBaseline) == 2                           %#ok<ISMAT>
    meanCorrEpoch   = corrBaseline;                       % no mean since only one epoch for correct trials
    stdCorrEpoch    = zeros(size(corrBaseline));          % std = 0 since only one epoch for correct trials
end

if ndims(incorrBaseline) == 3
    meanIncorrEpoch = squeeze(mean(incorrBaseline,2));    % mean epoch for incorrect trials
    stdIncorrEpoch  = squeeze(std(incorrBaseline,0,2));   % std epoch for incorrect trials
elseif ndims(incorrBaseline) == 2                         %#ok<ISMAT>
    meanIncorrEpoch = incorrBaseline;                     % no mean epoch for incorrect trials, only 1 trial
    stdIncorrEpoch  = zeros(size(incorrBaseline));        % std epoch for incorrect trials
end

% Baseline x values
xVals = 1:round(ErrorInfo.Behav.dur.itiDur*ErrorInfo.epochInfo.Fs);
XtickLabels = 0:round(ErrorInfo.Behav.dur.itiDur*ErrorInfo.epochInfo.Fs)/plotParams.nXtick:round(ErrorInfo.Behav.dur.itiDur*ErrorInfo.epochInfo.Fs);
XtickPos = 0:round(ErrorInfo.Behav.dur.itiDur*ErrorInfo.epochInfo.Fs)/plotParams.nXtick:round(ErrorInfo.Behav.dur.itiDur*ErrorInfo.epochInfo.Fs);
arrayLoc = ErrorInfo.plotInfo.arrayLoc;

% Getting max and min values to use equal Y limits in the plots
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

% Start plots
for ii = 1:3
    hFig(ii) = figure;  %#ok<*AGROW>
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect baseline epochs error-Bars start itiOnset, chs for %s array, %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        % Plot error bars
        hold on
        %(AFSG-20140304) plotParams.plotColors(1,:) = [0 0 1];
        plotParams.plotColors(1,:) = [26 150 65]/255;

        [plotErrCorr] = plotErrorBars(xVals,meanCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) - stdCorrEpoch(iCh,:),meanCorrEpoch(iCh,:) + stdCorrEpoch(iCh,:),plotParams);               % Blue for correct epochs
        %(AFSG-20140304) plotParams.plotColors(1,:) = [1 0 0];
        plotParams.plotColors(1,:) = [215 25 28]/255;
        [plotErrIncorr] = plotErrorBars(xVals,meanIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) - stdIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:) + stdIncorrEpoch(iCh,:),plotParams);     % Red for correct epochs
        % Axis and legend
        axis tight
        if ErrorInfo.plotInfo.equalLimits
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
               'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.errorBothMeanEpoch(ii) ErrorInfo.plotInfo.equalLim.yMax.errorBothMeanEpoch(ii)]);
        else
           set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        end
        % if subCh == 1
        %   legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontSize',plotParams.axisFontSize,'FontWeight','Bold')
        %   legend boxoff
        % end
    end
    
    % legend
    plotParams.errorColors = [0 0 1; 1 0 0];
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
    legend(legPlots,{'Correct','Error'},'Location','Best')
    axis off                                                                % remove axis and background
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-baselineEpochsErrorBar-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear legPlots hFig hPlot plotErrCorr plotErrIncorr

