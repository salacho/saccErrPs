function [corrRaster,incorrRaster,ErrorInfo] =  getRasterMatrix(corrSpkTimes,incorrSpkTimes,ErrorInfo) %#ok<INUSL>
% function [corrRaster,incorrRaster,ErrorInfo] =  getRasterMatrix(corrSpkTimes,incorrSpkTimes,ErrorInfo)
%
% Rasterizes spike activity for all correct and incorrect trials using cell arrays 
% containing spike data for each trial and cell/unit/channel 
%
% INPUT
% chSpkVector:              vector. Each row is related to the channel in the same row 
%                           of corrTrialSpkTimes and incorrTrialSpkTimes (since same channel for several units)
% unitSpkVector:            vector. Has the unit number for each channel/unit/row of 
%                           corrTrialSpkTimes and incorrTrialSpkTimes
% ErrorInfo:                structure will all params and features for the analysis 
%                           of the session, trial, epoch, LFPs and spike data.
% OUTPUT
% corrRaster:               matrix. [nChs, nTrials, length of epoch givern by 
%                           preOutcome and postOutcome times]. Has zeros and ones.
%                           Ones represent events/spikes for correct trials
% incorrRaster:             matrix. [nChs, nTrials, length of epoch givern by 
%                           preOutcome and postOutcome times]. Has zeros and ones.
%                           Ones represent events/spikes for incorrect trials
% ErrorInfo:                structure will all params and features for the analysis 
%                           of the session, trial, epoch, LFPs and spike data.
%
% Author : Andres. Following some guidelines used in nrn2bci.m from offlineBCI (Scott Brincat)
% 
% Andres :  v1.0    :   21 Oct 2014. init    
% Andres :  

%% Create rasterTrials matrix for both outcomes
disp('...'), disp('...'), disp('...')
dataNames = {'corrSpkTimes','incorrSpkTimes'};
for iOut = 1:length(dataNames)
    data2Raster = eval(dataNames{iOut});
    disp(strcat('Rasterizing-',dataNames{iOut}))
    [rasterChsTrials,ErrorInfo] = getRaster(data2Raster,ErrorInfo);
    % Includes all cells + empty channel (which will have zero activity)
    if iOut == 1 
        corrRaster = rasterChsTrials; 
    else
        incorrRaster = rasterChsTrials;
    end
end

if (size(corrRaster,1) ~= size(incorrRaster,1)) || (size(corrRaster,3) ~= size(incorrRaster,3))
    error('corrRaster and incorrRaster file size not matching!!!')
end

% Update ErrorInfo, number of trials per outcome
ErrorInfo.spikeInfo.nCorr = size(corrRaster,2);
ErrorInfo.spikeInfo.nErr = size(incorrRaster,2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rasterChsTrials,ErrorInfo] = getRaster(data2Raster,ErrorInfo)
% function rasterTrials = getRaster(data2Raster,ErrorInfo)
%
% Convert all trials into a same size matrix [nChs, nTrials, epochWindow] with ones when spikes occurred. 
% 
% INPUT
% data2Raster:      cell array containing for each cell/unit/channel all the time stamps for all trials. 
%                   Each channel/cell/unit is itself a cell array with each element being spike times per trial. 
% ErrorInfo:        structure with all parameters and info related to decoder,
%                   analysis, etc...
% OUTPUT
% rasterChsTrials:  matrix. [nChs, nTrials, length of epoch givern by preOutcome
%                   and postOutcome times]. Has zeros and ones. Ones represent events/spikes
%
% Author : Andres
% 
% Andres :  init    : 15 Oct 2014
% Andres :  v1.1    : added support for collecting spike data in same-size matrix for all channels/cells/units, and all trials. 

nChs = ErrorInfo.spikeInfo.nCellUnits;         % number of channles/units/cells
nTrials = 0;
for iChs = 1:nChs, nTrials =  max(nTrials,length(data2Raster{iChs})); end           % sometimes the channels do not have trials (no units nor cells)
spkSampFreq = ErrorInfo.spikeInfo.spkSampFreq;

%% Here starts getRasterTrials
timeVector = (-ErrorInfo.spikeInfo.preOutcomeTime/1000:1/spkSampFreq:ErrorInfo.spikeInfo.postOutcomeTime/1000); % values in milliseconds;
nSpkSamp = length(timeVector); % values in milliseconds;
reDimCheck = nan(nChs,nTrials,1);
% Master matrix for all channels, trials and samples in the window from preOutcome to postOutcome time
rasterChsTrials = int8(zeros(nChs,nTrials,nSpkSamp));
% Update the ErrorInfo structure

ErrorInfo.spikeInfo.nSpkSamp = nSpkSamp;
ErrorInfo.spikeInfo.timeVector = timeVector(:);

%% Create matrix for each channel/unit for all trials of this outcome
for iCh = 1:nChs
    disp(strcat('Rasterizing cell',num2str(iCh),'...'))
    for iTrial = 1:nTrials
        % in ms (+ ErrorInfo.spikeInfo.preOutcomeTime) shifts to the left, to have everything starting at zero
        
        % Kludge! Cells/units that do not exist give channels with zero
        % spikes, hence its dimensionality is different, size(xx(iCh),2) = 1, not 'nTrials'
        if size(data2Raster{iCh},2) ~= 1
            % Kludge! In case a given trial does not have spikes (is empty)
            if isempty(data2Raster{iCh}{iTrial})
                reDimCheck(iCh,iTrial) = 0; dimCheck{iCh,iTrial} = 0;     %#ok<*AGROW>
            else
                % Since time starts in zero (after shifting to right by preOutcomeTime) but samples indexes start in 1, add 1  
                trialTimes2Samps = round(((data2Raster{iCh}{iTrial}' + ErrorInfo.spikeInfo.preOutcomeTime)/1000)*spkSampFreq + 1);      % convert spike times (in milliseconds) to sample index (1/30k) so it is properly placed in 'rasterTrials'
                rasterChsTrials(iCh,iTrial,trialTimes2Samps) = 1;
                reDimCheck(iCh,iTrial)  = sum(trialTimes2Samps  - (((data2Raster{iCh}{iTrial}' + ErrorInfo.spikeInfo.preOutcomeTime)/1000)*spkSampFreq + 1));
                dimCheck{iCh,iTrial}    = trialTimes2Samps      - (((data2Raster{iCh}{iTrial}' + ErrorInfo.spikeInfo.preOutcomeTime)/1000)*spkSampFreq + 1); 
            end
        else
            reDimCheck(iCh,iTrial) = 0; dimCheck{iCh,iTrial} = 0;
        end
    end
end

% % Sample number difference due to rounding
% plot(reDimCheck)        % these differences are due to the floating number properties of Matlab. Usually the difference in the timestep value is 1e-7, in sample space, not time 1e-7 of 1/30k (spkSampFreq)
% title('reDimCheck, floating number sample difference for each ch!!')

end
