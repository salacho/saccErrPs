function plotCrossCorrFreqBand_three_1Freq(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo,CouplingBand)
% function plotCrossCorrFreqBand_three_1Freq(preIncorrXcorrFreqBand,postIncorrXcorrFreqBand,postCorrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
%
%
%
%
%
% 26 Oct. 2016

chList = ErrorInfo.chList;

% index
deltaIndx  = find(strcmp(errDiffFreqTxt,'delta'));
alphaIndx = find(strcmp(errDiffFreqTxt,'alpha'));
betaIndx = find(strcmp(errDiffFreqTxt,'beta'));
thetaIndx = find(strcmp(errDiffFreqTxt,'theta'));
gammaIndx = find(strcmp(errDiffFreqTxt,'gamma'));
hgammaIndx = find(strcmp(errDiffFreqTxt,'highGam'));

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
preDelta = squeeze(preIncorrXcorrFreqBand(firstIndx,deltaIndx,:));
preTheta = squeeze(preIncorrXcorrFreqBand(firstIndx,thetaIndx,:));
preAlpha = squeeze(preIncorrXcorrFreqBand(firstIndx,alphaIndx,:));
preBeta = squeeze(preIncorrXcorrFreqBand(firstIndx,betaIndx,:));
preGamma = squeeze(preIncorrXcorrFreqBand(firstIndx,gammaIndx,:));
preHgamma = squeeze(preIncorrXcorrFreqBand(firstIndx,hgammaIndx,:));

% postIncorr
postDelta = squeeze(postIncorrXcorrFreqBand(firstIndx,deltaIndx,:));
postTheta = squeeze(postIncorrXcorrFreqBand(firstIndx,thetaIndx,:));
postAlpha = squeeze(postIncorrXcorrFreqBand(firstIndx,alphaIndx,:));
postBeta = squeeze(postIncorrXcorrFreqBand(firstIndx,betaIndx,:));
postGamma = squeeze(postIncorrXcorrFreqBand(firstIndx,gammaIndx,:));
postHgamma = squeeze(postIncorrXcorrFreqBand(firstIndx,hgammaIndx,:));

% postCorr
postCorrDelta = squeeze(postCorrXcorrFreqBand(firstIndx,deltaIndx,:));
postCorrTheta = squeeze(postCorrXcorrFreqBand(firstIndx,thetaIndx,:));
postCorrAlpha = squeeze(postCorrXcorrFreqBand(firstIndx,alphaIndx,:));
postCorrBeta = squeeze(postCorrXcorrFreqBand(firstIndx,betaIndx,:));
postCorrGamma = squeeze(postCorrXcorrFreqBand(firstIndx,gammaIndx,:));
postCorrHgamma = squeeze(postCorrXcorrFreqBand(firstIndx,hgammaIndx,:));


%% plot
% colorTxt = {'b','r','k','g','c','y'};
couplingVars = {'Delta','Theta','Alpha','Beta','Gamma','Hgamma'}; 

hFig = figure; set(hFig,'PaperPositionMode','auto','position',[1281 1 1280 957],'visible','off')  %
lineWidth = 3;
fontSz = 11;

hLeg = nan(numel(couplingVars)-1,1);
iPlot = 0;
clear hLeg
for iCouple = 1:numel(couplingVars)
    if iCouple ~= find(strcmp(errDiffFreqTxt,CouplingBand))
        iPlot = iPlot + 1;
        subplot(numel(couplingVars)-1,1,iPlot)
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
        hLeg(iPlot) = legend(ErrorInfo.plotInfo.legendTxt);
        %
        %     if iCouple == numel(couplingVars)
        %         hLeg = legend(ErrorInfo.plotInfo.legendTxt);
        %         %hLeg(iCouple) = legend(ErrorInfo.plotInfo.legendTxt); %set(hLeg,'box','off','location','best')
        %     end
        set(gca,'fontsize',fontSz);
        ylabel(sprintf('%s-%s',CouplingBand,couplingVars{iCouple}),'fontweight','bold','fontsize',11);
        axis tight
    end
end
set(hLeg,'box','off','location','northeastoutside','fontsize',10)
subplot(numel(couplingVars)-1,1,numel(couplingVars)-1);
xlabel('Channel number','fontweight','bold','fontsize',12)

subplot(numel(couplingVars)-1,1,1);
title(sprintf('%s:  %sFdbacXcorr',ErrorInfo.session,ErrorInfo.plotInfo.dataPeriod),'fontweight','bold','fontsize',13)
saveplotName = sprintf('%s-%s-%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',...
ErrorInfo.session),ErrorInfo.plotInfo.dataPeriod,CouplingBand,'Fdback-CrossFreqAmpCoupling.png');
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




