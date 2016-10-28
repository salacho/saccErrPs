function plotDist2TgtPerCh(tgt2DistEpochs,tgtErrRPs,corrEpochs,ErrorInfo)
% function plotDist2TgtPerCh(tgt2DistEpochs,tgtErrRPs,corrEpochs,ErrorInfo)
% 
% Plots distance to target traces per channel and per location in visual
% field (6 target location). Mean epochs.
%
% INPUT
% tgt2DistEpochs:           structure [1:numTargets].For each target it
%                           has the following fields:
%         dist2tgt          vector. All possible distances of incorrect targets to true location    
%         dcdTgtRange:      vector. Possible dcd targets given to this location (erroneous locations). 
%                           Possible values taken by dcd target for this true target location (iTgt)
%         numEpochsPerDist: integer. Number of epochs for each distance to true location
%         epochDist1:       matrix. [numChns numEpochs(for distance 1) numDataPoints]. 
%                           Error epochs with error at a distance 1 to the target location
%         epochDist2:       matrix. [numChns numEpochs(for distance 2) numDataPoints]. 
%                           Error epochs with error at a distance 2 to the target location
%         epochDist3:       matrix. [numChns numEpochs(for distance 3) numDataPoints]. 
%                           Error epochs with error at a distance 3 to the target location
%         dcdTgtDist1:      vector. Decoded targets for the error epochs with distance 1 to the target location
%         dcdTgtDist2:      vector. Decoded targets for the error epochs with distance 2 to the target location
%         dcdTgtDist3:      vector. Decoded targets for the error epochs with distance 3 to the target location
%         stdEpochDist1:    vector. Std of error epochs for distance 1 to target location
%         stdEpochDist2:    vector. Std of error epochs for distance 2 to target location
%         stdEpochDist3:    vector. Std of error epochs for distance 3 to target location
%         meanEpochDist1:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 1 to target location
%         meanEpochDist2:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 2 to target location
%         meanEpochDist3:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 3 to target location
%
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
%
% Andres v1.0
% Created: June 2013
% Last modified: 18 July 2013
% Last modified: 01 March 2014
%
% Andres    : v2.0  : changed parameters to load from ErrorInfo.plotInfo 25 Nov 2014
 

% Plot params
plotInfo = ErrorInfo.plotInfo;
% Get string txts for titles, axis, saveFilename, ...
infoStr = getInfoStr(ErrorInfo);

%% Params
% Arrays
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
% Analysis per target
Tgts = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);

%timeVector
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

% Get mean and st.dev. vals for correct and dist2tgt trials
[incorrMeanDist2Tgt,incorrStdDist2Tgt,~,~,ErrorInfo] = ...
    getMeanDist2TgtErrPs(tgt2DistEpochs,ErrorInfo);
[corrMeanTgt,incorrMeanTgt,corrStdTgt,incorrStdTgt,corrMeanTgtArray,incorrMeanTgtArray,corrStdTgtArray,incorrStdTgtArray] = getMeanTgtErrPs(tgtErrRPs,ErrorInfo);

%% Plotting error potentials based on distance to true location per array/per channel
% Mean and std values for correct epochs
if ErrorInfo.plotInfo.tracePerArrayPerTgt == 1
    % Plot for each array
    for ii = 1:length(ErrorInfo.chList)
        iCh = ErrorInfo.chList(ii);
        % Plot for each target
        for iTgt = 1:nTgts
            % Only when there are incorrect trials for target 'iTgt'
            if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
                fprintf('Plotting independently ch%...tgt%i dist2tgt...\n',iCh,iTgt)
                distVals = tgt2DistEpochs(iTgt).dist2tgt;   % List of distance of dcd target to true location
                
                % Figure properties
                hFig = figure;
                set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
                    'name',sprintf('%s mean error - all distance to true location - tgt%i in ch%s %s',ErrorInfo.session,iTgt,iCh,infoStr.yLimTxt),...
                    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
                %stdEpochTgt = squeeze(std(corrEpochs(:,corrIndx,:),0,2));
                legendTxt = repmat('',[1,length(distVals)]);
                legendTxt{1} = 'Correct';                                           % legend for correct trials
                
                % Plotting mean vals per dist2tgt
                for iDist = 1:length(distVals)
                    % Mean or error epochs
                    % Standard deviation of error epochs
                    legendTxt{1 + iDist} = sprintf('Dist %i',iDist);                % legend text
                    % Correct mean and std values for each target
                    corrEpochTgt = squeeze(corrMeanTgt(iTgt,iCh,:));
                    % Subplot
                    hold on,
                    if iDist == 1
                        plot(timeVector,corrEpochTgt,'Color',plotInfo.distColors(1,:),'LineWidth',plotInfo.lineWidth);       %#ok<AGROW>
                    end
                    plot(timeVector,squeeze(incorrMeanDist2Tgt(iDist,iTgt,iCh,:)),'Color',plotInfo.distColors(iDist+1,:),'LineWidth',plotInfo.lineWidth); %#ok<AGROW>
                    axis tight
                    %                     if ErrorInfo.plotInfo.equalLimits
                    %                         set(gca,'FontSize',plotInfo.axisFontSz,...
                    %                             'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothChDist2tgt(iTgt,iArray) ErrorInfo.plotInfo.equalLim.yMax.bothChDist2tgt(iTgt,iArray)])
                    %                     else
                    %                         set(gca,'FontSize',plotInfo.axisFontSz)
                    %                     end
                end
                
                % legend
                legPlots = nan(length(distVals)+1,1);
                for kk = 1:length(distVals)+1, legPlots(kk) = plot(0,'Color',plotInfo.distColors(kk,:),'LineWidth',plotInfo.lineWidth-0.5); hold on, end;    % plot fake data to polace legends
                legend(legPlots,legendTxt,0,'FontSize',plotInfo.titleFontSz,'FontWeight','Bold')                                            % Include legend
                
                clear lengendTxt hPlot legPlots
                % Saving figure
                if ErrorInfo.plotInfo.savePlot
                    saveFilename = sprintf('%s-corrIncorr-tgt%i-meanEpochs-dist2tgt-%s%s%s.png',infoStr.strPrefix,...
                        iTgt,arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
                    saveas(hFig(iTgt,iArray),saveFilename)
                end
            else
                fprintf('No plots for target %i since no there are no trials\n',iTgt)
            end         % end if numTrials ~= 0
        end             % end for iTgt
    end                 % end iCh
end                     % end if tracePer ArrayPerTarget
clear hFig hPlot legendTxt legPlots

%% Plotting mean of dist2tgt per array and true target
numRows = sum((ErrorInfo.epochInfo.nIncorrEpochsTgt ~= 0));                 % number of rows for plot
% Figure properties
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s mean chs distance to true location - tgt%i in all arrays. %s',ErrorInfo.session,iTgt,infoStr.yLimTxt),...
    'NumberTitle','off','Visible',plotInfo.visible);
TgtIndx = 0;                                                                % initial conditions used for subplot eval
yaxisTxt = 1:length(arrayLoc):length(arrayLoc)*nTgts;                     % Y axis txt vble

% Plot for each target
for iTgt = 1:nTgts
    % Only when there are incorrect trials for target 'iTgt'
    if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
        fprintf('Plotting for tgt%i mean chs dist2tgt for all arrays...\n',iTgt)
        distVals = tgt2DistEpochs(iTgt).dist2tgt;                           % List of distance of dcd target to true location
        TgtIndx = TgtIndx + 1;                                              % indexing of targets with incorrect trials
        %stdEpochTgt = squeeze(std(corrEpochs(:,corrIndx,:),0,2));
        legendTxt = repmat('',[1,length(distVals)]);
        legendTxt{1} = 'Correct';                                           % legend for correct trials
        hPlot = nan(length(arrayLoc),nTgts,length(distVals));
        
        % Plotting mean vals per dist2tgt
        for iDist = 1:length(distVals)
            % legend text
            legendTxt{1 + iDist} = sprintf('Dist %i',iDist);
            
            % Get mean of chs for each array
            for iArray = 1:length(arrayLoc)
                subplot(numRows,length(arrayLoc),iArray + length(arrayLoc)*(TgtIndx - 1))
                if iDist == 1
                    hPlot(iArray,TgtIndx,iArray) = plot(timeVector,squeeze(corrMeanTgtArray(iArray,iTgt,:)),'Color',plotInfo.distColors(1,:),'LineWidth',plotInfo.lineWidth);
                end
                hold on
                hPlot(iArray,TgtIndx,iDist+1) = plot(timeVector,squeeze(incorrMeanTgtArray(iArray,iTgt,:)),'Color',plotInfo.distColors(iDist+1,:),'LineWidth',plotInfo.lineWidth);
                axis tight
                if ErrorInfo.plotInfo.equalLimits
                    set(gca,'FontSize',plotInfo.axisFontSz,...
                        'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.bothMeanDist2tgt) max(ErrorInfo.plotInfo.equalLim.yMax.bothMeanDist2tgt)])
                else
                    set(gca,'FontSize',plotInfo.axisFontSz)
                end
                % Array Area
                if TgtIndx == 1
                    title(sprintf('%s',arrayLoc{iArray}),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
                end
                % Target number in first row
                if any((iArray + length(arrayLoc)*(TgtIndx - 1) == yaxisTxt))
                    ylabel(sprintf('Tgt %i',iTgt),'FontSize',plotInfo.titleFontSz - 1,'FontWeight',plotInfo.axisFontWeight)
                end
            end
        end
    else
        fprintf('No incorrect trials for target %i',iTgt);
    end
end
% Saving plots
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanEpochs-meanChs-perTarget-dist2tgt%s%s.png',infoStr.strPrefix,...
        infoStr.signProcStr,infoStr.strSuffix);
    saveas(hFig,saveFilename)
end
clear hFig hPlot legendTxt legPlots


%% Plot mean and std for each array
% Six targets: color and spatial location (~degrees)
for iArray = 1:length(arrayLoc)
    hFig(iArray) = figure;
    disp('...')
    set(hFig(iArray),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s mean error - all distance to true location - 6Tgts in %s array. %s',ErrorInfo.session,arrayLoc{iArray},infoStr.yLimTxt),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    for iTgt = 1:ErrorInfo.epochInfo.nTgts
        fprintf('Plotting 6tgt layout %s array...tgt%i\n',arrayLoc{iArray},iTgt)
        distVals = tgt2DistEpochs(iTgt).dist2tgt;                           % List of distance of dcd target to true location
        % Each tgt
        getSubPlot(iTgt,plotInfo), hold on                                % Get subplot location
        % Number of incorrect and correct trials per target location
        legendTxt{1} = 'Correct';                                           % first legend text
        
        for iDist = 1:length(distVals)
            %disp(distVals)
            % for each ch in the array
            plot([0 0],[-90 90],'--k','linewidth',plotInfo.lineWidth-2); hold on
            
            if iDist == 1
                % plotInfo.plotColors(1,:) = [0 0 1];
                % [plotErrCorr] = plotErrorBars(timeVector,squeeze(corrMeanTgtArray(iArray,iTgt,:)),...
                %squeeze(corrMeanTgtArray(iArray,iTgt,:) - corrStdTgtArray(iArray,iTgt,:)),squeeze(corrMeanTgtArray(iArray,iTgt,:) + corrStdTgtArray(iArray,iTgt,:)),plotInfo);               % Blue for correct epochs
                hPlot(1,iTgt) = plot(timeVector,squeeze(corrMeanTgtArray(iArray,iTgt,:)),'Color',plotInfo.distColors(1,:),'LineWidth',plotInfo.lineWidth); %#ok<AGROW>
            end
            % iDist
            plotInfo.plotColors(1,:) = plotInfo.distColors(iDist+1,:);
            if any(isnan(squeeze(incorrMeanDist2TgtArray(iArray,iDist,iTgt,:))))
                plotErrIncorr.H = plot(0,0);
            else
                [plotErrIncorr] = plotErrorBars(timeVector,squeeze(incorrMeanDist2TgtArray(iArray,iDist,iTgt,:))',...
                    squeeze(incorrMeanDist2TgtArray(iArray,iDist,iTgt,:) - incorrStdDist2TgtArray(iArray,iDist,iTgt,:))',...
                    squeeze(incorrMeanDist2TgtArray(iArray,iDist,iTgt,:) + incorrStdDist2TgtArray(iArray,iDist,iTgt,:))',plotInfo);
            end
            hPlot(iDist+1,iTgt) = plotErrIncorr.H;
            
            axis tight
            % Equal Y axis
            if ErrorInfo.plotInfo.equalLimits
                set(gca,'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothArrayMeanDist2tgt(iArray)-10 ErrorInfo.plotInfo.equalLim.yMax.bothArrayMeanDist2tgt(iArray)+10])
            end
            
            %% Only axis in bottom plots
            if (iTgt == 5) || (iTgt == 6)
                set(gca,'FontSize',plotInfo.axisFontSz+2)
            else
                set(gca,'FontSize',plotInfo.axisFontSz+2,'Xtick',[],'Ytick',[])
            end
        end
    end
    
    % Legends in center of 6 tgt plots
    subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotInfo.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    allDist = (unique([tgt2DistEpochs(:).dist2tgt]));                         % All possible dist2tgts
    for kk = 1:length(allDist)+ 1                                            % plotting dummy traces to add legends
        legPlots(kk) = plot(0,0,'Color',plotInfo.distColors(kk,:),'LineWidth',plotInfo.lineWidth-0.5); hold on
        if kk == 1
            legendTxt{kk} = 'Correct';                 % legend text
        else
            legendTxt{kk} = sprintf('Dist %i',allDist(kk-1));                 % legend text
        end
    end;
    % Adding session and array
    legPlots(end+1) = plot(0,0,'k','LineWidth',plotInfo.lineWidth-0.5);legendTxt{end+1} = sprintf('%s-%s',ErrorInfo.session,char(arrayLoc{iArray})); %#ok<AGROW>
    legend(legPlots,legendTxt,'location','Best','FontSize',plotInfo.axisFontSz+3,'FontWeight','Bold')                                            % Include legend
    set(legend,'position',[0.47 0.47 0.1 0.1])                              % position normalized
    axis off
    
    clear legendTxt hPlot
    % Saving plots
    if plotInfo.savePlot
        disp('Should be called meanArray!!!')
        saveFilename = sprintf('%s-corrIncorr-6TgtMeanArray-dist2tgt-%s%s%s.png',infoStr.strPrefix,...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig(iArray),saveFilename)
    end
end
clear hPlot hFig legPlots

%% Plot dist2Tgt regardless of target location
% Mean and st.dev. of correct trials
meanCorr = nanmean(corrEpochs,2);
stdCorr = nanstd(corrEpochs,[],2);

minV = -60;%nanmin(reshape(meanDist2Tgt - stdDist2Tgt,[prod(size(meanDist2Tgt)) 1])); %#ok<*PSIZE>
maxV = 60;%nanmax(reshape(meanDist2Tgt + stdDist2Tgt,[prod(size(meanDist2Tgt)) 1]));

for iArray = 1:length(arrayLoc)
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
        'name',sprintf('%s mean dist2Tgt for %s',ErrorInfo.session,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        
        % Zero line
        plot([0 0],[minV maxV],'--k','linewidth',plotInfo.lineWidth-2), hold on
        % Plot mean epochs per channel for correct trials
        plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
        plotErrorBars(timeVector,meanCorr(iCh,:),meanCorr(iCh,:)-stdCorr(iCh,:),meanCorr(iCh,:)+stdCorr(iCh,:),plotInfo);               % Blue for correct epochs
        
        % Dist2Tgt
        for iDist = 1:3
            plotInfo.plotColors(1,:) = plotInfo.distColors(1+iDist,:);
            plotErrorBars(timeVector,squeeze(meanDist2Tgt(iDist,iCh,:))',squeeze(meanDist2Tgt(iDist,iCh,:))' - squeeze(stdDist2Tgt(iDist,iCh,:))',squeeze(meanDist2Tgt(iDist,iCh,:))' + squeeze(stdDist2Tgt(iDist,iCh,:))',plotInfo);
        end
        axis tight
    end
    
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    % legend
	legendTxt{1} = 'Correct';                                           % legend for correct trials
    for iDist = 1:3, legendTxt{1+iDist} = sprintf('Dist %i',iDist);end
    legendTxt{5} = sprintf('%s-%s',ErrorInfo.session,char(arrayLoc(iArray)));
    
    legPlots = nan(length(distVals)+2,1);
    for kk = 1:length(distVals)+2, legPlots(kk) = plot(0,'Color',plotInfo.distColors(kk,:),'LineWidth',plotInfo.lineWidth-0.5); hold on, end;    % plot fake data to polace legends
    legend(legPlots,legendTxt,0,'FontSize',plotInfo.axisFontSz+1,'FontWeight','Bold')                                            % Include legend
    axis off
    
    % Save plot
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochTgt-%s-dist2tgt%s%s.png',infoStr.strPrefix,...
            arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
    clear hFig hPlot legendTxt legPlots
end

%% Plot dist2Tgt for each channel, alone
% Mean and st.dev. of correct trials
meanCorr = nanmean(corrEpochs,2);
stdCorr = nanstd(corrEpochs,[],2);

% Plot separatedly for each channel
for ii = 1:length(ErrorInfo.chList)
    iCh = ErrorInfo.chList(ii);
    
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s mean dist2Tgt for %s',ErrorInfo.session,arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    % Zero line
    plot([0 0],[minV maxV],'--k','linewidth',plotInfo.lineWidth-2), hold on
    % Plot mean epochs per channel for correct trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
    hCorr = plotErrorBars(timeVector,meanCorr(iCh,:),meanCorr(iCh,:)-stdCorr(iCh,:),meanCorr(iCh,:)+stdCorr(iCh,:),plotInfo);               % Blue for correct epochs
    
    % legend
    legendTxt{1} = 'Correct';                                           % legend for correct trials
    % Dist2Tgt
    for iDist = 1:3
        plotInfo.plotColors(1,:) = plotInfo.distColors(1+iDist,:);
        hDist(iDist) = plotErrorBars(timeVector,squeeze(meanDist2Tgt(iDist,iCh,:))',squeeze(meanDist2Tgt(iDist,iCh,:))' - squeeze(stdDist2Tgt(iDist,iCh,:))',squeeze(meanDist2Tgt(iDist,iCh,:))' + squeeze(stdDist2Tgt(iDist,iCh,:))',plotInfo);
        legendTxt{1+iDist} = sprintf('Dist %i',iDist);
    end
    % legend
    hSubject = plot(0,0,'k','linewidth',plotInfo.lineWidth); legendTxt{5} = sprintf('%s-Ch%i',ErrorInfo.session,iCh); 
    legend([hCorr.H [hDist(:).H] hSubject],legendTxt,0,'FontSize',plotInfo.axisFontSz+5,'FontWeight','Bold')                                            % Include legend
    axis tight
    
    % Labels
    set(gca,'FontSize',plotInfo.axisFontSz+2)
    xlabel('Time from reward stimulus onset [s]','FontSize',plotInfo.axisFontSz+8,'FontWeight',plotInfo.axisFontWeight)
    ylabel('Signal voltage [uV]','FontSize',plotInfo.axisFontSz+8,'FontWeight',plotInfo.axisFontWeight)
    axis tight;
    title(sprintf('Ch%i',iCh),'FontSize',plotInfo.titleFontSz+5,'FontWeight',plotInfo.titleFontWeight)    

    % Save plot
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpoch-ch%i-dist2tgt%s%s.png',infoStr.strPrefix,...
            iCh,infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
    end
    clear hFig hPlot legendTxt legPlots
end
    

%% Plot 

end         % function end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getSubPlot(iTgt,plotInfo)
% function getSubPlot(iTgt,plotInfo)
%
% Selects the subplot based on the target number (iTgt)
%
% Andres v1.0

tgtLoc = plotInfo.TgtPlot.subplot{iTgt};
plotLoc = [tgtLoc,tgtLoc + plotInfo.TgtPlot.colms,tgtLoc + 2*plotInfo.TgtPlot.colms,tgtLoc + 3*plotInfo.TgtPlot.colms];
subplot(plotInfo.TgtPlot.rows,plotInfo.TgtPlot.colms,plotLoc); hold on,

end
