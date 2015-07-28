function popPlotDcdResults(popDcdResults,saveErrorInfo)
% function popPlotDcdResults(popDcdResults,saveErrorInfo)
%
% Plot population decoder error detection performance 
%
%
%
% Andres v.1 November 26th 2013
% Last modified Nov. 2013

dirs = initErrDirs;
ErrorInfo = saveErrorInfo;

% Plotting params
plotParams.nXtick = 6;
plotParams.axisFontSize = 14;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 17;
plotParams.titleFontWeight = 'Bold';
%plotParams.Colors = [0 0.2 1; 1 0 0.2; 0.2 1 0];      % Colors 
plotParams.Colors = [0 0 0; 1 0 0.2; 0.2 1 0];      % Colors 
plotParams.lineWidth = 7;
plotParams.lineStyle = '-';
plotParams.fontSz = 18;
saveErrorInfo.plotInfo.plotErrorBars = 0;

% Axis values
kk = 0;
nSessions = length(popDcdResults.sessions);
iDown = 1;
XtickPos = 1:iDown:nSessions;
for iSess = 1:iDown:nSessions
    kk = kk + 1;
    session = popDcdResults.sessions{iSess};
    XtickLabels{kk} = session(5:end);
end
xVals = 1:nSessions;

%%%% OJO!!!! 
%% Standard Deviation (for this STD not good idea since SD cannot pass 1. Need confidence intervals bootstrap!! or bernoulli CI using means performance as prob. values)
for kk = 1:nSessions
    stdOverall(kk)   = std(popDcdResults.decoder{kk}.performance.overallDcd);
    stdErr(kk)       = std(popDcdResults.decoder{kk}.performance.errorDcd);
    stdCorr(kk)      = std(popDcdResults.decoder{kk}.performance.corrDcd);
end

%% Plot error bars
if saveErrorInfo.plotInfo.plotErrorBars
    hFig = figure; hold on, set(hFig,'PaperPositionMode','auto','Position',[20 345 1232 525])
    plotParams.plotColors(1,:) = plotParams.Colors(1,:);
    [plotOverall]   = plotErrorBars(xVals,popDcdResults.OverallDcd,popDcdResults.OverallDcd - stdOverall,popDcdResults.OverallDcd + stdOverall,plotParams);               % Blue for correct epochs
    plotParams.plotColors(1,:) = plotParams.Colors(2,:);
    [plotCorr]   = plotErrorBars(xVals,popDcdResults.ErrorDcd,popDcdResults.ErrorDcd - stdErr,popDcdResults.ErrorDcd + stdErr,plotParams);               % Blue for correct epochs
    plotParams.plotColors(1,:) = plotParams.Colors(3,:);
    [plotErr]   = plotErrorBars(xVals,popDcdResults.CorrDcd,popDcdResults.CorrDcd - stdCorr,popDcdResults.CorrDcd + stdCorr,plotParams);               % Blue for correct epochs
    % hFig = figure; hold on,
    % plot(xVals,popDcdResults.OverallDcd,'color', plotParams.Colors(1,:));             % Blue for overall
    % plot(xVals,popDcdResults.ErrorDcd,'color', plotParams.Colors(2,:));               % Red for Error
    % plot(xVals,popDcdResults.CorrDcd,'color', plotParams.Colors(3,:));                % Green for Correct
else
    hFig = figure; hold on, set(hFig,'PaperPositionMode','auto','Position',[1414 278 1005 525]);
    plotParams.plotColors(1,:) = plotParams.Colors(1,:);
    [plotOverall.H]   = plot(xVals,popDcdResults.OverallDcd,'Color',plotParams.plotColors(1,:),'LineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle);               % Blue for correct epochs
    plotParams.plotColors(1,:) = plotParams.Colors(2,:);
    [plotCorr.H]   = plot(xVals,popDcdResults.ErrorDcd,'Color',plotParams.plotColors(1,:),'LineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle);               % Blue for correct epochs
    plotParams.plotColors(1,:) = plotParams.Colors(3,:);
    [plotErr.H]   = plot(xVals,popDcdResults.CorrDcd,'Color',plotParams.plotColors(1,:),'LineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle);               % Blue for correct epochs
end

% Text
if strcmpi(popDcdResults.decoder{1}.typeVal,'crossval')
   crossValPerc = popDcdResults.decoder{1}.crossValPerc;
else
    crossValPerc = 0;
end
% Arrays
strArray = '';
for iArray = 1:length(popDcdResults.decoder{1}.arrays)
    strArray = [strArray,'. ',popDcdResults.decoder{1}.arrays{iArray}];
end

% Loading old decoder info, if necesary
if popDcdResults.decoder{1}.loadDecoder
    oldDcd = ['-',popDcdResults.decoder{1}.oldSession];
else oldDcd = '';
end

%titleName = sprintf('Error Detection Performance %s Val:%s%i. nIter:%i%s',oldDcd,popDcdResults.decoder{1}.typeVal, crossValPerc, popDcdResults.decoder{1}.nIter,strArray);
titleName = sprintf('%s Error Detection Performance %s Val:%s%i%s',saveErrorInfo.decoder.dcdType,oldDcd,popDcdResults.decoder{1}.typeVal, crossValPerc,strArray);
title(titleName,'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
legend([plotOverall.H,plotCorr.H,plotErr.H],'Overall','Error','Correct','location','southwest')
xlabel('Session','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold','FontSize',plotParams.fontSz)
ylabel('Performance','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold','FontSize',plotParams.fontSz)

% Plot properties
axis tight;
set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels,'FontSize',plotParams.fontSz) %,'FontWeight',plotParams.axisFontWeight)

% Save Figure
saveErrorInfo.session = sprintf('pop%s-%s-%i%s',popDcdResults.sessions{1},popDcdResults.sessions{end},nSessions);
saveFilename = strrep(createFileForm(popDcdResults.decoder{1},saveErrorInfo,'decoder'),'mat','png');                 %#ok<*NASGU>
saveas(hFig,saveFilename)
