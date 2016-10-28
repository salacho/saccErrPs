function [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = loadErrSpikes(ErrorInfo)
% function [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = loadErrSpikes(ErrorInfo)
% 
% Loads previously saved cell arrays containing all cells and units obtained 
% from the 'nrn' file. All spike data is for correct and incorrect trials, 
% for all channels/cells/units. All spikes are 'rasterized' to create
% same-size matrices for both correct and incorrect trials (for all cells/units/channels)
%
% INPUTS
% ErrorInfo:           structure with all params and features for the analysis 
%                      of the session, trial, epoch, LFPs and spike data.
% OUTPUT
% corrRaster:          matrix. [nChs, nTrials, length of epoch givern by 
%                      preOutcome and postOutcome times]. Has zeros and ones.
%                      Ones represent events/spikes for correct trials
% incorrRaster:        matrix. [nChs, nTrials, length of epoch givern by 
%                      preOutcome and postOutcome times]. Has zeros and ones.
%                      Ones represent events/spikes for incorrect trials
% corrSpkTimes:        cell array with as many rows as channels or units. 
%                      Each channel/unit is a cell with spike times
%                      for each correct trial.
% incorrSpkTimes:      cell array with as many rows as channels or units. 
%                      Each channel/unit is a cell with spike times
%                      for each incorrect trial.
% ErrorInfo:           structure with all params and features for the analysis 
%                      of the session, trial, epoch, LFPs and spike data.
%
% Author : Andres. 
% 
% Andres :  v1.0    :   init. 22 Oct 2014
% Andres :  

% Name of file to load
infoStr = getInfoStr(ErrorInfo);

%% Get spike root filename
ErrorInfo = createSpikeFileForm(ErrorInfo);

% Get filename 
loadFilename = sprintf('%s-corrIncorrSpikes-[%i-%ims]%s.mat',infoStr.strPrefix,...
    ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.spikeInfo.txtRoot);

% if file exists
if (exist(loadFilename,'file') == 2)
    fprintf('Loading file %s...\nBe patient...\n',loadFilename)
    % load the file
    spk = load(loadFilename);
    corrSpkTimes = spk.corrSpkTimes;
    incorrSpkTimes = spk.incorrSpkTimes;
    
    % Updating ErrorInfo structure
    % BEWARE!! Do not change all the parameters in the newer
    % ErrorInfo.spikeInfo structure, only add those params that are not
    % already in it.
    oldStruct = spk.ErrorInfo.spikeInfo;
    newStruct = ErrorInfo.spikeInfo;
    ErrorInfo.spikeInfo = updateStructFields(newStruct,oldStruct);      % update structure with spike-ralted values saved in old ErrorInfo.spikeInfo
     
    % Rasterize spike data
    disp('Rasterizing...')
    [corrRaster,incorrRaster,ErrorInfo] =  getRasterMatrix(corrSpkTimes,incorrSpkTimes,ErrorInfo);      % Notice ErrorInfo here is the ew one, that the saved one
% if no file, then run all the analysis and extract spikes from 'nrn' files
else
    warning('Could not find file: %s...\nExtracting spike times and creating cell arrays...all analysis from beginning, be patient...\n',loadFilename) %#ok<WNTAG>
    [corrRaster,incorrRaster,ErrorInfo] = newErrSpikes(ErrorInfo);
end

end
