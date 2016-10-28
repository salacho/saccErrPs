function plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
% function plotSingleErrRPs(corrEpochs,incorrEpochs,ErrorInfo)
%
% Plots error-related potentials (ErrRPs) of all the epochs per channel in 
% the array layout in the array configuration. Includes the mean and st.
% dev/st.error for each channel. Also plots single channel examples.
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
% Author:   Andres 
%
% Andres    : v1.0  : init. Created 19 July 2013
% Andres    : v2.0  : changed only single trial plots, used to have mean trials plots (which must be in plotMeanErrPs) 29 October 2014

%% Params
plotInfo = ErrorInfo.plotInfo;
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
nArrays = plotInfo.nArrays;

% Get trials mean and st.dev. or standard error values 
[corrMeanTrials,incorrMeanTrials,corrStdTrials,incorrStdTrials,~,~,~,~] = getMeanTrialsErrPs(corrEpochs,incorrEpochs,ErrorInfo);
% Time vector 
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(ErrorInfo);

%% Plot all correct trials and its mean with st.dev. or st. error
dataOutcome = {'corrEpochs','incorrEpochs'};
for iOut = 1:length(dataOutcome)
    
    % Start plots
    for iArray = 1:nArrays
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
            'name',sprintf('%s %s for %s chs',ErrorInfo.session,dataOutcome{iOut},arrayLoc{iArray}),...
            'NumberTitle','off','Visible',plotInfo.visible);
        
        for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            % Verbose
            fprintf('%s-%s-ch%i-subplot%i...\n',dataOutcome{iOut},arrayLoc{iArray},iCh,subCh)
            % Get data to plot
            eval(sprintf('data2plot = squeeze(%s(iCh,:,:));',dataOutcome{iOut}));
            subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
            %% Plot all trials to see trend
            hh = plot(timeVector,data2plot);
            % Axis and legend
            axis tight
            
            %% Add error bars
            hold on
            if iOut == 1
                colorK = 1;
                plotInfo.plotColors(1,:) = plotInfo.colorErrP(colorK,:);
                plotErrorBars(timeVector,corrMeanTrials(iCh,:),corrMeanTrials(iCh,:) - corrStdTrials(iCh,:), corrMeanTrials(iCh,:) + corrStdTrials(iCh,:),plotInfo);
            else
                colorK = 2;
                plotInfo.plotColors(1,:) = plotInfo.colorErrP(colorK,:);
            	plotErrorBars(timeVector,incorrMeanTrials(iCh,:),incorrMeanTrials(iCh,:) - incorrStdTrials(iCh,:), incorrMeanTrials(iCh,:) + incorrStdTrials(iCh,:),plotInfo);
            end
            title(iCh,'FontSize',7)
        end
        
        % legend
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
        legPlots(1,:) = plot(1,1,'k'); hold on
        legPlots(2,:) = plot(1,1,'color',plotInfo.colorErrP(colorK,:));
        legStr = {char(ErrorInfo.session),char(sprintf('%s-%s',dataOutcome{iOut},arrayLoc{iArray}))};
        hLeg = legend(legPlots,legStr,'Location','Best','FontSize',10);
        set(hLeg,'XColor',[1 1 1],'YColor',[1 1 1])
        axis off                                                                % remove axis and background
        
        % Saving figures
        if plotInfo.savePlot
            saveFilename = sprintf('%s-%s-allTrialsMean-%s%s%s.png',infoStr.strPrefix,...
                dataOutcome{iOut},arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
            saveas(hFig,saveFilename)
            close(hFig)
        end

    end
    clear legPlots
end

%% An example of a single channel from each array
dataOutcome = {'corrEpochs','incorrEpochs'};
chList = [12,44,85];
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1312          15        1226         913],...
    'name',sprintf('%s all trials corr-Incorr epochs 3 channels: %i-%i-%i',ErrorInfo.session,chList),...
    'NumberTitle','off','Visible',plotInfo.visible);

for iOut = 1:length(dataOutcome)
    % Start plots
    for iArray = 1:nArrays
        %iCh = chList(iArray);
        subplot(nArrays,2,iArray*2-1 + (iOut-1))
        % Get data to plot
        eval(sprintf('data2plot = squeeze(%s(iCh,:,:));',dataOutcome{iOut}));
        %% Plot all trials to see trend
        plot(timeVector,data2plot)
        line([0 0],[min(min(data2plot)) max(max(data2plot))],'color','k','lineWidth',plotInfo.lineWidth-1,'lineStyle',plotInfo.lineStyle)
        % Axis and legend
        xlabel('Time from feedback onset','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
        ylabel('uVs','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
        title(sprintf('%s-%s-%s-ch%i',ErrorInfo.session,arrayLoc{iArray},dataOutcome{iOut},chList(iArray)),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
        axis tight
    end
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-allTrials3Chs%s%s.png',infoStr.strPrefix,...
        infoStr.signProcStr,infoStr.strSuffix);
    saveas(hFig,saveFilename)
    close(hFig)
end
clear legPlots
end

%% The mean trace for a channel in each array

%% An example of a single channel from each array
chList = [12,44,85];
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1312          15        1226         913],...
    'name',sprintf('%s mean corr-Incorr epochs 3 channels: %i-%i-%i',ErrorInfo.session,chList),...
    'NumberTitle','off','Visible',plotInfo.visible);

data2plot = [-50 30]

% Start plots
for iArray = 1:nArrays
    %iCh = chList(iArray);
    subplot(1,nArrays,iArray)
    hold on
    % Get data to plot
    plot(timeVector,squeeze(corrMeanTrials(chList(iArray),:)),'color',plotInfo.colorErrP(1,:),'lineWidth',plotInfo.lineWidth)         % correct
    plot(timeVector,squeeze(incorrMeanTrials(chList(iArray),:)),'color',plotInfo.colorErrP(2,:),'lineWidth',plotInfo.lineWidth)       % incorrect
    plot(timeVector,squeeze(incorrMeanTrials(chList(iArray),:) - corrMeanTrials(chList(iArray),:)),'color',plotInfo.colorErrP(4,:),'lineWidth',plotInfo.lineWidth)    % errDiff, incorr minus corr
    line([0 0],[min(min(data2plot)) max(max(data2plot))],'color','k','lineWidth',plotInfo.lineWidth-1,'lineStyle',plotInfo.lineStyle,'lineWidth',plotInfo.lineWidth)
    % Axis and legend
    xlabel('Time from feedback onset','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
    ylabel('uVs','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
    title(sprintf('%s-%s-%s-ch%i',ErrorInfo.session,arrayLoc{iArray},'Mean Epochs',chList(iArray)),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
    axis tight
end



