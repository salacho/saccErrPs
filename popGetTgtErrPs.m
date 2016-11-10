function [popTgtErrPs,popTgt2DistEpochs,meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,ErrorInfo] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popDcdTgt)
% function [meanPopTgt,meanPopDist2Tgt,stdPopDist2Tgt,ErrorInfo] = popGetTgtErrPs(sessionList,popCorr,popIncorr,popDcdTgt)
%
%  Gets epochs for population using either sessionList (from scratch) or
%  using popCorr and popIncorr and popDcdTgt. The files have the save
%  format of 
%
%
% INPUT
% popCorr:          matrix [nChannels x nTrials x nSamples]. Correct trials
% popIncorr:        matrix [nChannels x nTrials x nSamples]. Incorrect trials
% popDcdTgt:        structure. Has fields:
%     corrDcdTgt:   vector. Decoded target for correctly decoded trials 
%     corrExpTgt:   vector. Expected (true) target for correct trials
%     incorrDcdTgt: vector. Decoded target for incorrectly decoded trials
%     incorrExpTgt: vector. expected target for incorrect trials
%
% OUTPUT
% 
%
% Author:   Andres 
%
% Andres    :   v1.0    : init. Created 31 Oct 2014

tStart = tic;
nTgts = 6;
ErrorInfo = [];

%% Either load each session files or separate the population correct and incorrect epochs per target 
if nargin == 1
    %% If only sessionList means popCorr and popIncorr have not being collected yet. Run each session...
    disp('Collecting all epochs for all sessions one at a time...')
    for iSess = 1:length(sessionList)
        % Select sessions
        session = sessionList{iSess};
        fprintf('.\n.\n.\n.%s...\n',session)
        
        % load paths and dirs
        dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
        ErrorInfo = setDefaultParams(session,dirs);
        
        if iSess == 1
            nTgts = 6;
            nChs = ErrorInfo.nChs; %#ok<*NASGU>
            nSamps = ErrorInfo.epochInfo.epochLen;
            
            % Preallocate memory
            popTgtErrPs = repmat(struct(...
                'corrEpochs',[],...
                'incorrEpochs',[],...
                'incorrDcdTgt',[],...
                'nIncorrDcdTgts',[0 0 0 0 0 0],...
                'nIncorrTrials',[],...
                'normIncorrDcdTgts',[0 0 0 0 0 0]),...
                [nTgts,1]);
            
            popTgt2DistEpochs = repmat(struct(...
                'dist2tgt',[],...
                'dcdTgtRange',[],...
                'numEpochsPerDist',[0 0 0],...
                'normNumEpochsPerDist',[],...
                'dcdTgtDist1',[],...
                'epochDist1',[],...
                'dcdTgtDist2',[],...
                'epochDist2',[],...
                'dcdTgtDist3',[],...
                'epochDist3',[]),...
                [nTgts,1]);
        end
        
        % load files
        [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
        disp('Done loading')
        % Downsampling files!! Finally!!
        [corrEpochs,incorrEpochs,ErrorInfo] = downSampEpochs(corrEpochs,incorrEpochs,ErrorInfo);
        % Get tgtErrPs
        [tgtErrRPs,ErrorInfo] = getTgtErrRPs(corrEpochs,incorrEpochs,ErrorInfo);
        disp('Done getting tgtErr')
        clear corrEpochs incorrEpochs
        % Get dist2Tgt
        [tgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(tgtErrRPs,ErrorInfo);
        disp('Done dist2tgt')
        
        %% Separate per target
        for iTgt = 1:nTgts
            %add tgtErrPs to popTgtErrPs
            popTgtErrPs(iTgt).corrEpochs     = [popTgtErrPs(iTgt).corrEpochs  tgtErrRPs(iTgt).corrEpochs];
            popTgtErrPs(iTgt).incorrEpochs   = [popTgtErrPs(iTgt).incorrEpochs  tgtErrRPs(iTgt).incorrEpochs];
            popTgtErrPs(iTgt).incorrDcdTgt   = [popTgtErrPs(iTgt).incorrDcdTgt; tgtErrRPs(iTgt).incorrDcdTgt];
            popTgtErrPs(iTgt).nIncorrTrials  = popTgtErrPs(iTgt).nIncorrTrials + tgtErrRPs(iTgt).nIncorrTrials;
            popTgtErrPs(iTgt).nIncorrDcdTgts = popTgtErrPs(iTgt).nIncorrDcdTgts + tgtErrRPs(iTgt).nIncorrDcdTgts;
            disp('Done popTgtErrPs')
            
            %% add tgt2DistEpochs to popTgt2DistEpochs
            popTgt2DistEpochs(iTgt).numEpochsPerDist = popTgt2DistEpochs(iTgt).numEpochsPerDist + tgt2DistEpochs(iTgt).numEpochsPerDist;
            for iDist = 1:3
                eval(sprintf('popTgt2DistEpochs(iTgt).dcdTgtDist%i = [popTgt2DistEpochs(iTgt).dcdTgtDist%i tgt2DistEpochs(iTgt).dcdTgtDist%i];',iDist,iDist,iDist))
                % Kludge!! Some epochDist do not have epochs..no errors for
                % this dist2tgt
                if eval(sprintf('ndims(tgt2DistEpochs(iTgt).epochDist%i) == 3',iDist))
                    eval(sprintf('popTgt2DistEpochs(iTgt).epochDist%i = [popTgt2DistEpochs(iTgt).epochDist%i tgt2DistEpochs(iTgt).epochDist%i];',iDist,iDist,iDist))
                elseif eval(sprintf('(ndims(tgt2DistEpochs(iTgt).epochDist%i) == 2) && (~isempty(tgt2DistEpochs(iTgt).epochDist%i))',iDist,iDist))
                    eval(sprintf('tgt2DistEpochs(iTgt).epochDist%i = reshape(tgt2DistEpochs(iTgt).epochDist%i,[nChs,1,nSamps]);',iDist,iDist))
                    eval(sprintf('popTgt2DistEpochs(iTgt).epochDist%i = [popTgt2DistEpochs(iTgt).epochDist%i tgt2DistEpochs(iTgt).epochDist%i];',iDist,iDist,iDist))
                else    %is empty, do nothing!
                end
            end
            disp('Done popTgt2DistEpochs')
        end
        clear tgtErrRPs
    end
    
    % corr and incorr epochs for all sessionList have already being collected.
    % Only need to separate them per target
else
    %% If popCorr and popIncorr are ready, only separate them per target
    disp('Separating popCorr and popIncorr...')
    if strcmpi(popDcdTgt.subject,'chico')
        popDcdTgt.epochInfo.corrDcdTgt = popDcdTgt.corrDcdTgt;
        popDcdTgt.epochInfo.corrExpTgt = popDcdTgt.corrExpTgt;
        popDcdTgt.epochInfo.incorrDcdTgt = popDcdTgt.incorrDcdTgt;
        popDcdTgt.epochInfo.incorrExpTgt = popDcdTgt.incorrExpTgt;
    end
    ErrorInfo = popDcdTgt;
    [popTgtErrPs,popDcdTgt] = getTgtErrRPs(popCorr,popIncorr,popDcdTgt);
    % Get popDist2Tgt
    [popTgt2DistEpochs,numSampErrTrials] = getTgt2DistEpochs(popTgtErrPs,popDcdTgt);

    %% add tgt2DistEpochs to popTgt2DistEpochs
    %popTgt2DistEpochs(iTgt).epochDist
    %popTgt2DistEpochs(iTgt).numEpochsPerDist
    
end

% Needs to be done once all sessions are run
for iTgt = 1:nTgts
    popTgtErrPs(iTgt).nIncorrTrials = sum(popTgtErrPs(iTgt).nIncorrDcdTgts);
    popTgtErrPs(iTgt).normIncorrDcdTgts = popTgtErrPs(iTgt).nIncorrDcdTgts/popTgtErrPs(iTgt).nIncorrTrials;
    popTgt2DistEpochs(iTgt).nIncorrTrials = sum(popTgt2DistEpochs(iTgt).numEpochsPerDist);
    popTgt2DistEpochs(iTgt).normNumEpochsPerDist = popTgt2DistEpochs(iTgt).numEpochsPerDist/popTgt2DistEpochs(iTgt).nIncorrTrials;
end

tElapsed = toc(tStart);
fprintf('It took %i minutes to collect tgtErrPs and dist2Tgt info for all the sessions...\n',tElapsed/60)

%% Get mean trials and sessions epoch per dist2Tgt
for iTgt = 1:6
    fprintf('Calculating pop. mean and st.dev. for all trials and sessions for dist2Tgt for target %i...\n',iTgt)
    % Corr mean 
    meanPopDist2Tgt(iTgt).corr = squeeze(nanmean(popTgtErrPs(iTgt).corrEpochs,2));
    % Corr st.dev.
    stdPopDist2Tgt(iTgt).corr =  squeeze(nanstd(popTgtErrPs(iTgt).corrEpochs,[],2));
    % Incorr Mean
    meanPopDist2Tgt(iTgt).dist1 = squeeze(nanmean(popTgt2DistEpochs(iTgt).epochDist1,2));
    meanPopDist2Tgt(iTgt).dist2 = squeeze(nanmean(popTgt2DistEpochs(iTgt).epochDist2,2));
    meanPopDist2Tgt(iTgt).dist3 = squeeze(nanmean(popTgt2DistEpochs(iTgt).epochDist3,2));
    % Incorr st.dev.
    stdPopDist2Tgt(iTgt).dist1 = squeeze(nanstd(popTgt2DistEpochs(iTgt).epochDist1,[],2));
    stdPopDist2Tgt(iTgt).dist2 = squeeze(nanstd(popTgt2DistEpochs(iTgt).epochDist2,[],2));
    stdPopDist2Tgt(iTgt).dist3 = squeeze(nanstd(popTgt2DistEpochs(iTgt).epochDist3,[],2));
    % nTrials
    meanPopDist2Tgt(iTgt).dist1numTrials = popTgt2DistEpochs(iTgt).numEpochsPerDist(1);
    meanPopDist2Tgt(iTgt).dist2numTrials = popTgt2DistEpochs(iTgt).numEpochsPerDist(2);
    meanPopDist2Tgt(iTgt).dist3numTrials = popTgt2DistEpochs(iTgt).numEpochsPerDist(3);
    meanPopDist2Tgt(iTgt).corrNumTrials = size(popTgtErrPs(iTgt).corrEpochs,2);
end

%clear popTgt2DistEpochs 

%% Get mean trials and sessions per Tgt
for iTgt = 1:6
    fprintf('Calculating pop. mean and st.dev. for all trials and sessions for target %i...\n',iTgt)
    % Corr mean 
    meanPopTgt(iTgt).corr = squeeze(nanmean(popTgtErrPs(iTgt).corrEpochs,2));
    meanPopTgt(iTgt).incorr = squeeze(nanmean(popTgtErrPs(iTgt).incorrEpochs,2));
    % Corr st.dev.
    %       Error using nanvar (line 68)
    %       The length of W must be compatible with X.
%     stdPopTgt(iTgt).corr = squeeze(nanstd(popTgtErrPs(iTgt).corrEpochs,2));         % Out of memory?
%     stdPopTgt(iTgt).incorr = squeeze(nanstd(popTgtErrPs(iTgt).incorrEpochs,2));
    % nTrials
    meanPopTgt(iTgt).corrNumTrials = size(popTgtErrPs(iTgt).corrEpochs,2);
    meanPopTgt(iTgt).incorrNumTrials = size(popTgtErrPs(iTgt).incorrEpochs,2);
end

warning('Need to get all trials of all sessions together to get mean and std regardless of target!!!')


% %% Save
% ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
% % Save the two structures
% saveFilename = createFileForm(ErrorInfo.decoder,ErrorInfo,'popErrPs');
% fprintf('Saving population matrix in folder...\n%s\n',saveFilename)
% tStart = tic;
% 
% save(saveFilename,'meanPopDist2Tgt','stdPopDist2Tgt','meanPopTgt','sessionList','ErrorInfo','-v7.3')
% tElapsed = toc(tStart);
% fprintf('It took %i minutes \n',tElapsed/60)
   

end
