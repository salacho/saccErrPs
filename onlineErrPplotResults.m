function onlineRes = onlineErrPplotResults
% function onlineRes = onlineErrPplotResults
% 
% Plots the saccade performance and decoder error detection performance for
% both monkeys.
%
% Uses the online decoder error detection sessions 
%
% Author    :   Andres
% Andres    :   v1.0    : init
% Andres    :   v1.2    : included laterality analysis    

%% Paths and dirs
dirs = initErrDirs;

usingPrevSessionDecoder{1} = {'CS20140408','CS20140409','CS20140410','CS20140411','CS20140414'}; 
usingPrevSessionDecoder{2} = {'JS20140416','JS20140422'}; 

%% Sessions
jonahSessionsOnline = {'JS20140414';'JS20140415';'JS20140416';'JS20140417';'JS20140418';...
'JS20140421';'JS20140422';'JS20140423';'JS20140424';'JS20140425'};

chicoSessionsOnline = {'CS20140408';'CS20140409';'CS20140410';'CS20140411';...
'CS20140414';'CS20140415';'CS20140416';'CS20140417';'CS20140418';...
'CS20140421';'CS20140422';'CS20140423';'CS20140424';'CS20140425'};

% Results structure
onlineRes = struct('session','',...
                    'errDcdPerf',nan,...
                    'saccDcdPerf',nan,...
                    'numBCITrials',nan,...
                    'trials',[],...
                    'yDcd',[],...
                    'feedbackEvt',[],...
                    'saccActualTgt',[],...
                    'saccDcdTgt',[],...
                    'oldDecoderName','',...
                    'isDcdYesterdays',0);
% Subjects
subjects = {'chico','jonah'};
maxSubj = length(subjects);
maxSess =  max(length(jonahSessionsOnline),length(chicoSessionsOnline));
minSess =  min(length(jonahSessionsOnline),length(chicoSessionsOnline));

% Setting dimensionality for all sessions and subjects
onlineRes = repmat(onlineRes,[maxSubj,maxSess]);

%% Get all results for this subject
subjectsList = cell(2,1);
for iSbj = 1:length(subjects)
    iSubject = subjects{iSbj};
    
    % get all sessions
    if strcmpi(iSubject,'chico')    % for chico
        subjectsList{iSbj} = chicoSessionsOnline;
        latVals.arrayLaterality{iSbj} = 'left';
        latVals.ipsilatTgts(iSbj,:) = [3 4 5];
        latVals.contralatTgts(iSbj,:) = [6 1 2];
        latVals.contraIndx(iSbj) = 2;               % index/location of the column for plotting contralateral targets
        latVals.ipsiIndx(iSbj) = 1;               % index/location of the column for plotting ipsilateral targets
    else                            % for jonah
        subjectsList{iSbj} = jonahSessionsOnline;
        latVals.arrayLaterality{iSbj} = 'right';
        latVals.ipsilatTgts(iSbj,:) = [6 1 2];         % targets located ipsilateral to the implanted hemisphere
        latVals.contralatTgts(iSbj,:) = [3 4 5];         % targets located contralateral to the implanted hemisphere
        latVals.contraIndx(iSbj) = 1;               % index/location of the column for plotting contralateral targets
        latVals.ipsiIndx(iSbj) = 2;               % index/location of the column for plotting ipsilateral targets
    end
    
    % All sessions per subject
    for iSess = 1:length(subjectsList{iSbj})
        session = subjectsList{iSbj}{iSess};
        
        % Load bci session-data from online recording
        bciDataFilename = fullfile(strrep(dirs.DataIn,'mat','raw'),session,[session,'-data.mat']);
        fprintf('Loading bci-data for %s...\n',session)
        bciData = load(bciDataFilename);
        
        % Get only trials that were BCI/brain-controlled
        trials = ~isnan(bciData.bci.ErrPs.decoder.saccDcdTgt);
        numBCITrials = sum(trials);
        
        corrDcdTrials = bciData.bci.ErrPs.decoder.feedbackEvt(trials) == 25;
        errDcdPerf = sum(bciData.bci.ErrPs.decoder.yDcd(trials) == corrDcdTrials)/numBCITrials;
        fprintf('Decoder Error Detection Accuracy: %0.2f\n',errDcdPerf)
        
        saccDcdPerf = sum(bciData.bci.ErrPs.decoder.saccActualTgt(trials) == bciData.bci.ErrPs.decoder.saccDcdTgt(trials))/numBCITrials;
        fprintf('Saccade decoder Accuracy: %0.3f\n',saccDcdPerf)
        if all(isnan(bciData.bci.ErrPs.decoder.saccDcdTgt))
            warning('All values in ''bci.ErrPs.decoder.saccDcdTgt'' are NaNs!!...') %#ok<*WNTAG>
        end
        disp(bciData.bci.ErrPs.decoder.oldDecoderName)
        
        % Save data in structure
        onlineRes(iSbj,iSess).session         = session;
        onlineRes(iSbj,iSess).errDcdPerf      = errDcdPerf;
        onlineRes(iSbj,iSess).saccDcdPerf     = saccDcdPerf;
        onlineRes(iSbj,iSess).numBCITrials    = numBCITrials;
        onlineRes(iSbj,iSess).trials          = trials;
        onlineRes(iSbj,iSess).yHat            = bciData.bci.ErrPs.decoder.yHat;             % see (errDecoder) If yHat <= 0, the trials is correct. (round(double(yHat)) <= 0). Value >0 are incorrect trials!!!
        onlineRes(iSbj,iSess).yDcd            = bciData.bci.ErrPs.decoder.yDcd;
        onlineRes(iSbj,iSess).feedbackEvt     = bciData.bci.ErrPs.decoder.feedbackEvt;
        onlineRes(iSbj,iSess).saccActualTgt   = bciData.bci.ErrPs.decoder.saccActualTgt;
        onlineRes(iSbj,iSess).saccDcdTgt      = bciData.bci.ErrPs.decoder.saccDcdTgt;
        onlineRes(iSbj,iSess).oldDecoderName  = bciData.bci.ErrPs.decoder.oldDecoderName;
        
        % Check if decoder used in this session was the one used in the previous session (yesterdays/decoder was not updated)
        for repeatSess = 1:length(usingPrevSessionDecoder{iSbj})
            if strcmp(session,usingPrevSessionDecoder{iSbj}{repeatSess})
                onlineRes(iSbj,iSess).isDcdYesterdays = 1;
            end
        end
    end     % end iSess
end         % end iSbj

% Save these data
filenameEnd = 'onlineSessionsErrPs&SaccDcd-data.mat';
saveFilename = fullfile('C:\Users\salacho\Documents\Analysis\dlysac\onlineBCI',filenameEnd);
save(saveFilename,'onlineRes','subjectsList','latVals','-v7.3');

%% Plot error and saccade decoder values for all online sessions

Xvals = 1:maxSess;
% Fit lines 
[chicoFit.Err,chicoFit.ErrRsq] = fitLine(Xvals,[onlineRes(1,:).errDcdPerf],1);
[chicoFit.Sacc,chicoFit.SaccRsq] = fitLine(Xvals,[onlineRes(1,:).errDcdPerf],1);
[jonahFit.Err,jonahFit.ErrRsq] = fitLine(Xvals(end-minSess+1:end),[onlineRes(2,1:minSess).errDcdPerf],1);
[jonahFit.Sacc,jonahFit.SaccRsq] = fitLine(Xvals(end-minSess+1:end),[onlineRes(2,1:minSess).errDcdPerf],1);

% params
plotInfo.axisFontSize = 16; 
plotInfo.axisFontWeight = 'Bold';
plotInfo.titleFontSize = 18;
plotInfo.titleFontWeight = 'Bold';
plotInfo.lineWidth = 4;
plotInfo.lineStyle = '-';
plotInfo.colorErrP = [[26 150 65]/255;...          % Correct
    [215 25 28]/255;...          % Incorrect
    [0 0 128]/255;...            % Err difference
    [0 0 0]];                    % P300 signal in EEG studies


% Min val for Y limits
minYval = min(min([onlineRes(:,:).errDcdPerf]),min([onlineRes(:,:).saccDcdPerf]));

% Plot 
hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1439 33 1073 883],...
                'name','Online Decoder Error Detection for both monkeys')
            
Xvals = 1:maxSess;
xAxisSessions = cell(maxSess,1);
for iSess= 1:maxSess
    onlineSession = onlineRes(1,iSess).session;
    xAxisSessions{iSess} = onlineSession(5:10);
end

plot(Xvals,[onlineRes(1,:).errDcdPerf],'r','lineWidth',plotInfo.lineWidth); hold on, 
plot(Xvals,[onlineRes(1,:).saccDcdPerf],'--r','lineWidth',plotInfo.lineWidth);
%plot([length(usingPrevSessionDecoder{1}) length(usingPrevSessionDecoder{1})],[min([onlineRes(2,:).saccDcdPerf]) 1],'b','lineWidth',plotInfo.lineWidth,'lineStyle',':'); hold on, 
plot(Xvals(end-minSess+1:end),[onlineRes(2,1:minSess).errDcdPerf],'g','lineWidth',plotInfo.lineWidth);
plot(Xvals(end-minSess+1:end),[onlineRes(2,1:minSess).saccDcdPerf],'--g','lineWidth',plotInfo.lineWidth);
% same previous decoder 
plot(Xvals,[onlineRes(1,:).isDcdYesterdays],'r*','lineWidth',plotInfo.lineWidth+5); hold on, 
plot(Xvals(end-minSess+1:end),[onlineRes(2,1:minSess).isDcdYesterdays],'g*','lineWidth',plotInfo.lineWidth+5); hold on, 
% Fit lines
plot(Xvals,chicoFit.Err,'color',plotInfo.colorErrP(2,:)+ [0.15 0.2 0.4],'lineWidth',plotInfo.lineWidth-1,'lineStyle',':')
plot(Xvals(end-minSess+1:end),jonahFit.Err,'color',plotInfo.colorErrP(1,:) + [0.15 0.1 0.1],'lineWidth',plotInfo.lineWidth-1,'lineStyle',':')
% Axis 
legendTxt = {'monkeyC-ErrDcd','monkeyC-SaccBCI','monkeyJ-ErrDcd','monkeyJ-SaccBCI','monkeyC-prevSessionDecoder','monkeyJ-prevSessionDecoder','monkeyC-ErrFitLine','monkeyJ-ErrFitLine'};
% legendTxt = {'monkeyC-ErrDcd','monkeyC-SaccBCI','monkeyJ-ErrDcd','monkeyJ-SaccBCI','yesterdaysDecoder'};
titleTxt = sprintf('Online Decoder Error Detection. MonkeyC:%0.2f, MonkeyJ:%0.2f',[nanmean([onlineRes(1,:).errDcdPerf]) nanmean([onlineRes(2,:).errDcdPerf])]);

xlabel('Sessions','FontSize',plotInfo.axisFontSize+8,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Decoder performance','FontSize',plotInfo.axisFontSize+8,'FontWeight',plotInfo.axisFontWeight) 
legend(legendTxt,'location','SouthWest','FontSize',plotInfo.titleFontSize-2)
title(titleTxt,'FontSize',plotInfo.titleFontSize+2,'FontWeight',plotInfo.titleFontWeight)
set(gca,'Xtick',1:maxSess,'Xticklabel',xAxisSessions,'FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight)
axis tight
set(gca,'Ylim',[minYval 1]);

%% Calculate percentage of proper decoding for laterality
latPropCorrectlyErrDcd = nan(maxSubj,maxSess,2);
latPropIncorrectlyErrDcd = nan(maxSubj,maxSess,2);
for iSbj = 1:length(subjects)
    % Calculate laterality values
    for iSess = 1:length(subjectsList{iSbj})
        
        noNanTrials = ~isnan(onlineRes(iSbj,iSess).saccDcdTgt);
        corrTrials = onlineRes(iSbj,iSess).saccActualTgt(noNanTrials) == onlineRes(iSbj,iSess).saccDcdTgt(noNanTrials);     % trials when saccadeBMI was correct
        
        expTgts = onlineRes(iSbj,iSess).saccActualTgt(noNanTrials);                                                         % true saccade Tgt 
        errDcdAsCorrTrials = onlineRes(iSbj,iSess).yDcd(noNanTrials);
        
        correctlyErrDcd = (errDcdAsCorrTrials == corrTrials);   % trials correctly classified as decoder error or not
        incorrectlyErrDcd = (errDcdAsCorrTrials == ~corrTrials);
        correctlyErrDcdTgts = expTgts(correctlyErrDcd);         % expected target of trials correctly decoded by decoder error detection (BMI) BMI
        incorrectlyErrDcdTgts = expTgts(incorrectlyErrDcd);
        
        % Trials for each laterality
        corrLatErrDcd = zeros(length(correctlyErrDcdTgts),2);
        incorrLatErrDcd = zeros(length(incorrectlyErrDcdTgts),2);
        for iTgt = 1:length(latVals.ipsilatTgts(iSbj,:))
            corrLatErrDcd(:,latVals.ipsiIndx(iSbj))     = corrLatErrDcd(:,latVals.ipsiIndx(iSbj)) +   (correctlyErrDcdTgts == latVals.ipsilatTgts(iSbj,iTgt));
            corrLatErrDcd(:,latVals.contraIndx(iSbj))   = corrLatErrDcd(:,latVals.contraIndx(iSbj)) + (correctlyErrDcdTgts ==  latVals.contralatTgts(iSbj,iTgt));
            incorrLatErrDcd(:,latVals.ipsiIndx(iSbj))   = incorrLatErrDcd(:,latVals.ipsiIndx(iSbj)) +   (incorrectlyErrDcdTgts == latVals.ipsilatTgts(iSbj,iTgt));
            incorrLatErrDcd(:,latVals.contraIndx(iSbj)) = incorrLatErrDcd(:,latVals.contraIndx(iSbj)) + (incorrectlyErrDcdTgts == latVals.contralatTgts(iSbj,iTgt));
        end
        
        % Placing all subjects/session values together
        latPropCorrectlyErrDcd(iSbj,iSess,:) = sum(corrLatErrDcd,1)/sum(correctlyErrDcd);               % count how many ipsilaterals were correctly decoder by the DED BMI
        latPropIncorrectlyErrDcd(iSbj,iSess,:) = sum(incorrLatErrDcd,1)/sum(incorrectlyErrDcd);
        
        % Number of trials
        nIncorrectlyErrDcd(iSbj,iSess) = sum(incorrectlyErrDcd);
        nCorrectlyErrDcd(iSbj,iSess) = sum(correctlyErrDcd);
        
    end
end

%% Plot laterality
hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1343         145        1197         693],...
                'name','Proportion of trials correctly decoded by Error Detection Algorithm')
            
% Chico
iSbj = 1;
ipsiIndx = latVals.ipsiIndx(iSbj);
contraIndx = latVals.contraIndx(iSbj);
plot(Xvals,squeeze(latPropCorrectlyErrDcd(iSbj,:,ipsiIndx)),'color','r','lineWidth',plotInfo.lineWidth); hold on, %left Chico ipsi
hold on
plot(Xvals,squeeze(latPropCorrectlyErrDcd(iSbj,:,contraIndx)),'color','r','lineWidth',plotInfo.lineWidth,'lineStyle',':'); hold on, %left Chico contra
% Jonah
iSbj = 2;
ipsiIndx = latVals.ipsiIndx(iSbj);
contraIndx = latVals.contraIndx(iSbj);
plot(Xvals(end-minSess+1:end),squeeze(latPropCorrectlyErrDcd(iSbj,1:minSess,ipsiIndx)),'g','lineWidth',plotInfo.lineWidth); %right Jonah ipsi
plot(Xvals(end-minSess+1:end),squeeze(latPropCorrectlyErrDcd(iSbj,1:minSess,contraIndx)),'g','lineWidth',plotInfo.lineWidth,'lineStyle',':'); %left Jonah contra

% Fit lines 
iSbj = 1;
[chicoFit.corrErrDcdLatIpsi,chicoFit.corrErrDcdLatIpsiRsq] = fitLine(Xvals,squeeze(latPropCorrectlyErrDcd(iSbj,:,ipsiIndx)),1);
[chicoFit.corrErrDcdLatContra,chicoFit.corrErrDcdLatContraRsq] = fitLine(Xvals,squeeze(latPropCorrectlyErrDcd(iSbj,:,contraIndx)),1);
iSbj = 2;
[jonahFit.corrErrDcdLatIpsi,jonahFit.corrErrDcdLatIpsiRsq] = fitLine(Xvals(end-minSess+1:end),squeeze(latPropCorrectlyErrDcd(iSbj,1:minSess,ipsiIndx)),1);
[jonahFit.corrErrDcdLatContra,jonahFit.corrErrDcdLatContraRsq] = fitLine(Xvals(end-minSess+1:end),squeeze(latPropCorrectlyErrDcd(iSbj,1:minSess,contraIndx)),1);

% Plot fit lines
plot(Xvals,chicoFit.corrErrDcdLatIpsi,'--r')
%plot(Xvals,chicoFit.corrErrDcdLatContra,'--r')
plot(Xvals(end-minSess+1:end),jonahFit.corrErrDcdLatContra,'--g')
%plot(Xvals(end-minSess+1:end),jonahFit.corrErrDcdLatIpsi,'--g')

% Properties
titleTxt = 'Proportion of trials correctly decoded by Error Detection Algorithm for both subjects';
xlabel('Sessions','FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Proportion trials correctly decoded by Error Detect. Algor.','FontSize',plotInfo.axisFontSize-2,'FontWeight',plotInfo.axisFontWeight) 
legendTxt = {'MonkeyC-ipsilateral targets','MonkeyC-contralateral targets','MonkeyJ-ipsilateral targets','MonkeyJ-contralateral targets'};
title(titleTxt,'FontSize',plotInfo.titleFontSize,'FontWeight',plotInfo.titleFontWeight)
set(gca,'Xtick',1:maxSess,'Xticklabel',xAxisSessions,'FontSize',plotInfo.axisFontSize-2,'FontWeight',plotInfo.axisFontWeight)
axis tight, ylim([0.38 0.62]);
legend(legendTxt,'location','best')

% Mean and St.dev.
meanPropLatCorrDcdAsCorr = squeeze(nanmean(latPropCorrectlyErrDcd,2));
meanPropLatIncorrDcdAsCorr = squeeze(nanmean(latPropIncorrectlyErrDcd,2));
stdPropLatCorrDcdAsCorr = nanstd(latPropCorrectlyErrDcd,[],2);
stdPropLatIncorrDcdAsCorr = nanstd(latPropIncorrectlyErrDcd,[],2);




%% Box plot of proportion latCorrectlyErrDecoded
maxLim = max(reshape(latPropCorrectlyErrDcd,[maxSubj*maxSess*2 1]));
minLim = min(reshape(latPropCorrectlyErrDcd,[maxSubj*maxSess*2 1]));

hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1           1        1010         658],...
                'name','Boxplot Proportion trials correctly decoded by Error Detect. Algor.')

xAxisLabel = {'ipsilateral','contralateral'};
plotInfo.subjetColor = {'b','r'};

% Plot boxplots per subject
data2plot = nan(size(latPropCorrectlyErrDcd,2),2);
for iSbj = 1:2
    % For chico ipsi is alwais index 1
    % For Jonah ipsi is always index 2, need to change
    data2plot(:,1) = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
    hold on
    data2plot(:,2) = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    boxH(iSbj).h = boxplot(data2plot,'color',plotInfo.subjetColor{iSbj},'symbol', '*');%,'notch', 'on');
    % Changing boxplot line widht
    for i=1:size(boxH(iSbj).h,1) % <- # graphics handles/x
        for iLat = 1:2
            
            set(boxH(iSbj).h(i,iLat),'linewidth',3);
        end
    end
end

% Set axis properties
set(gca,'Xtick',1:2,'Xticklabel',xAxisLabel,'FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight,'Ylim',[minLim*0.98 maxLim*1.02])
titleTxt = 'Proportion trials correctly decoded by Error Detect. Algor.';
%xlabel('True target laterality','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
xlabel('','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Proportion trials correctly decoded by Error Detect. Algor.','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
title(titleTxt,'FontSize',plotInfo.titleFontSize,'FontWeight',plotInfo.titleFontWeight)

% Find all axis related to box!
plotHandle = findall(gca,'Tag','Box');
% Only use one color for each subject
hLegend = legend(plotHandle([1 3]), {'monkeyC-prop. correct err. detection','monkeyJ-prop. correct err. detection'});


%%%%%%%%%%%%%%%%%%
%% Box plot of proportion latCorrectlyErrDecoded
maxLim = max(reshape(latPropIncorrectlyErrDcd,[maxSubj*maxSess*2 1]));
minLim = min(reshape(latPropIncorrectlyErrDcd,[maxSubj*maxSess*2 1]));

hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1           1        1010         658],...
                'name','Boxplot Proportion trials incorrectly decoded by Error Detect. Algor.')

xAxisLabel = {'ipsilateral','contralateral'};
plotInfo.subjetColor = {'b','r'};

% Plot boxplots per subject
data2plot = nan(size(latPropIncorrectlyErrDcd,2),2);
for iSbj = 1:2
    % For chico ipsi is alwais index 1
    % For Jonah ipsi is always index 2, need to change
    data2plot(:,1) = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
    hold on
    data2plot(:,2) = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    boxH(iSbj).h = boxplot(data2plot,'color',plotInfo.subjetColor{iSbj},'symbol', '*');%,'notch', 'on');
    % Changing boxplot line widht
    for i=1:size(boxH(iSbj).h,1) % <- # graphics handles/x
        for iLat = 1:2
            
            set(boxH(iSbj).h(i,iLat),'linewidth',3);
        end
    end
end

% Set axis properties
set(gca,'Xtick',1:2,'Xticklabel',xAxisLabel,'FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight,'Ylim',[minLim*0.80 maxLim*1.09])
titleTxt = 'Proportion trials incorrectly decoded by Error Detect. Algor.';
%xlabel('True target laterality','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
xlabel('','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Proportion trials incorrectly decoded by Error Detect. Algor.','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
title(titleTxt,'FontSize',plotInfo.titleFontSize,'FontWeight',plotInfo.titleFontWeight)

% Find all axis related to box!
plotHandle = findall(gca,'Tag','Box');
% Only use one color for each subject
hLegend = legend(plotHandle([1 3]), {'monkeyC-prop. incorrect err. detection','monkeyJ-prop. incorrect err. detection'});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure
hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[42         250        1220         524],...
                'name','Boxplot Proportion trials correctly decoded by Error Detect. Algor.')

%% Box plot of proportion latCorrectlyErrDecoded
subplot(1,2,1)
maxLim = max(reshape(latPropCorrectlyErrDcd,[maxSubj*maxSess*2 1]));
minLim = min(reshape(latPropCorrectlyErrDcd,[maxSubj*maxSess*2 1]));


xAxisLabel = {'ipsilateral','contralateral'};
plotInfo.subjetColor = {'b','r'};

% Plot boxplots per subject
data2plot = nan(size(latPropCorrectlyErrDcd,2),2);
for iSbj = 1:2
    % For chico ipsi is alwais index 1
    % For Jonah ipsi is always index 2, need to change
    data2plot(:,1) = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
    hold on
    data2plot(:,2) = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    boxH(iSbj).h = boxplot(data2plot,'color',plotInfo.subjetColor{iSbj},'symbol', '*');%,'notch', 'on');
    % Changing boxplot line widht
    for i=1:size(boxH(iSbj).h,1) % <- # graphics handles/x
        for iLat = 1:2
            
            set(boxH(iSbj).h(i,iLat),'linewidth',3);
        end
    end
end

% Set axis properties
set(gca,'Xtick',1:2,'Xticklabel',xAxisLabel,'FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight,'Ylim',[minLim*0.97 maxLim*1.1])
titleTxt = 'Trials correctly decoded by DED BMI';
%xlabel('True target laterality','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
xlabel('','FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Prop. trials correctly decoded','FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight) 
title(titleTxt,'FontSize',plotInfo.titleFontSize+1,'FontWeight',plotInfo.titleFontWeight)

% Find all axis related to box!
plotHandle = findall(gca,'Tag','Box');
% Only use one color for each subject
hLegend = legend(plotHandle([1 3]), {'monkeyC','monkeyJ'},'location','southwest');


%%%%%%%%%%%%%%%%%%
%% Box plot of proportion latCorrectlyErrDecoded
subplot(1,2,2)
maxLim = max(reshape(latPropIncorrectlyErrDcd,[maxSubj*maxSess*2 1]));
minLim = min(reshape(latPropIncorrectlyErrDcd,[maxSubj*maxSess*2 1]));


xAxisLabel = {'ipsilateral','contralateral'};
plotInfo.subjetColor = {'b','r'};

% Plot boxplots per subject
data2plot = nan(size(latPropIncorrectlyErrDcd,2),2);
for iSbj = 1:2
    % For chico ipsi is alwais index 1
    % For Jonah ipsi is always index 2, need to change
    data2plot(:,1) = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
    hold on
    data2plot(:,2) = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    boxH(iSbj).h = boxplot(data2plot,'color',plotInfo.subjetColor{iSbj},'symbol', '*');%,'notch', 'on');
    % Changing boxplot line widht
    for i=1:size(boxH(iSbj).h,1) % <- # graphics handles/x
        for iLat = 1:2
            
            set(boxH(iSbj).h(i,iLat),'linewidth',3);
        end
    end
end

% Set axis properties
set(gca,'Xtick',1:2,'Xticklabel',xAxisLabel,'FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight,'Ylim',[minLim*0.5 maxLim*1.12])
titleTxt = 'Trials incorrectly decoded by DED BMI';
%xlabel('True target laterality','FontSize',plotInfo.axisFontSize+4,'FontWeight',plotInfo.axisFontWeight) 
xlabel('','FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight) 
ylabel('Prop. trials incorrectly decoded','FontSize',plotInfo.axisFontSize,'FontWeight',plotInfo.axisFontWeight) 
title(titleTxt,'FontSize',plotInfo.titleFontSize+1,'FontWeight',plotInfo.titleFontWeight)

% Find all axis related to box!
plotHandle = findall(gca,'Tag','Box');
% Only use one color for each subject
hLegend = legend(plotHandle([1 3]), {'monkeyC','monkeyJ'},'location','southwest');


%% Plot traces of prop. contralateral trials
figure, 
for iSbj = 1:2
    data2plot = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    plot(Xvals,data2plot,'color',plotInfo.subjetColor{iSbj},'linewidth',3), hold on

    data2plot = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    plot(Xvals,data2plot,'color',plotInfo.subjetColor{iSbj},'linewidth',3,'linestyle','--'), hold on
end
subplot(2,1,2)
for iSbj = 1:2
    data2plot = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
    plot(Xvals,data2plot,'color',plotInfo.subjetColor{iSbj},'linewidth',3), hold on
end

%% 
iSbj = 1;
[iSbj, nanmean(squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)))), nanstd(squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj))))]
[iSbj, nanmean(squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)))), nanstd(squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj))))]
iSbj = 2;
[iSbj, nanmean(squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)))), nanstd(squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj))))]
[iSbj, nanmean(squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)))), nanstd(squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj))))]
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Explained variance for laterality for correctly decoded trials
%% Compare contra vs. ipsi, are they different in proportion?

nIncorrectlyErrDcd(iSbj,iSess)
nCorrectlyErrDcd(iSbj,iSess)


for iSbj = 1:2;
data2Anal = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
dataContra = data2Anal(~isnan(data2Anal));
data2Anal = squeeze(latPropCorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
dataIpsi = data2Anal(~isnan(data2Anal));

data2Anal = [dataContra, dataIpsi];
dataLabels = [ones(1,size(dataContra,2)),2*ones(1,size(dataIpsi,2))];

analDim = 2;
[expVar,n,pVals,mu,F] = myANOVA1(data2Anal,dataLabels,analDim);
fprintf('For subject %i Correctly decoded trials... pVals-%0.3f....\n',iSbj,pVals)

%%%%%%
data2Anal = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.contraIndx(iSbj)));
dataContra = data2Anal(~isnan(data2Anal));
data2Anal = squeeze(latPropIncorrectlyErrDcd(iSbj,:,latVals.ipsiIndx(iSbj)));
dataIpsi = data2Anal(~isnan(data2Anal));

data2Anal = [dataContra, dataIpsi];
dataLabels = [ones(1,size(dataContra,2)),2*ones(1,size(dataIpsi,2))];

analDim = 2;
[expVar,n,pVals,mu,F] = myANOVA1(data2Anal,dataLabels,analDim);
fprintf('For subject %i Incorrectly decoded trials... pVals-%0.3f....\n',iSbj,pVals)
end


For subject 1 Correctly decoded trials...   pVals-0.197....
For subject 1 Incorrectly decoded trials... pVals-0.430....
For subject 2 Correctly decoded trials...   pVals-0.026....
For subject 2 Incorrectly decoded trials... pVals-0.004....

end