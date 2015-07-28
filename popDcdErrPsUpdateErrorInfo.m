function ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,iArray,iBaseline,iPredFun,ipredType,iTrans,availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf,oldSession)
% function ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,iArray,iBaseline,iPredFun,ipredType,iTrans,availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf,oldSession)
%
% Updates all the params so they match the iterations
%
% INPUT
% ErrorInfo:        structure as called by 'setDefaultParams.m'
% iArray:           integer. Array iteration (1:7 for all possible combinations of the 3 arrays)
% iBaseline:        integer for baseline
% iPredFun:         integer to select function to extract predictors
% ipredType:        integer to select type of feature selection 
% iTrans:           integer to select type of data transformation
% availArrays:      cell. Has string of all 3 arrays: {'PFC','SEF','FEF'}
% arrayIndx         matrix [7 x 2]. All combinations of arrays = [1,1;2,2;3,3;1,2;1,3;2,3;4,4];
% rmvBaseline:      logical. True or false. True removes baseline from all epochs
% predFunction:     cell with only one element. The string inside {1}
%                   informs the function used to extract the predictors. 
%                   Can be mean of time windows, max and min of time windows, none. 
% predSelectType:   string. Function used to select predictors. It can be
%                   anova, none, ... 
% dataTransf:       string. Function to transform the covariates. Can be
%                   subtracting the mean, log, sqrt, sqr, z-score, none.
% oldSession:       string. Old session file, already trained, used to test current session.
% 
% OUTPUT
% ErrorInfo:        structure updated

% Author    : Andres
% 
% andres    : 1.1   : init. 13 March 2014

%% 
if ~(nargin < 13)
    ErrorInfo.decoder.oldSession    = oldSession;
    ErrorInfo.decoder.oldDecoder    = '';
    ErrorInfo.decoder.loadDecoder   = 1;            % load previously trained decoder
    ErrorInfo.decoder.trainDecoder  = 0;            % Only set to true if all the data from the oldSession is used to train the decoder.
    ErrorInfo.decoder.saveDecoder   = 0;            % decoder is already saved for oldSession
    ErrorInfo.decoder.typeVal       = 'alltest';
    if length(oldSession)>10
        
    end
end
    
%% Load default parameters
if iArray == 7, ErrorInfo.signalProcess.arrays     = {'PFC','FEF'};
else ErrorInfo.signalProcess.arrays    = {availArrays{:,arrayIndx(iArray,1):arrayIndx(iArray,2)}}; %#ok<CCAT1>
end
ErrorInfo.signalProcess.baselineDone   = 0;
ErrorInfo.epochInfo.rmvBaseDone        = 0;
ErrorInfo.epochInfo.rmvBaseline        = rmvBaseline(iBaseline);
ErrorInfo.featSelect.predFunction      = {predFunction{iPredFun}}; %#ok<CCAT1>
ErrorInfo.featSelect.predSelectType    = predSelectType{ipredType};
ErrorInfo.decoder.dataTransform        = dataTransf{iTrans};

%% Change vbles based on mainParams
switch ErrorInfo.featSelect.predFunction{1}
    case 'none'
        ErrorInfo.featSelect.numPredPerCh = ErrorInfo.signalProcess.epochLen;
        ErrorInfo.featSelect.predWindows  = [];
    case 'mean'
        ErrorInfo.featSelect.predWindows  = ...
            [50 100; ...  % was mainParams.decoder.predWindows
            100 150;...
            150 250;...
            250 350;...
            350 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        ErrorInfo.featSelect.numPredPerCh = size(ErrorInfo.featSelect.predWindows,1);
    case {'minMax','mean2'}
        ErrorInfo.featSelect.predWindows  = ...
            [25 75; ...  % was mainParams.decoder.predWindows
            75 150;...
            150 300;...
            300 600];       % ms. Boundaries of the time sections for the predictors, which mean values will be taken from
        ErrorInfo.featSelect.numPredPerCh = size(ErrorInfo.featSelect.predWindows,1);
    otherwise
        fprintf('Function %s not availabel!!...\n',ErrorInfo.featSelect.predFunction{1})
end
% Updating values to match featSelect.predWindows
% Signal processing
if ~isempty(ErrorInfo.featSelect.predWindows)
    if (ErrorInfo.signalProcess.dcdWindow(1,1) >= ErrorInfo.featSelect.predWindows(1,1))
        ErrorInfo.signalProcess.dcdWindow(1,1) = ErrorInfo.featSelect.predWindows(1,1);
        ErrorInfo.signalProcess.epochLen       = (ErrorInfo.signalProcess.dcdWindow(2) - ErrorInfo.signalProcess.dcdWindow(1));  % was mainParams.decoder.lenEpoch. % ms. Length of data used for decoding
    end
end

%% Display params for each
disp(ErrorInfo)

end