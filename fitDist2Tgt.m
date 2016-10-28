function predVals = fitDist2Tgt(ampDecoding,ErrorInfo)
%
%
%
%
%
%
%
% 09 Nov 2014

% Params
plotInfo = ErrorInfo.plotInfo;

% Vbles
nChs = size(ampDecoding.maxAmp,2);
% Factors
factorError = ampDecoding.factorError;              
factorDist2Tgt = ampDecoding.factorDist2Tgt;
factorLat = ampDecoding.factorLat;
factorTgt = ampDecoding.factorTgt;
maxAmp = ampDecoding.maxAmp;
minAmp = ampDecoding.minAmp;

%% maxAmp dist2tgt 
lambda = 0.1;
num_labels = length(unique(factorDist2Tgt));
% Training
[all_theta] = oneVsAll(maxAmp,factorDist2Tgt, num_labels, lambda);
% Predicting
predVals = predictOneVsAll(all_theta, maxAmp);
% 
fprintf('\nTraining Set Accuracy: %f\n', mean(double(predVals == factorDist2Tgt)) * 100);

%% minAmp dist2tgt 
lambda = 0.1;
num_labels = length(unique(factorDist2Tgt));
% Training
[all_theta] = oneVsAll(minAmp,factorDist2Tgt, num_labels, lambda);
% Predicting
predVals = predictOneVsAll(all_theta, minAmp);
% 
fprintf('\nTraining Set Accuracy: %f\n', mean(double(predVals == factorDist2Tgt)) * 100);

%% maxAmp & minAmp dist2tgt 
lambda = 0.1;
num_labels = length(unique(factorDist2Tgt));
% Training
[all_theta] = oneVsAll([maxAmp minAmp],factorDist2Tgt, num_labels, lambda);
% Predicting
predVals = predictOneVsAll(all_theta, [maxAmp minAmp]);
% 
fprintf('\nTraining Set Accuracy: %f\n', mean(double(predVals == factorDist2Tgt)) * 100);

%% Logisaticx Regression Decoder Error Detector
lambda = 0.1;
num_labels = length(unique(factorError));
% Training
[all_theta] = oneVsAll([maxAmp minAmp],factorError, num_labels, lambda);
% Predicting
predVals = predictOneVsAll(all_theta, [maxAmp minAmp]);
% 
fprintf('\nTraining Set Accuracy: %f\n', mean(double(predVals == factorError)) * 100);

%% Using DEcoder Error Xvals
% Signal processing
[corrEpochs,incorrEpochs,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);

% Feature extraction and selection
[Xvals,ErrorInfo] = selectFeatures(corrEpochs,incorrEpochs,ErrorInfo);

% Decode
lambda = 0.001;
num_labels = length(unique(ErrorInfo.featSelect.Yvals));
% Training
[all_theta] = oneVsAll(Xvals,ErrorInfo.featSelect.Yvals, num_labels, lambda);
% Predicting
predVals = predictOneVsAll(all_theta, Xvals);
% 
fprintf('\nTraining Set Accuracy: %f\n', mean(double(predVals == ErrorInfo.featSelect.Yvals)) * 100);

%% fitLine
for iCh = 1:nChs
    subplot(10,10,iCh)
    pred = (maxAmp(:,iCh) - mean(maxAmp(:,iCh)))/std(maxAmp(:,iCh),[],1);
    [yFit,rSq] = fitLine(pred,factorDist2Tgt,1);
    plot(factorDist2Tgt,pred,'*');
    hold on,
    plot(factorDist2Tgt,yFit,'r*');
    title(iCh)
end

%% ANOVA Corr-Incorr maxAmp
ErrorInfo.analysis.ANOVA.analDim = 1;
predVals = maxAmp;
[expVar,n,pVals,mu,F] = myANOVA1(predVals,factorError,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);

imagesc(expVar.*(pVals <= 0.01)), colorbar
pValIndx = (pVals <= 0.01);
pValPred = predVals(:,pValIndx);

%% ANOVA Corr-Incorr minAmp
ErrorInfo.analysis.ANOVA.analDim = 1;
predVals = minAmp;
[expVar,n,pVals,mu,F] = myANOVA1(predVals,factorError,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);

imagesc(expVar.*(pVals <= 0.01)), colorbar
pValIndx = (pVals <= 0.01);
pValPred = predVals(:,pValIndx);


%% ANOVA Corr-Incorr maxAmp-minAmp
ErrorInfo.analysis.ANOVA.analDim = 1;
predVals = [maxAmp minAmp];
[expVar,n,pVals,mu,F] = myANOVA1(predVals,factorError,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);

imagesc(expVar.*(pVals <= 0.01)), colorbar
pValIndx = (pVals <= 0.01);
pValPred = predVals(:,pValIndx);

%% ANOVA Corr-Incorr maxAmp-pValsCrit
ErrorInfo.analysis.ANOVA.analDim = 1;
predVals = maxAmp;
[expVar,n,pVals,mu,F] = myANOVA1(predVals,factorError,ErrorInfo.analysis.ANOVA.analDim);%,ErrorInfo.epochInfo.ANOVA.epochLabel,ErrorInfo.epochInfo.ANOVA.grandMeanMethod,ErrorInfo.epochInfo.ANOVA.calcOmega2ExpVar);
expVar = squeeze(expVar);
pVals = squeeze(pVals);

imagesc(expVar.*(pVals <= 0.01)), colorbar
pValIndx = (pVals <= 0.01);
pValPred = predVals(:,pValIndx);

for iCh = 1:size(pValPred,2)
    subplot(ceil(sqrt(size(pValPred,2))),ceil(sqrt(size(pValPred,2))),iCh)
    pred = (pValPred(:,iCh) - mean(pValPred(:,iCh)))/std(pValPred(:,iCh),[],1);
    [yFit,rSq] = fitLine(pred,factorDist2Tgt,1);
    plot(factorDist2Tgt,pred,'*');
    hold on,
    plot(factorDist2Tgt,yFit,'r*');
    title(iCh)
end



