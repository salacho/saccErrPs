function [dcdVals,ErrorInfo] = decodeDist2TgtAmp(ampDecoding,ErrorInfo)
%
%
% ampDecoding:          structure. Has the following fields
%   factorError         logical. 1 for error, 0 for correctly BCI decoded trials
%   factorLat           integer. 1 or 2. 1 for left visual field target, 2 for 
%                       right visual field target. Using ipsiIndx and contraIndx 
%                       can be used to determined laterality for each subject
%
% Andres    :   v1.0    : init. 06 Nov. 2014


factorError = ampDecoding.factorError;              
factorDist2Tgt = ampDecoding.factorDist2Tgt;
factorLat = ampDecoding.factorLat;
factorTgt = ampDecoding.factorTgt;
maxAmp = ampDecoding.maxAmp;
minAmp = ampDecoding.minAmp;

%% Max
vbleTxt = {'max','min'};

for iTxt = 1:length(vbleTxt)
    
    % For dist2Tgt
    Xvals = eval(sprintf('ampDecoding.%sAmp;',vbleTxt{iTxt}));
    Y = factorDist2Tgt;
    
    % Transform/z-score data
    nTrials = size(Xvals,1);
    if ~ErrorInfo.analysis.dataTransfDone
        Xvals = dataTransform(Xvals,ErrorInfo);
    end
    
    % Decode linear regression
    X = [ones(nTrials,1) Xvals];         % Pre-pend column of ones to trainX to fit baseline weight
    thetas = pinv(X'*X) * X'*Y;                   % Fit regression weights, using pseudoinverse of autocorrelation matrix
    figure, 
    subplot(2,1,1),boxplot(Xvals),title('Boxplot Xvals')
    subplot(2,1,2),plot(thetas,'*'),title('thetas')
end
    

%% 


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Xvals = dataTransform(Xvals,ErrorInfo)
% function Xvals = dataTransform(Xvals,ErrorInfo)
%
% Transform data using different options given in ErrorInfo.analysis.dataTransform
%
%
% Anuthor   : Andres
%
% Andres    : v1.0  : init. 06 Nov. 2014

if ~ErrorInfo.analysis.dataTransfDone
    fprintf('Transforming data using %s!...\n',ErrorInfo.analysis.dataTransform)
    nTrls = size(Xvals,1);
    switch ErrorInfo.analysis.dataTransform
        case 'none';  % No transform/use raw data -- do nothing!
            % Square-root transform training and test data to approx transform Poisson spike counts to ~normal
        case 'sqrt';
            Xvals = sqrt(Xvals);    % Note: these could be done once, before any data partitioning, for efficiency
            
            % Log (base10) transform training and test data to ~equalize variance of LFP power across frequency bands
        case 'log';
            Xvals = log10(Xvals);   % Note: these could be once, before any data partitioning, for efficiency
            
            % Transform training and test data to z-scores from training-data across-trials mean and standard dev.
        case 'zscore';
            mu  = mean(Xvals, 1);       % Mean response across all training trials, for each predictor
            sig = std(Xvals, 0, 1);     % Standard deviation of response across all training trials
            
            Xvals = (Xvals - repmat(mu,[nTrls 1])) ... % Convert training data to z-scores
                ./ repmat(sig,[nTrls 1]);
            Xvals(:,sig == 0) = 0;      % To deal w/ (very rare) situation where response=0 for all
            
            % Saving values for testing with oldSession decoder
            ErrorInfo.analysis.dataTransfVals.zscoreMu = mu;
            ErrorInfo.analysis.dataTransfVals.zscoreSig = sig;
            
            % Square transform training and test data (usu. to convert LFP/MUA magnitude to power)
        case 'sqr';
            Xvals = Xvals.^ 2;     % Note: these could be once, before any data partitioning, for efficiency
            
            % Classical 'normalized response' transform -- normalize training and test data by max response in any training trial
        case 'max';
            maxVal    = max(Xvals, [], 1);  % Maximum response across all training trials, for each predictor
            %maxVal  =  ErrorInfo.analysis.dataTransfVals.maxMaxVal;
            
            Xvals = Xvals ./ repmat(maxVal,[nTrls 1]);
            Xvals(:,maxVal == 0) = 0;   % To deal w/ (very rare) situation where response=0 for all
            
            % Saving values for testing with oldSession decoder
            ErrorInfo.analysis.dataTransfVals.maxMaxVal = maxVal;
        case 'min';
            minVal    = min(Xvals, [], 1);  % Minimum response across all trials, for each predictor
            %minVal  =  ErrorInfo.analysis.dataTransfVals.minMinVal;
            
            Xvals = Xvals ./ repmat(minVal,[nTrls 1]);
            Xvals(:,minVal == 0) = 0;   % To deal w/ (very rare) situation where response=0 for all
            
            % Saving values for testing with oldSession decoder
            ErrorInfo.analysis.dataTransfVals.minMinVal = minVal;
        otherwise
            warning('No known function was included...') %#ok<*WNTAG>
            ErrorInfo.analysis.dataTransformed = 0;              % Flag data transformation set to zero again
    end
    
    % Flag this analysis was done to avoid repeat
    ErrorInfo.analysis.dataTranfDone = 1;
else
    disp('Data transform for analysis already flagged as done!!!')
end

end


