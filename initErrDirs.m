function [dirs] = initErrDirs(typeAnal)
%
% This function defines directory and path initializations for code.
%
% The function determines appropriate Code and Data directories to use for 
% given hostname you are running Matlab on. Users must add list of appropriate 
% directories below w/in a switch case for their own hostname.
% 
% OUTPUT: 
%
%   dirs:           Struct containing list of directory names needed to run 
%                   the data analysis code:
%     Code:         Dir w/ data analysis code.
%     DataIn:       Dir where 'raw' datafiles are to be read from.
%     DataOut:      Dir where analyzed datafiles and figures are to be written to 
%
% This code is pretty simmilar to the one used in the BlackRock to npl
% (init2npl.m) dataConversion code set by Scot Brincat.

if nargin == 0, typeAnal = 'loadSpec'; end

% Determine hostname of system 
[~,host]= system('hostname');
host      = deblank(host);

%% Set appropriate directories for code, data input and output, based on system hostname.
switch host
    case 'Miller-PC'
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'H:\Salachos_backup\Code\chronicRecord';          %Add dirs where all code is located
        dirs.DataOut    = 'C:\Users\Andres\Documents\Data\chico\mat';       %Add path where all processed data will be saved
    case 'Scott-Analysis';
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'C:\Users\sbrincat\analysis\cvm\offlineBCI';      %Add dirs where all code is located
        dirs.DataOut    = 'C:\Users\sbrincat\data\cvm\crunch\offlineBCI';   %Add path where all processed data will be saved
    case 'MISHA-DESK'
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'C:\Users\Andres\Documents\Code\chronicRecord';   %Add dirs where all code is located
        dirs.DataOut    = 'D:\Analysis\dlysac\ErrRPs';                      %Add path for chronic Recording analysis to be saved 
        dirs.BCIparams  = '\\millerlab.mit.edu\common\bciproject\cvm\raw';  %Add path where all BCIparams are located
        dirs.PTB        = 'C:\Users\Andres\Documents\MATLAB\toolbox\Psychtoolbox'; % Add path to PsychToolbox
    case 'salacho-laptop';
        dirs.Code       = 'C:\Users\salacho\Documents\Code\monkeyCode\saccErrPs';   % Dir w/ data analysis Code
        dirs.DataIn     = 'E:\Data\saccErrP';        % Dir w/ raw datafiles
        dirs.DataOut    = 'E:\Data\saccErrP'; 	% Dir to output analyzed datafiles and figures to
        dirs.helpers    = 'C:\Users\salacho\Documents\Code\helpers';                % Dir to multiple function used for general analysis

        dirs.chronux    = 'C:\Users\salacho\Documents\MATLAB\Chronux_matlab\chronux_code_2_00';            % Add path to chronux toolbox
        dirs.BCIparams  = 'E:\Data\saccErrP';                  %Add path where all BCIparams are located
        dirs.eeglab     = 'C:\Users\salacho\Documents\MATLAB\eeglab9_0_4_5s';       % Folder to eeglab toolbox
        dirs.PTB        = 'C:\Program Files\MATLAB\toolbox\Psychtoolbox'; % Add path to PsychToolbox
        addpath(dirs.helpers)
    
    case 'Salachos-CNS'
        dirs.Code       = 'C:\Users\salacho\Documents\Code\ErrRPs';      % Dir w/ data analysis Code
        dirs.helpers   	= 'C:\Users\salacho\Documents\Code\helpers';      % Dir w/ helpers analysis Code
        
        switch typeAnal
            case 'getRaw'
                dirs.DataIn     = 'Z:\bci\mat';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
                dirs.DataOut    = 'E:\Data_20160505\dlysac\ErrRPs';
            case 'getSpec'
                dirs.DataIn     = 'E:\Data_20160505\dlysac\ErrRPs';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
                dirs.DataOut    = 'E:\Data_20160505\dlysac\ErrRPs';
            case 'getSpecJonah'            
                dirs.DataIn     = 'C:\Users\salacho\Documents\Analysis\dlysac\ErrRPs\';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
                dirs.DataOut    = 'C:\Users\salacho\Documents\Analysis\dlysac\ErrRPs\';
            case 'loadSpec'
                dirs.DataIn     = 'E:\Data\saccErrP';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
                dirs.DataOut    = 'E:\Data\saccErrP';
        end
        %dirs.DataOut    = 'C:\Users\salacho\Documents\Analysis\dlysac\ErrRPs';  % Local Dir to output analyzed datafiles and figures too
        %dirs.BCIparams  = 'Z:\bci\raw';                  %Add path where all BCIparams are located
        dirs.BCIparams  = 'E:\Data\saccErrP';                  %Add path where all BCIparams are located
        dirs.PTB        = 'C:\Users\salacho\Documents\MATLAB\toolbox\Psychtoolbox'; % Add path to PsychToolbox
        dirs.chronux    = 'C:\Users\salacho\Documents\MATLAB\chronux';            % Add path to chronux toolbox
        addpath(dirs.helpers)
    
    case 'scc1'
        dirs.Code       = '/usr3/graduate/salacho/salacho/Code/saccErrPs';      % Dir w/ data analysis Code
        dirs.helpers   	= '/usr3/graduate/salacho/salacho/Code/helpers';      % Dir w/ helpers analysis Code
        dirs.DataIn     = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
        dirs.DataOut    = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';
        dirs.BCIparams  = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';                  %Add path where all BCIparams are located
        dirs.PTB        = '/usr3/graduate/salacho/salacho/Code/PsychToolbox'; % Add path to PsychToolbox
        dirs.chronux    = '/usr3/graduate/salacho/salacho/Code/Chronux_matlab/chronux_code_2_00/chronux';            % Add path to chronux toolbox

    otherwise
        dirs.Code       = '/usr3/graduate/salacho/salacho/Code/saccErrPs';      % Dir w/ data analysis Code
        dirs.helpers   	= '/usr3/graduate/salacho/salacho/Code/helpers';      % Dir w/ helpers analysis Code
        dirs.DataIn     = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
        dirs.DataOut    = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';
        dirs.BCIparams  = '/projectnb/busplab/salacho/Data/saccErrPs/dlysac/ErrRPs';                  %Add path where all BCIparams are located
        dirs.PTB        = '/usr3/graduate/salacho/salacho/Code/PsychToolbox'; % Add path to PsychToolbox
        dirs.chronux    = '/usr3/graduate/salacho/salacho/Code/Chronux_matlab/chronux_code_2_00/chronux';            % Add path to chronux toolbox
end

% Set up path so code is accessible to Matlab
addpath(dirs.DataIn);               % Add dir w/ your Data path
addpath(genpath(dirs.Code));        % Add dir w/ your code path
addpath(genpath(dirs.PTB));         % Add dir w/PsychToolbox code
addpath(genpath(dirs.chronux));     % Add dir w/chronux code
addpath(genpath(dirs.helpers));        % Add dir w/ your code path