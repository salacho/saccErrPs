function ch2StDevAbove = plotChsVariability(corrEpochs,incorrEpochs,ErrorInfo)
% function plotChsVariability(corrEpochs,incorrEpochs,ErrorInfo)
%
% Plot some metrics related to the channel variability in order to
% establish if a whole channel should be removed or if only some trials
% are the ones to be removed.
%
%
% ch2StDevAbove:    logical vector. True for channels (index) with a standard 
%                   deviation above the mean of the st. dev. of all the
%                   channels times the st. dev. factor criteria. This is
%                   how it is calculated:
%   
%       ch2StDevAbove = corrIncorrMeanChStDev > mean(corrIncorrMeanChStDev) + ErrorInfo.epochInfo.noisyChsStDevFactor*std(corrIncorrMeanChStDev);
%
% Author : Andres.
% 
% Andres :  init    : 30 Oct 2014
% Andres :  


%% Basic params
plotInfo = ErrorInfo.plotInfo;
nChs = ErrorInfo.nChs;
% Time vector 
timeVector = linspace(-ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.epochLen)/1000;       % time in seconds            % x values for error bar lot

switch ErrorInfo.epochInfo.typeRef
    case 'lfp',     strgRef = '';
    case 'lapla',   strgRef = 'lapla-';
    case 'car',     strgRef = 'car';
end

%% Mean and st.dev. per outcome
corrStDevTrial = squeeze(std(corrEpochs,[],2));
incorrStDevTrial = squeeze(std(incorrEpochs,[],2));

hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[279    69   683   865],...
    'name',sprintf('%s st.dev. for correct-incorrect trials',ErrorInfo.session),'NumberTitle','off','Visible',plotInfo.visible);
subplot(2,1,1)
imagesc(timeVector,1:nChs,corrStDevTrial), colorbar, set(gca,'Ydir','normal'), 
title(sprintf('%s st.dev. for correct trials',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
xlabel('Time from feedback onset','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
ylabel('Ch Number','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
        
subplot(2,1,2)
imagesc(timeVector,1:nChs,incorrStDevTrial), colorbar, set(gca,'Ydir','normal'), 
title(sprintf('%s st.dev. for incorrect trials',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
xlabel('Time from feedback onset','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
ylabel('Ch Number','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)

if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-trialStDev-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end

%% Since we are treating channels as a whole, we should take correct and incorrect trials as a unique observation
corrIncorrEpochs = [corrEpochs incorrEpochs];
corrIncorrStDevTrial = squeeze(std(corrIncorrEpochs,[],2));

hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[279    69   683   865],...
    'name',sprintf('%s corr-Incorr Mean and St.Dev. for all trials and samples',ErrorInfo.session),'NumberTitle','off','Visible',plotInfo.visible);
subplot(2,1,1)
imagesc(timeVector,1:nChs,corrIncorrStDevTrial), colorbar, set(gca,'Ydir','normal'), 
title(sprintf('%s st.dev. correct and incorrect trials',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
xlabel('Time from feedback onset','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)
ylabel('Ch Number','FontSize',plotInfo.axisFontSz,'FontWeight',plotInfo.axisFontWeight)

%% Mean vals for all trials and samples
corrIncorrMeanChMean = mean(reshape(corrIncorrEpochs,[size(corrIncorrEpochs,1),size(corrIncorrEpochs,2)*size(corrIncorrEpochs,3)]),2);
corrIncorrMeanChStDev = std(reshape(corrIncorrEpochs,[size(corrIncorrEpochs,1),size(corrIncorrEpochs,2)*size(corrIncorrEpochs,3)]),[],2);

subplot(2,1,2)
plot(corrIncorrMeanChMean,'b')
hold on,
plot(corrIncorrMeanChStDev,'r')
title(sprintf('%s correct and incorrect Mean and St.Dev. for all trials and samples',ErrorInfo.session),'FontSize',plotInfo.titleFontSz-2,'FontWeight',plotInfo.titleFontWeight)
xlabel('Channel number','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)
ylabel('Value [uV]','FontSize',plotInfo.axisFontSz+2,'FontWeight',plotInfo.axisFontWeight)

ch2StDevAbove = corrIncorrMeanChStDev > mean(corrIncorrMeanChStDev) + ErrorInfo.epochInfo.noisyChsStDevFactor*std(corrIncorrMeanChStDev);
plot(1:nChs,ch2StDevAbove.*corrIncorrMeanChStDev,'b*')
legend({'Mean all trials/samples','St.Dev all trials/samples',sprintf('St.Dev >%0.1f mean(allChs St.Dev',ErrorInfo.epochInfo.noisyChsStDevFactor)},'FontSize',plotInfo.axisFontSz+1)

if plotInfo.savePlot
    saveFilename = sprintf('%s-corrIncorr-chStDev-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
    saveas(hFig,saveFilename)
    close(hFig)
end

%% Plot the highly variable channels

highlyVbleChs = find(ch2StDevAbove);
dummyGoodCh = zeros(20,20); dummyGoodCh(1,1) = 1;
dummyBadCh = ones(20,20); dummyBadCh(1,1) = 0;

for iArray = 1:plotInfo.nArrays
    hFig = figure;
    set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],'name',...
        sprintf('%s corr-Incorr %s highly variable channels!',ErrorInfo.session,plotInfo.arrayLoc{iArray}),...
        'NumberTitle','off','Visible',plotInfo.visible);
    
    for iCh = plotInfo.arrayChs(iArray,1):plotInfo.arrayChs(iArray,end)
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(plotInfo.layout.rows,plotInfo.layout.colms,plotInfo.layout.subplot(subCh)) % subplot location using layout info
        %% Plot all trials to see trend
        if any(iCh == highlyVbleChs),   imagesc(dummyBadCh)
        else                            imagesc(dummyGoodCh)
        end
        title(iCh)
    end
    
    subplot(plotInfo.layout.rows,plotInfo.layout.colms,1)                             % use subplot to place legend outside the graph
    legPlots(1,:) = plot(1,1,'k'); hold on
    legPlots(2,:) = plot(1,1,'r');
    legStr = {ErrorInfo.session,plotInfo.arrayLoc{iArray}};
    hLeg = legend(legPlots,legStr,'Location','Best','FontSize',10);
    set(hLeg,'XColor',[1 1 1],'YColor',[1 1 1])
    axis off                                                                % remove axis and background
    
    if plotInfo.savePlot
        saveFilename = sprintf('%s-highlyVbleChs-corrIncorr-%s-%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            plotInfo.arrayLoc{iArray},strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig,saveFilename)
        close(hFig)
    end
    
end

%% Never forget to update the channel list
disp(ErrorInfo.chList)
