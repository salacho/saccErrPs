function [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo)
% Must first ==process signal== and ==select predictors== 
% for now, for Presentation, all in this file
% 
% Decoder of ErrPs using different approaches
%
% INPUT
% Xvals:            matrix. Predictors for all correct and incorrect trials
%                   [numEpochs numPreditors] -> first all correct, then all incorrect.
% ErrorInfo:        structure. Has all the info regarding how the epochs were obtained.
%                   In ErrorInfo.featSelect.predictorsY
%
% OUTPUT
% decoder:          structure. It is basically the same structure in
%                   ErrorInfo but separated to use it in other functions
% Author    : Andres
%
%   andres    : 1.1 : xx Aug 2013. initial. 
%   andres    : 1.2 : 25 Nov 2013. Added denoising, baseline reduction, channel selection, and regression decoder (based on Scotts offlineBCI regression code)
%   andres    : 2.1 : 03 Dec 2013. Allowed loading previously trained decoder
%   andres    : 2.2 : 14 Jan 2014. Added a true cross-validation analysis not the previous cuasi-leave-one-out cross-validation code I had
%   andres    : 2.3 : 26 Feb 2014. Separated signal processing, feature extraction and selection from decoder code

decoder = ErrorInfo.decoder;

%% Main decoder parameters
crossValPerc    = decoder.crossValPerc;                         % Percentage of trials used to test decoder using cross-validation
nTrials         = length(ErrorInfo.featSelect.Yvals);           % Total number of trials
Yvals           = ErrorInfo.featSelect.Yvals;                   % True target values. zeros (0s) for correct trials, ones (1s) for error trials
trialsPerm      = ErrorInfo.featSelect.trialsPerm;              % logical. True if trials have already being permutted
decoder.nTrials = nTrials;

%% If new decoder is used
if ~decoder.loadDecoder
    switch lower(decoder.typeVal)                           % Leave-one-out validation, cross-validation or alltrain
        case 'alltrain'
            disp('All trials for training...')
            nTrain  = nTrials;
            nTest   = 0;
            nIter   = 1;
            decoder.saveDecoder = 1;
        case 'loov'
            disp('Running LOOV...')
            nTest   = nTrials - 1;
            nTrain  = 1;
        case 'crossval'                                     % Cross-correlation validation with several iterations
            % Training and testing trial numbers
            fprintf('Running %i cross-validation\n',crossValPerc)
            nIter   = floor(100/crossValPerc);
            nTest = floor(nTrials/nIter);                   % number testing trials per subset/iteration
            nTrain = nTrials - nTest;                       % number training trials per subset/iteration
            %             decoder.nTestTrialsPerIter = nTest;
            %             AFSG (2014-03-03)
            %             % Size of data subsets for cross-validation per iteration
            %             decoder.nCorrTrialPerIter = floor(decoder.nCorrTrials/nIter);       % number correct trials per subset
            %             decoder.nIncorrTrialPerIter = floor(decoder.nIncorrTrials/nIter);   % number incorrect trials per subset
    end
    % Updating vbles
    decoder.nTest   = nTest;
    decoder.nTrain  = nTrain;
    decoder.nIter 	= nIter;
    fprintf('Using a total of %i testing and %i training trials in %i iterations...\n',nTest,nTrain,nIter)
    
    %     AFSG (2014-03-03)
    %     % Update values changed due to type of validation
    %     decoder.nIter = nIter;      % Updating number of iterations based on type of validation algorithm
    %
    %     % Adding values to structure
    %     decoder.nCorrTrain    = nCorrTrain;         % 841
    %     decoder.nIncorrTrain  = nIncorrTrain;
    %     decoder.nCorrTest     = nCorrTest;
    %     decoder.nIncorrTest   = nIncorrTest;
    
    % Initialize vbles
    yHat        = zeros(nIter,nTest);
    overallDcd  = zeros(nIter,1);
    corrDcd     = zeros(nIter,1);
    errorDcd    = zeros(nIter,1);
    
    % Start Iterations
    for iIter = 1:nIter
        decoder.iIter = iIter;      % flag required for cross-validation, to build appropriate testing and training datasets out of the subsets
        fprintf('Running %i iteration for %s decoder ...\n',iIter,decoder.dcdType);
        [dcdData,~] = getTrainTestData(Xvals,Yvals,decoder,trialsPerm);             % Getting training and testing data
        
        %% Transform data
        [dcdData,ErrorInfo]     = dcdDataTransform(dcdData,ErrorInfo);
        decoder.dataTransfVals  = ErrorInfo.decoder.dataTransfVals;                 % updating dataTransfVals values
        decoder.dataTransformed = ErrorInfo.decoder.dataTransformed; 
        
%         AFSG (2014-03-03)
%         % Updating number of correct and incorrect testing and training trials
%         nCorrTest   = decoder.nCorrTest; 
%         nIncorrTest = decoder.nIncorrTest;
%         nCorrTrain  = decoder.nCorrTrain;
%         nIncorrTrain= decoder.nIncorrTrain;
%         yHat        = zeros(nIter,decoder.nCorrTest + decoder.nIncorrTest);
%         % Dummy test
%         trainingX = dcdData.trainingX; trainingY = dcdData.trainingY; testX = dcdData.testX; typeVal = decoder.typeVal;
        
        %% Running Decoder
        switch decoder.dcdType
            case 'regress'
                %for ii = 1:100                                                     % getting time of calculations
                %tStart = tic;
                [yHat,newB,~] = regressDecoder(dcdData.trainX,dcdData.trainY,dcdData.testX,decoder.typeVal);
                %tStop(ii) = toc(tStart);
                %end
                %mean(tStop)/length(dcdData.testY)*1000
            case 'lda'
                dip('No coded yet!!! Come back later...')
            case 'logitreg'
                [yHat,newB,~] = logistregDecoder(dcdData.trainX,dcdData.trainY,dcdData.testX,decoder.typeVal);
            otherwise
                fprintf('\nThe decoder type %s is not currently available, come back later...\n',decoder.dcdType)
        end

        %% Saving first decoder
        if iIter == 1
            oldB = newB;
            dcdPerf = sum(double(round(yHat) == dcdData.testY))/length(dcdData.testY);
        end
        
        corrTrials = (dcdData.testY == 0);        % correct trials
        incorrTrials = (dcdData.testY == 1);
        
        %          AFSG (2014-03-04)
        %         % Decoder performance
        %         corrDcd(iIter)     = sum(round(yHat(1:nCorrTest)) == 0)/nCorrTest;
        %         errorDcd(iIter)    = sum(round(yHat(nCorrTest+1:end)) == 1)/nIncorrTest;
        %         overallDcd(iIter)  = sum(double(round(yHat) == dcdData.testY))/length(dcdData.testY);
        corrDcd(iIter)     = sum(round(yHat(corrTrials)) == 0)/sum(corrTrials);
        errorDcd(iIter)    = sum(round(yHat(incorrTrials)) == 1)/sum(incorrTrials);
        overallDcd(iIter)  = sum(double(round(yHat) == dcdData.testY))/length(dcdData.testY);
        
        %% Choosing best decoder
        if iIter > 1
            if decoder.saveDecoder && (overallDcd(iIter) > dcdPerf)
                oldB = newB;
                dcdPerf = overallDcd(iIter);
                fprintf('\nDecoder from iteration %i is currently the best one.\n',iIter)
            end
        end
    end
    %% Saving best decoder
    if decoder.saveDecoder
        fprintf('Saving the best decoder...\n')
        saveFilename = createFileForm(decoder,ErrorInfo,'decoder');
        ErrorInfo.decoder = decoder;
        save(saveFilename,'oldB','decoder','ErrorInfo') 
    end
    
    % if loading previously trained decoder
else
    fprintf('Using all data for testing, using decoder trained with session %s...\n',decoder.oldSession)
    % Training and testing trial numbers
    nTest       = nTrials;
    nTrain      = 0;
    nIter       = 1;
    fprintf('Using a total of %i testing and %i training trials in %i iterations...\n',nTest,nTrain,nIter)
    % Adding values to structure
    decoder.nTest   = nTest;
    decoder.nTrain  = nTrain;
    decoder.nIter   = nIter;
    
    % Getting testing data
    [dcdData,~] = getTrainTestData(Xvals,Yvals,decoder,trialsPerm);
    
    %% Load decoder each iteration or load the one previously saved (to save time in online sessions)
    if isempty(ErrorInfo.decoder.oldDecoder)
        saveFlag = decoder.saveDecoder; decoder.saveDecoder = 0;            % saving value and setting saveDecoder flag to zero
        loadFilename = createFileForm(decoder,ErrorInfo,'decoder');
        decoder.saveDecoder = saveFlag;                                     % returning original value of saveDecoder
        loadDecoder = load(loadFilename);                                   % includes: newB, decoder, ErrorInfo
        oldB = loadDecoder.oldB;
        % Updating dataTransfVals from 'oldSession' decoder to apply to the new one.
        ErrorInfo.decoder.dataTransfVals = loadDecoder.decoder.dataTransfVals;
    else
        oldB = ErrorInfo.decoder.oldDecoder;
    end
    
    %% Transform data
    [dcdData,ErrorInfo]     = dcdDataTransform(dcdData,ErrorInfo);
    decoder.dataTransfVals  = ErrorInfo.decoder.dataTransfVals;                 % updating dataTransfVals values
    decoder.dataTransformed = ErrorInfo.decoder.dataTransformed;

    %% Decode!!!
    switch decoder.dcdType
        case 'regress'
            [yHat,~,oldB] = regressDecoder(dcdData.trainX,dcdData.trainY,dcdData.testX,decoder.typeVal,oldB);
        otherwise
            warning('Decoder %s is not currently available...\n',decoder.dcdType)
    end
    
    %     AFSG (2014-03-04)
    %     % Decoder performance
    %     corrDcd     = sum(round(yHat(1:decoder.nCorrTrials)) == 0)/decoder.nCorrTrials;
    %     errorDcd    = sum(round(yHat(decoder.nCorrTrials+1:end)) == 1)/decoder.nIncorrTrials;
    %     overallDcd  = sum(double(round(yHat) == dcdData.testY))/length(dcdData.testY);
    corrTrials      = (dcdData.testY == 0);        % correct trials
    incorrTrials    = (dcdData.testY == 1);
    corrDcd         = sum(round(yHat(corrTrials)) == 0)/sum(corrTrials);
    errorDcd        = sum(round(yHat(incorrTrials)) == 1)/sum(incorrTrials);
    overallDcd      = sum(double(round(yHat) == dcdData.testY))/length(dcdData.testY);
end

% Number of covariates
decoder.nCov = size(dcdData.testX,2);

if decoder.loadDecoder
   dcdVal = 'oldDecoder';
else
    dcdVal = decoder.typeVal;        % 'alltrain','crossva;','loov','alltest';
end
    
% Performance
decoder.performance.meanCorrDcd     = mean(corrDcd);
decoder.performance.meanErrorDcd    = mean(errorDcd);
decoder.performance.meanOverallDcd  = mean(overallDcd);
decoder.performance.corrDcd         = corrDcd;
decoder.performance.errorDcd        = errorDcd;
decoder.performance.overallDcd      = overallDcd;
decoder.performance.yHat            = yHat;
decoder.performance.dcdVal          = dcdVal;               % type of validation run to test decoder
decoder.performance.oldSession      = decoder.oldSession;   % only if loaded old decoder
decoder.performance.oldB            = oldB;

% Adding 'decoder' structure to 'ErrorInfo'
ErrorInfo.decoder = decoder;
% Show results
if ErrorInfo.decoder.visible
    disp(decoder.performance)
end

end

% ======================================================
% Getting Train and Testing data for new and old decoder
% ======================================================
function [dcdData,decoder] = getTrainTestData(Xvals,Yvals,decoder,trialsPerm)
% function [dcdData,decoder] = getTrainTestData(Xvals,Yvals,decoder)
%
% Obtains data for training and testing decoding performance. Takes into 
% account if a new decoder is trained or if an old one is loaded.
%
% INPUT
% Xvals:            matrix. Predictors for all correct and incorrect trials
%                   [numEpochs numPreditors] -> first all correct, then all incorrect.
% Yvals:            vector. [numTrials x 1]. True target value. True target.
% decoder:          structure with several fields required for the analysis
% trialsPerm:       logical. True if trials have already being permutted     
%                   
% OUTPUT
% dcdData:          structure with all the training and testing data required. 
%   trainX:         matrix. [nTrainingTrials, nPredictors].
%   trainY:         vector [nTrainingTrials,1]. Zero for correct trials, ones for incorrect trials. 
%   testX:          matrix. [nTestingTrials, nPredictors].
%   testY:          vector [nTestingTrials,1]. Zero for correct trials, ones for incorrect trials. 
% 
% Author    : Andres
%
% andres    : 1.1   : initial. Created 3 Dec 2013
% andres    : 1.2   : moved  feature extraction to other code. Only here the selection of training and testing trials. 03 March 2013

persistent CrossValLabels

%% Resampling
if ~decoder.loadDecoder
    % Choose type of validation
    switch decoder.typeVal
        case {'loov','bci'}
            [testX,indx]            = datasample(Xvals,decoder.nTest,1,'replace',false);     	% randomly choosing without replacement
            testY                   = Yvals(indx);
            diffIndx                = setdiff(1:decoder.nTrials,indx);                         	% these are indeces of trials not selected
            trainX                  = Xvals(diffIndx,:);                                        % choosing the rest of trials for testing
            trainY                  = Yvals(diffIndx);                                                   
        case 'crossval'
            % Only sort trials once
            if decoder.iIter == 1
                [CrossValLabels,decoder] = getCrossValTrials(decoder,trialsPerm);
            end
            testX   = Xvals(CrossValLabels(:,decoder.iIter),:);                                 % subset used for testing
            testY   = Yvals(CrossValLabels(:,decoder.iIter));
            trainX  = Xvals(~CrossValLabels(:,decoder.iIter),:);                                % subset used for training
            trainY  = Yvals(~CrossValLabels(:,decoder.iIter));
        case 'alltrain'
            testX   = [];                                                                       % subset used for testing
            testY   = [];
            trainX  = Xvals;                                                                    % choosing the rest of trials for testing
            trainY  = Yvals;
        case 'alltest'
            testX   = Xvals;                                                                    % choosing all trials for testing
            testY   = Yvals;
            trainX  = [];                                                                       % subset used for testing
            trainY  = [];
        otherwise
            warning('Not coded yet, come back soon!!!')
    end
else
    % no training data, decoder already trained with another session
    trainX  = [];
    trainY  = [];
    testX   = Xvals;                        % choosing all trials for testing
    testY   = Yvals;                        
end

%% Get mean per window
% AFSG (2014-02-28)
% % Getting mean values for sections of waveforms
% corrTrainX  = []; incorrTrainX  = [];
% corrTestX   = []; incorrTestX   = [];
% trainingX   = []; testX         = [];
% 
% % Predictors
% for iPreX = 1:size(decoder.predWindows,1)
%     if ~decoder.loadDecoder
%         % Train
%         corrTrainX = [corrTrainX mean(corrTrainData(:,:,round(dcdPredWindows(iPreX,1)*Fs):round(dcdPredWindows(iPreX,2)*Fs)),3)'];        % nChs x nTrials
%         incorrTrainX = [incorrTrainX mean(incorrTrainData(:,:,round(dcdPredWindows(iPreX,1)*Fs):round(dcdPredWindows(iPreX,2)*Fs)),3)'];  % nChs x nTrials
%     end
%     % Test
%     corrTestX = [corrTestX mean(corrTestData(:,:,round(dcdPredWindows(iPreX,1)*Fs):round(dcdPredWindows(iPreX,2)*Fs)),3)'];           % nChs x nTrials
%     incorrTestX = [incorrTestX mean(incorrTestData(:,:,round(dcdPredWindows(iPreX,1)*Fs):round(dcdPredWindows(iPreX,2)*Fs)),3)'];     % nChs x nTrials
% end
% 
% % Creating training and testing matrices
dcdData.trainX  = trainX;
dcdData.trainY  = trainY;
dcdData.testX   = testX;
dcdData.testY   = testY;
end

% ====================================================================================
% Getting cross validation trials for train and testing data (for new and old decoder)
% ====================================================================================
function [CrossValLabels,decoder] = getCrossValTrials(decoder,trialsPerm)
%function [CrossValLabels,decoder] = getCrossValTrials(decoder,trialsPerm)
%function [CrossValData,decoder] = getCrossValTrials(Xvals,Yvals,decoder,trialsPerm)
%
% Creates k subsets of data based on the number of k-fold cross-validation
% values located in decoder.nIter
%
% INPUT
% Xvals:                matrix. All the data in feature space. [numTrials numPredictors].
% Yvals:                vector. All the true labels for each trials [numTrials x 1].
% decoder:              structure. It is basically the same structure in
%                       ErrorInfo but separated to use it in other functions
% trialsPerm:           logical. True if trials have already being permutted     
%
% OUTPUT
% CrossValData:         structure. Has Xvals and Yvals for each iteration
% decoder:              structure. It is basically the input with some extra values
%
% Author    : Andres 
%
% andres    : 1.1   : initial. Created 14 Jan 2014
% andres    : 1.2   : remove the use of correct and incorrect data. Already grouped after getting features. 3 March 2014

% Starting index for all iterations
iterIndx = 1:decoder.nTest:decoder.nTrials;         % get starting index per iteration

% Permuting trials to select them randomnly (not always from start to end)
if ~trialsPerm
    trialsPermIndx = randperm(decoder.nTrials);               % randomnly organize correct trials
end

% Cross Validation Labels for each iteration
CrossValLabels = false(decoder.nTrials,decoder.nIter);

%% Getting subsets and indeces from original data sets
for iIndx = 1:decoder.nIter
    if iIndx ~= decoder.nIter
        lastIndx = iterIndx(iIndx) + decoder.nTest - 1;
    else
        lastIndx = decoder.nTrials;
    end
    % Data
    CrossValLabels(iterIndx(iIndx):lastIndx,iIndx) = true;
end

end