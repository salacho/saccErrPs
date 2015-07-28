function [yHat,newB,oldB] = logistregDecoder(trainingX,trainingY,testX,typeVal,oldB)
% function [yHat,newB,oldB] = logistregDecoder(trainingX,trainingY,testX,typeVal,oldB)
%
% Logistic regression-based decoder -- Regresses x,y components of training-trial 
% target directions using multinomial regression and logit option as default for nominal bynary dependent results. 
%
% INPUT
% trainingX:    [nTrainTrials x nPredictor]. Training predictors.
% trainingY:    [nTrainTrials x 1]. Labels for training (0 correct, 1 error)
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
% Created 13 Feb. 2014.  
% Andres v1.0 Included the option to use a previously trained decoder.
% Last modified 13 Feb 2014.

[nTestTrls,~] = size(testX);

% If need to train decoder
if nargin < 5
    nTrainTrls  = size(trainingX,1);
    Y = trainingY;
    X = trainingX;             
    
    %sp = nominal(species);
    %sp = double(sp);
    [newB,dev,stats] = mnrfit(X,Y+1,'model','nominal');           % Use multinomial regression, 'logit' by default. Adding 1 to 'Y' since it must be positive values (no zeros allowed)
    
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

% Coping with logit solution
yHat = (yHat <= 0)+0;                            % Changing from logical to double


end

