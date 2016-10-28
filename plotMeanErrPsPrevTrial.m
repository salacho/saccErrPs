function plotMeanErrPsPrevTrial(corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo)
%
% function plotMeanErrPsPrevTrial(corrEpochsCorrPrev,corrEpochsErrPrev,incorrEpochsCorrPrev,incorrEpochsErrPrev,ErrorInfo)
% 
% Plots all mean epochs for both correct and incorrect outcomes, channels and arrays.
%
% INPUT
%
% Author : Andres.
% 
% Andres :  v1.0    : init. 23 Oct 2014
% Andres :  v.1.1   : 03 Nov 2014

tStart = tic;

%% Params
% Getting plot params
plotInfo = ErrorInfo.plotInfo;
timeVector = (-ErrorInfo.epochInfo.preOutcomeTime/1000 + 1/ErrorInfo.epochInfo.Fs:1/ErrorInfo.epochInfo.Fs:ErrorInfo.epochInfo.preOutcomeTime/1000);            % x values for error bar lot

%% Mean values
% Get trials mean and std or standard error values 
tempFlag = ErrorInfo.epochInfo.getMeanArrayEpoch;
ErrorInfo.epochInfo.getMeanArrayEpoch = true;
% Previous trials was correct
[corrMeanCorrPrev,incorrMeanCorrPrev,corrSampErrCorrPrev,incorrSampErrCorrPrev,...
    corrMeanCorrPrevArray,incorrMeanCorrPrevArray,corrStCorrPrevArray,incorrStCorrPrevArray] = ...
    getMeanTrialsErrPs(corrEpochsCorrPrev,incorrEpochsCorrPrev,ErrorInfo);
% Previous trials was incorrect
[corrMeanErrPrev,incorrMeanErrPrev,corrSampErrErrPrev,incorrSampErrErrPrev,...
    corrMeanErrPrevArray,incorrMeanErrPrevArray,corrStErrPrevArray,incorrStErrPrevArray] = ...
    getMeanTrialsErrPs(corrEpochsErrPrev,incorrEpochsErrPrev,ErrorInfo);
ErrorInfo.epochInfo.getMeanArrayEpoch = tempFlag;

%% Naming vbles
infoStr = getInfoStr(ErrorInfo);

%% Each channel independently
for ii = 1:length(ErrorInfo.chList)
    iCh = ErrorInfo.chList(ii);
    fprintf('Plotting meanCorrIncorr prevOutcome for ch%i...\n',iCh);
    hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1514 235 830 605],...
        'name',sprintf('%s mean Corr and Incorr epochs %s- based on previous trial outcome Ch%i. %s',ErrorInfo.session,infoStr.stdTxt,iCh,infoStr.yLimTxt),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    % Corr for prev. Correct trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
    [plotErrCorr] = plotErrorBars(timeVector,corrMeanCorrPrev(iCh,:),...
        corrMeanCorrPrev(iCh,:) - corrSampErrCorrPrev(iCh,:),...
        corrMeanCorrPrev(iCh,:) + corrSampErrCorrPrev(iCh,:),plotInfo);     % green for correct after correct
    hLeg(1) = plotErrCorr.H;
    
    % Corr for prev. incorrect trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(2,:);
    [plotErrCorr] = plotErrorBars(timeVector,corrMeanErrPrev(iCh,:),...
        corrMeanErrPrev(iCh,:) - corrSampErrErrPrev(iCh,:),...
        corrMeanErrPrev(iCh,:) + corrSampErrErrPrev(iCh,:),plotInfo);     % lime for correct after wrong
    hLeg(2) = plotErrCorr.H;
    
    % Incorr for prev. Correct trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(3,:);
    [plotErrCorr] = plotErrorBars(timeVector,incorrMeanCorrPrev(iCh,:),...
        incorrMeanCorrPrev(iCh,:) - incorrSampErrCorrPrev(iCh,:),...
        incorrMeanCorrPrev(iCh,:) + incorrSampErrCorrPrev(iCh,:),plotInfo);     % green for correct after correct
    hLeg(3) = plotErrCorr.H;
    
    % Incorr for prev. incorrect trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(4,:);
    [plotErrCorr] = plotErrorBars(timeVector,incorrMeanErrPrev(iCh,:),...
        incorrMeanErrPrev(iCh,:) - incorrSampErrErrPrev(iCh,:),...
        incorrMeanErrPrev(iCh,:) + incorrSampErrErrPrev(iCh,:),plotInfo);     % lime for correct after wrong
    hLeg(4) = plotErrCorr.H;
    
    % Axes, title, labels properties, etc
    axis tight
    xlabel('Time to feddback onset [sec]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    ylabel('uV','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    title(sprintf('ch%i mean Corr and Incorr epochs %s- based on previous trial outcome',iCh,infoStr.stdTxt),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    legend(hLeg,{'meanCorrWithPrevCorr','meanCorrWithPrevIncorr','meanIncorrWithPrevCorr','meanIncorrWithPrevIncorr'})
    
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochPrevOutcome-ch%i%s%s.png',infoStr.strPrefix,...
            iCh,infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig,saveFilename)
        close(hFig)
    end
end


%% Plot averaged signals for each channels and array
hFig = 1:plotInfo.nArrays;
plotInfo.lineWidth = plotInfo.lineWidth - 2;

for iArray = 1:plotInfo.nArrays
    fprintf('Plotting meanCorrIncorr prevOutcome for array %s...\n',plotInfo.arrayLoc{iArray});
    
    hFig(iArray) = figure;
    set(hFig(iArray),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s Correct-Incorrect mean epochs prevOutcome-dependent for %s array %s',ErrorInfo.session,plotInfo.arrayLoc{iArray},infoStr.yLimTxt),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    for ii = 1:size(plotInfo.arrayChs,2)
        % Channel location and subplot
        iCh = plotInfo.arrayChs(iArray,ii);
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        % Plot
        % Corr for prev. Correct trials
        plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
        [plotErrCorr] = plotErrorBars(timeVector,corrMeanCorrPrev(iCh,:),...
            corrMeanCorrPrev(iCh,:) - corrSampErrCorrPrev(iCh,:),...
            corrMeanCorrPrev(iCh,:) + corrSampErrCorrPrev(iCh,:),plotInfo);     % green for correct after correct
        
        % Corr for prev. incorrect trials
        plotInfo.plotColors(1,:) = plotInfo.distColors(2,:);
        [plotErrCorr] = plotErrorBars(timeVector,corrMeanErrPrev(iCh,:),...
            corrMeanErrPrev(iCh,:) - corrSampErrErrPrev(iCh,:),...
            corrMeanErrPrev(iCh,:) + corrSampErrErrPrev(iCh,:),plotInfo);     % lime for correct after wrong
        
        % Incorr for prev. Correct trials
        plotInfo.plotColors(1,:) = plotInfo.distColors(3,:);
        [plotErrCorr] = plotErrorBars(timeVector,incorrMeanCorrPrev(iCh,:),...
            incorrMeanCorrPrev(iCh,:) - incorrSampErrCorrPrev(iCh,:),...
            incorrMeanCorrPrev(iCh,:) + incorrSampErrCorrPrev(iCh,:),plotInfo);     % green for correct after correct
        
        % Incorr for prev. incorrect trials
        plotInfo.plotColors(1,:) = plotInfo.distColors(4,:);
        [plotErrCorr] = plotErrorBars(timeVector,incorrMeanErrPrev(iCh,:),...
            incorrMeanErrPrev(iCh,:) - incorrSampErrErrPrev(iCh,:),...
            incorrMeanErrPrev(iCh,:) + incorrSampErrErrPrev(iCh,:),plotInfo);     % lime for correct after wrong
        axis tight
    end
    
    % Legend
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    hLeg = nan(5,1);
    for kk = 1:5, hLeg(kk) = plot(0,'Color',plotInfo.distColors(kk,:),'lineWidth',plotInfo.lineWidth); hold on, end;    % plot fake data to polace legends
    legend(hLeg,{'meanCorrWithPrevCorr','meanCorrWithPrevIncorr','meanIncorrWithPrevCorr','meanIncorrWithPrevIncorr',char(plotInfo.arrayLoc(iArray))})
    axis off                                                                % remove axis and background
    
    % Saving figures
    if plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanErrorBarChPrevOutcome-%s%s%s.png',infoStr.strPrefix,...
            plotInfo.arrayLoc{iArray},infoStr.signProcStr,infoStr.strSuffix);
        saveas(hFig(iArray),saveFilename)
    end
end
plotInfo.lineWidth = plotInfo.lineWidth + 2;
clear hFig hPlot legPlots

%% mean of array channels for corr-incorr and prevTrial dependance
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[57 164 2417 605],...
    'name',sprintf('%s Mean array channels Correct-Incorrect mean epochs prevOutcome-dependent %s',ErrorInfo.session,infoStr.yLimTxt),...
    'NumberTitle','off','Visible',plotInfo.visible);
hLeg = nan(4,1);

for iArray = 1:plotInfo.nArrays
    fprintf('Plotting meanCorrIncorr prevOutcome for array %s...\n',plotInfo.arrayLoc{iArray});
    % Array subplot
    subplot(1,plotInfo.nArrays,iArray)
    
    % Corr for prev. correct trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(1,:);
    [plotErrCorr] = plotErrorBars(timeVector,...
        detrend(corrMeanCorrPrevArray(iArray,:)),detrend(corrMeanCorrPrevArray(iArray,:) + corrStCorrPrevArray(iArray,:)),...
        detrend(corrMeanCorrPrevArray(iArray,:) - corrStCorrPrevArray(iArray,:)),...
        plotInfo);     % green for correct after correct
    hLeg(1) = plotErrCorr.H;
    
    % Corr for prev. incorrect trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(2,:);
    [plotErrCorr] = plotErrorBars(timeVector,...
        detrend(corrMeanErrPrevArray(iArray,:)),detrend(corrMeanErrPrevArray(iArray,:) + corrStErrPrevArray(iArray,:)),...
        detrend(corrMeanErrPrevArray(iArray,:) - corrStErrPrevArray(iArray,:)),...
        plotInfo);     % lime for correct after wrong
    hLeg(2) = plotErrCorr.H;
    
    % Incorr for prev. correct trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(3,:);
    [plotErrCorr] = plotErrorBars(timeVector,...
        detrend(incorrMeanCorrPrevArray(iArray,:)),detrend(incorrMeanCorrPrevArray(iArray,:) + incorrStCorrPrevArray(iArray,:)),...
        detrend(incorrMeanCorrPrevArray(iArray,:) - incorrStCorrPrevArray(iArray,:)),...
        plotInfo);     % orange for incorrect after correct
    hLeg(3) = plotErrCorr.H;
    
    % Incorr for prev., incorrect trials
    plotInfo.plotColors(1,:) = plotInfo.distColors(4,:);
    [plotErrCorr] = plotErrorBars(timeVector,...
        detrend(incorrMeanErrPrevArray(iArray,:)),detrend(incorrMeanErrPrevArray(iArray,:) + incorrStErrPrevArray(iArray,:)),...
        detrend(incorrMeanErrPrevArray(iArray,:) - incorrStErrPrevArray(iArray,:)),...
        plotInfo);     % red for incorrect after wrong
    hLeg(4) = plotErrCorr.H;
    
    % Axes, title, labels properties, etc
    axis tight
    xlabel('Time to feddback onset [sec]','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    ylabel('uV','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
    title(sprintf('meanArrayChs %s CorrIncorr epochs & %s prev. trial outcome %s',plotInfo.arrayLoc{iArray},infoStr.stdTxt),'FontSize',plotInfo.titleFontSz,'FontWeight',plotInfo.titleFontWeight)
    legend(hLeg,{'meanCorrWithPrevCorr','meanCorrWithPrevIncorr','meanIncorrWithPrevCorr','meanIncorrWithPrevIncorr'},'location','NorthWest')
end

% Saving figures
if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-meanErrorBarEpochPerArray-PrevOutcome%s%s.png',infoStr.strPrefix,...
            infoStr.signProcStr,infoStr.strSuffix);        
    saveas(hFig,saveFilename)
end

% Time it took to run this code
tElapsed = toc(tStart);
fprintf('Time it took to get equal Y limits was %0.2f seconds\n',tElapsed);
