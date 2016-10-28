function [sessionsList,sessionsBCIperf] = onlineErrPsessions(subjName)
% function [sessionsList,sessionsBCIperf] = onlineErrPsessions(subjName)
%
% Usage: sessionsList = onlineErrPsessions('chico');
%
% Gives a list of the sessions and saccade BCI perfromance, for a given subject, 
% that used online decoder error detection.  
%
% INPUT
% subjName:         string. Name of the subject. Can be 'chico', or 'jonah'
%
% OUTPUT
% sessionsList:     cell. List of sessions for the given subjName.
% sessionsBCIperf:  vector. Online saccade BCI decoder perfromance values.
%
%
% Author    :   Andres
% andres    :   1.1     :   init. Created the file. 12 May 2014.


% Online ErrPs
switch subjName
    case 'jonah'
        sessionsList = {...%'JS20140411';...this JS20140411 did not have any testing trials...
            'JS20140414';'JS20140415';'JS20140416';'JS20140417';'JS20140418';...
            'JS20140421';'JS20140422';'JS20140423';'JS20140424';'JS20140425'};
        sessionsBCIperf = [40.21887825,51.21693122,52.21987315,49.6835443,45.07042254,...
            44.53125,42.12962963,44.06580494,44.63705309,43.5208];
    case 'chico'
        sessionsList = {...%'CS20140408'    %'CS20140408' is not converted to mat files yet
            'CS20140409';'CS20140410';'CS20140411';...
            'CS20140414';'CS20140415';'CS20140416';'CS20140417';'CS20140418';...
            'CS20140421';'CS20140422';'CS20140423';'CS20140424';'CS20140425'};
        sessionsBCIperf =[...%62.69430052   %'CS20140408' is not converted to mat files yet
            78.29787234,70,73.43324251,...
            63.40425532,70.43235704,70.92436975,70.46263345,76.7699115,...
            63.33333333,73.07692308,64.25233645,70.53701016,73.0263];
end

end
