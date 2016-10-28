function popDcdErrPs
% function popDcdErrPs
%
% Loads the Error signals and calculates the decoder performance
%
% You should be using popDcdErrPsIterParams.m instead!!!
%
%  For reference these are the sessions in chicoSession by 14 Jan 2013
% allChicoSessionList = ...
%     {'CS20120815',    'CS20120817',    'CS20120824',    'CS20120912',...
%     'CS20120913',    'CS20120914',    'CS20120917',    'CS20120918',...
%     'CS20120919',    'CS20120920',    'CS20120921',    'CS20120924',...
%     'CS20120925',    'CS20120926',    'CS20120927',    'CS20120928',...
%     'CS20121001',    'CS20121002',    'CS20121003',    'CS20121004',...
%     'CS20121005',    'CS20121012',    'CS20121015',    'CS20121016',...
%     'CS20121017',    'CS20121018',    'CS20121019',    'CS20121022',...
%     'CS20121023',    'CS20121024',    'CS20121025',    'CS20121026',...
%     'CS20121105',    'CS20121106',    'CS20121108',    'CS20121113',...
%     'CS20121114',    'CS20121115',    'CS20121116',    'CS20121119',...
%     'CS20121120',    'CS20121121',    'CS20121126',    'CS20121127',...
%     'CS20121128',    'CS20130410',    'CS20130411',    'CS20130412',...
%     'CS20130415',    'CS20130416',    'CS20130417',    'CS20130418',...
%     'CS20130422',    'CS20130423',    'CS20130424',    'CS20130425',...
%     'CS20130426',    'CS20130428',    'CS20130429',    'CS20130430',...
%     'CS20130501',    'CS20130502',    'CS20130503',    'CS20130617',...
%     'CS20130618'};
%
% Andres F. Salazar-Gomez. salacho@bu.edu
% Created December 2013
% Last modified 14 Jan 2014

warning('You should be using popDcdErrPsIterParams.m instead!!!')

if 1 == 0
    % Getting all sessions
    cd ../helpers/
    [allChicoSessionList,~] = chicoBCIsessions(1);
    
    % For preliminary Data
    %allChicoSessionList = {allChicoSessionList{2:8,:}}';
    
    cd ../ErrRPs/
    
    kk = 0;                                 % Flag for pop Results vble
    userEmail = 'salacho1@gmail.com';       % email me you finished a session
    
    % Start loop
    for iSess = 1:length(allChicoSessionList)
        % Main params
        dirs = initErrDirs;                 % Paths where all data is loaded from and where chronic Recordings analysis are saved
        session = allChicoSessionList{iSess};
        mainParams = setDefaultParams(session,dirs);
        % Getting filename
        switch mainParams.epochInfo.typeRef           % type of data from which epochs are taken from
            case 'lfp',  strgRef = '';
            case 'lapla',strgRef = 'lapla_';
            case 'car',  strgRef = 'car';
        end
        
        % AFSG (20145-03-19)
        %     if str2double(session(3:end)) >= 20121003
        %         mainParams.freqRange(1) = 0.6;
        %     end
        
        loadFilename = sprintf('%s-corrIncorrEpochs-%s[%i-%ims]-[%0.1f-%iHz].mat',fullfile(dirs.DataOut,session,session),...
            strgRef,mainParams.epochInfo.preOutcomeTime,mainParams.epochInfo.postOutcomeTime,mainParams.epochInfo.freqRange(1),mainParams.epochInfo.freqRange(2));
        
        % If file exists, load it
        if exist(loadFilename,'file') %&& ~mainParams.epochInfo.NewErrPs
            disp(mainParams)
            kk = kk + 1;        % counter for decoder sessions
            
            % AFSG (20145-03-19)
            %         % Updating decoder info, replacing the one from the loaded file in ErrorInfo
            %         ErrorInfo.decoder = mainParams.decoder;
            
            %         % Changing freq. temporarily
            %         if str2double(ErrorInfo.decoder.oldSession(3:end)) >= 20121003
            %             ErrorInfo.epochInfo.filtLowBound = 0.6;
            %         else
            %             ErrorInfo.epochInfo.filtLowBound = 1;
            %         end
            
            arrayIndx       = [2,2];
            availArrays     = {'PFC','SEF','FEF'};
            rmvBaseline     = false;
            predFunction    = {'mean'};
            predSelectType  = {'none'};
            dataTransf      = {'zscore'};
            
            % Setup initial params
            ErrorInfo = setDefaultParams(session,dirs);
            
            %% Update ErrorInfo with the best possible (after 'some' analysis)!!!
            ErrorInfo = popDcdErrPsUpdateErrorInfo(ErrorInfo,1,1,1,1,1,...
                availArrays,arrayIndx,rmvBaseline,predFunction,predSelectType,dataTransf);
            
            % Load epochs (this does not depend on decoding params)
            [corrEpochs,incorrEpochs,~,ErrorInfo] = loadErrRPs(ErrorInfo);
            
            %% Signal processing
            [corrEpochsProcess,incorrEpochsProcess,ErrorInfo] = signalProcess(corrEpochs,incorrEpochs,ErrorInfo);
            
            %% Feature extraction and selection
            [Xvals,ErrorInfo] = selectFeatures(corrEpochsProcess,incorrEpochsProcess,ErrorInfo);
            
            %% Detecting presence of ErrPs
            [ErrorInfo,decoder] = decodeErrRPs(Xvals,ErrorInfo);
            
            % Saving results
            % popDcdResults.loadDecoder(kk) = ErrorInfo.decoder.loadDecoder; popDcdResults.nIter(kk) = ErrorInfo.decoder.nIter; popDcdResults.nCorrTrain(kk) = ErrorInfo.decoder.nCorrTrain; popDcdResults.nIncorrTrain(kk) = ErrorInfo.decoder.nIncorrTrain; popDcdResults.nCorrTest(kk) =  ErrorInfo.decoder.nCorrTest; popDcdResults.nIncorrTest(kk) = ErrorInfo.decoder.nIncorrTest; popDcdResults.nCov(kk) = ErrorInfo.decoder.nCov;
            if ~strcmp(ErrorInfo.decoder.typeVal,'alltrain')
                popDcdResults.sessions{kk}  = session;
                popDcdResults.typeVal{kk}   = ErrorInfo.decoder.typeVal;
                popDcdResults.dcdType{kk}   = ErrorInfo.decoder.dcdType;
                popDcdResults.CorrDcd(kk)   = decoder.performance.meanCorrDcd;
                popDcdResults.ErrorDcd(kk)  = decoder.performance.meanErrorDcd;
                popDcdResults.OverallDcd(kk)= decoder.performance.meanOverallDcd;
                popDcdResults.decoder{kk}   = decoder;
            end
            
            % Email end of ErrP epoching
            emailme('dataconversionstate@gmail.com','DataConversionState','Finished allTrain ErrPs epochs',['Finished ',session],userEmail);
            % Saving last structure to name popResults
            saveErrorInfo = ErrorInfo;
        end
        % Reseting vbles
        clear mainParams decoder ErrorInfo corrEpochs incorrEpochs loadFilename
    end
    
    % Saving population decoding values
    if saveErrorInfo.decoder.loadDecoder            % Add loaded decoder
        saveErrorInfo.session = sprintf('pop%s-%s-%i-%s',allChicoSessionList{1},allChicoSessionList{end},kk,saveErrorInfo.decoder.oldSession);
    else
        saveErrorInfo.session = sprintf('pop%s-%s-%i',allChicoSessionList{1},allChicoSessionList{end},kk);
    end
    
    if 1 == 0
        saveFilename = createFileForm(popDcdResults.decoder{1},saveErrorInfo,'popDcd');                 %#ok<*NASGU>
        save(saveFilename,'popDcdResults','saveErrorInfo')
    end
    
end