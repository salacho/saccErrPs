function meanDcdPerf_AbstractSfN
% function meanDcdPerf_AbstractSfN
%
% Mean ErrPs, decoder error detection values used in the SfN abstract submitted 8th May 2014.
% For Chico the mean dcdErrPsPerf values for offline decoding was 0.9686, using the following approach:
% reg-cross10-[600-600ms]-[1.0-10Hz]-mn-zsc-SEF-50-100-100-150-150-250-250-350-350-600
%
% For Jonah the mean dcdErrPsPerf values for offline decoding was , using the following approach:
% reg-cross10-[600-600ms]-[1.0-10Hz]-mn-zsc-FEF-PFC-50-100-100-150-150-250-250-350-350-600
%
%
% Author    :   Andres 
% andres    :   init    : 6 May 2014 

%% Subject name
subjName = 'jonah';
% Email recepient
userEmail = 'salacho1@gmail.com';

switch subjName
    case 'chico', sessionsList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract. 
    case 'jonah', sessionsList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract. 
end
            
%% Running mainErrPs for each session
for iSes = 1:length(sessionsList)
    tStart = tic;
    session = sessionsList{iSes};
    fprintf('Running analysis for session %s...\n',session)
    %mainErrRPs(session,0,0)                   % decodeErrP = 0. getPlots = 0. Do not run decoder, only extract epochs from mat files
    [ErrorInfo{iSes},decoder{iSes}] = mainErrRPs(session,1,0);                    % decodeErrP = 0. getPlots = 1. Do not run decoder, get plots.
    close all
    
    % DcdErrPs Mean values
    meanCorrDcd(iSes)    = decoder{iSes}.performance.meanCorrDcd;
    meanErrorDcd(iSes)   = decoder{iSes}.performance.meanErrorDcd;
    meanOverallDcd(iSes) = decoder{iSes}.performance.meanOverallDcd;
    
    %% Email me, end of ErrP analysis
    tElapsed = toc(tStart);
    emailme('dataconversionstate@gmail.com','DataConversionState','Finished mainErrPs epoching and plots',['Finished ',session,' in ',num2str(tElapsed/60),' min.'],userEmail);
end

fprintf('%s mean decoder error detection for all %i sessions is %0.2f...\n',subjName,length(sessionsList),100*mean(meanCorrDcd));

end
