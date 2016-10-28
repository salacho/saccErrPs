function [corrMeanTgt,incorrMeanTgt,corrStdTgt,incorrStdTgt,corrMeanTgtArray,incorrMeanTgtArray,corrStdTgtArray,incorrStdTgtArray] = ...
    getMeanTgtErrPs(tgtErrRPs,ErrorInfo)
% function [corrMeanTgt,incorrMeanTgt,corrStTgt,incorrStTgt,corrMeanTgtArray,incorrMeanTgtArray,corrStdTgtArray,incorrStdTgtArray] = ...
%    getMeanTgtErrPs(tgtErrRPs,ErrorInfo)
%
% Get the mean epochs for each target, for correct and incorrect trials.
%
%
%
%
% Andres    : v1.0  : init. Created 03 Nov 2014

%% Vbles
plotInfo = ErrorInfo.plotInfo;
Tgts  = unique(ErrorInfo.epochInfo.corrExpTgt)';
nTgts = length(Tgts);

%% Pre allocating memory
%correct
[nChs,nCorrTrials,nDataPoints] = size(tgtErrRPs(1).corrEpochs);
corrMeanTgt = nan(nTgts,nChs,nDataPoints);      % epochs' mean
corrStdTgt = corrMeanTgt;

%incorrect
[nChs,~,nDataPoints] = size(tgtErrRPs(1).incorrEpochs);
incorrMeanTgt = nan(nTgts,nChs,nDataPoints);
incorrStdTgt = incorrMeanTgt;

%% Mean epochs for each target
disp('')
for iTgt = 1:nTgts
    % Number of Correct trials
    [~,nCorrTrials(iTgt),~] = size(tgtErrRPs(iTgt).corrEpochs);
    % Getting Mean values for correct and incorrect epochs for target iTgt
    if ndims(tgtErrRPs(iTgt).corrEpochs) == 3
        corrMeanTgt(iTgt,:,:) = squeeze(mean(tgtErrRPs(iTgt).corrEpochs,2));        % getting mean since more than 1 epoch
    elseif ndims(tgtErrRPs(iTgt).corrEpochs) == 2                                   %#ok<ISMAT> % only 1 epoch, no mean
        corrMeanTgt(iTgt,:,:) = tgtErrRPs(iTgt).corrEpochs;
    end
    % Only mean values if more than 1 epoch
    [~,nIncorrTrials(iTgt),nSamples] = size(tgtErrRPs(iTgt).incorrEpochs);
    switch nIncorrTrials(iTgt)
        case 0                                                                      % no epochs for this target location for incorrect trials
            fprintf('For target %i no incorrect epochs available\n',iTgt)
        case 1                                                                      % only one epoch for this target location for incorrect trials
            incorrMeanTgt(iTgt,:,:) = tgtErrRPs(iTgt).incorrEpochs;
            fprintf('For target %i only 1 epoch available\n',iTgt)
        otherwise                                                                   % getting mean vals for incorrect trials
            fprintf('For target %i, %i epochs available\n',iTgt,nIncorrTrials(iTgt))
            incorrMeanTgt(iTgt,:,:) = squeeze(mean(tgtErrRPs(iTgt).incorrEpochs,2));
    end
    
    %% standard deviation or error    
    if ErrorInfo.plotInfo.stdError
        corrStdErro(iTgt)    =  sqrt(size(tgtErrRPs(iTgt).corrEpochs,2));        % get standard error of the mean
        incorrStdError(iTgt) =  sqrt(tgtErrRPs(iTgt).nIncorrTrials);             % get standard error of the mean
    else
        corrStdError(iTgt)    = 1;    % get standard deviation
        incorrStdError(iTgt)  = 1;    % get standard deviation
    end
  
    % Standard deviation/error per location
    corrStdTgt(iTgt,:,:) = squeeze(nanstd(tgtErrRPs(iTgt).corrEpochs,0,2))/corrStdError(iTgt);  % standard deviation for this target
    incorrStdTgt(iTgt,:,:) = squeeze(nanstd(tgtErrRPs(iTgt).incorrEpochs,0,2))/incorrStdError(iTgt);
end

%% Agregate channels and trials per array for mean and st.dev./error
nChsPerArray = length(ErrorInfo.plotInfo.arrayChs(1,:));
for iArray = 1:ErrorInfo.plotInfo.nArrays
   for iTgt = 1:nTgts
       fprintf('Calculating array mean and std for target %i...\n',iTgt)
       % Correct epochs
       if nCorrTrials(iTgt) == 0                                    % no epochs
           corrMeanTgtArray(iArray,iTgt,:) = zeros(1,nSamples);     %#ok<*AGROW>
           corrStdTgtArray(iArray,iTgt,:) = zeros(1,nSamples);
       elseif nCorrTrials(iTgt) == 1                                % only one epoch
           corrMeanTgtArray(iArray,iTgt,:) = squeeze(nanmean(tgtErrRPs(iTgt).corrEpochs(plotInfo.arrayChs(iArray,:),:),1));
           corrStdTgtArray(iArray,iTgt,:) = squeeze(nanstd(tgtErrRPs(iTgt).corrEpochs(plotInfo.arrayChs(iArray,:),:),1));
       else
           corrMeanTgtArray(iArray,iTgt,:) = nanmean(reshape(tgtErrRPs(iTgt).corrEpochs(plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*nCorrTrials(iTgt) nSamples]),1);
           corrStdTgtArray(iArray,iTgt,:) = nanstd(reshape(tgtErrRPs(iTgt).corrEpochs(plotInfo.arrayChs(iArray,:),:,:),[nChsPerArray*nCorrTrials(iTgt) nSamples]),[],1)/corrStdError(iTgt);  % standard deviation for this target;
       end
       
       % Incorrect epochs
       if nIncorrTrials(iTgt) == 0                                  % no epochs
           error('No trials for this target')
           incorrMeanTgtArray(iArray,iTgt,:) = zeros(1,nSamples);   %#ok<UNRCH>
           incorrStdTgtArray(iArray,iTgt,:) = zeros(1,nSamples);   
       elseif nIncorrTrials(iTgt) == 1                              % only one epoch
           incorrMeanTgtArray(iArray,iTgt,:) = squeeze(nanmean(tgtErrRPs(iTgt).incorrEpochs(plotInfo.arrayChs(iArray,:),:),1));
           incorrStdTgtArray(iArray,iTgt,:) = squeeze(nanstd(tgtErrRPs(iTgt).incorrEpochs(plotInfo.arrayChs(iArray,:),:),1));        %#ok<*NASGU>
       else                                                         % more than one epoch
           incorrMeanTgtArray(iArray,iTgt,:) = nanmean(reshape(tgtErrRPs(iTgt).incorrEpochs(plotInfo.arrayChs(iArray,:),:),[nChsPerArray*nIncorrTrials(iTgt) nSamples]),1);
           incorrStdTgtArray(iArray,iTgt,:) = nanstd(reshape(tgtErrRPs(iTgt).incorrEpochs(plotInfo.arrayChs(iArray,:),:),[nChsPerArray*nIncorrTrials(iTgt) nSamples]),1)/incorrStdError(iTgt);
       end
   end
end

