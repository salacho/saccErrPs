function pop_groupIterCrossFreqCoupling(subject)
%
%
%
%
%
%
%

%% Dirs and paths
dirs = initErrDirs('loadSpec');                         % Paths where all data is loaded from and where chronic Recordings analysis are saved
dirs.DataIn     = '/projectnb/busplab/salacho/Data/saccErrPs/HD';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
dirs.DataOut    = '/projectnb/busplab/salacho/Data/saccErrPs/HD';
dirs.BCIparams  = '/projectnb/busplab/salacho/Data/saccErrPs/HD';                  %Add path where all BCIparams are located

%% Load pop files
% Extract or load popEpochs
if strcmpi(subject,'chico')
   disp('Loading popEpochs for Chico...')
   sessionList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract.
   popErrorInfo.subject = 'chico';
   popErrorInfo.session = 'popCS20121012-CS20121026-11';
else
    disp('Loading popEpochs for Jonah...')
    sessionList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract.
    popErrorInfo.subject = 'jonah';
    popErrorInfo.session = 'popJS20140318-JS20140328-9';
end

%% Iterate
nIter = 1000; 
for iIter =1:nIter
    % load
    file2Load = sprintf('%s_iterCrossFreqCoupling-%i.mat',popFreqSuffix,iIter);
    % reArrange
    preCorrXcorrFreqBand_allIter(:,:,:,iIter) = preCorrXcorrFreqBand;
    preIncorrXcorrFreqBand_allIter(:,:,:,iIter)  = preIncorrXcorrFreqBand;
    postCorrXcorrFreqBand_allIter(:,:,:,iIter)  = postCorrXcorrFreqBand;
    postIncorrXcorrFreqBand_allIter(:,:,:,iIter)  = postIncorrXcorrFreqBand;
end

%% Save
saveFilename = sprintf('%s_iterCrossFreqCoupling-allIter.mat',popFreqSuffix);
save(saveCrossFreqName,'preCorrXcorrFreqBand_allIter','preIncorrXcorrFreqBand_allIter',...
    'postCorrXcorrFreqBand_allIter','postIncorrXcorrFreqBand_allIter','freqBands','errDiffFreqTxt','ErrorInfo','sessionList','nIter','-v7.3')


end