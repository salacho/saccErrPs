function plotTgtDistanceEpochs(tgt2DistEpochs,corrEpochs,ErrorInfo)
% function plotTgtDistanceEpochs(tgt2DistEpochs,corrEpochs,ErrorInfo)
% 
% INPUT
% tgt2DistEpochs:           structure [1:numTargets].For each target it
%                           has the following fields:
%         dist2tgt          vector. All possible distances of incorrect targets to true location    
%         dcdTgtRange:      vector. Possible dcd targets given to this location (erroneous locations). 
%                           Possible values taken by dcd target for this true target location (iTgt)
%         numEpochsPerDist: integer. Number of epochs for each distance to true location
%         epochDist1:       matrix. [numChns numEpochs(for distance 1) numDataPoints]. 
%                           Error epochs with error at a distance 1 to the target location
%         epochDist2:       matrix. [numChns numEpochs(for distance 2) numDataPoints]. 
%                           Error epochs with error at a distance 2 to the target location
%         epochDist3:       matrix. [numChns numEpochs(for distance 3) numDataPoints]. 
%                           Error epochs with error at a distance 3 to the target location
%         dcdTgtDist1:      vector. Decoded targets for the error epochs with distance 1 to the target location
%         dcdTgtDist2:      vector. Decoded targets for the error epochs with distance 2 to the target location
%         dcdTgtDist3:      vector. Decoded targets for the error epochs with distance 3 to the target location
%         stdEpochDist1:    vector. Std of error epochs for distance 1 to target location
%         stdEpochDist2:    vector. Std of error epochs for distance 2 to target location
%         stdEpochDist3:    vector. Std of error epochs for distance 3 to target location
%         meanEpochDist1:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 1 to target location
%         meanEpochDist2:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 2 to target location
%         meanEpochDist3:   matrix. [numChannels numDatapoints]. Mean error epoch for distance 3 to target location
%
% corrEpochs:               matrix. Correct epochs in the form [numChs numEpochs lengthEpoch].
% incorrEpochs:             matrix. Incorrect epochs in the form [numChs numEpochs lengthEpoch].
%
% Andres v1.0
% Created: June 2013
% Last modified: 18 July 2013

disp('')
disp('Also average and STD of channels per array for distance to target for each target location')

%% Params
% Getting layout for array/channel distribution
test.NNs = 0; test.lapla = 0;
layoutInfo = layout(1,test);
% Arrays
arrayLoc = ErrorInfo.plotInfo.arrayLoc;
% Plotting params
plotParams.nXtick = 4; %(AFSG-20140304) 6;
plotParams.axisFontSize = 14; %(AFSG-20140304) 7;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 12;
plotParams.titleFontWeight = 'Bold';
plotParams.plotColors(1,:) = [0 0 1];
plotParams.lineWidth = 4% (AFSG-20140304) 1.5;
plotParams.lineStyle = '-';
% Axis
XtickLabels = -ErrorInfo.epochInfo.preOutcomeTime:(ErrorInfo.epochInfo.postOutcomeTime + ErrorInfo.epochInfo.preOutcomeTime)/plotParams.nXtick:ErrorInfo.epochInfo.postOutcomeTime;
XtickPos = (0:(ErrorInfo.epochInfo.epochLen-0)/plotParams.nXtick:ErrorInfo.epochInfo.epochLen);
% Analysis per target
Tgts = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);
% Colors for array, targets and distance
FigHand = figure; plotParams.Color = colormap; close(FigHand);
plotParams.Color = plotParams.Color(1:length(plotParams.Color)/32:end,:);                       % 32 different colors
FigHand = figure; plotParams.tgtColor = colormap; close(FigHand);
plotParams.tgtColor = plotParams.tgtColor(1:round(length(plotParams.tgtColor)/nTgts):end,:);    % 6 different colors
%plotParams.distColors = [0 0 0; 0 0 1; 1 0 0; 0 1 0];     %(black, blue, red, green)
%plotParams.distColors = [26 150 65;127 188 65; 253 141 60; 215 25 28]/255;   % [green, lime green, orange, red]
plotParams.distColors = [26 150 65;0 255 0; 253 141 60; 215 25 28]/255;   % [green, lime green, orange, red]

%plotParams.distColors = [0 0 0; ; 1 0 0]

% Type of signals used to get the epochs
switch ErrorInfo.epochInfo.typeRef
    case 'lfp'
        strgRef = '';
    case 'lapla'
        strgRef = 'lapla-';
    case 'car'
        strgRef = 'car';
end

% Create folders to save files Tgt figures
for iTgt = 1:nTgts
    if ~exist(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'),'dir')
        mkdir(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt'));
    end
end

% Using max and min values to get equal Y limits in the plots
if ErrorInfo.plotInfo.equalLimits, yLimTxt = 'equalY'; else yLimTxt = ''; end

xVals = 1:1:ErrorInfo.epochInfo.epochLen;           % x values for error bar lot

%% Plotting error potentials based on distance to true location per array/per channel
% Mean and std values for correct epochs
if 1==0
hFig = nan(nTgts, length(arrayLoc));

% Plot for each array
for jj = 1:length(arrayLoc)
    % Plot for each target
    for iTgt = 1:nTgts
        % Only when there are incorrect trials for target 'iTgt'
        if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
            fprintf('Plotting independently %s array...tgt%i dist2tgt...\n',arrayLoc{jj},iTgt)
            distVals = tgt2DistEpochs(iTgt).dist2tgt;   % List of distance of dcd target to true location
            
            % Figure properties
            hFig(iTgt,jj) = figure;
            set(hFig(iTgt,jj),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
                'name',sprintf('%s mean error - all distance to true location - tgt%i in %s array. %s',ErrorInfo.session,iTgt,arrayLoc{jj},yLimTxt),...
                'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
            % Correct mean and std values for each target
            corrIndx = (ErrorInfo.epochInfo.corrDcdTgt == iTgt);
            corrEpochTgt = squeeze(nanmean(corrEpochs(:,corrIndx,:),2));
            %stdEpochTgt = squeeze(std(corrEpochs(:,corrIndx,:),0,2));
            legendTxt = repmat('',[1,length(distVals)]);
            legendTxt{1} = 'Correct';                                           % legend for correct trials
            
            % Plotting mean vals per dist2tgt
            for iDist = 1:length(distVals)
                % Mean or error epochs
                iMeanDistTxt = sprintf('meanEpochDist%i',distVals(iDist));      % field meanEpoch
                meanIncorrEpoch = tgt2DistEpochs(iTgt).(iMeanDistTxt);          % mean error epoch for this distance to target location
                % Standard deviation of error epochs
                %stdDistTxt = sprintf('stdEpochDist%i',distVals(iDist));
                %stdEpoch = tgt2DistEpochs(iTgt).(stdDistTxt);                  % std of error epoch for this distance to target location
                legendTxt{1 + iDist} = sprintf('Dist %i',iDist);                % legend text
                
                % for each ch in the array
                for iCh = 1+(jj-1)*32:(jj)*32
                    subCh = mod(iCh - 1,32) + 1;                                        % channels from 1-32 per array
                    subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(subCh)) % subplot location using layout info
                    hold on,
                    if iDist == 1
                        hPlot(1,subCh) = plot(xVals,corrEpochTgt(iCh,:),'Color',plotParams.distColors(1,:),'LineWidth',plotParams.lineWidth);       %#ok<AGROW>
                    end
                    hPlot(iDist+1,subCh) = plot(xVals,meanIncorrEpoch(iCh,:),'Color',plotParams.distColors(iDist+1,:),'LineWidth',plotParams.lineWidth); %#ok<AGROW>
                    % Plot errorBars for all channels
                    %plotParams.plotColors(1,:) = [0 0 0];
                    %[plotErrCorr] = plotErrorBars(xVals,meanCorrEpoch(iCh,:),meanCorrEpoch(iCh,:)-stdCorrEpochs(iCh,:),meanCorrEpoch(iCh,:)+stdCorrEpochs(iCh,:),plotParams);               % Blue for correct epochs
                    %plotParams.plotColors(1,:) = plotParams.tgtColor(iTgt,:);
                    %[plotErrInCorr] = plotErrorBars(xVals,meanIncorrEpoch(iCh,:),meanIncorrEpoch(iCh,:)-stdEpoch(iCh,:),meanIncorrEpoch(iCh,:)+stdEpoch(iCh,:),plotParams);               % Blue for correct epochs
                    axis tight
                    if ErrorInfo.plotInfo.equalLimits
                         set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                             'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothChDist2tgt(iTgt,jj) ErrorInfo.plotInfo.equalLim.yMax.bothChDist2tgt(iTgt,jj)])
                    else
                        set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
                    end
                end
            end
            % legend
            subplot(layoutInfo.rows,layoutInfo.colms,1)                             % use subplot to place legend outside the graph
            legPlots = nan(length(distVals)+1,1);
            for kk = 1:length(distVals)+1, legPlots(kk) = plot(0,'Color',plotParams.distColors(kk,:),'LineWidth',plotParams.lineWidth-0.5); hold on, end;    % plot fake data to polace legends
            legend(legPlots,legendTxt,0,'FontSize',plotParams.axisFontSize+1,'FontWeight','Bold')                                            % Include legend
            axis off                                                                % remove axis and background
            
            clear lengendTxt hPlot legPlots
            % Saving figure
            if ErrorInfo.plotInfo.savePlot
                saveFilename = sprintf('%s-corrIncorr-tgt%i-meanEpochs-dist2tgt-%s-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,'perTgt',ErrorInfo.session),...
                    iTgt,arrayLoc{jj},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
                saveas(hFig(iTgt,jj),saveFilename)
            end
        else
            fprintf('No plots for target %i since no there are no trials\n',iTgt)
        end
    end
end
clear hFig hPlot legendTxt legPlots

%% Plotting mean of dist2tgt per array 
numRows = sum((ErrorInfo.epochInfo.nIncorrEpochsTgt ~= 0));                 % number of rows for plot
% Figure properties
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 1 1280 948],...
    'name',sprintf('%s mean chs distance to true location - tgt%i in all arrays. %s',ErrorInfo.session,iTgt,yLimTxt),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
TgtIndx = 0;                                                                % initial conditions used for subplot eval
yaxisTxt = 1:length(arrayLoc):length(arrayLoc)*nTgts;                     % Y axis txt vble

% Plot for each target
for iTgt = 1:nTgts
    % Only when there are incorrect trials for target 'iTgt'
    if ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt) ~= 0
        fprintf('Plotting for tgt%i mean chs dist2tgt for all arrays...\n',iTgt)
        distVals = tgt2DistEpochs(iTgt).dist2tgt;                           % List of distance of dcd target to true location
        TgtIndx = TgtIndx + 1;                                              % indexing of targets with incorrect trials
        
        % Correct mean and std values for each target
        corrIndx = (ErrorInfo.epochInfo.corrDcdTgt == iTgt);
        corrEpochTgt = squeeze(mean(corrEpochs(:,corrIndx,:),2));
        %stdEpochTgt = squeeze(std(corrEpochs(:,corrIndx,:),0,2));
        legendTxt = repmat('',[1,length(distVals)]);
        legendTxt{1} = 'Correct';                                           % legend for correct trials
        hPlot = nan(length(arrayLoc),nTgts,length(distVals));
        
        % Plotting mean vals per dist2tgt
        for iDist = 1:length(distVals)
            % Mean or error epochs
            iMeanDistTxt = sprintf('meanEpochDist%i',distVals(iDist));      % field meanEpoch
            meanIncorrEpoch = tgt2DistEpochs(iTgt).(iMeanDistTxt);          % mean error epoch for this distance to target location
            % legend text
            legendTxt{1 + iDist} = sprintf('Dist %i',iDist);
            
            % Get mean of chs for each array
            for jj = 1:length(arrayLoc)
                subplot(numRows,length(arrayLoc),jj + length(arrayLoc)*(TgtIndx - 1))
                if iDist == 1
                    hPlot(jj,TgtIndx,jj) = plot(xVals,mean(corrEpochTgt((1+(jj-1)*32:(jj)*32),:),1),'Color',plotParams.distColors(1,:),'LineWidth',plotParams.lineWidth);
                end
                hold on
                hPlot(jj,TgtIndx,iDist+1) = plot(xVals,mean(meanIncorrEpoch((1+(jj-1)*32:(jj)*32),:),1),'Color',plotParams.distColors(iDist+1,:),'LineWidth',plotParams.lineWidth);
                axis tight
                if ErrorInfo.plotInfo.equalLimits
                    set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                        'Ylim',[min(ErrorInfo.plotInfo.equalLim.yMin.bothMeanDist2tgt) max(ErrorInfo.plotInfo.equalLim.yMax.bothMeanDist2tgt)]) 
                else
                    set(gca,'FontSize',plotParams.axisFontSize,'Xtick',XtickPos,'XtickLabel',XtickLabels)
                end
                    % Array Area
                if TgtIndx == 1
                    title(sprintf('%s',arrayLoc{jj}),'FontSize',plotParams.titleFontSize,'FontWeight',plotParams.titleFontWeight)
                end
                % Target number in first row 
                if any((jj + length(arrayLoc)*(TgtIndx - 1) == yaxisTxt))
                    ylabel(sprintf('Tgt %i',iTgt),'FontSize',plotParams.titleFontSize - 1,'FontWeight',plotParams.axisFontWeight)
                end
            end
        end
    else
        fprintf('No incorrect trials for target %i',iTgt);
    end
    % Saving plots
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochs-meanChs-perTarget-dist2tgt-%s%s[%i-%ims]-[%0.1f-%iHz].png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(jj),saveFilename)
    end
end
clear hFig hPlot legendTxt legPlots
end

%% Plot mean and std for each array
% Six targets: color and spatial location (~degrees)
plotParams.TgtPlot.rows = 12;
plotParams.TgtPlot.colms = 12;
plotParams.TgtPlot.subplot = {57:60,7:10,3:6,49:52,99:102,103:106};         %{[3:6],[7:10],[49:52],[57:60],[99:102],[103:106]};
plotParams.targets = 1:length(ErrorInfo.epochInfo.Tgts);                    %all possible targets
plotParams.nTgts = length(plotParams.targets);
% Center subplot
tgtLoc = plotParams.TgtPlot.subplot{4};
tgtFirst = tgtLoc(end) + 1;
tgtLoc = plotParams.TgtPlot.subplot{1};
tgtLast = tgtLoc(1) - 1;
tgtLoc = (tgtFirst:tgtLast);
plotParams.TgtPlot.tgtCntr = [tgtLoc,tgtLoc + plotParams.TgtPlot.colms,tgtLoc + 2*plotParams.TgtPlot.colms,tgtLoc + 3*plotParams.TgtPlot.colms];

for jj = 1:length(arrayLoc)
    hFig(jj) = figure; 
    disp('...')
    set(hFig(jj),'PaperPositionMode','auto','Position',[1281 1 1280 948],...
        'name',sprintf('%s mean error - all distance to true location - 6Tgts in %s array. %s',ErrorInfo.session,arrayLoc{jj},yLimTxt),...
        'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    
    for iTgt = 1:ErrorInfo.epochInfo.nTgts
        fprintf('Plotting 6tgt layout %s array...tgt%i\n',arrayLoc{jj},iTgt)
        distVals = tgt2DistEpochs(iTgt).dist2tgt;                           % List of distance of dcd target to true location

        % Correct mean and std values for each target
        corrIndx = (ErrorInfo.epochInfo.corrDcdTgt == iTgt);
        corrEpochTgt = squeeze(mean(corrEpochs(:,corrIndx,:),2));
        %stdEpochTgt = squeeze(std(corrEpochs(:,corrIndx,:),[],2));
        
        % Each tgt
        getSubPlot(iTgt,plotParams), hold on                                % Get subplot location

        % Number of incorrect and correct trials per target location
        %(AFSG-20140304) title(sprintf('%ierr.%icorr',ErrorInfo.epochInfo.nIncorrEpochsTgt(iTgt),ErrorInfo.epochInfo.nCorrEpochsTgt(iTgt)),'FontSize',plotParams.axisFontSize+2,'color','b')
        legendTxt{1} = 'Correct';                                           % first legend text

        for iDist = 1:length(distVals)
            disp(distVals)
            % Mean or error epochs
            iMeanDistTxt = sprintf('meanEpochDist%i',distVals(iDist));      % field meanEpoch
            meanIncorrEpoch = tgt2DistEpochs(iTgt).(iMeanDistTxt);          % mean error epoch for this distance to target location
            % Standard deviation of error epochs
            %stdDistTxt = sprintf('stdEpochDist%i',distVals(iDist));
            %stdIncorrEpoch = tgt2DistEpochs(iTgt).(stdDistTxt);            % std of error epoch for this distance to target location
            
            % for each ch in the array
            if iDist == 1
                % plotParams.plotColors(1,:) = [0 0 1];
                % [plotErrCorr] = plotErrorBars(xVals,mean(corrEpochTgt((jj-1)*32+1:jj*32,:)),mean(corrEpochTgt((jj-1)*32+1:jj*32,:)-stdEpochTgt((jj-1)*32+1:jj*32,:)),mean(corrEpochTgt((jj-1)*32+1:jj*32,:)+stdEpochTgt((jj-1)*32+1:jj*32,:)),plotParams);               % Blue for correct epochs
                hPlot(1,iTgt) = plot(xVals,mean(corrEpochTgt((jj-1)*32+1:jj*32,:)),'Color',plotParams.distColors(1,:),'LineWidth',plotParams.lineWidth); %#ok<AGROW>
            end
            % Plot errorBars for all channels
            % plotParams.plotColors(1,:) = [1 0 0];
            % [plotErrInCorr] = plotErrorBars(xVals,mean(meanIncorrEpoch((jj-1)*32+1:jj*32,:)),mean(meanIncorrEpoch((jj-1)*32+1:jj*32,:)-stdEpoch((jj-1)*32+1:jj*32,:)),mean(meanIncorrEpoch((jj-1)*32+1:jj*32,:)+stdEpoch((jj-1)*32+1:jj*32,:)),plotParams);               % Blue for correct epochs
            hPlot(iDist+1,iTgt) = plot(xVals,mean(meanIncorrEpoch((jj-1)*32+1:jj*32,:)),'Color',plotParams.distColors(iDist+1,:),'LineWidth',plotParams.lineWidth); %#ok<AGROW>
            axis tight
            %% Only axis in bottom plots
            if (iTgt == 5) || (iTgt == 6)
                if ErrorInfo.plotInfo.equalLimits
                    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels,...
                        'Ylim',[ErrorInfo.plotInfo.equalLim.yMin.bothArrayMeanDist2tgt(jj) ErrorInfo.plotInfo.equalLim.yMax.bothArrayMeanDist2tgt(jj)])
                else
                    set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
                end
            else
                set(gca,'FontSize',plotParams.axisFontSize+2,'Xtick',[],'Ytick',[])
            end
        end
    end
    
    % Legends in center of 6 tgt plots
    subplot(plotParams.TgtPlot.rows,plotParams.TgtPlot.colms,plotParams.TgtPlot.tgtCntr); hold on,                 % use subplot to place legend outside the graph
    allDist = [unique([tgt2DistEpochs(:).dist2tgt])];                         % All possible dist2tgts
    for kk = 1:length(allDist)+1                                            % plotting dummy traces to add legends
        legPlots(kk) = plot(0,'Color',plotParams.distColors(kk,:),'LineWidth',plotParams.lineWidth-0.5); hold on
        if kk == 1
            legendTxt{kk} = 'Correct';                 % legend text
        else
            legendTxt{kk} = sprintf('Dist %i',allDist(kk-1));                 % legend text
        end
    end;                                                                    
    legend(legPlots,legendTxt,'location','Best','FontSize',plotParams.axisFontSize+3,'FontWeight','Bold')                                            % Include legend
    set(legend,'position',[0.47 0.47 0.1 0.1])                              % position normalized
    axis off
    
    clear lengendTxt hPlot
    % Saving plots
    if ErrorInfo.plotInfo.savePlot
        saveFilename = sprintf('%s-corrIncorr-meanEpochs-meanChs-dist2tgt-%s-%s%s[%i-%ims]-[%0.1f-%iHz]-iSLC2014.png',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
            arrayLoc{jj},strgRef,yLimTxt,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        saveas(hFig(jj),saveFilename)
    end
end

clear hPlot hFig legPlots
end         % function end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getSubPlot(iTgt,plotParams)
% function getSubPlot(iTgt,plotParams)
%
% Selects the subplot based on the target number (iTgt)
%
% Andres v1.0

tgtLoc = plotParams.TgtPlot.subplot{iTgt};
plotLoc = [tgtLoc,tgtLoc + plotParams.TgtPlot.colms,tgtLoc + 2*plotParams.TgtPlot.colms,tgtLoc + 3*plotParams.TgtPlot.colms];
subplot(plotParams.TgtPlot.rows,plotParams.TgtPlot.colms,plotLoc); hold on,

end
