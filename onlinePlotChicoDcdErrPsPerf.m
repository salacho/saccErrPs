function onlinePlotChicoDcdErrPsPerf
%
%
%
%
%
%
%
%
% up to session 20140414

saveFig = 1;

sessionList    = {'CS20140408';'CS20140409';'CS20140410';'CS20140411';'CS20140414'};
saccBCI     = [51.3,78.3,70,73.4,63.4];
errDcd      = [0.95,0.96,0.94,0.93,0.71]*100;
decoderName = {...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';...
    'popCS20140303-CS20140328-12-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat'};

nSessions = length(sessionList);

plotParams.yRange           = [0.6 1];
plotParams.lineWidth        = 2.5;
plotParams.lineStyle        = {'-.',':','-'};
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

% ColorMap params
hFig = figure; plotParams.trainTypeColors = colormap; close(hFig);
% Create colormap for the number of type of trainning and sessions
% plotParams.trainTypeColors = plotParams.trainTypeColors(1:round(size(plotParams.trainTypeColors,1)/length(sessionsType)):size(plotParams.trainTypeColors,1),:);
% plotParams.dcdPerf = 1;
plotParams.saveFig = saveFig;
plotParams.visible = 1;

% X-axis labels
kk = 0; 
XtickPos = 1:nSessions;
XtickLabels = {};
for iSess = 1:nSessions
    kk = kk + 1;    session = sessionList{iSess};
    XtickLabels{kk} = session(1:end);
end

xVals = 1:nSessions;
% dcdVbleNames = {'corrDcd','errDcd','overDcd'};
% sessionBCIperf = sessionsDcdPerf/100;

hSacc = plot(xVals,saccBCI,'color',plotParams.plotColors(1,:),'lineWidth',plotParams.lineWidth);
hold on,
hErr = plot(xVals,errDcd,'color',plotParams.plotColors(2,:),'lineWidth',plotParams.lineWidth);

xlabel('Sessions [YYMMDD]','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
ylabel('Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold');
set(gca,'Xtick',XtickPos,'XtickLabel',XtickLabels,'FontSize',plotParams.axisFontSize-2)
legend({'saccBCI','errDcd'},'FontSize',plotParams.axisFontSize,'FontWeight','Bold','location','southeast')
title('Chico online ErrPs decoder performance','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
  
set(gcf,'PaperPositionMode','auto','Position',[20 345 1232 525])
