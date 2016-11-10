function testSimulatedSpecGram
%
%
%
%
%
%



dirs = initErrDirs;                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
session = 'CS20120925';
% Params
ErrorInfo = setDefaultParams(session,dirs);
% For spectrogram high sampling rate
ErrorInfo.signalProcess.downSampFactor = 1;
% Load
[~,~,~,ErrorInfo] = loadErrRPs(ErrorInfo);

%% List of frequenciesa and time windows
% listFreq = [4,4,...
%     10,16,...
%     19,21,23,...
%     30:35,...
%     38:50,...
%     70:100];
% listTime = [0.2 0.3; 0.5 0.6;...
%     0 0.05; -0.5 -0.1;...
%     -0.4 -0.2; -0.42 -0.22; -0.44 -0.24;...
%     repmat([0.4 0.6],[6 1]);...
%     repmat([0 0.1],[13 1]);...
%     repmat([0.1 0.3],[31 1])];
% % listAmp = [4,4,2,2];

listFreq = [4 8 10 25 33];
listTime = [-0.5 -0.4; -0.3 -0.15; -0.1 0.1; 0 0.2; 0.2 0.4];

listFreq = [4 10 12 15 17 20 85];
listTime = [-0.4 -0.3; repmat([0.5 0.6],[5 1]); 0 0.1];

% Time vals to plot
specTimeStart = -ErrorInfo.epochInfo.preOutcomeTime/1000 + ErrorInfo.specParams.movingWin(1)/2;
timeRange = ErrorInfo.epochInfo.postOutcomeTime/1000 + ErrorInfo.epochInfo.preOutcomeTime/1000; 
timeVector = 0:ErrorInfo.specParams.movingWin(2):timeRange;
timeVector = specTimeStart + timeVector(1:nTime);
nTime = length(ErrorInfo.specParams.tSpec);
timeVals = ErrorInfo.specParams.tSpec;
freqVals = ErrorInfo.specParams.fSpec;
freqVector = freqVals;

%% Simulate data
[outputSignal,simCorrEpochs,simIncorrEpochs] = simmulateWaveform(ErrorInfo,listFreq,listTime);
    
% Text
infoStr = getInfoStr(ErrorInfo);

%% Calculate spectrogram
ErrorInfo.specParams.params.Fs = ErrorInfo.epochInfo.Fs;       % To be sure Fs was properly updated!!
% Everything is SpecInfo from now on...
[meanCorrSpec,ErrorInfo.specParams.tSpec,ErrorInfo.specParams.fSpec] = ...
    mtspecgramc(squeeze(simCorrEpochs(1,:,:))',ErrorInfo.specParams.movingWin,ErrorInfo.specParams.params);        % data has to be in the form [samples x channels/trials]

%% Plot
plotInfo = ErrorInfo.plotInfo;
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1281 0 1280 948],...
    'name',sprintf('%s %s mean for %s-%s',ErrorInfo.session,'Corr','unArray',infoStr.strSpecTrans,infoStr.strSpecRange),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

ErrorInfo.plotInfo.specgram.freqs = [0 10; 10 20;20 30;30 40; 40 60;60 100];%70; 70 80; 80 90; 90 100];      % range (lower/upper) of frequencies to plot
plotInfo = ErrorInfo.plotInfo;

%% Plot each frequency range set in plotInfo.specgram.freqs
for iFreq = 1:size(plotInfo.specgram.freqs,1)
    % Set the frequency range to plot
    ErrorInfo.plotInfo.specgram.fStart =  ErrorInfo.plotInfo.specgram.freqs(iFreq,1);
    ErrorInfo.plotInfo.specgram.fEnd = ErrorInfo.plotInfo.specgram.freqs(iFreq,2);
    
    % Find index of range of interest
    [~,tStartIndx] = min(abs(timeVals - plotInfo.specgram.tStart));
    [~,tEndIndx] = min(abs(timeVals - ErrorInfo.epochInfo.preOutcomeTime/1000 - plotInfo.specgram.tEnd));
    [~,fStartIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fStart));
    [~,fEndIndx] = min(abs(freqVals - ErrorInfo.plotInfo.specgram.fEnd));
    
    % Vector of time and frequency to plot
    time2plot = timeVector(tStartIndx:tEndIndx);
    freq2plot = freqVector(fStartIndx:fEndIndx); %always aim a bit higuer than the freq. of interest
    
    % Text
    infoStr = getInfoStr(ErrorInfo);
    
    %% Plot all channels correct and incorrect spectrogram
    % For each array
    iArray = 1; iOut = 1;iCh = 1;                                        % channels from 1-32 per array
    fprintf('For %i-%iHz...\n',ErrorInfo.plotInfo.specgram.fStart,ErrorInfo.plotInfo.specgram.fEnd)
    % subplot
    subplot(size(plotInfo.specgram.freqs,1),1,size(plotInfo.specgram.freqs,1) - iFreq + 1) % subplot location using layout info
    
    % Data 2 top
    data2plot = squeeze(meanCorrSpec(tStartIndx:tEndIndx,fStartIndx:fEndIndx,iCh))';
    imagesc(time2plot,freq2plot,data2plot);%,[0.000001 0.000015])
    set(gca,'Ydir','normal');
    colorbar
    % Axis properties
    set(gca,'FontSize',plotInfo.axisFontSz)
    axis tight
end

figure,imagesc(time2plot,ErrorInfo.specParams.fSpec,squeeze(meanCorrSpec(:,:,1))')
set(gca,'Ydir','normal'); 
