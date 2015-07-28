function ldaDecoder
% function ldaDecoder
%
%
%
%
%

% function [predictedTgts, popVectors, dcdObj] = LDAdecoder(trainingX, trainingY,testX,discrimType, gamma, tgtDirections, decoder, probTransform)
%
% Linear Discriminant Analysis decoder
%
% INPUTS (see decoder.m and ClassificationDiscriminant for further details):
% discrimType Type of discriminant to use, includes: 'pseudoLinear','linear','quadratic'
%             Usually, we have used pseudolinear; quadratic generally does poorly (badly overfits)
% gamma       Parameter for regularizing the correlation matrix of predictors for LDA.
%             0 = no regularization (use full predictor corr matrix), 
%             1 = maximum regularization (use only diagonal of predictor corr matrix)
% decoder     String indicating which type of decoder to use here (both seem to have similar performance):
%             'lda'     : Standard Linear Discriminant Analysis
%             'contlda' : "Continuous LDA"--use (discretized) vector mean of LDA target probabilities as prediction (Nan's invention)
% probTransform (optional) Function handle used to transform (eg, log) decoder-predicted probabilities before popVector computation
% 
% OUTPUTS:
% popVectors  Vector(nTestTrials,1) of continuous estimates of target direction for each test trial.
%             Obtained by calculating vector mean of LDA target probabilities
% dcdObj      Classification object variable returned by ClassificationDiscriminant.fit

% TEMP(?) KLUDGE: Remove any predictors from X (both training and testing) that are all 0
zeroPreds = all(trainingX == 0,1);      % Logical flagging predictors (X col's) with all 0's
if all(zeroPreds),                      % If all predictors were all-0, return with null predictions
  predictedTgts = nan(size(testX,1),1); 
  dcdObj = []; 
  return; 
end  
trainingX(:,zeroPreds)= [];             % Otherwise, just remove them from training/testX

% Fit linear discriminant model to training data. For SVD, Mx ~= 1 
dcdObj = ClassificationDiscriminant.fit(trainingX, trainingY, ...
    'discrimType',discrimType, 'Gamma',gamma);

% Predicted response on the test trial(s)
if ~isempty(testX)
  testX(:,zeroPreds) = [];    
  nTestTrls = size(testX,1);

  % Use LDA fit to generate continuous direction estimate = probability-weighted vector average (Nan)
  nTgts = length(tgtDirections);
  invSigma = pinv(dcdObj.Sigma);                            % Compute (pseudo)inverse of covariance matrix
  P = zeros(nTestTrls,nTgts);  
  for trl = 1:nTestTrls
      for tgtNo = 1:nTgts
          d     = testX(trl,:) - dcdObj.Mu(tgtNo,:);     
          P(trl,tgtNo) = -0.5*d*invSigma*d';                % Log(Probability) of target given trial activity
      end
  end
  if strcmp(probTransform,'log')    
    P   = P - repmat(min(P,[],2),[1 nTgts]);                % Subtract by min(log(P)) across tgts to avoid negative values
  else
    P   = exp(P);                                           % Convert log(P) to P    
    P   = P ./ repmat(max(P,[],2),[1 nTgts]);               % Divide by max(P) across tgts to avoid overflow (cf. CompactClassificationDiscriminant.m)    
  end
  % DEL?:
  % if strcmp(probTransform,'log')    
  %   P   = P - repmat(max(P,[],2),[1 nTgts]);                % Divide by max(P) across tgts to avoid overflow (cf. CompactClassificationDiscriminant.m)
  % else
  %   P   = P ./ repmat(max(P,[],2),[1 nTgts]);               % Divide by max(P) across tgts to avoid overflow (cf. CompactClassificationDiscriminant.m)    
  % end
  
  % DEL (SLB 10-16) -- Not necessary to normalize--doesn't change mean direction 
  % P   = P ./ repmat(sum(P,2),[1 nTgts]);  % Normalize prob's for each trial across tgt's  
  % DELETE: if ~isempty(probTransform), P = probTransform(P); end     % Transform probabilities (if desired)
  
  s   = repmat( exp(1i*tgtDirections'), [nTestTrls 1] );    % Stimuli -- tgt directions (expressed in complex form)  
  yHat    = sum(P .* s, 2);               % Probability-weighted vector sum of target directions
  
  % If using "continuous LDA" decoder, discretize continuous predicted direction to get predicted targets
  if strcmpi(decoder, 'contLDA')          
    predictedTgts = popVector2Tgt(yHat, tgtDirections, unique(tgtDirections));
  % If using standard (discrete) LDA decoder, use that to predicted targets
  else
        predictedTgts = predict(dcdObj,testX);       % LDA-predicted targets on test trials.     
  end
else                  % (or you may just want to fit the decoder model, return its object,
  predictedTgts = []; %  w/o making any predictions)
  yHat    = [];
end
%% ===============================================
