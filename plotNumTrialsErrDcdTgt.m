function plotNumTrialsErrDcdTgt(tgtErrRPs,tgt2DistEpochs,ErrorInfo)
%
%
%
%
% Author:   Andres 
%
% Andres    : v1.0  : init. Created 30 Oct 2014


%% Basic params and vbles
plotInfo = ErrorInfo.plotInfo;
nTgts = ErrorInfo.epochInfo.nTgts;

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(ErrorInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Plotting number of incorrect targetd per location %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot normalized by total number incorrect targets 
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[360   280   844   642],...
    'name',sprintf('%s Incorrectly Decoded Target Count',ErrorInfo.session),...
    'NumberTitle','off','Visible',plotInfo.visible);

hPlot = zeros(nTgts,1);
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    %hPlot(iTgt) = plot(1:3,tgt2DistEpochs(iTgt).normNumEpochsPerDist,'*','color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth+3);
    hPlot(iTgt) = plot(1:3,tgt2DistEpochs(iTgt).normNumEpochsPerDist,'color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth+3);
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend(hPlot,legTxt,'location','Best','FontSize',plotInfo.axisFontSz+5,'FontWeight',plotInfo.axisFontWeight)
set(gca,'FontSize',plotInfo.axisFontSz+5)
xlabel('Dist. to True Tgt of Incorrectly Decoded Targets ','FontSize',plotInfo.axisFontSz+5,'FontWeight',plotInfo.axisFontWeight)
ylabel('Normalized Number of Targets','FontSize',plotInfo.axisFontSz+6,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Normalized number incorr. dcd trials at given dist. to correct target',ErrorInfo.session),'FontSize',plotInfo.titleFontSz+3,'FontWeight',plotInfo.titleFontWeight)
axis tight

if plotInfo.savePlot
    saveFilename = sprintf('%s-normalizedNumTrialsPerTgtLoc-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        infoStr.strgRef,infoStr.noisyEpochStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot 
% Incorrectly Decoded Target Count 

hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1312          15        1226         913],...
    'name',sprintf('%s Incorrectly Decoded Target Count',ErrorInfo.session),...
    'NumberTitle','off','Visible',plotInfo.visible);

% Regular count
subplot(2,2,1)
dist2tgt = [0 1 2 3 2 1];                               % distance of decoded target to true target location (for Tgt 1) in the ith column of dist2tgt.
hPlot = zeros(nTgts,1);
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    %plot([1:6],reshape([tgtErrRPs(:).nIncorrDcdTgts],[6 6]))
    %iTgtDist2tgt = circshift(dist2tgt,[0 iTgt-1]);      % get dist2Tgt for each expected target location 
    hPlot(iTgt) = plot(1:nTgts,tgtErrRPs(iTgt).nIncorrDcdTgts,'color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth);
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend(hPlot,legTxt,'location','Best')
xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
ylabel('Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Number Trials Incorrectly Decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight

% Normalized count
subplot(2,2,3)
hPlot = zeros(nTgts,1);
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    hPlot(iTgt) = plot(1:nTgts,tgtErrRPs(iTgt).normIncorrDcdTgts,'color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth);
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend(hPlot,legTxt,'location','Best')
xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
ylabel('Normalized Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Normalized Number Trials Incorrectly Decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight

% Distance to target
% Number of trials
subplot(2,2,2)
hPlot = zeros(nTgts,1);
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    hPlot(iTgt) = plot(1:3,tgt2DistEpochs(iTgt).numEpochsPerDist,'color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth);
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend(hPlot,legTxt,'location','Best')
xlabel('Dist. to True Tgt of Incorrectly Decoded Targets ','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
ylabel('Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Number incorr. dcd trials at given dist. 2 correct target',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight

% Normalized number of trials
subplot(2,2,4)
hPlot = zeros(nTgts,1);
legTxt = cell(nTgts,1);
for iTgt  = 1:nTgts
    hPlot(iTgt) = plot(1:3,tgt2DistEpochs(iTgt).normNumEpochsPerDist,'color',plotInfo.colorTgt(iTgt,:),'lineWidth',plotInfo.lineWidth);
    hold on
    legTxt{iTgt} = sprintf('Tgt%i',iTgt);
end
legend(hPlot,legTxt,'location','Best')
xlabel('Dist. to True Tgt of Incorrectly Decoded Targets ','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
ylabel('Normalized Number of Targets','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
title(sprintf('%s Normalized number incorr. dcd trials at given dist. 2 correct target',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
axis tight

if plotInfo.savePlot
    saveFilename = sprintf('%s-nTrialsPerTgtLoc-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        infoStr.strgRef,infoStr.noisyEpochStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end

%% This needs to be checked!!!
% %% Plotting laterality analysis
% warning('A partir de aqui no esta revisado') %#ok<*WNTAG>
% warning('From here on not tested. Problems is subplot(3,1,3). sum does not make senes, not equal to all!!')
% disp('From here on not tested. Problems is subplot(3,1,3). sum does not make senes, not equal to all!!')
% 
% % (ErrorInfo.signalProcess.ipsiIndx) = sum([tgtErrRPs(ErrorInfo.signalProcess.ipsilatTgts).nIncorrDcdTgts]);
% % (ErrorInfo.signalProcess.contraIndx) = sum([tgtErrRPs(ErrorInfo.signalProcess.contralatTgts).nIncorrDcdTgts]);
% 
% % 6x6 matrix with number of expected and decoded targets
% normNumTrialsPerDcdTgt = reshape([tgtErrRPs(:).normIncorrDcdTgts],[6 6])';
% 
% %% Laterality analysis
% for iTgt = 1:nTgts
%     % Sum dcdTgt per laterality
%     normNumIncorrDcdTrialsLat(iTgt,ErrorInfo.signalProcess.ipsiIndx) = sum(normNumTrialsPerDcdTgt(iTgt,ErrorInfo.signalProcess.ipsilatTgts));
%     normNumIncorrDcdTrialsLat(iTgt,ErrorInfo.signalProcess.contraIndx) = sum(normNumTrialsPerDcdTgt(iTgt,ErrorInfo.signalProcess.contralatTgts));
%     
%     % Sum expTgt per laterality
%     normNumIncorrExpTrialsLat(ErrorInfo.signalProcess.ipsiIndx,iTgt) = sum(normNumTrialsPerDcdTgt(ErrorInfo.signalProcess.ipsilatTgts,iTgt));
%     normNumIncorrExpTrialsLat(ErrorInfo.signalProcess.contraIndx,iTgt) = sum(normNumTrialsPerDcdTgt(ErrorInfo.signalProcess.contralatTgts,iTgt));
% end
% 
% hFig = figure;
% set(hFig,'PaperPositionMode','auto','Position',[1644          20         560         912],...
%     'name',sprintf('%s Number Incorrectly Decoded Target',ErrorInfo.session),...
%     'NumberTitle','off','Visible',plotInfo.visible);
% 
% % All targets
% subplot(3,1,1)
% imagesc(normNumTrialsPerDcdTgt)
% colorbar
% set(gca,'Ydir','normal')
% xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% ylabel('True Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% title(sprintf('%s normalized number of trials incorrectly decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
% axis tight
% 
% % Adding Laterality of Dcd trials
% subplot(3,1,2)
% imagesc(normNumIncorrDcdTrialsLat)
% colorbar
% set(gca,'Ydir','normal')
% xlabel('Sum normalized number trials dcdTgt per laterality','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% ylabel('True Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% title(sprintf('%s normalized number of trials incorrectly decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
% axis tight
% 
% % Adding laterality of true target
% subplot(3,1,3)
% imagesc(normNumIncorrExpTrialsLat)
% colorbar
% set(gca,'Ydir','normal')
% xlabel('Incorrectly Decoded Target Location','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% ylabel('Sum normalized number trials expTgt per laterality','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
% title(sprintf('%s normalized number of trials incorrectly decoded',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-1,'FontWeight',plotInfo.titleFontWeight)
% axis tight
% 
end
