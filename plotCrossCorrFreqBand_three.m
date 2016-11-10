function plotCrossCorrFreqBand_three(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% function plotCrossCorrFreqBand(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo,PosNegVals)
%
%
%
%
%
% 24 Oct. 2016

chList = ErrorInfo.chList;

if any((ErrorInfo.session(1:4) == 'J'))
    tmp1 = preIncorrXcorrFreqBand;
    tmp2 = postIncorrXcorrFreqBand;
    tmp3 = postCorrXcorrFreqBand;
    
    preIncorrXcorrFreqBand(:,:,1:32) = tmp1(:,:,65:96);
    preIncorrXcorrFreqBand(:,:,33:96) = tmp1(:,:,1:64);
    postIncorrXcorrFreqBand(:,:,1:32) = tmp2(:,:,65:96);
    postIncorrXcorrFreqBand(:,:,33:96) = tmp2(:,:,1:64);
    postCorrXcorrFreqBand(:,:,1:32) = tmp3(:,:,65:96);
    postCorrXcorrFreqBand(:,:,33:96) = tmp3(:,:,1:64);
else
end


% index
deltaIndx  = find(strcmp(errDiffFreqTxt,'delta'));
alphaIndx = find(strcmp(errDiffFreqTxt,'alpha'));
betaIndx = find(strcmp(errDiffFreqTxt,'beta'));
thetaIndx = find(strcmp(errDiffFreqTxt,'theta'));
gammaIndx = find(strcmp(errDiffFreqTxt,'gamma'));

% preIncorr
preAlphaBeta = squeeze(preIncorrXcorrFreqBand(alphaIndx,betaIndx,:));
preAlphaTheta = squeeze(preIncorrXcorrFreqBand(alphaIndx,thetaIndx,:));
preAlphaGamma = squeeze(preIncorrXcorrFreqBand(alphaIndx,gammaIndx,:));
preThetaBeta = squeeze(preIncorrXcorrFreqBand(thetaIndx,betaIndx,:));
preThetaGamma = squeeze(preIncorrXcorrFreqBand(thetaIndx,gammaIndx,:));
preBetaGamma = squeeze(preIncorrXcorrFreqBand(betaIndx,gammaIndx,:));
preDeltaTheta = squeeze(preIncorrXcorrFreqBand(deltaIndx,thetaIndx,:));
preDeltaAlpha = squeeze(preIncorrXcorrFreqBand(deltaIndx,alphaIndx,:));
preDeltaBeta = squeeze(preIncorrXcorrFreqBand(deltaIndx,betaIndx,:));

% postIncorr
postAlphaBeta = squeeze(postIncorrXcorrFreqBand(alphaIndx,betaIndx,:));
postAlphaTheta = squeeze(postIncorrXcorrFreqBand(alphaIndx,thetaIndx,:));
postAlphaGamma = squeeze(postIncorrXcorrFreqBand(alphaIndx,gammaIndx,:));
postThetaBeta = squeeze(postIncorrXcorrFreqBand(thetaIndx,betaIndx,:));
postThetaGamma = squeeze(postIncorrXcorrFreqBand(thetaIndx,gammaIndx,:));
postBetaGamma = squeeze(postIncorrXcorrFreqBand(betaIndx,gammaIndx,:));
postDeltaTheta = squeeze(postIncorrXcorrFreqBand(deltaIndx,thetaIndx,:));
postDeltaAlpha = squeeze(postIncorrXcorrFreqBand(deltaIndx,alphaIndx,:));
postDeltaBeta = squeeze(postIncorrXcorrFreqBand(deltaIndx,betaIndx,:));

% postCorr
postCorrAlphaBeta = squeeze(postCorrXcorrFreqBand(alphaIndx,betaIndx,:));
postCorrAlphaTheta = squeeze(postCorrXcorrFreqBand(alphaIndx,thetaIndx,:));
postCorrAlphaGamma = squeeze(postCorrXcorrFreqBand(alphaIndx,gammaIndx,:));
postCorrThetaBeta = squeeze(postCorrXcorrFreqBand(thetaIndx,betaIndx,:));
postCorrThetaGamma = squeeze(postCorrXcorrFreqBand(thetaIndx,gammaIndx,:));
postCorrBetaGamma = squeeze(postCorrXcorrFreqBand(betaIndx,gammaIndx,:));
postCorrDeltaTheta = squeeze(postCorrXcorrFreqBand(deltaIndx,thetaIndx,:));
postCorrDeltaAlpha = squeeze(postCorrXcorrFreqBand(deltaIndx,alphaIndx,:));
postCorrDeltaBeta = squeeze(postCorrXcorrFreqBand(deltaIndx,betaIndx,:));


colorTxt = {'b','r','k','g','--b','--g','--k','c','y'};
couplingVars = {'AlphaBeta','AlphaTheta','AlphaGamma','ThetaBeta','ThetaGamma','BetaGamma','DeltaTheta','DeltaAlpha','DeltaBeta'}; 

% plot
hFig = figure; set(hFig,'PaperPositionMode','auto','position',[1281 1 1280 957],'visible','on')  %
lineWidth = 3;
fontSz = 10;

%hLeg = nan(numel(couplingVars),1);
for iCouple = 1:numel(couplingVars)
    subplot(numel(couplingVars),1,iCouple)
    % data
    eval(sprintf('preData2plot = %s%s;','pre',couplingVars{iCouple}));
    eval(sprintf('postData2plot = %s%s;','post',couplingVars{iCouple}));
    eval(sprintf('corrData2plot = %s%s;','postCorr',couplingVars{iCouple}));
    % plot
    plot(chList,corrData2plot,'k','linewidth',lineWidth); hold on
    plot(chList,preData2plot,'b','linewidth',lineWidth); hold on
    plot(chList,postData2plot,'r','linewidth',lineWidth); hold on
    %     plot(chList,preData2plot,colorTxt{iCouple},'linewidth',lineWidth); hold on
    %     plot(chList,postData2plot,colorTxt{iCouple},'linewidth',lineWidth); hold on
    % arrays
    minMax(1) = min([postData2plot;preData2plot;corrData2plot]);
    minMax(2) = max([postData2plot;preData2plot;corrData2plot]);
    plot([32,32],minMax,'--k','linewidth',2)
    plot([64,64],minMax,'--k','linewidth',2), hold off
    hLeg(iCouple) = legend(ErrorInfo.plotInfo.legendTxt); 
    %
    %     if iCouple == numel(couplingVars)
    %         hLeg = legend(ErrorInfo.plotInfo.legendTxt);
    %         %hLeg(iCouple) = legend(ErrorInfo.plotInfo.legendTxt); %set(hLeg,'box','off','location','best')
    %     end
    set(gca,'fontsize',fontSz);
    ylabel(couplingVars{iCouple},'fontweight','bold','fontsize',9);
    axis tight
end
set(hLeg,'box','off','location','northeastoutside','fontsize',7)
subplot(numel(couplingVars),1,numel(couplingVars));
xlabel('Channel number','fontweight','bold','fontsize',12)

subplot(numel(couplingVars),1,1);
title(sprintf('%s:  %sFdbacXcorr-PFCSEFFEF',ErrorInfo.session,ErrorInfo.plotInfo.dataPeriod),'fontweight','bold','fontsize',13)
saveplotName = sprintf('%s-%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',...
ErrorInfo.session),ErrorInfo.plotInfo.dataPeriod,'Fdback-CrossFreqAmpCoupling-PFCSEFFEF.png');
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
    
    
end




