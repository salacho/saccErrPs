function [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = newErrSpikes(ErrorInfo)
% function [corrRaster,incorrRaster,corrSpkTimes,incorrSpkTimes,ErrorInfo] = newErrSpikes(ErrorInfo)
% 
% Loads all cells and units in 'nrn' file, gets spike data for correct and 
% incorrect trials for all channels/cells/units, and organize them in cell arrays with 
% all trials and channels for the analysis window between preOutcome and postOutcome
% time.
%
% INPUTS
% ErrorInfo:                structure will all params and features for the analysis 
%                           of the session, trial, epoch, LFPs and spike data.
% OUTPUT
% corrRaster:               matrix. [nChs, nTrials, length of epoch givern by 
%                           preOutcome and postOutcome times]. Has zeros and ones.
%                           Ones represent events/spikes for correct trials
% incorrRaster:             matrix. [nChs, nTrials, length of epoch givern by 
%                           preOutcome and postOutcome times]. Has zeros and ones.
%                           Ones represent events/spikes for incorrect trials
% corrSpkTimes:             cell array with as many rows as channels or units. 
%                           Each channel/unit is a cell with spike times
%                           for each correct trial.
% incorrSpkTimes:           cell array with as many rows as channels or units. 
%                           Each channel/unit is a cell with spike times
%                           for each incorrect trial.
% ErrorInfo:                structure will all params and features for the analysis 
%                           of the session, trial, epoch, LFPs and spike data.
%     chSpkVector:          vector. Each row is related to the channel in the same row 
%                           of corrSpkTimes and incorrSpkTimes (since same channel for several units)
%     unitSpkVector:        vector. Has the unit number for each channel/unit/row of 
%                           corrSpkTimes and incorrSpkTimes
%
% Author : Andres. Following some guidelines used in nrn2bci.m from offlineBCI (Scott Brincat)
% 
% Andres :  v1.0     :   15 Oct 2014. init
% Andres :  v1.1    :   21 Oct 2014. Removed rasterizing from here and gcreated its own function
%                       getRasterMatrix.m

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%') 
fprintf('Starting ErrSpike analysis for %s\n',ErrorInfo.session)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

%% Get outcomeInfo using same params applied to get ErrPs
blockType = ErrorInfo.epochInfo.blockType;
decodOnly = ErrorInfo.epochInfo.decodOnly;
[ErrorInfo,OutcomeInfo] = getOutcmInfo(ErrorInfo,blockType,decodOnly);

% Saving the expected and decoded target (ground true and decoder's value)
iOutVal = 'outcm1';
ErrorInfo.spikeInfo.corrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
ErrorInfo.spikeInfo.corrDcdTgt = OutcomeInfo.(iOutVal).Response;
iOutVal = 'outcm7';
ErrorInfo.spikeInfo.incorrExpTgt = OutcomeInfo.(iOutVal).ExpectedResponse;
ErrorInfo.spikeInfo.incorrDcdTgt = OutcomeInfo.(iOutVal).Response;

%% Load file with all cells (channel) and units (sorted and unsorted)
if ErrorInfo.spikeInfo.manSorted, spkStr = '-sorted';
else spkStr = '';
end
    
spk = load(fullfile(ErrorInfo.dirs.DataIn,ErrorInfo.session,strcat(ErrorInfo.session,'-nrn',spkStr,'.mat')));

%% Params for cells and units
% Including unsorted spikes?
if strcmp(ErrorInfo.spikeInfo.spikeType,'unsorted')
    unitStart = 1; disp('Including unsorted spikes!');
else unitStart = 2; disp('Unit zero omitted, only sorted spikes!');
end

% Do individual units? Here unsorted units are taken into account
if ~ErrorInfo.spikeInfo.lumpUnits
    % Finding number of units per channel. SpikeInfo.nUnits gives total units incl. unsorted per channel.
    % Subtract out the first unit if not including unsorted
    ErrorInfo.spikeInfo.chNumUnits = max([spk.SpikeInfo(:).nUnits]' - (unitStart-1), 0);
    disp('Extracting spike data for each unit!');
else  % For analysis based on units lumped together w/in channels
    ErrorInfo.spikeInfo.chNumUnits = [spk.SpikeInfo(:).nUnits]' ~= 0;   % Set all == 1, except for chnls w/ no spikes
    disp('Extracting spike data for chnl-lumped multiunits!');
end

ErrorInfo.spikeInfo.nActiveChs = sum(ErrorInfo.spikeInfo.chNumUnits ~=0);
ErrorInfo.spikeInfo.nEmptyChs = sum((ErrorInfo.spikeInfo.chNumUnits(1:96)') == 0);

%% Load each cell and unit
cellUnitCount = 0;
% % Vector pointing the channel or unit for the corrSpktTime and incorrSpktTime
% chSpkVector = nan(,1);
% % Vector pointing the unit number for the corrSpktTime and incorrSpktTime
% unitSpkVector = nan(,1);

for iCh = 1:ErrorInfo.nChs
    disp(['Channel: ',num2str(iCh)]);
    
    % No units = no spikes, not even unsorted units. Move on.
    if ErrorInfo.spikeInfo.chNumUnits(iCh) == 0         
        disp('No units, not even unsorted!!')
        % Update cell/unit 
        cellUnitCount = cellUnitCount + 1;
        
        % Vector pointing the channel number for the corrSpktTime and incorrSpktTime
        chSpkVector(cellUnitCount,1) = iCh; %#ok<*AGROW>
        % Label units
        unitSpkVector(cellUnitCount,1) = NaN;
        
        % Putting zero spikes in the matrix
        corrSpkTimes{cellUnitCount} = 0;
        incorrSpkTimes{cellUnitCount} = 0;
        continue;
    end
    
    % If only analyzing channels with sorted units, skip ones that don't have any (ie, nUnits > the 1 unsorted 'unit')
    if ErrorInfo.spikeInfo.useChnlsWithUnitsOnly && (spk.SpikeInfo(iCh).nUnits < 2)
        disp('No sorted units!!')
        % Update cell/unit 
        cellUnitCount = cellUnitCount + 1;

        % If only channels with sorted units but there are unsorted, is like not having units at all -> set to zero 
        ErrorInfo.spikeInfo.chNumUnits(iCh) = 0;
 
        % Vector pointing the channel number for the corrSpktTime and incorrSpktTime
        chSpkVector(cellUnitCount,1) = iCh;
        % Label units
        unitSpkVector(cellUnitCount,1) = NaN;

        corrSpkTimes{cellUnitCount} = 0;
        incorrSpkTimes{cellUnitCount} = 0;
        continue;
    end
    
    % Load spike times
    if ErrorInfo.spikeInfo.lumpUnits
        % If all spike times grouped together, not separated by sorted units
        spkTimes = [];
        for iUnit = unitStart:spk.SpikeInfo(iCh).nUnits                                          % taking into account if including the ubnsorted unit
            spikeData = eval(sprintf('spk.nrn_c%03d_u%02d',iCh, spk.SpikeInfo(iCh).Units(iUnit)));
            spkTimes = [spkTimes; spikeData];
        end
        % Order spike times
        spkTimes = sort(spkTimes);
        [corrTrialSpkTimes,incorrTrialSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo);         % in milliseconds, with zero as feedback onset time
        % Update cell/channel number
        cellUnitCount = cellUnitCount + 1;
        
        % Save values in cell array
        corrSpkTimes{cellUnitCount} = corrTrialSpkTimes;
        incorrSpkTimes{cellUnitCount} = incorrTrialSpkTimes;
        
        % Vector pointing the channel number for the corrSpktTime and incorrSpktTime
        chSpkVector(cellUnitCount,1) = iCh;
        % Vector pointing the unit number for the corrSpktTime and incorrSpktTime
        unitSpkVector(cellUnitCount,1) = NaN;
    else
        % Spike times for each unit (within a cell/channel)
        for iUnit = unitStart:spk.SpikeInfo(iCh).nUnits
            % Update cell/channel number
            cellUnitCount = cellUnitCount + 1;
            fprintf('Cell %i, unit %i...\n',iCh,spk.SpikeInfo(iCh).Units(iUnit))
            % Load unit
            spkTimes = eval(sprintf('spk.nrn_c%03d_u%02d',iCh, spk.SpikeInfo(iCh).Units(iUnit)));
            [corrTrialSpkTimes,incorrTrialSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo);  	% in milliseconds, with zero as feedback onset time
            
            % Save values in cell array
            corrSpkTimes{cellUnitCount} = corrTrialSpkTimes;
            incorrSpkTimes{cellUnitCount} = incorrTrialSpkTimes;
            
            % Vector pointing the channel number for the corrSpktTime and incorrSpktTime
            chSpkVector(cellUnitCount,1) = iCh;
            % Vector pointing the unit number for the corrSpktTime and incorrSpktTime
            unitSpkVector(cellUnitCount,1) = spk.SpikeInfo(iCh).Units(iUnit);
        end
    end
end

ErrorInfo.spikeInfo.nCellUnits = cellUnitCount;
% Update ErrorInfo, mapping of units and channel in corr and incorr cell arrays
ErrorInfo.spikeInfo.chSpkVector = chSpkVector;
ErrorInfo.spikeInfo.unitSpkVector = unitSpkVector;
% Cells/units per array
for iArray = 1:ErrorInfo.BCIparams.nArrays
    ErrorInfo.spikeInfo.arrayCellUnits{iArray} = (ErrorInfo.spikeInfo.chSpkVector >= ErrorInfo.BCIparams.arrayChs(iArray,1)) & ...
      (ErrorInfo.spikeInfo.chSpkVector <= ErrorInfo.BCIparams.arrayChs(iArray,end));
end

%% Get spike root filename
ErrorInfo = createSpikeFileForm(ErrorInfo);

%% Saving epochs
% Creating folder to save results if not there already
if ~(exist(fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session),'dir') == 7)
    mkdir(ErrorInfo.dirs.DataOut,ErrorInfo.session);      % Create folder
end
% Saving

if ErrorInfo.spikeInfo.saveSpikes
    saveFilename = sprintf('%s-corrIncorrSpikes-[%i-%ims]%s.mat',fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session),...
        ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,ErrorInfo.spikeInfo.txtRoot);
    save(saveFilename,'corrSpkTimes','incorrSpkTimes','ErrorInfo','-v7.3')
end

%% Rasterize spike data
[corrRaster,incorrRaster,ErrorInfo] =  getRasterMatrix(corrSpkTimes,incorrSpkTimes,ErrorInfo);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Get spite times for each channel (all trials included in cell array) 
% % function [corrSpkTimes,incorrSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo)
% function [corrSpkTimes,incorrSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo)
% % function [corrSpkTimes,incorrSpkTimes] = getSpkTimesForTrials(spkTimes,OutcomeInfo,ErrorInfo)
% %
% % Organize all spike times per trial and outcome (correct and incorrect),
% % for each spkTimes vector using trial times given in OutcomeInfo. All
% % these spike times belong to one channel or unit. Time zero is the feedback onset time, 
% % hence values span from -preOutcome to +postOutcome time, in milliseconds. 
% %
% % INPUT
% %
% % spkTimes:                 vector. Time stamps for spike events for all session. 
% % OutcomeInfo:              Structure with the following vector/cells:
% %     TimeUnits:            'ms'
% %     nTrials:              Total number of trials
% %     lastTrainTrial:       Last trial in the training block. Used to have
% %                           access to only decoder-controlled trials.
% %     outcmLbl:             Vector [7x1]. Number for that outcome.
% %     outcmTxt:             String. Name of the different outcomes ('correct',
% %                           'noFix','fixBreak','sacMaxRt','sacNoTrgt','sacBrk',
% %                           'inCorrect').
% %     noutcms:              String. Vector with total number of trials for each outcome.
% %     block:                String. Informs if trials used were from the first, 
% %                           second or third block ('Train','Blocked', 'Random' 
% %                           respectively). If all blockes are used 'All' is used instead.  
% %     nGoodTrls:            Number of good trials.
% %     BCtrials:             Brain/decoder-controlled trials
% %     BCcode:               EventCode for BC trials. For eye-controlled it is 5001. 
% %                           Refer to 'setBhvParam_dlySaccBCI_chico.m', check for 
% %                           bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
% %     outcm%i:              Structure with times for different events for outcome i (from 1 to 7).  
% % ErrorInfo:                Chronic Recording info structure. 
% %
% % OUTPUT
% %
% % corrSpkTimes:        cell array spike times for all correct trials.  
% %                           Each trial is a cell array with spike times
% %                           Each correct trial is a cell array with spike times.
% % incorrSpkTimes:      cell array spike times for all incorrect trials.  
% %                           Each incorrect trial is a cell with spike times
% %
% % Author : Andres
% % 
% % Andres :  init    : 15 Oct 2014
% % Andres :  
% 
% % Vbles for each outcome
% outcomes = {'outcm1','outcm7'};
% nOuts = length(outcomes);
% 
% % Running analysis for each outcome
% for iOut = 1:nOuts
%     fprintf('Extracting spike data for %s...\n',outcomes{iOut})
%     % Center of analysis window
%     if iOut == 1
%         %outcomeStimuli = OutcomeInfo.(outcomes{iOut}).juiceOn;         % correct target acknowledgement by delivering juice reward
%         outcomeStimuli = OutcomeInfo.(outcomes{iOut}).rwdStimOn;        % correct target presentation
%     else
%         outcomeStimuli = OutcomeInfo.(outcomes{iOut}).punChc;           % incorrect target presentation. Punishment
%     end
%     % Analysis window
%     analWindow(1,:) = (outcomeStimuli - ErrorInfo.spikeInfo.preOutcomeTime);
%     analWindow(2,:) = (outcomeStimuli + ErrorInfo.spikeInfo.postOutcomeTime);
%     
%     % Extract epochs per trial, per channel
%     for iTrial = 1:OutcomeInfo.(outcomes{iOut}).nTrials
%         % For each trial find spikes times within feedback onset. Also center spike times to feedback onset
%         outcomeSpk{iTrial} = spkTimes((spkTimes >= analWindow(1,iTrial)) & (spkTimes <= analWindow(2,iTrial))) - outcomeStimuli(iTrial);
%     end
%     
%     % Saving corr and incorr spike times
%     if iOut == 1
%         corrSpkTimes = outcomeSpk;
%     else
%         incorrSpkTimes = outcomeSpk;
%     end
%     clear outcomeSpk analWindow                                                     % erase these vbles to continue with the next outcome
% end
% 
% end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

