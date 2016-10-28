function plotPredictorsDist2Tgt(ampDecoding,ErrorInfo)
%
%
%
%
% 09 Nov 2014

% Params
plotInfo = ErrorInfo.plotInfo;

% Factors
factorError = ampDecoding.factorError;              
factorDist2Tgt = ampDecoding.factorDist2Tgt;
% factorLat = ampDecoding.factorLat;
% factorTgt = ampDecoding.factorTgt;
maxAmp = ampDecoding.maxAmp; %#ok<*NASGU>
minAmp = ampDecoding.minAmp;

%% Plot
% Vals for each array
nCols = 6;
nRows = 6;
nTrials = size(ampDecoding.maxAmp,1);

% Find corr and incorr trials
corrTrials  =  factorError == 0;
incorrTrials = factorError ~= 0;
dist1Trials = factorDist2Tgt == 1;
dist2Trials = factorDist2Tgt == 2;
dist3Trials = factorDist2Tgt == 3;

% min Number of trials to plot
[corrTrials,incorrTrials] = reduceVectorsToPlotPred(corrTrials,incorrTrials);
[corrTrials1,dist1Trials] = reduceVectorsToPlotPred(corrTrials,dist1Trials);
[corrTrials2,dist2Trials] = reduceVectorsToPlotPred(corrTrials,dist2Trials);
[corrTrials3,dist3Trials] = reduceVectorsToPlotPred(corrTrials,dist3Trials);

% % Mean and variance per channel of max Amp
% corrMaxAmp = maxAmp(corrTrials,:);
% incorrMaxAmp = maxAmp(incorrTrials,:);
% subplot(1,2,1)
% boxplot(corrMaxAmp,'color','g')
% subplot(1,2,2)
% boxplot(incorrMaxAmp,'color','b')
 
%% Corr vs. Incorr/dist2Tgt
predictName = {'maxAmp','minAmp'};
for iPred = 1:length(predictName)
    % Predictors to plot
    predict2plot = eval(predictName{iPred});
    % Predictor per array
    for iArray = 1:plotInfo.nArrays
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1281           1        1280         948],...
            'name',sprintf('%s corr-incorr-dist2tgt predictor %s %s',ErrorInfo.session,predictName{iPred},plotInfo.arrayLoc{iArray}),...
            'NumberTitle','off','Visible',plotInfo.visible);
        % Plot each array
        for iCh = ErrorInfo.plotInfo.arrayChs(iArray,1):ErrorInfo.plotInfo.arrayChs(iArray,end)
            subCh = mod(iCh-1,size(plotInfo.colorMap,1))+1;
            subplot(nRows,nCols,subCh)
            % Get max min limit
            upLim = max([predict2plot(corrTrials,iCh);predict2plot(incorrTrials,iCh)]);
            lowLim = min([predict2plot(corrTrials,iCh);predict2plot(incorrTrials,iCh)]);
            % Plot dots
            plot([lowLim upLim],[lowLim upLim],'k','linewidth',plotInfo.lineWidth-1), hold on
            plot(predict2plot(corrTrials,iCh),predict2plot(incorrTrials,iCh),'color',plotInfo.distColors(1,:),'lineStyle','*');
            plot(predict2plot(corrTrials1,iCh),predict2plot(dist1Trials,iCh),'color',plotInfo.distColors(2,:),'lineStyle','*');
            plot(predict2plot(corrTrials2,iCh),predict2plot(dist2Trials,iCh),'color',plotInfo.distColors(3,:),'lineStyle','*');
            plot(predict2plot(corrTrials3,iCh),predict2plot(dist3Trials,iCh),'color',plotInfo.distColors(4,:),'lineStyle','*');
            title(iCh,'fontsize',plotInfo.titleFontSz-2,'fontweight',plotInfo.titleFontWeight)
            axis tight
        end
        
        subplot(nRows,nCols,subCh + 1)
        legPlots = nan(5,1);
        for kk = 1:5, legPlots(kk) = plot(0,'Color',plotInfo.distColors(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
        legend(legPlots,{'Corr-Incorr','Corr-dist1','Corr-dist2','Corr-dist3',[char(plotInfo.arrayLoc(iArray)),'-',char(predictName{iPred})]},0)
        axis off                                                                % remove axis and background
        % Saving figures
        if plotInfo.savePlot
            saveFilename = sprintf('%s-%sPredict-corrIncorrDist2Tgt-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
                predictName{iPred},plotInfo.arrayLoc{iArray},ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
            saveas(hFig,saveFilename)
        end
    end
end


