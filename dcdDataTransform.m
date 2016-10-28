function [dcdData,ErrorInfo] = dcdDataTransform(dcdData,ErrorInfo)
% function [dcdData,ErrorInfo] = dcdDataTransform(dcdData,ErrorInfo)
%
% Transforms covariates to better fit normal distribution or the one 
% assumed to have the extracted data. 
%
% INPUT
% dcd:              structure. The fields include the training and testing
%                   matrices in the form [numTrials X numCovariates]. 
%     trainingX:    matrix [numTrainingTrials X numCovariates]. Training cov.
%     trainingY:    matrix [numTrainingTrials X 1]. Outcome labels.
%     testX:        matrix [numTestingTrials X numCovariates]. Test cov.
%     testY:        matrix [numTestingTrials X 1]. Expected outcomes.
% 
% ErrorInfo:        structure. Has all the info regarding how the epochs 
%                   were obtained. 
%
% OUTPUT
% dcd:              structure. The fields include the training and testing
%                   matrices in transformed using the function included in
%                   'ErrorInfo.decoder.dataTranform'.
%     trainingX:    matrix [numTrainingTrials X numCovariates]. Training cov.
%     trainingY:    matrix [numTrainingTrials X 1]. Outcome labels.
%     testX:        matrix [numTestingTrials X numCovariates]. Test cov.
%     testY:        matrix [numTestingTrials X 1]. Expected outcomes.
% 
% ErrorInfo:        structure. Has all the info regarding how the epochs 
%                   were obtained. 
%
% Author    : Andres
%
% andres    : 1.1   : init. 10 March 2014
% andres    : 1.2   : fixed problems when used 'allTrain' and 'oldSession' decoder. 
%                     Mainly empty matrices and lack of data for calculating 'mu' 
%                     and 'sig', and 'maxVal'. Added fields to
%                     ErrorInfo.decoder. 19 Mars 2014

nTrainTrls = size(dcdData.trainX,1);
nTestTrls = size(dcdData.testY,1);

trainX = dcdData.trainX;
testX = dcdData.testX;
ErrorInfo.decoder.dataTransformed = 1;      % set here so it applies to all cases. If none of the available cases, in the 'otherwise' option is set back to zero.

% Creating dummy vbles in case empty matrices for 'allTrain' or testing with 'oldSession' decoder
if isempty(trainX), trainX = 1; warning('trainX is empty but added a 1 to bypass errors!!!'), end
if isempty(testX), testX = 1; warning('testX is empty but added a 1 to bypass errors!!!'), end

% Transform data
switch ErrorInfo.decoder.dataTransform
    case 'none';  % No transform/use raw data -- do nothing!
        % Square-root transform training and test data to approx transform Poisson spike counts to ~normal
    case 'sqrt';
        if ~ErrorInfo.decoder.loadDecoder
            trainX = sqrt(trainX);    % Note: these could be once, before any data partitioning, for efficiency
        end
        testX     = sqrt(testX);        %  but done here to make code clearer, avoid confusion
        
        % Log (base10) transform training and test data to ~equalize variance of LFP power across frequency bands
    case 'log';
        if ~ErrorInfo.decoder.loadDecoder
            trainX = log10(trainX);   % Note: these could be once, before any data partitioning, for efficiency
        end
        testX     = log10(testX);       %  but done here to make code clearer, avoid confusion
        
        %         % Center training and test data -- transform to differences from training-data across-trials mean activity (w/in predictors)
        %     case {'center','meandiff'};
        %         mu  = mean(trainingX, 1);       % Mean response across all training trials, for each predictor
        %         trainingX = trainingX - repmat(mu,[nTrainTrls 1]);  % Convert training data difference from mean
        %         testX     = testX - repmat(mu,[nTestTrls 1]);       % Convert test data to difference from training-data mean
        
    % Transform training and test data to z-scores from training-data across-trials mean and standard dev.
    case 'zscore';
        if ~ErrorInfo.decoder.loadDecoder
            mu  = mean(trainX, 1);       % Mean response across all training trials, for each predictor
            sig = std(trainX, 0, 1);     % Standard deviation of response across all training trials
            % Saving values for testing with oldSession decoder
            ErrorInfo.decoder.dataTransfVals.zscoreMu = mu;
            ErrorInfo.decoder.dataTransfVals.zscoreSig = sig;
        else
            mu  = ErrorInfo.decoder.dataTransfVals.zscoreMu;
            sig = ErrorInfo.decoder.dataTransfVals.zscoreSig;
        end
        
        trainX = (trainX - repmat(mu,[nTrainTrls 1])) ... % Convert training data to z-scores
            ./ repmat(sig,[nTrainTrls 1]);
        testX     = (testX - repmat(mu,[nTestTrls 1])) ...  % Convert test data to z-scores
            ./ repmat(sig,[nTestTrls 1]);             % relative to training data mean/stddev
        
        trainX(:,sig == 0) = 0;      % To deal w/ (very rare) situation where response=0 for all
        testX(:,sig == 0)     = 0;      % training trials (usu. spike counts), and would produce z-score = NaN
        
    % Square transform training and test data (usu. to convert LFP/MUA magnitude to power)
    case 'sqr';
        if ~ErrorInfo.decoder.loadDecoder
            trainX = trainX .^ 2;     % Note: these could be once, before any data partitioning, for efficiency
        end
        testX     = testX .^ 2;         %  but done here to make code clearer, avoid confusion
        
    % Classical 'normalized response' transform -- normalize training and test data by max response in any training trial
    case 'max';
         if ~ErrorInfo.decoder.loadDecoder
           maxVal    = max(trainX, [], 1);  % Maximum response across all training trials, for each predictor
         else
             maxVal  =  ErrorInfo.decoder.dataTransfVals.maxMaxVal;
         end
         
        trainX = trainX ./ repmat(maxVal,[nTrainTrls 1]);
        testX     = testX ./ repmat(maxVal,[nTestTrls 1]);
        
        trainX(:,maxVal == 0) = 0;   % To deal w/ (very rare) situation where response=0 for all
        testX(:,maxVal == 0)     = 0;   % training trials (usu. spike counts), and would produce z-score = NaN
        
        % Saving values for testing with oldSession decoder
        ErrorInfo.decoder.dataTransfVals.maxMaxVal = maxVal;
    otherwise
        warning('No known function was included...') %#ok<*WNTAG>
        ErrorInfo.decoder.dataTransformed = 0;              % Flag data transformation set to zero again
end

% Bringing back 
dcdData.trainX  = trainX; 
dcdData.testX   = testX;

end
