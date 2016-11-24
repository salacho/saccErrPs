function plotCrossCorrFreqBand_ErrDiffpostPreDiff_ave1kIter_arrayMean(preIncorrXcorrFreqBand_allIter,postIncorrXcorrFreqBand_allIter,preCorrXcorrFreqBand_allIter,postCorrXcorrFreqBand_allIter,errDiffFreqTxt,ErrorInfo)
%
%
%
%
% 26 Oct. 2016
%
% errDiffFreqTxt
% ErrorInfo

% indxPreCorr = (~(preCorrXcorrFreqBand_allIter == 0));
% indxPreIncorr = (~(preIncorrXcorrFreqBand_allIter == 0));
% indxPostCorr = (~(postCorrXcorrFreqBand_allIter == 0));
% indxPostIncorr = (~(postIncorrXcorrFreqBand_allIter == 0));

indxPreCorr = find(squeeze(preCorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPreIncorr = find(squeeze(preIncorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPostCorr = find(squeeze(postCorrXcorrFreqBand_allIter(1,1,1,:) == 0));
indxPostIncorr = find(squeeze(postIncorrXcorrFreqBand_allIter(1,1,1,:) == 0));

%% Save
preCorrXcorrFreqBand = mean(preCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreCorr)),4);
preIncorrXcorrFreqBand = mean(preIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreIncorr)),4);
postCorrXcorrFreqBand = mean(postCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostCorr)),4);
postIncorrXcorrFreqBand = mean(postIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostIncorr)),4);

chList = ErrorInfo.chList;

% Get pre-post diff to account for real change due to feedback presentation
postPreIncorr = postIncorrXcorrFreqBand - preIncorrXcorrFreqBand;
postPreCorr = postCorrXcorrFreqBand - preCorrXcorrFreqBand;
ErrDiffPre = postPreIncorr - postPreCorr;

% Rearrange order of arrays so they all are PFC,SEF, FEF
if any((ErrorInfo.session(1:4) == 'J'))
    tmp = ErrDiffPre;
    ErrDiff(:,:,1:32) = tmp(:,:,65:96);
    ErrDiff(:,:,33:96) = tmp(:,:,1:64);
else
    ErrDiff = ErrDiffPre;
end

% index
deltaIndx  = find(strcmp(errDiffFreqTxt,'delta'));
alphaIndx = find(strcmp(errDiffFreqTxt,'alpha'));
betaIndx = find(strcmp(errDiffFreqTxt,'beta'));
thetaIndx = find(strcmp(errDiffFreqTxt,'theta'));
gammaIndx = find(strcmp(errDiffFreqTxt,'gamma'));
hgammaIndx = find(strcmp(errDiffFreqTxt,'highGam'));

hFig = figure; set(hFig,'PaperPositionMode','auto','position',[1823 35 866 717],'visible','on');  %

colorTxt = {'c','y','k','r','b','g'};
couplingVars = {'Delta','Theta','Alpha','Beta','Gamma','Hgamma'}; 
hLeg = nan(numel(couplingVars)-1,numel(errDiffFreqTxt));
lineWidth = 3;
fontSz = 11;

minMax = [0 0];
for iFreqBand = 1:numel(errDiffFreqTxt)
    
    CouplingBand = errDiffFreqTxt{iFreqBand};
    %% First band to compare
    switch CouplingBand
        case 'delta',   firstIndx = deltaIndx;
        case 'theta',   firstIndx = thetaIndx;
        case 'alpha',   firstIndx = alphaIndx;
        case 'beta',    firstIndx = betaIndx;
        case 'gamma',   firstIndx = gammaIndx;
        case 'highGam', firstIndx = hgammaIndx;
    end
    
    %% Data
    % preIncorr
    Delta = squeeze(ErrDiff(firstIndx,deltaIndx,:));
    Theta = squeeze(ErrDiff(firstIndx,thetaIndx,:));
    Alpha = squeeze(ErrDiff(firstIndx,alphaIndx,:));
    Beta = squeeze(ErrDiff(firstIndx,betaIndx,:));
    Gamma = squeeze(ErrDiff(firstIndx,gammaIndx,:));
    Hgamma = squeeze(ErrDiff(firstIndx,hgammaIndx,:));
    
    %% plot
    iPlot = 0;
    meanArray = 1:3;
    for iCouple = 1:numel(couplingVars)
        subplot(numel(couplingVars),1,iFreqBand)
        % Zero line
        if iCouple == 1, plot([1 3],[0 0],'--k','linewidth',1), hold on, end
        % Data
        if iFreqBand ~= iCouple
            iPlot = iPlot + 1;
            eval(sprintf('data2plot = %s;',couplingVars{iCouple}));
            meanPFC = nanmean(data2plot(1:32));
            meanSEF = nanmean(data2plot(33:64));
            meanFEF = nanmean(data2plot(65:96));
            mean2plot = [meanPFC meanSEF meanFEF];
            % plot
            hPlot(iFreqBand,iPlot) = plot(meanArray,mean2plot,'-*','color',colorTxt{iCouple}','linewidth',lineWidth,'markersize',3); hold on
            legendTxt{iFreqBand,iPlot} = sprintf('%s-%s',CouplingBand,couplingVars{iCouple});
            
            minMax(1) = min(min(mean2plot),minMax(1));
            minMax(2) = max(max(mean2plot),minMax(2));
        end
        %ylim([-0.3 0.3])
    end
    % arrays
    set(gca,'fontsize',fontSz);
    axis tight
    
    subplot(numel(couplingVars),1,iFreqBand);
    hLeg(iFreqBand,:) = legend(hPlot(iFreqBand,:),legendTxt(iFreqBand,:));
    ylabel(sprintf('%s',CouplingBand),'fontweight','bold','fontsize',11);
end
set(hLeg,'box','off','location','northeastoutside','fontsize',10);
subplot(numel(couplingVars),1,numel(couplingVars));
xlabel('Channel number (channel order: PFC-SEF-FEF)','fontweight','bold','fontsize',12);

%% update dirs and paths
ErrorInfo.dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved

subplot(numel(couplingVars),1,1);
title(sprintf('mean Array Ave.1000 iter %s:  ErrDiff-prePostDiff Cross-Freq. Amp-Amp. Coupling PFCSEFFEF',ErrorInfo.session),'fontweight','bold','fontsize',13);
saveplotName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',...
ErrorInfo.session),'ErrDiff-prePostDiff-Fdback-CrossFreqAmpCoupling-PFCSEFFEF_ave1kIterResampRepla_meanArray.png');
saveas(hFig,saveplotName), %close(hFig)

end