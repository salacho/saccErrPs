function sessionsList = sfnSAbstractSessionList(subjName)
%
%
%
%
% Andres:
% 23 Oct 2014

switch lower(subjName)
    case 'chico', sessionsList = {'CS20121012';'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026'};  %Chicos SfN Abstract. 
    case 'jonah', sessionsList = {'JS20140318';'JS20140319';'JS20140320';'JS20140321';'JS20140324';'JS20140325';'JS20140326';'JS20140327';'JS20140328'};                            %Jonahs SfN Abstract. 
end
