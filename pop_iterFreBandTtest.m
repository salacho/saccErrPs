function pop_iterFreBandTtest(subject)
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
if strcmpi(subject,'chico'), sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
else sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
end

% save freqbands
session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end}(7:end),numel(sessionList));
loadFreqbandName = sprintf('%s-%s',fullfile(dirs.DataOut,'popAnalysis',session),'freqBands.mat');
load(loadFreqbandName)

if exist('sessionsListC','var'), clear sessionsListC
elseif exist('sessionsListJ','var'), clear sessionsListJ
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot freq.bands 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ErrorInfo.plotInfo.specgram.doColorbar = 0;
ErrorInfo.plotInfo.specgram.tStart      = -0.4;                             % start in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.tEnd        = 1;                              % end in time for spectrogram plotting
ErrorInfo.plotInfo.specgram.fStart      = 0;                                % lower bound frequency to plot. Used for naming files. Comes from 'ErrorInfo.plotInfo.specgram.freqs'
ErrorInfo.plotInfo.specgram.fEnd        = 200;                              % upper bound frequency to plot

errDiffFreqBand = (squeeze(nanmean(popIncorrFreqBand,3)) - squeeze(nanmean(popCorrFreqBand,3)));
ErrorInfo.plotInfo.specgram.transfType  = 'db';                         % string. %'freqzscore', 'norm', '' Z-score each freq. band over all time axis, 'allzscore' Z-score based on all data, along all freqs. and time points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Freq. band two sample T-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T.test previous trial outcome for correct and incorrect trials
ErrorInfo.analysis.balanced = 1;

if ErrorInfo.analysis.balanced
    % Define vars
    nIter = 1000;
    expVarFreq = nan(size(popCorrFreqBand,1),size(popCorrFreqBand,2),nIter,size(popCorrFreqBand,4));
    pValsFreq = nan(size(popCorrFreqBand,1),size(popCorrFreqBand,2),nIter,size(popCorrFreqBand,4));
    FFreq = nan(size(popCorrFreqBand,1),size(popCorrFreqBand,2),nIter,size(popCorrFreqBand,4));
    muFreq = nan(size(popCorrFreqBand,1),size(popCorrFreqBand,2),2,size(popCorrFreqBand,4),nIter);
    nFreq = nan(2,nIter);
    
    % Iterate
    for iIter =1:nIter
        fprintf('T-test for freqBands for iter %i...\n',iIter)
        [expVarFreq(:,:,iIter,:),nFreq(:,iIter),pValsFreq(:,:,iIter,:),muFreq(:,:,:,:,iIter),FFreq(:,:,iIter,:),ErrorInfo] = getFreqBandT_test(popCorrFreqBand,popIncorrFreqBand,ErrorInfo);
    end
else
    [expVarFreq,nFreq,pValsFreq,muFreq,FFreq,ErrorInfo] = getFreqBandT_test(popCorrFreqBand,popIncorrFreqBand,ErrorInfo);
end

% save freqbands
saveFreqbandName = sprintf('%s-%s',fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session),'iterTtest_freqBands.mat');
save(saveFreqbandName,'expVarFreq','nFreq','pValsFreq','muFreq','FFreq','ErrorInfo')

end
