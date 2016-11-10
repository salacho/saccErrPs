function [Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo)
% function [Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo)
%
% Feature extraction and dimensionality reduction
%
% INPUT
%
% OUTPUT
%
%
% Author    : Andres
%
% andres    : 1.1   : initial

tStart = tic;

%% Params
nChs        = ErrorInfo.nChs;
nP          = ErrorInfo.featSelect.numPredPerCh*nChs;                   % total number of predictors
nCorr       = ErrorInfo.epochInfo.nCorr;                                % number correct trials
nError      = ErrorInfo.epochInfo.nError;                               % number incorrect trials
nTrials     = nCorr + nError;                                           % total number of trials
if isfield(ErrorInfo.featSelect,'predWindows')                          % as safeguard for predFunction = 'none'
    predWindows = ErrorInfo.featSelect.predWindows/1000;                % predictor windows in seconds
    nWindows    = length(predWindows);
end
Fs          = ErrorInfo.epochInfo.Fs;

%% Initialize values
dataMatrix  = nan(nTrials,nP);
predList    = [1:nChs:nP; (1:nChs:nP) + (nChs - 1)];                    % predictor start and end index per predWindow
Yvals       = [false(nCorr,1); true(nError,1)];                         % if predictor is correct or incorrect
ErrorInfo.featSelect.nP = nP;

%% Extract features
switch ErrorInfo.featSelect.predFunction{1}
    % Getting mean values for sections of waveforms
    case 'none'         %not enough RAM 
        dataMatrix  = reshape(permute([corrEpochs,incorrEpochs],[2 3 1]),[nTrials,nChs*ErrorInfo.epochInfo.epochLen]);       % nChs x nTrials
        warning('Problems with preFunction = ''none'' and ''anova''!!!...The problema is dataMatrix not being nTrials x nCov, has nChs x nTrials x nCovPerCh...')
    case {'mean','mean2'}
        for iPreX = 1:nWindows
            dataMatrix(:,predList(1,iPreX):predList(2,iPreX)) = ...
                [mean(corrEpochs(:,:,round(predWindows(iPreX,1)*Fs):round(predWindows(iPreX,2)*Fs)),3)';...       % nChs x nTrials
                mean(incorrEpochs(:,:,round(predWindows(iPreX,1)*Fs):round(predWindows(iPreX,2)*Fs)),3)'];        % nChs x nTrials
        end
    case 'minMax'
        evalFuns = {'min','max','min','max'};
        for iPreX = 1:nWindows
            corrVals    = corrEpochs(:,:,round(predWindows(iPreX,1)*Fs):round(predWindows(iPreX,2)*Fs));
            incorrVals  = incorrEpochs(:,:,round(predWindows(iPreX,1)*Fs):round(predWindows(iPreX,2)*Fs));
            dataMatrix(:,predList(1,iPreX):predList(2,iPreX)) = ...
                ([eval(sprintf('%s(corrVals,[],3)',evalFuns{iPreX}))';...       % nChs x nTrials
                eval(sprintf('%s(incorrVals,[],3)',evalFuns{iPreX}))']);        % nChs x nTrials
        end
    otherwise
        warning('This feature extraction approach is not available. Come back later!')
end

%% Spike features
if ErrorInfo.spikeInfo.useChnlsWithUnitsOnly
   warning('Remove channels that do not have units!!!')     
end
    
%% Select features
switch ErrorInfo.featSelect.predSelectType
    % ANOVA analysis
    case 'none'
        Xvals = dataMatrix;
        predictorsToUse = 1:nP;
    case 'anova'
        warning('Problems with preFunction = ''none'' and ''anova''!!!...\n')
        pVals = myANOVA1(dataMatrix,Yvals,1);
        predictorsToUse = (pVals <= ErrorInfo.featSelect.predSelectCrit);
        Xvals = dataMatrix(:,predictorsToUse);
    case 'pca'
        tic
        coeff = pca(dataMatrix);
        toc
    otherwise
        warning('Selection type currently not available...')            %#ok<*WNTAG>
end
nP = size(Xvals,2);                                                     % Updating nuber of predictors

%% Permute trials to mix correct and incorrect trials to avoid biasing analysis (-Anyhow, it will be biased towards correct trials since, in average, we have more correct trials per session-)
if ErrorInfo.featSelect.doPerm
    permTrials = randperm(nTrials);
    Xvals = Xvals(permTrials,:);
    ErrorInfo.featSelect.Yvals = Yvals(permTrials);
    ErrorInfo.featSelect.trialsPerm = 1;                    % True when trials were permuted
    warning('Correct and incorrect trials have been permutted...')
end

%% Saving vbles in ErrorInfo structure
ErrorInfo.featSelect.nP = nP;
ErrorInfo.featSelect.predictorsToUse = predictorsToUse;                 % To point the channels and windows the predictors come from
ErrorInfo.featSelect.nTrials = nTrials;

fprintf('Feature reduction using %s function gave a total of %i predictors...\n',ErrorInfo.featSelect.predSelectType,ErrorInfo.featSelect.nP)

tEnd = toc(tStart);                                                     % time took to select features
fprintf('Feature selection took %2f seconds\n',tEnd)

