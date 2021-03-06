function plotCrossCorrFreqBand_ErrDiffpostPreDiff_aveGroup1000Iter(preIncorrXcorrFreqBand_allIter,postIncorrXcorrFreqBand_allIter,preCorrXcorrFreqBand_allIter,postCorrXcorrFreqBand_allIter,errDiffFreqTxt,ErrorInfo)
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
preCorrXcorrFreqBand = nanmean(preCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreCorr)),4);
preIncorrXcorrFreqBand = nanmean(preIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPreIncorr)),4);
postCorrXcorrFreqBand = nanmean(postCorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostCorr)),4);
postIncorrXcorrFreqBand = nanmean(postIncorrXcorrFreqBand_allIter(:,:,:,setdiff(1:nIter,indxPostIncorr)),4);

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

hFig = figure; set(hFig,'PaperPositionMode','auto','position',[1281 1 1280 957],'visible','on');  %
chList = ErrorInfo.chList;

colorTxt = {'c','y','k','r','b','g'};
couplingVars = {'Delta','Theta','Alpha','Beta','Gamma','Hgamma'}; 
hLeg = nan(numel(couplingVars)-1,numel(errDiffFreqTxt));
lineWidth = 3;
fontSz = 11;

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
    for iCouple = 1:numel(couplingVars)
        subplot(numel(couplingVars),1,iFreqBand)
        % Zero line
        if iCouple == 1, plot([chList(1),chList(end)],[0 0],'k','linewidth',2), hold on, end
        % Data
        if iFreqBand ~= iCouple
            iPlot = iPlot + 1;
            eval(sprintf('data2plot = %s;',couplingVars{iCouple}));
            % plot
            hPlot(iFreqBand,iPlot) = plot(chList,data2plot,colorTxt{iCouple}','linewidth',lineWidth); hold on
            legendTxt{iFreqBand,iPlot} = sprintf('%s-%s',CouplingBand,couplingVars{iCouple});
        end
        %ylim([-0.3 0.3])
    end
    % arrays
    minMax(1) = nanmin([Delta;Theta;Alpha;Beta;Gamma;Hgamma]);
    minMax(2) = nanmax([Delta;Theta;Alpha;Beta;Gamma;Hgamma]);
    plot([32,32],minMax,'--k','linewidth',2);
    plot([64,64],minMax,'--k','linewidth',2),
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
title(sprintf('Ave.1000 iter %s:  ErrDiff-prePostDiff Cross-Freq. Amp-Amp. Coupling PFCSEFFEF rndSeedIter',ErrorInfo.session),'fontweight','bold','fontsize',13);
saveplotName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis','24Nov2016_rng_1000Iter',...
ErrorInfo.session),'ErrDiff-prePostDiff-Fdback-CrossFreqAmpCoupling-PFCSEFFEF_ave1000iterResampReplacing.png');
saveas(hFig,saveplotName), %close(hFig)

end