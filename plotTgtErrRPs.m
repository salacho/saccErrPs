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

%% Plot Params
plotInfo = ErrorInfo.plotInfo;
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

% String values to name plots, axis, title, and figures
infoStr = getInfoStr(ErrorInfo);

% Analysis per target
Tgts    = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts   = length(Tgts);

%% Get mean epochs per target
[corrMeanTgt,incorrMeanTgt,corrStdTgt,incorrStdTgt,corrMeanTgtArray,incorrMeanTgtArray,corrStdTgtArray,incorrStdTgtArray] = ...
    getMeanTgtErrPs(tgtErrRPs,ErrorInfo);

% %% Plot everything for each target 
% for iTgt = 1:nTgts
%     % Only when there are incorrect trials for target 'iTgt'
%     if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
%         fprintf('Plotting figures for target %i...\n',iTgt)
%         % Mean values per location
%         corrMean = squeeze(corrMeanTgt(iTgt,:,:));                          % mean values for this target
%         incorrMean = squeeze(incorrMeanTgt(iTgt,:,:));
%        
%          stdCorr = squeeze(corrStdTgt(iTgt,:,:)); 
%          stdIncorr = squeeze(incorrStdTgt(iTgt,:,:));
%         
%         % Create folders to save files Tgt figures
%         if ~exist(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'),'dir')
%             mkdir(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'));
%         end
%         
%         %% Plot error bars of averaged signals for each channels and array
%         hFig = 1:length(arrayLoc);
%         for iArray = 1:length(arrayLoc)
%             hFig(iArray) = figure;
%             set(hFig(iArray),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%                 'name',sprintf('%s Correct-Incorrect mean epochs chs. Tgt%i %s array. %s',ErrorInfo.session,iTgt,arrayLoc{iArray},infoStr.yLimTxt),...
%                 'NumberTitle','off','Visible',plotInfo.visible);
%             % Per array
%             for iCh = 1+(iArray-1)*32:(iArray)*32
%                 subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
%                 subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info                
%                 
%                 % Plot error bars
%                 hold on
%                 plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);         %gree
%                 [~] = plotErrorBars(timeVector,corrMean(iCh,:),corrMean(iCh,:) - stdCorr(iCh,:),corrMean(iCh,:) + stdCorr(iCh,:),plotInfo);              % Blue for correct epochs
%                 plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);         % red
%                 [~] = plotErrorBars(timeVector,incorrMean(iCh,:),incorrMean(iCh,:) - stdIncorr(iCh,:),incorrMean(iCh,:) + stdIncorr(iCh,:),plotInfo); 	% Red for incorrect epochs
%                 axis tight
%                 % Use equal y lim for all plots
%                 if ErrorInfo.plotInfo.equalLimits
%                     set(gca,'FontSize',plotInfo.axisFontSz,...
%                         'Ylim',[plotInfo.equalLim.yMin.errorBothTgt(iTgt,iArray) plotInfo.equalLim.yMax.errorBothTgt(iTgt,iArray)])
%                 else set(gca,'FontSize',plotInfo.axisFontSz)
%                 end
%             end
%             
%             % legend
%             subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
%             legPlots = 1:3;
%             for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
%             hLeg = legend(legPlots,{'Correct','Error',char(arrayLoc{iArray})},0);
%             set(hLeg ,'box','on')
%             axis off                                                                % remove axis and background
%             
%             % Saving figures
%             if ErrorInfo.plotInfo.savePlot
%                 saveFilename = sprintf('%s-corrIncorr-tgt%i-meanErrorBarsChs-%s%s%s.spng',infoStr.strPrefix,...
%                     iTgt,arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
%                 saveas(hFig(iArray),saveFilename)
%             end
%         end
%         clear hFig hPlot legPlots
%         % Closing all figures
%         if strcmp(ErrorInfo.plotInfo.visible,'off')
%             close all
%         end
%         
%         %% Plot all array's channels in one figure (mean epochs, each channel with different color)
%         % Plots mean traces for each array with same color, different color and with std
%         % Figure name
%         titleTxt = 'allChsColor';
%         hFig = figure;
%         set(hFig,'PaperPositionMode','auto','Position',[1096 59 1449 852],...
%             'name',sprintf('%s Correct-Incorrect Tgt%i mean epochs together for %s',ErrorInfo.session,iTgt,titleTxt),...
%             'NumberTitle','off','visible',ErrorInfo.plotInfo.visible);
%         
%         % Plot for each array
%         for iArray = 1:length(arrayLoc)
%             for iCh = 1+(iArray-1)*32:(iArray)*32
%                 % Get trace color vals
%                 chColor     =  mod(iCh-1,size(plotInfo.colorMap,1))+1;       % Trace color from colormap
%                 colorVal1   = plotInfo.colorMap(chColor,:);
%                 colorVal2   = colorVal1;
%                 % Plot
%                 subplot(2,3,1+(iArray-1)), hold on,
%                 plot(detrend(corrMean(iCh,:)),'Color',colorVal1)
%                 title(['Correct Tgt',num2str(iTgt),' mean epochs array ',arrayLoc{iArray}],'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
%                 subplot(2,3,4+(iArray-1)), hold on
%                 plot(detrend(incorrMean(iCh,:)),'Color',colorVal2)
%                 % Title
%                 title(['Tgt',num2str(iTgt),' Incorrect mean epochs array ',arrayLoc{iArray}],'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
%             end
%             % First row plot properties
%             set(gca,'FontSize',plotInfo.axisFontSz+2)
%             xlabel('Time from reward stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
%             ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
%             axis tight;
%             % Second row plot properties
%             subplot(2,3,1+(iArray-1)), axis tight
%             set(gca,'FontSize',plotInfo.axisFontSz+2)
%             
%             xlabel('Time from punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
%             ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
%         end
%         
%         % Saving figures
%         if plotInfo.savePlot
%             saveFilename = sprintf('%s-corrIncorr-tgt%i-overlayMeanChsPerArray-%s%s%s.png',infoStr.strPrefix,...
%                 iTgt,titleTxt,infoStr.signProcStr,infoStr.strSuffix);
%             saveas(hFig,saveFilename)
%             close(hFig)
%         end
%         
%         clear hFig hPlot
%         % Closing all figures
%         if strcmp(ErrorInfo.plotInfo.visible,'off')
%             close all
%         end
%         
%         %% Plotting error bars for mean of all channels per array 
%         hFig = figure;
%         set(hFig,'PaperPositionMode','auto','Position',[282 210 2159 523],...
%             'name',sprintf('%s Correct-Incorrect tgt%i chs error bars for all arrays. %s',ErrorInfo.session,iTgt,infoStr.yLimTxt),...
%             'NumberTitle','off','visible',ErrorInfo.plotInfo.visible);
%         
%         % Plot together mean and std for correct and incorrect for each array
%         for iArray = 1:plotInfo.nArrays
%             % Plot error bars
%             subplot(1,3,iArray), hold on,
%             plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);             % green
%             [plotErrCorr]   = plotErrorBars(timeVector,squeeze(corrMeanTgtArray(iArray,iTgt,:))',...
%                 squeeze(corrMeanTgtArray(iArray,iTgt,:) - corrStdTgtArray(iArray,iTgt,:))',squeeze(corrMeanTgtArray(iArray,iTgt,:) + corrStdTgtArray(iArray,iTgt,:))',plotInfo);               % Blue for correct epochs
%             title(['Tgt',num2str(iTgt),' Correct and Incorrect channels error bars ',arrayLoc{iArray}],'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
%             plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);             % red
%             [plotErrIncorr]   = plotErrorBars(timeVector,squeeze(incorrMeanTgtArray(iArray,iTgt,:))',...
%                 squeeze(incorrMeanTgtArray(iArray,iTgt,:) - incorrStdTgtArray(iArray,iTgt,:))',squeeze(incorrMeanTgtArray(iArray,iTgt,:) + incorrStdTgtArray(iArray,iTgt,:))',plotInfo);               % Blue for correct epochs
%             
%             % Plot properties
%             xlabel('Time from reward/punishment stimulus onset [s]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
%             ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+4,'FontWeight','Bold')
%             axis tight;
%             
%             if ErrorInfo.plotInfo.equalLimits
%                 set(gca,'FontSize',plotInfo.axisFontSz+3,...
%                     'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.errorBothArrayTgt(iTgt,:)) max(ErrorInfo.plotInfo.equalLim.yMax.errorBothArrayTgt(iTgt,:))])
%             else set(gca,'FontSize',plotInfo.axisFontSz+3)
%             end
%             % legend
%             legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontWeight','Bold')
%         end
%         
%         % Saving figures
%         if ErrorInfo.plotInfo.savePlot
%             saveFilename = sprintf('%s-corrIncorr-tgt%i-meanArrayErrorBars%s%s.png',infoStr.strPrefix,...
%                 iTgt,infoStr.signProcStr,infoStr.strSuffix);
%             saveas(hFig,saveFilename)
%             close(hFig)
%         end
%         clear hFig hPlot
%         % Closing all figures
%         if strcmp(ErrorInfo.plotInfo.visible,'off')
%             close all
%         end
%     else
%         fprintf('No plots for target %i...\n',iTgt)
%     end
% end
% %end
% %% Overlay of both correct and incorrect epochs
% % Plot averaged signals for each channels and array
% %ColorMap
% hPlot = nan(nTgts,ErrorInfo.epochInfo.nChs/3);
% legendTxt = repmat('',[1 nTgts]);
% 
% for iArray = 1:3
%     hFig(iArray) = figure;
%     set(hFig(iArray),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%         'name',sprintf('%s Correct-Incorrect mean epochs all tgts %s array. %s',ErrorInfo.session,arrayLoc{iArray},infoStr.yLimTxt),...
%         'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
%     
%     % Plot all targets in each channel
%     for iTgt = 1:nTgts
%         corrMean = squeeze(corrMeanTgt(iTgt,:,:));
%         incorrMean = squeeze(incorrMeanTgt(iTgt,:,:));
%         legendTxt{iTgt} = sprintf('Tgt%i',iTgt);                                    % Possible legend text
%         % Plot each channel
%         for iCh = 1+(iArray-1)*32:(iArray)*32
%             subCh = mod(iCh - 1,32) + 1;                                            % channels from 1-32 per array
%             subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh))     % subplot location using layout info
%             %plot(detrend(corrMean(iCh,:)),'Color',plotInfo.tgtColor(iTgt,:));    % plot Correct epochs
%             plot(detrend(corrMean(iCh,:)),'Color','k');     % plot Correct epochs
%             hold on
%             %plot(detrend(incorrMean(iCh,:)),'Color',plotInfo.tgtColor(iTgt,:),'LineStyle','--')      % plot incorrect epochs
%             hPlot(iTgt,iCh) = plot(detrend(incorrMean(iCh,:)),'Color',plotInfo.colorTgt(iTgt,:),'LineWidth',plotInfo.lineWidth);         % plot incorrect epochs
%             axis tight
%             % Use same Y lim in all plots
%             if ErrorInfo.plotInfo.equalLimits
%                 set(gca,'FontSize',plotInfo.axisFontSz,...
%                     'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.bothTgt(:,iArray)) max(ErrorInfo.plotInfo.equalLim.yMax.bothTgt(:,iArray))])
%             else set(gca,'FontSize',plotInfo.axisFontSz)
%             end
%         
%         end
%     end
%     % legend
%     subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
%     iTxt = 0;
%     for iTgt = 1:nTgts,
%         if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
%             iTxt = iTxt + 1;
%             finalTxt{iTxt} = legendTxt{iTgt};                               %#ok<AGROW>
%             legPlots(iTxt) = plot(0,'Color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth);
%         end
%         hold on,
%     end;                                                                    % plot dummy data to place legends
%     hLeg = legend(legPlots,finalTxt,0,'FontSize',plotInfo.axisFontSz+1);
%     set(hLeg ,'box','off')
%     axis off                                                                % remove axis and background
%     % Saving figures
%     if ErrorInfo.plotInfo.savePlot
%         saveFilename = sprintf('%s-corrIncorr-meanChEpochs-allTgtsColor-%s%s%s.png',infoStr.strPrefix,...
%             arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
%         saveas(hFig(iArray),saveFilename)
%     end
%     clear hFig hPlot legendTxt
% end
% % Closing all figures
% if strcmp(ErrorInfo.plotInfo.visible,'off')
%     close all
% end
% 
%% Plotting per-channel correct/error at target location (6 targets)
% Six targets: color and spatial location (~degrees)
% Plotting for each channel each target location 
legendH = nan(4,1);

for ii = 1:length(ErrorInfo.chList)
    iCh = ErrorInfo.chList(ii);
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect meanEpochs ch%i 6tgts %s',ErrorInfo.session,iCh,infoStr.yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    fprintf('Six target plot for ch%i...\n',iCh);
    
    % Only when there are incorrect trials for target 'iTgt'
    for iTgt = 1: ErrorInfo.epochInfo.nTgts
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
            % Each tgt subplot
            getSubPlot(iTgt,plotInfo), hold on                                            % Get subplot location
            % Get mean and std for each channel
            meanChCorr = squeeze(corrMeanTgt(iTgt,iCh,:))';
            stdChCorr = squeeze(corrStdTgt(iTgt,iCh,:))';
            meanChIncorr = squeeze(incorrMeanTgt(iTgt,iCh,:))';
            stdChIncorr = squeeze(incorrStdTgt(iTgt,iCh,:))';
            
            % Plot error bars
            plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);                               % color of correct
            [plotErrCorr] = plotErrorBars(timeVector,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotInfo);               % Blue for correct epochs
            plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);                               % color of incorrect
            [plotErrIncorr] = plotErrorBars(timeVector,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotInfo);     % Red for correct epochs
            % Plot errDiff
            errDiffH = plot(timeVector,meanChIncorr - meanChCorr,'lineWidth',plotInfo.lineWidth,'color','k'); hold on
            chNumH = plot(0,0);
            axis tight
            % Use same Y lim in all plots
            if plotInfo.equalLimits
                if any(iTgt == [5,6])
                set(gca,'FontSize',plotInfo.axisFontSz+6,...
                    'Ylim',[min(reshape(ErrorInfo.plotInfo.equalLim.yMin.errorBothTgt,[6*3 1])) max(reshape(ErrorInfo.plotInfo.equalLim.yMax.errorBothTgt,[6*3 1]))],...
                    'FontWeight','bold');
                else set(gca,'XTickLabel','','YTickLabel','')
                end
            else set(gca,'FontSize',plotInfo.axisFontSz+4)
            end
            % Legend
            %hLeg = legend([plotErrCorr.H plotErrIncorr.H errDiffH],{'Correct','Incorrect','Incorr - Corr'},'location','SouthWest','FontSize',plotInfo.axisFontSz+2,'FontWeight','Bold');
            %set(hLeg ,'box','off')
            plot([0,0],[min(reshape(ErrorInfo.plotInfo.equalLim.yMin.errorBothTgt,[6*3 1])) max(reshape(ErrorInfo.plotInfo.equalLim.yMax.errorBothTgt,[6*3 1]))],'--k','linewidth',2)
        else                                                                    % No incorrect target for this location
            getSubPlot(iTgt,plotInfo), hold on                                % Get subplot location
            tPlot = plot(1,1,':'); legend(tPlot,'NO TRACES FOR THIS TARGET','FontWeight','Bold','FontSize',14), legend boxoff
            fprintf('No plots for target %i...\n',iTgt)
        end
    end
    % Middle legend
    subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotInfo.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    for iH = 1:2, legendH(iH) = plot(0,0,'color',plotInfo.colorErrP(iH,:),'lineWidth',plotInfo.lineWidth); end
    legendH(3) = plot(0,0,'color',plotInfo.colorErrP(4,:),'lineWidth',plotInfo.lineWidth); legendH(4) = plot(0,0,'color',plotInfo.colorErrP(3,:),'lineWidth',plotInfo.lineWidth); 
    hLeg = legend(legendH,{'Correct','Incorrect','Incorr-Corr',[ErrorInfo.session,'-ch',num2str(iCh)]},'location','SouthWest','FontSize',plotInfo.axisFontSz+7,'FontWeight','Bold');
    set(legend,'position',[0.47 0.47 0.1 0.1])                              % position normalized
    set(hLeg ,'box','off')
    axis off
    
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochs-6Tgts-ch%i%s%s.png',infoStr.strPrefix,...
            iCh,infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
    clear hFig hPlot
end

%% Plotting correct/error at target location (6 targets).
% Six targets: color and spatial location (~degrees)

% Plotting in each target location the array chs mean and std
for iArray = 1:length(arrayLoc)
    hFig(iArray) = figure;
    set(hFig(iArray),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean epochs chs-error bars 6tgts %s array. %s',ErrorInfo.session,arrayLoc{iArray},infoStr.yLimTxt),...
        'NumberTitle','off','Visible','on')%ErrorInfo.plotInfo.visible);

    % Only when there are incorrect trials for target 'iTgt'
    for iTgt = 1: ErrorInfo.epochInfo.nTgts
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
            % Each tgt subplot
            getSubPlot(iTgt,plotInfo), hold on                                            % Get subplot location
            % Get mean and std for each array
            meanChCorr = squeeze(corrMeanTgtArray(iArray,iTgt,:))';
            stdChCorr = squeeze(corrStdTgtArray(iArray,iTgt,:))';
            meanChIncorr = squeeze(incorrMeanTgtArray(iArray,iTgt,:))';
            stdChIncorr = squeeze(incorrStdTgtArray(iArray,iTgt,:))';
            
            % Plot error bars
            plotInfo.plotColors(1,:) = plotInfo.colorErrP(1,:);                               % color of correct
            [plotErrCorr] = plotErrorBars(timeVector,meanChCorr,meanChCorr-stdChCorr,meanChCorr+stdChCorr,plotInfo);               % Blue for correct epochs
            plotInfo.plotColors(1,:) = plotInfo.colorErrP(2,:);                               % color of incorrect
            [plotErrIncorr] = plotErrorBars(timeVector,meanChIncorr,meanChIncorr-stdChIncorr,meanChIncorr+stdChIncorr,plotInfo);     % Red for correct epochs
            % Plot errDiff
            errDiffH = plot(timeVector,meanChIncorr - meanChCorr,'lineWidth',plotInfo.lineWidth,'color','k'); hold on
            axis tight
            % Use same Y lim in all plots
            if plotInfo.equalLimits
                if any(iTgt == [5,6])
                 set(gca,'FontSize',plotInfo.axisFontSz+6,...
                    'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.errorBothArrayTgt(:,iArray)),...
                    max(ErrorInfo.plotInfo.equalLim.yMax.errorBothArrayTgt(:,iArray))],'FontWeight','bold');
                else set(gca,'XTickLabel','','YTickLabel','')
                end
            else set(gca,'FontSize',plotInfo.axisFontSz+4)
            end
            % Legend
            %legend([plotErrCorr.H plotErrIncorr.H errDiffH],{'Correct','Incorrect','Incorr-Corr'},'location','SouthWest','FontSize',plotInfo.axisFontSz+2,'FontWeight','Bold')
            plot([0,0],[min(ErrorInfo.plotInfo.equalLim.yMin.errorBothArrayTgt(:,iArray)) max(ErrorInfo.plotInfo.equalLim.yMax.errorBothArrayTgt(:,iArray))],'--k','linewidth',2)
        else                                                                    % No incorrect target for this location
            getSubPlot(iTgt,plotInfo), hold on                                % Get subplot location
            tPlot = plot(1,1,':'); legend(tPlot,'NO TRACES FOR THIS TARGET','FontWeight','Bold','FontSize',14), legend boxoff
            fprintf('No plots for target %i...\n',iTgt)
        end
    end
    
    % Middle legend
    subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotInfo.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    for iH = 1:2, legendH(iH) = plot(0,0,'color',plotInfo.colorErrP(iH,:),'lineWidth',plotInfo.lineWidth); end
    legendH(3) = plot(0,0,'color',plotInfo.colorErrP(4,:),'lineWidth',plotInfo.lineWidth); legendH(4) = plot(0,0,'color',plotInfo.colorErrP(3,:),'lineWidth',plotInfo.lineWidth); 
    hLeg = legend(legendH,{'Correct','Incorrect','Incorr-Corr',[ErrorInfo.session,'-',ErrorInfo.BCIparams.arrays{iArray}]},'location','SouthWest','FontSize',plotInfo.axisFontSz+7,'FontWeight','Bold');
    set(legend,'position',[0.47 0.47 0.1 0.1])                              % position normalized
    set(hLeg ,'box','off')
    axis off

    
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanArrayErrorBars-6Tgts-%s%s%s.png',infoStr.strPrefix,...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig(iArray),saveFilename)
    end
    clear hFig hPlot
end

end         % function end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getSubPlot(iTgt,plotInfo)
% function getSubPlot(iTgt,plotInfo)
%
% Selects the subplot based on the target number (iTgt)
%

tgtLoc = plotInfo.TgtPlot.subplot{iTgt};
plotLoc = [tgtLoc,tgtLoc + plotInfo.TgtPlot.colms,tgtLoc + 2*plotInfo.TgtPlot.colms,tgtLoc + 3*plotInfo.TgtPlot.colms];
subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotLoc); hold on,

end
