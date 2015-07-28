function popBoxPlotSessionsIterParams(ErrorInfos,dcdVals,iterParams,sessionList)
% function popBoxPlotSessionsIterParams(ErrorInfos,dcdVals,iterParams,sessionList)
%
% Gets boxplots with median in center and 25 and 75 percentils for the decoder 
% performance values for all the sessions
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
% andres    : 1.1   : init. 17 March 2014

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
plotParams.lineStyle = {'*',':','-.','-','--','.','o'};
plotParams.fontSz = 11;
%plotParams.plotType = 'perOutcome'; %'3Dline'; %'perOutcome'; '3Dbar'; 
plotParams.yRange = [0.7 1];
plotParams.saveFig = 1;
plotParams.visible = 1;
plotParams.smallPlot = 0;

%% Dcd values
corrDcd = dcdVals{1};
errDcd  = dcdVals{2};
overDcd = dcdVals{3};

% X-axis labels
kk = 0; nDataTrans = length(iterParams.dataTransf); iDown = 1; 
XtickPos = 1:6;
XtickLabels = {};
for iData= 1:iDown:nDataTrans
    kk = kk + 1;
    XtickLabels{kk} = iterParams.dataTransf{iData};
end
xVals = 1:nDataTrans;

for iBaseline = 1:length(iterParams.rmvBaseline)                   % Remove baseline
    for iPredType = 1:length(iterParams.predSelectType)        % pred. 'none','anova'
        close all
        hFig = figure; hold on
        legTxt = {}; legArray = {}; iterTxt = '';
        
        for iPredFun = 1:length(iterParams.predFunction)               % pred function 'mean','minMax'
            hPlot = nan(7,6,3);
            for iArray = 1:length(iterParams.arrayIndx)                            % Arrays used for decoding
                valsCorrDcd     = squeeze(corrDcd(:,iArray,iBaseline,iPredFun,iPredType,:));
                valsErrorDcd    = squeeze(errDcd(:,iArray,iBaseline,iPredFun,iPredType,:));
                valsOverallDcd  = squeeze(overDcd(:,iArray,iBaseline,iPredFun,iPredType,:));
                
                %% Arrays sorted
                if iArray == 7, arrays = {'PFC','FEF'};
                else arrays = {iterParams.availArrays{:,iterParams.arrayIndx(iArray,1):iterParams.arrayIndx(iArray,2)}}; %#ok<CCAT1>
                end
                
                %% Plotting values for each outcome
                subplot(4,3,(iArray-1)*3 + 1), hold on
                hPlot(:,:,1) = boxplot(valsCorrDcd);%,'color',plotParams.Colors(iPredFun,:));%,'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                subplot(4,3,(iArray-1)*3 + 2), hold on
                hPlot(:,:,2) = boxplot(valsErrorDcd);%,'color',plotParams.Colors(iPredFun,:));%,'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});
                subplot(4,3,(iArray-1)*3 + 3), hold on
                hPlot(:,:,3) = boxplot(valsOverallDcd);%,'color',plotParams.Colors(iPredFun,:));%,'lineWidth',plotParams.lineWidth,'lineStyle',plotParams.lineStyle{iArray});

% FAILED !!!!                
%                 %% Array legend
%                 legArray{(iArray-1)*3 + (length(iterParams.predFunction)-1)*(iPredFun-1) + 1} = ...
%                     cell2mat([arrays,'-',iterParams.predFunction(iPredFun)]);
%                 
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% FIGURE PROPERTIES %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Figure location
        if plotParams.visible, set(hFig,'PaperPositionMode','auto','Position',[ 1355          57        1166         825],'visible','on')
        else set(hFig,'PaperPositionMode','auto','Position',[ 1355          57        1166         825],'visible','off'), end
        
        %% IterParamsTxt
        iterTxt = sprintf('%iBase-%sFeat',iterParams.rmvBaseline(iBaseline),iterParams.predSelectType{iPredType});
        
        %% Subplot properties and legend
        % Legend text
        XLabelTxt = {'Correct','Incorrect','Overall'};
        nSubplots = 3;
        hLeg = nan(1,nSubplots);
        for iSub = 1:nSubplots
            subplot(subplot(4,3,(iArray-1)*3 + iSub))
            %% Legend Txt
            switch plotParams.plotType
                case 'perOutcome', hLeg(iSub) = legend(legArray,'location','southeast');
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
            saveFilename = sprintf('%s-dcdPerf-[%0.1f-%0.1fYLim]-%s.png',rootFilename,plotParams.yRange,iterTxt);
            saveas(hFig,saveFilename)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% END OF FIGURE PROPERTIES %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

