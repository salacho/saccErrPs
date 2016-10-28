function [latTgts,latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo)
% function [latMeanCh,latStdCh,latMeanArray,latStdArray] = getMeanLatErrPs(tgtErrRPs,ErrorInfo)
%
% Get the mean epochs for each laterality, for correct and incorrect trials.
%
%
%
%
% Andres    : v1.0  : init. Created 03 Nov 2014

%% Vbles
Tgts = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);
ipsiIndx = ErrorInfo.signalProcess.ipsiIndx;
contraIndx = ErrorInfo.signalProcess.contraIndx;

%% All epochs per target 
contraLatArray = repmat(struct(...
    'corr',[],...
    'incorr',[]),...
    [1 ErrorInfo.plotInfo.nArrays]);

ipsiLatArray = repmat(struct(...
    'corr',[],...
    'incorr',[]),...
    [1 ErrorInfo.plotInfo.nArrays]);

latTgts = repmat(struct(...
    'corr',[],...
    'incorr',[]),...
    [nTgts ErrorInfo.plotInfo.nArrays]);

contraLat.corr = [];
contraLat.incorr = [];
ipsiLat.corr = [];
ipsiLat.incorr = [];

nCorrTrials = nan(nTgts,1);
nIncorrTrials = nan(nTgts,1);

for iTgt = 1:nTgts
    % Per array
    for iArray = 1:ErrorInfo.plotInfo.nArrays
        fprintf('Getting laterality for tgt %i, array %s...\n',iTgt,ErrorInfo.plotInfo.arrayLoc{iArray})
        
        arrayChs = ErrorInfo.plotInfo.arrayChs(iArray,:);
        nChsPerArray = length(arrayChs);
        
        % Getting epochs for channels and trials for correct targets
        [~,nCorrTrials(iTgt),nDataPoints] = size(tgtErrRPs(iTgt).corrEpochs);
        if ndims(tgtErrRPs(iTgt).corrEpochs) == 3
            latTgts(iTgt,iArray).corr = reshape(tgtErrRPs(iTgt).corrEpochs(arrayChs,:),[nChsPerArray*nCorrTrials(iTgt) nDataPoints]);        % getting mean since more than 1 epoch
        elseif ndims(tgtErrRPs(iTgt).corrEpochs) == 2                                   %#ok<ISMAT> % only 1 epoch, no mean
            latTgts(iTgti,iArray).corr = reshape(tgtErrRPs(iTgt).corrEpochs(arrayChs,:),[nChsPerArray*nCorrTrials(iTgt) nDataPoints]);
        else
            latTgts(iTgt,iArray).corr = nan(1,nDataPoints);
        end
        
        % Getting epochs for channels and trials for incorrect targets
        [~,nIncorrTrials(iTgt),~] = size(tgtErrRPs(iTgt).incorrEpochs);
        if ndims(tgtErrRPs(iTgt).incorrEpochs) == 3
            latTgts(iTgt,iArray).incorr = reshape(tgtErrRPs(iTgt).incorrEpochs(arrayChs,:),[nChsPerArray*nIncorrTrials(iTgt) nDataPoints]);        % getting mean since more than 1 epoch
        elseif ndims(tgtErrRPs(iTgt).incorrEpochs) == 2                                   %#ok<ISMAT> % only 1 epoch, no mean
            latTgts(iTgt,iArray).incorr = reshape(tgtErrRPs(iTgt).incorrEpochs(arrayChs,:),[nChsPerArray*nIncorrTrials(iTgt) nDataPoints]);
        else
            latTgts(iTgt,iArray).incorr = nan(1,nDataPoints);
        end
        
        % Laterality per array for contra
        if any(ErrorInfo.signalProcess.contralatTgts == iTgt)
            contraLatArray(iArray).corr = [contraLatArray(iArray).corr; latTgts(iTgt,iArray).corr];
            contraLatArray(iArray).incorr = [contraLatArray(iArray).incorr; latTgts(iTgt,iArray).incorr];
        end
        
        % Laterality per array for ipsi
        if any(ErrorInfo.signalProcess.ipsilatTgts == iTgt)
            ipsiLatArray(iArray).corr = [ipsiLatArray(iArray).corr; latTgts(iTgt,iArray).corr];
            ipsiLatArray(iArray).incorr = [ipsiLatArray(iArray).incorr; latTgts(iTgt,iArray).incorr];
        end
    end
    
    % Laterality per channel for contra
    if any(ErrorInfo.signalProcess.contralatTgts == iTgt)
        contraLat.corr = [contraLat.corr  tgtErrRPs(iTgt).corrEpochs];
        contraLat.incorr = [contraLat.incorr  tgtErrRPs(iTgt).incorrEpochs];
    end
    
    % Laterality per channel for ipsi
    if any(ErrorInfo.signalProcess.ipsilatTgts == iTgt)
        ipsiLat.corr = [ipsiLat.corr  tgtErrRPs(iTgt).corrEpochs];
        ipsiLat.incorr = [ipsiLat.incorr  tgtErrRPs(iTgt).incorrEpochs];
    end
end

%% Mean and Std. Dev/Error for ipsi and contra
% Per channel
disp('Calculating meanCh/stCh for ipsi- and contra-lateral targets')
[ipsiLatMeanCh.corr, ipsiLatStdCh.corr] = getMeanTrials(ipsiLat.corr,ErrorInfo);
[ipsiLatMeanCh.incorr, ipsiLatStdCh.incorr] = getMeanTrials(ipsiLat.incorr,ErrorInfo);
[contraLatMeanCh.corr, contraLatStdCh.corr] = getMeanTrials(contraLat.corr,ErrorInfo);
[contraLatMeanCh.incorr, contraLatStdCh.incorr] = getMeanTrials(contraLat.incorr,ErrorInfo);

% Per Array
for iArray = 1:ErrorInfo.plotInfo.nArrays
    fprintf('Calculating meanArray/stArray for ipsi- and contra-lateral targets for array %s\n',ErrorInfo.plotInfo.arrayLoc{iArray})
    [ipsiLatMeanArray.corr(iArray,:), ipsiLatStdArray.corr(iArray,:)] = getMeanArrays(ipsiLatArray(iArray).corr,ErrorInfo); %#ok<*AGROW>
    [ipsiLatMeanArray.incorr(iArray,:), ipsiLatStdArray.incorr(iArray,:)] = getMeanArrays(ipsiLatArray(iArray).incorr,ErrorInfo);
    [contraLatMeanArray.corr(iArray,:), contraLatStdArray.corr(iArray,:)] = getMeanArrays(contraLatArray(iArray).corr,ErrorInfo);
    [contraLatMeanArray.incorr(iArray,:), contraLatStdArray.incorr(iArray,:)] = getMeanArrays(contraLatArray(iArray).incorr,ErrorInfo);
end

%% Appending all data in proper laterality location (left-right)
% Per channel
latMeanCh(ipsiIndx).corr = ipsiLatMeanCh.corr;
latMeanCh(ipsiIndx).incorr = ipsiLatMeanCh.incorr;
latMeanCh(contraIndx).corr = contraLatMeanCh.corr;
latMeanCh(contraIndx).incorr = contraLatMeanCh.incorr;

latStdCh(ipsiIndx).corr = ipsiLatStdCh.corr;
latStdCh(ipsiIndx).incorr = ipsiLatStdCh.incorr;
latStdCh(contraIndx).corr = contraLatStdCh.corr;
latStdCh(contraIndx).incorr = contraLatStdCh.incorr;

% Per array
latMeanArray(ipsiIndx).corr = ipsiLatMeanArray.corr;
latMeanArray(ipsiIndx).incorr = ipsiLatMeanArray.incorr;
latMeanArray(contraIndx).corr = contraLatMeanArray.corr;
latMeanArray(contraIndx).incorr = contraLatMeanArray.incorr;

latStdArray(ipsiIndx).corr = ipsiLatStdArray.corr;
latStdArray(ipsiIndx).incorr = ipsiLatStdArray.incorr;
latStdArray(contraIndx).corr = contraLatStdArray.corr;
latStdArray(contraIndx).incorr = contraLatStdArray.incorr;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Subfunctions start here %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [epochsMeanMatrix,epochsStdMatrix] = getMeanTrials(epochsMatrix,ErrorInfo)
% function  [epochsMeanMatrix,endepochsStdMatrix] = getMeanTrials(epochsMatrix,ErrorInfo)
%
% Get the mean and std. dev./error of trials for each channel
%
%

[nChs,nTrials,nDataPoints] = size(epochsMatrix);
% Checking dimensionality!!
if ndims(epochsMatrix) ~= 3
    error('Number of dimmensios for epochsMatrix is not three!!!')
    disp(ndism(epochsMatrix)); %#ok<*UNRCH>
end

% standard deviation or error
if ErrorInfo.plotInfo.stdError,     StdK =  sqrt(nTrials);        % get standard error of the mean
    if StdK == 0, StdK = 1; end
else                                StdK = 1;    % get standard deviation
end

if nTrials == 0,        
    epochsMeanMatrix    = nan(nChs,nDataPoints);
    epochsStdMatrix     = nan(nChs,nDataPoints);
elseif nTrials == 1,   
    epochsMeanMatrix    = squeeze(epochsMatrix);
    epochsStdMatrix     = zeros(nChs,nDataPoints);
else
    epochsMeanMatrix    = squeeze(nanmean(epochsMatrix,2));
    epochsStdMatrix  = squeeze(nanstd(epochsMatrix,[],2))/StdK;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [epochsMeanMatrix,epochsStdMatrix] = getMeanArrays(epochsMatrix,ErrorInfo)
% function  [epochsMeanMatrix,endepochsStdMatrix] = getMeanArrays(epochsMatrix,ErrorInfo)
%
% Get the mean and std. dev./error of trials and channels for each array
%
%

[nTrials,nDataPoints] = size(epochsMatrix);
% Checking dimensionality!!
if ndims(epochsMatrix) ~= 2 %#ok<ISMAT>
    error('Number of dimmensios for epochsMatrix is not two!!!')
    disp(ndism(epochsMatrix));
end

% standard deviation or error
if ErrorInfo.plotInfo.stdError,     StdK = sqrt(nTrials);        % get standard error of the mean
    if StdK == 0, StdK = 1; end
else                                StdK = 1;    % get standard deviation
end

if nTrials == 0,        
    epochsMeanMatrix    = nan(nDataPoints,1);
    epochsStdMatrix     = nan(nDataPoints,1);
elseif nTrials == 1,   
    epochsMeanMatrix    = squeeze(epochsMatrix);
    epochsStdMatrix     = zeros(nDataPoints,1);
else
    epochsMeanMatrix    = squeeze(nanmean(epochsMatrix,1));
    epochsStdMatrix  = squeeze(nanstd(epochsMatrix,[],1))/StdK;
end

end

