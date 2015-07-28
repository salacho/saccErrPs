function popPlotDcdErrPsPrevSessionTrain(ErrorInfos,dcdVals)
% function popPlotDcdErrPsPrevSessionTrain(ErrorInfos,dcdVals,iterParams,sessionList)
%
% Plots the error detection performance for al lthe sessions analyzed 
% (iterated) Also plots the online BCI saccade decoder performance.
%
% INPUT
% ErrorInfos:         cell [numSessions x 1]. with all the ErrorInfo structures for all the
%                     sessions analyzed
% dcdVals:            cell. Contains the correct, error and overal decoder
%                     performance for all the sessions and iterations of the params. 
%     dcdVals{1}:     corrDcd. Decoder performance for all correct epochs 
%     dcdVals{2}:     errorDcd. Decoder performance for all incorrect epochs
%     dcdVals{3}:     overallDcd. Decoder performance for all epochs
%     dcdVals{4}:     cell with the list of sessions used to extract the data in
%                     dcdVals and ErrorInfos 
%     dcdVals{5}:     cell with the list of decoders used to decoder the data from sessionsList 
%     dcdVals{6}:     cell with the name and order of the fields in dcdVals. 
%                     These usually are: {'corrDcd','errorDcd','overallDcd','sessionList','oldDecoders'};
%
% All this data can be found in a file saved with followin naming structure: 
% i.e. 'popCS20120815-CS20130618-65-CS20130617-reg-oldDcd-[600-600ms]-[1.0-10Hz]-dcdPerf-bestParams.mat'
%
% Author    : Andres
%
% andres    : 1.1   : init. 20 March 2014

% warning('Best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf.') %#ok<WNTAG>
% fprintf('Best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf!!!\n') %#ok<WNTAG>

dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
[~,sessionsDcdPerf] = chicoBCIsessions;

%% Dcd values
corrDcd = dcdVals{1};
errDcd  = dcdVals{2};
overDcd = dcdVals{3};
sessionList = dcdVals{4};
oldDecoders = dcdVals{5};
nSessions = size(sessionList,1); %#ok<*NODEF>

%oldDcdTxt = 'predSession';
oldDcdTxt = 'midSession'; if strcmp(oldDcdTxt,'midSession'), midSessions = round(nSessions/2);

%% Plotting best params
% Plot params
plotParams.yRange           = [0.6 1];
plotParams.lineWidth        = 3;
plotParams.axisFontSize     = 14;
plotParams.axisFontWeight   = 'Bold';
plotParams.titleFontSize    = 17;
plotParams.titleFontWeight  = 'Bold';
% plotParams.Colors = [0 0 0; 1 0 0.2; 0.2 1 0];      % black, red, green
% plotParams.fontSz = 11;
% %plotParams.plotType = 'perOutcome'; %'3Dline'; %'perOutcome'; '3Dbar'; 
plotParams.plotColors(1,:)  = [26 150 65]/255;       % green
plotParams.plotColors(2,:)  = [215 25 28]/255;       % red
plotParams.plotColors(3,:)  = [0 0 0];
plotParams.dcdPerf = 1;
plotParams.saveFig = 1;
plotParams.visible = 0;

% X-axis labels
kk = 0; nSessions = length(sessionList); iDown = 6; 
XtickPos = 1:iDown:nSessions;
XtickLabels = {};
for iSess = 1:iDown:nSessions
    kk = kk + 1;    session = sessionList{iSess};
    XtickLabels{kk} = session(5:end);
end

% Y labels
nYTicks = 8;
YtickPos = round(100*linspace(plotParams.yRange(1),plotParams.yRange(2),nYTicks))/100;
bciYtickPos = round(100*linspace(0,1,nYTicks))/100;
for iYtick = 1:nYTicks
    YtickLabels{iYtick} = num2str(YtickPos(iYtick));
    bciYtickLabels{iYtick} = num2str(bciYtickPos(iYtick));
end

xVals = 1:nSessions;
dcdVbleNames = {'corrDcd','errDcd','overDcd'};
sessionBCIperf = sessionsDcdPerf/100;
hFig = figure; hold on

% Plot error detection and BCI decoder performance
for iVal = 1:3
    % Get the values
    vals2plot(iVal,:) = eval(dcdVbleNames{iVal});
end

if plotParams.dcdPerf && isequal(length(sessionBCIperf),length(sessionList))
    [hAxes,hLine,hVals] = plotyy(xVals,sessionBCIperf,xVals,vals2plot);
    % Color to error detection
    for iVal = 1:3
        set(hVals(iVal),'color',plotParams.plotColors(iVal,:),'lineWidth',plotParams.lineWidth);
    end
    % Color to BCI dcd perf.
    set(hLine,'color','b','lineWidth',plotParams.lineWidth);
    % Legend and Axis
    legendTxt = {'saccBCI','Correct','Incorrect','Overall'};
    % Labels
    xlabel('Sessions [YYMMDD]','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylabel(hAxes(1),'BCI Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold');
    ylabel(hAxes(2),'Error Detection Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold');
    % Axis
	axis(hAxes,'tight')
    set(hAxes,'Xtick',XtickPos,'XtickLabel',XtickLabels)%,'XAxisLocation','Top')
    set(hAxes(1),'FontSize',plotParams.axisFontSize-2,'Ytick',bciYtickPos,'YtickLabel',bciYtickLabels,'box','off')%,'TickDir','out')
    set(hAxes(2),'FontSize',plotParams.axisFontSize-2,'Ytick',YtickPos,'YtickLabel',YtickLabels)
    ylim(hAxes(1),[0 1]);
    ylim(hAxes(2),[plotParams.yRange(1) plotParams.yRange(2)]);
    
else
    for iVal = 1:3
        hAxes(iVal,1) = plot(xVals,vals2plot,'color',plotParams.plotColors(iVal,:),'lineWidth',plotParams.lineWidth);
    end
    warning('Number of sessions with BCI decoder performance do not match!!!');
    legendTxt = {'Correct','Incorrect','Overall'};
    xlabel('Sessions [YYMMDD]','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylabel('Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylim([plotParams.yRange(1) plotParams.yRange(2)]);
    set(gca,'FontSize',plotParams.axisFontSize-2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    axis tight;
end

hLeg = legend(legendTxt,'location','southeast');
set(hFig,'PaperPositionMode','auto','Position',[1297 201 1260 546]);
% Legend fontsize
set(hLeg,'FontSize',plotParams.axisFontSize-2);
% Title
ErrorInfo = ErrorInfos{end};
iterTxt = sprintf('%s: %s-%s-%s-%ibase-%sPredFun-%sPredSelect',oldDcdTxt,ErrorInfo.decoder.dcdType(1:3),...
    char(ErrorInfo.signalProcess.arrays),ErrorInfo.decoder.typeVal,ErrorInfo.signalProcess.baselineDone,ErrorInfo.featSelect.predFunction{1},ErrorInfo.featSelect.predSelectType);
title(iterTxt,'FontWeight',plotParams.axisFontWeight,'FontSize',plotParams.titleFontSize)

%% Saving the file
% Naming the plot
ErrorInfo = ErrorInfos{end}; %#ok<*USENS>
decoder = ErrorInfo.decoder;

switch oldDcdTxt
    case 'predSession'
        % Session for the population
        if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
            ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{end},length(sessionList),'alltest');
        else
            ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
        end
    case 'midSession'
        ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{midSessions+1},sessionList{end},nSessions-midSessions,ErrorInfo.decoder.oldSession);
end

%% Save Filename
if plotParams.saveFig
    switch oldDcdTxt
        case 'predSession', rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 
        case 'midSession',  rootFilename = createFileForm(decoder,ErrorInfo,'popTest');                 
    end
    saveFilename = sprintf('%s-dcdPerf-%s-bestIterParams.png',rootFilename,oldDcdTxt);
    saveas(hFig,saveFilename)
end

end

