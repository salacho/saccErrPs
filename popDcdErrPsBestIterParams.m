function [maxParams,maxValIndx] = popDcdErrPsBestIterParams(ErrorInfos,dcdVals,iterParams,sessionList,popTxt)
% function [maxParams,maxValIndx] = popDcdErrPsBestIterParams(ErrorInfos,dcdVals,iterParams,sessionList,popTxt)
% 
% Runs analysis on a matrix of decoder performances using several different
% (iterated) parameters and selects the best parameters. 
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
% popTxt:             string. 'sessionsMean' or 'sessionsMedian'. Determines the 
%                     approach used to determine the best parameters
%
% OUTPUT
% maxParams:          cell{3x1}. Three strings stating the paramters that gave better decoder performance0 
% maxValIndx:         vector. Has the indices for the best parameters.  
%
% All this data can be found in a file saved with followin naming structure: 
% 'popFirstSession-lastSession-totalSessions-oldDecoder-eppochsParams-dcdPerf-IterParams.mat'
% i.e. 'popCS20120815-CS20130618-65-reg-cross10-[600-600ms]-[1.0-10Hz]-dcdPerf-IterParams.mat'
%
%
% Author    : Andres
%
% andres    : 1.1   : init. 18 March 2014
% andres    : 1.2   : added Jonah compatibility. 10 April 2014

if nargin < 5
    popTxt  = 'sessionsMean';
    %popTxt  = 'sessionsMedian';
end

switch lower(ErrorInfos{1}(1).session(1))                       % Only when seventh array combination (seven, sept, siete) is used
    case 'c', 
        [~,sessionsDcdPerf] = chicoBCIsessions(0,1);            % beforeSessions = 0; newOnly = 1;
        warning('Chico''s best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf.') %#ok<WNTAG>
        fprintf('Chico''s best iter. params dcd. perf. is for SEF, no RmvBaseline, mean Pred.Func., no Pred. Select., zScore dataTranf!!!\n') %#ok<WNTAG>
        disp('Getting best iter params for Chico!!')
    case 'j', 
        [~,sessionsDcdPerf] = jonahBCIsessions;
        warning('Jonah''s best iter. params dcd. perf. is for FEF & PFC, non RmvBaseline, mean Pred.Func., no Pred. Select., no dataTransf.');   %#ok<*WNTAG>
        fprintf('Jonah''s best iter. params dcd. perf. is for FEF & PFC, non RmvBaseline, mean Pred.Func., no Pred. Select., no dataTransf!!!\n');
end

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
    [maxDataTransf,indxDataTransf]  = nanmax(popVals,[],5);
    [maxPredSelect,indxPredSelect]  = nanmax(maxDataTransf,[],4);
    [maxPredFun,indxPredFun]        = nanmax(maxPredSelect,[],3);
    [maxRmvBase,indxRmvBase]        = nanmax(maxPredFun,[],2);
    [maxArrayVal,indxArrayIndx]     = nanmax(maxRmvBase);
    
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
            maxParams{iVal} = sprintf('Max.dcd.perf: %0.3f. %s: %s-array,%iBase,%s-predFun,%s-predSel,%s-dataTransf.',maxVal(iVal),...
                popVbleNames{iVal},cell2mat(arrays),iterParams.rmvBaseline(maxValIndx(iVal,2)),...
                iterParams.predFunction{maxValIndx(iVal,3)},iterParams.predSelectType{maxValIndx(iVal,4)},iterParams.dataTransf{maxValIndx(iVal,5)});
        
        else warning('BIG mistake!!! Error, values do not match!!');
        end
end

