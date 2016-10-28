function [bci_npl2br] = bci_npl2br_checkNumTrialsAndPerf
% function [bci_npl2br] = bci_npl2br_checkNumTrialsAndPerf
%
% Checking the number of non-Nan trials for both the 'bci' vble saved online 
% and the 'EventInfo' trial vble from the br2npl.m code.  
%
% 
%
%
%
%
% Author    :   Andres
% andres    :   1.1     : init
%

%% Paths and dirs
dirs = initErrDirs;

%% Sessions
jonahSessionsOnline = {'JS20140414';'JS20140415';'JS20140416';'JS20140417';'JS20140418';...
'JS20140421';'JS20140422';'JS20140423';'JS20140424';'JS20140425'};
chicoSessionsOnline = {'CS20140409';'CS20140410';'CS20140411';...
'CS20140414';'CS20140415';'CS20140416';'CS20140417';'CS20140418';...
'CS20140421';'CS20140422';'CS20140423';'CS20140424';'CS20140425'};

%% Subjects
subjects = {'chico','jonah'};
maxSubj = length(subjects);
maxSess =  max(length(jonahSessionsOnline),length(chicoSessionsOnline));
minSess =  min(length(jonahSessionsOnline),length(chicoSessionsOnline));

% Results structure
bci_npl2br = struct(...
    'session','',...
    'yDcdTrials',[],...
    'yDcdNumTrials',[],...
    'yHatTrials',[],...
    'yHatNumTrials',[],...
    'saccDcdTgtTrials',[],...
    'saccDcdTgtNumTrials',[],...
    'saccActualTgtTrials',[],...
    'saccActualTgtNumTrials',[],...
    'feedbackEvtTrials',[],...
    'feedbackEvtNumTrials',[],...
    'goodTestTrials',[],...
    'goodTestNumTrials',[],...
    'IncorrTestTrials',[],...
    'IncorrTestNumTrials',[],...
    'TestCorrIncorrTrials',[],...
    'TestCorrIncorrNumTrials',[],...
    'bciErrDcdPerf',[],...
    'bciSaccDcdPerf',[],...
    'nplErrDcdPerf',[],...
    'nplSaccDcdPerf',[]);

% Setting dimensionality for all sessions and subjects
bci_npl2br = repmat(bci_npl2br,[maxSubj,maxSess]);

for iSbj = 1:length(subjects)
    iSubject = subjects{iSbj};
    
    % Get all sessions
    if strcmpi(iSubject,'chico')    % For Chico
        subjectSessions = chicoSessionsOnline;
    else                            % For Jonah
        subjectSessions = jonahSessionsOnline;
    end
    
    % All sessions per subject
    for iSess = 1:length(subjectSessions)
        session = subjectSessions{iSess};
        
        %% Load bci session-data from online recording
        bciDataFilename = fullfile(strrep(dirs.DataIn,'mat','raw'),session,[session,'-data.mat']);
        fprintf('Loading bci-data for %s...\n',session)
        bciData = load(bciDataFilename);
        
        %% Getting testing trials
        blockType = 0;
        decodOnly = 1;
        ErrorInfo.session = session;
        ErrorInfo.filedate = str2double(session(3:end));
        ErrorInfo.dirs = dirs;
        [ErrorInfo,OutcomeInfo] = getOutcmInfo(ErrorInfo,blockType,decodOnly);        %Get all events and possible outcomes
        
        %% Get number of trials that were BCI/brain-controlled
        % bci
        bci_npl2br(iSbj,iSess).session                 = session;
        bci_npl2br(iSbj,iSess).yDcdTrials              = ~isnan(bciData.bci.ErrPs.decoder.yDcd);
        bci_npl2br(iSbj,iSess).yDcdNumTrials           = sum(~isnan(bciData.bci.ErrPs.decoder.yDcd));
        bci_npl2br(iSbj,iSess).yHatTrials              = ~isnan(bciData.bci.ErrPs.decoder.yHat);
        bci_npl2br(iSbj,iSess).yHatNumTrials           = sum(~isnan(bciData.bci.ErrPs.decoder.yHat));
        bci_npl2br(iSbj,iSess).saccDcdTgtTrials        = ~isnan(bciData.bci.ErrPs.decoder.saccDcdTgt);
        bci_npl2br(iSbj,iSess).saccDcdTgtNumTrials     = sum(~isnan(bciData.bci.ErrPs.decoder.saccDcdTgt));
        bci_npl2br(iSbj,iSess).saccActualTgtTrials     = ~isnan(bciData.bci.ErrPs.decoder.saccActualTgt);
        bci_npl2br(iSbj,iSess).saccActualTgtNumTrials  = sum(~isnan(bciData.bci.ErrPs.decoder.saccActualTgt));
        bci_npl2br(iSbj,iSess).feedbackEvtTrials       = ~isnan(bciData.bci.ErrPs.decoder.feedbackEvt);
        bci_npl2br(iSbj,iSess).feedbackEvtNumTrials    = sum(~isnan(bciData.bci.ErrPs.decoder.feedbackEvt));
        % npl2br
        bci_npl2br(iSbj,iSess).goodTestTrials       = ErrorInfo.BCItrialInfo.goodTestTrials;
        bci_npl2br(iSbj,iSess).goodTestNumTrials    = sum(bci_npl2br(iSbj,iSess).goodTestTrials);
        bci_npl2br(iSbj,iSess).IncorrTestTrials   	= ErrorInfo.BCItrialInfo.IncorrTestTrials;
        bci_npl2br(iSbj,iSess).IncorrTestNumTrials  = sum(bci_npl2br(iSbj,iSess).IncorrTestTrials);
        bci_npl2br(iSbj,iSess).TestCorrIncorrTrials = ErrorInfo.BCItrialInfo.TestCorrIncorrTrials;
        bci_npl2br(iSbj,iSess).TestCorrIncorrNumTrials = sum(bci_npl2br(iSbj,iSess).TestCorrIncorrTrials);
        
        % bci online performance values
        trials = ~isnan(bciData.bci.ErrPs.decoder.saccDcdTgt);
        testNumTrials = sum(trials);
        corrDcdTrials = bciData.bci.ErrPs.decoder.feedbackEvt(trials) == 25;
        bci_npl2br(iSbj,iSess).bciErrDcdPerf = sum(bciData.bci.ErrPs.decoder.yDcd(trials) == corrDcdTrials)/testNumTrials*100;
        bci_npl2br(iSbj,iSess).bciSaccDcdPerf = sum(bciData.bci.ErrPs.decoder.saccActualTgt(trials) == bciData.bci.ErrPs.decoder.saccDcdTgt(trials))/testNumTrials*100;
        
        % npl2br online performance values
        yTrials = ~isnan(bciData.bci.ErrPs.decoder.yDcd);
        yDcdTestNumTrials = sum(yTrials);
        corrDcdTrials = bciData.bci.ErrPs.decoder.feedbackEvt(yTrials) == 25;
        bci_npl2br(iSbj,iSess).nplErrDcdPerf = sum(bciData.bci.ErrPs.decoder.yDcd(yTrials) == corrDcdTrials)/yDcdTestNumTrials*100;
        bci_npl2br(iSbj,iSess).nplSaccDcdPerf = sum(bciData.bci.ErrPs.decoder.saccActualTgt(yTrials) == bciData.bci.ErrPs.decoder.saccDcdTgt(yTrials))/yDcdTestNumTrials*100;
        
        %% Plot
        hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1301 513 922 420],...
                'name','Decoder Error Detection','visible','off')
            plot(bciData.bci.ErrPs.decoder.feedbackEvt(yTrials),'r'), hold on
            plot(bciData.bci.ErrPs.decoder.feedbackEvt(trials),'g--'),
        % Title text
        titleTxt = sprintf('%s-yDcdNum_RED%i-saccDcdNum_GREEN%i-bciErr%0.2f-bciSacc%0.2f-nplErr%0.2f-nplSacc%0.2f',...
            session,yDcdTestNumTrials,testNumTrials,...
            bci_npl2br(iSbj,iSess).bciErrDcdPerf,bci_npl2br(iSbj,iSess).nplErrDcdPerf,bci_npl2br(iSbj,iSess).bciSaccDcdPerf,bci_npl2br(iSbj,iSess).nplSaccDcdPerf);
        % Axis
        title(titleTxt,'FontWeight','Bold');
        xlabel('Trial number','FontWeight','Bold'), ylabel('Feedback value','FontWeight','Bold')
        
        %% Saving plot
        saveas(hFig,sprintf([titleTxt,'.png']))
        saveas(hFig,sprintf([titleTxt,'.fig']))
        close all
    end
end


end

