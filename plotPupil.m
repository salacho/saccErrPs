function plotPupil(eyeTraces,ErrorInfo)
%
%
%
%
%
%
%
%
%
%
%
% v1.0 

% Plotting params
plotParams.nXtick = 6;
plotParams.axisFontSize = 7;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 12;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 1.5;
plotParams.lineStyle = '-';

% Vble names
corrPupil = eyeTraces.eyeTraces.corrEye.pupil;
incorrPupil = eyeTraces.eyeTraces.incorrEye.pupil;

% Remove outliers related to eye traces lost
rmOutliers = true;
lowBound = -600;
corrMatrix = ones(ErrorInfo.epochInfo.nCorr,ErrorInfo.epochInfo.lenEpoch);
incorrMatrix = ones(ErrorInfo.epochInfo.nError,ErrorInfo.epochInfo.lenEpoch);
if rmOutliers
    % Find trials with values smaller than lowBound
    outlierCorrIndx = (eyeTraces.eyeTraces.corrEye.pupil <= lowBound*corrMatrix);
    outlierIncorrIndx = (eyeTraces.eyeTraces.incorrEye.pupil <= lowBound*incorrMatrix);
    corrTrials = find(sum(outlierCorrIndx,2) == 0);
    incorrTrials = find(sum(outlierIncorrIndx,2) == 0);
    
    % Discard trials with specified outliers. Do not correct, discard
    corrPupil = eyeTraces.eyeTraces.corrEye.pupil(corrTrials,:);
    incorrPupil = eyeTraces.eyeTraces.incorrEye.pupil(incorrTrials,:); 
end

% Mean and std epochs pupil traces
meanCorrPupil = nanmean(corrPupil);
meanIncorrPupil = nanmean(incorrPupil);
stdCorrPupil = nanstd(corrPupil,[],1);
stdIncorrPupil = nanstd(incorrPupil,[],1);
timeVals = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.lenEpoch);

% Plotting all traces for both outcomes
subplot(1,2,1),plot(timeVals,corrPupil,'b'),subplot(1,2,2),plot(timeVals,incorrPupil,'r')

% Plotting each trial
lastTrial = min([ErrorInfo.epochInfo.nCorr,ErrorInfo.epochInfo.nError]);
for iTrial = 1:lastTrial
    plot(timeVals,detrend(corrPupil(iTrial,:)),'b')
    hold on
    plot(timeVals,detrend(incorrPupil(iTrial,:)),'r')
    title(num2str(iTrial))
    hold off
    pause
end

% Plotting mean values
plot(timeVals,meanCorrPupil,'b')
hold on
plot(timeVals, meanIncorrPupil,'r')

% Plot error bars
hold on,
plotParams.plotColors(1,:) = [0 0 1];
[plotErrCorr]   = plotErrorBars(timeVals,(meanCorrPupil),(meanCorrPupil-stdCorrPupil),(meanCorrPupil+stdCorrPupil),plotParams);               % Blue for correct epochs
title(['Correct and Incorrect Mean/STD pupil size for ',ErrorInfo.session],'FontSize',plotParams.titleFontSize+2,'FontWeight',plotParams.titleFontWeight)
plotParams.plotColors(1,:) = [1 0 0];
[plotErrIncorr] = plotErrorBars(timeVals,(meanIncorrPupil),(meanIncorrPupil-stdIncorrPupil),(meanIncorrPupil+stdIncorrPupil),plotParams);     % Red for correct epochs
plotParams.lineStyle = '--';
line([0 0],[min(min(meanCorrPupil-stdCorrPupil),min(meanIncorrPupil-stdIncorrPupil)) max(max(meanCorrPupil+stdCorrPupil),max(meanIncorrPupil+stdIncorrPupil))],...
            'Color','k','LineWidth',plotParams.lineWidth,...
            'LineStyle',plotParams.lineStyle);
 plotParams.lineStyle = '-';
% Plot properties
xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+6,'FontWeight','Bold')
ylabel('Pupil axis size [dva]','FontSize',plotParams.axisFontSize+6,'FontWeight','Bold')
legend([plotErrCorr.H plotErrIncorr.H],{'Correct','Error'},'location','SouthWest','FontWeight','Bold','FontSize',plotParams.titleFontSize+2)
axis tight;

% ANOVA
ErrorInfo.epochInfo.ANOVA.grandMeanMethod = 0;
ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar = 0;
ErrorEpochs = [corrPupil; incorrPupil];
ErrorID = [zeros(size(corrPupil,1),1);ones(size(incorrPupil,1),1)];
ErrorInfo.epochInfo.ANOVA.analDim = 1;
%ErrorInfo.epochInfo.ANOVA.epochLabel

[expVar,n,pVals,mu,F] = myANOVA1(ErrorEpochs,ErrorID,ErrorInfo.epochInfo.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);

subplot(2,1,1)
subPlot(1) = plot(timeVals,expVar,'r','LineWidth',2);
ylabel('Explained variance','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
title(['Pupil size ANOVA. ',ErrorInfo.session],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
plotParams.lineStyle = '--';
line([0 0],[min(expVar) max(expVar)],'Color','k','LineWidth',plotParams.lineWidth,'LineStyle',plotParams.lineStyle);
subplot(2,1,2)
subPlot(2) = plot(timeVals,pVals,'b','LineWidth',2);
xlabel('Time from reward/punishment stimulus onset [ms]','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
ylabel('P-value','FontSize',plotParams.axisFontSize+4,'FontWeight','Bold')
title(['p-values for ANOVA. ',ErrorInfo.session],'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
line([0 0],[min(pVals) max(pVals)],'Color','k','LineWidth',plotParams.lineWidth,'LineStyle',plotParams.lineStyle);
