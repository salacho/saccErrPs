function popPlotDcdErrPsIterParams(ErrorInfos,dcdVals,iterParams,sessionList)
% function popPlotDcdErrPsIterParams
%
%
%
%
%
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
% Author    : Andres
%
% andres    : 1.1   : init. 13 March 2014
% andres    : 1.2   : added saving features to have all the sessions and
%                     the name and order of the fields in dcdVals 
%

%% Plot params
plotParams.plotColors(1,:) = [26 150 65]/255;       % green
plotParams.plotColors(2,:) = [215 25 28]/255;       % red
plotParams.plotColors(3,:) = [0 0 0];

plotParams.nXtick = 6;
plotParams.axisFontSize = 14;
plotParams.axisFontWeight = 'Bold';
plotParams.titleFontSize = 17;
plotParams.titleFontWeight = 'Bold';
plotParams.Colors = [0 0 0; 1 0 0.2; 0.2 1 0];      % black, red, green
plotParams.lineWidth = 3;
plotParams.lineStyle = {'.',':','-.','-','*','--','o'};
plotParams.fontSz = 11;
plotParams.plotType = 'perOutcome'; %'3Dline'; %'perOutcome'; '3Dbar'; 
plotParams.yRange = [0.2 1];
plotParams.saveFig = 1;
plotParams.visible = 0;
plotParams.smallPlot = 0;

% saveErrorInfo.plotInfo.plotErrorBars = 0;
% ErrorCells = cell2mat(ErrorInfos);
% dcdCells = cell2mat(dcdErrors);
% ErrorCells(:,iArray,iBaseline,iPredFun,iPredType,iTrans).decoder.performance.meanCorrDcd
% meanCorr = [ErrorCells(:,iArray,iBaseline,iPredFun,iPredType,iTrans).decoder];


%% Dcd values
corrDcd = dcdVals{1};
errDcd  = dcdVals{2};
overDcd = dcdVals{3};
nSessions = size(corrDcd,1); %#ok<*NODEF>
xVals = 1:nSessions;

%% Plot the results
%session = sessionList{iSession};
dataTransZ = 1:length(iterParams.dataTransf);

% X-axis labels
kk = 0; nSessions = length(sessionList); iDown = 6; 
XtickPos = 1:iDown:nSessions;
XtickLabels = {};
for iSess = 1:iDown:nSessions
    kk = kk + 1;    session = sessionList{iSess};
    XtickLabels{kk} = session(5:end);
end

% To make smaller fontsize so plots look pretty
if plotParams.smallPlot, smallSz = 3; else smallSz = 0; end

for iBaseline = 1:length(iterParams.rmvBaseline)                   % Remove baseline
    for iPredFun = 1:length(iterParams.predFunction)               % pred function 'mean','minMax'
        for iPredType = 1:length(iterParams.predSelectType)        % pred. 'none','anova'
            for iTrans = 1:length(iterParams.dataTransf)           % data transf. 'log','sqr'
                close all
                hFig = figure; hold on
                legTxt = {}; legArray = {}; iterTxt = ''; 
                
                for iArray = 1:length(iterParams.arrayIndx)                            % Arrays used for decoding
                    %% Values to plot
                    %                     meanCorrDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanCorrDcd];
                    %                     meanErrorDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanErrorDcd];
                    %                     meanOverallDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanOverallDcd];
                    meanCorrDcd     = corrDcd(:,iArray,iBaseline,iPredFun,iPredType,iTrans);
                    meanErrorDcd    = errDcd(:,iArray,iBaseline,iPredFun,iPredType,iTrans);
                    meanOverallDcd  = overDcd(:,iArray,iBaseline,iPredFun,iPredType,iTrans);
                    
                    %% Arrays sorted
                    if iArray == 7
                        arrays = {'PFC','FEF'};
                    else
                        arrays = {iterParams.availArrays{:,iterParams.arrayIndx(iArray,1):iterParams.arrayIndx(iArray,2)}}; %#ok<CCAT1>
                    end
                    
                    %% Type of plot
                    switch plotParams.plotType
                        case 'perOutcome'
                            %% Plotting values for each outcome
                            subplot(1,3,1), hold on
                            hPlot(iArray,1) = plot(xVals,meanCorrDcd,'color',plotParams.plotColors(1,:),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                            subplot(1,3,2), hold on
                            hPlot(iArray,2) = plot(xVals,meanErrorDcd,'color',plotParams.plotColors(2,:),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                            subplot(1,3,3), hold on
                            hPlot(iArray,3) = plot(xVals,meanOverallDcd,'color',plotParams.plotColors(3,:),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                            
                            %% Array legend
                            legArray{(iArray-1)*3 + 1} = cell2mat(arrays);
                            legArray{(iArray-1)*3 + 2} = cell2mat(arrays);
                            legArray{(iArray-1)*3 + 3} = cell2mat(arrays);
                            
                            %% Legend root (without array list)
                            iterTxt = sprintf('%s-%iBase-%sFun-%sFeat-%sTrans',cell2mat(arrays),iterParams.rmvBaseline(iBaseline),...
                                iterParams.predFunction{iPredFun},iterParams.predSelectType{iPredType},iterParams.dataTransf{iTrans});
                            
                            %% Complete legend
                            legTxt{(iArray-1)*3 + 1} = sprintf('%s-%s','Corr',iterTxt);
                            legTxt{(iArray-1)*3 + 2} = sprintf('%s-%s','Error',iterTxt);
                            legTxt{(iArray-1)*3 + 3} = sprintf('%s-%s','Overall',iterTxt);
                            
                        case '3Dbar'
                            % Plotting values for each outcome
                            datTransz = repmat(dataTransZ(iTrans),1,nSessions);
                            
                            subplot(1,3,1), hold on
                            hPlot = bar3(xVals,meanCorrDcd,datTransz);
                            set(hPlot,'facecolor',plotParams.plotColors(1,:));
                            subplot(1,3,2), hold on
                            hPlot = bar3(xVals,meanErrorDcd,datTransz);
                            set(hPlot,'facecolor',plotParams.plotColors(2,:));
                            subplot(1,3,3), hold on
                            hPlot = bar3(xVals,meanOverallDcd,datTransz);
                            set(hPlot,'facecolor',plotParams.plotColors(3,:)+0.1);
                            
                            legTxt{(iArray-1)*3 + iArray} = cell2mat([cell2mat(arrays),'-',iterParams.dataTransf(iTrans)]);
                            
                        case '3Dline'
                            %% Plotting values for each outcome
                            datTransz = repmat(dataTransZ(iTrans),1,nSessions);
                            
                            meanCorrDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanCorrDcd];
                            meanErrorDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanErrorDcd];
                            meanOverallDcd = [dcdVals(:,iArray,iBaseline,iPredFun,iPredType,iTrans).meanOverallDcd];
                            
                            subplot(1,3,1), hold on
                            hPlot(iArray,1,iTrans) = plot3(xVals,meanCorrDcd,datTransz,'color',plotParams.plotColors(1,:)*(iTrans/length(dataTransZ)),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                            subplot(1,3,2), hold on
                            hPlot(iArray,2,iTrans) = plot3(xVals,meanErrorDcd,datTransz,'color',plotParams.plotColors(2,:)*(iTrans/length(dataTransZ)),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                            subplot(1,3,3), hold on
                            hPlot(iArray,3,iTrans) = plot3(xVals,meanOverallDcd,datTransz,'color',plotParams.plotColors(3,:)+(iTrans/(length(dataTransZ)+1)),'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray}); %#ok<*AGROW>
                            
                            legTxt{(iArray-1)*(length(dataTransZ)) + iTrans} = cell2mat([cell2mat(arrays),'-',iterParams.dataTransf(iTrans)]);
                        otherwise
                            warning('That option of typePlot does not exist...yet...') %#ok<*WNTAG>
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%% FIGURE PROPERTIES %%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% Figure location
                if plotParams.visible, set(hFig,'PaperPositionMode','auto','Position',[14 141 2538 589],'visible','on')
                else set(hFig,'PaperPositionMode','auto','Position',[14 141 2538 589],'visible','off'), end
                
                %% IterParamsTxt
                iterTxt = sprintf('%iBase-%sFun-%sFeat-%sTrans',iterParams.rmvBaseline(iBaseline),...
                    iterParams.predFunction{iPredFun},iterParams.predSelectType{iPredType},iterParams.dataTransf{iTrans});
                
                %% Subplot properties and legend
                % Legend text
                XLabelTxt = {'Correct','Incorrect','Overall'};
                nSubplots = 3;
                hLeg = nan(1,nSubplots);
                for iSub = 1:nSubplots
                    subplot(1,3,iSub)
                    %% Legend Txt
                    switch plotParams.plotType
                        case 'perOutcome', hLeg(iSub) = legend(legArray{iSub:3:end},'location','southeast');
                            %legend(legTxt{iSub:3:end},'location','south')
                        case  {'3Dline', '3Dbar'}
                            if iSub ~= 2, hLeg(iSub) = legend(legTxt,'location','southeast');end
                    end
                    
                    %% Axis
                    xlabel(XLabelTxt{iSub},'FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
                    ylabel('Performance','FontSize',plotParams.axisFontSize + 3,'FontWeight','Bold')
                    axis tight;
                    ylim([plotParams.yRange(1) plotParams.yRange(2)]);
                    set(gca,'FontSize',plotParams.axisFontSize-2,'Xtick',XtickPos,'XtickLabel',XtickLabels)
                end
                % Legend fontsize
                set(hLeg,'FontSize',plotParams.axisFontSize-2);
                % Title
                subplot(1,3,2), title(iterTxt,'FontWeight',plotParams.axisFontWeight,'FontSize',plotParams.titleFontSize)
                
                %% Naming the plot
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
                    saveFilename = sprintf('%s-dcdPerf-%s.png',rootFilename,iterTxt);
                    saveas(hFig,saveFilename)
                end
                    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%% END OF FIGURE PROPERTIES %%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
    end
end

%% Getting median for each parametes 

