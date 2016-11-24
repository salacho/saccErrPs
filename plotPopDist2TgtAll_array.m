function plotPopDist2TgtAll_array(meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo)
% function plotPopDist2TgtAll_array(popCorr,meanPopDist2Tgt,stdPopDist2Tgt,popErrorInfo)
% 
% Plots all mean epochs for both correct and incorrect outcomes, channels and arrays.
%
% INPUT
% corrEpochs:       matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:     matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
% popErrorInfo:        structure. 
%   visiblePlot:    logical. true for figures to be visible. False to do
%                   batch processes without figures popping continuously.
%   equalLimits:    logical. True to use same Y limits for all plots.
%
% Andres v1.0
% Created 11 June 2013
% Last modified 16 July 2013

%  popErrorInfo.plotInfo.equalLim.yMax.maxChs = 30
%  popErrorInfo.plotInfo.equalLim.yMin.minChs = -33
% 

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(popErrorInfo);

%% Params
% Getting plot params
plotInfo = popErrorInfo.plotInfo;
nChs = popErrorInfo.epochInfo.nChs;
arrayLoc = plotInfo.arrayLoc;

% Get trials mean and std or standard error values 
tempFlag = popErrorInfo.epochInfo.getMeanArrayEpoch;
popErrorInfo.epochInfo.getMeanArrayEpoch = true;

popErrorInfo.epochInfo.getMeanArrayEpoch = tempFlag;

% Plotting params
plotInfo.axisFontSz = 13; %(AFSG-20140304) 7;
plotInfo.titleFontSz = 17; %(AFSG-20140304)12; 
plotInfo.lineWidth = plotInfo.lineWidth - 1;

% Time vector 
timeVector = linspace(-popErrorInfo.epochInfo.preOutcomeTime,popErrorInfo.epochInfo.postOutcomeTime,popErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

%% Plot mean and error bars of epochs per channel, per array 
plotInfo.lineWidth = plotInfo.lineWidth - 1;        % making lines smaller to see error bars
for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s %s and mean for %s',popErrorInfo.session,infoStr.stdTxt,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);

    yMin(iArray) = nanmin(nanmin(nanmin([...
        meanPopDist2Tgt.corr(plotInfo.arrayChs(iArray,:),:)-stdPopDist2Tgt.corr(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist1(plotInfo.arrayChs(iArray,:),:)-stdPopDist2Tgt.dist1(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist2(plotInfo.arrayChs(iArray,:),:)-stdPopDist2Tgt.dist2(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist3(plotInfo.arrayChs(iArray,:),:)-stdPopDist2Tgt.dist3(plotInfo.arrayChs(iArray,:),:)])));
    yMax(iArray) = nanmax(nanmax(nanmax([...
        meanPopDist2Tgt.corr(plotInfo.arrayChs(iArray,:),:)+stdPopDist2Tgt.corr(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist1(plotInfo.arrayChs(iArray,:),:)+stdPopDist2Tgt.dist1(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist2(plotInfo.arrayChs(iArray,:),:)+stdPopDist2Tgt.dist2(plotInfo.arrayChs(iArray,:),:),...
        meanPopDist2Tgt.dist3(plotInfo.arrayChs(iArray,:),:)+stdPopDist2Tgt.dist3(plotInfo.arrayChs(iArray,:),:)])));
    
    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        
        
        %%%%%%%%%%%%%%%%%%%%%
        % Corr
        plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
        [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt.corr(iCh,:),...
            meanPopDist2Tgt.corr(iCh,:) - stdPopDist2Tgt.corr(iCh,:),...
            meanPopDist2Tgt.corr(iCh,:) + stdPopDist2Tgt.corr(iCh,:),plotInfo);
        hPlot(1) = plotErrIncorr.H;
        
        % Dist1
        plotInfo.plotColors(1,:) = plotInfo.distColors(2,:);
        [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt.dist1(iCh,:),...
            meanPopDist2Tgt.dist1(iCh,:) - stdPopDist2Tgt.dist1(iCh,:),...
            meanPopDist2Tgt.dist1(iCh,:) + stdPopDist2Tgt.dist1(iCh,:),plotInfo);
        hPlot(2) = plotErrIncorr.H;
        
        % Dist2
        plotInfo.plotColors(1,:) = plotInfo.distColors(3,:);
        [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt.dist2(iCh,:),...
            meanPopDist2Tgt.dist2(iCh,:) - stdPopDist2Tgt.dist2(iCh,:),...
            meanPopDist2Tgt.dist2(iCh,:) + stdPopDist2Tgt.dist2(iCh,:),plotInfo);
        hPlot(3) = plotErrIncorr.H;

        
        % Dist3
        plotInfo.plotColors(1,:) = plotInfo.distColors(4,:);
        [plotErrIncorr] = plotErrorBars(timeVector,meanPopDist2Tgt.dist3(iCh,:),...
            meanPopDist2Tgt.dist3(iCh,:) - stdPopDist2Tgt.dist3(iCh,:),...
            meanPopDist2Tgt.dist3(iCh,:) + stdPopDist2Tgt.dist3(iCh,:),plotInfo);
        hPlot(4) = plotErrIncorr.H;
        axis tight
        
        % Zero line
        plot([0 0],[yMin(iArray) yMax(iArray)],'--k','linewidth',plotInfo.lineWidth-1); hold on
        
        %set(gca,'Ylim',[yMin yMax]);

        if plotInfo.equalLimits
            set(gca,'FontSize',plotInfo.axisFontSz,...
                'Ylim',[yMin(iArray) yMax(iArray)])
        %else set(gca,'FontSize',plotInfo.axisFontSz)
        end
        set(gca,'FontSize',plotInfo.axisFontSz)
    end
    
    % legend
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    allDist = [1 2 3]; %All possible dist2tgts
    for kk = 1:length(allDist)+ 1                                            % plotting dummy traces to add legends
        legPlots(kk) = plot(0,0,'Color',plotInfo.distColors(kk,:),'LineWidth',plotInfo.lineWidth-0.5); hold on %#ok<*AGROW>
        if kk == 1
            legendTxt{kk} = 'Correct';                 % legend text
        else
            legendTxt{kk} = sprintf('Dist %i',allDist(kk-1));                 % legend text
        end
    end;  
    % Add array
    legPlots(kk+1) = plot(0,0,'Color',plotInfo.distColors(kk+1,:),'LineWidth',plotInfo.lineWidth-0.5); hold on , 
    legendTxt{kk+1} = char(arrayLoc(iArray));
    % Adding session and array
    hLeg = legend(legPlots,legendTxt,0,'fontsize',10);
    set(hLeg,'box','off')
    axis off                                                                % remove axis and background
    
    clear legendTxt hPlot legPlots

    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-dist2Tgt-%s%s%s.png',fullfile(popErrorInfo.dirs.DataOut,'popAnalysis',popErrorInfo.session),...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
end
clear hFig hPlot legPlots
plotInfo.lineWidth = plotInfo.lineWidth + 1;        % making lines bigger again. Returning to defualt












