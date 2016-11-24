function pop_iterCrossFreqAmpTtest(iIter,subject)
%
%
%
%
%
%
% clear all, clc, close all, subject = 'chico';

%% dirs and path 
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
dirs.DataIn     = '/projectnb/busplab/salacho/Data/saccErrPs/HD';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
dirs.DataOut    = '/projectnb/busplab/salacho/Data/saccErrPs/HD';
dirs.BCIparams  = '/projectnb/busplab/salacho/Data/saccErrPs/HD';                  %Add path where all BCIparams are located

%% Define vars
freqBands = [1 4;4 8;8 13;13 30;30 80;80 200];
errDiffFreqTxt = {'delta','theta','alpha','beta','gamma','highGam'};

%% Load data
if strcmpi(subject,'chico'), 
    sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
else
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
end

% save freqbands
session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end}(7:end),numel(sessionList));
loadFreqbandName = sprintf('%s-%s',fullfile(dirs.DataOut,'popAnalysis',session),'freqBands.mat');
load(loadFreqbandName)

% Remove sessionListC and J to avoid confusion 
if exist('sessionsListC','var'), clear sessionsListC
elseif exist('sessionsListJ','var'), clear sessionsListJ
end

ErrorInfo.plotInfo.specgram.doColorbar = 0;
ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Amplitude-amplitude cross-frequency coupling %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define vars
ErrorInfo.analysis.withReplacement = 'true';
ErrorInfo.analysis.balanced = 1;
nIter = 1000;

nTimes = size(popCorrFreqBand,1);
specTimeStart = -ErrorInfo.epochInfo.preOutcomeTime/1000 + ErrorInfo.specParams.movingWin(1)/2;
timeRange = ErrorInfo.epochInfo.postOutcomeTime/1000 + ErrorInfo.epochInfo.preOutcomeTime/1000;
timeVector = 0:ErrorInfo.specParams.movingWin(2):timeRange;
timeVector = specTimeStart + timeVector(1:nTimes);
[~,fdbackStart] = min(abs(timeVector));

% %% When iIter was local
% % pre-allocate memory
% preCorrXcorrFreqBand = nan(size(popCorrFreqBand,2),size(popCorrFreqBand,2),size(popCorrFreqBand,4),nIter);
% preIncorrXcorrFreqBand = nan(size(popCorrFreqBand,2),size(popCorrFreqBand,2),size(popCorrFreqBand,4),nIter);
% postCorrXcorrFreqBand = nan(size(popCorrFreqBand,2),size(popCorrFreqBand,2),size(popCorrFreqBand,4),nIter);
% postIncorrXcorrFreqBand = nan(size(popCorrFreqBand,2),size(popCorrFreqBand,2),size(popCorrFreqBand,4),nIter);
% 
% % Get vals for balanced analysis
% nCorr = size(popCorrFreqBand,3);
% nError = size(popIncorrFreqBand,3);
% 
% % Iterate
% for iIter = 1:nIter
%     fprintf('cross-Freq amp-amp coupling for iter %i...\n',iIter)
%     % Randomly choosing trials, not always the first ones
%     corrIndxRandBalance = randsample(nCorr,nCorr,'true');
%     incorrIndxRandBalance = randsample(nError,nError,'true');
%     
%     % Compute cross-coherence
%     preCorrXcorrFreqBand(:,:,:,iIter) = crossCorrFreqBand(popCorrFreqBand(1:fdbackStart,:,corrIndxRandBalance,:));
%     preIncorrXcorrFreqBand(:,:,:,iIter) = crossCorrFreqBand(popIncorrFreqBand(1:fdbackStart,:,incorrIndxRandBalance,:));
%     postCorrXcorrFreqBand(:,:,:,iIter) = crossCorrFreqBand(popCorrFreqBand(fdbackStart:end,:,corrIndxRandBalance,:));
%     postIncorrXcorrFreqBand(:,:,:,iIter) = crossCorrFreqBand(popIncorrFreqBand(fdbackStart:end,:,incorrIndxRandBalance,:));
% end
% 

%% iIter is outside this function

% Get vals for balanced analysis
nCorr = size(popCorrFreqBand,3);
nError = size(popIncorrFreqBand,3);

rng('shuffle');

% Iterate
fprintf('cross-Freq amp-amp coupling for iter %i...\n',iIter)
% Randomly choosing trials, not always the first ones
corrIndxRandBalance = randsample(nCorr,nCorr,'true');
incorrIndxRandBalance = randsample(nError,nError,'true');

% Compute cross-coherence
preCorrXcorrFreqBand = crossCorrFreqBand(popCorrFreqBand(1:fdbackStart,:,corrIndxRandBalance,:));
preIncorrXcorrFreqBand = crossCorrFreqBand(popIncorrFreqBand(1:fdbackStart,:,incorrIndxRandBalance,:));
postCorrXcorrFreqBand = crossCorrFreqBand(popCorrFreqBand(fdbackStart:end,:,corrIndxRandBalance,:));
postIncorrXcorrFreqBand = crossCorrFreqBand(popIncorrFreqBand(fdbackStart:end,:,incorrIndxRandBalance,:));

%% Save files
ErrorInfo.dirs = dirs;
ErrorInfo.session = session;
saveCrossFreqName = sprintf('%s_%s-%i%s',fullfile(dirs.DataOut,'popAnalysis',session),'iterCrossFreqCoupling-rndShuffle',iIter,'.mat');
save(saveCrossFreqName,'preCorrXcorrFreqBand','preIncorrXcorrFreqBand',...
    'postCorrXcorrFreqBand','postIncorrXcorrFreqBand','freqBands','errDiffFreqTxt','ErrorInfo','sessionList','iIter','nIter','-v7.3')
                       
end

