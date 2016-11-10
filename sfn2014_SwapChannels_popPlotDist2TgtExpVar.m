function sfn2014_SwapChannels_popPlotDist2TgtExpVar(expVar,pVals,ErrorInfo)
%
%
%
%
%
%
% 12 Nov 2014

if strcmp(ErrorInfo.plotInfo.arrayLoc{1},'SEF')
    % Jonah: 'SEF'    'FEF'    'PFC'
   %swapchannels to match Chico's order 
   % Exp. Var 
   tmpExpVar(1:32,:) = expVar(65:96,:);        % PFC in jonah is 65:96 -> PFC in Chico is 1:32
    tmpExpVar(65:96,:) = expVar(33:64,:);            % FEF in Jonah is 33:64 -> 65:96 Chico
    tmpExpVar(33:64,:) = expVar(1:32,:);            % FEF in Jonah is 33:64 -> 65:96 Chico
% P-values
    tmpPvals(1:32,:) = pVals(65:96,:);        % PFC in jonah is 65:96 -> PFC in Chico is 1:32
    tmpPvals(65:96,:) = pVals(33:64,:);            % FEF in Jonah is 33:64 -> 65:96 Chico
    tmpPvals(33:64,:) = pVals(1:32,:);            % FEF in Jonah is 33:64 -> 65:96 Chico
end

% Update vals
expVar = tmpExpVar;
pVals = tmpPvals;


%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);
% Arrays
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
% Plotting params
plotParams.nXtick = 12;
plotParams.nYtick = 10; %(AFSG-20140305)16; %96; set(gca,'fontsize',6)
plotParams.axisFontSize = 18; %(AFSG-20140305)13;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 19;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 2;
plotParams.lineStyle = ':';
% Axis

timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot
chVector = 1:ErrorInfo.nChs;

% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors
plotParams.arrayColor = [0.8 0.8 0.8];

timeVals = (1:1:size(expVar,2));            % x vals for imagfesc
chVals = 1:ErrorInfo.epochInfo.nChs;          % Y vals for imagesc

% Arrays
switch lower(ErrorInfo.session(1))
    case 'c', arrayLoc = {'PFC','SEF','FEF'};
    case 'j', arrayLoc = {'SEF','FEF','PFC'};
end


%% Plotting explained variance of all arrays
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s for %s trials, exp. var. of effect of previous trial outcome',ErrorInfo.session,ErrorInfo.analysis.typeVble),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

hPlot = imagesc(timeVector,chVector,(squeeze(expVar)).*(pVals <= ErrorInfo.analysis.ANOVA.pValCrit));
set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize+8)

% Plotting array limits
hold on
line([-ErrorInfo.epochInfo.preOutcomeTime/1000,ErrorInfo.epochInfo.postOutcomeTime/100],[32 32],'Color',[1 1 1],'lineWidth',plotParams.lineWidth+8,'lineStyle',plotParams.lineStyle)
line([-ErrorInfo.epochInfo.preOutcomeTime/1000,ErrorInfo.epochInfo.postOutcomeTime/100],[64 64],'Color',[1 1 1],'lineWidth',plotParams.lineWidth+8,'lineStyle',plotParams.lineStyle)
hBar = colorbar;
set(hBar,'Fontsize',plotParams.axisFontSize+8);

xlabel('Time to feedback onset [s]','FontSize',plotParams.axisFontSize+8,'FontWeight',plotParams.axisFontWeight)
ylabel('Electrode #','FontSize',plotParams.axisFontSize + 8,'FontWeight',plotParams.axisFontWeight)

% Title
title(sprintf('%s %s Exp.Var. all channels and arrays pVal <= %0.2f',ErrorInfo.session,ErrorInfo.analysis.typeVble,ErrorInfo.analysis.ANOVA.pValCrit),'FontSize',plotParams.titleFontSize + 4,'FontWeight',plotParams.titleFontWeight)

% Saving figures
if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-%s-ExpVar-balanced%i[%i-%ims]-[%0.1f-%iHz]-swapArraysJonah2Chico-SfNposter2014.png',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),...
        ErrorInfo.analysis.typeVble,ErrorInfo.analysis.balanced,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    disp(saveFilename)
    saveas(hFig,saveFilename)
end
clear hFig hPlot