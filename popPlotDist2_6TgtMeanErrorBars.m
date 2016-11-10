function popPlotDist2_6TgtMeanErrorBars(meanPopDist2Tgt,stdPopDist2Tgt,sessionList,ErrorInfo)
%
%
%
%
%
% 08 Nov 2014

plotInfo = ErrorInfo.plotInfo;
arrayLoc = plotInfo.arrayLoc;
infoStr = getInfoStr(ErrorInfo);
% Time vector 
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

%% Population Y axis limits
switch lower(char(sessionList{1}(1)));
    case 'j'
        yMin = -65;
        yMax = 65;
    case 'c'
        yMin = -80;
        yMax = 80;
end

%% Plot mean and std for each array
% Six targets: color and spatial location (~degrees)

popSession = sprintf('pop%s-%s',char(sessionList(1)),char(sessionList(end)));
ErrorInfo.sessions = popSession;

for iCh = 1:96
    hFig = figure; 
    disp('...')
    set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('Population mean and error bars all distance to true location - 6Tgts in ch %i. %s',iCh,infoStr.yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    
    fprintf('Plotting 6tgt layout for ch %i...\n',iCh)
    for iTgt = 1:ErrorInfo.epochInfo.nTgts
        % Each tgt
        getSubPlot(iTgt,plotInfo), hold on                                % Get subplot location
        % Number of incorrect and correct trials per target location
        %(AFSG-20140304) title(sprintf('%ierr.%icorr',ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt),ErrorInfo.epochInfo.nCorrEpochsTgt(iTgt)),'FontSize',plotInfo.axisFontSize+2,'color','b')
        legendTxt{1} = 'Correct';                                           % first legend text
        % Corr
        if meanPopDist2Tgt(iTgt).corrNumTrials ~= 0
            plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
            [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt(iTgt).corr(iCh,:),...
                meanPopDist2Tgt(iTgt).corr(iCh,:) - stdPopDist2Tgt(iTgt).corr(iCh,:),...
                meanPopDist2Tgt(iTgt).corr(iCh,:) + stdPopDist2Tgt(iTgt).corr(iCh,:),plotInfo);
            hPlot(1,iTgt) = plotErrIncorr.H;
            axis tight,set(gca,'Ylim',[yMin yMax]);
        end
        
        % Zero line
        plot([0 0],[-90 90],'--k','linewidth',plotInfo.lineWidth-2); hold on
        
        % Dist1
        if meanPopDist2Tgt(iTgt).dist1numTrials ~= 0
            plotInfo.plotColors(1,:) = plotInfo.distColors(2,:);
            [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt(iTgt).dist1(iCh,:),...
                meanPopDist2Tgt(iTgt).dist1(iCh,:) - stdPopDist2Tgt(iTgt).dist1(iCh,:),...
                meanPopDist2Tgt(iTgt).dist1(iCh,:) + stdPopDist2Tgt(iTgt).dist1(iCh,:),plotInfo);
            hPlot(2,iTgt) = plotErrIncorr.H;
            axis tight,set(gca,'Ylim',[yMin yMax]);
        end
        
        % Dist2
        if meanPopDist2Tgt(iTgt).dist2numTrials ~= 0
            plotInfo.plotColors(1,:) = plotInfo.distColors(3,:);
            [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt(iTgt).dist2(iCh,:),...
                meanPopDist2Tgt(iTgt).dist2(iCh,:) - stdPopDist2Tgt(iTgt).dist2(iCh,:),...
                meanPopDist2Tgt(iTgt).dist2(iCh,:) + stdPopDist2Tgt(iTgt).dist2(iCh,:),plotInfo);
            hPlot(3,iTgt) = plotErrIncorr.H;
            axis tight,set(gca,'Ylim',[yMin yMax]);
        end
        
        % Dist3
        if meanPopDist2Tgt(iTgt).dist3numTrials ~= 0
            plotInfo.plotColors(1,:) = plotInfo.distColors(4,:);
            [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt(iTgt).dist3(iCh,:),...
                meanPopDist2Tgt(iTgt).dist3(iCh,:) - stdPopDist2Tgt(iTgt).dist3(iCh,:),...
                meanPopDist2Tgt(iTgt).dist3(iCh,:) + stdPopDist2Tgt(iTgt).dist3(iCh,:),plotInfo);
            hPlot(4,iTgt) = plotErrIncorr.H;
            axis tight,set(gca,'Ylim',[yMin yMax]);
        end
        
        
        %             % Equal Y axis
        %             if ErrorInfo.plotInfo.equalLimits
        %                 set(gca,'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothArrayMeanDist2tgt(iArray) ErrorInfo.plotInfo.equalLim.yMax.bothArrayMeanDist2tgt(iArray)])
        %             end
        
        %% Only axis in bottom plots
        if (iTgt == 5) || (iTgt == 6)
            set(gca,'FontSize',plotInfo.axisFontSz+8)
        else
            set(gca,'FontSize',plotInfo.axisFontSz+8,'Xtick',[],'Ytick',[])
        end
    end
    
    
    % Legends in center of 6 tgt plots
    subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotInfo.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    allDist = [1 2 3]; %All possible dist2tgts
    for kk = 1:length(allDist)+ 1                                            % plotting dummy traces to add legends
        legPlots(kk) = plot(0,0,'Color',plotInfo.distColors(kk,:),'LineWidth',plotInfo.lineWidth-0.5); hold on %#ok<*AGROW>
        if kk == 1
            legendTxt{kk} = 'Correct';                 % legend text
        else
            legendTxt{kk} = sprintf('Dist %i',allDist(kk-1));                 % legend text
        end
    end; 
    % Adding session and array
    legPlots(end+1) = plot(0,0,'k','LineWidth',plotInfo.lineWidth-0.5);legendTxt{end+1} = sprintf('pop-Ch%i',iCh); %#ok<AGROW>
    legend(legPlots,legendTxt,'location','Best','FontSize',plotInfo.axisFontSz+8,'FontWeight','bold')                                            % Include legend
    set(legend,'position',[0.47 0.47 0.1 0.1])                              % position normalized
    axis off
    
    clear legendTxt hPlot legPlots
    % Saving plots
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanSessions-dist2tgt-Ch%i%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',popSession),...
            iCh,infoStr.strgRef,infoStr.yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig,saveFilename)
    end
    close(hFig)
end

clear hPlot hFig legPlots

end 
    