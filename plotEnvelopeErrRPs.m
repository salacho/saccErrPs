function plotEnvelopeErrRPs(envelopCorrMean,envelopIncorrMean,corrMean,incorrMean,ErrorInfo);%envelopCorrEpochs,envelopIncorrEpochs)
%
%
%
%
%
%
%
% %% Try plot
% envCorrMean = squeeze(mean(envelopCorrEpochs,2));
% envIncorrMean = squeeze(mean(envelopIncorrEpochs,2));
% 
% figure,
% iCh = 33;
% subplot(2,1,1), hold on,
% plot(detrend(squeeze(mean(corrEpochs(iCh,:,:),2))),'b')
% plot(detrend(envCorrMean(iCh,:)),'r')
% subplot(2,1,2), hold on,
% plot(detrend(squeeze(mean(incorrEpochs(iCh,:,:),2))),'b')
% plot(detrend(envIncorrMean(iCh,:)),'r') 
% 
% figure
% iCh = 33;
% hold on,
% plot(detrend(envelopCorrMean(iCh,:)),'b')
% plot(detrend(envelopIncorrMean(iCh,:)),'r')
% legendTxt{1} = 'envelope of mean correct epoch';
% legendTxt{2} = 'envelope of mean incorrect epoch';
% plot(detrend(envCorrMean(iCh,:)),':b')
% plot(detrend(envIncorrMean(iCh,:)),':r') 
% legendTxt{3} = 'mean of envelope of each correct epoch';
% legendTxt{4} = 'mean of envelope of each incorrect epoch';
% legend(legendTxt,'Location','NorthWest')

%Some basic plot params
%% Params
% Getting layout for array/channel distribution
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
% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors

XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.lenEpoch-0)/plotParams.nXtick:ErrorInfo.epochInfo.lenEpoch);
arrayLoc = ErrorInfo.plotInfo.arrayLoc;

% Type of signals used to get the epochs
switch ErrorInfo.epochInfo.typeRef
    case 'lfp'
        strgRef = '';
    case 'lapla'
        strgRef = 'lapla_';
    case 'car'
        strgRef = 'car';
end

%% Plotting envelope of averaged epochs for each channel and array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1921 1 1920 1004],...
        'name',sprintf('%s Correct-Incorrect envelope of mean epochs per ch for %s array',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
    % Plotting averaged epochs
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        plot(envelopCorrMean(iCh,:),'b')
        hold on,
        plot(envelopIncorrMean(iCh,:),'r')
        axis tight
        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    end
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochsEnvelope-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig

%% Plotting envelope of all epochs for each channel and array

for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1921 1 1920 1004],...
        'name',sprintf('%s Correct-Incorrect envelope and mean epochs per ch for %s array',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
    % Plotting averaged epochs
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        plot(envelopCorrMean(iCh,:),'b')
        hold on,
        plot(corrMean(iCh,:),':b')
        plot(envelopIncorrMean(iCh,:),'r')
        plot(incorrMean(iCh,:),':r')
        axis tight
        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    end
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochsEnvelope2-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
end
clear hFig

%% Aggregated channels

% Plots mean traces for each array with same color, different color and with std
xVals = (1:1:length(envelopCorrMean(1,:)));            % x values for error bar lot
for colorType = 2:3
    % Figure name
    switch colorType
        case 2
            titleTxt = 'allChsColor';
        case 3
            titleTxt = 'MeanChs';
    end
    hFig(colorType) = figure;
    set(hFig(colorType),'PaperPositionMode','auto','Position',[1921 1 1920 1004],...
        'name',sprintf('%s Correct-Incorrect envelope of mean epochs array/channels %s',ErrorInfo.session,titleTxt),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    % Plot for each array
    for ii = 1:3
        if (colorType == 1) || (colorType == 2)                                 % plot each channel epoch-averaged trace
            for iCh = 1+(ii-1)*32:(ii)*32
                % Get trace color vals
                switch colorType
                    case 2                                                      % all traces diff. color (to see shape and amp. changes w.r.t. ch. location)
                        chColor =  mod(iCh-1,size(plotParams.Color,1))+1;       % Trace color from colormap
                        colorVal1 = plotParams.Color(chColor,:);
                        colorVal2 = colorVal1;
                end
                % Plot
                subplot(2,3,1+(ii-1)), hold on,
                plot(detrend(envelopCorrMean(iCh,:)),'Color',colorVal1)
                title(['Mean Correct epochs envelope for array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
                subplot(2,3,4+(ii-1)), hold on
                plot(detrend(envelopIncorrMean(iCh,:)),'Color',colorVal2)
                % Title
                title(['Mean Incorrect epochs envelope for array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
            end
        else                                                                    % plot the averaged-epoch and channel traces representative for all the array 
            % Getting mean and std for all channels per array
            meanChCorr = mean(envelopCorrMean(1+(ii-1)*32:(ii)*32,:),1);
            stdChCorr = std(envelopCorrMean(1+(ii-1)*32:(ii)*32,:),1);
            meanChIncorr = mean(envelopIncorrMean(1+(ii-1)*32:(ii)*32,:),1);
            stdChIncorr = std(envelopIncorrMean(1+(ii-1)*32:(ii)*32,:),1);
            % Plot error bars
            subplot(2,3,1+(ii-1)), hold on,
            plotParams.plotColors(1,:) = [0 0 1];
            [plotErrCorr] = plotErrorBars(xVals,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
            title(['Mean Correct epochs/chs envelope for array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
            plotParams.plotColors(1,:) = [1 0 0];
            subplot(2,3,4+(ii-1)), hold on
            [plotErrCorr] = plotErrorBars(xVals,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
            % Title
            title(['Mean Incorrect epochs/chs envelope for array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
        end
        % First row plot properties
        set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        xlabel('Time from reward stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
        ylabel('Envelope power','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
        axis tight;
        % Second row plot properties
        subplot(2,3,1+(ii-1)), axis tight
        set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
        
        xlabel('Time from punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
        ylabel('Envelope power','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
    end
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-MeanEpochsEnvelope-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            titleTxt,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(colorType),saveFilename)
    end
end
clear hFig

%% Overlay of both correct and incorrect envelopes 
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1945 329 1884 451],...
    'name',sprintf('%s Correct-Incorrect overlay of mean epochs envelopes for all arrays %s',ErrorInfo.session),...
    'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);

% Plot together mean and std for correct and incorrect for each array
for ii = 1:3
    % Get mean and std values
    meanChCorr = mean(envelopCorrMean(1+(ii-1)*32:(ii)*32,:),1);
    stdChCorr = std(envelopCorrMean(1+(ii-1)*32:(ii)*32,:),1);
    meanChIncorr = mean(envelopIncorrMean(1+(ii-1)*32:(ii)*32,:),1);
    stdChIncorr = std(envelopIncorrMean(1+(ii-1)*32:(ii)*32,:),1);
    
    % Plot error bars
    subplot(1,3,ii), hold on,
    plotParams.plotColors(1,:) = [0 0 1];
    [plotErrCorr] = plotErrorBars(xVals,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
    title(['Mean epochs envelope (meanChs) Correct/Incorrect ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
    plotParams.plotColors(1,:) = [1 0 0];
    [plotErrIncorr] = plotErrorBars(xVals,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
    
    % Plot properties
    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight','normal')
    ylabel('Envelope power','FontSize',plotParams.axisFontSize+4,'FontWeight','normal')
    axis tight;
    legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'});
    legend boxoff
end

% Saving figures
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-MeanEpochsEnvelope-MeanChs2-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
end
clear hFig

