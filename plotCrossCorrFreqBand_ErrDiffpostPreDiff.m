function plotCrossCorrFreqBand_ErrDiffpostPreDiff(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,preCorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% function plotCrossCorrFreqBand_ErrDiffpostPreDiff_1Freq(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,preCorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
%
%
%
%
%
% 26 Oct. 2016

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

hFig = figure; set(hFig,'PaperPositionMode','auto','position',[1281 1 1280 957],'visible','on')  %

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
        ylim([-0.3 0.3])
    end
    % arrays
    minMax(1) = nanmin([Delta;Theta;Alpha;Beta;Gamma;Hgamma]);
    minMax(2) = nanmax([Delta;Theta;Alpha;Beta;Gamma;Hgamma]);
    plot([32,32],minMax,'--k','linewidth',2)
    plot([64,64],minMax,'--k','linewidth',2),
    set(gca,'fontsize',fontSz);
    %axis tight
    
    subplot(numel(couplingVars),1,iFreqBand)
    hLeg(iFreqBand,:) = legend(hPlot(iFreqBand,:),legendTxt(iFreqBand,:));
    ylabel(sprintf('%s',CouplingBand),'fontweight','bold','fontsize',11);
end
set(hLeg,'box','off','location','northeastoutside','fontsize',10)
subplot(numel(couplingVars),1,numel(couplingVars));
xlabel('Channel number (channel order: PFC-SEF-FEF)','fontweight','bold','fontsize',12)

subplot(numel(couplingVars),1,1);
title(sprintf('%s:  ErrDiff-prePostDiff Cross-Freq. Amp-Amp. Coupling',ErrorInfo.session),'fontweight','bold','fontsize',13)
saveplotName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',...
ErrorInfo.session),'ErrDiff-prePostDiff-Fdback-CrossFreqAmpCoupling.png');
saveas(hFig,saveplotName), %close(hFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Text
% infoStr = getInfoStr(ErrorInfo);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Per array
% plotInfo = ErrorInfo.plotInfo;
% rhythmList = {'alphaBeta','alphaTheta','alphaGamma','thetaBeta','thetaGamma','betaGamma','deltaTheta','deltaAlpha','deltaBeta'};
% rhytmTypeList = 1:numel(rhythmList);
% 
% for iCouple = 1:numel(rhythmList)
%     %% data2plot
%     switch iCouple
%         case 1, rhythm1 = 'alpha';rhythm2 = 'beta';     data2plot = alphaBeta;
%         case 2, rhythm1 = 'alpha';rhythm2 = 'theta';    data2plot = alphaTheta;
%         case 3, rhythm1 = 'alpha';rhythm2 = 'gamma';    data2plot = alphaGamma;
%         case 4, rhythm1 = 'theta';rhythm2 = 'beta';     data2plot = thetaBeta;
%         case 5, rhythm1 = 'theta';rhythm2 = 'gamma';    data2plot = thetaGamma;
%         case 6, rhythm1 = 'beta';rhythm2 =  'gamma';     data2plot = betaGamma;
%         case 7, rhythm1 = 'delta';rhythm2 = 'theta';     data2plot = deltaTheta;
%         case 8, rhythm1 = 'delta';rhythm2 = 'alpha';     data2plot = deltaAlpha;
%         case 9, rhythm1 = 'delta';rhythm2 = 'beta';     data2plot = deltaBeta;
%     end
%     
%     %% get clims per array
%     clim(1) = nanmin(data2plot);
%     clim(2) = nanmax(data2plot);
%     rhythmTxt = rhythmList{iCouple};
% 
%     %% Plot array
%     for iArray = 1:length(plotInfo.arrayLoc)
%        
%         hFig = figure;
%         set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
%             'name',sprintf('%s cross-freq amp-amp coupling for %s-%s-%s-%s',ErrorInfo.session,plotInfo.arrayLoc{iArray},rhythmTxt,PosNegVals,infoStr.strSpecRange),...
%             'NumberTitle','off','Visible','off');
%         
%         % Plot all channel
%         for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
%             subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
%             subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
%             % Plot
%             imagesc(data2plot(iCh),[clim(1) clim(2)])
%             %imagesc(data2plot(iCh),[clim(1,iArray) clim(2,iArray)])
%             %colorbar
%             title(sprintf('Ch%i',iCh),'FontSize',plotInfo.axisFontSz+2)
%             set(gca,'Ydir','normal'), axis off
%         end
%         
%         % legend arrays
%         subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
%         legPlots = clim;
%         %legPlots = clim(:,iArray);
%         for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
%         hLeg = legend(legPlots,{[char(plotInfo.arrayLoc(iArray)),'-',ErrorInfo.plotInfo.dataPeriod,'Fdback'],sprintf('CrossFreqAmpCoup-%s',PosNegVals),ErrorInfo.session([1:5,10:end])},0);
%         set(hLeg,'box','off','fontsize',9)
%         axis off                                                                % remove axis and background
%         
%         % legend transform
%         subplot(plotInfo.layout.rows,plotInfo.layout.colms,6)                             % use subplot to place legend outside the graph
%         %imagesc(clim(:,iArray));
%         imagesc(clim);
%         colorbar
%         hold on, axis off
%         title(sprintf('CrossFreqAmpCoupling-%s',rhythmTxt) ,'FontSize',plotInfo.axisFontSz+3), axis off                                                                % remove axis and background
%         
%         % Saving figures if plotInfo.savePlot
%         saveFilename = ...
%             sprintf('%s-%s-FdbackXcorr-%s-%s-%s%s.png',infoStr.strPrefix,...
%             ErrorInfo.plotInfo.dataPeriod,plotInfo.arrayLoc{iArray},rhythmTxt,PosNegVals,infoStr.strSuffix);
%         saveas(hFig,saveFilename), close(hFig)
%     end
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   
ferrez = [270 270 350 450 550 550]; 
jonah = [100 100 200 300 300 500]; 
chico = [100 100 100 300 250 500]

mean(ferrez - chico)
mean(ferrez - jonah)
end




