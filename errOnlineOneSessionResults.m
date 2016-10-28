function errOnlineOneSessionResults(bci,res,errXs)
% function errOnlineOneSessionResults(bci,res,errXs)
%
% Asses the online performance of decoder error detection by using the
% results saved in bci.
%
% INPUT
% bci:      structure saved in raw folder of server. Inludes the values 
%           required to assess decoder error detection performance 
%           bci.ErrPs.decoder.yDcd
%           bci.ErrPs.decoder.feedbackEvt
% res:      structure saved in raw folder of server. Has the overall
%           saccade BCI performance
%
% errXs:    matrix. Covariates matrix saved in online decoder error
%           detection
% OUTPUT
% Decoder error detection is prompted in the command line as well as sacc BCI performance. 
% 
% 14 April 2014

%load(fullfile(rawPath,session,[session,'-data.mat']));

%% Getting decoder error detection performance
trials = (~isnan(bci.ErrPs.decoder.yDcd));
numBCITrials = sum(~isnan(bci.ErrPs.decoder.yDcd));
corrDcdTrials = bci.ErrPs.decoder.feedbackEvt(trials) == 25;
errDcdPerf = sum(bci.ErrPs.decoder.yDcd(trials) == corrDcdTrials)/numBCITrials;
fprintf('Decoder Error Detection Accuracy: %0.2f\n',errDcdPerf)

saccDcdPerf = sum(bci.ErrPs.decoder.saccActualTgt(trials) == bci.ErrPs.decoder.saccDcdTgt(trials))/numBCITrials;
fprintf('Saccade decoder Accuracy: %0.3f\n',saccDcdPerf)
if all(isnan(bci.ErrPs.decoder.saccDcdTgt))
    warning('All values in ''bci.ErrPs.decoder.saccDcdTgt'' are NaNs!!...') %#ok<*WNTAG>
end
disp(bci.ErrPs.decoder.oldDecoderName)


%% Show the dec
disp([corrDcdTrials, bci.ErrPs.decoder.yDcd(trials)]')

%% Plot values
if 1 == 0
    plot(corrDcdTrials,'b'), hold on
    plot(bci.ErrPs.decoder.yDcd(trials),'g')
end

%% Getting training trials
goodTrls = ~isnan(errXs(trials,:));

%% Getting saccade decoder performance
bciTrls         = (~isnan(res.decodeDone));
dcdTrlsOutcm    = {res.outcome{bciTrls}};          %#ok<*CCAT1>
corrTrls        = nan([length(dcdTrlsOutcm) 1]);

for iTrial = 1:length(dcdTrlsOutcm)
    corrTrls(iTrial) = strcmp(dcdTrlsOutcm{iTrial},'RES-CORR');
end

nCorrDcd    = sum(corrTrls);
nDcdTrls    = length(dcdTrlsOutcm);
saccDcdPerf = nCorrDcd/nDcdTrls;
fprintf('Saccade decoder Accuracy: %0.2f\n',saccDcdPerf)

%% Another approach
nCorr   = sum(strcmp(res.outcome,'RES-CORR'));
nErr	= sum(strcmp(res.outcome,'RES-INCORR'));

nTotal  = nCorr + nErr;
DcdPerf = nCorr/nTotal;
fprintf('Saccade decoder Accuracy: %0.2f\n',DcdPerf)

