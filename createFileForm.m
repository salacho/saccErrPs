function [fileName] = createFileForm(decoder,ErrorInfo,fileType)
% function [fileName] = createFileForm(decoder,ErrorInfo,fileType)
%
% fileType:         string. Type of file to create. Cad be:
%                   'decoder'
%                   ''
%
%
%
% Author    : Andres
%
% andres    : 1.1   : init. Nov 2013
% andres    : 1.2   : Updated fields, included signalProcess.baselineDone
% andres    : 1.3   : updated fields to include decoders trained with data from several sessions. 20 Mars 2014 

%% Global Params 
% Get suffix string ([msStart - msEnd]-filterType&Order-[hzStart - hzEnd])
infoStr = getInfoStr(ErrorInfo);

% Type of data loaded
switch ErrorInfo.epochInfo.typeRef
    case 'lfp',         strgRef = '';
    case 'lapla',       strgRef = 'lapla_';
    case 'car',         strgRef = 'car';
end

% Noisy channels removed
if ErrorInfo.epochInfo.rmvNoisyErrPDone, noisyEpochStr = '-rmvNoisTrials';
else noisyEpochStr = '';
end

%% Decoder used
switch decoder.dcdType
    case 'regress',     dcdStrg = 'reg';
    case 'logitreg',    dcdStrg = 'log';
    case 'lda',         dcdStrg = 'lda';
    otherwise, error('Decoder type does not exist for now...')
end

%% Arrays used
Arrays = '';
if ~isempty(ErrorInfo.signalProcess.arrays)
    for ii = 1:length(ErrorInfo.signalProcess.arrays)                   % (AFSG-20140312) was: for ii = 1:length(decoder.arrays)
        Arrays = [Arrays,'-',ErrorInfo.signalProcess.arrays{ii}];       %#ok<AGROW> % (AFSG-20140312) was: Arrays = [Arrays,'-',decoder.arrays{ii}];
    end
else Arrays = ''; 
end

%% Signal processing
% Baseline removed
if ErrorInfo.signalProcess.baselineDone, Base = '-rmBase';              % (AFSG-20140312) was: if decoder.baselineDone, Base = '-rmBase';
else Base = '';
end
% Predictor Windows
if ~isempty(ErrorInfo.featSelect.predWindows), predWindString = '';     % (AFSG-20140312) was: if ~isempty(decoder.predWindows), predWindString = '';
    for iPred = 1:size(ErrorInfo.featSelect.predWindows,1)              % (AFSG-20140312) was: for iPred = 1:size(decoder.predWindows,1)
        predWindString = sprintf('%s-%i-%i',predWindString...           % (AFSG-20140312) was: predWindString = sprintf('%s-%i-%i',predWindString,decoder.predWindows(iPred,1),decoder.predWindows(iPred,2));
            ,ErrorInfo.featSelect.predWindows(iPred,1),ErrorInfo.featSelect.predWindows(iPred,2));      % (AFSG-20140312) was: predWindString = sprintf('%s-%i-%i',predWindString,decoder.predWindows(iPred,1),decoder.predWindows(iPred,2));
    end
end

%% Feature extraction and selection
% Feature extraction function
switch ErrorInfo.featSelect.predFunction{1}
    case 'none',    featFun = '';
    case 'mean',    featFun = '-mn';
    case 'mean2',   featFun = '-mn2';
    case 'minMax',  featFun = '-mMx';
    otherwise,   	warning('This feature selection approach is not available. Come back later!')
end
% Feature selection
switch ErrorInfo.featSelect.predSelectType
    case 'none',    featSel = '';
    case 'anova',   featSel = '-anov';
    case 'rayleigh',featSel = '-rayl';
    case 'pca',     featSel = '-pca';
    case 'svd',     featSel = '-svd';
    otherwise,      warning('This feature extraction approach is not available. Come back later!')
end

%% Data transform
switch ErrorInfo.decoder.dataTransform
    case 'none',    datTrans = '';
    case 'mean',    datTrans = '-ave';
    case 'sqr',     datTrans = '-sqr';
    case 'sqrt',    datTrans = '-sqrt';
    case 'zscore',  datTrans = '-zsc';
    case 'log',     datTrans = '-log';
    otherwise,      warning('Data transform %s is not yet specified!!!...',ErrorInfo.decoder.dataTransform)
end

%% FileType specific params
switch fileType
    case 'decoder'          % After running a decoder on only ONE sessions
        %% Decoder validation. Type of validation
        % Can be leave-one-out validation ('loov'); cross-validation ('crossval'); no validation, just training ('alltrain')
        switch decoder.typeVal
            case 'alltrain';            % no validation, just training ('alltrain')
                valStr = 'train';
            case 'loov'                 % leave-one-out validation ('loov');
                valStr = 'loo';
            case 'crossval'             % cross-validation
                if decoder.loadDecoder
                    valStr = ['cross',num2str(10)];
                else
                    valStr = ['cross',num2str(decoder.crossValPerc)];
                end
            case 'alltest'              % we do not save decoders when they are from other sessions. We used the 'train' string for the filename of the decoder to load
                valStr = 'train';
                fprintf('Using the string ''%s'' to name the decoder to be loaded!!!\n',valStr)
            otherwise
                valStr = '';
        end
        %% Session
        if length(ErrorInfo.session) > 10           % For population analysis
            warning('Check naming of the files!!!') 
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
        elseif decoder.loadDecoder                  % if loaded old decoder, decoder was trained with data from oldSession
            if length(ErrorInfo.decoder.oldSession) > 10           % For population analysis
                fileRoot = (fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',decoder.oldSession));
            else
                fileRoot = (fullfile(ErrorInfo.dirs.DataOut,decoder.oldSession,decoder.oldSession));
            end
        else                                        % if decoder trained with data from same session
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session);
        end
        %% Save decoder
        fileName = sprintf('%s-%s-%s-%s[%i-%ims]-[%0.1f-%iHz]%s%s%s%s%s%s.mat',fileRoot,...
            dcdStrg,valStr,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
            ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound,...
            Base,featFun,featSel,datTrans,Arrays,predWindString); 

    case 'popDcd'           % After running a decoder on a whole population
        %% Session
        if length(ErrorInfo.session) > 10           % For population analysis
            warning('popSession!!!') 
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
        elseif decoder.loadDecoder                  % if loaded old decoder, decoder was trained with data from oldSession
            fileRoot = (fullfile(ErrorInfo.dirs.DataOut,decoder.oldSession,decoder.oldSession));
        else                                        % if decoder trained with data from same session
            %fileRoot = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session);
            warning('No fileRoot check filename for sessions %s',ErrorInfo.session) %#ok<*WNTAG>
        end
        %% TypeVal
        switch decoder.typeVal
            case 'alltrain';            % no validation, just training ('alltrain')
                valStr = 'train';
            case 'loov'                 % leave-one-out validation ('loov');
                valStr = 'loo';
            case 'crossval'             % cross-validation
                if decoder.loadDecoder
                    valStr = ['cross',num2str(10)];
                else
                    valStr = ['cross',num2str(decoder.crossValPerc)];
                end
            case 'alltest'
                valStr = 'oldDcd';
            otherwise
                valStr = '';
        end
        %% Filename
        fileName = sprintf('%s-%s-%s-%s[%i-%ims]-[%0.1f-%iHz]',fileRoot,...
            dcdStrg,valStr,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
            ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound);
        
    case 'popTrain'
        %% typeVal
        switch decoder.typeVal
            case 'alltrain';            % no validation, just training ('alltrain')
                valStr = 'xvals';
%             case 'loov'                 % leave-one-out validation ('loov');
%                 valStr = 'loo';
%             case 'crossval'             % cross-validation
%                 if decoder.loadDecoder
%                     valStr = ['cross',num2str(10)];
%                 else
%                     valStr = ['cross',num2str(decoder.crossValPerc)];
%                 end
            case 'alltest'
                valStr = 'oldDcd';
            otherwise
                valStr = '';
        end
        %% Session
        if length(ErrorInfo.session) > 10           % For population analysis
            warning('Check naming of the files!!!') %#ok<WNTAG>
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
        elseif decoder.loadDecoder                  % if loaded old decoder, decoder was trained with data from oldSession
            fileRoot = (fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',decoder.oldSession));
        else                                        % if decoder trained with data from same session
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,ErrorInfo.session,ErrorInfo.session);
        end
        %% Filename 
        fileName = sprintf('%s-%s-%s-%s[%i-%ims]-[%0.1f-%iHz]%s%s%s%s%s%s.mat',fileRoot,...
            dcdStrg,valStr,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
            ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound,...
            Base,featFun,featSel,datTrans,Arrays,predWindString); 
        
    case 'popTest'
        %% Session
        if decoder.loadDecoder && (length(ErrorInfo.decoder.oldSession) > 10) && (length(ErrorInfo.session) < 13)      %loading a decoder that is run over a single sessions (hence session < 13) 
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.decoder.oldSession);
        elseif  decoder.loadDecoder  && (length(ErrorInfo.session) > 13)           % For population session
            fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
            warning('No fileRoot check filename for sessions %s',ErrorInfo.session) %#ok<*WNTAG>
        end
        %% TypeVal
        switch decoder.typeVal
            case 'alltrain';            % no validation, just training ('alltrain')
                valStr = 'train';
%             case 'loov'                 % leave-one-out validation ('loov');
%                 valStr = 'loo';
%             case 'crossval'             % cross-validation
%                 if decoder.loadDecoder
%                     valStr = ['cross',num2str(10)];
%                 else
%                     valStr = ['cross',num2str(decoder.crossValPerc)];
%                 end
            case 'alltest'
                if (length(ErrorInfo.session) > 13), valStr = 'oldDcd';    
                else valStr = 'train';                
                end
            otherwise
                valStr = '';
        end
        %% Filename
        if (length(ErrorInfo.session) > 13)
            fileName = sprintf('%s-%s-%s-%s[%i-%ims]-[%0.1f-%iHz]',fileRoot,...
            dcdStrg,valStr,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
            ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound); 
        else
            fileName = sprintf('%s-%s-%s-%s[%i-%ims]-[%0.1f-%iHz]%s%s%s%s%s%s.mat',fileRoot,...
            dcdStrg,valStr,strgRef,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
            ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound,...
            Base,featFun,featSel,datTrans,Arrays,predWindString); 
        end
       
    case 'popEpochs'
        %% Session
        fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
        fileName = sprintf('%s-corrIncorr-%s%s.mat',fileRoot,...
            noisyEpochStr,infoStr.strSuffix); 
    case 'popErrPs'
%         %% Session
%         fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
%         fileName = sprintf('%s-tgtErr&Dist2Tgt-%s%s[%i-%ims]-[%0.1f-%iHz].mat',fileRoot,...
%             strgRef,noisyEpochStr,ErrorInfo.epochInfo.preOutcomeTime,ErrorInfo.epochInfo.postOutcomeTime,...
%             ErrorInfo.epochInfo.filtLowBound,ErrorInfo.epochInfo.filtHighBound); 
    case 'popDist2Tgt'
        %% Session
        fileRoot = fullfile(ErrorInfo.dirs.DataOut,'popAnalysis',ErrorInfo.session);
        fileName = sprintf('%s-dist2Tgt-%s%s%s.mat',fileRoot,...
            strgRef,noisyEpochStr,infoStr.strSuffix); 
        
end