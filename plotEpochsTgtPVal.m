function plotEpochsTgtPVal(expVarTgt,pValsTgt,ErrorInfo)
%
%
%
%
%
%

%% Params
% Six targets: color and spatial location (~degrees)
plotParams.TgtPlot.rows = 12;
plotParams.TgtPlot.colms = 12;
plotParams.TgtPlot.subplot = {57:60,7:10,3:6,49:52,99:102,103:106};       %{[3:6],[7:10],[49:52],[57:60],[99:102],[103:106]};
plotParams.targets = 1:length(ErrorInfo.epochInfo.Tgts);                                   %all possible targets
plotParams.nTgts = length(plotParams.targets);

nTgts = plotParams.nTgts;

% ColorMap params
hFig = figure; plotParams.Color = colormap; close(hFig);
% Plot each expected target trace with one color only
nColors = size(plotParams.Color,1);
plotParams.tgtColor = plotParams.Color(1:round(nColors/nTgts):nColors,:);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors
plotParams.plotColors(1,:) = [0 0 1];                                       % used for errorBar plots
plotParams.arrayColor = [0.8 0.8 0.8];                                      % used for shadow under the curves

% % Arrays
% %expVarTgtMod = nan(size(expVarTgt));
% switch lower(ErrorInfo.session(1))
%     case 'c', arrayLoc = {'PFC','SEF','FEF'}; 
%         expVarTgtMod = expVarTgt;
%     case 'j', arrayLoc = {'SEF','FEF','PFC'}; 
%         expVarTgtMod(:,1:32,:) = expVarTgt(:,65:96,:);
%         expVarTgtMod(:,33:96,:) = expVarTgt(:,1:64,:);
%         arrayLoc = {'PFC','SEF','FEF'}; 
%     case 'p'
%         if strcmp(lower(ErrorInfo.session(4)),'j')
%             expVarTgtMod(:,1:32,:) = expVarTgt(:,65:96,:);
%             expVarTgtMod(:,33:96,:) = expVarTgt(:,1:64,:);
%             arrayLoc = {'PFC','SEF','FEF'};
%         else arrayLoc = {'PFC','SEF','FEF'}; 
%             expVarTgtMod = expVarTgt;
%         end
% end

% Arrays
expVarTgtMod = nan(size(expVarTgt));
switch lower(ErrorInfo.session(1))
    case 'c', arrayLoc = {'PFC','SEF','FEF'}; 
        expVarTgtMod = expVarTgt;
        pValsTgtMod = pValsTgt;
    case 'j', arrayLoc = {'SEF','FEF','PFC'}; 
        expVarTgtMod(:,1:32,:)  = expVarTgt(:,65:96,:);
        expVarTgtMod(:,33:96,:) = expVarTgt(:,1:64,:);
        pValsTgtMod(:,1:32,:)   = pValsTgt(:,65:96,:);
        pValsTgtMod(:,33:96,:)  = pValsTgt(:,1:64,:);
        arrayLoc = {'PFC','SEF','FEF'};
    case 'p'
        if strcmpi((ErrorInfo.session(4)),'j')
            expVarTgtMod(:,1:32,:)  = expVarTgt(:,65:96,:);
            expVarTgtMod(:,33:96,:) = expVarTgt(:,1:64,:);
            pValsTgtMod(:,1:32,:)   = pValsTgt(:,65:96,:);
            pValsTgtMod(:,33:96,:)  = pValsTgt(:,1:64,:);
            arrayLoc = {'PFC','SEF','FEF'};
        else arrayLoc = {'PFC','SEF','FEF'}; 
            expVarTgtMod = expVarTgt;
            pValsTgtMod = pValsTgt;
        end
end

% Plotting params
plotParams.nXtick = 6; %(AFSG-20140305)12;
plotParams.nYtick = 10; %(AFSG-20140305)16; %96; set(gca,'fontsize',6)
plotParams.axisFontSize = 19; %(AFSG-20140305)13;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 20;
plotParams.titleFontWeight = 'Bold';
plotParams.lineWidth = 2;
plotParams.lineStyle = ':';

% Axis labels and position
XtickLabels = (-ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime)/1000;
XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
YtickLabels = 1:round(ErrorInfo.epochInfo.nChs/plotParams.nYtick ):ErrorInfo.epochInfo.nChs;
YtickPos = 1:round(ErrorInfo.epochInfo.nChs/plotParams.nYtick):ErrorInfo.epochInfo.nChs;
% X and Y axis values
timeVals = (1:1:size(expVarTgtMod,3));             % x vals for imagfesc
chVals = 1:1:ErrorInfo.epochInfo.nChs;            % Y vals for imagesc

%% Plotting explained variance of all arrays

% Plot explained variance for target-specific locations
for iNorm = 0:1
    fprintf('Plotting Exp.Var per Tgt for iNorm %i\n',iNorm)
    % Figure
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct/Incorrect epochs explained variance per target for all arrays (norm %i)',ErrorInfo.session,iNorm),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    
    maxExpVarTgt = nanmax(reshape(expVarTgtMod,[prod([size(expVarTgtMod)]) 1]));
    
    for iTgt = 1: ErrorInfo.epochInfo.nTgts
        % Tgt location 
        getSubPlot(iTgt,plotParams), hold on                                            % Get subplot location

        if iNorm == 0
            %hPlot = imagesc(squeeze(expVarTgtMod(iTgt,:,:).*(pValsTgtMod(iTgt,:,:) <= ErrorInfo.analysis.ANOVA.pValCrit/(120*96))));            % not normalized for all targets exp. variance
            hPlot = imagesc((squeeze(pValsTgtMod(iTgt,:,:)) <= ErrorInfo.analysis.ANOVA.pValCrit/(size(pValsTgtMod,3)*96)));            % not normalized for all targets exp. variance
            saveTxt = 'nonNorm';
        else
            %hPlot = imagesc(squeeze(expVarTgtMod(iTgt,:,:).*(pValsTgtMod(iTgt,:,:) <= ErrorInfo.analysis.ANOVA.pValCrit/(120*96)))/maxExpVarTgt,[0 1]); %max(max(max(expVarTgtMod)))]);      % normalized all targets exp. variance
            hPlot = imagesc(squeeze(pValsTgtMod(iTgt,:,:)) <= ErrorInfo.analysis.ANOVA.pValCrit/(size(pValsTgtMod,3)*96)/maxExpVarTgt,[0 1]); %max(max(max(expVarTgtMod)))]);      % normalized all targets exp. variance
            saveTxt = 'Norm';
        end
        % Ratio of incorrect/correct trials per target
        %(AFSG-20140305) title(sprintf('err%i.corr%i',ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt),ErrorInfo.epochInfo.nCorrEpochsTgt(iTgt)),'FontSize',plotParams.axisFontSize-5,'Color','b')
        
        axis tight
        hold on
        % X and Y axis vals
        line([timeVals(1),timeVals(end)],[32 32],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+4,'lineStyle',plotParams.lineStyle)
        line([timeVals(1),timeVals(end)],[64 64],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth+4,'lineStyle',plotParams.lineStyle)
        hBar = colorbar;
        
        % X-axis labels
        if (iTgt == 5)||(iTgt == 6)
            set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize-4.5,'Xtick',XtickPos,'XtickLabel',XtickLabels,'Ytick',YtickPos,'YtickLabel',YtickLabels)
        else
            set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize-4.5,'Xtick',[],'Ytick',YtickPos,'YtickLabel',YtickLabels)
        end
        % Colorbar fontsize
%         if (iTgt == 3)||(iTgt == 5)
%             set(hBar,'FontSize',0.5)
%         end

        %Remove Yaxis
        if (iTgt == 2)||(iTgt == 6)
            set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize-4.5,'Ytick',[])
        end
    end
       
    % Middle legend
    subplot(ErrorInfo.plotInfo.TgtPlot.rows,ErrorInfo.plotInfo.TgtPlot.colms,ErrorInfo.plotInfo.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    for iH = 1:2, legendH(iH) = plot(0,0,'.','color',[1 1 1],'lineWidth',ErrorInfo.plotInfo.lineWidth); end
    hLeg = legend(legendH,{sprintf('Exp.Var. p-val < %0.2f',ErrorInfo.analysis.ANOVA.pValCrit),sprintf('%s-allArrays',ErrorInfo.session)},'location','SouthWest','FontSize',ErrorInfo.plotInfo.axisFontSz+8,'FontWeight','Bold');
    set(legend,'position',[0.45 0.47 0.1 0.1])                              % position normalized
    set(hLeg ,'box','off')
    axis off
    
    % Saving figures
    if ErrorInfo.plotInfo.savePlot
        if strcmp(ErrorInfo.session(1),'p')
            saveFilename = sprintf('%s-epochsPvalTgts-%s-[%i-%ims]-[%0.1f-%iHz]-balance.png',fullfile(ErrorInfo.dirs.saveFilename,ErrorInfo.session),...
                saveTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        else saveFilename = sprintf('%s-epochsPvalTgts-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
                saveTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        end
        saveas(hFig,saveFilename)
        close(hFig)
    end
    clear hFig hPlot
end

% %% Plot p-values
% % 
% warning('Here pVals < 0.05 gives zeros that later are blue. Most of blue are values that are zero and look like they are highly significant')
% warning('NEED TO FIX!!')
% for iNorm = 0:1
%     % Figure
%     hFig = figure;
%     set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
%         'name',sprintf('%s Correc/Incorrect epochs ANOVA p-values for all arrays',ErrorInfo.session),...
%         'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
%     
%     for iTgt = 1: ErrorInfo.epochInfo.nTgts
%         
%         % Getting p-values below threshold only
%         $
%         pValsSign = pValsTgtMod.*~(pValsTgtMod <= ErrorInfo.epochInfo.pValCrit);
%         $
%         % Each tgt
%         %getSubPlot(iTgt,plotParams), hold on                                            % Get subplot location
%                 tgtLoc = plotParams.TgtPlot.subplot{iTgt};
% plotLoc = [tgtLoc,tgtLoc + plotParams.TgtPlot.colms,tgtLoc + 2*plotParams.TgtPlot.colms,tgtLoc + 3*plotParams.TgtPlot.colms];
% subplot(plotParams.TgtPlot.rows,plotParams.TgtPlot.colms,plotLoc); hold on,
% 
%         if iNorm == 0
%             hPlot = imagesc((squeeze(pValsSign(iTgt,:,:))));            % not normalized for all targets exp. variance
%             saveTxt = 'nonNorm';
%         else
%             hPlot = imagesc((squeeze(pValsSign(iTgt,:,:))),[0 ErrorInfo.epochInfo.pValCrit]);      % normalized all targets exp. variance
%             saveTxt = 'Norm';
%         end
%         set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize-4,'Xtick',XtickPos,'XtickLabel',XtickLabels,'Ytick',YtickPos,'YtickLabel',YtickLabels)
%         axis tight
%         hold on
%         % X and Y axis vals
%         line([timeVals(1),timeVals(end)],[32 32],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle)
%         line([timeVals(1),timeVals(end)],[64 64],'Color',plotParams.arrayColor,'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle)
%         colorbar
%     end
%     
%     % Saving figures
%     if ErrorInfo.plotInfo.savePlot
%         saveFilename = sprintf('%s-epochsExpVarTgts-pValsSignif-%0.2f-%s-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
%             ErrorInfo.epochInfo.pValCrit,saveTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
%         saveas(hFig,saveFilename)
%     end
%     clear hFig hPlot
% end

end

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
