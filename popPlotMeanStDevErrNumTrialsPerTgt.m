function popPlotMeanStDevErrNumTrialsPerTgt(sessionList,popNumTrialsPerDist2Tgt,ErrorInfo)
%
% 
%
%
% INPUT
% popNumTrialsPerTgt   %[numSessions x trueTgt x dcdTgt] 
% popNumTrialsPerDist2Tgt %[numSessions x trueTgt x dis2Tgt] 
%
%
% Author:   Andres 
%
% Andres    : v1.0  : init. Created 31 Oct 2014

popSession = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));

%% Basic params and vbles
plotInfo = ErrorInfo.plotInfo;
nTgts = ErrorInfo.epochInfo.nTgts;

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(ErrorInfo);

% Get Normalized values
% popNormNumTrialsPerTgt = nan(size(popNumTrialsPerTgt));
popNormNumTrialsPerDist2Tgt = nan(size(popNumTrialsPerDist2Tgt));
for iSess = 1:length(sessionList)
%     popNormNumTrialsPerTgt(iSess,:) = popNumTrialsPerTgt(iSess,:)/sum(popNumTrialsPerTgt(iSess,:));
    for iTgt = 1:nTgts
        popNormNumTrialsPerDist2Tgt(iSess,iTgt,:) = popNumTrialsPerDist2Tgt(iSess,iTgt,:)/sum(popNumTrialsPerDist2Tgt(iSess,iTgt,:));
    end
end

%% Get mean and st.dev.
%sessionList 
% popMeanNumTrialsPerTgt = squeeze(nanmean(popNumTrialsPerTgt,1));                %[trueTgt x dcdTgt] 
% popStDevNumTrialsPerTgt = squeeze(nanstd(popNumTrialsPerTgt,[],1));             %[trueTgt x dcdTgt] 
popMeanNumTrialsPerDist2Tgt = squeeze(nanmean(popNumTrialsPerDist2Tgt,1));      %[trueTgt x dis2Tgt] 
popStDevNumTrialsPerDist2Tgt = squeeze(nanstd(popNumTrialsPerDist2Tgt,[],1));   %[trueTgt x dis2Tgt] 

%Normalized
% popNormMeanNumTrialsPerTgt = squeeze(nanmean(popNormNumTrialsPerTgt,1));                %[trueTgt x dcdTgt] 
% popNormStDevNumTrialsPerTgt = squeeze(nanstd(popNormNumTrialsPerTgt,[],1));             %[trueTgt x dcdTgt] 
popNormMeanNumTrialsPerDist2Tgt = squeeze(nanmean(popNormNumTrialsPerDist2Tgt,1));      %[trueTgt x dis2Tgt] 
popNormStDevNumTrialsPerDist2Tgt = squeeze(nanstd(popNormNumTrialsPerDist2Tgt,[],1));   %[trueTgt x dis2Tgt] 

%% Plotting pop
% Incorrectly Decoded Target Count 
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[ 1312          15         649         913],...
    'name',sprintf('%s Incorrectly Decoded Target Count',popSession),...
    'NumberTitle','off','Visible',plotInfo.visible);

% % Regular count
% subplot(2,2,1)
% legTxt = cell(nTgts,1);
% for iTgt  = 1:nTgts
%     plotInfo.plotColors(1,:) = plotInfo.colorTgt(iTgt,:);
%     hPlot(iTgt) = plotErrorBars(1:nTgts,popMeanNumTrialsPerTgt(iTgt,:),...
%         popMeanNumTrialsPerTgt(iTgt,:) - popStDevNumTrialsPerTgt(iTgt,:),...
%         popMeanNumTrialsPerTgt(iTgt,:) + popStDevNumTrialsPerTgt(iTgt,:),plotInfo); %#ok<AGROW>
%     hold on
%     legTxt{iTgt} = sprintf('Tgt%i',iTgt);
% end
% legend([hPlot(:).H],legTxt,'location','Best')
% xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% ylabel('Population Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% title(sprintf('%s Population Number Trials Incorrectly Decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
% axis tight, clear hPlot
% 
% % Normalized count
% subplot(2,2,3)
% legTxt = cell(nTgts,1);
% for iTgt  = 1:nTgts
%     plotInfo.plotColors(1,:) = plotInfo.colorTgt(iTgt,:);
%     hPlot(iTgt) = plotErrorBars(1:nTgts,popNormMeanNumTrialsPerTgt(iTgt,:),...
%         popNormMeanNumTrialsPerTgt(iTgt,:) - popNormStDevNumTrialsPerTgt(iTgt,:),...
%         popNormMeanNumTrialsPerTgt(iTgt,:) + popNormStDevNumTrialsPerTgt(iTgt,:),plotInfo);
%     hold on
%     legTxt{iTgt} = sprintf('Tgt%i',iTgt);
% end
% legend([hPlot(:).H],legTxt,'location','Best','FontSize',plotInfo.axisFontSz)
% xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% ylabel('Population Normalized Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% title(sprintf('%i Sessions Population Normalized Number Trials Incorrectly Decoded',length(sessionList)),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
% axis tight, clear hPlot

% Distance to target
subplot(2,1,1)
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    plotInfo.plotColors(1,:) = plotInfo.colorTgt(iTgt,:);
    hPlot(iTgt) = plotErrorBars(1:3,popMeanNumTrialsPerDist2Tgt(iTgt,:),...
        popMeanNumTrialsPerDist2Tgt(iTgt,:) - popStDevNumTrialsPerDist2Tgt(iTgt,:),...
        popMeanNumTrialsPerDist2Tgt(iTgt,:) + popStDevNumTrialsPerDist2Tgt(iTgt,:),plotInfo); %#ok<AGROW>
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend([hPlot(:).H],legTxt,'location','northeast','FontSize',plotInfo.axisFontSz+3)
xlabel('Dist. to True Tgt of Incorrectly Decoded Targets ','FontSize',plotInfo.axisFontSz+3,'FontWeight',plotInfo.axisFontWeight)
ylabel('Population Mean Number Trials','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s number incorr. dcd trials at dist. 2 corr. trgt',popSession),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight, clear hPlot

% Removing legend box
legend boxoff

% Normalized number of trials
subplot(2,1,2)
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    plotInfo.plotColors(1,:) = plotInfo.colorTgt(iTgt,:);
    hPlot(iTgt) = plotErrorBars(1:3,popNormMeanNumTrialsPerDist2Tgt(iTgt,:),...
        popNormMeanNumTrialsPerDist2Tgt(iTgt,:) - popNormStDevNumTrialsPerDist2Tgt(iTgt,:),...
        popNormMeanNumTrialsPerDist2Tgt(iTgt,:) + popNormStDevNumTrialsPerDist2Tgt(iTgt,:),plotInfo); %#ok<AGROW>
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend([hPlot(:).H],legTxt,'location','northeast','FontSize',plotInfo.axisFontSz+3)
xlabel('Dist. to True Tgt of Incorrectly Decoded Targets ','FontSize',plotInfo.axisFontSz+3,'FontWeight',plotInfo.axisFontWeight)
ylabel('Pop. Normalized Mean Number of Trials','FontSize',plotInfo.axisFontSz+4,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Norm. number incorr. dcd trials at dist. 2 corr. trgt',popSession),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight, clear hPlot

% Removing legend box
legend boxoff

if plotInfo.savePlot
    saveFilename = sprintf('%s-meanErrorBarNumTrialsPerTgtLoc-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',popSession),...
        infoStr.strgRef,infoStr.noisyEpochStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end
