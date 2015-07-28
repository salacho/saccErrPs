function tempCorrelationDecoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here and below Analysis done in August 2013, correlation decoder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Per trials analysis of Corr-Incorr difference traces
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analysis vbles
nChs = ErrorInfo.epochInfo.nChs;
nCorr = ErrorInfo.epochInfo.nCorr;
nError = ErrorInfo.epochInfo.nError;
epochLen = ErrorInfo.epochInfo.lenEpoch;
session = ErrorInfo.session;
analStartTime = 601;
maxLag = 50;

% % Data transformation
% dataTransform(corrEpochs)
% dataTransform(incorrEpochs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Per trial analysis based on baseline difference
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Baseline mean and std 
baseEpochBoth = [corrBaseline(:,:,1001:2500),incorrBaseline(:,:,1001:2500)];
baseMeanBoth = nanmean(squeeze(nanmean(baseEpochBoth,2)),2);
baseStdBoth = nanstd(squeeze(nanmean(baseEpochBoth,2)),[],2);
baseLen = size(baseEpochBoth,3);
clear baseEpochBoth
% % Correct and Error Mean values
% baseMeanCorr    = nanmean(meanCorrBaseline(:,1001:2500),2);
% baseMeanIncorr  = nanmean(meanIncorrBaseline(:,1001:2500),2);
% baseStdCorr     = nanstd(meanCorrBaseline(:,1001:2500),[],2);
% baseStdIncorr   = nanstd(meanIncorrBaseline(:,1001:2500),[],2);

% %% Analysis for the mean values
% diffMean = corrMean - incorrMean;
% analDiff  = nan(size(diffMean(:,analStartTime:size(diffMean,2))));
% analDiff3 = nan(size(diffMean(:,analStartTime:size(diffMean,2))));
% 
% iTs = 0;
% for iTime = analStartTime:size(diffMean,2)
%     iTs = iTs + 1;
%     analDiff(:,iTs) = (diffMean(:,iTime) > 2*baseStdCorr);
%     analDiff3(:,iTs) = (diffMean(:,iTime) > 3*baseStdCorr);
% end
% figure, 
% subplot(2,1,1)
% imagesc(analDiff), set(gca,'yDir','normal'), colorbar
% subplot(2,1,2)
% imagesc(analDiff3), set(gca,'yDir','normal'), colorbar 

%% Getting meanCorrect-error difference trace per epoch
corrMeanAllT = repmat(corrMean,[1 1 nError]);                                           % Creating same matrices for all trials
corrMeanAllT = permute(corrMeanAllT,[1 3 2]);                                           % Permuting the dim to match the incorrEpochs dim
epochDiff = corrMeanAllT - incorrEpochs;                                                % Getting diff between correct and incorrect traces for each trial
% Checking difference per epoch for error trials
baseStdBothAllT     = repmat(baseStdBoth,[1 nError epochLen-analStartTime+1]);          % Creating 3-Dim matrix with std values of channels for all trials and time steps
analEpochDiff       = epochDiff(:,:,analStartTime:epochLen) > 2*baseStdBothAllT;        % comparing 3-Dim 2*std matrix with error values in all trials and time-steps
analEpochDiff3      = epochDiff(:,:,analStartTime:epochLen) > 3*baseStdBothAllT;        % comparing 3-Dim 3*std matrix with error values in all trials and time-steps
% comparing meanCorr
epochDiffCorr       = corrMean - squeeze(corrEpochs(:,iTrial,:));                             
% Checking difference per epoch for correct trials
baseStdBothAllT     = repmat(baseStdBoth,[1 nCorr epochLen-analStartTime+1]);           % Creating 3-Dim matrix with std values of channels for all trials and time steps
analEpochDiffCorr   = epochDiffCorr(:,:,analStartTime:epochLen) > 2*baseStdBothAllT;    % comparing 3-Dim 2*std matrix with correct values in all trials and time-steps
analEpochDiffCorr3  = epochDiffCorr(:,:,analStartTime:epochLen) > 3*baseStdBothAllT;    % comparing 3-Dim 3*std matrix with correct values in all trials and time-steps

%% Checking if threshold is held for more than X ms
% %% Plotting each trial
% hFig = figure;
% set(hFig,'Position',[412 49 560 892])
% for iTrial = 1:nError
%     subplot(2,2,1)
%     imagesc(squeeze(analEpochDiffCorr(:,iTrial,:))), set(gca,'yDir','normal'), colorbar
%     subplot(2,2,3)
%     imagesc(squeeze(analEpochDiffCorr3(:,iTrial,:))), set(gca,'yDir','normal'), colorbar
%     subplot(2,2,2)
%     imagesc(squ eeze(analEpochDiff(:,iTrial,:))), set(gca,'yDir','normal'), colorbar
%     subplot(2,2,4)
%     imagesc(squeeze(analEpochDiff3(:,iTrial,:))), set(gca,'yDir','normal'), colorbar
%     title(sprintf('Trial%i',iTrial))
%     pause
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Signal template correlation decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matching templates
repErrCorrMean    = repmat(corrMean,[1 1 nError]);   	% repeating mean waveforms for mean correct and incorrect traces
repErrCorrMean    = permute(repErrCorrMean,[1 3 2]); 
repErrIncorrMean  = repmat(incorrMean,[1 1 nError]);    % repeating mean waveforms for mean correct and incorrect traces
repErrIncorrMean  = permute(repErrIncorrMean,[1 3 2]); 
repCorrCorrMean   = repmat(corrMean,[1 1 nCorr]);       % repeating mean waveforms for mean correct and incorrect traces
repCorrCorrMean   = permute(repCorrCorrMean,[1 3 2]);
repCorrIncorrMean = repmat(incorrMean,[1 1 nCorr]);     % repeating mean waveforms for mean correct and incorrect traces
repCorrIncorrMean = permute(repCorrIncorrMean,[1 3 2]); 

% Compare mean waveforms with correct epochs
rCorrCorr = nan(nChs,nCorr,2*maxLag + 1);
rCorrIncorr = nan(nChs,nCorr,2*maxLag + 1);
tStart = tic;
for iTrial = 1:nCorr
    fprintf('%i-%i\n',iTrial,nCorr) 
    for iCh = 1:nChs
        rCorrCorr(iCh,iTrial,:) = xcorr(squeeze(repCorrCorrMean(iCh,iTrial,:)),squeeze(corrEpochs(iCh,iTrial,:)),maxLag); 
        rCorrIncorr(iCh,iTrial,:) = xcorr(squeeze(repCorrIncorrMean(iCh,iTrial,:)),squeeze(corrEpochs(iCh,iTrial,:)),maxLag);
    end
end
tCorr = toc(tStart);

% Compare mean waveforms with incorrect epochs
rIncorrCorr = nan(nChs,nError,2*maxLag + 1);
rIncorrIncorr = nan(nChs,nError,2*maxLag + 1);
tStart = tic;
for iTrial = 1:nError
    fprintf('%i-%i\n',iTrial,nError) 
    for iCh = 1:nChs
        rIncorrCorr(iCh,iTrial,:) = xcorr(squeeze(repErrCorrMean(iCh,iTrial,:)),squeeze(incorrEpochs(iCh,iTrial,:)),maxLag); 
        rIncorrIncorr(iCh,iTrial,:) = xcorr(squeeze(repErrIncorrMean(iCh,iTrial,:)),squeeze(incorrEpochs(iCh,iTrial,:)),maxLag);
    end
end
tError = toc(tStart); 

%rIncorrCorr     % correlations of incorrect epochs with correct mean
%rIncorrIncorr   % correlations of incorrect epochs with incorrect mean
%rCorrCorr       % correlations of correct epochs with correct mean
%rCorrIncorr     % correlations of correct epochs with incorrect mean

%% Mean values and std for epochs correlation
xVals = -maxLag:maxLag;                     % X values
rMeanIncorrCorr = mean(rIncorrCorr,3)';   	% correlations of incorrect epochs with correct mean
rStdIncorrCorr = std(rIncorrCorr,[],3)';   	% correlations of incorrect epochs with correct mean
rMeanIncorrIncorr = mean(rIncorrIncorr,3)'; % correlations of incorrect epochs with incorrect mean
rStdIncorrIncorr = std(rIncorrIncorr,[],3)';% correlations of incorrect epochs with incorrect mean

rMeanCorrCorr  = mean(rCorrCorr,3)';        % correlations of correct epochs with correct mean
rStdCorrCorr  = std(rCorrCorr,[],3)';       % correlations of correct epochs with correct mean
rMeanCorrIncorr = mean(rCorrIncorr,3)';     % correlations of correct epochs with incorrect mean
rStdCorrIncorr = std(rCorrIncorr,[],3)';    % correlations of correct epochs with incorrect mean

%% Finding the if max. values are centered with zero lag
$ check if max val between -10 +10 belongs to what trace, that one wins! That's it

[valIncorrCorr,indxIncorrCorr]      = (max(rIncorrCorr,[],3));     % correlations of incorrect epochs with correct mean
[valIncorrIncorr,indxIncorrIncorr]  = (max(rIncorrIncorr,[],3));   % correlations of incorrect epochs with incorrect mean
[valCorrCorr,indxCorrCorr]          = (max(rCorrCorr,[],3));       % correlations of correct epochs with correct mean
[valCorrIncorr,indxCorrIncorr]      = (max(rCorrIncorr,[],3));     % correlations of correct epochs with incorrect mean

nanmean(indxCorrCorr(32:64,:),1)
nanmean(indxCorrCorr(32:64,:),1)
nanmean(indxIncorrCorr(32:64,:),1)

%% Velocities of correlation coefficients per epoch
rDiffIncorrCorr = diff(rIncorrCorr,1,3);        % diff of correlations of incorrect epochs with correct mean
rDiffIncorrIncorr = diff(rIncorrIncorr,1,3);    % diff of correlations of incorrect epochs with incorrect mean
rDiffCorrCorr = diff(rCorrCorr,1,3);            % diff of correlations of correct epochs with correct mean
rDiffCorrIncorr = diff(rCorrIncorr,1,3);        % diff of correlations of correct epochs with incorrect mean

%% Find transition in correlation coefficients from positive to negative
pos2negIncorrCorr   = nan(nChs,nError);
pos2negIncorrIncorr = nan(nChs,nError);
pos2negCorrCorr     = nan(nChs,nCorr);
pos2negCorrIncorr   = nan(nChs,nCorr);
decoderOutcm        = zeros(nChs,nCorr+nError);          % decoder outcome. Here the selection is made. 1s for errors, 0s for correct

for iCh = 1:nChs
    % Correct epochs
    for iTrial = 1:nCorr
        pos2negCorrCorr(iCh,iTrial) = (rDiffCorrCorr(iCh,iTrial,maxLag - 20) > 0) && (rDiffCorrCorr(iCh,iTrial,maxLag + 20));
        pos2negCorrIncorr(iCh,iTrial) = (rDiffCorrIncorr(iCh,iTrial,maxLag - 20) > 0) && (rDiffCorrIncorr(iCh,iTrial,maxLag + 20) < 0);
        % Decoder Outcome
        if pos2negCorrCorr(iCh,iTrial) && ~pos2negCorrIncorr(iCh,iTrial)
            % IF CORRECT, 5
            decoderOutcm(iCh,iTrial) =  5;
            %             else
            %                 decoderOutcm(iCh,iTrial) =  1000;
            %             end
            %         elseif pos2negCorrIncorr(iCh,iTrial)
            %             decoderOutcm(iCh,iTrial) =  1;
        end
    end
    % Incorrect epochs
    for iTrial = 1:nError
        pos2negIncorrCorr(iCh,iTrial) = (rDiffIncorrCorr(iCh,iTrial,maxLag - 20) > 0) && (rDiffIncorrCorr(iCh,iTrial,maxLag + 20));
        pos2negIncorrIncorr(iCh,iTrial) = (rDiffIncorrIncorr(iCh,iTrial,maxLag - 20) > 0) && (rDiffIncorrIncorr(iCh,iTrial,maxLag + 20) < 0);
        % Decoder Outcome
        if pos2negIncorrIncorr(iCh,iTrial) %&& ~pos2negIncorrCorr(iCh,iTrial)
            % IF INCORRECT, 10
            decoderOutcm(iCh,iTrial+nCorr) = 10;
                %             else
                %                 decoderOutcm(iCh,iTrial+nCorr) = 10000;
                %             end
                %         elseif pos2negIncorrCorr(iCh,iTrial)
                %             decoderOutcm(iCh,iTrial+nCorr) = 0;
        end
    end
end

loco = decoderOutcm(41,:);  sum(loco == 5)/nCorr*100
loco = decoderOutcm(45,:);  sum(loco == 10)/nError*100

for iCh = 1:nChs, loco = decoderOutcm(iCh,:); 
    decCorrIncorr(iCh,1) = sum(loco == 5)/nCorr*100; 
    decCorrIncorr(iCh,2) = sum(loco ==10)/nError*100; 
    
    corrBeingCorr(iCh) = sum(loco(1:nCorr) == 5)/nCorr*100;
    incorrBeingCorr(iCh) = sum(loco(1:nCorr) == 10)/nCorr*100;
    corrBeingIncorr(iCh) = sum(loco(nCorr+1:end) == 5)/nCorr*100;
    incorrBeingIncorr(iCh) = sum(loco(nCorr+1:end) == 10)/nCorr*100;
end
figure, plot(decCorrIncorr), legend('Corr','Incorr')

figure, hold on
plot(corrBeingCorr,'r')
plot(incorrBeingCorr,'b')
plot(corrBeingIncorr,'g')
plot(incorrBeingIncorr,'k')





% All trials and channels
hFig = figure;
subplot(3,2,1), imagesc(pos2negCorrCorr),title('corr.corr','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)
subplot(3,2,3), imagesc(pos2negCorrIncorr),title('corr.incorr','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)
subplot(3,2,2), imagesc(pos2negIncorrCorr),title('incorr.corr','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)
subplot(3,2,4), imagesc(pos2negIncorrIncorr),title('incorr.incorr','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)
subplot(3,2,5), imagesc(pos2negCorrCorr.*~pos2negCorrIncorr),
title('Corr.(corr*~incorr)','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)
subplot(3,2,6), imagesc(pos2negIncorrIncorr.*~pos2negIncorrCorr),
title('Incorr.(inccorr*~corr)','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trials','FontWeight',plotParams.axisFontWeight); ylabel('Channels','FontWeight',plotParams.axisFontWeight)

% Sum of trials, all channels
hFig = figure;     
subplot(2,1,1)                          % what channel got more correct epochs correct!
hhPlot(1) = plot(sum(pos2negCorrCorr,2),'b','lineWidth',plotParams.lineWidth); hold on
hhPlot(2) = plot(sum(pos2negCorrIncorr,2),'r','lineWidth',plotParams.lineWidth); hold on
xlabel('Channel number','FontWeight',plotParams.axisFontWeight); ylabel('No. trials selected','FontWeight',plotParams.axisFontWeight)
set(gca,'FontSize',plotParams.axisFontSize+3)
title(sprintf('%s Sum all epochs Correct epochs correlation',session),'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
legend(hhPlot,{'Correct epochs labeled correct','Correct epochs labeled incorrect'})
subplot(2,1,2)                          % what channel got more incorrect epochs correct!
hhPlot(1) = plot(sum(pos2negIncorrCorr,2),'b','lineWidth',plotParams.lineWidth);  hold on
hhPlot(2) = plot(sum(pos2negIncorrIncorr,2),'r','lineWidth',plotParams.lineWidth);
title('Sum all epochs Incorrect epochs correlation','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Channel number','FontWeight',plotParams.axisFontWeight); ylabel('No. trials selected','FontWeight',plotParams.axisFontWeight)
set(gca,'FontSize',plotParams.axisFontSize+3)
legend(hhPlot,{'Incorrect epochs labeled correct','Incorrect epochs labeled incorrect'})

% Sum of channels, all channels
hFig = figure;     
subplot(2,1,1)                          % what channel got more correct epochs correct!
hhPlot(1) = plot(sum(pos2negCorrCorr,1),'b','lineWidth',plotParams.lineWidth-1); hold on
hhPlot(2) = plot(sum(pos2negCorrIncorr,1),'r','lineWidth',plotParams.lineWidth-1); hold on
xlabel('Trial','FontWeight',plotParams.axisFontWeight); ylabel('No. channels selected','FontWeight',plotParams.axisFontWeight)
set(gca,'FontSize',plotParams.axisFontSize+3)
title('Sum all channels Correct epochs correlation','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
legend(hhPlot,{'Correct epochs labeled correct','Correct epochs labeled incorrect'})
subplot(2,1,2)                          % what channel got more incorrect epochs correct!
hhPlot(1) = plot(sum(pos2negIncorrCorr,1),'b','lineWidth',plotParams.lineWidth-1);  hold on
hhPlot(2) = plot(sum(pos2negIncorrIncorr,1),'r','lineWidth',plotParams.lineWidth-1);
title('Sum all channels Incorrect epochs correlation','FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
xlabel('Trial','FontWeight',plotParams.axisFontWeight); ylabel('No. channels selected','FontWeight',plotParams.axisFontWeight)
set(gca,'FontSize',plotParams.axisFontSize+3)
legend(hhPlot,{'Incorrect epochs labeled correct','Incorrect epochs labeled incorrect'})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;layoutInfo = layout(1,test);

% Plotting params
plotParams.nXtick = 6;
plotParams.axisFontSize = 7;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 12;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 1.5;
plotParams.lineStyle = '-';
% Colors 
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);   % 32 different colors
XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.lenEpoch-0)/plotParams.nXtick:ErrorInfo.epochInfo.lenEpoch);
arrayLoc = ErrorInfo.plotInfo.arrayLoc;

% Signals used to extract epochs plotted here
switch ErrorInfo.epochInfo.typeRef
    case 'lfp',     strgRef = '';
    case 'lapla',   strgRef = 'lapla-';
    case 'car',     strgRef = 'car';        stop
end
% Identifier used in saveFilename and in Figure name
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

%% Plotting each epoch's cor  relation
% (Corr) Plotting each epoch correlation (with corr/incorr) for Corr trials
hPlot = nan(ErrorInfo.epochInfo.nChs,2);hFig = nan(length(arrayLoc),1);
for ii = 1:length(arrayLoc)
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s correlation corr epochs to corr/incorr values for %s array %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
    for iTrial = 1:nCorr
        fprintf('%i-%i\n',iTrial,nCorr);
        for iCh = 1+(ii-1)*32:(ii)*32
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
            hPlot(ii,1) = plot(detrend(rCorrCorr(iCh,iTrial,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
            hold on
            hPlot(ii,2) = plot(detrend(rCorrIncorr(iCh,iTrial,:)),'r','lineWidth',plotParams.lineWidth);                 % plot incorrect epochs
            axis tight
            hold off
        end
        pause
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'corr-epoch2Correct','corr-epoch2Error'},0)
    axis off                                                                % remove axis and background
    % Save
    saveFilename = sprintf('%s_correlation-CorrEpochs-2-corrIncorr-%s.fig',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    close figure(hFig(ii))
end
clear hFig hPlot legPlots

% (Incorr) Plotting each epoch correlation (with corr/incorr) for Incorr trials
hPlot = nan(ErrorInfo.epochInfo.nChs,2);hFig = nan(length(arrayLoc),1);
for ii = 1:length(arrayLoc)
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s correlation incorr epochs to corr/incorr values for %s array %s',ErrorInfo.session,arrayLoc{ii},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visiblePlot);
    for iTrial = 1:nError
        fprintf('%i-%i\n',iTrial,nError);
        for iCh = 1+(ii-1)*32:(ii)*32
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
            hPlot(ii,1) = plot(detrend(rIncorrCorr(iCh,iTrial,:)),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
            hold on
            hPlot(ii,2) = plot(detrend(rIncorrIncorr(iCh,iTrial,:)),'r','lineWidth',plotParams.lineWidth);                 % plot incorrect epochs
            axis tight
            hold off
        end
        pause
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'incorr-epoch2Correct','incorr-epoch2Error'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    saveFilename = sprintf('%s_correlation-IncorrEpochs-2-corrIncorr-%s.fig',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    close figure(hFig(ii))
end
clear hFig hPlot legPlots

%% Error bars mean and std
% Plot mean and std correlation of correct epochs to corr/incorr mean traces, for each array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s Compared Correct Epochs to corr and incorr mean and std for %s',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hold on
        % Plot error bars
        plotParams.plotColors(1,:) = [0 0 1];
        [plotErrCorr]   = plotErrorBars(xVals,rMeanCorrCorr(iCh,:),rMeanCorrCorr(iCh,:)-rStdCorrCorr(iCh,:),rMeanCorrCorr(iCh,:)+rStdCorrCorr(iCh,:),plotParams);               % Blue for correct epochs
        plotParams.plotColors(1,:) = [1 0 0];
        [plotErrIncorr] = plotErrorBars(xVals,rMeanCorrIncorr(iCh,:),rMeanCorrIncorr(iCh,:)-rStdCorrIncorr(iCh,:),rMeanCorrIncorr(iCh,:)+rStdCorrIncorr(iCh,:),plotParams);     % Red for correct epochs
        axis tight;
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'meanCorrEp-2-Correct','meanCorrEp-2-Error'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    saveFilename = sprintf('%s_meanCorrelation-CorrEpochs-2-corrIncorr-%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    close figure(hFig(ii))
end
clear hFig hPlot legPlots
% Plot mean and std correlation of incorrect epochs to corr/incorr mean traces, for each array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s Compared Incorrect Epochs to corr and incorr mean and std for %s',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hold on
        % Plot error bars
        plotParams.plotColors(1,:) = [0 0 1];
        [plotErrCorr]   = plotErrorBars(xVals,rMeanIncorrCorr(iCh,:),rMeanIncorrCorr(iCh,:)-rStdIncorrCorr(iCh,:),rMeanIncorrCorr(iCh,:)+rStdIncorrCorr(iCh,:),plotParams);               % Blue for correct epochs
        plotParams.plotColors(1,:) = [1 0 0];
        [plotErrIncorr] = plotErrorBars(xVals,rMeanIncorrIncorr(iCh,:),rMeanIncorrIncorr(iCh,:)-rStdIncorrIncorr(iCh,:),rMeanIncorrIncorr(iCh,:)+rStdIncorrIncorr(iCh,:),plotParams);     % Red for correct epochs
        axis tight;
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'meanIncorrEp-2-Correct','meanIncorrEp-2-Error'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    saveFilename = sprintf('%s_meanCorrelation-IncorrEpochs-2-corrIncorr-%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    %close figure(hFig(ii))
end
clear hFig hPlot legPlots

%% Error bars mean and std
% Plot correlation of correct and incorrect epochs to Corr mean and std for each array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s Compared Correct and Incorrect Epochs to Corr mean and std for %s',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hold on
        % Plot error bars
        plotParams.plotColors(1,:) = [0 0 1];
        [plotErrCorr]   = plotErrorBars(xVals,rMeanCorrCorr(iCh,:),rMeanCorrCorr(iCh,:)-rStdCorrCorr(iCh,:),rMeanCorrCorr(iCh,:)+rStdCorrCorr(iCh,:),plotParams);               % Blue for correct epochs
        plotParams.plotColors(1,:) = [1 0 0];
        [plotErrIncorr] = plotErrorBars(xVals,rMeanIncorrCorr(iCh,:),rMeanIncorrCorr(iCh,:)-rStdIncorrCorr(iCh,:),rMeanIncorrCorr(iCh,:)+rStdIncorrCorr(iCh,:),plotParams);     % Red for correct epochs
        axis tight;
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'meanCorrEp-2-Correct','meanIncorrEp-2-Correct'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    saveFilename = sprintf('%s_meanCorrelation-CorrIncorrEpochs-2-corr-%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    %close figure(hFig(ii))
end
clear hFig hPlot legPlots
% Plot correlation of correct and incorrect epochs to Incorr mean and std for each array
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s Compared Correct and Incorrect Epochs to Incorr mean and std for %s',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    for iCh = 1+(ii-1)*32:(ii)*32
        subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
        subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
        hold on
        % Plot error bars
        plotParams.plotColors(1,:) = [0 0 1];
        [plotErrCorr]   = plotErrorBars(xVals,rMeanCorrIncorr(iCh,:),rMeanCorrIncorr(iCh,:)-rStdCorrIncorr(iCh,:),rMeanCorrIncorr(iCh,:)+rStdCorrIncorr(iCh,:),plotParams);               % Blue for correct epochs
        plotParams.plotColors(1,:) = [1 0 0];
        [plotErrIncorr] = plotErrorBars(xVals,rMeanIncorrIncorr(iCh,:),rMeanIncorrIncorr(iCh,:)-rStdIncorrIncorr(iCh,:),rMeanIncorrIncorr(iCh,:)+rStdIncorrIncorr(iCh,:),plotParams);     % Red for correct epochs
        axis tight;
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'meanCorrEp-2-Error','meanIncorrEp-2-Error'},0)
    axis off                                                                % remove axis and background
    % Save figure
    saveFilename = sprintf('%s_meanCorrelation-CorrIncorrEpochs-2-Incorr-%s.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    %close figure(hFig(ii))
end
clear hFig hPlot legPlots

%% Plotting diff of correlation values of incorrect epochs with corr/incorr mean traces  
for ii = 1:3
    hFig(ii) = figure;
    set(hFig(ii),'PaperPositionMode','auto','Position',[1281 1 1280 948],...%[1 165 1600 784],...
        'name',sprintf('%s Compared diff. of correlation of incorrect epochs to corr./incorr. mean traces %s',ErrorInfo.session,arrayLoc{ii}),...
        'NumberTitle','off','visible',ErrorInfo.plotInfo.visiblePlot);
    for iTrial = 1:100%nError
        disp(iTrial)
        for iCh = 1+(ii-1)*32:(ii)*32
            subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
            subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
            hPlot(ii,1) = plot((squeeze(rDiffIncorrCorr(iCh,iTrial,:))),'b','lineWidth',plotParams.lineWidth);                   % plot Correct epochs
            hold on
            hPlot(ii,2) = plot((squeeze(rDiffIncorrIncorr(iCh,iTrial,:))),'r','lineWidth',plotParams.lineWidth);                 % plot incorrect epochs
            axis tight;
            hold off
        end
        pause
    end
    % legend
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    plotParams.errorColors = [0 0 1; 1 0 0];                                % Blue and red traces
    eBars(1) = plot(1,1,'b'); hold on, eBars(2) = plot(1,1,'r');
    subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
    legend(eBars,{'diffIncorrEp-2-Corr','diffIncorrEp-2-Incorr'},0)
    axis off                                                                % remove axis and background
    % Saving figures
    saveFilename = sprintf('%s_CorrelationVeloc-IncorrEpochs-2-corrIncorr-%s.fig',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),arrayLoc{ii});
    saveas(hFig(ii),saveFilename)
    %close figure(hFig(ii))
end
