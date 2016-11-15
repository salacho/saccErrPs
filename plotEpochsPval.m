function plotEpochsPval(expVar,pVals,ErrorInfo)
%
%
%
%
%
% andres    : 1.2   : added Jonah compatibility

%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);
% Arrays
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
% Plotting params
plotParams.nXtick = 12;
plotParams.nYtick = 10; %(AFSG-20140305)16; %96; set(gca,'fontsize',6)
plotParams.axisFontSize = 16; %(AFSG-20140305)13;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 17;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 2;
plotParams.lineStyle = ':';
% Axis
XtickLabels = (-ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime)/1000;
XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
YtickLabels = 1:round(ErrorInfo.epochInfo.nChs/plotParams.nYtick ):ErrorInfo.epochInfo.nChs;
YtickPos = 1:round(ErrorInfo.epochInfo.nChs/plotParams.nYtick ):ErrorInfo.epochInfo.nChs;
% Colors
% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors
plotParams.arrayColor = [0.8 0.8 0.8];

timeVals = (1:1:size(expVar,2));            % x vals for imagfesc
chVals = 1:ErrorInfo.epochInfo.nChs;          % Y vals for imagesc

% % Arrays
% expVarMod = nan(size(expVar));
% switch lower(ErrorInfo.session(1))
%     case 'c', arrayLoc = {'PFC','SEF','FEF'}; 
%         expVarMod = expVar;
%     case 'j', arrayLoc = {'SEF','FEF','PFC'}; 
%         expVarMod(1:32,:) = expVar(65:96,:);
%         expVarMod(33:96,:) = expVar(1:64,:);
%         arrayLoc = {'PFC','SEF','FEF'}; 
%     case 'p'
%         if strcmp(lower(ErrorInfo.session(4)),'j')
%             expVarMod(1:32,:) = expVar(65:96,:);
%             expVarMod(33:96,:) = expVar(1:64,:);
%             arrayLoc = {'PFC','SEF','FEF'};
%         else arrayLoc = {'PFC','SEF','FEF'}; 
%             expVarMod = expVar;
%         end
% end

% Arrays
expVarMod = nan(size(expVar));
switch lower(ErrorInfo.session(1))
    case 'c', arrayLoc = {'PFC','SEF','FEF'}; 
        expVarMod = expVar;
    case 'j', arrayLoc = {'SEF','FEF','PFC'}; 
        expVarMod(1:32,:) = expVar(65:96,:);
        expVarMod(33:96,:) = expVar(1:64,:);
        pValsMod(1:32,:) = pVals(65:96,:);
        pValsMod(33:96,:) = pVals(1:64,:);
        arrayLoc = {'PFC','SEF','FEF'};
    case 'p'
        if strcmp(lower(ErrorInfo.session(4)),'j')
            expVarMod(1:32,:) = expVar(65:96,:);
            expVarMod(33:96,:) = expVar(1:64,:);
            pValsMod(1:32,:) = pVals(65:96,:);
            pValsMod(33:96,:) = pVals(1:64,:);
            arrayLoc = {'PFC','SEF','FEF'};
        else arrayLoc = {'PFC','SEF','FEF'}; 
            expVarMod = expVar;
            pValsMod = pVals;
        end
end

%% Plotting explained variance of all arrays
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1394         126        1006         730],...
    'name',sprintf('%s Correct/Incorrect epochs explained variance for all arrays',ErrorInfo.session),...
    'NumberTitle','off','Visible','on')%ErrorInfo.plotInfo.visible);

hPlot = imagesc(pValsMod <= (ErrorInfo.analysis.ANOVA.pValCrit/(size(expVarMod,2)*96)));
set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,'Ytick',YtickPos,'YtickLabel',YtickLabels)

% Plotting array limits
hold on
line([timeVals(1),timeVals(end)],[32 32],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+4,'lineStyle',plotParams.lineStyle)
line([timeVals(1),timeVals(end)],[64 64],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+4,'lineStyle',plotParams.lineStyle)
hBar = colorbar;
set(hBar,'Fontsize',plotParams.axisFontSize);

xlabel('Time to feedback onset [s]','FontSize',plotParams.axisFontSize+2,'FontWeight',plotParams.axisFontWeight)
ylabel('Electrode #','FontSize',plotParams.axisFontSize+2,'FontWeight',plotParams.axisFontWeight)

% Title
title(sprintf('%s Epochs Exp. Var. for all channels and arrays pVal <= %0.3f',ErrorInfo.session,ErrorInfo.analysis.ANOVA.pValCrit),'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)

% Saving figures
if ErrorInfo.plotInfo.savePlot
    if strcmp(ErrorInfo.session(1),'p')
        saveFilename = sprintf('%s-epochsPval-[%i-%ims]-[%0.1f-%iHz]-balance.png',fullfile(ErrorInfo.dirs.saveFilename,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    else
        
    saveFilename = sprintf('%s-epochsPval-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    end
    saveas(hFig,saveFilename)
end
clear hFig hPlot

% %% Plot p-values
% warning('Here pVals < 0.05 gives zeros that later are blue. Most of blue are values that are zero and look like they are highly significant')
% hFig = figure;
% set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%     'name',sprintf('%s Correct/Incorrect epochs ANOVA p-values for all arrays',ErrorInfo.session),...
%     'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
% 
% pValsSign = pVals.*(pVals <= ErrorInfo.epochInfo.pValCrit);
% hPlot = imagesc((squeeze(pValsSign)));
% set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,'Ytick',YtickPos,'YtickLabel',YtickLabels)
% 
% % Plotting array limits
% hold on
% line([timeVals(1),timeVals(end)],[32 32],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+2,'lineStyle',plotParams.lineStyle)
% line([timeVals(1),timeVals(end)],[64 64],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+2,'lineStyle',plotParams.lineStyle)
% colorbar
% 
% xlabel('Time from reward stimulus onset [ms]','FontSize',plotParams.axisFontSize+2,'FontWeight',plotParams.axisFontWeight)
% ylabel('Electrode #','FontSize',plotParams.axisFontSize+2,'FontWeight',plotParams.axisFontWeight)
% 
% % Title
% title(sprintf('%s Correct/Incorrect epochs ANOVA p-values for all arrays',ErrorInfo.session),'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
% 
% % Saving figures
% if ErrorInfo.plotInfo.savePlot
%     saveFilename = sprintf('%s-epochsExpVar-pValSignif-%0.2f-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
%         ErrorInfo.epochInfo.pValCrit,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
%     saveas(hFig,saveFilename)
% end
% clear hFig hPlot legPlots
% 
%% Plotting explained variance for each array

% % Updating Plotting params
% plotParams.nXtick = 6;
% plotParams.axisFontSize = 7;
% plotParams.titleFontSize = 12;
% plotParams.lineStyle = '-';
% plotParams.arrayColors = [0 153 0; 204 0 0; 51 51 255]/255;
% % Axis
% XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
% XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
% 
% % Plotting expVar for each array
% hFig = figure;
% set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%     'name',sprintf('%s Correct/Incorrect epochs explained variance for all arrays',ErrorInfo.session),...
%     'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
% for ii = 1:3
%     for iCh = 1+(ii-1)*32:(ii)*32
%         subCh = mod(iCh - 1,32) + 1;                                                    % channels from 1-32 per array
%         subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh))             % subplot location using layout info
%         hPlot(subCh,ii) = plot(detrend(expVar(iCh,:)),'Color',plotParams.arrayColors(ii,:),'lineWidth',1.5);% plot explained variance for each channel
%         hold on
%         axis tight
%         set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
%     end
% end
% % legend
% subplot(layoutInfo.rows,layoutInfo.colms,1)             % use subplot to place legend outside the graph
% for kk = 1:3, legPlots(kk) = plot(0,'Color',plotParams.arrayColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
% legend(legPlots,arrayLoc,'location','best')                  % legends
% axis off % remove axis and background
% 
% titleTxt = 'allArrays';
% 
% % Saving figures
% if ErrorInfo.plotInfo.savePlot
%     saveFilename = sprintf('%s-epochsExpVar-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
%         titleTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
%     saveas(hFig,saveFilename)
% end
% clear hFig hPlot
% 
% %% Plot all array's exp.var. channels in one
% 
% % Plots exp. var. traces for each array with same color, different color and mean per array with std
% titleTxt = 'allChsAndErrorBars';
% hFig = figure;
% set(hFig,'PaperPositionMode','auto','Position',[532 155 1841 615],...
%     'name',sprintf('%s Correct-Incorrect epochs explained variance %s',ErrorInfo.session,titleTxt),...
%     'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
% xVals = 1:ErrorInfo.epochInfo.epochLen;
% 
% for colorType = 1:2
%     % Plot for each array
%     for ii = 1:3
%         if (colorType == 1)                                 % plot each channel epoch-averaged trace
%             for iCh = 1+(ii-1)*32:(ii)*32
%                 % Get trace color vals
%                 if colorType == 1                                                      % all traces diff. color (to see shape and amp. changes w.r.t. ch. location)
%                     chColor =  mod(iCh-1,size(plotParams.Color,1))+1;       % Trace color from colormap
%                     colorVal1 = plotParams.Color(chColor,:);
%                     colorVal2 = colorVal1;
%                 end
%                 % Plot
%                 subCh =  mod(iCh-1,size(plotParams.Color,1))+1;
%                 subplot(2,3,ii), hold on,
%                 hPlot(subCh) = plot(detrend(expVar(iCh,:)),'Color',colorVal1);
%                 % legend
%                 legendTxt{iCh} = sprintf('Ch%i',iCh);
%                 % Title
%                 title([ErrorInfo.session,' Corr/Incorr Epochs Explained Variance for ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
%             end
%             %             if colorType == 2
%             %                 legend(hPlot,legendTxt,'Location','SouthWest','FontSize',5)
%             %             end
%         else                                                                    % plot the averaged-epoch and channel traces representative for all the array
%             % Getting mean and std for all channels per array
%             meanChExpVar = mean(expVar(1+(ii-1)*32:(ii)*32,:),1);
%             stdChExpVar = std(expVar(1+(ii-1)*32:(ii)*32,:),1);
%             % Plot error bars
%             subplot(2,3,ii+3), hold on,
%             plotParams.plotColors(1,:) = [0 0 1];
%             [plotErrCorr] = plotErrorBars(xVals,meanChExpVar,meanChExpVar-stdChExpVar,meanChExpVar+stdChExpVar,plotParams);               % Blue for correct epochs
%             % Title
%             title(['Mean and STD Exp.Var. for channels in ',arrayLoc{ii}],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
%         end
%         % First row plot properties
%         set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
%         xlabel('Time from reward stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
%         ylabel('Explained Variance','FontSize',plotParams.axisFontSize+4,'FontWeight',plotParams.axisFontWeight)
%         axis tight;
%     end
% end
% 
% % Saving figures
% if ErrorInfo.plotInfo.savePlot
%     saveFilename = sprintf('%s-epochsExpVariance-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
%         titleTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
%     saveas(hFig,saveFilename)
% end
% clear hFig hPlot
% 

end
