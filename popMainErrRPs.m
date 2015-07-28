function popMainErrRPs
% function popMainErrRPs
%
sessionList = {...%'CS20120816';'CS20120817';...
    'CS20120912';'CS20120913';'CS20120914';...
    'CS20120918';'CS20120919';'CS20120920';'CS20120921';...
    'CS20120925';'CS20120926';'CS20120927';'CS20120928'};

%sessionList = {'CS20121001';'CS20121002';'CS20121003';'CS20121004';'CS20121005'};

% sessionList = {'CS20121010';'CS20121011';'CS20121012';...
%     'CS20121015';'CS20121016';'CS20121017';'CS20121018';'CS20121019';...
%     'CS20121022';'CS20121023';'CS20121024';'CS20121025';'CS20121026';...
%     'CS20121105';'CS20121106';'CS20121108'};

% sessionList = {'CS20121113';'CS20121114';'CS20121115';'CS20121116';...
%     'CS20121119';'CS20121120';'CS20121121';...
%     'CS20121126';'CS20121127';'CS20121128'};


dataTypes = {'lfp'}; %'lapla',

for iSes = 1:length(sessionList)
    session = sessionList{iSes};
    for ii = 1:length(dataTypes)
        dataType = dataTypes{ii};
        disp(sprintf('Running analysis for dataType %s...',dataType ))
        disp(sprintf('Running analysis for session %s...\n',session))
        mainErrRPs(session,0,dataType)
        close all
    end
end
