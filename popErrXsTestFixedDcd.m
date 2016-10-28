function popErrXsTestFixedDcd
%
%
%
%
%
%
%
%
%
%


oldXroot = 'popCS20140324-CS20140411-8-reg-xvals-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';
odDcdRoot = 'popCS20140324-CS20140411-8-reg-train-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600.mat';

newSession1 = 'CS20140409';


%% Checking files are for the same monkey
if strcmpi(oldXroot(4),newSession1(1))
    if strcmpi(oldXroot(4),'c')
    else strcmpi(oldXroot(4),'j')
    end
else  
   error('The values for newSession and oldXroot are not for the same monkey')
end

%% Paths
dirs = initErrDirs;

%% Load oldX train matrix
popPath = fullfile(dirs.DataOut,'popAnalysis');
oldXfilename = fullfile(popPath,oldXroot);
oldX = load(oldXfilename);

%% Load bci session-data from online recording
bciDataFilename = fullfile(strrep(dirs.DataIn,'mat','raw'),newSession1,[newSession1,'-data.mat']);
bciData = load(bciDataFilename);

% Get trials that were decoded (correct and incorrect)
bciTrials = ~isnan(bciData.bci.ErrPs.decoder.feedbackEvt); 
numBCItrials = sum(bciTrials);

% Remember that this coded labels Y with ones when an error is found, hence
% ~(trials == 25), ones for those that are not correct.
errTrials = (bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 11);      % trials that are not correct -> 1
corrTrials = (bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 25);      % trials that are not correct -> 1
nErr = sum(errTrials);
nCorr = sum(corrTrials);

% errTrials = ~(bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 25);      % trials that are not correct -> 1

% New epochs
if isfield(bciData,'errXs'), 
    errXs = bciData.errXs(bciTrials,:);
    errYs = errTrials;
else error('The field errXs does not exist for %s data',newSession1);
end

% Decoder to load
oldDcdFilename = fullfile(popPath,odDcdRoot);
oldDcd = load(oldDcdFilename);

% Data transform
if strcmpi(newSession1(1),'c'), 
    Xvals = (errXs-repmat(oldDcd.decoder.dataTransfVals.zscoreMu,[numBCItrials 1]))...
        ./repmat(oldDcd.decoder.dataTransfVals.zscoreSig,[numBCItrials 1]);
    disp('Getting Z-scores')
else
    Xvals = (errXs);
end
% Test decoder
X = [ones(numBCItrials,1) Xvals];
yHat = X*oldDcd.oldB;                                               % Close to zero for correct, close to one for error

% Error detection performance
corrDcd     = sum(round(yHat(corrTrials)) == 0)/nCorr;
errorDcd    = sum(round(yHat(errTrials)) == 1)/nErr;
overallDcd  = sum(round(yHat) == errTrials)/numBCItrials;           % errTrials => 1s for error, 0s for correct
warning('Error detection performance corr %0.2f, error %0.2f, overall %0.2f',[corrDcd errorDcd overallDcd]) %#ok<*WNTAG>
disp([corrDcd errorDcd overallDcd]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

newSession = 'JS20140415';
popPath = fullfile(dirs.DataOut,'popAnalysis');

%% Load bci session-data from online recording
bciDataFilename = fullfile(strrep(dirs.DataIn,'mat','raw'),newSession1,[newSession1,'-data.mat']);
bciData = load(bciDataFilename);

% Get trials that were decoded (correct and incorrect)
bciTrials = ~isnan(bciData.bci.ErrPs.decoder.feedbackEvt); 
numBCItrials = sum(bciTrials);

% Remember that this coded labels Y with ones when an error is found, hence
% ~(trials == 25), ones for those that are not correct.
errTrials = (bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 11);      % trials that are not correct -> 1

% errTrials = ~(bciData.bci.ErrPs.decoder.feedbackEvt(bciTrials) == 25);      % trials that are not correct -> 1
ErrorInfo.featSelect.trialsPerm = 1;
Xvals = errXs;

ErrorInfo.featSelect.Yvals = errYs;

% New epochs
if isfield(bciData,'errXs'), 
    errXs = bciData.errXs(bciTrials,:);
    errYs = errTrials;
else error('The field errXs does not exist for %s data',newSession1);
end

dcdData.trainX  = [];
dcdData.trainY  = [];
dcdData.testX   = errXs;
dcdData.testY   = errYs;

