function [yHat,newB,oldB] = regressDecoder(trainX,trainY,testX,typeVal,oldB)
% function [yHat,newB,oldB] = regressDecoder(trainX,trainY,testX,typeVal,oldB)
%
% Regression-based decoder -- Regresses x,y components of training-trial
% target directions onto design matrix of trial; resulting fitted weights
% used to predict x,y components of test trial. The output is
%
% INPUT
% trainX:    [nTrainTrials x nPredictor]. Training predictors.
% trainY:    [nTrainTrials x 1]. Labels for training (0 correct, 1 error)
% testX:        [nTestTrials x nPredictor]. Testing predictors.
% typeVal:      string. Type of validation. Can be 'alltrain', 'crossval', 'loov'
% oldB:         [nCov nCov]. Already trained B matrix of weights. Used to
%               decode current trials with decoder trained with data from
%               another session.
% OUTPUT
% yHat:         vector. [nTestTrials, 1]. Decoded targets
% oldB:         [nCov nCov]. Already trained B matrix of weights. Used to
%               decode current trials with decoder trained with data from
%               another session.
% newB:         [nCov nCov]. New B matrix of weights using training and
%               testing trials from the current session .
%
% Scott's regression decoder
% Andres v1.2 Some changes to vble names and included option to use 
% previously trained decoder but mainly Scott's decoder. 

[nTestTrls,~] = size(testX);

% If need to train decoder
if nargin < 5
    nTrainTrls  = size(trainX,1);
    Y = trainY;
    
    % Fit regression weights (B) to training data (Y). Note that complex directional data vector Y (ie, Y = Yx + i*Yy)
    % results in complex directional weights (ie, B = Bx + i*By)
    % Scott's -> todo: Replace 'pinv' pseudoinverse with more flexible regularized inversion (ie, ridge regression, SVD decomp)
    X = [ones(nTrainTrls,1) trainX];         % Pre-pend column of ones to trainX to fit baseline weight
    newB = pinv(X'*X) * X'*Y;                   % Fit regression weights, using pseudoinverse of autocorrelation matrix
    
    if ~strcmp(typeVal,'alltrain')
        % Use fitted weights to predict target directions on testing trial(s).
        X = [ones(nTestTrls,1) testX];          % Pre-pend a col of ones to testX to account for baseline weight
        yHat = X*newB;                          % Regression-predicted target on each trial
        % Old B matrix
    else
        yHat = [];
    end
    oldB = [];
else
    % If decoder already trained with previous session
    X = [ones(nTestTrls,1) testX];              % Pre-pend a col of ones to testX to account for baseline weight
    yHat = X*oldB;                              % Regression-predicted target on each trial
    % New weights matrix? no.
    newB = [];
end

end

