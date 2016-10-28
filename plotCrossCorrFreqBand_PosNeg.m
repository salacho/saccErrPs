function plotCrossCorrFreqBand_PosNeg(incorrXcorrFreqBand,corrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
% plotCrossCorrFreqBand_PosNeg(incorrXcorrFreqBand,corrXcorrFreqBand,errDiffFreqTxt,ErrorInfo)
%
%
%
%
%
% 24 Oct. 2016

% xcrossFreqBand = preCorrXcorrFreqBand;
% xcrossFreqBand = preIncorrXcorrFreqBand;

incorrPos = incorrXcorrFreqBand.*(incorrXcorrFreqBand > 0);
corrPos = corrXcorrFreqBand.*(corrXcorrFreqBand > 0);

incorrNeg = incorrXcorrFreqBand.*(incorrXcorrFreqBand <= 0);
corrNeg = corrXcorrFreqBand.*(corrXcorrFreqBand <= 0);

xcrossFreqBand = incorrPos-corrPos;
chList = ErrorInfo.chList;

% index
deltaIndx  = find(strcmp(errDiffFreqTxt,'delta'));
alphaIndx = find(strcmp(errDiffFreqTxt,'alpha'));
betaIndx = find(strcmp(errDiffFreqTxt,'beta'));
thetaIndx = find(strcmp(errDiffFreqTxt,'theta'));
gammaIndx = find(strcmp(errDiffFreqTxt,'gamma'));

% xcorr
alphaBeta = squeeze(xcrossFreqBand(alphaIndx,betaIndx,:));
alphaTheta = squeeze(xcrossFreqBand(alphaIndx,thetaIndx,:));
alphaGamma = squeeze(xcrossFreqBand(alphaIndx,gammaIndx,:));
thetaBeta = squeeze(xcrossFreqBand(thetaIndx,betaIndx,:));
thetaGamma = squeeze(xcrossFreqBand(thetaIndx,gammaIndx,:));
betaGamma = squeeze(xcrossFreqBand(betaIndx,gammaIndx,:));
deltaTheta = squeeze(xcrossFreqBand(deltaIndx,thetaIndx,:));
deltaAlpha = squeeze(xcrossFreqBand(deltaIndx,alphaIndx,:));
deltaBeta = squeeze(xcrossFreqBand(deltaIndx,betaIndx,:));

% plot
hFig = figure; set(hFig,'PaperPositionMode','auto','position',[279   206   877   610],'visible','off')
lineWidth = 3;
plot(chList,alphaBeta,'b','linewidth',lineWidth); hold on
plot(chList,alphaTheta,'r','linewidth',lineWidth);
plot(chList,thetaBeta,'k','linewidth',lineWidth); 
plot(chList,alphaGamma,'g','linewidth',lineWidth); 
plot(chList,betaGamma,'c','linewidth',lineWidth); 
plot(chList,thetaGamma,'y','linewidth',lineWidth);
plot(chList,deltaTheta,'--g','linewidth',lineWidth);
plot(chList,deltaAlpha,'--b','linewidth',lineWidth);
plot(chList,deltaBeta,'--k','linewidth',lineWidth);

minMax(1) = min([alphaBeta;alphaTheta;alphaGamma;thetaBeta;thetaGamma;betaGamma]);
minMax(2) = max([alphaBeta;alphaTheta;alphaGamma;thetaBeta;thetaGamma;betaGamma]);
plot([32,32],minMax,'--k','linewidth',2)
plot([64,64],minMax,'--k','linewidth',2), hold off
hLeg = legend({'alphaBeta','alphaTheta','thetaBeta','alphaGamma','betaGamma','thetaGamma','deltaTheta','deltaAlpha','deltaBeta'});
set(hLeg,'box','off','linewidth',3,'location','best','fontsize',8);
xlabel('Channel number','fontweight','bold')
ylabel('Cross-frequency amplitude-amplitude coupling','fontweight','bold')
title(sprintf('%s:  %sFdbacXcorr',ErrorInfo.session,ErrorInfo.plotInfo.dataPeriod),'fontweight','bold')
axis tight
saveplotName = sprintf('%s-%s%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',...
ErrorInfo.session),ErrorInfo.plotInfo.dataPeriod,'FdbackErrDiffXcorr.png');
saveas(hFig,saveplotName), close(hFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Text
infoStr = getInfoStr(ErrorInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Per array
plotInfo = ErrorInfo.plotInfo;
rhythmList = {'alphaBeta','alphaTheta','alphaGamma','thetaBeta','thetaGamma','betaGamma','deltaTheta','deltaAlpha','deltaBeta'};
rhytmTypeList = 1:numel(rhythmList);

for iCouple = 1:numel(rhythmList)
    %% data2plot
    switch iCouple
        case 1, rhythm1 = 'alpha';rhythm2 = 'beta';     data2plot = alphaBeta;
        case 2, rhythm1 = 'alpha';rhythm2 = 'theta';    data2plot = alphaTheta;
        case 3, rhythm1 = 'alpha';rhythm2 = 'gamma';    data2plot = alphaGamma;
        case 4, rhythm1 = 'theta';rhythm2 = 'beta';     data2plot = thetaBeta;
        case 5, rhythm1 = 'theta';rhythm2 = 'gamma';    data2plot = thetaGamma;
        case 6, rhythm1 = 'beta';rhythm2 =  'gamma';     data2plot = betaGamma;
        case 7, rhythm1 = 'delta';rhythm2 = 'theta';     data2plot = deltaTheta;
        case 8, rhythm1 = 'delta';rhythm2 = 'alpha';     data2plot = deltaAlpha;
        case 9, rhythm1 = 'delta';rhythm2 = 'beta';     data2plot = deltaBeta;
    end
    
    %% get clims per array
    clim(1) = nanmin(data2plot);
    clim(2) = nanmax(data2plot);
    rhythmTxt = rhythmList{iCouple};

    %% Plot array
    for iArray = 1:length(plotInfo.arrayLoc)
       
        hFig = figure;
        set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
            'name',sprintf('%s cross-freq amp-amp coupling for %s-%s-%s',ErrorInfo.session,plotInfo.arrayLoc{iArray},rhythmTxt,infoStr.strSpecRange),...
            'NumberTitle','off','Visible','off');
        
        % Plot all channel
        for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
            % Plot
            imagesc(data2plot(iCh),[clim(1) clim(2)])
            %imagesc(data2plot(iCh),[clim(1,iArray) clim(2,iArray)])
            %colorbar
            title(sprintf('Ch%i',iCh),'FontSize',plotInfo.axisFontSz+2)
            set(gca,'Ydir','normal'), axis off
        end
        
        % legend arrays
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
        legPlots = clim;
        %legPlots = clim(:,iArray);
        for kk = 1:3, legPlots(kk) = plot(0,'Color',plotInfo.colorErrP(kk,:),'lineWidth',2); hold on, end;    % plot fake data to polace legends
        hLeg = legend(legPlots,{[char(plotInfo.arrayLoc(iArray)),'-',ErrorInfo.plotInfo.dataPeriod,'Fdback'],'CrossFreqAmpCoup',ErrorInfo.session([1:5,10:end])},0);
        set(hLeg,'box','off','fontsize',9)
        axis off                                                                % remove axis and background
        
        % legend transform
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,6)                             % use subplot to place legend outside the graph
        %imagesc(clim(:,iArray));
        imagesc(clim);
        colorbar
        hold on, axis off
        title(sprintf('CrossFreqAmpCoupling-%s',rhythmTxt) ,'FontSize',plotInfo.axisFontSz+3), axis off                                                                % remove axis and background
        
        % Saving figures if plotInfo.savePlot
        saveFilename = ...
            sprintf('%s-%s-FdbackXcorr-%s-%s%s.png',infoStr.strPrefix,...
            ErrorInfo.plotInfo.dataPeriod,plotInfo.arrayLoc{iArray},rhythmTxt,infoStr.strSuffix);
        saveas(hFig,saveFilename), close(hFig)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
end




