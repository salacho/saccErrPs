function plotCorrIncorrPrevOutcomeExpVar(expVarCorr,expVarIncorr,pValsCorr,pValsIncorr,ErrorInfo)
%
%
%
%
%

if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s Exp. Variance effect previous trial outcome %s',ErrorInfo.session,yLimTxt),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);


timeVector = (-ErrorInfo.epochInfo.preOutcomeTime/1000 + 1/ErrorInfo.epochInfo.Fs:1/ErrorInfo.epochInfo.Fs:ErrorInfo.epochInfo.preOutcomeTime/1000);            % x values for error bar lot
chNums = 1:ErrorInfo.nChs;

%% Correct
subplot(2,2,1)
imagesc(timeVector,chNums,expVarCorr)
colorbar
set(gca,'Ydir','normal')
xlabel('Time to feedback onset [sec]','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
ylabel('Explained Variance','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
title('Exp.Var. effect previous trial outcome Corr trials','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
hold on,
line([timeVector(1),timeVector(end)],[32 32],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')
line([timeVector(1),timeVector(end)],[64 64],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')

subplot(2,2,3)
imagesc(timeVector,chNums,expVarCorr.*(pValsCorr <= ErrorInfo.epochInfo.pValCrit))
colorbar
set(gca,'Ydir','normal')
xlabel('Time to feedback onset [sec]','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
ylabel('Explained Variance','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
title(sprintf('Exp.Var. effect p.Vals <= %0.2f Corr trials',ErrorInfo.epochInfo.pValCrit),'FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
hold on,
line([timeVector(1),timeVector(end)],[32 32],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')
line([timeVector(1),timeVector(end)],[64 64],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')

%% Incorrect
subplot(2,2,2)
imagesc(timeVector,chNums,expVarIncorr)
colorbar
set(gca,'Ydir','normal')
xlabel('Time to feedback onset [sec]','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
ylabel('Explained Variance','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
title('Exp.Var. effect previous trial outcome Incorr trials','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
hold on,
line([timeVector(1),timeVector(end)],[32 32],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')
line([timeVector(1),timeVector(end)],[64 64],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')

subplot(2,2,4)
imagesc(timeVector,chNums,expVarIncorr.*(pValsIncorr <= ErrorInfo.epochInfo.pValCrit))
colorbar
set(gca,'Ydir','normal')
xlabel('Time to feedback onset [sec]','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
ylabel('Explained Variance','FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
title(sprintf('Exp.Var. effect p.Vals <= %0.2f Corr trials',ErrorInfo.epochInfo.pValCrit),'FontSize',ErrorInfo.plotInfo.axisFontSz+5,'FontWeight',ErrorInfo.plotInfo.axisFontWeight)
hold on,
line([timeVector(1),timeVector(end)],[32 32],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')
line([timeVector(1),timeVector(end)],[64 64],'Color',ErrorInfo.plotInfo.arrayColor,'lineWidth',ErrorInfo.plotInfo.lineWidth+2,'lineStyle',':')

if ErrorInfo.plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-prevOutcomeExpVar-[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)

end


