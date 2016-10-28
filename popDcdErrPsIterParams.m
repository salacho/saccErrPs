function popDcdErrPsIterParams(subjName)
% function popDcdErrPsIterParams
%
% Calculates decoder perfromance for different sessions and parameters.
% Values are changed manually in the lines below. 
%
% INPUT 
% subjName:           string. Name of the subject in lower case. Either
%                     'jonah' or 'chico'.
% OUTPUT
% ErrorInfos:         cell [numSessions x 1]. with all the ErrorInfo structures for all the
%                     sessions analyzed
% dcdVals:            cell. Contains the correct, error and overal decoder
%                     performance for all the sessions and iterations of the params. 
%     dcdVals{1}:     meanCorrDcd. Decoder performance for all correct epochs 
%     dcdVals{2}:     meanErrorDcd. Decoder performance for all incorrect epochs
%     dcdVals{3}:     meanOverallDcd. Decoder performance for all epochs
%     dcdVals{4}:     cell with the name and order of the params used. 
%                     i.e. {'sessionList','arrayIndx','rmvBaseline','predFunction','predSelectType','dataTransf'};
% iterParams:         params used to get decoder performance, different
%                     dimensions. Each param is one dim in dcdVals
%     arrayIndx:      matrix. [numOptions x 2]. Has the start and end array used for analysis. [1,1;2,2;1,2;1,3];        % (AFSG-20140313) was arrayIndx = [1,1;2,2;3,3;1,2;1,3;2,3;4,4];
%     availArrays:    cell. Strings with the names of the arrays. {'PFC','SEF','FEF'};              
% 	  rmvBaseline:    logical. Remove baseline from each trial?. [true, false];
% 	  predFunction:   cell. String values for type of function (and time windows) used for getting the predictors. {'mean','mean2','minMax'};        
% 	  predSelectType: cell. String values for type of feature selection. {'none','anova'};
% 	  dataTransf:     cell. String values for data transformation. {'none','log','sqr','sqrt','mean','zscore'};
% sessionList:        cell. List of sessions used to extract the data in
%                     dcdVals and ErrorInfos.
% 
% All this data can be found in a file saved with followin naming structure: 
% 'popFirstSession-lastSession-totalSessions-oldDecoder-eppochsParams-dcdPerf-IterParams.mat'
% i.e. 'popCS20120815-CS20130618-65-reg-cross10-[600-600ms]-[1.0-10Hz]-dcdPerf-IterParams.mat'
%
% Author    : Andres
%
% andres    : 1.1   : initial. 07 March 2014
% andres    : 1.2   : session epochs only need to be loaded once (faster processing)
% andres    : 1.3   : updated Jonah compatibility 

% Paths
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved
userEmail = 'salacho1@gmail.com';

%% Params iterated (that will change)
switch subjName
    case 'chico', [sessionList,~] = chicoBCIsessions(0,1);  availArrays = {'PFC','SEF','FEF'};              % name of the arrays or source of the data
    case 'jonah', sessionList = jonahBCIsessions;           availArrays = {'SEF','FEF','PFC'}; 
end

%arrayIndx      = [1,1;2,2;1,2;1,3];        % (AFSG-20140313) was 
arrayIndx       = [1,1;2,2;3,3;1,2;1,3;2,3;4,4];
rmvBaseline     = [true, false];
predFunction    = {'mean','mean2','minMax'};        % prediction functions
predSelectType  = {'none','anova'};
dataTransf      = {'none','log','sqr','sqrt','mean','zscore'};
nSessions       = length(sessionList);

%% All sessions
% [sessionList,~] = chicoBCIsessions;

%% Initializing vbles
meanCorrDcd     = nan(nSessions,length(arrayIndx),length(rmvBaseline),length(predFunction),length(predSelectType),length(dataTransf));
meanErrorDcd    = nan(nSessions,length(arrayIndx),length(rmvBaseline),length(predFunction),length(predSelectType),length(dataTransf));
meanOverallDcd  = nan(nSessions,length(arrayIndx),length(rmvBaseline),length(predFunction),length(predSelectType),length(dataTransf));

%% Iterating sessions...
for iSession = 7:length(sessionList)
    tStart = tic;
    session = sessionList{iSession};
    % Setup initial params
    ErrorInfo = setDefaultParams(session,dirs);
    % Load epochs (this does not depend on decoding params)
    [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
    
    %% Iterating different params
    for iArray = 1:length(arrayIndx)                            % Arrays used for decoding
        for iBaseline = 1:length(rmvBaseline)                   % Remove baseline
            for iPredFun = 1:length(predFunction)               % pred function 'mean','minMax'
                for iPredType = 1:length(predSelectType)        % pred. 'none','anova'
                    for iTrans = 1:length(dataTransf)           % data transf. 'log','sqr'
                        %% Update ErrorInfo
                        ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,iArray,iBaseline,iPredFun,iPredType,iTrans,...
                            availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf);
                        
                        %% Signal processing
                        [corrEpochsProcess,incorrEpochsProcess,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
                        
                        %% Feature extraction and selection
                        [Xvals,ErrorInfo] = selectFeatures(corrEpochsProcess,incorrEpochsProcess,ErrorInfo);
                        
                        %% Detecting presence of ErrPs
                        [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo);
                        
                        %% Saving the results
                        ErrorInfos{iSession,iArray,iBaseline,iPredFun,iPredType,iTrans} = ErrorInfo; %#ok<*NASGU>
                        %dcdErrors{iSession,iArray,iBaseline,iPredFun,iPredType,iTrans}  = decoder;
                    
%                         dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanCorrDcd    = decoder.performance.meanCorrDcd; %#ok<*AGROW>
%                         dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanErrorDcd   = decoder.performance.meanErrorDcd;
%                         dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanOverallDcd = decoder.performance.meanOverallDcd;
                        
                        meanCorrDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans)    = decoder.performance.meanCorrDcd; %#ok<*AGROW>
                        meanErrorDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans)   = decoder.performance.meanErrorDcd;
                        meanOverallDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans) = decoder.performance.meanOverallDcd;
                        
                        % Deleting extra vbles
                        clear Xvals decoder corrEpochsProcess incorrEpochsProcess
                    end
                end
            end
        end
    end
    tElapsed = toc(tStart);
    sprintf('It took %0.2f seconds to run session %s...\n',tElapsed, session)
    disp('')
    %% Email end of ErrP epoching
    emailme('dataconversionstate@gmail.com','DataConversionState','Finished iterParams DcdErrPs',['Finished ',session,' in ',num2str(tElapsed/60),' min.'],userEmail);
end

%% Saving decoded values for all params
dcdVals{1} = meanCorrDcd;
dcdVals{2} = meanErrorDcd;
dcdVals{3} = meanOverallDcd;
dcdVals{4} = {'sessionList','arrayIndx','rmvBaseline','predFunction','predSelectType','dataTransf'};

%% Saving the result
iterParams.arrayIndx    = arrayIndx;
iterParams.availArrays  = availArrays;
iterParams.rmvBaseline  = rmvBaseline;
iterParams.predFunction = predFunction;
iterParams.predSelectType = predSelectType;
iterParams.dataTransf   = dataTransf;           %#ok<*STRNU>

% Session for the population 
decoder = ErrorInfo.decoder;
if ErrorInfo.decoder.loadDecoder            % Add loaded decoder
    ErrorInfo.session = sprintf('pop%s-%s-%i-%s',sessionList{1},sessionList{end},length(sessionList),ErrorInfo.decoder.oldSession);
else
    ErrorInfo.session = sprintf('pop%s-%s-%i',sessionList{1},sessionList{end},length(sessionList));
end
% Filename
rootFilename = createFileForm(decoder,ErrorInfo,'popDcd');                 %#ok<*NASGU>
saveFilename = sprintf('%s-dcdPerf-IterParams.mat',rootFilename);
%% Save files
%save(saveFilename,'ErrorInfos','iterParams','dcdErrors','dcdVals','sessionList') 
save(saveFilename,'ErrorInfos','iterParams','dcdVals','sessionList') 

% %% Organizing in matrix, not cell array
% nSessions = length(sessionList);
% meanCorrDcd     = nan(nSessions,length(iterParams.arrayIndx),length(iterParams.rmvBaseline),length(iterParams.predFunction),length(iterParams.predSelectType),length(iterParams.dataTransf));
% meanErrorDcd    = nan(nSessions,length(iterParams.arrayIndx),length(iterParams.rmvBaseline),length(iterParams.predFunction),length(iterParams.predSelectType),length(iterParams.dataTransf));
% meanOverallDcd  = nan(nSessions,length(iterParams.arrayIndx),length(iterParams.rmvBaseline),length(iterParams.predFunction),length(iterParams.predSelectType),length(iterParams.dataTransf));
% 
% for iSession = 1:nSessions
%     for iArray = 1:length(iterParams.arrayIndx)                            % Arrays used for decoding
%         for iBaseline = 1:length(iterParams.rmvBaseline)                   % Remove baseline
%             for iPredFun = 1:length(iterParams.predFunction)               % pred function 'mean','minMax'
%                 for iPredType = 1:length(iterParams.predSelectType)        % pred. 'none','anova'
%                     for iTrans = 1:length(iterParams.dataTransf)           % data transf. 'log','sqr'
%                         meanCorrDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans)    = dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanCorrDcd;
%                         meanErrorDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans)   = dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanErrorDcd;
%                         meanOverallDcd(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans) = dcdVals(iSession,iArray,iBaseline,iPredFun,iPredType,iTrans).meanOverallDcd;
%                     end
%                 end
%             end
%         end
%     end
% end

end
