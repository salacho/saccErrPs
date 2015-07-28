function plotTgtErrRPs(tgtErrRPs,ErrorInfo)
% function plotTgtErrRPs(tgtErrRPs,ErrorInfo)
%
% For each target location, plots all epochs for both correct and incorrect outcomes, channels and arrays.
%
% INPUT
% tgtErrRPs:
%         corrEpochs:       matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
%         incorrEpochs:     matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% ErrorInfo:                structure.
%         visiblePlot:      logical. true for figures to be visible. False to do
%                           batch processes without figures popping continuously.
%
% Andres v1.0
% Created 11 June 2013
% Last modified 15 July 2013

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
plotParams.lineWidth = 1.5;
plotParams.lineStyle = '-';
% Colors
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors

XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos    = (0:(ErrorInfo.epochInfo.lenEpoch-0)/plotParams.nXtick:ErrorInfo.epochInfo.lenEpoch);
arrayLoc    = ErrorInfo.plotInfo.arrayLoc;

% Type of signals used to get the epochs
switch ErrorInfo.epochInfo.typeRef
    case 'lfp',     strgRef = '';
    case 'lapla',   strgRef = 'lapla-';
    case 'car',     strgRef = 'car';
end

% Analysis per target
Tgts    = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts   = length(Tgts);

% Pre allocating memory
%correct
[nChs,~,nDataPoints] = size(tgtErrRPs(1).corrEpochs);
corrMeanTgt = nan(nTgts,nChs,nDataPoints);      % epochs' mean
%stdCorr = nan(nChs,nDataPoints);               % epochs' standard deviation
%incorrect
[nChs,~,nDataPoints] = size(tgtErrRPs(1).incorrEpochs);
incorrMeanTgt = nan(nTgts,nChs,nDataPoints);
%stdIncorr = nan(nChs,nDataPoints);

% Mean epochs for each target
disp('')
for iTgt = 1:nTgts
    % Getting Mean values for correct and incorrect epochs for target iTgt
    if ndims(tgtErrRPs(iTgt).corrEpochs) == 3
        corrMeanTgt(iTgt,:,:) = squeeze(mean(tgtErrRPs(iTgt).corrEpochs,2));        % getting mean since more than 1 epoch
    elseif ndims(tgtErrRPs(iTgt).corrEpochs) == 2                                   %#ok<ISMAT> % only 1 epoch, no mean
        corrMeanTgt(iTgt,:,:) = tgtErrRPs(iTgt).corrEpochs;
    end
    % Only mean values if more than 1 epoch
    switch ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt)
        case 0                                                                      % no epochs for this target location for incorrect trials
            fprintf('For target %i no incorrect epochs available\n',iTgt)
        case 1                                                                      % only one epoch for this target location for incorrect trials
            incorrMeanTgt(iTgt,:,:) = tgtErrRPs(iTgt).incorrEpochs;
            fprintf('For target %i only 1 epoch available\n',iTgt)
        otherwise                                                                   % getting mean vals for incorrect trials
            fprintf('For target %i, %i epochs available\n',iTgt,ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt))
            incorrMeanTgt(iTgt,:,:) = squeeze(mean(tgtErrRPs(iTgt).incorrEpochs,2));
    end
end
% X values
xVals =  (1:1:size(corrMeanTgt,3));             % x values for error bar lot

% Using max and min values to get equal Y limits in the plots
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

% All plots for each target
%if 1 == 2 
for iTgt = 1:nTgts
    % Only when there are incorrect trials for target 'iTgt'
    if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
        fprintf('Plotting figures for target %i...\n',iTgt)
        % Mean values per location
        corrMean = squeeze(corrMeanTgt(iTgt,:,:));                      % mean values for this target
        incorrMean = squeeze(incorrMeanTgt(iTgt,:,:));
        % Standard deviation per location
        stdCorr = squeeze(std(tgtErrRPs(iTgt).corrEpochs,0,2));         % standard deviation for this target
        stdIncorr = squeeze(std(tgtErrRPs(iTgt).incorrEpochs,0,2)); 
        % Create folders to save files Tgt figures
        if ~exist(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'),'dir')
            mkdir(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'));
        end
        
        %% Plot error bars of averaged signals for each channels and array
        hFig = 1:length(arrayLoc);
        for ii = 1:length(arrayLoc)
            hFig(ii) = figure;
            set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
                'name',sprintf('%s Correct-Incorrect mean epochs chs. Tgt%i %s array. %s',ErrorInfo.session,iTgt,arrayLoc{ii},yLimTxt),...
                'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
            % Per array
            for iCh = 1+(ii-1)*32:(ii)*32
                subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
                subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info                
                % Just plot mean
                %hold on
                %hPlot(ii,1) = plot(detrend(corrMean(iCh,:)),'b','LineWidth',plotParams.lineWidth);                   % plot Correct epochs
                %hPlot(ii,2) = plot(detrend(incorrMean(iCh,:)),'r','LineWidth',plotParams.lineWidth);                 % plot incorrect epochs
                
                % Plot error bars
                hold on
                plotParams.plotColors(1,:) = [0 0 1];
                [~] = plotErrorBars(xVals,corrMean(iCh,:),corrMean(iCh,:) - stdCorr(iCh,:),corrMean(iCh,:) + stdCorr(iCh,:),plotParams);              % Blue for correct epochs
                plotParams.plotColors(1,:) = [1 0 0];
                [~] = plotErrorBars(xVals,incorrMean(iCh,:),incorrMean(iCh,:) - stdIncorr(iCh,:),incorrMean(iCh,:) + stdIncorr(iCh,:),plotParams); 	% Red for incorrect epochs
                axis tight
                % Use equal y lim for all plots
                if ErrorInfo.plotInfo.equalLimits
                    set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                        'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.errorBothTgt(iTgt,ii) ErrorInfo.plotInfo.equalLim.yMax.errorBothTgt(iTgt,ii)])
                else set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
                end
                % % legend
                % if subCh == 1
                %   legend(hPlot(ii,:),{'Correct','Error'},'location','SouthWest')
                % end
            end
            
            % legend
            plotParams.errorColors = [0 0 1; 1 0 0];
            subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
            legPlots = 1:2;
            for kk = 1:2, legPlots(kk) = plot(0,'Color',plotParams.errorColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
            legend(legPlots,{'Correct','Error'},0)
            axis off                                                                % remove axis and background
            
            % Saving figures
            if ErrorInfo.plotInfo.savePlot
                saveFilename = sprintf('%s-corrIncorr-tgt%i-meanEpochs-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt',ErrorInfo.session),...
                    iTgt,arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
                saveas(hFig(ii),saveFilename)
            end
        end
        clear hFig hPlot legPlots
        % Closing all figures
        if strcmp(ErrorInfo.plotInfo.visiblePlot,'off')
            close all
        end
        
        %% Plot all array's channels in one (mean epochs, each channel with different color)
        % Plots mean traces for each array with same color, different color and with std
        colorType = 1;
        % Figure name
        titleTxt = 'allChsColor';
        hFig(colorType) = figure;
        set(hFig(colorType),'PaperPositionMode','auto','Position',[1096 59 1449 852],...
            'name',sprintf('%s Correct-Incorrect Tgt%i mean epochs for %s',ErrorInfo.session,iTgt,titleTxt),...
            'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
        
        % Plot for each array
        for ii = 1:3
            for iCh = 1+(ii-1)*32:(ii)*32
                % Get trace color vals
                chColor     =  mod(iCh-1,size(plotParams.Color,1))+1;       % Trace color from colormap
                colorVal1   = plotParams.Color(chColor,:);
                colorVal2   = colorVal1;
                % Plot
                subplot(2,3,1+(ii-1)), hold on,
                plot(detrend(corrMean(iCh,:)),'Color',colorVal1)
                title(['Correct Tgt',num2str(iTgt),' mean epochs array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
                subplot(2,3,4+(ii-1)), hold on
                plot(detrend(incorrMean(iCh,:)),'Color',colorVal2)
                % Title
                title(['Tgt',num2str(iTgt),' Incorrect mean epochs array ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
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
            saveFilename = sprintf('%s-corrIncorr-tgt%i-meanEpochs-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt',ErrorInfo.session),...
                iTgt,titleTxt,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
            saveas(hFig(colorType),saveFilename)
        end
        
        clear hFig hPlot
        % Closing all figures
        if strcmp(ErrorInfo.plotInfo.visiblePlot,'off')
            close all
        end
        
        %% Plotting error bars for mean of all channels per array 
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
            'name',sprintf('%s Correct-Incorrect tgt%i chs error bars for all arrays. %s',ErrorInfo.session,iTgt,yLimTxt),...
            'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
        
        % Plot together mean and std for correct and incorrect for each array
        for ii = 1:3
            % Get mean and std values
            meanChCorr      = nanmean(corrMean(1+(ii-1)*32:(ii)*32,:),1);
            stdChCorr       = nanstd(corrMean(1+(ii-1)*32:(ii)*32,:),1);
            meanChIncorr    = nanmean(incorrMean(1+(ii-1)*32:(ii)*32,:),1);
            stdChIncorr     = nanstd(incorrMean(1+(ii-1)*32:(ii)*32,:),1);
            
            % Plot error bars
            subplot(1,3,ii), hold on,
            plotParams.plotColors(1,:) = [0 0 1];
            [plotErrCorr]   = plotErrorBars(xVals,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
            title(['Tgt',num2str(iTgt),' Correct and Incorrect channels error bars ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
            plotParams.plotColors(1,:) = [1 0 0];
            [plotErrIncorr] = plotErrorBars(xVals,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
            
            % Plot properties
            xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
            ylabel('Signal voltage [uV]','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
            axis tight;
            
            if ErrorInfo.plotInfo.equalLimits
                set(gca,'FontSize',plotParams.axisFontSize+3,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                    'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.errorBothArrayTgt(iTgt,:)) max(ErrorInfo.plotInfo.equalLim.yMax.errorBothArrayTgt(iTgt,:))])
            else set(gca,'FontSize',plotParams.axisFontSize+3,'Xtick',XtickPos,'XtickLabel',XtickLabels)
            end
            % legend
            legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontWeight','Bold')
        end
        
        % Saving figures
        if ErrorInfo.plotInfo.savePlot
            saveFilename = sprintf('%s-corrIncorr-tgt%i-chsErrorBars-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt',ErrorInfo.session),...
                iTgt,strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
            saveas(hFig,saveFilename)
        end
        clear hFig hPlot
        % Closing all figures
        if strcmp(ErrorInfo.plotInfo.visiblePlot,'off')
            close all
        end
    else
        fprintf('No plots for target %i...\n',iTgt)
    end
end
%end
%% Overlay of both correct and incorrect epochs

% Plot averaged signals for each channels and array
%ColorMap
figHand = figure; 
plotParams.Color = colormap; close(figHand);
plotParams.tgtColor = plotParams.Color(1:round(length(plotParams.Color)/nTgts):end,:);   % 32 different colors
hPlot = nan(nTgts,ErrorInfo.epochInfo.nChs/3);
legendTxt = repmat('',[1 nTgts]);

for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean epochs all tgts %s array. %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
    
    % Plot all targets in each channel
    for iTgt = 1:nTgts
        corrMean = squeeze(corrMeanTgt(iTgt,:,:));
        incorrMean = squeeze(incorrMeanTgt(iTgt,:,:));
        legendTxt{iTgt} = sprintf('Tgt%i',iTgt);                                    % Possible legend text
        % Plot each channel
        for iCh = 1+(ii-1)*32:(ii)*32
            subCh = mod(iCh - 1,32) + 1;                                            % channels from 1-32 per array
            subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh))     % subplot location using layout info
            %plot(detrend(corrMean(iCh,:)),'Color',plotParams.tgtColor(iTgt,:));    % plot Correct epochs
            plot(detrend(corrMean(iCh,:)),'Color','k');     % plot Correct epochs
            hold on
            %plot(detrend(incorrMean(iCh,:)),'Color',plotParams.tgtColor(iTgt,:),'LineStyle','--')      % plot incorrect epochs
            hPlot(iTgt,iCh) = plot(detrend(incorrMean(iCh,:)),'Color',plotParams.tgtColor(iTgt,:),'LineWidth',plotParams.lineWidth);         % plot incorrect epochs
            axis tight
            % Use same Y lim in all plots
            if ErrorInfo.plotInfo.equalLimits
                set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                    'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.bothTgt(:,ii)) max(ErrorInfo.plotInfo.equalLim.yMax.bothTgt(:,ii))])
            else set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
            end
        
        end
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    iTxt = 0;
    for iTgt = 1:nTgts,
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
            iTxt = iTxt + 1;
            finalTxt{iTxt} = legendTxt{iTgt};                               %#ok<AGROW>
            legPlots(iTxt) = plot(0,'Color',plotParams.tgtColor(iTgt,:),'lineWidth',plotParams.lineWidth);
        end
        hold on,
    end;                                                                    % plot dummy data to place legends
    legend(legPlots,finalTxt,0,'FontSize',plotParams.axisFontSize+1)
    axis off                                                                % remove axis and background
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochs-allTgtsColor-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
    clear hFig hPlot legendTxt
end
% Closing all figures
if strcmp(ErrorInfo.plotInfo.visiblePlot,'off')
    close all
end

%% Plotting correct/error at target location (6 targets).
% Six targets: color and spatial location (~degrees)
plotParams.TgtPlot.rows = 12;
plotParams.TgtPlot.colms = 12;
plotParams.TgtPlot.subplot = {57:60,7:10,3:6,49:52,99:102,103:106};       %{[3:6],[7:10],[49:52],[57:60],[99:102],[103:106]};
plotParams.targets = 1:length(ErrorInfo.epochInfo.Tgts);                                   %all possible targets
plotParams.nTgts = length(plotParams.targets);

% Plotting in each target location the array chs mean and std
for ii = 1:length(arrayLoc)
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean epochs chs-error bars 6tgts %s array. %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);

    % Only when there are incorrect trials for target 'iTgt'
    for iTgt = 1: ErrorInfo.epochInfo.nTgts
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
            % Get data for this target - all channels
            corrMean = squeeze(corrMeanTgt(iTgt,:,:));
            incorrMean = squeeze(incorrMeanTgt(iTgt,:,:));
            
            % Each tgt subplot
            getSubPlot(iTgt,plotParams), hold on                                            % Get subplot location
            % Get mean and std for each array
            meanChCorr = mean(corrMean((ii-1)*32+1:ii*32,:),1);
            stdChCorr = std(corrMean((ii-1)*32+1:ii*32,:),1);
            meanChIncorr = mean(incorrMean((ii-1)*32+1:ii*32,:),1);
            stdChIncorr = std(incorrMean((ii-1)*32+1:ii*32,:),1);
            % Plot error bars
            plotParams.plotColors(1,:) = [0 0 1];                               % color of correct
            [plotErrCorr] = plotErrorBars(xVals,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotParams);               % Blue for correct epochs
            plotParams.plotColors(1,:) = [1 0 0];                               % color of incorrect
            [plotErrIncorr] = plotErrorBars(xVals,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotParams);     % Red for correct epochs
            axis tight
            % Use same Y lim in all plots
            if ErrorInfo.plotInfo.equalLimits
                set(gca,'FontSize',plotParams.axisFontSize+4,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                    'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.errorBothArrayTgt(:,ii)) max(ErrorInfo.plotInfo.equalLim.yMax.errorBothArrayTgt(:,ii))]);
            else set(gca,'FontSize',plotParams.axisFontSize+4,'Xtick',XtickPos,'XtickLabel',XtickLabels)
            end
            % Legend
            legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontSize',plotParams.axisFontSize+2,'FontWeight','Bold')
        else                                                                    % No incorrect target for this location
            getSubPlot(iTgt,plotParams), hold on                                % Get subplot location
            tPlot = plot(1,1,':'); legend(tPlot,'NO TRACES FOR THIS TARGET','FontWeight','Bold','FontSize',14), legend boxoff
            fprintf('No plots for target %i...\n',iTgt)
        end
    end
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-chsErrorBars-6Tgts-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{ii},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(ii),saveFilename)
    end
    clear hFig hPlot
end

end         % function end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getSubPlot(iTgt,plotParams)
% function getSubPlot(iTgt,plotParams)
%
% Selects the subplot based on the target number (iTgt)
%

tgtLoc = plotParams.TgtPlot.subplot{iTgt};
plotLoc = [tgtLoc,tgtLoc + plotParams.TgtPlot.colms,tgtLoc + 2*plotParams.TgtPlot.colms,tgtLoc + 3*plotParams.TgtPlot.colms];
subplot(plotParams.TgtPlot.rows,plotParams.TgtPlot.colms,plotLoc); hold on,

end
