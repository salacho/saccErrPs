function popPlotChicoJonahErrNormNumTrialsPerTgt
%
%
%
%
%
%
%


% Chico
sessionListChico = sfnSAbstractSessionList('chico'); 
[~,chicoPopNumTrialsPerDist2Tgt,ErrorInfo] = popGetErrNumTrialsPerTgt(sessionListChico);
% Jonah
sessionListJonah = sfnSAbstractSessionList('jonah');
[~,jonahPopNumTrialsPerDist2Tgt,ErrorInfo] = popGetErrNumTrialsPerTgt(sessionListJonah);

popSession = 'popMonkeyC-popMonkeyJ';

%% Basic params and vbles
plotInfo = ErrorInfo.plotInfo;
nTgts = ErrorInfo.epochInfo.nTgts;

%% Figure 
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[ 1312          15         649         913],...
    'name',sprintf('%s Incorrectly Decoded Target Count',popSession),...
    'NumberTitle','off','Visible',plotInfo.visible);
set(gcf,'visible','on');

%% Get infoStr (useful to name files, titles, axis, ...)
infoStr = getInfoStr(ErrorInfo);

for iPlot = 1:2
    if iPlot == 1       % Chico
        popSession = sprintf('pop%s-%s-%i',sessionListChico{1},sessionListChico{end},length(sessionListChico));
        popNumTrialsPerDist2Tgt = chicoPopNumTrialsPerDist2Tgt;
        sessionList = sessionListChico;
    else                % Jonah
        popSession = sprintf('pop%s-%s-%i',sessionListJonah{1},sessionListJonah{end},length(sessionListJonah));
        popNumTrialsPerDist2Tgt = jonahPopNumTrialsPerDist2Tgt;
        sessionList = sessionListJonah;
    end
    
    % Get Normalized values
    % popNormNumTrialsPerTgt = nan(size(popNumTrialsPerTgt));
    popNormNumTrialsPerDist2Tgt = nan(size(popNumTrialsPerDist2Tgt));
    for iSess = 1:length(sessionList)
        for iTgt = 1:nTgts
            popNormNumTrialsPerDist2Tgt(iSess,iTgt,:) = popNumTrialsPerDist2Tgt(iSess,iTgt,:)/sum(popNumTrialsPerDist2Tgt(iSess,iTgt,:));
        end
    end
    
    %Normalized
    % popNormMeanNumTrialsPerTgt = squeeze(nanmean(popNormNumTrialsPerTgt,1));                %[trueTgt x dcdTgt]
    % popNormStDevNumTrialsPerTgt = squeeze(nanstd(popNormNumTrialsPerTgt,[],1));             %[trueTgt x dcdTgt]
    popNormMeanNumTrialsPerDist2Tgt = squeeze(nanmean(popNormNumTrialsPerDist2Tgt,1));      %[trueTgt x dis2Tgt]
    popNormStDevNumTrialsPerDist2Tgt = squeeze(nanstd(popNormNumTrialsPerDist2Tgt,[],1));   %[trueTgt x dis2Tgt]
    
    %%
    subplot(2,1,iPlot)
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
end

%% Save figure
popSession = 'popMonkeyC-popMonkeyJ';

if plotInfo.savePlot
    saveFilename = sprintf('%s-meanErrorBarNumTrialsPerTgtLoc-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',popSession),...
        infoStr.strgRef,infoStr.noisyEpochStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end
