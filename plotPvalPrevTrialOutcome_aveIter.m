function plotPvalPrevTrialOutcome_aveIter(expVar,pVals,ErrorInfo)
%
%
%
%
%
%
% 09 Nov 2014



%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);
% Arrays
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
% Plotting params
plotParams.nXtick = 12;
plotParams.nYtick = 10; %(AFSG-20140305)16; %96; set(gca,'fontsize',6)
plotParams.axisFontSize = 16; %(AFSG-20140305)13;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 17;
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

% % Arrays
% switch lower(ErrorInfo.session(1))
%     case 'c', arrayLoc = {'PFC','SEF','FEF'};
%     case 'j', arrayLoc = {'SEF','FEF','PFC'};
% end
%
% Arrays
expVarMod = nan(size(expVar));
switch lower(ErrorInfo.session(1))
    case 'c', arrayLoc = {'PFC','SEF','FEF'}; 
        expVarMod = expVar;
            pValsMod = pVals;
    case 'j', arrayLoc = {'SEF','FEF','PFC'}; 
        expVarMod(1:32,:) = expVar(65:96,:);
        expVarMod(33:96,:) = expVar(1:64,:);
        pValsMod(1:32,:) = pVals(65:96,:);
        pValsMod(33:96,:) = pVals(1:64,:);
        arrayLoc = {'PFC','SEF','FEF'};
    case 'p'
        if strcmp(lower(ErrorInfo.session(4)),'j')
            expVarMod(1:32,:) = expVar(65:96,:);
            expVarMod(33:96,:) = expVar(1:64,:);
            pValsMod(1:32,:) = pVals(65:96,:);
            pValsMod(33:96,:) = pVals(1:64,:);
            arrayLoc = {'PFC','SEF','FEF'};
        else arrayLoc = {'PFC','SEF','FEF'}; 
            expVarMod = expVar;
            pValsMod = pVals;
        end
end

%% Plotting explained variance of all arrays
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s for %s trials, exp. var. of effect of previous trial outcome',ErrorInfo.session,ErrorInfo.analysis.typeVble),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

hPlot = imagesc(timeVector,chVector,(pValsMod <= ErrorInfo.analysis.ANOVA.pValCrit/((size(expVarMod,2)*96))));
set(gca,'Ydir','normal','FontSize',plotParams.axisFontSize+8)

% Plotting array limits
hold on
line([-ErrorInfo.epochInfo.preOutcomeTime/1000,ErrorInfo.epochInfo.postOutcomeTime/100],[32 32],'Color',[1 1 1],'lineWidth',plotParams.lineWidth+8,'lineStyle',plotParams.lineStyle)
line([-ErrorInfo.epochInfo.preOutcomeTime/1000,ErrorInfo.epochInfo.postOutcomeTime/100],[64 64],'Color',[1 1 1],'lineWidth',plotParams.lineWidth+8,'lineStyle',plotParams.lineStyle)
hBar = colorbar;
set(hBar,'Fontsize',plotParams.axisFontSize+8);

xlabel('Time from feedback onset [s]','FontSize',plotParams.axisFontSize+8,'FontWeight',plotParams.axisFontWeight)
ylabel('Electrode #','FontSize',plotParams.axisFontSize + 8,'FontWeight',plotParams.axisFontWeight)

% Title
title(sprintf('%s %s prevTrialOut Exp. Var. pVal <= %0.2f',ErrorInfo.session,ErrorInfo.analysis.typeVble,ErrorInfo.analysis.ANOVA.pValCrit),'FontSize',plotParams.titleFontSize + 4,'FontWeight',plotParams.titleFontWeight)

% Saving figures
if ErrorInfo.plotInfo.savePlot
    disp('Saving file')
    if any(ErrorInfo.session == 'p')
           saveFilename = sprintf('%s-%s-prevTrialOutcomePval_ave1000Iter-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),...
        ErrorInfo.analysis.typeVble,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    else
        saveFilename = sprintf('%s-%s-prevTrialOutcomePval_ave1000Iter-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            ErrorInfo.analysis.typeVble,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    end
    saveas(hFig,saveFilename)
end
clear hFig hPlot