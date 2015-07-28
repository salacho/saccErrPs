function popBestIterParams(ErrorInfos,dcdVals,iterParams,sessionList)
% function popBestIterParams(ErrorInfos,dcdVals,iterParams,sessionList)
%
% Runs analysis on a matrix of decoder perfromances using several different
% (iterated) parameters and selects the best parameters. Also plots values
% for each outcome as well as the online BCI saccade decoder performance.
%
% INPUT
% ErrorInfos:         cell [numSessions x 1]. with all the ErrorInfo structures for all the
%                     sessions analyzed
% dcdVals:            cell. Contains the correct, error and overal decoder
%                     performance for all the sessions and iterations of the params. 
%     dcdVals{1}:     meanCorrDcd. Decoder performance for all correct epochs 
%     dcdVals{2}:     meanErrorDcd. Decoder performance for all incorrect epochs
%     dcdVals{3}:     meanOverallDcd. Decoder performance for all epochs
%     dcdVals{4}:     cell with the name and order of the params used. 
%                     i.e. {'sessionList','arrayIndx','rmvBaseline','predFunction','predSelectType','dataTransf'};
% iterParams:         params used to get decoder performance, different
%                     dimensions. Each param is one dim in dcdVals
%     arrayIndx:      matrix. [numOptions x 2]. Has the start and end array used for analysis. [1,1;2,2;1,2;1,3];        % (AFSG-20140313) was arrayIndx = [1,1;2,2;3,3;1,2;1,3;2,3;4,4];
%     availArrays:    cell. Strings with the names of the arrays. {'PFC','SEF','FEF'};              
% 	  rmvBaseline:    logical. Remove baseline from each trial?. [true, false];
% 	  predFunction:   cell. String values for type of function (and time windows) used for getting the predictors. {'mean','mean2','minMax'};        
% 	  predSelectType: cell. String values for type of feature selection. {'none','anova'};
% 	  dataTransf:     cell. String values for data transformation. {'none','log','sqr','sqrt','mean','zscore'};
% sessionList:        cell. List of sessions used to extract the data in
%                     dcdVals and ErrorInfos.
%
% All this data can be found in a file saved with followin naming structure: 
% 'popFirstSession-lastSession-totalSessions-oldDecoder-eppochsParams-dcdPerf-IterParams.mat'
% i.e. 'popCS20120815-CS20130618-65-reg-cross10-[600-600ms]-[1.0-10Hz]-dcdPerf-IterParams.mat'
%
%
% Author    : Andres
%
% andres    : 1.1   : init. 18 March 2014

clear all, close all, clc, isTrain = 1;

% Paths
dirs = eegErrDirs;

% Load and set params
ErrorInfo = eegSetDefaultParams('allTrainSubjAllSess',dirs,isTrain);
disp(ErrorInfo)

load('F:\BCIchallengeNER2015\analyzed\popAnalysis\popAllSubjButOne-IterParams-none-oldDcd[600-600ms]-[1.0-10Hz].mat')


% LOSOV
for iSubj = 1:length(trainSubjects)
    for iDcd = 1:length(dcdType)
        for iAlpha = 1:length(alphaVals)                            % Play with thresholdAplha!!!
            for iBaseline = 1:length(rmvBaseline)                   % Remove or not baseline
                for iPredFun = 1:length(predFunction)               % pred function 'mean','minMax'
                    for iPredType = 1:length(predSelectType)        % pred. 'none','anova'
                        for iTrans = 1:length(dataTransf)           % data transf. 'none','log','sqr'
                            dcdPerfAUC(iSubj,iAlpha,iBaseline,iPredFun,iPredType,iTrans,iDcd) = popDcdPerf(iSubj,iAlpha,iBaseline,iPredFun,iPredType,iTrans,iDcd).performance.auc;
                            %[numSubj length(alphaVals) length(rmvBaseline) length(predFunction) length(predSelectType) length(dataTransf) length(dcdType)]
                        end
                    end
                end
            end
        end
    end
end


if sum(isnan(reshape(dcdPerfAUC,[16*7*2*3*3*6*2 1]))) ~= 0
    error('Nan values where they should not be!!')
else
meanSubjDcdPerf = squeeze(nanmean(dcdPerfAUC,1));
maxAlphaDcdPerf = nanmax(meanSubjDcdPerf,[],1);
maxBaselineDcdPerf = nanmax(maxAlphaDcdPerf,[],1);
maxPredFunctDcdPerf = nanmax(maxBaselineDcdPerf,[],1);


end

% ErrorInfo.decoder.typeVal = 'alltrain'; 
% ErrorInfo.session = sprintf('popAllSubjsPCAinfo-IterParams%s');
% saveFilename = [eegCreateFileForm(ErrorInfo.decoder,ErrorInfo,'popIterParams'),'.mat'];



$$$$$$$$$$$$$$$$$$$$$$
warning('Best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf.') %#ok<WNTAG>
fprintf('Best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf!!!\n') %#ok<WNTAG>

if nargins < 4
    popTxt  = 'sessionsMean';
end

[chicoSessionList,sessionsDcdPerf] = chicoBCIsessions;

%% Dcd values
corrDcd = dcdVals{1};
errDcd  = dcdVals{2};
overDcd = dcdVals{3};
paramsList = dcdVals{4};
nSessions = size(sessionList,1); %#ok<*NODEF>

% Session mean and median
switch popTxt
    case 'sessionsMean'
        popCorr     = squeeze(nanmean(corrDcd,1));
        popError    = squeeze(nanmean(errDcd,1));
        popOverall  = squeeze(nanmean(overDcd,1));
        stdCorr     = squeeze(nanstd(corrDcd,0,1));
        stdError    = squeeze(nanstd(errDcd,0,1));
        stdOverall  = squeeze(nanstd(overDcd,0,1));
    case 'sessionsMedian'
        popCorr     = squeeze(nanmedian(corrDcd,1));
        popError    = squeeze(nanmedian(errDcd,1));
        popOverall  = squeeze(nanmedian(overDcd,1));
end

popVbleNames = {'popCorr','popError','popOverall'};
maxValIndx = nan(3,length(paramsList)-1);

for iVal = 1:3
    % Get the values
    popVals = eval(popVbleNames{iVal});
    % Find indeces
    [maxDataTransf,indxDataTransf] = nanmax(popVals,[],5);
    [maxPredSelect,indxPredSelect] = nanmax(maxDataTransf,[],4);
    [maxPredFun,indxPredFun] = nanmax(maxPredSelect,[],3);
    [maxRmvBase,indxRmvBase] = nanmax(maxPredFun,[],2);
    [maxArrayVal,indxArrayIndx] = nanmax(maxRmvBase);
    
    maxIndxVal = popVals(indxArrayIndx,...
            indxRmvBase(indxArrayIndx),...
            indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx)),...
            indxPredSelect(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx))),...
            indxDataTransf(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx)),indxPredSelect(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx)))));
        
        if isequal(maxArrayVal,maxIndxVal)
            % Get all the info about best params config
            maxVal(iVal) = maxArrayVal;
            maxValIndx(iVal,:) = ...
                [indxArrayIndx,...
                indxRmvBase(indxArrayIndx),...
                indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx)),...
                indxPredSelect(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx))),...
                indxDataTransf(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx)),indxPredSelect(indxArrayIndx,indxRmvBase(indxArrayIndx),indxPredFun(indxArrayIndx,indxRmvBase(indxArrayIndx))))];
            arrays = {iterParams.availArrays{:,iterParams.arrayIndx(maxValIndx(iVal,1),1):iterParams.arrayIndx(maxValIndx(iVal,1),2)}}; %#ok<CCAT1>
            maxParams{iVal} = sprintf('Max.dcd.perf. %s: %s-array,%iBase,%s-predFun,%s-predSel,%s-dataTransf.',...
                popVbleNames{iVal},cell2mat(arrays),iterParams.rmvBaseline(maxValIndx(iVal,2)),...
                iterParams.predFunction{maxValIndx(iVal,3)},iterParams.predSelectType{maxValIndx(iVal,4)},iterParams.dataTransf{maxValIndx(iVal,5)});
            
        else warning('BIG mistake!!! Error, values do not match!!');
        end
end

%% Plotting best params
% Plot params
plotParams.yRange           = [0.6 1];
plotParams.lineWidth        = 3;
plotParams.axisFontSize     = 14;
plotParams.axisFontWeight   = 'Bold';
plotParams.titleFontSize    = 17;
plotParams.titleFontWeight  = 'Bold';
% plotParams.Colors = [0 0 0; 1 0 0.2; 0.2 1 0];      % black, red, green
% plotParams.fontSz = 11;
% %plotParams.plotType = 'perOutcome'; %'3Dline'; %'perOutcome'; '3Dbar'; 
plotParams.plotColors(1,:)  = [26 150 65]/255;       % green
plotParams.plotColors(2,:)  = [215 25 28]/255;       % red
plotParams.plotColors(3,:)  = [0 0 0];
plotParams.dcdPerf = 1;
plotParams.saveFig = 1;
plotParams.visible = 0;

% X-axis labels
kk = 0; nSessions = length(sessionList); iDown = 6; 
XtickPos = 1:iDown:nSessions;
XtickLabels = {};
for iSess = 1:iDown:nSessions
    kk = kk + 1;    session = sessionList{iSess};
    XtickLabels{kk} = session(5:end);
end

% Y labels
nYTicks = 8;
YtickPos = round(100*linspace(plotParams.yRange(1),plotParams.yRange(2),nYTicks))/100;
bciYtickPos = round(100*linspace(0,1,nYTicks))/100;
for iYtick = 1:nYTicks
    YtickLabels{iYtick} = num2str(YtickPos(iYtick));
    bciYtickLabels{iYtick} = num2str(bciYtickPos(iYtick));
end

xVals = 1:nSessions;
dcdVbleNames = {'corrDcd','errDcd','overDcd'};
sessionBCIperf = sessionsDcdPerf/100;
hFig = figure; hold on

% Plot error detection and BCI decoder performance
for iVal = 1:3
    % Get the values
    popVals = eval(dcdVbleNames{iVal});
    %vals2plot = popVals(:,maxValIndx(iVal,1),maxValIndx(iVal,2),maxValIndx(iVal,3),maxValIndx(iVal,4),maxValIndx(iVal,5));
    vals2plot(iVal,:) = popVals(:,maxValIndx(1,1),maxValIndx(1,2),maxValIndx(1,3),maxValIndx(1,4),maxValIndx(1,5));
end

if plotParams.dcdPerf && isequal(length(sessionBCIperf),length(sessionList))
    [hAxes,hLine,hVals] = plotyy(xVals,sessionBCIperf,xVals,vals2plot);
    % Color to error detection
    for iVal = 1:3
        set(hVals(iVal),'color',plotParams.plotColors(iVal,:),'lineWidth',plotParams.lineWidth);
    end
    % Color to BCI dcd perf.
    set(hLine,'color','b','lineWidth',plotParams.lineWidth);
    % Legend and Axis
    legendTxt = {'saccBCI','Correct','Incorrect','Overall'};
    % Labels
    xlabel('Sessions [YYMMDD]','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylabel(hAxes(1),'BCI Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold');
    ylabel(hAxes(2),'Error Detection Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold');
    % Axis
	axis(hAxes,'tight')
    set(hAxes,'Xtick',XtickPos,'XtickLabel',XtickLabels)%,'XAxisLocation','Top')
    set(hAxes(1),'FontSize',plotParams.axisFontSize-2,'Ytick',bciYtickPos,'YtickLabel',bciYtickLabels,'box','off')%,'TickDir','out')
    set(hAxes(2),'FontSize',plotParams.axisFontSize-2,'Ytick',YtickPos,'YtickLabel',YtickLabels)
    ylim(hAxes(1),[0 1]);
    ylim(hAxes(2),[plotParams.yRange(1) plotParams.yRange(2)]);
    
else
    for iVal = 1:3
        hAxes(iVal,1) = plot(xVals,vals2plot,'color',plotParams.plotColors(iVal,:),'lineWidth',plotParams.lineWidth);
    end
    warning('Number of sessions with BCI decoder performance do not match!!!');
    legendTxt = {'Correct','Incorrect','Overall'};
    xlabel('Sessions [YYMMDD]','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylabel('Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
    ylim([plotParams.yRange(1) plotParams.yRange(2)]);
    set(gca,'FontSize',plotParams.axisFontSize-2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
    axis tight;
end

hLeg = legend(legendTxt,'location','southeast');
set(hFig,'PaperPositionMode','auto','Position',[1297 201 1260 546]);
% Legend fontsize
set(hLeg,'FontSize',plotParams.axisFontSize-2);
% Title
iterTxt = maxParams{1};
title(iterTxt(24:end),'FontWeight',plotParams.axisFontWeight,'FontSize',plotParams.titleFontSize)

%% Saving the file
% Naming the plot
ErrorInfo = ErrorInfos{1}; %#ok<*USENS>
decoder = ErrorInfo.decoder;

% Session for the population
if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{end},length(sessionList),ErrorInfo.decoder.oldSession);
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
end

%% Save Filename
if plotParams.saveFig
    rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 %#ok<*NASGU>
    saveFilename = sprintf('%s-dcdPerf-bestIterParams.png',rootFilename);
    saveas(hFig,saveFilename)
end

end

