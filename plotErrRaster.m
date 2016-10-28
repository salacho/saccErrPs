function plotErrRaster(corrRaster,incorrRaster,ErrorInfo)
%
% This function plots raster data for all trials for mean and sum correct 
% and incorrect trials for all cells/units/channels. 
%
% 
%
%
%
%
%
%
% Author : Andres.
% 
% Andres :  init    : 20 Oct 2014
% Andres :  


%% Mean trial values
disp('Getting mean trial values for corrRaster and incorrRaster')
corrMeanRaster = squeeze(mean(corrRaster,2));           
incorrMeanRaster = squeeze(mean(incorrRaster,2));
incorrCorrMeanRasterDiff = (incorrMeanRaster - corrMeanRaster);

disp('Getting sum of all trial values for corrRaster and incorrRaster')
corrSumRaster = squeeze(sum(corrRaster,2));           
incorrSumRaster = squeeze(sum(incorrRaster,2));
incorrCorrSumRasterDiff = (incorrSumRaster - corrSumRaster);

plotInfo = ErrorInfo.plotInfo;

% Plotting params
for iArray = 1:plotInfo.nArrays
    indxArray = find(ErrorInfo.spikeInfo.arrayCellUnits{iArray});
    plotInfo.arrayIndx(iArray,:) = [indxArray(1) indxArray(end)];
end

%% Bin data


%% Plot average and sum trial spike activity for all correct and incorrect units

dataList = {'corrMeanRaster','corrSumRaster','incorrMeanRaster','incorrSumRaster','incorrCorrMeanRasterDiff','incorrCorrSumRasterDiff'};
dataListTitle = {'corrMean','corrSum','errMean','errSum','errCorrDiffMean','errCorrDiffSum'};

if length(dataList) == length(dataListTitle);
    hFig = figure;
    set(hFig,'Position',[257    80   836   841],'PaperPositionMode','auto',...
        'name',sprintf('%s mean and sum Correct-Incorrect trials spike activity, all cells %s',ErrorInfo.session,ErrorInfo.spikeInfo.txtRoot),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    for iData = 1:6         %subplot number
        % Data to plot
        eval(sprintf('data2plot = ~%s;',dataList{iData}))
        % Plot correct cells
        subplot(3,2,iData)
        imagesc(ErrorInfo.spikeInfo.timeVector,ErrorInfo.spikeInfo.chSpkVector,data2plot)
        colormap(gray)
        % Axis properties
        set(gca,'Ydir','normal')
        if iData == 1 || iData == 2
            title(sprintf('%s-%s',ErrorInfo.session,dataListTitle{iData}),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
        else
            title(dataListTitle{iData},'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
        end
        xlabel('Time from feedback onset [sec]')
        ylabel('Channel')
        % Plot feedback onset line
        hold on
        line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
        
        % Set arrays lines
        for iArray = 1:ErrorInfo.BCIparams.nArrays - 1
            % Start
            line([ErrorInfo.spikeInfo.timeVector(1) ErrorInfo.spikeInfo.timeVector(1)+(ErrorInfo.spikeInfo.timeVector(end)-ErrorInfo.spikeInfo.timeVector(1))/20],...
                [ErrorInfo.spikeInfo.chSpkVector(plotInfo.arrayIndx(iArray,2)) ErrorInfo.spikeInfo.chSpkVector(plotInfo.arrayIndx(iArray,2))],...
            'lineWidth',1.5,'lineStyle',plotInfo.lineStyle,'Color','r')
            % End
            line([ErrorInfo.spikeInfo.timeVector(end)-((ErrorInfo.spikeInfo.timeVector(end)-ErrorInfo.spikeInfo.timeVector(1))/20) ErrorInfo.spikeInfo.timeVector(end)],...
                [ErrorInfo.spikeInfo.chSpkVector(plotInfo.arrayIndx(iArray,2)) ErrorInfo.spikeInfo.chSpkVector(plotInfo.arrayIndx(iArray,2))],...
            'lineWidth',1.5,'lineStyle',plotInfo.lineStyle,'Color','r')

        end
        axis tight
    end
else
    error('dataList and dataListTitle do not have same length!!')
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-allTrialsRaster-[%i-%ims]%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
    ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.spikeInfo.txtRoot);
    saveas(hFig,saveFilename)
end

% %% Plot spikes as traces
% figure, 
% plot(1:ErrorInfo.spikeInfo.nSpkSamp,corrSumRaster,'*','Color',plotInfo.colorErrP(1,:))
% hold on
% plot(incorrSumRaster,1:ErrorInfo.spikeInfo.nSpkSamp,'*','Color',plotInfo.colorErrP(2,:))
% 
% plot(corrSumRaster,incorrSumRaster,'*')


%% Plots per channel/cell/unit
% %% Plot per cell/channel all trial spike activity for all correct and incorrect units
% figure
% for iCell = 1:size(corrSumRaster,1)
%     % Plot correct cells
%     subplot(2,1,1)
%     imagesc(ErrorInfo.spikeInfo.timeVector,[1:ErrorInfo.spikeInfo.nCorr],squeeze(~corrRaster(iCell,:,:)))
%     colormap(gray)
%     set(gca,'Ydir','normal')
%     title(sprintf('Corr cell%i',iCell))
%     ylabel('Channel')
%     % Plot feedback onset line
%     hold on
%     line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
%     colorbar
%     hold off
%     
%     % Plot incorrect cells
%     subplot(2,1,2)
%     imagesc(ErrorInfo.spikeInfo.timeVector,[1:ErrorInfo.spikeInfo.nErr],squeeze(~incorrRaster(iCell,:,:)))
%     colormap(gray)
%     set(gca,'Ydir','normal')
%     title(sprintf('Err'))
%     % Plot feedback onset line
%     hold on
%     line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
%     colorbar
%     hold off 
%     
%     pause
% end
%
% %% Plot sum of all trial spike activity for all correct and incorrect units
% figure
% for iCell = 1:size(corrSumRaster,1)
%     % Plot correct cells
%     subplot(3,1,1)
%     imagesc(ErrorInfo.spikeInfo.timeVector,ErrorInfo.spikeInfo.chSpkVector,~corrSumRaster(iCell,:))
%     colormap(gray)
%     set(gca,'Ydir','normal')
%     title(sprintf('Corr cell%i',iCell))
%     ylabel('Channel')
%     % Plot feedback onset line
%     hold on
%     line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
%     colorbar
%     hold off
%     
%     % Plot incorrect cells
%     subplot(3,1,2)
%     imagesc(ErrorInfo.spikeInfo.timeVector,ErrorInfo.spikeInfo.chSpkVector,~incorrSumRaster(iCell,:))
%     colormap(gray)
%     set(gca,'Ydir','normal')
%     title(sprintf('Err'))
%     % Plot feedback onset line
%     hold on
%     line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
%     colorbar
%     hold off 
%     
%     % Plot incorrect-correct cells
%     subplot(3,1,3)
%     imagesc(ErrorInfo.spikeInfo.timeVector,ErrorInfo.spikeInfo.chSpkVector,~incorrCorrSumRasterDiff(iCell,:))
%     colormap(gray)
%     set(gca,'Ydir','normal')
%     title(sprintf('Err-Corr'))
%     % Plot feedback onset line
%     hold on
%     line([0 0],[-1 ErrorInfo.nChs],'color','k','lineWidth',2,'lineStyle','--')
%     colorbar
%     hold off 
%     
%     pause
% end

%% Plot for each array
